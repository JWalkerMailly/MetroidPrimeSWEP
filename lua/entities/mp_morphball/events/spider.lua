
function MORPHBALL:SurfaceValid(surfaceProps)
	if (!surfaceProps) then return false; end
	return game.MetroidPrimeSpiderSurfaces.Cache[util.GetSurfaceData(surfaceProps).name];
end

function MORPHBALL:UseSpider(owner, boosting, bombJumping)

	-- This function should only called once per frame since it calls to SpiderGroundTrace.
	local powersuit = self:GetPowerSuit();
	return powersuit.MorphBall:IsSpiderEnabled()
		&& self:WaterLevel() < 3
		&& owner:KeyDown(IN_SPEED)
		&& self:SpiderGroundTrace(owner, boosting, bombJumping);
end

function MORPHBALL:SpiderGroundTrace(owner, boosting, bombJumping)

	-- Trace data setup; 3 is not a magic number. Since we will be hit scanning from the center
	-- of the morphball, we multiply the radius by 3 in order to scan 1 full morphball width in front of us.
	local origin        = self:GetPos();
	local velocity      = self:GetVelocity() - self:GetSurfaceVelocity();
	local velAngle      = velocity:Angle();
	local traceLength   = self.Radius * 3;
	local surfaceNormal = self:GetSurfaceNormal();

	-- Setup spider ball ground trace data. This will drive the ground normal.
	local groundDir     = !bombJumping && (surfaceNormal * traceLength) || -(WGL.UpVec * traceLength);
	local groundEndPos  = origin - groundDir;
	local groundTrace   = util.TraceLine({ start = origin, endpos = groundEndPos, filter = { owner, self } });
	debugoverlay.Line(origin, groundEndPos, FrameTime() * 2, Color(0, 255, 0));

	-- If we are freefalling, change spider trace to use eye angles.
	local groundValid   = groundTrace.Hit && self:SurfaceValid(groundTrace.SurfaceProps);
	if (!groundValid && !boosting) then velAngle = owner:EyeAngles(); end

	-- Setup spider ball wall trace data. This will scan for walls in front of us. It is important
	-- to not normalize this vector. Velocity will play an important role when we are boosting or bomb
	-- jumping onto other surfaces while in spider ball.
	local min, max      = WGL.OneVec * -self.Radius / 2, WGL.OneVec * self.Radius / 2;
	local wallDir       = velAngle:Forward() * (traceLength + velocity:Length() / self.Radius);
	local wallEndPos    = origin + wallDir;
	local wallTrace     = util.TraceHull({ start = origin, endpos = wallEndPos, mins = min, maxs = max, filter = { owner, self } });
	debugoverlay.SweptBox(origin, wallEndPos, min, max, velAngle, FrameTime() * 2, Color(0, 0, 255));

	-- Setup spider ball corner trace data.
	local cornerDir     = (wallDir - groundDir):GetNormalized() * traceLength;
	local cornerEndPos  = origin + cornerDir;
	local cornerTrace   = util.TraceLine({ start = origin, endpos = cornerEndPos, filter = { owner, self } });
	local wallValid     = wallTrace.Hit && self:SurfaceValid(wallTrace.SurfaceProps);
	local cornerValid   = cornerTrace.Hit && self:SurfaceValid(cornerTrace.SurfaceProps);
	debugoverlay.Line(origin, cornerEndPos, FrameTime() * 2, Color(0, 255, 255));

	-- Calculate the new spider normal.
	local normal = surfaceNormal;
	if (groundValid)              then normal = normal + groundTrace.HitNormal; end
	if (wallValid)                then normal = normal + wallTrace.HitNormal; end
	if (cornerValid || wallValid) then normal = normal + cornerTrace.HitNormal;
	                              else normal = normal + wallDir:GetNormalized(); end

	-- We didn't hit anything, reset the spider normal to its default position.
	if (!groundValid && !wallValid && !cornerValid) then normal = WGL.UpVec; end

	-- Lerp our surface normal in order to avoid jitter during corner and surface transitions.
	-- Normally, this function should not be modifying any flags, but since this function cannot
	-- be called multiple times (to avoid casting traces everytime), we must delegate
	-- the data transform to this function for optimization.
	local result = groundValid || wallValid || cornerValid;
	self:SetSurfaceParent(groundTrace.Entity);
	self:SetSurfaceNormal(LerpVector(FrameTime() * self.Radius, surfaceNormal, normal:GetNormalized()));
	self:SetOnGround(result);
	return result;
end