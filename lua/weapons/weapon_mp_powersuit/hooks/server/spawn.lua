
local stateRestore = {};

hook.Add("PlayerInitialSpawn", "POWERSUIT.RestoreState", function(ply)
	stateRestore[ply] = true;
end);

hook.Add("SetupMove", "POWERSUIT.RestoreState", function(ply, _, cmd)

	-- Map changes of type "transition" behave differently from normal map changes.
	if (stateRestore[ply] && !cmd:IsForced()) then

		local isPowerSuit, weapon = ply:UsingPowerSuit();
		if (!isPowerSuit) then
			stateRestore[ply] = false;
			return;
		end

		-- Reload weapon entirely in order to refresh entire state.
		local weaponClass = weapon:GetClass();
		ply:StripWeapon(weaponClass);
		ply:Give(weaponClass);
		ply:SelectWeapon(weaponClass);
		stateRestore[ply] = nil;
	end
end);