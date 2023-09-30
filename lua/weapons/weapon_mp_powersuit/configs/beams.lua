
POWERSUIT.Beams = {};

-- Power beam projectile setup table.
POWERSUIT.Beams[1] = {

	-- Clientside selection key.
	Key                 = KEY_UP,
	DisplayName         = "Power Beam",
	DisplayPos          = 625,
	Icon                = Material("models/metroid/hud/beammenu/power/MAT_0_0"),

	-- Aim assist parameters.
	AimAssist           = true,
	ComboAutoTarget     = false,

	-- Projectile parameters.
	BeamDelay           = 0.10,
	BeamCloseSound      = false,

	ChargeColor         = Color(225, 218, 109, 1),
	ChargeBallColor     = Color(255, 204, 0, 0.5),
	ChargeGlowSize      = 350,
	ChargeViewPunch     = 20,
	ChargeDelay         = 0.8,

	MissileCloseDelay   = 0.3,
	MissileCloseDelay2  = 0.21,
	MissileCloseSound   = false,

	ComboViewPunch      = 30,
	ComboCost           = 5,
	ComboDelay          = 0.1,
	ComboReset          = 1.5,
	ComboLoopDelay      = nil,
	ComboUnderWater     = true,

	Projectiles = {
		["normal"]      = "mp_projectile_powerbeam_normal",
		["charge"]      = "mp_projectile_powerbeam_charge",
		["combo"]       = "mp_projectile_supermissile"
	},

	-- Sound parameters for beam activities.
	Sounds = {
		["open"]        = nil,
		["charge"]      = Sound("weapons/powerbeam/charge.wav"),
		["fire_normal"] = Sound("weapons/powerbeam/fire_normal.wav"),
		["fire_charge"] = Sound("weapons/powerbeam/fire_charge.wav"),
		["fire_combo"]  = Sound("weapons/powerbeam/fire_special.wav"),
	},

	-- View model and world model parameters.
	ViewModel           = Model("models/metroid/armcannon/c_power.mdl"),
	WorldModel          = Model("models/metroid/armcannon/w_power.mdl"),

	-- View model particle effects.
	ChargeEffect        = "mp_powerbeam_charge",
	MuzzleEffect        = "mp_powerbeam_muzzle",
	MuzzleBreakEffect   = nil,
	MuzzleComboEffect   = "mp_powerbeam_combo_muzzle",
	AmbientEffect       = nil,

	-- Beam menu settings.
	ModelName           = Model("models/metroid/hud/beammenu/v_power.mdl")
};

-- Wave beam projectile setup table.
POWERSUIT.Beams[2] = {

	-- Clientside selection key.
	Key                 = KEY_RIGHT,
	DisplayName         = "Wave Beam",
	DisplayPos          = 640,
	Icon                = Material("models/metroid/hud/beammenu/wave/MAT_0_0"),

	-- Aim assist parameters.
	AimAssist           = false,
	ComboAutoTarget     = true,

	-- Projectile parameters.
	BeamDelay           = 0.5,
	BeamCloseSound      = true,

	ChargeColor         = Color(255, 53, 224, 2.5),
	ChargeBallColor     = Color(255, 0, 0, 0.25),
	ChargeGlowSize      = 200,
	ChargeViewPunch     = 20,
	ChargeDelay         = 0.5,

	MissileCloseDelay   = 1.1,
	MissileCloseDelay2  = 1.1,
	MissileCloseSound   = true,

	ComboViewPunch      = 30,
	ComboCost           = 10,
	ComboDelay          = 0,
	ComboReset          = 0.25,
	ComboLoopDelay      = 1,
	ComboUnderWater     = true,

	Projectiles = {
		["normal"]      = "mp_projectile_wavebeam_normal",
		["charge"]      = "mp_projectile_wavebeam_charge",
		["combo"]       = "mp_projectile_wavebuster"
	},

	-- Sound parameters for beam activities.
	Sounds = {
		["open"]        = Sound("weapons/wavebeam/open.wav"),
		["charge"]      = Sound("weapons/wavebeam/charge.wav"),
		["fire_normal"] = Sound("weapons/wavebeam/fire_normal.wav"),
		["fire_charge"] = Sound("weapons/wavebeam/fire_charge.wav"),
		["fire_combo"]  = Sound("weapons/wavebeam/fire_special.wav"),
	},

	-- View model and world model parameters.
	ViewModel           = Model("models/metroid/armcannon/c_wave.mdl"),
	WorldModel          = Model("models/metroid/armcannon/w_wave.mdl"),

	-- View model particle effects.
	ChargeEffect        = "mp_wavebeam_charge",
	MuzzleEffect        = "mp_powerbeam_muzzle",
	MuzzleBreakEffect   = nil,
	MuzzleComboEffect   = "mp_wavebeam_combo_muzzle",
	MuzzleLoopEffect    = "mp_wavebeam_combo_loop_muzzle",
	AmbientEffect       = nil,

	-- Beam menu settings.
	ModelName           = Model("models/metroid/hud/beammenu/v_wave.mdl")
};

-- Ice beam projectile setup table.
POWERSUIT.Beams[3] = {

	-- Clientside selection key.
	Key                 = KEY_DOWN,
	DisplayName         = "Ice Beam",
	DisplayPos          = 668,
	Icon                = Material("models/metroid/hud/beammenu/ice/MAT_0_0"),

	-- Aim assist parameters.
	AimAssist           = true,
	ComboAutoTarget     = false,

	-- Projectile parameters.
	BeamDelay           = 1,
	BeamCloseSound      = true,

	ChargeColor         = Color(0, 120, 255, 1),
	ChargeBallColor     = Color(60, 100, 140, 0.75),
	ChargeGlowSize      = 300,
	ChargeViewPunch     = 20,
	ChargeDelay         = 0.65,

	MissileCloseDelay   = 1.2,
	MissileCloseDelay2  = 1.2,
	MissileCloseSound   = true,

	ComboViewPunch      = 35,
	ComboCost           = 10,
	ComboDelay          = 0.3,
	ComboReset          = 1.7,
	ComboLoopDelay      = nil,
	ComboUnderWater     = true,

	Projectiles = {
		["normal"]      = "mp_projectile_icebeam_normal",
		["charge"]      = "mp_projectile_icebeam_charge",
		["combo"]       = "mp_projectile_icespreader"
	},

	-- Sound parameters for beam activities.
	Sounds = {
		["open"]        = Sound("weapons/icebeam/open.wav"),
		["charge"]      = Sound("weapons/icebeam/charge.wav"),
		["fire_normal"] = Sound("weapons/icebeam/fire_normal.wav"),
		["fire_charge"] = Sound("weapons/icebeam/fire_charge.wav"),
		["fire_combo"]  = Sound("weapons/icebeam/fire_special.wav"),
	},

	-- View model and world model parameters.
	ViewModel           = Model("models/metroid/armcannon/c_ice.mdl"),
	WorldModel          = Model("models/metroid/armcannon/w_ice.mdl"),

	-- View model particle effects.
	ChargeEffect        = "mp_icebeam_charge",
	MuzzleEffect        = "mp_icebeam_muzzle",
	MuzzleBreakEffect   = "mp_icebeam_charge_muzzle",
	MuzzleComboEffect   = "mp_icebeam_combo_muzzle",
	AmbientEffect       = "mp_icebeam_ambient",

	-- Beam menu settings.
	ModelName           = Model("models/metroid/hud/beammenu/v_ice.mdl")
};

-- Plasma beam projectile setup table.
POWERSUIT.Beams[4] = {

	-- Clientside selection key.
	Key                 = KEY_LEFT,
	DisplayName         = "Plasma Beam",
	DisplayPos          = 619,
	Icon                = Material("models/metroid/hud/beammenu/plasma/MAT_0_0"),

	-- Aim assist parameters.
	AimAssist           = true,
	ComboAutoTarget     = false,

	-- Projectile parameters.
	BeamDelay           = 0.35,
	BeamCloseSound      = true,

	ChargeColor         = Color(225, 145, 0, 1.5),
	ChargeGlowSize      = 200,
	ChargeViewPunch     = 15,
	ChargeDelay         = 0.8,

	MissileCloseDelay   = 1.2,
	MissileCloseDelay2  = 1.2,
	MissileCloseSound   = true,

	ComboViewPunch      = 25,
	ComboCost           = 10,
	ComboDelay          = 0,
	ComboReset          = 0.25,
	ComboLoopDelay      = 0.4,
	ComboUnderWater     = false,

	Projectiles = {
		["normal"]      = "mp_projectile_plasmabeam_normal",
		["charge"]      = "mp_projectile_plasmabeam_charge",
		["combo"]       = "mp_projectile_flamethrower"
	},

	-- Sound parameters for beam activities.
	Sounds = {
		["open"]        = Sound("weapons/plasmabeam/open.wav"),
		["charge"]      = Sound("weapons/plasmabeam/charge.wav"),
		["fire_normal"] = Sound("weapons/plasmabeam/fire_normal.wav"),
		["fire_charge"] = Sound("weapons/plasmabeam/fire_charge.wav"),
		["fire_combo"]  = Sound("weapons/plasmabeam/fire_special.wav"),
	},

	-- View model and world model parameters.
	ViewModel           = Model("models/metroid/armcannon/c_plasma.mdl"),
	WorldModel          = Model("models/metroid/armcannon/w_plasma.mdl"),

	-- View model particle effects.
	ChargeEffect        = "mp_plasmabeam_charge",
	MuzzleEffect        = nil,
	MuzzleBreakEffect   = nil,
	MuzzleComboEffect   = "mp_plasmabeam_combo_muzzle",
	MuzzleLoopEffect    = "mp_plasmabeam_combo_loop_muzzle",
	AmbientEffect       = nil,

	-- Beam menu settings.
	ModelName           = Model("models/metroid/hud/beammenu/v_plasma.mdl")
};

-- These sounds are shared across all beams. This must be added last
-- in order to respect the beams array indexing of 1 - 4.
POWERSUIT.Beams.Sounds = {
	["close"]         = Sound("weapons/beam/close_beam.wav"),
	["change"]        = Sound("weapons/beam/change.wav"),
	["equipped"]      = Sound("weapons/beam/equipped.wav"),
	["combo"]         = Sound("weapons/beam/special.wav"),
	["fire_missile"]  = Sound("weapons/missile/fire.wav"),
	["reload"]        = Sound("weapons/missile/reload.wav"),
	["close_muzzle"]  = Sound("weapons/missile/close_muzzle.wav"),
	["close_missile"] = Sound("weapons/missile/close_missile.wav"),
	["depleted"]      = Sound("weapons/missile/empty.wav")
};

POWERSUIT.MissileProjectile      = "mp_projectile_missile";

POWERSUIT.ViewModelFOV           = 62;
POWERSUIT.Weight                 = 1;
POWERSUIT.AutoSwitchTo           = true;
POWERSUIT.AutoSwitchFrom         = false;

POWERSUIT.ViewModel              = POWERSUIT.Beams[1].ViewModel;
POWERSUIT.WorldModel             = POWERSUIT.Beams[1].WorldModel;
POWERSUIT.AmbientEffect          = nil;
POWERSUIT.MuzzleOffset           = Vector(33.568420, 5.526276, 8.699661);
POWERSUIT.CSMuzzleFlashes        = false;
POWERSUIT.SelectorLayerKey       = KEY_E;
POWERSUIT.FidgetAnimations       = {
	ACT_VM_FIDGET,
	ACT_VM_PULLPIN,
	ACT_VM_THROW,
	ACT_VM_DRYFIRE
};

POWERSUIT.Primary.Ammo           = "none";
POWERSUIT.Primary.ClipSize       = -1;
POWERSUIT.Primary.DefaultClip    = -1;
POWERSUIT.Primary.Automatic      = true;

POWERSUIT.Secondary.Ammo         = "none";
POWERSUIT.Secondary.ClipSize     = -1;
POWERSUIT.Secondary.DefaultClip  = -1;
POWERSUIT.Secondary.Automatic    = false;