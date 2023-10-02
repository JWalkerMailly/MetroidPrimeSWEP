
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/plasmabeam/impact_normal.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_plasmabeam_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_plasmabeam_projectile";
PROJECTILE.ImpactEffect       = "mp_plasmabeam_impact";

-- Properties
PROJECTILE.Mask               = MASK_SHOT_PORTAL;
PROJECTILE.Radius             = 2.5;
PROJECTILE.Speed              = 10000;
PROJECTILE.LifeTime           = 0.325;
PROJECTILE.GlowColor          = Color(225, 218, 109, 0.8);
PROJECTILE.GlowSize           = 400;
PROJECTILE.BlastColor         = Color(225, 145, 0, 3);
PROJECTILE.BlastSize          = 200;
PROJECTILE.BlastDieTime       = 3;
PROJECTILE.BlastDecay         = 400;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_PLASMA;
PROJECTILE.Damage             = 12;
PROJECTILE.KnockBack          = 1000;