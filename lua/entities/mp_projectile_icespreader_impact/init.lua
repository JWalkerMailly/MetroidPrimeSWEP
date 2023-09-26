
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function ENT:Use(activator, caller)
	return false;
end

function ENT:OnTakeDamage(damageInfo)
	return false;
end