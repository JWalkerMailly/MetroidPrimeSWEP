
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"]   = Sound("weapons/powerbeam/impact_charge.wav");

PROJECTILE.ProjectileEffectSP = "mp_powerbeam_charge_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_powerbeam_charge_projectile";
PROJECTILE.ImpactEffect       = "mp_powerbeam_charge_impact";
PROJECTILE.DecalEffect        = "powerbeam_impact_charge_decal";
PROJECTILE.DecalGlowEffect    = "powerbeam_glow_charge_decal";
PROJECTILE.DecalBurnEffect    = "beam_burn_charge_decal";

-- Properties
PROJECTILE.Radius             = 5;
PROJECTILE.Speed              = 1250;
PROJECTILE.LifeTime           = 2;
PROJECTILE.GlowColor          = Color(225, 209, 50, 2);
PROJECTILE.GlowSize           = 300;
PROJECTILE.BlastColor         = Color(225, 209, 100, 2);
PROJECTILE.BlastSize          = 400;
PROJECTILE.BlastDieTime       = 2;
PROJECTILE.BlastDecay         = 600;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_POWER;
PROJECTILE.Damage             = 25;
PROJECTILE.KnockBack          = 2500;
PROJECTILE.DamageFull         = 50;
PROJECTILE.KnockBackFull      = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 25;
PROJECTILE.BlastRadius        = 30;
PROJECTILE.BlastKnockBack     = 2500;
PROJECTILE.BlastDamageFull    = 50;
PROJECTILE.BlastRadiusFull    = 50;
PROJECTILE.BlastKnockBackFull = 3000;