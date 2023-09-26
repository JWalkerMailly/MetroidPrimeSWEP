
-- Syntactic sugar.
BOMB = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_bomb_base");

-- Sound properties
BOMB.Sounds = {
	["bomb"]    = Sound("entities/morphball/bomb.wav"),
	["explode"] = Sound("entities/morphball/explode.wav")
};

-- Properties
BOMB.Radius          = 17;
BOMB.LifeTime        = 1.1;
BOMB.ResidualTime    = 0;

-- Lighting
BOMB.BlastColor      = Color(20, 78, 255, 3);
BOMB.BlastSize       = 500;
BOMB.BlastDieTime    = 1;
BOMB.BlastDecay      = 1000;
BOMB.BlastStyle      = 0;

-- Blast damage
BOMB.DamageType      = DMG_MP_BOMB;
BOMB.BlastDamage     = 10;
BOMB.BlastRadius     = 80;
BOMB.BlastKnockBack  = 1000;

-- Effects
BOMB.BombEffect      = "mp_morphball_bomb_set"
BOMB.ExplosionEffect = "mp_morphball_bomb_explosion";

function BOMB:DetonateCallback(pos)

	if (!IsValid(self.MorphBall)) then return; end
	debugoverlay.Sphere(pos, 22, 1, Color(0, 255, 0, 0));

	-- Apply bomb jump to owner if using the morphball.
	if (CurTime() < self.MorphBall:GetBombJumpTime() || self.MorphBall:GetPos():DistToSqr(pos) > 2000) then return; end
	local phys = self.MorphBall:GetPhysicsObject();
	phys:SetVelocityInstantaneous(WGL.UpVec * 650);
	self.MorphBall:SetBombJumpTime(CurTime() + 0.15);
end