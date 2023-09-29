
function POWERSUIT:IsBoundingBoxVisible(entity, maxDistance)

	local owner  = self:GetOwner();
	local eyePos = owner:EyePos();
	local endPos = eyePos + (entity:WorldSpaceCenter() - eyePos):GetNormalized() * (maxDistance + 50);
	local trace  = util.TraceHull({
		start    = eyePos,
		endpos   = endPos,
		mins     = WGL.OneVec * -2.5,
		maxs     = WGL.OneVec * 2.5,
		filter   = { self, owner },
		mask     = MASK_SHOT
	});

	return trace.Hit && entity == trace.Entity;
end

function POWERSUIT:GetDangerRatio()

	local pos           = self:GetOwner():GetPos();
	local maxDistance   = self.Helmet.Constants.Visor.DangerDistance;
	local closestDanger = maxDistance;

	-- Scan all potentially dangerous entities and keep the closest one for reference.
	for k,v in pairs(ents.FindInSphere(pos, maxDistance)) do
		if (game.MetroidPrimeThreats.Cache[v:GetClass()]) then
			local distance = v:GetPos():Distance(pos);
			if (distance < closestDanger) then closestDanger = distance; end
		end
	end

	-- Return threat ratio to closest entity.
	return WGL.Clamp(1 - (closestDanger / maxDistance));
end

function POWERSUIT:GetAimVector(owner, shootPos, aimVector, target, autoTarget, lockedOn)

	-- Auto targeting is a special feature used primarily for the wavebuster.
	if (autoTarget) then return (target:WorldSpaceCenter() - shootPos):GetNormalized(); end

	local shouldAutoAim = tobool(owner:GetInfo("mp_options_autoaim")) || lockedOn;

	-- Regular aim assist works by establishing a maximal aim angle vector and predicting a set number of frames in advance.
	local autoAimVector = shouldAutoAim && ((target:WorldSpaceCenter() + target:GetVelocity() * FrameTime() * self.Helmet.Constants.Visor.AimAssistFrames) - shootPos):GetNormalized() || aimVector;
	if (autoAimVector:Dot(aimVector) > self.Helmet:GetAimAssistAngle()) then return autoAimVector; end
	return aimVector;
end

function POWERSUIT:GetAimData(aimAssist, autoTarget)

	-- Only process aim assist for valid targets. Grapple anchor points are considered valid only
	-- for aim lock, not for shoot data. This prevents projectiles from homing grapple points.
	local validTarget = false;
	local shootPos, owner, aimVector    = self:GetMuzzlePos();
	local target, targetValid, lockedOn = self.Helmet:GetTarget(IN_SPEED);
	if (targetValid) then
		validTarget = !target:IsGrappleAnchor();
		if (aimAssist && validTarget) then aimVector = self:GetAimVector(owner, shootPos, aimVector, target, autoTarget, lockedOn); end
	end

	return {
		Owner         = owner,
		Weapon        = self,
		ShootPos      = shootPos,
		AimVector     = aimVector,
		Target        = target,
		ValidTarget   = validTarget,
		Locked        = lockedOn,
		Assist        = aimAssist,
		Auto          = autoTarget
	};
end

function POWERSUIT:CanBeLockedOn(visor, entity, maxDistance)

	local owner = self:GetOwner();
	if (!IsValid(entity) || entity == owner || entity == self) then return false, NULL, false; end

	local targetPos = entity:WorldSpaceCenter();
	local isAnchor  = entity:IsGrappleAnchor();
	if (!visor.AllowLockAll) then

		if (!isAnchor && !WGL.IsAlive(entity)) then return false, NULL, false; end

		local isVisible = self:IsBoundingBoxVisible(entity, maxDistance);
		if (!isVisible) then return false, NULL, false; end

		if (isAnchor) then
			local distanceLimit = self.PowerSuit.Constants.Grapple.MaxDistance;
			local isWithinReach = targetPos:DistToSqr(owner:EyePos()) <= distanceLimit * distanceLimit;
			if (!isWithinReach || !self.PowerSuit:IsGrappleEnabled()) then return false, NULL, false; end
		end
	else

		-- Call to API for implementation homogenization.
		local isScannable = entity:CanBeScanned();
		if (!isScannable) then return false, NULL, false; end

		local isVisible = self:IsBoundingBoxVisible(entity, maxDistance);
		if (!isVisible) then return false, NULL, false; end
	end

	return true, targetPos, isAnchor;
end

function POWERSUIT:AcquireTarget(ply, maxDistance, maxCosine)

	-- Do nothing if the player is preemptively holding down the lock on key.
	if (!ply:KeyPressed(IN_SPEED) && ply:KeyDown(IN_SPEED)) then return nil, nil; end

	local visor         = self:GetVisor();
	local eyePos        = ply:EyePos();
	local aimVector     = ply:GetAimVector();
	local viewVector    = aimVector * maxDistance;
	local lastDistance  = maxDistance;
	local currentTarget = NULL;
	local isAnchor      = false;

	-- Scan every viable entity in view frustrum.
	for k,v in pairs(ents.FindInCone(eyePos, aimVector, maxDistance, maxCosine)) do

		local locked, pos, anchor = self:CanBeLockedOn(visor, v, maxDistance);
		if (!locked) then continue; end

		-- Compute the closest distance from the aim vector in order to determine
		-- which entity is most suitable for aim lock.
		local targetDistance = util.DistanceToLine(eyePos, eyePos + viewVector, pos);
		if (targetDistance < lastDistance) then
			currentTarget, isAnchor = v, anchor;
			lastDistance = targetDistance;
		end
	end

	return currentTarget, isAnchor;
end

function POWERSUIT:HelmetThink()

	if (SERVER || (!game.SinglePlayer() && !IsFirstTimePredicted())) then return; end

	-- Play lock on sound.
	local target, _, lockedOn = self.Helmet:GetTarget(IN_SPEED);
	if (lockedOn) then
		if (!self.LockedOnSound) then
			local isAnchor = target:IsGrappleAnchor();
			WSL.PlaySoundPatch(self:GetVisor(), isAnchor && "grapple" || "aimlock", 0.3, 0);
			self.LockedOnSound = true;
		end
	else
		self.LockedOnSound = false;
	end

	-- Throttle helmet think.
	if (self.NextHelmetThink || 0) > CurTime() then return; end

	local owner = self:GetOwner();
	if (!IsValid(owner) || owner:InVehicle()) then return; end

	-- Do nothing if target didn't change.
	local visor      = self.Helmet.Constants.Visor;
	local nextTarget = self:AcquireTarget(owner, visor.LockOnDistance, visor.LockOnCosine);
	if (nextTarget == nil || target == nextTarget) then return; end

	-- Propagate to server.
	net.Start("POWERSUIT.SwitchTarget");
		net.WriteEntity(self);
		net.WriteEntity(nextTarget);
	net.SendToServer();
	hook.Run("MP.OnTargetChanged", self, nextTarget);
	self.NextHelmetThink = CurTime() + visor.LockOnFPS;
end

-- Change target networking code.
if (SERVER) then util.AddNetworkString("POWERSUIT.SwitchTarget"); end
net.Receive("POWERSUIT.SwitchTarget", function(length, ply)

	local powersuit = net.ReadEntity();
	local target    = net.ReadEntity();

	-- Safety check in case the networked information is invalid.
	if (!IsValid(powersuit) || powersuit:GetOwner() != ply) then return; end

	-- Network target data.
	if (target:IsWorld()) then target = NULL; end
	powersuit.Helmet:SetTarget(target);
	hook.Run("MP.OnTargetChanged", powersuit, target);
end);

-- Scan completed network code.
if (SERVER) then util.AddNetworkString("POWERSUIT.ScanCompleted"); end
net.Receive("POWERSUIT.ScanCompleted", function(length, ply)

	local powersuit = net.ReadEntity();
	local target    = net.ReadEntity();

	-- Safety check in case the networked information is invalid.
	if (!IsValid(powersuit) || powersuit:GetOwner() != ply) then return; end

	-- Raise event callback.
	hook.Run("MP.OnScanCompleted", powersuit, target);
end)