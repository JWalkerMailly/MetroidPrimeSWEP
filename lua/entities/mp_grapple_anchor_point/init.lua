
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function ANCHOR:Use(activator, caller)
	return false;
end

function ANCHOR:OnTakeDamage(damageInfo)
	return false;
end