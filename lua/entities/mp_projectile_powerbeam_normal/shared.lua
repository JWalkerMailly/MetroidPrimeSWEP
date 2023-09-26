
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/powerbeam/impact_normal.wav");

PROJECTILE.ProjectileEffectSP = "mp_powerbeam_projectile_sp";
PROJECTILE.ProjectileEffect   = "mp_powerbeam_projectile";
PROJECTILE.ImpactEffect       = "mp_powerbeam_impact";
PROJECTILE.DecalEffect        = "powerbeam_impact_decal";
PROJECTILE.DecalGlowEffect    = "powerbeam_glow_decal";
PROJECTILE.DecalBurnEffect    = "beam_burn_decal";

-- Properties
PROJECTILE.Radius             = 2.5;
PROJECTILE.Speed              = 3000;
PROJECTILE.LifeTime           = 3;
PROJECTILE.GlowColor          = Color(225, 218, 109, 1);
PROJECTILE.GlowSize           = 200;

-- Damage data
PROJECTILE.DamageType         = DMG_MP_POWER;
PROJECTILE.Damage             = 2;
PROJECTILE.KnockBack          = 1000;