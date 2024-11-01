
POWERSUIT.ArmCannon = {};

function POWERSUIT.ArmCannon:SetupDataTables(weapon)

	self.Constants = {

		Beam = {
			Initial     = 1,
			Waterlog    = 2,
			Change      = 1.0,
			ChangeAnim  = 0.8,
			Request     = 1.0,
			Missile     = 0.15
		},

		Beam1 = {
			Limit       = 250
		},

		Beam2 = {
			Limit       = 250
		},

		Beam3 = {
			Limit       = 250
		},

		Beam4 = {
			Limit       = 250
		},

		Charge = {
			Delay       = 0.2,
			Epsilon     = 0.1,
			Weak        = 0.7,
			Full        = 1.4,
			Open        = 0.075,
		},

		Missile = {
			Limit       = 250,
			Delay       = 1.2,
			Reload      = 0.7,
			Busy        = 0.5,
			Deny        = 0.16,
			Auto        = 7.0,
			Open        = 0.75,
			Close       = 0.4
		},

		Combo = {
			Delay       = 0.5,
			Drain       = 0.2
		},

		Fidget = {
			Delay       = 2.0
		},

		ViewPunch = {
			Reset       = 0.08
		}
	};

	self.State = {

		Beam = {
			Initial     = 1
		},

		Beam1 = {
			Ammo        = 0,
			MaxAmmo     = 0,
			Enable      = true,
			ComboEnable = false
		},

		Beam2 = {
			Ammo        = 0,
			MaxAmmo     = 0,
			Enable      = false,
			ComboEnable = false
		},

		Beam3 = {
			Ammo        = 0,
			MaxAmmo     = 0,
			Enable      = false,
			ComboEnable = false
		},

		Beam4 = {
			Ammo        = 0,
			MaxAmmo     = 0,
			Enable      = false,
			ComboEnable = false
		},

		Charge = {
			Enable      = false
		},

		Missile = {
			Ammo        = 0,
			MaxAmmo     = 0
		}
	};

	weapon:NetworkVar("Bool",   0, "LoadSaveFile",      { KeyName = "loadfile",   Edit = { order =  1, category = "Save File", type = "Boolean" } });
	weapon:NetworkVar("Bool",   1, "Beam1Enabled",      { KeyName = "beam1",      Edit = { order = 17, category = "Weapons",   type = "Boolean" } });
	weapon:NetworkVar("Bool",   2, "Beam2Enabled",      { KeyName = "beam2",      Edit = { order = 18, category = "Weapons",   type = "Boolean" } });
	weapon:NetworkVar("Bool",   3, "Beam3Enabled",      { KeyName = "beam3",      Edit = { order = 19, category = "Weapons",   type = "Boolean" } });
	weapon:NetworkVar("Bool",   4, "Beam4Enabled",      { KeyName = "beam4",      Edit = { order = 20, category = "Weapons",   type = "Boolean" } });
	weapon:NetworkVar("Bool",   5, "Beam1ComboEnabled", { KeyName = "beamcombo1", Edit = { order = 21, category = "Combos",    type = "Boolean" } });
	weapon:NetworkVar("Bool",   6, "Beam2ComboEnabled", { KeyName = "beamcombo2", Edit = { order = 22, category = "Combos",    type = "Boolean" } });
	weapon:NetworkVar("Bool",   7, "Beam3ComboEnabled", { KeyName = "beamcombo3", Edit = { order = 23, category = "Combos",    type = "Boolean" } });
	weapon:NetworkVar("Bool",   8, "Beam4ComboEnabled", { KeyName = "beamcombo4", Edit = { order = 24, category = "Combos",    type = "Boolean" } });
	weapon:NetworkVar("Bool",   9, "ChargeBeamEnabled", { KeyName = "chargebeam", Edit = { order = 16, category = "Weapons",   type = "Boolean" } });

	weapon:NetworkVar("Int",    0, "BeamType");
	weapon:NetworkVar("Int",    1, "BeamRoll");
	weapon:NetworkVar("Bool",  10, "BeamBusy");
	weapon:NetworkVar("Float",  0, "NextBeamChange");

	weapon:NetworkVar("Float",  1, "NextBeamMuzzle");
	weapon:NetworkVar("Float",  2, "NextChargeMuzzle");
	weapon:NetworkVar("Float",  3, "NextComboMuzzle");
	weapon:NetworkVar("Float",  4, "NextComboLoopMuzzle");
	weapon:NetworkVar("Float",  5, "NextBeamOpen");
	weapon:NetworkVar("Float",  6, "NextBeamOpenAnim");
	weapon:NetworkVar("Float",  7, "NextBeamClose");
	weapon:NetworkVar("Float",  8, "NextBeamFidget");

	weapon:NetworkVar("Float",  9, "ChargeStart");
	weapon:NetworkVar("Bool",  11, "ChargeStarted");
	weapon:NetworkVar("Float", 10, "ChargeTime");
	weapon:NetworkVar("Bool",  12, "ChargeMax");
	weapon:NetworkVar("Float", 11, "ChargeViewPunch");
	weapon:NetworkVar("Float", 12, "NextViewPunch");

	weapon:NetworkVar("Float", 13, "NextMissile");
	weapon:NetworkVar("Float", 14, "NextMissileReload");

	weapon:NetworkVar("Entity", 0, "MissileCombo");
	weapon:NetworkVar("Bool",  13, "MissileComboBusy");
	weapon:NetworkVar("Bool",  14, "MissileComboLoop");
	weapon:NetworkVar("Float", 15, "NextMissileCombo");
	weapon:NetworkVar("Float", 16, "NextMissileComboReset");
	weapon:NetworkVar("Float", 17, "NextMissileComboDrain");

	weapon:NetworkVar("Int",    2, "Beam1Ammo");
	weapon:NetworkVar("Int",    3, "Beam1MaxAmmo");
	weapon:NetworkVar("Int",    4, "Beam2Ammo");
	weapon:NetworkVar("Int",    5, "Beam2MaxAmmo");
	weapon:NetworkVar("Int",    6, "Beam3Ammo");
	weapon:NetworkVar("Int",    7, "Beam3MaxAmmo");
	weapon:NetworkVar("Int",    8, "Beam4Ammo");
	weapon:NetworkVar("Int",    9, "Beam4MaxAmmo");
	weapon:NetworkVar("Int",   10, "MissileAmmo",    { KeyName = "missiles",    Edit = { order = 15, category = "Weapons", type = "Int", min = 0, max = 250 } });
	weapon:NetworkVar("Int",   11, "MissileMaxAmmo", { KeyName = "maxmissiles", Edit = { order = 14, category = "Weapons", type = "Int", min = 0, max = 250 } });

	self.Weapon = weapon;
	if (SERVER) then self:LoadState(); end
end

function POWERSUIT.ArmCannon:SaveState()

	-- Update local state cache with current network information.
	local weapon = self.Weapon;
	self.State.Beam.Initial      = weapon:GetBeamType();
	self.State.Beam1.MaxAmmo     = weapon:GetBeam1MaxAmmo();
	self.State.Beam1.Ammo        = weapon:GetBeam1Ammo();
	self.State.Beam1.Enable      = weapon:GetBeam1Enabled();
	self.State.Beam1.ComboEnable = weapon:GetBeam1ComboEnabled();
	self.State.Beam2.MaxAmmo     = weapon:GetBeam2MaxAmmo();
	self.State.Beam2.Ammo        = weapon:GetBeam2Ammo();
	self.State.Beam2.Enable      = weapon:GetBeam2Enabled();
	self.State.Beam2.ComboEnable = weapon:GetBeam2ComboEnabled();
	self.State.Beam3.MaxAmmo     = weapon:GetBeam3MaxAmmo();
	self.State.Beam3.Ammo        = weapon:GetBeam3Ammo();
	self.State.Beam3.Enable      = weapon:GetBeam3Enabled();
	self.State.Beam3.ComboEnable = weapon:GetBeam3ComboEnabled();
	self.State.Beam4.MaxAmmo     = weapon:GetBeam4MaxAmmo();
	self.State.Beam4.Ammo        = weapon:GetBeam4Ammo();
	self.State.Beam4.Enable      = weapon:GetBeam4Enabled();
	self.State.Beam4.ComboEnable = weapon:GetBeam4ComboEnabled();
	self.State.Charge.Enable     = weapon:GetChargeBeamEnabled();
	self.State.Missile.MaxAmmo   = weapon:GetMissileMaxAmmo();
	self.State.Missile.Ammo      = weapon:GetMissileAmmo();

	return self.State;
end

function POWERSUIT.ArmCannon:LoadState(state)

	-- Assign state to current instance.
	if (state) then self.State = state; end

	-- Initialize base variables.
	local weapon = self.Weapon;
	weapon:SetLoadSaveFile(true);
	weapon:SetBeamType(self.Constants.Beam.Initial);
	weapon:SetBeam1MaxAmmo(self.State.Beam1.MaxAmmo);
	weapon:SetBeam2MaxAmmo(self.State.Beam2.MaxAmmo);
	weapon:SetBeam3MaxAmmo(self.State.Beam3.MaxAmmo);
	weapon:SetBeam4MaxAmmo(self.State.Beam4.MaxAmmo);
	weapon:SetBeam1Ammo(self.State.Beam1.Ammo);
	weapon:SetBeam2Ammo(self.State.Beam2.Ammo);
	weapon:SetBeam3Ammo(self.State.Beam3.Ammo);
	weapon:SetBeam4Ammo(self.State.Beam4.Ammo);
	weapon:SetBeam1Enabled(self.State.Beam1.Enable);
	weapon:SetBeam2Enabled(self.State.Beam2.Enable);
	weapon:SetBeam3Enabled(self.State.Beam3.Enable);
	weapon:SetBeam4Enabled(self.State.Beam4.Enable);
	weapon:SetBeam1ComboEnabled(self.State.Beam1.ComboEnable);
	weapon:SetBeam2ComboEnabled(self.State.Beam2.ComboEnable);
	weapon:SetBeam3ComboEnabled(self.State.Beam3.ComboEnable);
	weapon:SetBeam4ComboEnabled(self.State.Beam4.ComboEnable);
	weapon:SetChargeBeamEnabled(self.State.Charge.Enable);
	weapon:SetMissileMaxAmmo(self.State.Missile.MaxAmmo);
	weapon:SetMissileAmmo(self.State.Missile.Ammo);
end

function POWERSUIT.ArmCannon:GetBeam()
	return self.Weapon:GetBeamType();
end

function POWERSUIT.ArmCannon:SetBeam(beam)
	self.Weapon:SetBeamType(beam);
end

function POWERSUIT.ArmCannon:IsBeamEnabled(index)
	return self.Weapon["GetBeam" .. index .. "Enabled"](self.Weapon);
end

function POWERSUIT.ArmCannon:EnableBeam(index, enable)
	self.Weapon["SetBeam" .. index .. "Enabled"](self.Weapon, enable);
end

function POWERSUIT.ArmCannon:IsChargeBeamEnabled()
	return self.Weapon:GetChargeBeamEnabled();
end

function POWERSUIT.ArmCannon:EnableChargeBeam(enable)
	self.Weapon:SetChargeBeamEnabled(enable);
end

function POWERSUIT.ArmCannon:IsMissileComboEnabled(index)
	return self.Weapon["GetBeam" .. index .. "ComboEnabled"](self.Weapon);
end

function POWERSUIT.ArmCannon:EnableMissileCombo(index, enable)
	self.Weapon["SetBeam" .. index .. "ComboEnabled"](self.Weapon, enable);
end

function POWERSUIT.ArmCannon:Waterlogged()
	return self.Weapon:GetOwner():WaterLevel() >= self.Constants.Beam.Waterlog;
end

--
-- Beam Animations
--

function POWERSUIT.ArmCannon:GetBeamRoll()
	return self.Weapon:GetBeamRoll();
end

function POWERSUIT.ArmCannon:SetBeamRoll(roll)
	if (util.SharedRandom("beamroll", 0, 7) > 4) then self.Weapon:SetBeamRoll(roll); end
end

function POWERSUIT.ArmCannon:GetNextBeamFidgetTime()
	return self.Weapon:GetNextBeamFidget();
end

function POWERSUIT.ArmCannon:GetNextBeamFidgetTimeElapsed()
	return CurTime() - self:GetNextBeamFidgetTime();
end

function POWERSUIT.ArmCannon:SetNextBeamFidgetTime(time)
	self.Weapon:SetNextBeamFidget(time);
end

function POWERSUIT.ArmCannon:CanBeamFidget()
	return self:GetNextBeamFidgetTimeElapsed() > self.Constants.Fidget.Delay;
end

function POWERSUIT.ArmCannon:GetViewPunch()
	return self.Weapon:GetChargeViewPunch();
end

function POWERSUIT.ArmCannon:SetViewPunch(punch)
	self.Weapon:SetChargeViewPunch(punch);
end

function POWERSUIT.ArmCannon:ViewPunch(punch)
	self.Weapon:SetNextViewPunch(CurTime() + self.Constants.ViewPunch.Reset);
	self:SetViewPunch(punch);
end

function POWERSUIT.ArmCannon:ShouldViewPunchReset()
	return self:GetViewPunch() != 0 && CurTime() > self.Weapon:GetNextViewPunch();
end

--
-- Beam Muzzles
-- 

function POWERSUIT.ArmCannon:SetNextBeamMuzzleTime(time)
	self.Weapon:SetNextBeamMuzzle(time);
end

function POWERSUIT.ArmCannon:SetNextChargeMuzzleTime(time)
	self.Weapon:SetNextChargeMuzzle(time);
end

function POWERSUIT.ArmCannon:SetNextComboMuzzleTime(time)
	self.Weapon:SetNextComboMuzzle(time);
end

function POWERSUIT.ArmCannon:SetNextComboLoopMuzzleTime(time)
	self.Weapon:SetNextComboLoopMuzzle(time);
end

--
-- Beam Busy States
-- 

function POWERSUIT.ArmCannon:IsBeamOpen()
	return self:IsBeamBusy() || self:IsMissileBusy();
end

function POWERSUIT.ArmCannon:IsBusy(ignoreOpenState)
	return self:IsCharging() || (!ignoreOpenState && self:IsBeamOpen()) || self:IsMissileComboBusy() || !self:CanBeamChange();
end

function POWERSUIT.ArmCannon:IsBeamBusy()
	return self.Weapon:GetBeamBusy();
end

function POWERSUIT.ArmCannon:SetBeamBusy(busy)
	self.Weapon:SetBeamBusy(busy);
end

function POWERSUIT.ArmCannon:IsMissileBusy()
	return !self:IsMissileComboBusy()
		&& CurTime() < self:GetNextMissileTime();
end

function POWERSUIT.ArmCannon:IsMissileComboBusy()
	return self.Weapon:GetMissileComboBusy();
end

function POWERSUIT.ArmCannon:SetMissileComboBusy(busy)
	if (!busy) then self:SetNextMissileComboResetTime(0); end
	self.Weapon:SetMissileComboBusy(busy);
end

--
-- Beam Change
--

function POWERSUIT.ArmCannon:GetNextBeamChangeTime()
	return self.Weapon:GetNextBeamChange();
end

function POWERSUIT.ArmCannon:GetNextBeamChangeTimeElapsed()
	return CurTime() - self:GetNextBeamChangeTime();
end

function POWERSUIT.ArmCannon:SetNextBeamChangeTime(time)
	self.Weapon:SetNextBeamChange(time);
end

function POWERSUIT.ArmCannon:CanBeamChange()
	return !self:IsMissileComboBusy()
		&& self:GetNextBeamChangeTimeElapsed() > self.Constants.Beam.Change;
end

function POWERSUIT.ArmCannon:CanBeamChangeAnim()
	return !self:IsMissileComboBusy()
		&& self:GetNextBeamChangeTimeElapsed() > self.Constants.Beam.ChangeAnim;
end

--
-- Beam Open State
--

function POWERSUIT.ArmCannon:GetNextBeamOpenTime()
	return self.Weapon:GetNextBeamOpen();
end

function POWERSUIT.ArmCannon:GetNextBeamOpenAnimTime()
	return self.Weapon:GetNextBeamOpenAnim();
end

function POWERSUIT.ArmCannon:SetNextBeamOpenTime(time)
	self.Weapon:SetNextBeamOpen(time);
end

function POWERSUIT.ArmCannon:SetNextBeamOpenAnimTime(time)
	self.Weapon:SetNextBeamOpenAnim(time);
end

function POWERSUIT.ArmCannon:GetNextBeamCloseTime()
	return self.Weapon:GetNextBeamClose();
end

function POWERSUIT.ArmCannon:SetNextBeamCloseTime(time)
	self.Weapon:SetNextBeamClose(time);
end

--
-- Charge Beam
-- 

function POWERSUIT.ArmCannon:IsMaxCharge()
	return self.Weapon:GetChargeMax();
end

function POWERSUIT.ArmCannon:SetMaxCharge(max)
	self.Weapon:SetChargeMax(max);
end

function POWERSUIT.ArmCannon:GetChargeStartTime()
	return self.Weapon:GetChargeStart();
end

function POWERSUIT.ArmCannon:GetChargeStartTimeElapsed()
	return CurTime() - self:GetChargeStartTime();
end

function POWERSUIT.ArmCannon:ChargingStarted()
	return self:GetChargeStartTime() > 0;
end

function POWERSUIT.ArmCannon:SetNextChargeStartTime(time)
	self.Weapon:SetChargeStart(time);
end

function POWERSUIT.ArmCannon:ChargeStarted()
	return self.Weapon:GetChargeStarted();
end

function POWERSUIT.ArmCannon:SetChargeStarted(started)
	return self.Weapon:SetChargeStarted(started);
end

function POWERSUIT.ArmCannon:GetChargeTime()
	return self.Weapon:GetChargeTime();
end

function POWERSUIT.ArmCannon:GetChargeTimeElapsed()
	return CurTime() - self:GetChargeTime();
end

function POWERSUIT.ArmCannon:IsCharging()
	return self:GetChargeTime() > 0;
end

function POWERSUIT.ArmCannon:SetChargeTime(time)
	self.Weapon:SetChargeTime(time);
end

function POWERSUIT.ArmCannon:ShouldChargeBeamStart()

	return self:IsChargeBeamEnabled()
		&& !self:IsCharging()
		&& self:ChargingStarted()
		&& self:GetChargeStartTimeElapsed() > self.Constants.Charge.Delay;
end

function POWERSUIT.ArmCannon:GetChargeRatio()
	if (!self:ChargeStarted()) then return 0; end
	return WGL.Clamp(self:GetChargeTimeElapsed() / self.Constants.Charge.Full);
end

function POWERSUIT.ArmCannon:ChargingFull()
	if (self:GetChargeTime() == 0) then return false; end
	return self:GetChargeTimeElapsed() >= self.Constants.Charge.Full;
end

function POWERSUIT.ArmCannon:ShouldChargeBeamFire(input)
	return self:IsCharging()
		&& self:GetChargeTimeElapsed() >= self.Constants.Charge.Weak
		&& !self.Weapon:GetOwner():KeyDown(input);
end

function POWERSUIT.ArmCannon:ShouldChargeBeamStop(input)
	return !self.Weapon:GetOwner():KeyDown(input) && self:ChargingStarted();
end

function POWERSUIT.ArmCannon:StopCharging()
	self:SetNextChargeStartTime(0);
	self:SetChargeTime(0);
end

--
-- Missiles
-- 

function POWERSUIT.ArmCannon:GetMissileAmmo()
	return self.Weapon:GetMissileAmmo();
end

function POWERSUIT.ArmCannon:GetMissileMaxAmmo()
	return self.Weapon:GetMissileMaxAmmo();
end

function POWERSUIT.ArmCannon:UseMissileAmmo(amount)

	local current = self:GetMissileAmmo();
	if (current < amount) then return false; end

	self.Weapon:SetMissileAmmo(current - amount);
	return true;
end

function POWERSUIT.ArmCannon:CanMissileFire()
	return self:GetNextMissileTimeElapsed() > self.Constants.Missile.Delay
		&& self:GetMissileAmmo() > 0;
end

function POWERSUIT.ArmCannon:GetNextMissileTime()
	return self.Weapon:GetNextMissile();
end

function POWERSUIT.ArmCannon:GetNextMissileTimeElapsed()
	return CurTime() - self:GetNextMissileTime();
end

function POWERSUIT.ArmCannon:SetNextMissileTime(time)
	self.Weapon:SetNextMissile(time);
end

function POWERSUIT.ArmCannon:GetNextMissileReloadTime()
	return self.Weapon:GetNextMissileReload();
end

function POWERSUIT.ArmCannon:SetNextMissileReloadTime(time)
	self.Weapon:SetNextMissileReload(time);
end

function POWERSUIT.ArmCannon:ShouldMissileReload()
	local nextReload = self:GetNextMissileReloadTime();
	return nextReload > 0
		&& CurTime() - nextReload >= self.Constants.Missile.Reload;
end

function POWERSUIT.ArmCannon:IsMissileReloading()
	return self.Weapon:GetMissileMaxAmmo() > 0 && CurTime() > self:GetNextMissileTime() - self.Constants.Missile.Busy;
end

function POWERSUIT.ArmCannon:ShouldMissileReset()
	return self:IsBeamBusy()
		&& CurTime() > self:GetNextMissileTime() + self.Constants.Missile.Auto;
end

--
-- Beam Combo
-- 

function POWERSUIT.ArmCannon:GetNextMissileComboTime()
	return self.Weapon:GetNextMissileCombo();
end

function POWERSUIT.ArmCannon:GetNextMissileComboTimeElapsed()
	return CurTime() - self:GetNextMissileComboTime();
end

function POWERSUIT.ArmCannon:SetNextMissileComboDrainTime(time)
	self.Weapon:SetNextMissileComboDrain(time);
end

function POWERSUIT.ArmCannon:GetNextMissileComboDrainTime()
	return self.Weapon:GetNextMissileComboDrain();
end

function POWERSUIT.ArmCannon:GetNextMissileComboDrainTimeElapsed()
	return CurTime() - self:GetNextMissileComboDrainTime();
end

function POWERSUIT.ArmCannon:GetNextMissileComboResetTime()
	return self.Weapon:GetNextMissileComboReset();
end

function POWERSUIT.ArmCannon:SetNextMissileComboResetTime(time)
	if (time > 0) then self:SetNextMissileComboDrainTime(CurTime()); end
	self.Weapon:SetNextMissileComboReset(time);
end

function POWERSUIT.ArmCannon:CanMissileCombo(cost)
	return self:IsMissileComboEnabled(self:GetBeam())
		&& self:IsCharging()
		&& self:ChargingFull()
		&& self:GetMissileAmmo() >= cost;
end

function POWERSUIT.ArmCannon:GetMissileComboStartRatio()
	return self:GetNextMissileComboTimeElapsed() / self.Constants.Combo.Delay;
end

function POWERSUIT.ArmCannon:ShouldMissileCombo()
	return self:IsMissileComboBusy()
		&& self:GetNextMissileComboTime() > 0
		&& self:GetNextMissileComboTimeElapsed() >= self.Constants.Combo.Delay;
end

function POWERSUIT.ArmCannon:ShouldMissileComboDrain(continuous)
	return continuous && self:IsMissileComboDraining()
end

function POWERSUIT.ArmCannon:MissileComboDrain(continuous)
	self:SetNextMissileComboDrainTime(CurTime());
	self:UseMissileAmmo(1);
end

function POWERSUIT.ArmCannon:IsMissileComboDraining()
	return self:IsMissileComboBusy()
		&& self:GetNextMissileComboTimeElapsed() > self.Constants.Combo.Delay
		&& self:GetNextMissileComboDrainTimeElapsed() > self.Constants.Combo.Drain;
end

function POWERSUIT.ArmCannon:ShouldMissileComboReset(input, loop, water)
	return self:GetNextMissileComboResetTime() > 0
		&& CurTime() > self:GetNextMissileComboResetTime()
		&& ((!loop || !self.Weapon:GetOwner():KeyDown(input)) || (!water && self:Waterlogged()) || !IsValid(self.Weapon:GetMissileCombo()));
end

function POWERSUIT.ArmCannon:MissileComboLooping()
	return self.Weapon:GetMissileComboLoop();
end

function POWERSUIT.ArmCannon:SetMissileComboLooping(loop)
	self.Weapon:SetMissileComboLoop(loop);
end

--
-- Beam Ammo
--

function POWERSUIT.ArmCannon:GetAmmo(type)
	return self.Weapon["Get" .. type .. "Ammo"](self.Weapon);
end

function POWERSUIT.ArmCannon:AddAmmo(type, amount)
	local ammo = self:GetAmmo(type);
	return self:SetAmmo(type, ammo + amount);
end

function POWERSUIT.ArmCannon:SetAmmo(type, amount)
	local max = self:GetMaxAmmo(type);
	local ammo = math.Clamp(amount, 0, max);
	self.Weapon["Set" .. type .. "Ammo"](self.Weapon, ammo);
	return ammo;
end

function POWERSUIT.ArmCannon:GetMaxAmmo(type)
	return self.Weapon["Get" .. type .. "MaxAmmo"](self.Weapon);
end

function POWERSUIT.ArmCannon:AddMaxAmmo(type, amount)
	local ammo = self:GetMaxAmmo(type);
	return self:SetMaxAmmo(type, ammo + amount);
end

function POWERSUIT.ArmCannon:SetMaxAmmo(type, amount)
	local limit = self.Constants[type]["Limit"];
	local maxAmmo = math.Clamp(amount, 0, limit);
	self.Weapon["Set" .. type .. "MaxAmmo"](self.Weapon, maxAmmo);
	local current = self:GetAmmo(type);
	local ammo = math.Clamp(current, current, maxAmmo);
	self.Weapon["Set" .. type .. "Ammo"](self.Weapon, ammo);
	return ammo, maxAmmo;
end

--
-- Events
--

function POWERSUIT.ArmCannon:Reset()
	self.Weapon:SetNextBeamOpen(0);
	self.Weapon:SetNextBeamOpenAnim(0);
	self.Weapon:SetNextBeamClose(0);
end

function POWERSUIT.ArmCannon:StartBeamChange(beam)
	self:SetNextBeamOpenTime(0);
	self:SetNextBeamCloseTime(0);
	self:SetNextBeamChangeTime(CurTime());
	return self:IsBeamEnabled(beam), self:IsBeamOpen();
end

function POWERSUIT.ArmCannon:StartBeamOpen()

	local shouldStart = self:GetNextBeamOpenTime() != 0 && CurTime() > self:GetNextBeamOpenTime();
	if (shouldStart) then self:SetNextBeamOpenTime(0); end
	return shouldStart;
end

function POWERSUIT.ArmCannon:StartBeamOpenAnim()

	local shouldStart = self:GetNextBeamOpenAnimTime() != 0 && CurTime() > self:GetNextBeamOpenAnimTime();
	if (shouldStart) then self:SetNextBeamOpenAnimTime(0); end
	return shouldStart;
end

function POWERSUIT.ArmCannon:StartBeamClose()

	local shouldStart = self:GetNextBeamCloseTime() != 0 && CurTime() > self:GetNextBeamCloseTime();
	if (shouldStart) then self:SetNextBeamCloseTime(0); end
	return shouldStart;
end

function POWERSUIT.ArmCannon:StartBeam()
	self:SetNextBeamMuzzleTime(CurTime());
	self:SetNextChargeStartTime(CurTime());
	self:SetBeamRoll(util.SharedRandom("beamroll", -12.5, 12.5));
end

function POWERSUIT.ArmCannon:StopBeam(silent, quickCharge, close)

	self:SetNextChargeStartTime(!quickCharge && 0 || CurTime());
	self:SetNextMissileReloadTime(0);
	self:SetNextMissileTime(0);
	self:SetBeamBusy(false);

	if (silent) then return; end
	self:SetNextBeamOpenTime(CurTime() + self.Constants.Missile.Open);
	if (close) then self:SetNextBeamCloseTime(CurTime() + self.Constants.Missile.Close); end
end

function POWERSUIT.ArmCannon:StartChargeBeam(quickCharge)

	self:SetChargeTime(CurTime());
	self:SetChargeStarted(true);

	if (!quickCharge) then return; end
	self:SetNextBeamOpenTime(CurTime() + self.Constants.Charge.Open);
	self:SetNextBeamCloseTime(0);
end

function POWERSUIT.ArmCannon:StopChargeBeam(shoot, punch)

	local full    = self:ChargingFull();
	local started = self:ChargeStarted();
	if (started) then self:SetChargeStarted(false); end
	self:StopCharging();

	if (shoot) then
		self:SetNextBeamMuzzleTime(CurTime());
		self:SetNextChargeMuzzleTime(CurTime());
		self:ViewPunch(punch);
	end

	return started, full;
end

function POWERSUIT.ArmCannon:StartMissile()
	self:UseMissileAmmo(1);
	self:SetBeamBusy(true);
	self:SetNextMissileTime(CurTime());
	self:SetNextMissileReloadTime(CurTime());
end

function POWERSUIT.ArmCannon:StartMissileCombo(time, cost, reset, punch)

	if (time > 0) then
		self:SetNextComboMuzzleTime(CurTime());
		self:SetMissileComboBusy(true);
		self:SetChargeStarted(false);
		self:StopCharging();
	else
		self:UseMissileAmmo(cost);
		self:SetNextChargeMuzzleTime(CurTime());
		self:SetNextComboLoopMuzzleTime(CurTime());
		self:SetNextMissileComboResetTime(CurTime() + reset);
		self:ViewPunch(punch);
	end

	self.Weapon:SetNextMissileCombo(time);
end

function POWERSUIT.ArmCannon:StopMissileCombo()
	self:SetNextComboLoopMuzzleTime(0);
	self:SetNextMissileComboResetTime(0);
	self:SetMissileComboBusy(false);
	self:SetMissileComboLooping(false);
end