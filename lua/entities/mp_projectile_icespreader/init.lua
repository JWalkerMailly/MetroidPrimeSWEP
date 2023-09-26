
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)

	-- 3D particle should not play on a direct hit.
	if (IsValid(entity) && WGL.IsAlive(entity)) then
		ParticleEffect("mp_icebeam_enemy_impact", pos, angle);
	end

	-- Render 3D effect.
	local ice = ents.Create("mp_projectile_icespreader_impact");
	ice:SetPos(pos);
	ice:SetAngles(angle);
	ice:Spawn();
end