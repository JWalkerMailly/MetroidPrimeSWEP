
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- Render 3D rays.
	ParticleSystem3D("mp_powerbeam_impact_rays", pos, angle, 3.4);
end