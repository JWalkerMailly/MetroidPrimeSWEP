
local MorphBall         = WGLComponent:New(MORPHBALL, "MorphBall");
MorphBall.GyroMaxBank   = 45;
MorphBall.GyroBankRate  = 50;
MorphBall.GyroLerpRate  = 300;
MorphBall.GyroThreshold = 150;
MorphBall.Models        = { ["MorphBall"] = Model("models/metroid/morphball/powersuit.mdl") };

function MorphBall:Draw(morphball, owner, pos, velocity, radius, spider, frametime)

	-- Setup velocity data for simulation.
	local onGround        = morphball:GetOnGround();
	local surfaceNormal   = morphball:GetSurfaceNormal();
	local surfaceParent   = morphball:GetSurfaceParent();
	local surfaceVelocity = velocity - morphball:GetSurfaceVelocity();
	local position        = Vector(pos[1], pos[2], 0);
	local velocityAngle   = velocity:Angle();
	local velocityPlane   = Angle(0, velocityAngle[2], velocityAngle[3]);
	local velocityRight   = velocityPlane:Right();

	if (self.LastOrientation == nil) then
		local viewAng            = owner:EyeAngles();
		self.LastPosition        = position;
		self.LastOrientation     = Angle(0, viewAng[2], viewAng[3]);
		self.LastRollInfluence   = 0;
		self.LastAngularRotation = 0;
		self.LastSpiderVelocity  = surfaceVelocity;
		self.RotationAccumulator = 0;
		self.VelocityPlane       = velocityPlane:Forward();
	end

	if (spider) then
		velocityPlane = self.LastSpiderVelocity:AngleEx(surfaceNormal):Forward();
		velocityRight = velocityPlane:Cross(surfaceNormal);
	end

	-- Update spider velocity delta on current surface.
	if (surfaceVelocity:LengthSqr() > 2500) then
		self.LastSpiderVelocity = surfaceVelocity;
	end

	-- Switch to the parent's local space system for displacement calculations.
	if (spider) then
		if (IsValid(surfaceParent)) then position = surfaceParent:WorldToLocal(pos);
		else position = pos; end
	end

	-- Compute angular displacement.
	local displacement    = (position - self.LastPosition):Length();
	local angularRotation = (displacement / radius) * 48;
	local angularSpeed    = displacement / frametime;
	self.LastPosition     = position;

	-- Angular displacement is only available when touching the ground, otherwise, decelerate.
	if (!spider && !onGround) then angularRotation = Lerp(frametime, self.LastAngularRotation, 0); end

	-- Apply angular displacement and keep a reference for gyroscopic precession.
	self.RotationAccumulator = self.RotationAccumulator + angularRotation;
	self.LastOrientation:RotateAroundAxis(velocityRight, -angularRotation);
	if (angularRotation > 0) then self.LastAngularRotation = angularRotation; end

	-- Prepare left and right gyro velocity vectors in order to determine the best orientation bias.
	local gyroRight     = velocityRight;
	local gyroLeft      = gyroRight * -1;
	local gyroRightBias = self.LastOrientation:Right():Dot(gyroRight);
	local gyroLeftBias  = self.LastOrientation:Right():Dot(gyroLeft);
	local gyroBias      = gyroLeft;

	-- Determine the best vector to bias towards, this way the right vector is never influenced by forward velocity direction.
	if (gyroRightBias < gyroLeftBias) then gyroBias = gyroRight; end

	-- Spider computations end here, return result to save on cpu time.
	if (spider) then

		-- Match gyro angular displacement based on accumulator to the spiderball.
		local gyro = gyroBias:Cross(surfaceNormal):AngleEx(surfaceNormal);
		gyro:RotateAroundAxis(velocityRight, -self.RotationAccumulator);
		self:DrawModel("MorphBall", pos, gyro, 0.9);
		self.LastOrientation = gyro;
		return gyro, 0;
	end

	-- Match gyro angular displacement based on accumulator to the morphball.
	local gyro = gyroBias:Cross(WGL.UpVec):Angle();
	gyro:RotateAroundAxis(velocityRight, -self.RotationAccumulator);

	-- Begin lerping our current orientation towards the absolute gyroscopic angles. We only bias while on ground.
	local gyroOrientation = Angle(self.LastOrientation[1], self.LastOrientation[2], self.LastOrientation[3]);
	if (angularSpeed > self.GyroThreshold && onGround) then
		gyroOrientation = LerpAngle(displacement / self.GyroLerpRate * math.abs(gyroRightBias * 2.0), self.LastOrientation, gyro);
		self.VelocityPlane = velocityPlane:Forward();
	end

	-- Setup camera angles in order to correctly inluence gyro roll.
	local cameraAngle   = (pos - morphball:GetVehicleViewPos()):Angle();
	local cameraAngle2D = Angle(0, cameraAngle[2], cameraAngle[3]);
	local cameraRight   = cameraAngle2D:Right():GetNormalized();
	local cameraForward = cameraAngle2D:Forward():GetNormalized();

	-- Setup velocity ratios on a 2D plane to influence the total roll to be applied.
	local velocityRatioRight   = cameraRight:Dot(self.VelocityPlane);
	local velocityRatioForward = cameraForward:Dot(self.VelocityPlane);

	-- Apply roll influence to gyro based on forward velocity and sideward velocity. The faster we move
	-- forward, the more roll is required on the gyro in order to move correctly sideward.
	local gyroRollInfluence     = 0;
	local gyroVelocityInfluence = (self.VelocityPlane * angularSpeed * velocityRatioForward):Length();
	if (gyroVelocityInfluence > self.GyroThreshold) then gyroRollInfluence = velocityRatioRight * self.GyroMaxBank; end

	-- Determine amount of roll to be applied from surface normal, this is only used to bank the morphball.
	local surfaceBank = 0;
	if (onGround) then

		-- Prepare forward bias, if we are rolling straight into the slope, do not bank the morphball.
		local surfaceBias    = velocityRight:Dot(surfaceNormal);
		local surfaceAngBias = velocityPlane:Up():Dot(surfaceNormal);
		local normalAngle    = surfaceNormal:Angle();
		local normal2D       = Angle(0, normalAngle.y, normalAngle.r);
		local forwardBias    = 1.0 - math.abs(normal2D:Forward():Dot(velocityPlane:Forward()));
		surfaceBank          = (360 - surfaceAngBias * 360) * math.Clamp(surfaceBias / math.abs(surfaceBias), -1, 1) * forwardBias;
	end

	-- Apply relative roll, The roll will not be saved in order to keep angle computations relative to morphball.
	local rollInfluence = Lerp(displacement / self.GyroBankRate, self.LastRollInfluence, gyroRollInfluence + surfaceBank);
	local angles = Angle(gyroOrientation[1], gyroOrientation[2], gyroOrientation[3]);
	angles:RotateAroundAxis(self.VelocityPlane, rollInfluence);

	-- Render morphball physics simulation.
	self:DrawModel("MorphBall", pos, angles, 0.9);
	self.LastRollInfluence = rollInfluence;
	self.LastOrientation = gyroOrientation;

	-- Output simulation data for component reuse.
	return angles, math.abs(gyroOrientation:Right():Dot(gyroBias));
end