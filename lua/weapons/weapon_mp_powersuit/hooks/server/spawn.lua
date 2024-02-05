
local stateRestore = {};

hook.Add("PlayerInitialSpawn", "POWERSUIT.RestoreState", function(ply)
	stateRestore[ply] = true;
end);

hook.Add("SetupMove", "POWERSUIT.RestoreState", function(ply, _, cmd)

	-- Map changes of type "transition" behave differently from normal map changes.
	if (stateRestore[ply] && !cmd:IsForced()) then

		local currentWeapon = ply:GetActiveWeapon();
		for k,v in ipairs(ply:GetWeapons()) do

			if (!v:IsPowerSuit()) then continue; end

			-- Reload weapon entirely in order to refresh entire state.
			local weaponClass = v:GetClass();
			ply:StripWeapon(weaponClass);
			ply:Give(weaponClass);

			-- Reequip powersuit if it was active after a map change.
			if (currentWeapon == v) then ply:SelectWeapon(weaponClass); end
		end

		-- Clear state restore cache.
		stateRestore[ply] = nil;
	end
end);