
POWERSUIT.Suits = {};

-- Power suit setup table.
POWERSUIT.Suits[1] = {

	DisplayName     = "Power Suit",

	WorldModel      = "models/impulse/metroid/samus/samus_powersuit_playermodel.mdl",
	Group           = 1,
	Skin            = 0,
	DamageScale     = 1,

	MorphBall = {
		Glow        = Color(255, 255, 255),
		Color       = Color(255, 125, 0, 0.5),
		Group       = 0,
		Skin        = 0,
		Trail       = Material("entities/morphball/powertrail"),
		Effect      = "mp_morphball_powersuit"
	},

	SpiderBall = {
		Model       = false,
		Color       = Color(255, 125, 0, 0.5),
		Group       = 0,
		Glass       = 2,
		Skin        = 0,
		Trail       = Material("entities/morphball/powertrail"),
		Effect      = "mp_morphball_powersuit"
	}
};

-- Varia suit setup table.
POWERSUIT.Suits[2] = {

	DisplayName     = "Varia Suit",

	WorldModel      = "models/impulse/metroid/samus/samus_playermodel.mdl",
	Group           = 1,
	Skin            = 0,
	DamageScale     = 0.9,

	MorphBall = {
		Glow        = Color(255, 255, 255),
		Color       = Color(75, 225, 255, 0.5),
		Group       = 0,
		Skin        = 1,
		Trail       = Material("entities/morphball/variatrail"),
		Effect      = "mp_morphball_variasuit"
	},

	SpiderBall = {
		Model       = true,
		Color       = Color(40, 200, 40, 0.5),
		Group       = 1,
		Glass       = 2,
		Skin        = 0,
		Trail       = Material("entities/morphball/spidertrail"),
		Effect      = "mp_morphball_spider"
	}
};

-- Gravity suit setup table.
POWERSUIT.Suits[3] = {

	DisplayName     = "Gravity Suit",

	WorldModel      = "models/impulse/metroid/samus/samus_playermodel.mdl",
	Group           = 1,
	Skin            = 1,
	DamageScale     = 0.8,

	MorphBall = {
		Glow        = Color(255, 255, 255),
		Color       = Color(20, 40, 255, 1),
		Group       = 1,
		Skin        = 1,
		Trail       = Material("entities/morphball/gravitytrail"),
		Effect      = "mp_morphball_gravitysuit"
	},

	SpiderBall = {
		Model       = true,
		Color       = Color(20, 40, 255, 1),
		Group       = 1,
		Glass       = 2,
		Skin        = 1,
		Trail       = Material("entities/morphball/gravitytrail"),
		Effect      = "mp_morphball_gravitysuit"
	}
};

-- Phazon suit setup table.
POWERSUIT.Suits[4] = {

	DisplayName     = "Phazon Suit",

	WorldModel      = "models/impulse/metroid/samus/samus_playermodel.mdl",
	Group           = 1,
	Skin            = 2,
	DamageScale     = 0.5,

	MorphBall = {
		Glow        = Color(255, 185, 0),
		Color       = Color(255, 65, 50, 0.5),
		Group       = 1,
		Skin        = 2,
		Trail       = Material("entities/morphball/phazontrail"),
		Effect      = "mp_morphball_phazonsuit"
	},

	SpiderBall = {
		Model       = true,
		Color       = Color(255, 65, 50, 0.5),
		Group       = 1,
		Glass       = 2,
		Skin        = 2,
		Trail       = Material("entities/morphball/phazontrail"),
		Effect      = "mp_morphball_phazonsuit"
	}
};

-- These sounds are shared across all suits. This must be added last
-- in order to respect the suits array indexing of 1 - 4.
POWERSUIT.Suits.Sounds = {
	["dash"]           = Sound("weapons/jump/dash.wav"),
	["jump_1"]         = Sound("weapons/jump/jump_1.wav"),
	["jump_2"]         = Sound("weapons/jump/jump_2.wav"),
	["grapple_fire"]   = Sound("weapons/grapplebeam/fire.wav"),
	["grapple_anchor"] = Sound("weapons/grapplebeam/anchor.wav"),
	["morph"]          = Sound("entities/morphball/morph.wav")
};

POWERSUIT.MorphBallVehicle = "mp_morphball";

POWERSUIT.JumpCount        = 0;
POWERSUIT.JumpTime         = 0;
POWERSUIT.Dashing          = false;
POWERSUIT.WasMoving        = false;

POWERSUIT.GrappleStart     = nil;
POWERSUIT.GrappleDistance  = nil;
POWERSUIT.GrappleStartTime = nil;

POWERSUIT.SwingStart       = nil;
POWERSUIT.SwingLastPos     = nil;
POWERSUIT.SwingStartPos    = nil;
POWERSUIT.SwingStartTime   = nil;
POWERSUIT.SwingStartAngle  = nil;
POWERSUIT.SwingViewAngle   = nil;
POWERSUIT.SwingVelocity    = nil;
POWERSUIT.Swinging         = false;