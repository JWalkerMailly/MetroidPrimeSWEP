
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/missile/impact.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_missile_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_missile_projectile";
PROJECTILE.ImpactEffect       = "mp_missile_impact";
PROJECTILE.DecalBurnEffect    = "beam_burn_missile_decal"

-- Properties
PROJECTILE.Radius             = 2;
PROJECTILE.WaterDrag          = 0.7;
PROJECTILE.Speed              = 1000;
PROJECTILE.LifeTime           = 5;
PROJECTILE.GlowColor          = Color(20, 78, 255, 3);
PROJECTILE.GlowSize           = 200;
PROJECTILE.BlastColor         = Color(255, 255, 255, 3);
PROJECTILE.BlastSize          = 200;
PROJECTILE.BlastDieTime       = 7;
PROJECTILE.BlastDecay         = 350;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_SPECIAL;
PROJECTILE.Damage             = 30;
PROJECTILE.KnockBack          = 1000;

-- Blast damage
PROJECTILE.BlastDamage        = 30;
PROJECTILE.BlastRadius        = 50;
PROJECTILE.BlastKnockBack     = 1000;

-- Tracking parameters
PROJECTILE.Homing             = true;
PROJECTILE.HomingLag          = 20;