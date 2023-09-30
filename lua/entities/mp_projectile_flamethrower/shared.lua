
-- Syntactic sugar.
PROJECTILE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("mp_projectile_base");
PROJECTILE.RemoveOnCollide = false;

-- Properties
PROJECTILE.Radius          = 5;
PROJECTILE.GlowColor       = Color(200, 83, 25, 1);
PROJECTILE.GlowSize        = 300;
PROJECTILE.GlowStyle       = 1;

-- Damage data
PROJECTILE.DamageType      = bit.bor(DMG_MP_PLASMA, DMG_MP_SPECIAL);
PROJECTILE.Damage          = 1.2;

function PROJECTILE:HitScanThink(weapon, shoot)

	if (!SERVER) then return; end

	-- If the target is in range, lock the aim position to its location.
	local maxDist = weapon.Helmet.Constants.Visor.LockOnDistance / 2;
	local aimPos  = shoot.ShootPos + shoot.AimVector * maxDist;
	if (shoot.Locked && shoot.ValidTarget && shoot.Target:GetPos():DistToSqr(shoot.Owner:GetPos()) < (maxDist * maxDist)) then
		aimPos = shoot.Target:GetLockOnPosition();
	end

	-- Lerp aim position for swaying effect.
	self:SetCollisionEndPos(LerpVector(FrameTime() * 3.5, self:GetCollisionEndPos() || shoot.ShootPos, aimPos));
end