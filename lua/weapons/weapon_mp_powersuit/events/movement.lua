
function POWERSUIT:HandleTargetInvalidation()

	-- If target is not valid anymore, reset everything.
	local target, targetValid = self.Helmet:GetTarget(IN_SPEED);
	if (!targetValid) then return; end

	-- If grapple anchor is not visible, unlock now.
	local visor     = self.Helmet.Constants.Visor;
	local isVisible = self:IsBoundingBoxVisible(target, visor.LockOnDistance);
	local isAnchor  = target:IsGrappleAnchor();
	if (!isVisible && isAnchor) then return self.Helmet:Reset(); end
	if (isVisible) then self.LastLock = CurTime(); end

	-- If lock on has been lost for long enough, unlock.
	local isInvalidated = CurTime() - (self.LastLock || CurTime()) > visor.LockOnTime;
	if (isInvalidated) then self.Helmet:Reset(); end
end

function POWERSUIT:HandleAirMovement(ply, movement)

	if (self.PowerSuit:IsGrappling() || self.PowerSuit:Grappled() || ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE)) then return; end

	-- Prevent dashing from a grapple anchor unless using the Scan Visor.
	local visor = self:GetVisor();
	local target, validTarget, locked = self.Helmet:GetTarget(IN_SPEED);
	if (validTarget && target:IsGrappleAnchor() && !visor.AllowLockAll) then return; end

	-- Setup movement variables.
	self.Dashing     = false;
	local inForward  = movement:KeyDown(IN_FORWARD);
	local inBack     = movement:KeyDown(IN_BACK);
	local inRight    = movement:KeyDown(IN_MOVERIGHT);
	local inLeft     = movement:KeyDown(IN_MOVELEFT);
	local angles     = movement:GetMoveAngles();
	local moveAngles = Angle(0, angles[2], angles[3]);
	local speed      = math.min(ply:GetWalkSpeed(), self.PowerSuit.Constants.Movement.WalkSpeed);
	local velocity   = movement:GetVelocity();
	local lockDash   = visor.AllowLockDash || GetConVar("mp_cheats_scandashing"):GetBool();
	local dash       = self.PowerSuit.Constants.Dash;

	if (!ply:OnGround()) then

		-- Prepare movement velocities.
		local airVelocity = Vector(0, 0, velocity[3]);

		-- Prepare override vector to allow air movement.
		if (inForward) then airVelocity = airVelocity + moveAngles:Forward() *  speed; end
		if (inBack)    then airVelocity = airVelocity + moveAngles:Forward() * -speed; end
		if (inRight)   then airVelocity = airVelocity + moveAngles:Right()   *  speed; end
		if (inLeft)    then airVelocity = airVelocity + moveAngles:Right()   * -speed; end

		-- Handle dashing midair.
		if (lockDash && movement:KeyPressed(IN_JUMP) && movement:KeyDown(IN_SPEED) && locked) then
			if (inRight || inLeft) then self.Dashing = true; self.WasMoving = true; end
			if (inRight && self.Dashing) then velocity = moveAngles:Right() *  dash.Speed + moveAngles:Forward() * dash.AirSpeed; end
			if (inLeft && self.Dashing)  then velocity = moveAngles:Right() * -dash.Speed + moveAngles:Forward() * dash.AirSpeed; end
		end

		-- Conserve initial velocity if it was greater than our newly computed one.
		if (velocity:LengthSqr() > airVelocity:LengthSqr() && self.WasMoving) then airVelocity = velocity; end
		if (self.Dashing) then movement:SetVelocity(velocity)
		else movement:SetVelocity(airVelocity); end
	else

		-- Handle dashing from ground.
		if (lockDash && movement:KeyPressed(IN_JUMP) && movement:KeyDown(IN_SPEED) && locked) then
			if (inRight || inLeft) then self.Dashing = true; end
			if (inRight && self.Dashing) then velocity = moveAngles:Right() *  dash.Speed + moveAngles:Forward() * dash.GroundSpeed; end
			if (inLeft && self.Dashing)  then velocity = moveAngles:Right() * -dash.Speed + moveAngles:Forward() * dash.GroundSpeed; end
		end

		if (self.Dashing) then movement:SetVelocity(velocity); end
		local walkSpeedSqr = ply:GetWalkSpeed() * 0.95;
		if (velocity:LengthSqr() > (walkSpeedSqr * walkSpeedSqr)) then self.WasMoving = true;
		else self.WasMoving = false; end
	end

	-- Raise event.
	if (self.Dashing) then hook.Run("MP.OnDash", ply, self); end
end

function POWERSUIT:HandleSpaceJump(ply, movement)

	self.MaxJumpCount = self.PowerSuit:IsSpaceJumpEnabled() && 2 || 1;
	if (self.PowerSuit:IsGrappling() && movement:KeyDown(IN_SPEED)) then return; end

	-- Reset jumping if on ground and allow a single jump if falling without jupming.
	if (ply:OnGround()) then self.JumpCount = 0; end
	if (!ply:OnGround() && self.JumpCount == 0) then self.JumpCount = 1; end
	if (!movement:KeyPressed(IN_JUMP) || self.JumpCount >= self.MaxJumpCount) then return; end

	-- If we are dashing, conserve linear velocity and override vertical velocity.
	local velocity = movement:GetVelocity();
	local spaceJump = self.PowerSuit.Constants.SpaceJump;
	movement:SetVelocity(Vector(velocity[1], velocity[2], !self.Dashing && spaceJump.Power || spaceJump.Dash));
	ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP, -1);

	-- Animations.
	self.JumpTime  = CurTime();
	self.JumpCount = self.JumpCount + 1;
	if (self.Dashing && self.JumpCount == 1) then
		WSL.PlaySound(self.Suits, "dash");
	else
		WSL.PlaySound(self.Suits, "jump_" .. self.JumpCount);
	end
end

function POWERSUIT:HandleMorphBall(ply, movement)

	if (!self.MorphBall:IsMorphEnabled() || !self.MorphBall:CanMorph() || ply:InVehicle()) then return; end
	if (movement:KeyPressed(IN_DUCK) && !self.ArmCannon:IsBusy() && !ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE)) then

		-- Create morphball vehicle.
		local morphball = ents.Create(self.MorphBallVehicle);
		morphball:SetOwner(ply);
		morphball:SetPowerSuit(self);
		morphball:SetPos(ply:GetPos() + Vector(0, 0, morphball.Radius));
		morphball:Spawn();
		self:SetMorphBall(morphball);
		self.MorphBall:Reset();

		-- Match morphball velocity to the player's current velocity.
		local phys = morphball:GetPhysicsObject();
		phys:SetVelocityInstantaneous(movement:GetVelocity());
		ply:EnterVehicle(morphball.Vehicle);
		ply:Freeze(true);

		-- Animations.
		local suitData = self:GetSuit();
		local morphEffect = self.MorphBall:IsSpiderEnabled() && suitData.SpiderBall.Effect || suitData.MorphBall.Effect;
		sound.Play(self.Suits.Sounds["morph"], self:GetPos(), 75, 100, 1);
		ParticleEffectAttach(morphEffect, PATTACH_ABSORIGIN_FOLLOW, morphball, 0);

		-- Raise event.
		hook.Run("MP.OnMorphBall", owner, self, morphball);
	end
end

function POWERSUIT:HandleGrapple(ply, movement)

	local onGround   = ply:OnGround();
	local visor      = self:GetVisor();
	local barnacle   = ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE);
	local anchor, validAnchor, locked = self.Helmet:GetTarget(IN_SPEED);

	-- Do nothing if grapple beam is not enabled or we do not have a valid anchor target.
	if (!self.PowerSuit:IsGrappleEnabled() || visor.ShouldHideBeamMenu || !locked || !validAnchor || !anchor:IsGrappleAnchor() || barnacle) then
		if (self.GrappleStartTime != nil || self.PowerSuit:Grappled()) then self:ResetGrapple(visor.ShouldHideBeamMenu, onGround); end
		return;
	end

	-- Perform collision prediction to avoid getting stuck in geometry.
	local collision  = WGL.TraceCollision(ply, self.SwingStart == nil);
	local collided   = (!onGround && self.PowerSuit:IsGrappling() && collision.Hit) || collision.StartSolid;

	-- Do nothing if we collided with something.
	if (collided) then return self:ResetGrapple(isAnchor && collided); end

	-- Setup grapple variables.
	local ownerPos   = movement:GetOrigin();
	local grapple    = self.PowerSuit.Constants.Grapple;
	local anchorPos  = anchor:GetLockOnPosition();
	local anchorAng  = (anchorPos - ownerPos):Angle();
	local swingRatio = ply:GetForward():Dot(anchorAng:Forward());
	if (self.GrappleStartTime == nil) then
		self.PowerSuit:SetGrappled(false);
		self.GrappleDistance = ownerPos:Distance(anchorPos);
		self.GrappleStartTime = CurTime();
	end

	-- Handle grappled fire animation.
	local delay = grapple.Delay * 0.25;
	if (onGround && self.GrappleStart == nil) then delay = grapple.Delay; end
	if (CurTime() < self.GrappleStartTime + delay) then return false; end
	if (self.GrappleStart == nil) then
		self.GrappleStart = 0;
		WSL.PlaySound(self.Suits, "grapple_fire");
	end

	-- Delay is expired, linearily increment our grapple start in order to establish a
	-- a distance ratio. This ratio will be used to draw the beam to the anchor.
	if (self.GrappleStart < self.GrappleDistance) then
		self.GrappleStart = self.GrappleStart + grapple.BeamSpeed * FrameTime();
	end

	-- Wait for the grapple to anchor onto the grapple point before starting the swing logic.
	local grappleTravelRatio = WGL.Clamp(self.GrappleStart / self.GrappleDistance);
	self.PowerSuit:SetGrappleRatio(grappleTravelRatio);
	if (grappleTravelRatio < 1) then return false; end

	-- Setup swing variables.
	if (self.SwingStart == nil) then

		self.SwingLastPos    = ownerPos;
		self.SwingStartPos   = ownerPos;
		self.SwingStartTime  = CurTime();
		self.SwingStartAngle = Angle(0, anchorAng[2], anchorAng[3]);
		self.SwingViewAngle  = ply:EyeAngles();
		self.JumpCount       = 2;
		self.PowerSuit:Grappling(true);
		self.PowerSuit:SetGrappled(true);

		-- Start grapple beam sound loop.
		if (!self.GrappleSound) then
			WSL.PlaySound(self.Suits, "grapple_anchor");
			self.GrappleSound = true;
		end
	end

	-- Prevent default behavior.
	if (hook.Run("MP.GrappleBeamThink", ply, self, anchor)) then
		self.Helmet:SetLockAngle((anchorPos - ply:EyePos()):Angle());
		return false;
	end

	-- Apply swing rotational input.
	local rotation = 0;
	if (movement:KeyDown(IN_MOVERIGHT)) then rotation = -1; end
	if (movement:KeyDown(IN_MOVELEFT))  then rotation = 1;  end
	if (self.Swinging) then self.SwingStartAngle:RotateAroundAxis(WGL.UpVec, FrameTime() * grapple.RotationSpeed * rotation); end

	-- Rotate view and movement based on swing angle.
	self.SwingViewAngle = LerpAngle(FrameTime() * 5, self.SwingViewAngle, self.SwingStartAngle);
	self.Helmet:SetLockAngle(self.SwingViewAngle);
	movement:SetAngles(self.SwingViewAngle);
	movement:SetMoveAngles(self.SwingViewAngle);

	-- Setup initial swing vectors.
	local angle   = self.SwingStartAngle;
	local forward = angle:Forward();
	local up      = angle:Up();

	-- Setup min and max simulated points of the grapple swing.
	local swingForwardPos = forward * grapple.SwingDistance;
	local swingHeightPos  = up * -75;
	local maxAnchorPos    = anchorPos + swingForwardPos + swingHeightPos;
	local minAnchorPos    = self.SwingStartPos;
	if (self.Swinging) then minAnchorPos = anchorPos - swingForwardPos + swingHeightPos; end

	-- Setup control points of the grapple swing bezier curve.
	local swingCurveHeightPos           = -up * grapple.SwingDistance;
	local swingControlPointHeightPos    = swingCurveHeightPos + swingCurveHeightPos * 0.33;
	local swingControlPointHeightAdjust = swingHeightPos * 0.66;
	local maxAnchorControlPos           = maxAnchorPos + swingControlPointHeightPos - swingControlPointHeightAdjust;
	local minAnchorControlPos           = minAnchorPos;
	if (self.Swinging) then minAnchorControlPos = minAnchorPos + swingControlPointHeightPos - swingControlPointHeightAdjust; end

	-- Simulate grapple beam swing position using a bezier spline. The initial state of the swing will
	-- position two control points on the player's position in order to setup the initial swing curve.
	-- Upon reaching the maximal height of the swing for the first time, the algorithm will position the
	-- points in a semi circle fashion in order to simulate swinging from the anchor point.
	local swingPoints   = { minAnchorPos, minAnchorControlPos, maxAnchorControlPos, maxAnchorPos };
	local swingProgress = math.Round((-math.cos((CurTime() - self.SwingStartTime) * grapple.SwingSpeed) + 1) / 2, 3);
	local swingPos      = nil;
	if (self.Swinging) then swingPos = WGL.Bezier(swingProgress, swingPoints);
	else swingPos = WGL.Bezier(math.ease.OutCirc(swingProgress), swingPoints); end

	-- Switch swing states upon reaching the max position for the first time.
	self.SwingStart = math.max(self.SwingStart || 0, swingProgress);
	if (swingProgress > 0.85 && !self.Swinging) then
		self.SwingStartTime = self.SwingStartTime - 0.475;
		self.Swinging = true;
	end

	-- Get swing velocity from previous position.
	local swingVelocity = (swingPos - self.SwingLastPos) / FrameTime();
	local swingForce    = math.Clamp(swingVelocity:Length(), 0, grapple.MaxVelocity);
	self.SwingVelocity  = (swingVelocity:Angle():Forward() + ply:GetForward() * -swingRatio) * swingForce;
	self.SwingLastPos   = swingPos;

	-- Apply movement data for the grapple beam.
	movement:SetOrigin(self.SwingLastPos);
	movement:SetVelocity(self.SwingVelocity);
	return self.Swinging;
end

function POWERSUIT:ResetGrapple(resetHelmet, onGround)

	-- Restore animation flags.
	self.Swinging         = false;
	self.SwingStart       = nil;
	self.GrappleSound     = false;
	self.GrappleStart     = nil;
	self.GrappleStartTime = nil;

	-- Reset statemachines.
	self.PowerSuit:Reset();
	if (onGround)    then self.PowerSuit:SetGrappled(false); end
	if (resetHelmet) then self.Helmet:Reset(); end
	WSL.StopSound(self.Suits, "grapple_anchor", 0.1);
end