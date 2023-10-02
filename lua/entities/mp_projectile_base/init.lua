
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

function PROJECTILE:Use(activator, caller)
	return false;
end

function PROJECTILE:OnTakeDamage(damageInfo)
	return false;
end

function PROJECTILE:CanDamage(owner, entity)
	return entity != owner && IsValid(entity) && entity:IsSolid() && entity:GetOwner() != owner;
end

function PROJECTILE:PredictCollisions()

	-- Do nothing if we collided and wait for cleanup.
	if (self.OscillatorParent) then return; end

	-- Begin collision prediction for custom projectile.
	local collision = WGL.TraceCollision(self, false, self.CollisionFilter, self.HitScanPos, self.Mask);
	if (self.HitScanPos) then
		self:SetCollisionRan(true);
		self:SetCollisionPos(collision.HitPos);
		self:SetCollisionNormal(collision.HitNormal);
	end

	-- Collision occured, call to collision handler. Worldspawn does not have a IsValid function, must check manually for validity.
	if (collision.Hit && collision.Entity != nil && collision.Entity != NULL && collision.Entity:IsSolid()) then
		self:OnCollide(collision.HitPos, collision.HitNormal, collision.Entity, collision.Entity:GetPhysicsObject());
		return self.RemoveOnCollide;
	end

	return false;
end

function PROJECTILE:ApplyDamage(entity, damage)

	-- If owner turns invalid, let the projectile be the attacker.
	local owner = self:GetOwner();
	if (!IsValid(owner)) then owner = self; end
	if (!self:CanDamage(owner, entity)) then return false, owner; end

	-- Projectiles that are not removed on collide use hitscan damage at 60fps.
	local damageInfo = DamageInfo();
	damageInfo:SetDamage(self.RemoveOnCollide && damage || damage * (FrameTime() / (1 / 60)));
	damageInfo:SetAttacker(owner);
	damageInfo:SetInflictor(self);
	damageInfo:SetDamageCustom(self.DamageType);
	entity:TakeDamageInfo(damageInfo);
	if (GetConVar("developer"):GetInt() > 1) then print(damageInfo); end

	return true, owner;
end

function PROJECTILE:ApplyBlastDamage(entity, pos, normal)

	for k,v in pairs(ents.FindInSphere(pos, self:GetBlastRadius())) do

		-- Don't apply blast damage on direct hit.
		if (v == entity) then continue; end

		-- Apply blast damage.
		if (!self:ApplyDamage(v, self:GetBlastDamage())) then continue; end

		-- Apply blast knockback.
		local vPhys = v:GetPhysicsObject();
		if (IsValid(vPhys)) then vPhys:ApplyForceCenter((v:GetPos() - pos + normal):GetNormalized() * self:GetBlastKnockBack()); end
	end

	debugoverlay.Sphere(pos, self:GetBlastRadius(), 1, Color(255, 0, 0, 0));
end

function PROJECTILE:DirectDamageCallback(owner, entity)
	-- Override.
end

function PROJECTILE:OnCollideCallback(pos, normal, angle, entity, phys)
	-- Override.
end

function PROJECTILE:OnCollide(pos, normal, entity, phys)

	-- Raise collision flags.
	self:SetCollisionRan(true);
	self:SetCollisionPos(pos);
	self:SetCollisionNormal(normal);
	if (!self.Oscillator) then
		self:SetPos(pos);
		self:GetPhysicsObject():SetVelocityInstantaneous(Vector(0, 0, 0));
	end

	-- Apply knockback force to entity.
	if (IsValid(phys)) then phys:ApplyForceCenter(-normal * self:GetKnockBack()); end

	-- Apply projectile damage to entity.
	local directDamage, owner = self:ApplyDamage(entity, self:GetDamage());
	if (directDamage)     then self:DirectDamageCallback(owner, entity); end
	if (self.BlastDamage) then self:ApplyBlastDamage(entity, pos, normal); end

	-- Compute impact angle relative to absolute up for impact angle in PCF space.
	local impactCross = normal:Angle():Forward():Cross(Vector(0, 0, -1));
	local impactAngle = impactCross:AngleEx(normal);

	-- Render impact effects.
	if (self.ImpactEffect != nil)    then ParticleEffect(self.ImpactEffect, pos, impactAngle); end
	if (self.DecalEffect != nil)     then util.Decal(self.DecalEffect,     pos, pos - normal * 50, self); end
	if (self.DecalGlowEffect != nil) then util.Decal(self.DecalGlowEffect, pos, pos - normal * 50, self); end
	if (self.DecalBurnEffect != nil) then util.Decal(self.DecalBurnEffect, pos, pos - normal * 50, self); end

	-- Call to collision delegate and begin cleanup.
	if (self.Sounds["impact"] != nil) then sound.Play(self.Sounds["impact"], pos, 75, 100, 1); end
	self:OnCollideCallback(pos, normal, impactAngle, entity, phys);
	self:Destroy();
end

function PROJECTILE:ApplyRotation(phys)

	-- Apply roll animation to projectile.
	self.LastAngles:RotateAroundAxis(self.LastAngles:Forward(), self.RotationRate * FrameTime());
	phys:SetAngles(self.LastAngles);
end

function PROJECTILE:GetHomingAngle(pos, target, targetPos, targetDirection)
	local distance       = targetDirection:Length();
	local targetVelocity = target:GetVelocity() / distance;
	local time           = distance / self.Speed;
	return (targetPos + targetVelocity * time - pos):Angle();
end

function PROJECTILE:Home(phys)

	-- Do nothing if the target is invalidated.
	local target = self.HomingTarget;
	if (!IsValid(target)) then return; end

	-- Stop homing if we have gone past the target.
	local pos             = self:GetPos();
	local direction       = phys:GetVelocity():GetNormalized();
	local targetPos       = target:GetLockOnPosition();
	local targetDirection = targetPos - pos;
	if (direction:Dot(targetDirection:GetNormalized()) < 0) then
		self.Homing = false;
		return;
	end

	-- Point projectile towards target and apply lag.
	local homingAngle = LerpAngle(self.HomingLag * FrameTime(), self.LastAngles, self:GetHomingAngle(pos, target, targetPos, targetDirection));
	self:SetAngles(homingAngle);
	self.LastAngles = homingAngle;
end

function PROJECTILE:PhysicsUpdate(phys)

	if (!self.SpawnTime || !self.RemoveOnCollide || self:GetCollided()) then return; end

	self.LastAngles = self.LastAngles || self:GetAngles();
	if (self.RotationRate) then self:ApplyRotation(phys); end
	if (self.Homing)       then self:Home(phys); end
	if (self.Oscillator)   then return; end

	phys:SetVelocityInstantaneous(self:GetForward() * (self.Speed + (self.InitialVelocity || 0)));
	if (phys:GetAngleVelocity():LengthSqr() != 0) then self:Destroy(true); end
end