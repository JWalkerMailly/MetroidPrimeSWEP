
hook.Add("AllowPlayerPickup", "POWERSUIT.StopPickup", function(ply, ent)
	return !ply:UsingPowerSuit();
end);

hook.Add("StartCommand", "POWERSUIT.StartCommand", function(ply, cmd)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end
	if (IsValid(weapon:GetMorphBall())) then return; end

	-- Handle jumping mechanics here. This code handles multiple things at once. If the key is
	-- down, it will time the second jump to the peak of the first jump to get max height.
	-- If we are under water, it will prevent the player from swimming up like in the original.
	local delay = weapon.PowerSuit.Constants.SpaceJump.Delay;
	if (weapon.JumpCount >= (weapon.MaxJumpCount || 1) || (ply:KeyDownLast(IN_JUMP) && weapon.JumpTime + delay < CurTime())) then cmd:RemoveKey(IN_JUMP); end
end);

hook.Add("SetupMove", "POWERSUIT.SetupMove", function(ply, movement, cmd)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then

		-- Do nothing if we didn't use the powersuit.
		if (!ply.__mp_RestoreMove) then return; end

		-- Restore old move data.
		ply.__mp_RestoreMove = false;
		ply:SetGravity(ply.__mp_OldGravity);
		ply:SetWalkSpeed(ply.__mp_OldWalkSpeed);
		ply:SetRunSpeed(ply.__mp_OldRunSpeed);
		ply:SetJumpPower(ply.__mp_OldJumpPower);
		ply:SetDuckSpeed(ply.__mp_OldDuckSpeed);
		return;
	end

	-- Backup old move data.
	if (!ply.__mp_RestoreMove) then

		ply.__mp_RestoreMove  = true;
		ply.__mp_OldGravity   = ply:GetGravity();
		ply.__mp_OldJumpPower = ply:GetJumpPower();
		ply.__mp_OldWalkSpeed = ply:GetWalkSpeed();
		ply.__mp_OldRunSpeed  = ply:GetRunSpeed();
		ply.__mp_OldDuckSpeed = ply:GetDuckSpeed();

		-- Apply new move data.
		local powersuit = weapon.PowerSuit.Constants;
		ply:SetGravity(powersuit.Movement.Gravity);
		ply:SetWalkSpeed(powersuit.Movement.WalkSpeed);
		ply:SetRunSpeed(powersuit.Movement.WalkSpeed);
		ply:SetJumpPower(0);
		ply:SetDuckSpeed(1000);
	end

	-- Prevent other addons from modifying jump and duck for compatibility.
	if (ply:GetJumpPower() != 0)    then ply:SetJumpPower(0);    end
	if (ply:GetDuckSpeed() != 1000) then ply:SetDuckSpeed(1000); end

	-- Handle custom movement when not using the morphball.
	if (IsValid(weapon:GetMorphBall()) || ply:InVehicle()) then return; end
	weapon:HandleTargetInvalidation();
	weapon:HandleAirMovement(ply, movement);
	weapon:HandleSpaceJump(ply, movement);
	weapon:HandleMorphBall(ply, movement);
end);

hook.Add("Move", "POWERSUIT.Move", function(ply, movement)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Override default movement while using the grapple beam.
	return weapon:HandleGrapple(ply, movement);
end);

hook.Add("PlayerSwitchFlashlight", "POWERSUIT.PlayerSwitchFlashlight", function(ply, enabled)

	local isPowerSuit = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Disable flashlight use with powersuit.
	if (!enabled) then return true;
	else return false; end
end);