
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact_world"]   = Sound("weapons/icebeam/impact_charge.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_icebeam_charge_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_icebeam_charge_projectile";
PROJECTILE.DecalEffect        = "icebeam_impact_charge_decal";
PROJECTILE.DecalGlowEffect    = "icebeam_glow_charge_decal";
PROJECTILE.DecalBurnEffect    = "beam_burn_charge_decal";

-- Properties
PROJECTILE.Radius             = 5;
PROJECTILE.WaterDrag          = 0.7;
PROJECTILE.Speed              = 1000;
PROJECTILE.LifeTime           = 2;
PROJECTILE.GlowColor          = Color(0, 120, 255, 4);
PROJECTILE.GlowSize           = 150;
PROJECTILE.BlastColor         = Color(173, 240, 240, 1);
PROJECTILE.BlastSize          = 400;
PROJECTILE.BlastDieTime       = 3;
PROJECTILE.BlastDecay         = 400;
PROJECTILE.BlastStyle         = 0;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_ICE;
PROJECTILE.Damage             = 30;
PROJECTILE.KnockBack          = 2500;
PROJECTILE.DamageFull         = 60;
PROJECTILE.KnockBackFull      = 3000;

-- Blast damage
PROJECTILE.BlastDamage        = 25;
PROJECTILE.BlastRadius        = 60;
PROJECTILE.BlastKnockBack     = 2500;
PROJECTILE.BlastDamageFull    = 50;
PROJECTILE.BlastRadiusFull    = 60;
PROJECTILE.BlastKnockBackFull = 3000;