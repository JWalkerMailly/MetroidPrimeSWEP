
-- --------------------
-- 3D Particle systems.
-- --------------------

game.Add3DParticles("particles/mp_missile_explosion.lua");
game.Add3DParticles("particles/mp_missile_impact_rays.lua");
game.Add3DParticles("particles/mp_supermissile_explosion.lua");
game.Add3DParticles("particles/mp_supermissile_impact_rays.lua");
game.Add3DParticles("particles/mp_ice_impact.lua");
game.Add3DParticles("particles/mp_icecharge_impact.lua");
game.Add3DParticles("particles/mp_plasma_impact.lua");
game.Add3DParticles("particles/mp_powerbeam_impact_rays.lua");
game.Add3DParticles("particles/mp_powerbomb_blast.lua");

-- --------------------
-- 2D Particle systems.
-- --------------------

-- Muzzle systems
game.AddParticles("particles/mp_beam_muzzles.pcf");

-- Charge Systems
game.AddParticles("particles/mp_powerbeam_charge.pcf");
game.AddParticles("particles/mp_wavebeam_charge.pcf");
game.AddParticles("particles/mp_icebeam_charge.pcf");
game.AddParticles("particles/mp_plasmabeam_charge.pcf");

-- Missile Systems
game.AddParticles("particles/mp_missile_projectile.pcf");
game.AddParticles("particles/mp_missile_projectile_sp.pcf");
game.AddParticles("particles/mp_missile_impact.pcf");

-- Power Beam
game.AddParticles("particles/mp_powerbeam_projectile.pcf");
game.AddParticles("particles/mp_powerbeam_projectile_sp.pcf");
game.AddParticles("particles/mp_powerbeam_charge_projectile.pcf");
game.AddParticles("particles/mp_powerbeam_charge_projectile_sp.pcf");
game.AddParticles("particles/mp_powerbeam_impact.pcf");
game.AddParticles("particles/mp_powerbeam_charge_impact.pcf");
game.AddParticles("particles/mp_supermissile_projectile.pcf");
game.AddParticles("particles/mp_supermissile_projectile_sp.pcf");
game.AddParticles("particles/mp_supermissile_impact.pcf");

-- Wave Beam Systems
game.AddParticles("particles/mp_wavebeam_projectile.pcf");
game.AddParticles("particles/mp_wavebeam_projectile_sp.pcf");
game.AddParticles("particles/mp_wavebeam_charge_projectile.pcf");
game.AddParticles("particles/mp_wavebeam_charge_projectile_sp.pcf");
game.AddParticles("particles/mp_wavebeam_impact.pcf");
game.AddParticles("particles/mp_wavebeam_charge_impact.pcf");

-- Ice Beam Systems
game.AddParticles("particles/mp_icebeam_projectile.pcf");
game.AddParticles("particles/mp_icebeam_projectile_sp.pcf");
game.AddParticles("particles/mp_icebeam_charge_projectile.pcf");
game.AddParticles("particles/mp_icebeam_charge_projectile_sp.pcf");
game.AddParticles("particles/mp_icebeam_impact.pcf");
game.AddParticles("particles/mp_icebeam_enemy_impact.pcf");
game.AddParticles("particles/mp_icebeam_charge_impact.pcf");
game.AddParticles("particles/mp_icespreader_projectile.pcf");
game.AddParticles("particles/mp_icespreader_projectile_sp.pcf");

-- Plasma Beam Systems
game.AddParticles("particles/mp_plasmabeam_projectile.pcf");
game.AddParticles("particles/mp_plasmabeam_projectile_sp.pcf");
game.AddParticles("particles/mp_plasmabeam_impact.pcf");
game.AddParticles("particles/mp_plasmabeam_charge_projectile.pcf");
game.AddParticles("particles/mp_plasmabeam_charge_projectile_sp.pcf");
game.AddParticles("particles/mp_plasmabeam_charge_impact.pcf");

-- Morph Ball Systems
game.AddParticles("particles/mp_morphball_effects.pcf");

-- --------------------
-- 2D Particle effects.
-- --------------------

-- Missile
PrecacheParticleSystem("mp_missile_projectile");
PrecacheParticleSystem("mp_missile_projectile_sp");
PrecacheParticleSystem("mp_missile_impact");

-- Power Beam / Super Missiles
PrecacheParticleSystem("mp_powerbeam_muzzle");
PrecacheParticleSystem("mp_powerbeam_combo_muzzle");
PrecacheParticleSystem("mp_powerbeam_charge");
PrecacheParticleSystem("mp_powerbeam_projectile");
PrecacheParticleSystem("mp_powerbeam_projectile_sp");
PrecacheParticleSystem("mp_powerbeam_charge_projectile");
PrecacheParticleSystem("mp_powerbeam_charge_projectile_sp");
PrecacheParticleSystem("mp_powerbeam_impact");
PrecacheParticleSystem("mp_powerbeam_charge_impact");
PrecacheParticleSystem("mp_supermissile_projectile");
PrecacheParticleSystem("mp_supermissile_projectile_sp");
PrecacheParticleSystem("mp_supermissile_impact");

-- Wave Beam / WaveBuster
PrecacheParticleSystem("mp_wavebeam_combo_muzzle");
PrecacheParticleSystem("mp_wavebeam_combo_loop_muzzle");
PrecacheParticleSystem("mp_wavebeam_charge");
PrecacheParticleSystem("mp_wavebeam_projectile");
PrecacheParticleSystem("mp_wavebeam_projectile_sp");
PrecacheParticleSystem("mp_wavebeam_charge_projectile");
PrecacheParticleSystem("mp_wavebeam_charge_projectile_sp");
PrecacheParticleSystem("mp_wavebeam_impact");
PrecacheParticleSystem("mp_wavebeam_charge_impact");

-- Ice Beam / Ice Spreader
PrecacheParticleSystem("mp_icebeam_ambient");
PrecacheParticleSystem("mp_icebeam_muzzle");
PrecacheParticleSystem("mp_icebeam_charge_muzzle");
PrecacheParticleSystem("mp_icebeam_combo_muzzle");
PrecacheParticleSystem("mp_icebeam_charge");
PrecacheParticleSystem("mp_icebeam_projectile");
PrecacheParticleSystem("mp_icebeam_projectile_sp");
PrecacheParticleSystem("mp_icebeam_charge_projectile");
PrecacheParticleSystem("mp_icebeam_charge_projectile_sp");
PrecacheParticleSystem("mp_icebeam_impact");
PrecacheParticleSystem("mp_icebeam_enemy_impact");
PrecacheParticleSystem("mp_icebeam_charge_impact");
PrecacheParticleSystem("mp_icespreader_projectile");
PrecacheParticleSystem("mp_icespreader_projectile_sp");

-- Plasma Beam / Flamethrower
PrecacheParticleSystem("mp_plasmabeam_combo_muzzle");
PrecacheParticleSystem("mp_plasmabeam_combo_loop_muzzle");
PrecacheParticleSystem("mp_plasmabeam_charge");
PrecacheParticleSystem("mp_plasmabeam_projectile");
PrecacheParticleSystem("mp_plasmabeam_projectile_sp");
PrecacheParticleSystem("mp_plasmabeam_impact");
PrecacheParticleSystem("mp_plasmabeam_charge_projectile");
PrecacheParticleSystem("mp_plasmabeam_charge_projectile_sp");
PrecacheParticleSystem("mp_plasmabeam_charge_impact");

-- Morph Ball Bombs / Power Bombs / Morph Effects
PrecacheParticleSystem("mp_morphball_powersuit");
PrecacheParticleSystem("mp_morphball_variasuit");
PrecacheParticleSystem("mp_morphball_spider");
PrecacheParticleSystem("mp_morphball_gravitysuit");
PrecacheParticleSystem("mp_morphball_phazonsuit");
PrecacheParticleSystem("mp_morphball_bomb_set");
PrecacheParticleSystem("mp_morphball_bomb_explosion");
PrecacheParticleSystem("mp_morphball_powerbomb");