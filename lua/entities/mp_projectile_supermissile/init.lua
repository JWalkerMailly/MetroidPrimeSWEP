
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- Render 3D rays.
	ParticleSystem3D("mp_supermissile_impact_rays", pos, angle, 3.4);

	-- Render 3D explosion.
	ParticleSystem3D("mp_supermissile_explosion", pos, angle, 3.4);

	-- Apply screenshake to players in radius.
	util.ScreenShake(pos, 6, 0.05, 0.5, 1024);
end