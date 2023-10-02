
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact_world"] = Sound("weapons/icebeam/impact_normal.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP = "mp_icebeam_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_icebeam_projectile";
PROJECTILE.DecalEffect        = "icebeam_impact_decal";
PROJECTILE.DecalGlowEffect    = "icebeam_glow_decal";
PROJECTILE.DecalBurnEffect    = "beam_burn_decal";

-- Properties
PROJECTILE.Mask               = MASK_SHOT_PORTAL;
PROJECTILE.Radius             = 2.5;
PROJECTILE.Speed              = 1000;
PROJECTILE.LifeTime           = 5;
PROJECTILE.GlowColor          = Color(0, 120, 255, 2);
PROJECTILE.GlowSize           = 200;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_ICE;
PROJECTILE.Damage             = 20;
PROJECTILE.KnockBack          = 1000;