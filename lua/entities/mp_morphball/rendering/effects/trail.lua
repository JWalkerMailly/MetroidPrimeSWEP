
local MorphBallTrail         = WGLComponent:New(MORPHBALL, "Trail");
MorphBallTrail.BoostMaterial = Material("entities/morphball/boost");
MorphBallTrail.Resolution    = 2;
MorphBallTrail.WayPoints     = 10;
MorphBallTrail.ShouldDraw    = false;

local debugTrail = Material("entities/debug/debug_wireframe");

function MorphBallTrail:Initialize(state, pos, angles)

	-- Generate catmullrom spline with specified resolution.
	self.Trail = WGL.CatmullRom:New(self.Resolution);

	-- Add initial waypoints to catmull-rom spline to avoid artifacting.
	for i = 1, self.WayPoints do
		self.Trail:AddWayPoint(pos, angles:Right());
	end
end

function MorphBallTrail:DrawMesh(trail, pos, angles, material, size, uvOffset, uvScroll, length)

	-- Trail nodes setup.
	local nodes      = trail:GetNodes();
	local nodesCount = #nodes;
	local ups        = trail.Ups;
	local up         = ups[1] * size;

	-- Draw trail mesh.
	render.SetMaterial(material);
	if (GetConVar("developer"):GetInt() > 1) then render.SetMaterial(debugTrail); end
	mesh.Begin(MATERIAL_TRIANGLE_STRIP, nodesCount * 2);
	for i = 1, nodesCount do

		-- Generate scrolling UV texture coordinates based on current velocity. The trail texture
		-- needs to be scrolled along the mesh in order to avoid jitter when generating new
		-- mesh points. This way, the leftside of the mesh is always out of the last quad before
		-- being discarded.
		local curTexCoord = math.Clamp(((((i - 1) / (nodesCount - 1)) * uvOffset + (1 - uvOffset)) - uvScroll) * length, uvOffset, 1);

		-- Generate dynamic trail mesh. The mesh is positionned at the center of the morphball,
		-- We extend the lower and upper bounds in opposing directions in order to get the banking
		-- effect without using too much math intensive operations.
		local curNode = nodes[i];
		if (i > 1) then up = ups[i - 1] * size; end

		mesh.Position(pos + curNode + up);
		mesh.TexCoord(0, curTexCoord, 0);
		mesh.AdvanceVertex();

		mesh.Position(pos + curNode - up);
		mesh.TexCoord(0, curTexCoord, 1);
		mesh.AdvanceVertex();
	end
	mesh.End();
end

function MorphBallTrail:Draw(state, pos, angles, sway, velocity, material, radius, frametime)

	local size     = radius - 1.5;
	local angVel   = velocity:Length() / size;

	-- Reinitialize trail and avoid rendering under a certain angular velocity.
	if (angVel < 5) then

		if (self.ShouldDraw) then
			self.ShouldDraw = false;
			self.Initialized = false;
		end

		return;
	else
		self.ShouldDraw = true;
	end

	-- 3D trail setup.
	local trail    = self.Trail;
	local trailPos = Vector(0, 0, size);
	local center   = pos - trailPos;
	local waypoint = self.Trail.WayPoints[1];
	local length   = WGL.Clamp(pos:DistToSqr(waypoint) / 6000);

	-- Setup morphball ghost trail blending.
	if (self.LastWaypoint == nil) then
		self.LastWaypoint    = center;
		self.LastLength      = 0;
		self.LastTrailRatio  = 1;
		self.LastBoostRatio  = 0;
		self.NextTrailBoost  = CurTime();
	end

	-- Compute boost and trail ratios. This will be used to blend between the boost trail and the regular
	-- trail. The trail is a 3D mesh, material blending is not an option in order to reproduce the original.
	if (state:Boosting() && CurTime() > self.NextTrailBoost) then
		self.NextTrailBoost = CurTime() + state.Constants.Charge.Full * 2;
		self.LastTrailRatio = 0;
		self.LastBoostRatio = 1;
	else
		self.LastTrailRatio = Lerp(frametime * 4, self.LastTrailRatio, 1);
		self.LastBoostRatio = Lerp(frametime * 0.15, self.LastBoostRatio, 0);
	end

	-- Trail length ratio.
	if (length > 0.8) then
		length = Lerp(frametime, self.LastLength, length);
	end

	-- Compute waypoint distances. This will be used for mesh generation and texture scrolling.
	-- Trail texture coordinates setup. About half of the original texture will be discarded.
	local bank      = angles:Right();
	local distance  = center:Distance(self.LastWaypoint);
	local uvScroll  = (self.Resolution * WGL.Clamp(distance / angVel)) / ((self.WayPoints - 3) * self.Resolution) * 0.5;

	-- Generate new mesh points according to waypoint distances relative to angular velocity.
	if (distance > angVel && angVel > 0.1) then
		self.LastWaypoint = center;
		trail:RemoveFirstWayPoint();
		trail:AddWayPoint(center, bank);
	end

	-- Render 3D mesh for the regular trail.
	local lengthSway = length * sway;
	trail:MoveLastSegment(center, center, bank);
	self:DrawMesh(trail, trailPos, angles, material, size, 0.5, uvScroll, lengthSway * self.LastTrailRatio);

	-- Only render the boost mesh if the ratio is big enough, this is mainly for optimization purposes.
	if (self.LastBoostRatio > 0.1) then
		self:DrawMesh(trail, trailPos, angles, self.BoostMaterial, size, 0.5, uvScroll, lengthSway * self.LastBoostRatio);
	end

	-- Save current trail length for interpolation.
	self.LastLength = length;
end