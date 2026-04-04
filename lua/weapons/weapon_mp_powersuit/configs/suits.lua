
game.MetroidPrimeSuitVariants["Prime"] = {};

-- Power suit setup table.
game.MetroidPrimeSuitVariants["Prime"][1] = {

	DisplayName     = "Power Suit",

	WorldModel      = Model("models/impulse/metroid/samus/samus_powersuit_playermodel.mdl"),
	Group           = 1,
	Skin            = 0,
	DamageScale     = 1,

	MorphBall = {
		WorldModel  = Model("models/metroid/morphball/powersuit.mdl"),
		Glow        = Color(255, 255, 255),
		Color       = Color(255, 125, 0, 0.5),
		Group       = 0,
		Skin        = 0,
		Trail       = Material("entities/morphball/powertrail"),
		Effect      = "mp_morphball_powersuit",
		Scale       = 0.9
	}
};

-- Varia suit setup table.
game.MetroidPrimeSuitVariants["Prime"][2] = {

	DisplayName     = "Varia Suit",

	WorldModel      = Model("models/impulse/metroid/samus/samus_playermodel.mdl"),
	Group           = 1,
	Skin            = 0,
	DamageScale     = 0.9,

	MorphBall = {
		WorldModel  = Model("models/metroid/morphball/powersuit.mdl"),
		Glow        = Color(255, 255, 255),
		Color       = Color(75, 225, 255, 0.5),
		Group       = 0,
		Skin        = 1,
		Trail       = Material("entities/morphball/variatrail"),
		Effect      = "mp_morphball_variasuit",
		Scale       = 0.9
	},

	SpiderBall = {
		WorldModel  = Model("models/metroid/morphball/powersuit.mdl"),
		Color       = Color(40, 200, 40, 0.5),
		Group       = 1,
		Boost       = 2,
		Skin        = 0,
		Trail       = Material("entities/morphball/spidertrail"),
		Effect      = "mp_morphball_spider",
		Scale       = 0.9
	}
};

-- Gravity suit setup table.
game.MetroidPrimeSuitVariants["Prime"][3] = {

	DisplayName     = "Gravity Suit",

	WorldModel      = Model("models/impulse/metroid/samus/samus_playermodel.mdl"),
	Group           = 1,
	Skin            = 1,
	DamageScale     = 0.8,

	SpiderBall = {
		WorldModel  = Model("models/metroid/morphball/powersuit.mdl"),
		Color       = Color(20, 40, 255, 1),
		Group       = 1,
		Boost       = 2,
		Skin        = 1,
		Trail       = Material("entities/morphball/gravitytrail"),
		Effect      = "mp_morphball_gravitysuit",
		Scale       = 0.9
	}
};

-- Phazon suit setup table.
game.MetroidPrimeSuitVariants["Prime"][4] = {

	DisplayName     = "Phazon Suit",

	WorldModel      = Model("models/impulse/metroid/samus/samus_playermodel.mdl"),
	Group           = 1,
	Skin            = 2,
	DamageScale     = 0.5,

	MorphBall = {
		Glow        = Color(255, 185, 0)
	},

	SpiderBall = {
		WorldModel  = Model("models/metroid/morphball/powersuit.mdl"),
		Color       = Color(255, 65, 50, 0.5),
		Group       = 1,
		Boost       = 2,
		Skin        = 2,
		Trail       = Material("entities/morphball/phazontrail"),
		Effect      = "mp_morphball_phazonsuit",
		Scale       = 0.9
	}
};

POWERSUIT.Suits = {};
POWERSUIT.Suits.Variant = {};

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