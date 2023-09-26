
DEFINE_BASECLASS("base_anim");

-- Syntactic sugar.
PROJECTILE             = ENT;
PROJECTILE.RenderGroup = RENDERGROUP_BOTH;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

-- Collision properties.
PROJECTILE.Radius              = 2.5;
PROJECTILE.CollisionFilter     = nil;
PROJECTILE.RemoveDelay         = nil;
PROJECTILE.RemoveOnCollide     = true;
PROJECTILE.HitScanPos          = nil;
PROJECTILE.HitScanAssist       = false;
PROJECTILE.HitScanAuto         = false;

-- Particle effects.
PROJECTILE.ProjectileEffect    = nil;
PROJECTILE.ImpactEffect        = nil;

-- Properties
PROJECTILE.Speed               = 0;
PROJECTILE.RotationRate        = nil;
PROJECTILE.LifeTime            = 0;
PROJECTILE.FullCharge          = false;
PROJECTILE.GlowColor           = Color(255, 255, 255, 1);
PROJECTILE.GlowSize            = 400;
PROJECTILE.GlowStyle           = 0;
PROJECTILE.BlastColor          = Color(255, 255, 255, 0);
PROJECTILE.BlastSize           = 0;
PROJECTILE.BlastDieTime        = 0;
PROJECTILE.BlastDecay          = 0;
PROJECTILE.BlastStyle          = 0;

-- Damage data
PROJECTILE.DamageType          = DMG_MP_NULL;
PROJECTILE.Damage              = 0;
PROJECTILE.KnockBack           = 0;
PROJECTILE.DamageFull          = 0;
PROJECTILE.KnockBackFull       = 0;

-- Blast damage
PROJECTILE.BlastDamage         = 0;
PROJECTILE.BlastRadius         = 0;
PROJECTILE.BlastKnockBack      = 0;
PROJECTILE.BlastDamageFull     = 0;
PROJECTILE.BlastRadiusFull     = 0;
PROJECTILE.BlastKnockBackFull  = 0;

-- Tracking parameters
PROJECTILE.Homing              = false;
PROJECTILE.HomingLag           = 0;

-- Oscillation properties
PROJECTILE.Oscillator          = false;
PROJECTILE.OscillatorParent    = false;
PROJECTILE.OscillationSpeed    = 0;
PROJECTILE.OscillationFactor   = 0;
PROJECTILE.OscillationDomain   = 0;
PROJECTILE.OscillationDegree   = 0;
PROJECTILE.OscillationOffset   = 0;

-- Prepare sounds lookup table.
PROJECTILE.Sounds              = {};

function PROJECTILE:SetupDataTables()
	WGL.AddProperty(self, "Weapon",          "Entity");
	WGL.AddProperty(self, "CollisionPos",    "Vector");
	WGL.AddProperty(self, "CollisionNormal", "Vector");
	WGL.AddProperty(self, "CollisionRan",    "Bool");
	WGL.AddProperty(self, "Collided",        "Bool");
end

function PROJECTILE:Initialize()

	if (SERVER) then

		-- Prepare physics sphere for our projectile.
		self:SetModel("models/effects/combineball.mdl");
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
		self:PhysicsInitSphere(self.Radius, "default");
		self:SetCollisionBounds(WGL.OneVec * -self.Radius, WGL.OneVec * self.Radius);
		self:SetNotSolid(true);
		self:DrawShadow(false);
		self:PhysWake();
		self:SetLagCompensated(true);
		self:NextThink(CurTime());

		-- Prepare physics properties for the projectile to fly.
		local physObject = self:GetPhysicsObject();
		physObject:EnableDrag(false);
		physObject:EnableGravity(false);
		physObject:SetBuoyancyRatio(0);
	end

	if (CLIENT) then

		-- Force rendering even when not in immediate view.
		if (!self.RemoveOnCollide) then
			self:SetRenderBounds(WGL.OneVec * -1200, WGL.OneVec * 1200);
		end

		-- Attach particle system onto the projectile if supplied.
		if (game.SinglePlayer()) then
			if (self.ProjectileEffectSP != nil) then ParticleEffectAttach(self.ProjectileEffectSP, PATTACH_ABSORIGIN_FOLLOW, self, 0); end
		else
			if (self.ProjectileEffect != nil) then ParticleEffectAttach(self.ProjectileEffect, PATTACH_ABSORIGIN_FOLLOW, self, 0); end
		end
	end
end

function PROJECTILE:SetCollisionFilter(filter)
	self.CollisionFilter = filter || nil;
end

function PROJECTILE:GetCollisionEndPos()
	return self.HitScanPos;
end

function PROJECTILE:SetCollisionEndPos(endPos)
	self.HitScanPos = endPos;
end

function PROJECTILE:SetFullCharge(full)
	self.FullCharge = full;
end

function PROJECTILE:GetDamage()
	return self.FullCharge && self.DamageFull || self.Damage;
end

function PROJECTILE:GetKnockBack()
	return self.FullCharge && self.KnockBackFull || self.KnockBack;
end

function PROJECTILE:GetBlastRadius()
	return self.FullCharge && self.BlastRadiusFull || self.BlastRadius;
end

function PROJECTILE:GetBlastDamage()
	return self.FullCharge && self.BlastDamageFull || self.BlastDamage;
end

function PROJECTILE:GetBlastKnockBack()
	return self.FullCharge && self.BlastKnockBackFull || self.BlastKnockBack;
end

function PROJECTILE:SetTarget(target)

	if (!IsValid(target)) then return; end
	self.HomingOffset = Vector(0, 0, target:OBBCenter()[3]);
	self.HomingTarget = target;
end

function PROJECTILE:SetRoll(degrees, parent)

	-- Define roll in local space or parent space.
	self.Roll     = degrees;
	local forward = !parent && self:GetForward() || parent:GetForward();
	local angles  = !parent && self:GetAngles()  || parent:GetAngles();

	-- Set angles relative to self or parent.
	angles:RotateAroundAxis(forward, degrees);
	self:SetAngles(angles);
end

function PROJECTILE:SetRollRelatives()

	-- Roll relative angle defines the angle constant between parent and child.
	-- Oscillators' position is always relative to parent.
	self.RollRelativeAngle = self:GetParent():GetAngles() - self:GetAngles();

	-- Define roll relative angle to parent.
	local rollAngle = Angle(self.RollRelativeAngle[1], self.RollRelativeAngle[2], self.RollRelativeAngle[3]);
	rollAngle:RotateAroundAxis(Vector(1, 0, 0), self:GetParent().Roll);

	-- Define relative up to parent.
	self.RollRelativeUp = Vector(0, 0, 1);
	self.RollRelativeUp:Rotate(rollAngle);

	-- Define relative offset to parent.
	self.RollRelativeOffset = Vector(0, 0, self.OscillationOffset);
	self.RollRelativeOffset:Rotate(rollAngle);
end

function PROJECTILE:ShootCallback(shootdata, degrees, parent, fullCharge)
	return self;
end

function PROJECTILE:Shoot(shootdata, degrees, parent, fullCharge)

	-- Setup references.
	self:SetOwner(shootdata.Owner);
	self:SetWeapon(shootdata.Weapon);
	if (shootdata.ValidTarget && shootdata.Locked) then self:SetTarget(shootdata.Target); end

	-- Copy shoot data to projectile.
	self.HitScanAssist = shootdata.Assist;
	self.HitScanAuto = shootdata.Auto;
	self:SetFullCharge(fullCharge);
	self:SetRoll(degrees, parent);
	self:SetParent(parent);

	-- Apply positioning for normal and hitscan projectiles.
	if (IsValid(parent)) then
		self:SetPos(parent:GetPos());
		self:SetRollRelatives();
	else
		local velocity       = shootdata.Owner:GetVelocity();
		self.InitialVelocity = WGL.Clamp(shootdata.AimVector:Dot(velocity)) * velocity:Length();
		self:SetPos(shootdata.ShootPos);
		self:SetAngles(shootdata.AimVector:Angle());
	end

	self:Spawn();
	return self:ShootCallback(shootdata, degrees, parent, fullCharge);
end

function PROJECTILE:Oscillate()

	-- Define oscillation wave function according to oscillator parameters.
	local wave        = math.sin((CurTime() - self.SpawnTime) * self.OscillationSpeed + self.OscillationDegree);
	local oscillator  = (wave + self.OscillationDomain) / (1.0 + self.OscillationDomain);
	local oscillation = self.RollRelativeUp * oscillator * self.OscillationFactor;
	self:SetPos(self.RollRelativeOffset + oscillation);

	return true;
end

function PROJECTILE:PreThink()

	if (!CLIENT || self.Oscillator) then return; end

	-- Render dynamic lighting emanating from the projectile.
	if (!self:GetCollided()) then
		WGL.EmitLight(self, self:GetPos(), self.GlowColor, 1000, self.GlowSize, CurTime() + FrameTime(), self.GlowStyle);
	else
		WGL.EmitLight(self, self:GetCollisionPos(), self.BlastColor, self.BlastDecay, self.BlastSize, CurTime() + self.BlastDieTime, self.BlastStyle);
	end
end

function PROJECTILE:HitScanPreThink()

	-- Grab current weapon for shootdata.
	local weapon = self:GetWeapon();
	if (!IsValid(weapon)) then return self:Destroy(true); end

	local shoot = weapon:GetAimData(self.HitScanAssist, self.HitScanAuto);
	self:SetPos(shoot.ShootPos);
	self:HitScanThink(weapon, shoot);

	if (CLIENT && self:GetCollisionRan()) then

		-- Render lighting at the end point and setup for effects.
		self.ValidTarget = IsValid(shoot.Target);
		self.EndPos      = self:GetCollisionPos();
		self.EndNormal   = self:GetCollisionNormal();
		WGL.EmitLight(self, self.EndPos, self.GlowColor, 1000, self.GlowSize, CurTime() + FrameTime(), self.GlowStyle);
	end
end

function PROJECTILE:HitScanThink(weapon, shoot)
	if (SERVER) then self:SetCollisionEndPos(shoot.ShootPos + shoot.AimVector * weapon.Helmet.Constants.Visor.LockOnDistance); end
end

function PROJECTILE:Think()

	-- Think delegate call.
	self.SpawnTime = self.SpawnTime || CurTime();
	self:NextThink(CurTime());

	-- Handle prethink routines for regular and hitscan projectiles.
	if (self.RemoveOnCollide) then self:PreThink();
	else self:HitScanPreThink(); end

	-- Handle collision prediction and oscillation.
	if (!SERVER || self:GetCollided() || self:PredictCollisions()) then return; end
	if (self.Oscillator) then return self:Oscillate(); end

	-- Handle projectile lifetime.
	if ((self.SpawnTime + self.LifeTime < CurTime()) || (self.OscillatorParent && #self:GetChildren() <= 0)) then
		self:Destroy();
	end

	return true;
end

function PROJECTILE:Destroy(force)

	if (!SERVER) then return; end

	-- Cleanup. Delay by two ticks for effects to have a chance to catch up.
	if (!force && !self.RemoveOnCollide) then return; end

	-- Safely remove projectile and effects.
	self:SetParent(NULL);
	self:SetCollided(true);
	if (self.Oscillator) then self:StopParticles(); end
	SafeRemoveEntityDelayed(self, self.RemoveDelay || (FrameTime() * 2));
end