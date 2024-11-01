
function POWERSUIT:BackupMovement(ply)
	ply.__mp_RestoreMove  = true;
	ply.__mp_OldGravity   = ply:GetGravity();
	ply.__mp_OldJumpPower = ply:GetJumpPower();
	ply.__mp_OldWalkSpeed = ply:GetWalkSpeed();
	ply.__mp_OldRunSpeed  = ply:GetRunSpeed();
	ply.__mp_OldDuckSpeed = ply:GetDuckSpeed();
end

function POWERSUIT:ResetMovement(ply)

	-- Do nothing if we didn't use the powersuit.
	if (!ply.__mp_RestoreMove || !self:IsActiveWeapon(ply)) then return; end

	-- Restore old move data.
	ply.__mp_RestoreMove = false;
	ply:SetGravity(ply.__mp_OldGravity);
	ply:SetWalkSpeed(ply.__mp_OldWalkSpeed);
	ply:SetRunSpeed(ply.__mp_OldRunSpeed);
	ply:SetJumpPower(ply.__mp_OldJumpPower);
	ply:SetDuckSpeed(ply.__mp_OldDuckSpeed);
	ply:Freeze(false);
end

function POWERSUIT:HandleTargetInvalidation(movement)

	-- If target is not valid anymore, reset everything.
	local target, targetValid = self.Helmet:GetTarget(IN_SPEED, movement);
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

	local powersuit = self.PowerSuit;
	if (powersuit:IsGrappling() || powersuit:Grappled() || ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE)) then return; end

	-- Prevent dashing from a grapple anchor unless using the Scan Visor.
	local visor = self:GetVisor();
	local target, validTarget, locked = self.Helmet:GetTarget(IN_SPEED, movement);
	if (locked && validTarget && target:IsGrappleAnchor() && !visor.AllowLockAll) then return; end

	-- Setup movement variables.
	powersuit:Dashing(false);
	local inForward  = movement:KeyDown(IN_FORWARD);
	local inBack     = movement:KeyDown(IN_BACK);
	local inRight    = movement:KeyDown(IN_MOVERIGHT);
	local inLeft     = movement:KeyDown(IN_MOVELEFT);
	local angles     = movement:GetMoveAngles();
	local moveAngles = Angle(0, angles[2], angles[3]);
	local speed      = math.min(ply:GetWalkSpeed(), powersuit.Constants.Movement.WalkSpeed);
	local velocity   = movement:GetVelocity();
	local lockDash   = visor.AllowLockDash || GetConVar("mp_cheats_scandashing"):GetBool();
	local dash       = powersuit.Constants.Dash;

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
			if (inRight || inLeft) then powersuit:Dashing(true); powersuit:Moving(true); end
			if (inRight && powersuit:IsDashing()) then velocity = moveAngles:Right() *  dash.Speed + moveAngles:Forward() * dash.AirSpeed; end
			if (inLeft && powersuit:IsDashing())  then velocity = moveAngles:Right() * -dash.Speed + moveAngles:Forward() * dash.AirSpeed; end
		end

		-- Conserve initial velocity if it was greater than our newly computed one.
		if (velocity:LengthSqr() > airVelocity:LengthSqr() && powersuit:WasMoving()) then airVelocity = velocity; end
		if (powersuit:IsDashing()) then movement:SetVelocity(velocity)
		else movement:SetVelocity(airVelocity); end
	else

		-- Handle dashing from ground.
		if (lockDash && movement:KeyPressed(IN_JUMP) && movement:KeyDown(IN_SPEED) && locked) then
			if (inRight || inLeft) then powersuit:Dashing(true); end
			if (inRight && powersuit:IsDashing()) then velocity = moveAngles:Right() *  dash.Speed + moveAngles:Forward() * dash.GroundSpeed; end
			if (inLeft && powersuit:IsDashing())  then velocity = moveAngles:Right() * -dash.Speed + moveAngles:Forward() * dash.GroundSpeed; end
		end

		if (powersuit:IsDashing()) then movement:SetVelocity(velocity); end
		local walkSpeedSqr = ply:GetWalkSpeed() * 0.95;
		if (velocity:LengthSqr() > (walkSpeedSqr * walkSpeedSqr)) then powersuit:Moving(true);
		else powersuit:Moving(false); end
	end

	-- Raise event.
	if (powersuit:IsDashing()) then hook.Run("MP.OnDash", ply, self); end
end

function POWERSUIT:HandleSpaceJump(ply, movement)

	local powersuit = self.PowerSuit;
	if (powersuit:IsGrappling() && movement:KeyDown(IN_SPEED)) then return; end

	-- Reset jumping if on ground and allow a single jump if falling without jupming.
	if (ply:OnGround()) then powersuit:SetJumpCount(0); end
	if (!ply:OnGround() && powersuit:GetJumpCount() == 0) then powersuit:SetJumpCount(1); end
	if (!movement:KeyPressed(IN_JUMP) || powersuit:GetJumpCount() >= powersuit:MaxJumpCount()) then return; end

	-- If we are dashing, conserve linear velocity and override vertical velocity.
	local velocity = movement:GetVelocity();
	local spaceJump = powersuit.Constants.SpaceJump;
	movement:SetVelocity(Vector(velocity[1], velocity[2], !powersuit:IsDashing() && spaceJump.Power || spaceJump.Dash));
	powersuit:SetJumpTime(CurTime());
	powersuit:AddJumpCount(1);

	-- Animations.
	if (!SERVER) then return; end
	ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP, -1);
	if (powersuit:IsDashing() && powersuit:GetJumpCount() == 1) then
		WSL.PlaySound(self.Suits, "dash");
	else
		WSL.PlaySound(self.Suits, "jump_" .. powersuit:GetJumpCount());
	end
end

function POWERSUIT:HandleGrapple(ply, movement)

	local onGround   = ply:OnGround();
	local visor      = self:GetVisor();
	local barnacle   = ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE);
	local anchor, validAnchor, locked = self.Helmet:GetTarget(IN_SPEED, movement);

	-- Do nothing if grapple beam is not enabled or we do not have a valid anchor target.
	if (!self.PowerSuit:IsGrappleEnabled() || visor.ShouldHideBeamMenu || !locked || !validAnchor || !anchor:IsGrappleAnchor() || barnacle) then
		if (self.PowerSuit:GetGrappleStartTime() >= 0 || self.PowerSuit:Grappled()) then self:ResetGrapple(visor.ShouldHideBeamMenu, onGround); end
		return;
	end

	-- Perform collision prediction to avoid getting stuck in geometry.
	if (SERVER) then
		local collision = WGL.TraceCollision(ply, !self.PowerSuit:GetSwingStart());
		local collided  = (!onGround && self.PowerSuit:IsGrappling() && collision.Hit) || collision.StartSolid;
		if (collided) then return self:ResetGrapple(isAnchor && collided); end
	end

	-- Setup grapple variables.
	local ownerPos   = movement:GetOrigin();
	local grapple    = self.PowerSuit.Constants.Grapple;
	local anchorPos  = anchor:GetLockOnPosition();
	local anchorAng  = (anchorPos - ownerPos):Angle();
	local swingRatio = ply:GetForward():Dot(anchorAng:Forward());
	local grappleMag = ownerPos:Distance(anchorPos);
	if (self.PowerSuit:GetGrappleStartTime() < 0) then
		self.PowerSuit:SetGrappled(false);
		self.PowerSuit:SetGrappleStartTime(CurTime());
	end

	-- Handle grappled fire animation.
	local delay = grapple.Delay * 0.25;
	if (onGround && self.PowerSuit:GetGrappleStart() < 0) then delay = grapple.Delay; end
	if (CurTime() < self.PowerSuit:GetGrappleStartTime() + delay) then return false; end
	if (self.PowerSuit:GetGrappleStart() < 0) then
		self.PowerSuit:SetGrappleStart(0);
		WSL.PlaySound(self.Suits, "grapple_fire");
	end

	-- Delay is expired, linearily increment our grapple start in order to establish a
	-- a distance ratio. This ratio will be used to draw the beam to the anchor.
	if (self.PowerSuit:GetGrappleStart() < grappleMag) then
		self.PowerSuit:SetGrappleStart(self.PowerSuit:GetGrappleStart() + grapple.BeamSpeed * FrameTime());
	end

	-- Wait for the grapple to anchor onto the grapple point before starting the swing logic.
	local grappleTravelRatio = WGL.Clamp(self.PowerSuit:GetGrappleStart() / grappleMag);
	self.PowerSuit:SetGrappleRatio(grappleTravelRatio);
	if (grappleTravelRatio < 1) then return false; end

	-- Setup swing variables.
	if (!self.PowerSuit:GetSwingStart()) then

		self.PowerSuit:SetSwingLastPos(ownerPos);
		self.PowerSuit:SetSwingStartPos(ownerPos);
		self.PowerSuit:SetSwingStartTime(CurTime());
		self.PowerSuit:SetSwingStartAngle(Angle(0, anchorAng[2], anchorAng[3]));
		self.PowerSuit:SetSwingViewAngle(movement:GetAngles());
		self.PowerSuit:SetJumpCount(2);
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
	if (self.PowerSuit:IsSwinging()) then
		local swingStartAngle = self.PowerSuit:GetSwingStartAngle();
		swingStartAngle:RotateAroundAxis(WGL.UpVec, FrameTime() * grapple.RotationSpeed * rotation);
		self.PowerSuit:SetSwingStartAngle(swingStartAngle);
	end

	-- Rotate view and movement based on swing angle.
	self.PowerSuit:SetSwingViewAngle(LerpAngle(FrameTime() * 5, self.PowerSuit:GetSwingViewAngle(), self.PowerSuit:GetSwingStartAngle()));
	self.Helmet:SetLockAngle(self.PowerSuit:GetSwingViewAngle());
	movement:SetAngles(self.PowerSuit:GetSwingViewAngle());
	movement:SetMoveAngles(self.PowerSuit:GetSwingViewAngle());

	-- Setup initial swing vectors.
	local angle   = self.PowerSuit:GetSwingStartAngle();
	local forward = angle:Forward();
	local up      = angle:Up();

	-- Setup min and max simulated points of the grapple swing.
	local swingForwardPos = forward * grapple.SwingDistance;
	local swingHeightPos  = up * -75;
	local maxAnchorPos    = anchorPos + swingForwardPos + swingHeightPos;
	local minAnchorPos    = self.PowerSuit:IsSwinging() && anchorPos - swingForwardPos + swingHeightPos || self.PowerSuit:GetSwingStartPos();

	-- Setup control points of the grapple swing bezier curve.
	local swingCurveHeightPos           = -up * grapple.SwingDistance;
	local swingControlPointHeightPos    = swingCurveHeightPos + swingCurveHeightPos * 0.33;
	local swingControlPointHeightAdjust = swingHeightPos * 0.66;
	local maxAnchorControlPos           = maxAnchorPos + swingControlPointHeightPos - swingControlPointHeightAdjust;
	local minAnchorControlPos           = self.PowerSuit:IsSwinging() && minAnchorPos + swingControlPointHeightPos - swingControlPointHeightAdjust || minAnchorPos;

	-- Simulate grapple beam swing position using a bezier spline. The initial state of the swing will
	-- position two control points on the player's position in order to setup the initial swing curve.
	-- Upon reaching the maximal height of the swing for the first time, the algorithm will position the
	-- points in a semi circle fashion in order to simulate swinging from the anchor point.
	local swingPoints   = { minAnchorPos, minAnchorControlPos, maxAnchorControlPos, maxAnchorPos };
	local swingProgress = math.Round((-math.cos((CurTime() - self.PowerSuit:GetSwingStartTime()) * grapple.SwingSpeed) + 1) / 2, 3);
	local swingPos      = self.PowerSuit:IsSwinging() && WGL.Bezier(swingProgress, swingPoints) || WGL.Bezier(math.ease.OutCirc(swingProgress), swingPoints);

	-- Switch swing states upon reaching the max position for the first time.
	self.PowerSuit:SetSwingStart(true);
	if (swingProgress > 0.85 && !self.PowerSuit:IsSwinging()) then
		self.PowerSuit:SetSwingStartTime(self.PowerSuit:GetSwingStartTime() - 0.475);
		self.PowerSuit:SetSwinging(true);
	end

	-- Get swing velocity from previous position.
	local swingVelocity = (swingPos - self.PowerSuit:GetSwingLastPos()) / FrameTime();
	local swingForce    = math.Clamp(swingVelocity:Length(), 0, grapple.MaxVelocity);
	self.PowerSuit:SetSwingLastPos(swingPos)

	-- Apply movement data for the grapple beam.
	movement:SetOrigin(self.PowerSuit:GetSwingLastPos());
	movement:SetVelocity((swingVelocity:Angle():Forward() + ply:GetForward() * -swingRatio) * swingForce);
	return self.PowerSuit:IsSwinging();
end

function POWERSUIT:ResetGrapple(resetHelmet, onGround)

	-- Restore animation flags.
	self.GrappleSound = false;
	self.PowerSuit:SetSwinging(false);
	self.PowerSuit:SetSwingStart(false);
	self.PowerSuit:SetGrappleStart(-1);
	self.PowerSuit:SetGrappleStartTime(-1);

	-- Reset statemachines.
	self.PowerSuit:Reset();
	if (onGround)    then self.PowerSuit:SetGrappled(false); end
	if (resetHelmet) then self.Helmet:Reset(); end
	WSL.StopSound(self.Suits, "grapple_anchor", 0.1);
end

function POWERSUIT:HandleMorphBall(ply, movement)

	if (!SERVER) then return; end
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
		ply:SetAllowWeaponsInVehicle(false);
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