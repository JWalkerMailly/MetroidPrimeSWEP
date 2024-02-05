
MORPHBALL.InvertedControls = 1;

function MORPHBALL:GroundTrace()
	return util.QuickTrace(self:GetPos(), Vector(0, 0, -self.Radius * 1.5), self);
end

function MORPHBALL:ShouldUnfreeze(owner, morphball)
	return owner:IsFrozen() && morphball:CanMorph();
end

function MORPHBALL:ShouldUnmorph(owner)
	return (CurTime() - self.SpawnTime > 1) && owner:KeyDown(IN_DUCK) && hook.Call("CanExitVehicle", nil, self.Vehicle, owner);
end

function MORPHBALL:GetSlopeInfluence()

	-- Compute slope influence based on the camera and the morphball. This will tilt
	-- the morphball to the side in order to match the angle of the slope it is riding.
	local ground          = self:GroundTrace();
	local velocity        = self:GetVelocity();
	local velocityAngle   = velocity:Angle();
	local velocityAngle2D = Angle(0, velocityAngle[2], velocityAngle[3]);
	local slopeInfluence  = velocityAngle2D:Right():Dot(WGL.UpVec:Cross(ground.HitNormal));

	return slopeInfluence, ground.Hit;
end

function MORPHBALL:GetDirectionalInput(owner)

	local surfaceNormal = self:GetSurfaceNormal();
	local ceiling       = surfaceNormal[3];
	local eyeAngles     = owner:EyeAngles();
	local keyForward    = owner:KeyDown(IN_FORWARD);
	local keyBack       = owner:KeyDown(IN_BACK);
	local keyRight      = owner:KeyDown(IN_MOVERIGHT);
	local keyLeft       = owner:KeyDown(IN_MOVELEFT);

	-- Compute ceiling sign, this will be multiplied onto our forward
	-- movement in order to inverse controls.
	if (ceiling < -0.5) then ceiling = ceiling / math.abs(ceiling);
	else ceiling = 1; end

	-- Wait until the user lets go of the current controls before applying
	-- the inverted controls when we move to the ceiling.
	if (!keyForward && !keyBack && !keyRight && !keyLeft && self.InvertedControls != ceiling) then
		self.InvertedControls = ceiling;
	end

	-- Compute movement based on our camera's current orientation.
	local moveAngles  = Angle(0, eyeAngles[2], eyeAngles[3]);
	local moveForward = moveAngles:Right():Cross(-surfaceNormal):GetNormalized() * self.InvertedControls;
	local moveRight   = moveForward:Cross(surfaceNormal):GetNormalized() * self.InvertedControls;
	local direction   = Vector(0, 0, 0);

	-- Compute desired movement and let the physics handle the velocity.
	if (keyForward) then direction = direction + moveForward; end
	if (keyBack)    then direction = direction - moveForward; end
	if (keyRight)   then direction = direction + moveRight; end
	if (keyLeft)    then direction = direction - moveRight; end

	return direction;
end

function MORPHBALL:DefaultPhysicsUpdate(phys, onGround)

	-- Enable defaults.
	phys:EnableGravity(true);
	self:SetSpider(false);
	self:SetOnGround(onGround);
	self:SetSurfaceParent(NULL);
	self:SetSurfaceNormal(WGL.UpVec);
	self:SetSurfaceVelocity(Vector(0, 0, 0));

	-- Animations.
	if (self.SpiderSoundActive) then
		self.SpiderSoundActive = false;
		WSL.StopSound(self, "spider");
	end
end

function MORPHBALL:SpiderBallPhysicsUpdate(phys)

	-- Disable gravity, it will be handled using custom forces.
	-- We also change the onGround implementation to use the data computed
	-- by the spider ball ground trace instead.
	local onGround     = self:GetOnGround();
	local maxSpeed     = self.MaxSpeed / 4;
	local acceleration = self.Acceleration * FrameTime();
	phys:EnableGravity(false);
	self:SetSpider(onGround);

	-- Animations.
	if (!self.SpiderSoundActive) then
		self.SpiderSoundActive = true;
		WSL.PlaySound(self, "spider");
	end

	return onGround, maxSpeed, acceleration;
end

function MORPHBALL:SpiderBallThink(phys, velocity, desiredVelocity, deceleration)

	-- Handle moving surfaces when using the spider ball.
	local surfaceParent = self:GetSurfaceParent();
	if (!IsValid(surfaceParent)) then return false; end

	local parentPhys = surfaceParent:GetPhysicsObject();
	if (!IsValid(parentPhys)) then return false; end

	-- Apply velocity taking into account the spider surface velocity.
	local parentVelocity = parentPhys:GetVelocityAtPoint(self:GetPos());
	self:SetSurfaceVelocity(parentVelocity);
	phys:SetVelocityInstantaneous(velocity + parentVelocity + desiredVelocity - deceleration);
	phys:SetMass(0);

	-- Raise event.
	hook.Run("MP.MorphBallSpiderThink", self, surfaceParent, parentPhys, parentVelocity);
	return true;
end

function MORPHBALL:PhysicsUpdate(phys)

	-- Fixes client side velocity during prediction.
	self:SetVelocityFix(self:GetVelocity());

	-- Failsafe for weapon drops.
	if (!IsValid(self:GetPowerSuit()) || !IsValid(self:GetPowerSuit():GetOwner()) || self.SoundsCache["roll"] == nil) then return; end

	-- Apply custom gravity to the morphball in order to match the feel of the original game.
	-- If we are using the spider ball, this is where greater gravity will be applied
	-- in order to better navigate around corners.
	local surfaceNormal	= self:GetSurfaceNormal();
	if (self:WaterLevel() < 3) then phys:ApplyForceCenter(surfaceNormal * phys:GetMass() * (!self:GetSpider() && -20 || -25)); end

	-- Prepare user data.
	local owner           = self:GetOwner();
	local boosting        = self:GetPowerSuit().MorphBall:Boosting();
	local bombJumping     = CurTime() < self:GetBombJumpTime();
	local slope, onGround = self:GetSlopeInfluence();
	local acceleration    = (1 - WGL.Clamp(slope)) * self.Acceleration * FrameTime();
	local velocity        = self:GetVelocity() - self:GetSurfaceVelocity();
	local velocityMag     = velocity:Length();
	local maxSpeed        = self.MaxSpeed;

	-- The spider ball has special movement parameters, load them instead of the defaults.
	if (!self:UseSpider(owner, boosting, bombJumping)) then self:DefaultPhysicsUpdate(phys, onGround);
	else onGround, maxSpeed, acceleration = self:SpiderBallPhysicsUpdate(phys); end

	-- Prepare rolling sound.
	if (self.Rolling == nil) then
		self.Rolling = false;
		WSL.PlaySound(self, "roll");
		self.SoundsCache["roll"]:ChangeVolume(0, 0);
	end

	-- Play rolling sound depending on current speed.
	if (onGround) then
		self.SoundsCache["roll"]:ChangeVolume(WGL.Clamp(velocityMag / maxSpeed * 0.4), 0);
		self.SoundsCache["roll"]:ChangePitch(math.Clamp(velocityMag / maxSpeed * 100, 25, 125), 0);
	else
		acceleration = self.Acceleration / 5 * FrameTime();
		self.SoundsCache["roll"]:ChangeVolume(0, 0);
	end

	-- Compute input and velocity data.
	local desiredVelocity    = self:GetDirectionalInput(owner) * acceleration;
	local directionInfluence = desiredVelocity:GetNormalized():Dot(velocity:GetNormalized());
	local decelRatio         = (1 - directionInfluence) / 2 * acceleration;
	local deceleration       = decelRatio * (velocity + surfaceNormal) / maxSpeed;
	local magnitude          = math.Clamp(velocityMag, 0, maxSpeed + self.Deceleration);
	desiredVelocity          = desiredVelocity - (desiredVelocity * magnitude / maxSpeed) * directionInfluence;

	-- Apply final velocity and handle spider ball parent velocity.
	if ((slope < self.MinSlope && !self:GetSpider()) || !onGround || boosting || bombJumping) then deceleration = deceleration * 0; end
	if (self:SpiderBallThink(phys, velocity, desiredVelocity, deceleration)) then return; end
	phys:SetVelocity(velocity + desiredVelocity - deceleration);
	phys:SetMass(90);
end