
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");
PROJECTILE.RemoveOnCollide = false;

-- Properties
PROJECTILE.Radius          = 5;
PROJECTILE.GlowColor       = Color(255, 53, 224, 0.8);
PROJECTILE.GlowSize        = 400;
PROJECTILE.GlowStyle       = 6;

-- Damage data
PROJECTILE.DamageType      = bit.bor(DMG_MP_WAVE, DMG_MP_SPECIAL);
PROJECTILE.Damage          = 0.8;