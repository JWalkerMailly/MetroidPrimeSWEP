
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- 3D particle should not play on a direct hit.
	if (IsValid(entity) && WGL.IsAlive(entity)) then
		ParticleEffect("mp_icebeam_enemy_impact", pos, angle);
	else
		sound.Play(self.Sounds["impact_world"], pos, 75, 100, 1);
		ParticleEffect("mp_icebeam_charge_impact", pos, angle);
		ParticleSystem3D("mp_icecharge_impact", pos, angle, 1);
	end
end