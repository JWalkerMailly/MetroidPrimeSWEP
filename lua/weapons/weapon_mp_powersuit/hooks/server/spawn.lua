
local stateRestore = {};

hook.Add("PlayerInitialSpawn", "POWERSUIT.RestoreState", function(ply)
	stateRestore[ply] = true;
end);

hook.Add("SetupMove", "POWERSUIT.RestoreState", function(ply, _, cmd)

	-- Map changes of type "transition" behave differently from normal map changes.
	if (stateRestore[ply] && !cmd:IsForced()) then

		local forceSelect = false;
		local currentWeapon = ply:GetActiveWeapon();
		for k,v in ipairs(ply:GetWeapons()) do

			if (!v:IsPowerSuit()) then continue; end

			-- Cleanup stray Morph Balls now.
			local morphball = v:GetMorphBall();
			if (IsValid(morphball)) then
				forceSelect = true;
				morphball:Remove();
				ply:ExitVehicle();
			end

			-- Reload weapon entirely in order to refresh entire state.
			local weaponClass = v:GetClass();
			ply:StripWeapon(weaponClass);
			ply:Give(weaponClass);

			-- Reequip powersuit if it was active after a map change.
			if (forceSelect || currentWeapon == v) then
				local vehicle = ply:GetAllowWeaponsInVehicle();
				ply:SetAllowWeaponsInVehicle(true);
				ply:SelectWeapon(weaponClass);
				timer.Simple(math.Clamp(FrameTime() * 16, 0.24, 0.24 * 16), function() ply:SetAllowWeaponsInVehicle(vehicle); end);
			end
		end

		-- Clear state restore cache.
		stateRestore[ply] = nil;
	end
end);