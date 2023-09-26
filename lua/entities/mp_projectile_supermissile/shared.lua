
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/powerbeam/impact_special.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_supermissile_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_supermissile_projectile";
PROJECTILE.ImpactEffect       = "mp_supermissile_impact";
PROJECTILE.DecalBurnEffect    = "beam_burn_missile_decal"

-- Properties
PROJECTILE.Radius             = 2;
PROJECTILE.Speed              = 1000;
PROJECTILE.RotationRate       = 800;
PROJECTILE.LifeTime           = 2;
PROJECTILE.GlowColor          = Color(225, 209, 50, 4);
PROJECTILE.GlowSize           = 200;
PROJECTILE.BlastColor         = Color(225, 209, 100, 3);
PROJECTILE.BlastSize          = 400;
PROJECTILE.BlastDieTime       = 2;
PROJECTILE.BlastDecay         = 600;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = bit.bor(DMG_MP_POWER, DMG_MP_SPECIAL);
PROJECTILE.Damage             = 180;
PROJECTILE.KnockBack          = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 180;
PROJECTILE.BlastRadius        = 80;
PROJECTILE.BlastKnockBack     = 3000;

-- Tracking parameters
PROJECTILE.Homing             = true;
PROJECTILE.HomingLag          = 20;