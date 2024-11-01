
function POWERSUIT:GetMuzzlePos()

	local muzzle    = self.MuzzleOffset;
	local owner     = self:GetOwner();
	local aimVector = owner:GetAimVector();
	local aimAngle  = aimVector:Angle();
	local up        = aimAngle:Up();
	local right     = aimAngle:Right();
	local forward   = aimAngle:Forward();
	local pos       = owner:GetShootPos() - (up * muzzle[3]) + (right * muzzle[2]) + (forward * muzzle[1]);

	return WGL.ToViewModelProjection(pos, 62, 75, false, owner, true), owner, aimVector;
end

function POWERSUIT:CanAttack()
	return !self:UndoVisor(IN_ATTACK) && self.ArmCannon:CanBeamChange() && self.MorphBall:CanMorph();
end

function POWERSUIT:CanQuickCharge(beamData)
	return math.Round(self:GetNextPrimaryFire() - self.ArmCannon:GetChargeStartTime(), 2) > beamData.BeamDelay + self.ArmCannon.Constants.Charge.Epsilon;
end

function POWERSUIT:Reload()

	local visorData = self:GetVisor();
	if (self:CanRequestComponent(false) && self.ArmCannon:CanBeamFidget() && !visorData.ShouldHideBeamMenu) then
		self.ArmCannon:SetNextBeamFidgetTime(CurTime());
		WGL.SendViewModelAnimation(self, self.FidgetAnimations[math.random(1, #self.FidgetAnimations)]);
	end
end

function POWERSUIT:MissileDeny()
	self:SetNextSecondaryFire(CurTime() + self.ArmCannon.Constants.Missile.Deny);
	if (self.ArmCannon:IsMissileReloading()) then WSL.PlaySound(self.Beams, "depleted"); end
end

function POWERSUIT:MissileReload()
	self.ArmCannon:SetNextMissileReloadTime(0);
	WGL.SendViewModelAnimation(self, ACT_VM_RELOAD);
	WSL.PlaySound(self.Beams, "reload");
end

function POWERSUIT:SetNextFire(primary, secondary)
	self:SetNextPrimaryFire(CurTime()   + (primary || 0));
	self:SetNextSecondaryFire(CurTime() + (secondary || 0));
end

function POWERSUIT:ShootProjectile(projectile, aimAssist, autoTarget, fullCharge)
	if (SERVER) then return ents.Create(projectile):Shoot(self:GetAimData(aimAssist, autoTarget), math.random(0, 360), nil, fullCharge); end
end

function POWERSUIT:NormalBeam()

	local beamData = self:GetBeam();
	self:ShootProjectile(beamData.Projectiles["normal"], beamData.AimAssist);

	-- Statemachines.
	self:SetNextFire(beamData.BeamDelay, self.ArmCannon.Constants.Charge.Delay);
	if (SERVER) then self.ArmCannon:StartBeam(); end

	-- Animations.
	self:GetOwner():SetAnimation(PLAYER_ATTACK1);
	WGL.SendViewModelAnimation(self, ACT_VM_PRIMARYATTACK);
	WSL.PlaySound(beamData, "fire_normal");
end

function POWERSUIT:StartChargeBeam(beamData)

	-- Statemachines.
	self.ArmCannon:StartChargeBeam(self:CanQuickCharge(beamData));

	-- Animations.
	WGL.SendViewModelAnimation(self, ACT_VM_PULLBACK);
	WSL.PlaySound(beamData, "charge");
end

function POWERSUIT:ChargeBeamThink()

	-- Statemachines.
	if (!self.ArmCannon:IsCharging()) then
		if (self.ArmCannon:IsMaxCharge()) then self.ArmCannon:SetMaxCharge(false); end
		return;
	end

	-- Raise event.
	hook.Run("MP.ChargeBeamThink", self);
	if (self.ArmCannon:GetChargeRatio() < 1 || self.ArmCannon:IsMaxCharge()) then return; end

	-- Animations.
	self.ArmCannon:SetMaxCharge(true);
	WGL.SendViewModelAnimation(self, ACT_VM_PULLBACK_LOW);
end

function POWERSUIT:ChargeBeam(beamData)

	local full = self:StopChargeBeam(beamData, true);
	self:ShootProjectile(beamData.Projectiles["charge"], beamData.AimAssist, nil, full);

	-- Statemachines.
	self:SetNextFire(beamData.ChargeDelay, beamData.ChargeDelay);

	-- Animations.
	self:GetOwner():SetAnimation(PLAYER_ATTACK1);
	WGL.SendViewModelAnimation(self, ACT_VM_RECOIL1);
	WSL.PlaySound(beamData, "fire_charge");
end

function POWERSUIT:StopChargeBeam(beamData, shoot)

	-- Statemachines.
	local started, full = self.ArmCannon:StopChargeBeam(shoot, beamData.ChargeViewPunch);
	if (started) then WGL.SendViewModelAnimation(self, ACT_VM_IDLE); end

	-- Animations.
	WSL.StopSound(beamData, "charge");
	return full;
end

function POWERSUIT:CloseBeam(beamData, silent, quickCharge)

	-- Statemachines.
	self:SetNextFire(beamData.MissileCloseDelay, beamData.MissileCloseDelay2);
	self.ArmCannon:StopBeam(silent, quickCharge, beamData.MissileCloseSound)

	-- Animations.
	if (silent) then return; end
	WGL.SendViewModelAnimation(self, ACT_VM_DETACH_SILENCER);
	WSL.PlaySound(self.Beams, "close_muzzle");
end

function POWERSUIT:Missile()

	self:ShootProjectile(self.MissileProjectile);

	-- Statemachines.
	self:SetNextFire(self.ArmCannon.Constants.Beam.Missile, self.ArmCannon.Constants.Missile.Close);
	self.ArmCannon:StartMissile();

	-- Animations.
	self:GetOwner():SetAnimation(PLAYER_ATTACK1);
	WGL.SendViewModelAnimation(self, ACT_VM_SECONDARYATTACK);
	WSL.PlaySound(self.Beams, "fire_missile");
end

function POWERSUIT:StartMissileCombo()

	local beamData = self:GetBeam();
	if (!beamData.ComboUnderWater && self.ArmCannon:Waterlogged()) then return; end
	if (!self.ArmCannon:CanMissileCombo(beamData.ComboCost))       then return; end

	-- Statemachines.
	self.ArmCannon:StartMissileCombo(CurTime());

	-- Animations.
	WSL.StopSound(beamData, "charge");
	WSL.PlaySound(self.Beams, "combo");
end

function POWERSUIT:MissileCombo(beamData)

	local autoTarget = beamData.ComboAutoTarget;
	local projectile = self:ShootProjectile(beamData.Projectiles["combo"], autoTarget, autoTarget);
	self:SetMissileCombo(projectile);

	-- Statemachines.
	self:StopChargeBeam(beamData);
	self.ArmCannon:StartMissileCombo(0, beamData.ComboCost, beamData.ComboReset, beamData.ComboViewPunch);

	-- Animations.
	self:GetOwner():SetAnimation(PLAYER_ATTACK1);
	WGL.SendViewModelAnimation(self, ACT_VM_RECOIL3);
	WSL.PlaySound(beamData, "fire_combo");
end

function POWERSUIT:MissileComboLoop(beamData)

	if (self.ArmCannon:GetMissileAmmo() <= 0) then return self:CloseMissileCombo(beamData); end

	-- Statemachines.
	self.ArmCannon:MissileComboDrain();
	if (self.ArmCannon:MissileComboLooping() || CurTime() <= self.ArmCannon:GetNextMissileComboResetTime() + beamData.ComboLoopDelay) then return; end
	self.ArmCannon:SetMissileComboLooping(true);

	-- Animations.
	WGL.SendViewModelAnimation(self, ACT_VM_PULLBACK_HIGH);
end

function POWERSUIT:CloseMissileCombo(beamData)

	-- Statemachines.
	self:SetNextFire(beamData.ComboDelay, beamData.ComboDelay);
	self.ArmCannon:StopMissileCombo();

	-- Animations.
	WGL.SendViewModelAnimation(self, ACT_VM_RECOIL2);
	if (beamData.ComboLoopDelay != nil) then
		local beamCombo = self:GetMissileCombo();
		if (IsValid(beamCombo)) then beamCombo:Destroy(true); end
		WSL.StopSound(beamData, "fire_combo");
	end
end

function POWERSUIT:BeamThink(beamData)
	if (self.ArmCannon:ShouldViewPunchReset()) then self.ArmCannon:SetViewPunch(0); end
	if (self.ArmCannon:StartBeamOpen())        then WSL.PlaySound(beamData, "open"); end
	if (self.ArmCannon:StartBeamClose())       then WSL.PlaySound(self.Beams, "close_missile"); end
	if (self.ArmCannon:StartBeamOpenAnim())    then WGL.SendViewModelAnimation(self, ACT_VM_IDLE_LOWERED); end
end

function POWERSUIT:MuzzleCallback(networkVar, effectKey)

	self.MuzzleEffects = self.MuzzleEffects || {};
	self:NetworkVarNotify(networkVar, function(ent, name, old, new)

		if (!IsValid(ent)) then return; end

		local owner = ent:GetOwner();
		if (!IsValid(owner) || owner != LocalPlayer()) then return; end

		local viewModel = owner:GetViewModel();
		if (!IsValid(viewModel)) then return; end

		local beamData = ent:GetBeam();
		if (beamData && new > 0 && beamData[effectKey] && !IsValid(ent.MuzzleEffects[effectKey])) then
			ent.MuzzleEffects[effectKey] = CreateParticleSystem(viewModel, beamData[effectKey], PATTACH_POINT_FOLLOW, 1);
		end

		if (new <= 0 && IsValid(ent.MuzzleEffects[effectKey])) then
			ent.MuzzleEffects[effectKey]:StopEmissionAndDestroyImmediately();
			ent.MuzzleEffects[effectKey] = nil;
		end
	end);
end