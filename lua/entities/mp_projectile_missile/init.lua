
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- Render 3D rays.
	ParticleSystem3D("mp_missile_impact_rays", pos, angle, 2.5);

	-- Render 3D Explosion.
	ParticleSystem3D("mp_missile_explosion", pos, angle, 2.5);
end