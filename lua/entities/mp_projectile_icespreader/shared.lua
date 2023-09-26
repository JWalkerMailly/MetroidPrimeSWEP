
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/icebeam/impact_special.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_icespreader_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_icespreader_projectile";

-- Properties
PROJECTILE.Radius             = 2;
PROJECTILE.Speed              = 1000;
PROJECTILE.RotationRate       = 800;
PROJECTILE.LifeTime           = 2;
PROJECTILE.GlowColor          = Color(112, 183, 255, 1.5);
PROJECTILE.GlowSize           = 400;

-- Damage data
PROJECTILE.DamageType         = bit.bor(DMG_MP_ICE, DMG_MP_SPECIAL);
PROJECTILE.Damage             = 150;
PROJECTILE.KnockBack          = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 150;
PROJECTILE.BlastRadius        = 100;
PROJECTILE.BlastKnockBack     = 3000;