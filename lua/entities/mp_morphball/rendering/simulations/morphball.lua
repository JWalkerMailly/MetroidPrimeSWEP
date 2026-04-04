
local MorphBall         = WGLComponent:New(MORPHBALL, "MorphBall");
MorphBall.ModelScale    = 0.9;
MorphBall.GyroMaxBank   = 45;
MorphBall.GyroBankRate  = 50;
MorphBall.GyroLerpRate  = 300;
MorphBall.GyroThreshold = 150;
MorphBall.Models        = { ["MorphBall"] = Model("models/metroid/morphball/powersuit.mdl") };

MorphBall.Position        = Vector(0, 0, 0);
MorphBall.SurfaceNormal   = Vector(0, 0, 0);
MorphBall.SurfaceVelocity = Vector(0, 0, 0);
MorphBall.VelocityRight   = Vector(0, 0, 0);
MorphBall.VelocityLeft    = Vector(0, 0, 0);
MorphBall.VelocityPlane   = Angle(0, 0, 0);
MorphBall.GyroOrientation = Angle(0, 0, 0);
MorphBall.CameraAngle2D   = Angle(0, 0, 0);

function MorphBall:Draw(morphball, owner, pos, velocity, radius, spider, frametime)

	local onGround      = morphball:GetOnGround();
	local surfaceParent = morphball:GetSurfaceParent();
	local velocityAngle = velocity:Angle();

	self.Position:SetUnpacked(pos[1], pos[2], 0);

	-- Setup velocity data for simulation.
	self.VelocityPlane:SetUnpacked(0, velocityAngle[2], velocityAngle[3]);
	self.VelocityRight:Set(self.VelocityPlane:Right());
	self.VelocityLeft:Set(self.VelocityRight);
	self.VelocityLeft:Mul(-1);

	self.SurfaceNormal:Set(morphball:GetSurfaceNormal());
	self.SurfaceVelocity:Set(velocity);
	self.SurfaceVelocity:Sub(morphball:GetSurfaceVelocity());

	if (self.LastOrientation == nil) then

		local viewAng = owner:EyeAngles();

		self.LastPosition = Vector(self.Position);
		self.LastOrientation = Angle(0, viewAng[2], viewAng[3]);
		self.LastVelocityPlane = self.VelocityPlane:Forward();
		self.LastSpiderVelocity = Vector(self.SurfaceVelocity);

		self.LastRollInfluence = 0;
		self.LastAngularRotation = 0;
		self.RotationAccumulator = 0;
	end

	if (spider) then
		self.VelocityPlane:Set(self.LastSpiderVelocity:AngleEx(self.SurfaceNormal));
		self.VelocityRight:Set(self.VelocityPlane:Forward():Cross(self.SurfaceNormal));
	end

	-- Update spider velocity delta on current surface.
	if (self.SurfaceVelocity:LengthSqr() > 2500) then
		self.LastSpiderVelocity:Set(self.SurfaceVelocity);
	end

	-- Switch to the parent's local space system for displacement calculations.
	if (spider) then
		if (IsValid(surfaceParent)) then self.Position:Set(surfaceParent:WorldToLocal(pos));
		else self.Position:Set(pos); end
	end

	-- Compute angular displacement.
	local displacement = self.Position:Distance(self.LastPosition);
	local angularRotation = (displacement / radius) * 48;
	local angularSpeed = displacement / frametime;
	self.LastPosition:Set(self.Position);

	-- Angular displacement is only available when touching the ground, otherwise, decelerate.
	if (!spider && !onGround) then angularRotation = Lerp(frametime, self.LastAngularRotation, 0); end

	-- Apply angular displacement and keep a reference for gyroscopic precession.
	self.RotationAccumulator = self.RotationAccumulator + angularRotation;
	self.LastOrientation:RotateAroundAxis(self.VelocityRight, -angularRotation);
	if (angularRotation > 0) then self.LastAngularRotation = angularRotation; end

	-- Prepare left and right gyro velocity vectors in order to determine the best orientation bias.
	local lastRight = self.LastOrientation:Right();
	local gyroRightBias = lastRight:Dot(self.VelocityRight);
	local gyroLeftBias = lastRight:Dot(self.VelocityLeft);
	local gyroBias = gyroRightBias < gyroLeftBias && self.VelocityRight || self.VelocityLeft;

	-- Spider computations end here, return result to save on cpu time.
	if (spider) then

		-- Match gyro angular displacement based on accumulator to the spiderball.
		local gyro = gyroBias:Cross(self.SurfaceNormal):AngleEx(self.SurfaceNormal);
		gyro:RotateAroundAxis(self.VelocityRight, -self.RotationAccumulator);
		self:DrawModel("MorphBall", pos, gyro, 0.9);
		self.LastOrientation:Set(gyro);
		return gyro, 0;
	end

	-- Match gyro angular displacement based on accumulator to the morphball.
	local gyro = gyroBias:Cross(WGL.UpVec):Angle();
	gyro:RotateAroundAxis(self.VelocityRight, -self.RotationAccumulator);

	-- Begin lerping our current orientation towards the absolute gyroscopic angles. We only bias while on ground.
	self.GyroOrientation:Set(self.LastOrientation);
	if (angularSpeed > self.GyroThreshold && onGround) then
		self.GyroOrientation:Set(LerpAngle(displacement / self.GyroLerpRate * math.abs(gyroRightBias * 2.0), self.LastOrientation, gyro));
		self.LastVelocityPlane:Set(self.VelocityPlane:Forward());
	end

	-- Setup camera angles in order to correctly inluence gyro roll.
	self.Position:Sub(morphball:GetVehicleViewPos());

	local cameraAngle = self.Position:Angle();
	self.CameraAngle2D:SetUnpacked(0, cameraAngle[2], cameraAngle[3]);

	local cameraRight   = self.CameraAngle2D:Right();
	local cameraForward = self.CameraAngle2D:Forward();

	-- Setup velocity ratios on a 2D plane to influence the total roll to be applied.
	local velocityRatioRight   = cameraRight:Dot(self.LastVelocityPlane);
	local velocityRatioForward = cameraForward:Dot(self.LastVelocityPlane);

	-- Apply roll influence to gyro based on forward velocity and sideward velocity. The faster we move
	-- forward, the more roll is required on the gyro in order to move correctly sideward.
	local gyroRollInfluence = 0;
	local gyroVelocityInfluence = (self.LastVelocityPlane * angularSpeed * velocityRatioForward):Length();
	if (gyroVelocityInfluence > self.GyroThreshold) then gyroRollInfluence = velocityRatioRight * self.GyroMaxBank; end

	-- Determine amount of roll to be applied, this is only used to bank the morphball.
	if (onGround) then
		self.LastRollInfluence = Lerp(displacement / self.GyroBankRate, self.LastRollInfluence, gyroRollInfluence);
	end

	-- Apply relative roll and rotation.
	self.LastOrientation:Set(self.GyroOrientation);
	self.GyroOrientation:RotateAroundAxis(self.LastVelocityPlane, self.LastRollInfluence);

	-- Render morphball physics simulation.
	self:DrawModel("MorphBall", pos, self.GyroOrientation, self.ModelScale);

	-- Output simulation data for component reuse.
	return self.GyroOrientation, math.abs(self.LastOrientation:Right():Dot(gyroBias));
end