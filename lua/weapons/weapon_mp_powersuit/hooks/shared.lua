
-- ----------------------------------
-- Entity and Game Lookup Cache Hooks
-- ----------------------------------

local function AddEntityToLookupCache(ent)

	-- Add logbook compatibility for entities that do not directly reference the API.
	local class   = ent:GetClass();
	local logBook = game.MetroidPrimeLogBook;
	if (logBook.Cache[class]) then
		ent.LogBook = logBook.Cache[class];
	end

	-- Add lock on support to entities defined through the API.
	local lockOn = game.MetroidPrimeLockOn;
		if (lockOn.Cache[class]) then timer.Simple(FrameTime(), function() if (IsValid(ent)) then ent:SetLockOnAttachment(lockOn.Cache[class]); end end);
	end

	-- Add entity to material swap cache if it contains material swap logic.
	if (ent:HasHeatSignature() || ent:HasXRaySignature()) then
		game.MetroidPrimeMaterialSwaps[tostring(ent:EntIndex())] = ent;
	end

	-- Add entity to logbook cache if it can be scanned.
	if (!ent:CanBeScanned()) then return; end
	game.MetroidPrimeLogBook.Entities[tostring(ent:EntIndex())] = ent;
end

hook.Add("OnEntityCreated", "POWERSUIT.AddToEntityLookupCache",      AddEntityToLookupCache);
hook.Add("EntityRemoved",   "POWERSUIT.RemoveFromEntityLookupCache", function(ent)

	-- Delete entry from table to speed up rendering.
	game.MetroidPrimeMaterialSwaps[tostring(ent:EntIndex())] = nil;
	game.MetroidPrimeLogBook.Entities[tostring(ent:EntIndex())] = nil;
end);

hook.Add("SetupMove", "POWERSUIT.BuildEntityLookupCache", function(ply)

	-- Lookup cache is built only once to avoid overhead, eg, joining a server.
	if (ply.__mp_LookupCacheReady) then return; end
	for k,v in ents.Iterator() do
		AddEntityToLookupCache(v);
	end

	ply.__mp_LookupCacheReady = true;
end);

-- --------------------------
-- Movement and Command Hooks
-- --------------------------

POWERSUIT.Hooks["PlayerPostThink"] = function(weapon, ply)

	local isActive = weapon:IsActiveWeapon(ply);
	ply.__mp_DeathSound = isActive;

	if (!isActive) then return; end

	-- Clamp player health to prevent going over energy tank capacity.
	local maxHealth = weapon.Helmet:GetMaxEnergy() * 100 + 99;
	if (ply:Armor() > 0)                 then ply:SetArmor(0);             end
	if (ply:Health() > maxHealth)        then ply:SetHealth(maxHealth);    end
	if (ply:GetMaxHealth() != maxHealth) then ply:SetMaxHealth(maxHealth); end
end

POWERSUIT.Hooks["StartCommand"] = function(weapon, ply, cmd)

	if (!weapon:IsActiveWeapon(ply) || IsValid(weapon:GetMorphBall())) then return; end

	-- Handle jumping mechanics here. This code handles multiple things at once. If the key is
	-- down, it will time the second jump to the peak of the first jump to get max height.
	-- If we are under water, it will prevent the player from swimming up like in the original.
	if (!weapon.PowerSuit:CanJump()) then cmd:RemoveKey(IN_JUMP); end
end

POWERSUIT.Hooks["SetupMove"] = function(weapon, ply, movement, cmd)

	if (!weapon:IsActiveWeapon(ply)) then return; end
	if (!ply.__mp_RestoreMove) then

		-- Backup old move data.
		weapon:BackupMovement(ply);

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
	weapon:HandleTargetInvalidation(movement);
	weapon:HandleAirMovement(ply, movement);
	weapon:HandleSpaceJump(ply, movement);
	weapon:HandleMorphBall(ply, movement);
end

POWERSUIT.Hooks["Move"] = function(weapon, ply, movement)

	if (!weapon:IsActiveWeapon(ply)) then return; end

	-- Override default movement while using the grapple beam.
	return weapon:HandleGrapple(ply, movement);
end

-- -----------------------------
-- Playermodel Support Unhooking
-- -----------------------------

hook.Remove("StartCommand",       "morphball");
hook.Remove("SetupMove",          "morphball");
hook.Remove("CalcView",           "morphball");
hook.Remove("EntityTakeDamage",   "morphball");
hook.Remove("PlayerSwitchWeapon", "morphball");
hook.Remove("EntityTakeDamage",   "SuitBenefits");
hook.Remove("KeyPress",           "metroid_suitvalues");
hook.Remove("GetFallDamage",      "metroid_suitvalues");