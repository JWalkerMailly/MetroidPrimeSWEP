
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function ENT:DirectDamageCallback(owner, entity)
	if (IsValid(entity) && WGL.IsAlive(entity) && entity:IsIgnitable()) then entity:Ignite(5); end
end

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- Render 3D Explosion.
	ParticleSystem3D("mp_plasma_impact", pos, angle, 1);
end