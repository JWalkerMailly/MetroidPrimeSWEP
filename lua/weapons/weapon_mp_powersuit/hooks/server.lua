
-- ------------
-- Damage Hooks
-- ------------

POWERSUIT.Hooks["PlayerDeathSound"] = function(weapon, ply)
	return ply.__mp_DeathSound;
end

POWERSUIT.Hooks["GetFallDamage"] = function(weapon, ply, damage)
	if (weapon:IsActiveWeapon(ply)) then return 0; end
end

POWERSUIT.Hooks["EntityTakeDamage"] = function(weapon, ent, damage)

	if (!IsValid(ent)) then return; end

	-- Scale damage given according to game multipler.
	local attacker = damage:GetAttacker();
	if (IsValid(attacker) && attacker:IsPlayer() && weapon:IsActiveWeapon(attacker)) then
		damage:ScaleDamage(GetConVar("mp_cheats_damagegivenscale"):GetInt());
	end

	-- Scale damage taken according to current suit and game multiplier.
	if (ent:IsPlayer() && weapon:IsActiveWeapon(ent)) then
		damage:ScaleDamage(GetConVar("mp_cheats_damagetakenscale"):GetInt());
		damage:ScaleDamage(weapon:GetSuit().DamageScale);
	end
end

-- -------------
-- Command Hooks
-- -------------

POWERSUIT.Hooks["AllowPlayerPickup"] = function(weapon, ply, ent)
	return !weapon:IsActiveWeapon(ply);
end

POWERSUIT.Hooks["PlayerSwitchFlashlight"] = function(weapon, ply, enabled)

	if (!weapon:IsActiveWeapon(ply)) then return; end

	-- Disable flashlight use with powersuit.
	if (!enabled) then return true;
	else return false; end
end

-- -------------
-- Vehicle Hooks
-- -------------

POWERSUIT.Hooks["CanPlayerEnterVehicle"] = function(weapon, ply, vehicle, role)

	if (!weapon:IsActiveWeapon(ply)) then return; end

	-- Make sure the armcannon is not busy before entering a vehicle.
	return !weapon.ArmCannon:IsBusy();
end

POWERSUIT.Hooks["CanExitVehicle"] = function(weapon, vehicle, ply)

	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall()) then return; end

	-- AABB test to see if the player can exit the morphball.
	local bottom, top = ply:GetHull();
	local groundPos   = morphball:GetPos();
	local unmorphHull = util.TraceHull({
		start  = groundPos,
		endpos = groundPos,
		mins   = bottom,
		maxs   = top,
		filter = { ply, morphball, vehicle },
		mask   = MASK_PLAYERSOLID
	});

	local powersuit = morphball:GetPowerSuit();
	if (!IsValid(powersuit)) then return; end

	local canExit   = !unmorphHull.StartSolid && !unmorphHull.Hit;
	local canMorph  = powersuit.MorphBall:CanMorph();
	if (!canExit && canMorph) then
		powersuit.MorphBall:SetNextMorphTime(CurTime());
		WSL.PlaySound(morphball, "stuck");
	end

	return canExit;
end

POWERSUIT.Hooks["PlayerLeaveVehicle"] = function(weapon, ply, vehicle)

	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall()) then return; end

	-- Match the player's velocity and direction to the morphball before removing it.
	ply:SetEyeAngles(Angle(0, ply:LocalEyeAngles()[2] - 90, 0));
	ply:SetPos(morphball:GetPos() - Vector(0, 0, 11));
	ply:SetVelocity(morphball:GetVelocity() * 0.75);

	local powersuit = morphball:GetPowerSuit();
	if (!IsValid(powersuit)) then return; end

	-- Remove morphball on exit.
	powersuit.MorphBall:SetNextMorphTime(CurTime());
	morphball:StopCharging(powersuit.MorphBall);
	ply:EmitSound("entities/morphball/unmorph.wav");
	SafeRemoveEntity(morphball);

	-- Raise event.
	hook.Run("MP.OnMorphBallUnmorph", ply, powersuit);
end