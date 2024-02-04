
DEFINE_BASECLASS("base_anim");

-- Syntactic sugar.
BOMB             = ENT;
BOMB.RenderGroup = RENDERGROUP_BOTH;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

-- Properties
BOMB.Radius          = 0;
BOMB.LifeTime        = 0;
BOMB.ResidualTime    = 0;

-- Lighting
BOMB.BlastColor      = Color(255, 255, 255, 0);
BOMB.BlastSize       = 0;
BOMB.BlastDieTime    = 0;
BOMB.BlastDecay      = 0;
BOMB.BlastStyle      = 0;

-- Blast damage
BOMB.DamageType      = DMG_MP_BOMB;
BOMB.BlastDamage     = 0;
BOMB.BlastRadius     = 0;
BOMB.BlastKnockBack  = 0;

-- Effects
BOMB.BombEffect      = nil;
BOMB.Blast3DEffect   = nil;
BOMB.ExplosionEffect = nil;

function BOMB:SetupDataTables()
	self:NetworkVar("Float", 0, "SpawnTime");
end

function BOMB:Initialize()

	-- Attach shared particle system onto the bomb if supplied.
	if (CLIENT && self.BombEffect != nil) then
		ParticleEffectAttach(self.BombEffect, PATTACH_ABSORIGIN_FOLLOW, self, 0);
	end

	if (!SERVER) then return; end
	if (!IsValid(self:GetOwner()) || !IsValid(self.MorphBall)) then return self:Remove(); end

	-- Prepare physics sphere for our bomb.
	if (!game.SinglePlayer()) then self:NextThink(CurTime()); end
	self:SetModel("models/effects/combineball.mdl");
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self:PhysicsInitSphere(self.Radius, "default");
	self:SetCollisionBounds(Vector(0, 0, 0), Vector(0, 0, 0));
	self:SetNotSolid(true);
	self:DrawShadow(false);
	self:PhysWake();
	self:SetLagCompensated(true);
	self:SetSpawnTime(CurTime());

	-- Handle moving surfaces.
	local surfaceParent = self.MorphBall:GetSurfaceParent();
	if (IsValid(surfaceParent)) then
		self:SetParent(surfaceParent);
	end

	-- Prepare physics properties for the bomb to remain stationary.
	local physObject = self:GetPhysicsObject();
	physObject:EnableGravity(false);

	-- Play bomb spawn sound, if any.
	if (self.Sounds["bomb"] != nil) then
		sound.Play(self.Sounds["bomb"], self:GetPos(), 75, 100, 1);
	end

	-- Add blast effect if supplied.
	if (self.Blast3DEffect != nil) then
		ParticleSystem3D(self.Blast3DEffect, self:GetPos(), self:GetAngles(), 5);
	end

	-- Debug bomb.
	debugoverlay.Sphere(self:GetPos(), self.Radius, self.LifeTime, Color(255, 255, 255, 0));
end

function BOMB:SetMorphBall(morphball)
	self.MorphBall = morphball;
end

function BOMB:CanDamage(owner, entity)
	return entity != owner && IsValid(entity) && entity:IsSolid() && entity:GetOwner() != owner;
end

function BOMB:ApplyDamage(entity, damage)

	-- If owner turns invalid, let the bomb be the attacker.
	local owner = self:GetOwner();
	if (!IsValid(owner)) then owner = self; end
	if (!self:CanDamage(owner, entity)) then return false, owner; end

	-- bombs that are residual use hitscan damage at 60fps.
	local damageInfo = DamageInfo();
	damageInfo:SetDamage((self.ResidualTime <= 0) && damage || damage * (FrameTime() / (1 / 60)));
	damageInfo:SetAttacker(owner);
	damageInfo:SetInflictor(self);
	damageInfo:SetDamageType(self.DamageEffect || DMG_GENERIC);
	damageInfo:SetDamageCustom(self.DamageType);
	entity:TakeDamageInfo(damageInfo);
	if (GetConVar("developer"):GetInt() > 1) then print(damageInfo); end

	return true, owner;
end

function BOMB:ApplyBlastDamage(pos)

	for k,v in pairs(ents.FindInSphere(pos, self.BlastRadius)) do

		-- Apply blast damage.
		if (!self:ApplyDamage(v, self.BlastDamage)) then continue; end

		-- Apply blast knockback.
		local vPhys = v:GetPhysicsObject();
		if (IsValid(vPhys)) then vPhys:ApplyForceCenter((v:GetPos() - pos):GetNormalized() * self.BlastKnockBack); end
	end

	debugoverlay.Sphere(pos, self.BlastRadius, 1, Color(255, 0, 0, 0));
end

function BOMB:DetonateCallback(pos)
	-- Override.
end

function BOMB:Think()

	local pos      = self:GetPos();
	local detonate = CurTime() > self:GetSpawnTime() + self.LifeTime;
	if (SERVER && detonate) then

		-- Run the explosion routine of the bomb.
		if (!self.Detonated) then
			sound.Play(self.Sounds["explode"], pos, 75, 100, 1);
			self.Detonated = true;
		end

		-- Run detonation routine.
		self:DetonateCallback(pos);
		self:ApplyBlastDamage(pos);

		-- Render detonation effect.
		if (self.ExplosionEffect != nil) then ParticleEffect(self.ExplosionEffect, pos, self:GetAngles()); end

		-- Cleanup.
		if (CurTime() > self:GetSpawnTime() + self.ResidualTime) then self:Destroy(); end
	end

	-- Emit light upon detonation.
	if (CLIENT && detonate) then
		WGL.EmitLight(self, pos, self.BlastColor, self.BlastDecay, self.BlastSize, CurTime() + self.BlastDieTime, self.BlastStyle);
	end

	-- Maximum update loop frequency.
	self:NextThink(CurTime());
	return true;
end

function BOMB:Destroy()
	SafeRemoveEntity(self);
end