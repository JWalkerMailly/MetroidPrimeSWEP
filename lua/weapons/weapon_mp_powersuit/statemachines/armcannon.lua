
sm_ArmCannon = {};
sm_ArmCannon.__index = sm_ArmCannon;

function sm_ArmCannon:New(weapon)

	local object = {};
	object.Constants = {

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

	object.State = {

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

	object.Weapon = weapon;
	setmetatable(object, sm_ArmCannon);
	object:SetupDataTables();
	return object;
end

function sm_ArmCannon:SetupDataTables()

	local weapon = self.Weapon;

	WGL.AddProperty(weapon, "LoadSaveFile",          "Bool", { KeyName = "loadfile",   Edit = { order =  1, category = "Save File", type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam1Enabled",          "Bool", { KeyName = "beam1",      Edit = { order = 17, category = "Weapons",   type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam2Enabled",          "Bool", { KeyName = "beam2",      Edit = { order = 18, category = "Weapons",   type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam3Enabled",          "Bool", { KeyName = "beam3",      Edit = { order = 19, category = "Weapons",   type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam4Enabled",          "Bool", { KeyName = "beam4",      Edit = { order = 20, category = "Weapons",   type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam1ComboEnabled",     "Bool", { KeyName = "beamcombo1", Edit = { order = 21, category = "Combos",    type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam2ComboEnabled",     "Bool", { KeyName = "beamcombo2", Edit = { order = 22, category = "Combos",    type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam3ComboEnabled",     "Bool", { KeyName = "beamcombo3", Edit = { order = 23, category = "Combos",    type = "Boolean" } });
	WGL.AddProperty(weapon, "Beam4ComboEnabled",     "Bool", { KeyName = "beamcombo4", Edit = { order = 24, category = "Combos",    type = "Boolean" } });
	WGL.AddProperty(weapon, "ChargeBeamEnabled",     "Bool", { KeyName = "chargebeam", Edit = { order = 16, category = "Weapons",   type = "Boolean" } });

	WGL.AddProperty(weapon, "BeamType",              "Int");
	WGL.AddProperty(weapon, "BeamRoll",              "Int");
	WGL.AddProperty(weapon, "BeamBusy",              "Bool");
	WGL.AddProperty(weapon, "NextBeamChange",        "Float");

	WGL.AddProperty(weapon, "NextBeamMuzzle",        "Float");
	WGL.AddProperty(weapon, "NextChargeMuzzle",      "Float");
	WGL.AddProperty(weapon, "NextComboMuzzle",       "Float");
	WGL.AddProperty(weapon, "NextComboLoopMuzzle",   "Float");
	WGL.AddProperty(weapon, "NextBeamOpen",          "Float");
	WGL.AddProperty(weapon, "NextBeamOpenAnim",      "Float");
	WGL.AddProperty(weapon, "NextBeamClose",         "Float");
	WGL.AddProperty(weapon, "NextBeamFidget",        "Float");

	WGL.AddProperty(weapon, "ChargeStart",           "Float");
	WGL.AddProperty(weapon, "ChargeStarted",         "Bool");
	WGL.AddProperty(weapon, "ChargeTime",            "Float");
	WGL.AddProperty(weapon, "ChargeMax",             "Bool");
	WGL.AddProperty(weapon, "ChargeViewPunch",       "Float");
	WGL.AddProperty(weapon, "NextViewPunch",         "Float");

	WGL.AddProperty(weapon, "NextMissile",           "Float");
	WGL.AddProperty(weapon, "NextMissileReload",     "Float");

	WGL.AddProperty(weapon, "MissileCombo",          "Entity");
	WGL.AddProperty(weapon, "MissileComboBusy",      "Bool");
	WGL.AddProperty(weapon, "MissileComboLoop",      "Bool");
	WGL.AddProperty(weapon, "NextMissileCombo",      "Float");
	WGL.AddProperty(weapon, "NextMissileComboReset", "Float");
	WGL.AddProperty(weapon, "NextMissileComboDrain", "Float");

	WGL.AddProperty(weapon, "Beam1Ammo",             "Int");
	WGL.AddProperty(weapon, "Beam1MaxAmmo",          "Int");
	WGL.AddProperty(weapon, "Beam2Ammo",             "Int");
	WGL.AddProperty(weapon, "Beam2MaxAmmo",          "Int");
	WGL.AddProperty(weapon, "Beam3Ammo",             "Int");
	WGL.AddProperty(weapon, "Beam3MaxAmmo",          "Int");
	WGL.AddProperty(weapon, "Beam4Ammo",             "Int");
	WGL.AddProperty(weapon, "Beam4MaxAmmo",          "Int");
	WGL.AddProperty(weapon, "MissileAmmo",           "Int", { KeyName = "missiles",    Edit = { order = 15, category = "Weapons", type = "Int", min = 0, max = 250 } });
	WGL.AddProperty(weapon, "MissileMaxAmmo",        "Int", { KeyName = "maxmissiles", Edit = { order = 14, category = "Weapons", type = "Int", min = 0, max = 250 } });

	if (SERVER) then self:LoadState(); end
end

function sm_ArmCannon:SaveState()

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

function sm_ArmCannon:LoadState(state)

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

function sm_ArmCannon:GetBeam()
	return self.Weapon:GetBeamType();
end

function sm_ArmCannon:SetBeam(beam)
	self.Weapon:SetBeamType(beam);
end

function sm_ArmCannon:IsBeamEnabled(index)
	return self.Weapon["GetBeam" .. index .. "Enabled"](self.Weapon);
end

function sm_ArmCannon:EnableBeam(index, enable)
	self.Weapon["SetBeam" .. index .. "Enabled"](self.Weapon, enable);
end

function sm_ArmCannon:IsChargeBeamEnabled()
	return self.Weapon:GetChargeBeamEnabled();
end

function sm_ArmCannon:EnableChargeBeam(enable)
	self.Weapon:SetChargeBeamEnabled(enable);
end

function sm_ArmCannon:IsMissileComboEnabled(index, enable)
	return self.Weapon["GetBeam" .. index .. "ComboEnabled"](self.Weapon, enable);
end

function sm_ArmCannon:EnableMissileCombo(index, enable)
	self.Weapon["SetBeam" .. index .. "ComboEnabled"](self.Weapon, enable);
end

function sm_ArmCannon:Waterlogged()
	return self.Weapon:GetOwner():WaterLevel() >= self.Constants.Beam.Waterlog;
end

--
-- Beam Animations
--

function sm_ArmCannon:GetBeamRoll()
	return self.Weapon:GetBeamRoll();
end

function sm_ArmCannon:SetBeamRoll(roll)
	if (math.random(7) > 4) then self.Weapon:SetBeamRoll(roll); end
end

function sm_ArmCannon:GetNextBeamFidgetTime()
	return self.Weapon:GetNextBeamFidget();
end

function sm_ArmCannon:GetNextBeamFidgetTimeElapsed()
	return CurTime() - self:GetNextBeamFidgetTime();
end

function sm_ArmCannon:SetNextBeamFidgetTime(time)
	self.Weapon:SetNextBeamFidget(time);
end

function sm_ArmCannon:CanBeamFidget()
	return self:GetNextBeamFidgetTimeElapsed() > self.Constants.Fidget.Delay;
end

function sm_ArmCannon:GetViewPunch()
	return self.Weapon:GetChargeViewPunch();
end

function sm_ArmCannon:SetViewPunch(punch)
	self.Weapon:SetChargeViewPunch(punch);
end

function sm_ArmCannon:ViewPunch(punch)
	self.Weapon:SetNextViewPunch(CurTime() + self.Constants.ViewPunch.Reset);
	self:SetViewPunch(punch);
end

function sm_ArmCannon:ShouldViewPunchReset()
	return self:GetViewPunch() != 0 && CurTime() > self.Weapon:GetNextViewPunch();
end

--
-- Beam Muzzles
-- 

function sm_ArmCannon:SetNextBeamMuzzleTime(time)
	self.Weapon:SetNextBeamMuzzle(time);
end

function sm_ArmCannon:SetNextChargeMuzzleTime(time)
	self.Weapon:SetNextChargeMuzzle(time);
end

function sm_ArmCannon:SetNextComboMuzzleTime(time)
	self.Weapon:SetNextComboMuzzle(time);
end

function sm_ArmCannon:SetNextComboLoopMuzzleTime(time)
	self.Weapon:SetNextComboLoopMuzzle(time);
end

--
-- Beam Busy States
-- 

function sm_ArmCannon:IsBeamOpen()
	return self:IsBeamBusy() || self:IsMissileBusy();
end

function sm_ArmCannon:IsBusy(ignoreOpenState)
	return self:IsCharging() || (!ignoreOpenState && self:IsBeamOpen()) || self:IsMissileComboBusy() || !self:CanBeamChange();
end

function sm_ArmCannon:IsBeamBusy()
	return self.Weapon:GetBeamBusy();
end

function sm_ArmCannon:SetBeamBusy(busy)
	self.Weapon:SetBeamBusy(busy);
end

function sm_ArmCannon:IsMissileBusy()
	return !self:IsMissileComboBusy()
		&& CurTime() < self:GetNextMissileTime();
end

function sm_ArmCannon:IsMissileComboBusy()
	return self.Weapon:GetMissileComboBusy();
end

function sm_ArmCannon:SetMissileComboBusy(busy)
	if (!busy) then self:SetNextMissileComboResetTime(0); end
	self.Weapon:SetMissileComboBusy(busy);
end

--
-- Beam Change
--

function sm_ArmCannon:GetNextBeamChangeTime()
	return self.Weapon:GetNextBeamChange();
end

function sm_ArmCannon:GetNextBeamChangeTimeElapsed()
	return CurTime() - self:GetNextBeamChangeTime();
end

function sm_ArmCannon:SetNextBeamChangeTime(time)
	self.Weapon:SetNextBeamChange(time);
end

function sm_ArmCannon:CanBeamChange()
	return !self:IsMissileComboBusy()
		&& self:GetNextBeamChangeTimeElapsed() > self.Constants.Beam.Change;
end

function sm_ArmCannon:CanBeamChangeAnim()
	return !self:IsMissileComboBusy()
		&& self:GetNextBeamChangeTimeElapsed() > self.Constants.Beam.ChangeAnim;
end

--
-- Beam Open State
--

function sm_ArmCannon:GetNextBeamOpenTime()
	return self.Weapon:GetNextBeamOpen();
end

function sm_ArmCannon:GetNextBeamOpenAnimTime()
	return self.Weapon:GetNextBeamOpenAnim();
end

function sm_ArmCannon:SetNextBeamOpenTime(time)
	self.Weapon:SetNextBeamOpen(time);
end

function sm_ArmCannon:SetNextBeamOpenAnimTime(time)
	self.Weapon:SetNextBeamOpenAnim(time);
end

function sm_ArmCannon:GetNextBeamCloseTime()
	return self.Weapon:GetNextBeamClose();
end

function sm_ArmCannon:SetNextBeamCloseTime(time)
	self.Weapon:SetNextBeamClose(time);
end

--
-- Charge Beam
-- 

function sm_ArmCannon:IsMaxCharge()
	return self.Weapon:GetChargeMax();
end

function sm_ArmCannon:SetMaxCharge(max)
	self.Weapon:SetChargeMax(max);
end

function sm_ArmCannon:GetChargeStartTime()
	return self.Weapon:GetChargeStart();
end

function sm_ArmCannon:GetChargeStartTimeElapsed()
	return CurTime() - self:GetChargeStartTime();
end

function sm_ArmCannon:ChargingStarted()
	return self:GetChargeStartTime() > 0;
end

function sm_ArmCannon:SetNextChargeStartTime(time)
	self.Weapon:SetChargeStart(time);
end

function sm_ArmCannon:ChargeStarted()
	return self.Weapon:GetChargeStarted();
end

function sm_ArmCannon:SetChargeStarted(started)
	return self.Weapon:SetChargeStarted(started);
end

function sm_ArmCannon:GetChargeTime()
	return self.Weapon:GetChargeTime();
end

function sm_ArmCannon:GetChargeTimeElapsed()
	return CurTime() - self:GetChargeTime();
end

function sm_ArmCannon:IsCharging()
	return self:GetChargeTime() > 0;
end

function sm_ArmCannon:SetChargeTime(time)
	self.Weapon:SetChargeTime(time);
end

function sm_ArmCannon:ShouldChargeBeamStart()

	return self:IsChargeBeamEnabled()
		&& !self:IsCharging()
		&& self:ChargingStarted()
		&& self:GetChargeStartTimeElapsed() > self.Constants.Charge.Delay;
end

function sm_ArmCannon:GetChargeRatio()
	if (!self:ChargeStarted()) then return 0; end
	return WGL.Clamp(self:GetChargeTimeElapsed() / self.Constants.Charge.Full);
end

function sm_ArmCannon:ChargingFull()
	if (self:GetChargeTime() == 0) then return false; end
	return self:GetChargeTimeElapsed() >= self.Constants.Charge.Full;
end

function sm_ArmCannon:ShouldChargeBeamFire(input)
	return self:IsCharging()
		&& self:GetChargeTimeElapsed() >= self.Constants.Charge.Weak
		&& !self.Weapon:GetOwner():KeyDown(input);
end

function sm_ArmCannon:ShouldChargeBeamStop(input)
	return !self.Weapon:GetOwner():KeyDown(input) && self:ChargingStarted();
end

function sm_ArmCannon:StopCharging()
	self:SetNextChargeStartTime(0);
	self:SetChargeTime(0);
end

--
-- Missiles
-- 

function sm_ArmCannon:GetMissileAmmo()
	return self.Weapon:GetMissileAmmo();
end

function sm_ArmCannon:GetMissileMaxAmmo()
	return self.Weapon:GetMissileMaxAmmo();
end

function sm_ArmCannon:UseMissileAmmo(amount)

	local current = self:GetMissileAmmo();
	if (current < amount) then return false; end

	self.Weapon:SetMissileAmmo(current - amount);
	return true;
end

function sm_ArmCannon:CanMissileFire()
	return self:GetNextMissileTimeElapsed() > self.Constants.Missile.Delay
		&& self:GetMissileAmmo() > 0;
end

function sm_ArmCannon:GetNextMissileTime()
	return self.Weapon:GetNextMissile();
end

function sm_ArmCannon:GetNextMissileTimeElapsed()
	return CurTime() - self:GetNextMissileTime();
end

function sm_ArmCannon:SetNextMissileTime(time)
	self.Weapon:SetNextMissile(time);
end

function sm_ArmCannon:GetNextMissileReloadTime()
	return self.Weapon:GetNextMissileReload();
end

function sm_ArmCannon:SetNextMissileReloadTime(time)
	self.Weapon:SetNextMissileReload(time);
end

function sm_ArmCannon:ShouldMissileReload()
	local nextReload = self:GetNextMissileReloadTime();
	return nextReload > 0
		&& CurTime() - nextReload >= self.Constants.Missile.Reload;
end

function sm_ArmCannon:IsMissileReloading()
	return self.Weapon:GetMissileMaxAmmo() > 0 && CurTime() > self:GetNextMissileTime() - self.Constants.Missile.Busy;
end

function sm_ArmCannon:ShouldMissileReset()
	return self:IsBeamBusy()
		&& CurTime() > self:GetNextMissileTime() + self.Constants.Missile.Auto;
end

--
-- Beam Combo
-- 

function sm_ArmCannon:GetNextMissileComboTime()
	return self.Weapon:GetNextMissileCombo();
end

function sm_ArmCannon:GetNextMissileComboTimeElapsed()
	return CurTime() - self:GetNextMissileComboTime();
end

function sm_ArmCannon:SetNextMissileComboDrainTime(time)
	self.Weapon:SetNextMissileComboDrain(time);
end

function sm_ArmCannon:GetNextMissileComboDrainTime()
	return self.Weapon:GetNextMissileComboDrain();
end

function sm_ArmCannon:GetNextMissileComboDrainTimeElapsed()
	return CurTime() - self:GetNextMissileComboDrainTime();
end

function sm_ArmCannon:GetNextMissileComboResetTime()
	return self.Weapon:GetNextMissileComboReset();
end

function sm_ArmCannon:SetNextMissileComboResetTime(time)
	if (time > 0) then self:SetNextMissileComboDrainTime(CurTime()); end
	self.Weapon:SetNextMissileComboReset(time);
end

function sm_ArmCannon:CanMissileCombo(cost)
	return self:IsMissileComboEnabled(self:GetBeam())
		&& self:IsCharging()
		&& self:ChargingFull()
		&& self:GetMissileAmmo() >= cost;
end

function sm_ArmCannon:GetMissileComboStartRatio()
	return self:GetNextMissileComboTimeElapsed() / self.Constants.Combo.Delay;
end

function sm_ArmCannon:ShouldMissileCombo()
	return self:IsMissileComboBusy()
		&& self:GetNextMissileComboTime() > 0
		&& self:GetNextMissileComboTimeElapsed() >= self.Constants.Combo.Delay;
end

function sm_ArmCannon:ShouldMissileComboDrain(continuous)
	return continuous && self:IsMissileComboDraining()
end

function sm_ArmCannon:MissileComboDrain(continuous)
	self:SetNextMissileComboDrainTime(CurTime());
	self:UseMissileAmmo(1);
end

function sm_ArmCannon:IsMissileComboDraining()
	return self:IsMissileComboBusy()
		&& self:GetNextMissileComboTimeElapsed() > self.Constants.Combo.Delay
		&& self:GetNextMissileComboDrainTimeElapsed() > self.Constants.Combo.Drain;
end

function sm_ArmCannon:ShouldMissileComboReset(input, loop, water)
	return self:GetNextMissileComboResetTime() > 0
		&& CurTime() > self:GetNextMissileComboResetTime()
		&& ((!loop || !self.Weapon:GetOwner():KeyDown(input)) || (!water && self:Waterlogged()) || !IsValid(self.Weapon:GetMissileCombo()));
end

function sm_ArmCannon:MissileComboLooping()
	return self.Weapon:GetMissileComboLoop();
end

function sm_ArmCannon:SetMissileComboLooping(loop)
	self.Weapon:SetMissileComboLoop(loop);
end

--
-- Beam Ammo
--

function sm_ArmCannon:GetAmmo(type)
	return self.Weapon["Get" .. type .. "Ammo"](self.Weapon);
end

function sm_ArmCannon:AddAmmo(type, amount)
	local ammo = self:GetAmmo(type);
	return self:SetAmmo(type, ammo + amount);
end

function sm_ArmCannon:SetAmmo(type, amount)
	local max = self:GetMaxAmmo(type);
	local ammo = math.Clamp(amount, 0, max);
	self.Weapon["Set" .. type .. "Ammo"](self.Weapon, ammo);
	return ammo;
end

function sm_ArmCannon:GetMaxAmmo(type)
	return self.Weapon["Get" .. type .. "MaxAmmo"](self.Weapon);
end

function sm_ArmCannon:AddMaxAmmo(type, amount)
	local ammo = self:GetMaxAmmo(type);
	return self:SetMaxAmmo(type, ammo + amount);
end

function sm_ArmCannon:SetMaxAmmo(type, amount)
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

function sm_ArmCannon:Reset()
	self.Weapon:SetNextBeamOpen(0);
	self.Weapon:SetNextBeamOpenAnim(0);
	self.Weapon:SetNextBeamClose(0);
end

function sm_ArmCannon:StartBeamChange(beam)
	self:SetNextBeamOpenTime(0);
	self:SetNextBeamCloseTime(0);
	self:SetNextBeamChangeTime(CurTime());
	return self:IsBeamEnabled(beam), self:IsBeamOpen();
end

function sm_ArmCannon:StartBeamOpen()

	local shouldStart = self:GetNextBeamOpenTime() != 0 && CurTime() > self:GetNextBeamOpenTime();
	if (shouldStart) then self:SetNextBeamOpenTime(0); end
	return shouldStart;
end

function sm_ArmCannon:StartBeamOpenAnim()

	local shouldStart = self:GetNextBeamOpenAnimTime() != 0 && CurTime() > self:GetNextBeamOpenAnimTime();
	if (shouldStart) then self:SetNextBeamOpenAnimTime(0); end
	return shouldStart;
end

function sm_ArmCannon:StartBeamClose()

	local shouldStart = self:GetNextBeamCloseTime() != 0 && CurTime() > self:GetNextBeamCloseTime();
	if (shouldStart) then self:SetNextBeamCloseTime(0); end
	return shouldStart;
end

function sm_ArmCannon:StartBeam()
	self:SetNextBeamMuzzleTime(CurTime());
	self:SetNextChargeStartTime(CurTime());
	self:SetBeamRoll(math.Rand(-12.5, 12.5));
end

function sm_ArmCannon:StopBeam(silent, quickCharge, close)

	self:SetNextChargeStartTime(!quickCharge && 0 || CurTime());
	self:SetNextMissileReloadTime(0);
	self:SetNextMissileTime(0);
	self:SetBeamBusy(false);

	if (silent) then return; end
	self:SetNextBeamOpenTime(CurTime() + self.Constants.Missile.Open);
	if (close) then self:SetNextBeamCloseTime(CurTime() + self.Constants.Missile.Close); end
end

function sm_ArmCannon:StartChargeBeam(quickCharge)

	self:SetChargeTime(CurTime());
	self:SetChargeStarted(true);

	if (!quickCharge) then return; end
	self:SetNextBeamOpenTime(CurTime() + self.Constants.Charge.Open);
	self:SetNextBeamCloseTime(0);
end

function sm_ArmCannon:StopChargeBeam(shoot, punch)

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

function sm_ArmCannon:StartMissile()
	self:UseMissileAmmo(1);
	self:SetBeamBusy(true);
	self:SetNextMissileTime(CurTime());
	self:SetNextMissileReloadTime(CurTime());
end

function sm_ArmCannon:StartMissileCombo(time, cost, reset, punch)

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

function sm_ArmCannon:StopMissileCombo()
	self:SetNextComboLoopMuzzleTime(0);
	self:SetNextMissileComboResetTime(0);
	self:SetMissileComboBusy(false);
	self:SetMissileComboLooping(false);
end

setmetatable(sm_ArmCannon, {__call = sm_ArmCannon.New });