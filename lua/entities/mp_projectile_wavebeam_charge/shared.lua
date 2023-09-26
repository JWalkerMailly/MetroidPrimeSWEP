
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"]   = Sound("weapons/wavebeam/impact_charge.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_wavebeam_charge_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_wavebeam_charge_projectile";
PROJECTILE.ImpactEffect       = "mp_wavebeam_charge_impact";
PROJECTILE.DecalEffect        = "wavebeam_impact_charge_decal";
PROJECTILE.DecalBurnEffect    = "beam_burn_charge_decal";

-- Properties
PROJECTILE.Radius             = 5;
PROJECTILE.Speed              = 1000;
PROJECTILE.LifeTime           = 2;
PROJECTILE.GlowColor          = Color(255, 53, 224, 2);
PROJECTILE.GlowSize           = 250;
PROJECTILE.BlastColor         = Color(255, 150, 224, 1.2);
PROJECTILE.BlastSize          = 500;
PROJECTILE.BlastDieTime       = 1.5;
PROJECTILE.BlastDecay         = 1000;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_WAVE;
PROJECTILE.Damage             = 20;
PROJECTILE.KnockBack          = 2000;
PROJECTILE.DamageFull         = 40;
PROJECTILE.KnockBackFull      = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 20;
PROJECTILE.BlastRadius        = 40;
PROJECTILE.BlastKnockBack     = 2000;
PROJECTILE.BlastDamageFull    = 40;
PROJECTILE.BlastRadiusFull    = 60;
PROJECTILE.BlastKnockBackFull = 3000;

-- Tracking parameters
PROJECTILE.Homing             = true;
PROJECTILE.HomingLag          = 20;