
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");

-- Sound properties
PROJECTILE.Sounds = {};
PROJECTILE.Sounds["impact"] = Sound("weapons/wavebeam/impact_normal.wav");

-- Properties
PROJECTILE.Radius           = 0.5;
PROJECTILE.Speed            = 1150;
PROJECTILE.LifeTime         = 2.1;
PROJECTILE.GlowColor        = Color(255, 53, 224, 1);
PROJECTILE.GlowSize         = 400

-- Tracking parameters
PROJECTILE.Homing           = true;
PROJECTILE.HomingLag        = 20;

-- Oscillation properties
PROJECTILE.OscillatorParent = true;

function PROJECTILE:ShootCallback(shootdata, degrees, parent, fullCharge)
	ents.Create("mp_projectile_wavebeam_normal_child"):Shoot(shootdata,    0, self);
	ents.Create("mp_projectile_wavebeam_normal_child"):Shoot(shootdata,  120, self);
	ents.Create("mp_projectile_wavebeam_normal_child"):Shoot(shootdata, -120, self);
	return self;
end