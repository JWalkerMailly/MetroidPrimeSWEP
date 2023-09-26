
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"]    = Sound("weapons/wavebeam/impact_normal.wav");

-- Particle effects.
PROJECTILE.ProjectileEffectSP  = "mp_wavebeam_projectile_sp";
PROJECTILE.ProjectileEffect    = "mp_wavebeam_projectile";
PROJECTILE.ImpactEffect        = "mp_wavebeam_impact";
PROJECTILE.DecalEffect         = "wavebeam_impact_decal";
PROJECTILE.DecalGlowEffect     = "wavebeam_glow_decal";
PROJECTILE.DecalBurnEffect     = "beam_burn_decal";

-- Properties
PROJECTILE.Radius              = 2.5;
PROJECTILE.Speed               = 800;
PROJECTILE.LifeTime            = 2;

-- Damage data
PROJECTILE.DamageType          = DMG_MP_WAVE;
PROJECTILE.Damage              = 3;
PROJECTILE.KnockBack           = 500;

-- Oscillation properties
PROJECTILE.Oscillator          = true;
PROJECTILE.OscillationSpeed    = 30;
PROJECTILE.OscillationFactor   = 35;
PROJECTILE.OscillationDomain   = 1;
PROJECTILE.OscillationDegree   = 180;
PROJECTILE.OscillationOffset   = 2.5;