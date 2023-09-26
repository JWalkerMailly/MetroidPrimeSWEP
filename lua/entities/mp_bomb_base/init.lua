
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function BOMB:Use(activator, caller)
	return false;
end

function BOMB:OnTakeDamage(damageInfo)
	return false;
end