
POWERSUIT.Visors = {};

-- Combat visor setup table.
POWERSUIT.Visors[1] = {

	-- Clientside selection key.
	Key                 = KEY_UP,
	DisplayName         = "Combat Visor",
	GuiColor            = Color(0.3647, 0.4823, 0.6),

	-- Hud function to call.
	Hud                 = "CombatVisor",
	BeamDelay           = 0,

	-- Visor menu settings.
	ModelName           = Model("models/metroid/hud/visormenu/v_combat.mdl"),

	-- Sound parameters for beam activities.
	Sounds = {
		["change"]      = Sound("visors/visor_in.wav"),
		["ambient"]     = nil,
		["aimlock"]     = Sound("visors/aimlock.wav"),
		["grapple"]     = Sound("visors/grapple.wav")
	},

	-- Special settings.
	ShouldHideBeamMenu  = false,
	ShouldHideVisorMenu = false,
	ShouldReflectFace   = true,
	AllowLockDash       = true,
	AllowLockAll        = false
};

-- Scan visor setup table.
POWERSUIT.Visors[2] = {

	-- Clientside selection key.
	Key                 = KEY_LEFT,
	DisplayName         = "Scan Visor",
	GuiColor            = Color(0.3647, 0.4823, 0.6),

	-- Hud function to call.
	Hud                 = "ScanVisor",
	BeamDelay           = 1,

	-- Visor menu settings.
	ModelName           = Model("models/metroid/hud/visormenu/v_scan.mdl"),

	-- Sound parameters for beam activities.
	Sounds = {
		["change"]      = Sound("visors/visor_out.wav"),
		["ambient"]     = Sound("visors/scan.wav"),
		["aimlock"]     = Sound("visors/aimlock.wav"),
		["grapple"]     = Sound("visors/aimlock.wav")
	},

	-- Special settings.
	ShouldHideBeamMenu  = true,
	ShouldHideVisorMenu = false,
	ShouldReflectFace   = false,
	AllowLockDash       = false,
	AllowLockAll        = true,

	-- Helmet ambient lighting.
	AmbientLight = {
		Color           = Color(50, 50, 50, 1),
		Decay           = 1000,
		Size            = 100
	}
};

-- Thermal visor setup table.
local thermalTexturizer = Material("huds/thermal/thermal.png");
POWERSUIT.Visors[3] = {

	-- Clientside selection key.
	Key                 = KEY_DOWN,
	DisplayName         = "Thermal Visor",
	GuiColor            = Color(0.3647, 0.4823, 0.8),

	-- Hud function to call.
	Hud                 = "ThermalVisor",
	BeamDelay           = 0,

	-- Visor menu settings.
	ModelName           = Model("models/metroid/hud/visormenu/v_thermal.mdl"),

	-- Sound parameters for beam activities.
	Sounds = {
		["change"]      = Sound("visors/visor_out.wav"),
		["ambient"]     = Sound("visors/thermal.wav"),
		["aimlock"]     = Sound("visors/aimlock.wav"),
		["grapple"]     = Sound("visors/grapple.wav")
	},

	-- Special settings.
	ShouldHideBeamMenu  = false,
	ShouldHideVisorMenu = false,
	ShouldReflectFace   = false,
	AllowLockDash       = true,
	AllowLockAll        = false,

	-- Viewmodel material overrides.
	ViewModelMaterials  = "models/metroid/armcannon/thermal/",
	ViewModelExceptions = {
		[1]             = false,
		[2]             = false,
		[3]             = true,
		[4]             = false
	},

	-- Entity material swapping while using visor.
	MaterialFilter      = function(entity)

		if (!IsValid(entity)) then return nil; end

		-- All living entities are hot by default unless specified to be cold.
		-- Call to API for implementation homogenization.
		if (entity:HasHeatSignature()) then
			return "huds/thermal/thermal_hot";
		end
	end,

	-- Helmet ambient lighting.
	AmbientLight = {
		Color           = Color(50, 50, 50, 1),
		Decay           = 1000,
		Size            = 100
	},

	-- World lighting.
	ProjectedTexture = {
		Texture         = "huds/thermal/neutralize_red",
		FOV             = 179,
		FOVV            = 179,
		Brightness      = 6,
		Distance        = 10000,
		Attenuation     = 10000
	},

	-- Visor shader pass.
	Shader = function()

		-- Color modify now before any other rendering operations. This way
		-- the texturizer will be compounded on top.
		DrawColorModify({
			["$pp_colour_addr"]       = 0   * 0.02,
			["$pp_colour_addg"]       = 0   * 0.02,
			["$pp_colour_addb"]       = 0   * 0.02,
			["$pp_colour_mulr"]       = 125 * 0.1,
			["$pp_colour_mulg"]       = 75 * 0.1,
			["$pp_colour_mulb"]       = 45  * 0.1,
			["$pp_colour_brightness"] = 0.04,
			["$pp_colour_contrast"]   = 0.15,
			["$pp_colour_colour"]     = 0.0
		});

		-- Render first bloom pass and apply texurizer to achieve thermal effect.
		DrawBloom(0.65, 3.1, 1.75, 0.45, 2, -7, 70 / 255, 0 / 255, 0 / 255);
		DrawTexturize(1, thermalTexturizer);
	end
};

-- XRay visor setup table.
local xrayTexturizer = Material("huds/xray/xray.png");
POWERSUIT.Visors[4] = {

	-- Clientside selection key.
	Key                 = KEY_RIGHT,
	DisplayName         = "X-Ray Visor",
	GuiColor            = Color(0.64, 0.64, 0.75),

	-- Hud function to call.
	Hud                 = "XRayVisor",
	BeamDelay           = 0,

	-- Visor menu settings.
	ModelName           = Model("models/metroid/hud/visormenu/v_xray.mdl"),

	-- Sound parameters for beam activities.
	Sounds = {
		["change"]      = Sound("visors/visor_out.wav"),
		["ambient"]     = Sound("visors/xray.wav"),
		["aimlock"]     = Sound("visors/aimlock.wav"),
		["grapple"]     = Sound("visors/grapple.wav")
	},

	-- Special settings.
	ShouldHideBeamMenu  = false,
	ShouldHideVisorMenu = false,
	ShouldReflectFace   = false,
	AllowLockDash       = true,
	AllowLockAll        = false,

	-- Viewmodel material overrides.
	ViewModelMaterials  = "models/metroid/armcannon/xray/",

	-- Entity material swapping while using visor.
	MaterialFilter      = function(entity)

		-- Test entity for visibility/invisibility.
		if (entity:IsXRayHot())  then return "huds/xray/xray_hot"; end
		if (entity:IsXRayCold()) then return "huds/xray/xray_cold"; end
	end,

	-- Helmet ambient lighting.
	AmbientLight = {
		Color           = Color(75, 75, 255, 1),
		Decay           = 1000,
		Size            = 100
	},

	-- World lighting.
	ProjectedTexture = {
		Texture         = "vgui/white",
		FOV             = 179,
		FOVV            = 179,
		Brightness      = 2.5,
		Distance        = 800,
		Attenuation     = 100
	},

	-- World shadowing.
	Fog = {
		Color           = Color(0, 0, 0),
		Density         = 1,
		Start           = 0,
		End             = 1000
	},

	-- Visor shader pass.
	Shader = function()
		DrawSharpen(0.25, 10);
		DrawTexturize(1, xrayTexturizer);
		DrawBloom(0.5, 4, 17, 0, 0, 0, 1, 1, 1);
	end
};

POWERSUIT.Visors.Sounds = {
	["warning"]        = Sound("visors/warning.wav"),
	["low_energy"]     = Sound("visors/low_energy.wav"),
	["low_missiles"]   = Sound("visors/low_missiles.wav"),
	["scan_raise"]     = Sound("visors/scan_raise.wav"),
	["scan_start"]     = Sound("visors/scan_start.wav"),
	["scanning"]       = Sound("visors/scanning.wav"),
	["scan_complete"]  = Sound("visors/scan_complete.wav"),
	["scan_paragraph"] = Sound("visors/scan_paragraph.wav"),
	["scan_lower"]     = Sound("visors/scan_lower.wav"),
	["scan_end"]       = Sound("visors/scan_end.wav")
};

POWERSUIT.DrawAmmo               = false;
POWERSUIT.DrawCrosshair          = false;

POWERSUIT.HealthState            = {};
POWERSUIT.AlertState             = {};
POWERSUIT.MissileState           = {};
POWERSUIT.DamageFlash            = Material("huds/white_additive");

POWERSUIT.BobScale               = 0;
POWERSUIT.SwayScale              = 0;
POWERSUIT.LastViewPunch          = 0;
POWERSUIT.LastCursorPos          = Vector(0, 0, 0);
POWERSUIT.ViewResetSpeed         = 0.5;

POWERSUIT.LastViewSway           = Angle(0, 0, 0);
POWERSUIT.ViewSway               = {};
POWERSUIT.ViewSway.Lerp          = 0;
POWERSUIT.ViewSway.Time          = 0;
POWERSUIT.ViewSway.Duration      = nil;

POWERSUIT.LastViewModelSway      = Angle(0, 0, 0);
POWERSUIT.ViewModelSway          = {};
POWERSUIT.ViewModelSway.Lerp     = 0;
POWERSUIT.ViewModelSway.Time     = 0;
POWERSUIT.ViewModelSway.Duration = nil;

POWERSUIT.ViewModelRoll          = 0;
POWERSUIT.ViewModelRollBuffer    = 0.5;
POWERSUIT.ViewModelRollCompleted = false;
POWERSUIT.LastViewModelRoll      = 0;

POWERSUIT.LastGesture            = Vector(0, 0, 0);
POWERSUIT.LastGestureSet         = false;
POWERSUIT.LastGestureKey         = nil;