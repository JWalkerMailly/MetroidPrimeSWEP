
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"]   = Sound("weapons/plasmabeam/impact_charge.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_plasmabeam_charge_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_plasmabeam_charge_projectile";
PROJECTILE.ImpactEffect       = "mp_plasmabeam_charge_impact";

-- Properties
PROJECTILE.Radius             = 5;
PROJECTILE.WaterDrag          = 0.6;
PROJECTILE.Speed              = 4000;
PROJECTILE.LifeTime           = 0.325;
PROJECTILE.GlowColor          = Color(225, 218, 109, 0.8);
PROJECTILE.GlowSize           = 400;
PROJECTILE.BlastColor         = Color(225, 145, 0, 3);
PROJECTILE.BlastSize          = 300;
PROJECTILE.BlastDieTime       = 2.5;
PROJECTILE.BlastDecay         = 400;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_PLASMA;
PROJECTILE.Damage             = 50;
PROJECTILE.KnockBack          = 2500;
PROJECTILE.DamageFull         = 100;
PROJECTILE.KnockBackFull      = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 25;
PROJECTILE.BlastRadius        = 20;
PROJECTILE.BlastKnockBack     = 2500;
PROJECTILE.BlastDamageFull    = 50;
PROJECTILE.BlastRadiusFull    = 50;
PROJECTILE.BlastKnockBackFull = 3000;