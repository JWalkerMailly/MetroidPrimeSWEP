
-- Syntactic sugar.
BOMB = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_bomb_base");

-- Sound properties
BOMB.Sounds = {};
BOMB.Sounds["explode"] = Sound("entities/morphball/powerbomb.wav");

-- Properties
BOMB.Radius            = 17;
BOMB.LifeTime          = 0;
BOMB.ResidualTime      = 4;

-- Blast damage
BOMB.DamageEffect      = DMG_DISSOLVE;
BOMB.DamageType        = bit.bor(DMG_MP_BOMB, DMG_MP_SPECIAL);
BOMB.BlastDamage       = 50;
BOMB.BlastRadius       = 400;
BOMB.BlastKnockBack    = 0;

BOMB.BombEffect        = "mp_morphball_powerbomb";
BOMB.Blast3DEffect     = "mp_powerbomb_blast";

function BOMB:DetonateCallback(pos)

	-- Swap radius data before growing.
	self.BlastMaxRadius = self.BlastMaxRadius || self.BlastRadius;
	if (self.BlastRadius == self.BlastMaxRadius) then self.BlastRadius = self.Radius; end

	-- Continuously grow blast radius according to residual time.
	self.BlastRadius = self.BlastRadius + ((self.BlastMaxRadius * FrameTime()) / self.ResidualTime);
end