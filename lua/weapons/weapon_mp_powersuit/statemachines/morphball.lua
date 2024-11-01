
POWERSUIT.MorphBall = {};

function POWERSUIT.MorphBall:SetupDataTables(weapon)

	self.Constants = {

		Morph = {
			Delay   = 1.0
		},

		Charge = {
			Delay   = 0.0,
			Full    = 0.4
		},

		Bomb = {
			Delay   = 3.0
		},

		PowerBomb = {
			Limit   = 8,
			Delay   = 4.0
		},

		Camera = {
			Offset = 5,
			Radius = 155
		}
	};

	self.State = {

		Morph = {
			Enable  = false
		},

		Charge = {
			Enable  = false
		},

		Bomb = {
			Enable  = false
		},

		PowerBomb = {
			Ammo    = 0,
			MaxAmmo = 0
		},

		Spider = {
			Enable  = false
		}
	};

	weapon:NetworkVar("Bool",  20, "MorphEnabled",  { KeyName = "morphball",      Edit = { order = 27, category = "Morph Ball", type = "Boolean" } });
	weapon:NetworkVar("Bool",  21, "BombsEnabled",  { KeyName = "morphballbombs", Edit = { order = 28, category = "Morph Ball", type = "Boolean" } });
	weapon:NetworkVar("Bool",  22, "BoostEnabled",  { KeyName = "boostball",      Edit = { order = 29, category = "Morph Ball", type = "Boolean" } });
	weapon:NetworkVar("Bool",  23, "SpiderEnabled", { KeyName = "spiderball",     Edit = { order = 30, category = "Morph Ball", type = "Boolean" } });

	weapon:NetworkVar("Entity", 2, "MorphBall");
	weapon:NetworkVar("Float", 18, "NextMorph");
	weapon:NetworkVar("Angle",  1, "LastViewAngles");
	weapon:NetworkVar("Vector", 0, "LastViewPos");

	weapon:NetworkVar("Float", 19, "Boost");
	weapon:NetworkVar("Float", 20, "BoostCharge");
	weapon:NetworkVar("Float", 21, "BoostChargeStart");

	weapon:NetworkVar("Float", 22, "Bomb1");
	weapon:NetworkVar("Float", 23, "Bomb2");
	weapon:NetworkVar("Float", 24, "Bomb3");

	weapon:NetworkVar("Int",   15, "PowerBombAmmo",    { KeyName = "powerbombs",    Edit = { order = 26, category = "Morph Ball", type = "Int", min = 0, max = 8 } });
	weapon:NetworkVar("Int",   16, "PowerBombMaxAmmo", { KeyName = "maxpowerbombs", Edit = { order = 25, category = "Morph Ball", type = "Int", min = 0, max = 8 } });
	weapon:NetworkVar("Float", 25, "NextPowerBomb");

	self.Weapon = weapon;
	if (SERVER) then self:LoadState(); end
end

function POWERSUIT.MorphBall:SaveState()

	-- Update local state cache with current network information.
	local weapon = self.Weapon;
	self.State.Morph.Enable      = weapon:GetMorphEnabled();
	self.State.Bomb.Enable       = weapon:GetBombsEnabled();
	self.State.Charge.Enable     = weapon:GetBoostEnabled();
	self.State.Spider.Enable     = weapon:GetSpiderEnabled();
	self.State.PowerBomb.MaxAmmo = weapon:GetPowerBombMaxAmmo();
	self.State.PowerBomb.Ammo    = weapon:GetPowerBombAmmo();

	return self.State;
end

function POWERSUIT.MorphBall:LoadState(state)

	-- Assign state to current instance.
	if (state) then self.State = state; end

	-- Initialize base variables.
	local weapon = self.Weapon;
	weapon:SetMorphEnabled(self.State.Morph.Enable);
	weapon:SetBombsEnabled(self.State.Bomb.Enable);
	weapon:SetBoostEnabled(self.State.Charge.Enable);
	weapon:SetSpiderEnabled(self.State.Spider.Enable);
	weapon:SetPowerBombMaxAmmo(self.State.PowerBomb.MaxAmmo);
	weapon:SetPowerBombAmmo(self.State.PowerBomb.Ammo);
end

function POWERSUIT.MorphBall:Reset()
	self.Weapon:SetBoostCharge(0);
	self.Weapon:SetNextMorph(CurTime());
end

function POWERSUIT.MorphBall:IsMorphEnabled()
	return self.Weapon:GetMorphEnabled();
end

function POWERSUIT.MorphBall:EnableMorph(enable)
	self.Weapon:SetMorphEnabled(enable);
end

function POWERSUIT.MorphBall:IsBombsEnabled()
	return self.Weapon:GetBombsEnabled();
end

function POWERSUIT.MorphBall:EnableBombs(enable)
	self.Weapon:SetBombsEnabled(enable);
end

function POWERSUIT.MorphBall:IsBoostEnabled()
	return self.Weapon:GetBoostEnabled();
end

function POWERSUIT.MorphBall:EnableBoost(enable)
	self.Weapon:SetBoostEnabled(enable);
end

function POWERSUIT.MorphBall:IsSpiderEnabled()
	return self.Weapon:GetSpiderEnabled();
end

function POWERSUIT.MorphBall:EnableSpider(enable)
	self.Weapon:SetSpiderEnabled(enable);
end

--
-- Morph Ball
-- 

function POWERSUIT.MorphBall:GetNextMorphTime()
	return self.Weapon:GetNextMorph();
end

function POWERSUIT.MorphBall:GetNextMorphTimeElapsed()
	return CurTime() - self:GetNextMorphTime();
end

function POWERSUIT.MorphBall:SetNextMorphTime(time)
	self.Weapon:SetNextMorph(time);
end

function POWERSUIT.MorphBall:CanMorph()
	return self:GetNextMorphTimeElapsed() > self.Constants.Morph.Delay;
end

--
-- Boost Ball
-- 

function POWERSUIT.MorphBall:GetBoostTime()
	return self.Weapon:GetBoost();
end

function POWERSUIT.MorphBall:GetBoostTimeElapsed()
	return CurTime() - self:GetBoostTime();
end

function POWERSUIT.MorphBall:SetBoostTime(time)
	self.Weapon:SetBoost(time);
end

function POWERSUIT.MorphBall:IsCharging()
	return self:GetBoostChargeTime() > 0;
end

function POWERSUIT.MorphBall:ChargingStarted()
	return self:GetBoostChargeStartTime() > 0;
end

function POWERSUIT.MorphBall:GetBoostChargeTime()
	return self.Weapon:GetBoostCharge();
end

function POWERSUIT.MorphBall:GetBoostChargeTimeElapsed()
	return CurTime() - self:GetBoostChargeTime();
end

function POWERSUIT.MorphBall:SetBoostChargeTime(time)
	self.Weapon:SetBoostCharge(time);
end

function POWERSUIT.MorphBall:GetBoostChargeStartTime()
	return self.Weapon:GetBoostChargeStart();
end

function POWERSUIT.MorphBall:SetBoostChargeStartTime(time)
	self.Weapon:SetBoostChargeStart(time);
end

function POWERSUIT.MorphBall:Boosting()
	return CurTime() < self:GetBoostTime() + self.Constants.Charge.Full;
end

function POWERSUIT.MorphBall:ShouldChargeStart(input)
	return self.Weapon:GetOwner():KeyDown(input) && !self:ChargingStarted();
end

function POWERSUIT.MorphBall:ShouldChargeLoop()
	return self:ChargingStarted() && !self:IsCharging() && self:GetBoostChargeTimeElapsed() > self.Constants.Charge.Delay;
end

function POWERSUIT.MorphBall:ShouldChargeBallFire(input)
	return !self.Weapon:GetOwner():KeyDown(input) && self:IsCharging();
end

function POWERSUIT.MorphBall:ShouldChargeStop(input)
	return !self.Weapon:GetOwner():KeyDown(input) && self:ChargingStarted();
end

function POWERSUIT.MorphBall:ChargingFull()
	if (self:GetBoostChargeTime() == 0) then return false; end
	return self:GetBoostChargeTimeElapsed() >= self.Constants.Charge.Full;
end

--
-- Morph Ball Bombs
--

function POWERSUIT.MorphBall:GetNextBombTime(bomb)
	return self.Weapon["GetBomb" .. bomb](self.Weapon, bomb);
end

function POWERSUIT.MorphBall:GetNextBombTimeElapsed(bomb)
	return CurTime() - self:GetNextBombTime(bomb);
end

function POWERSUIT.MorphBall:SetNextBombTime(bomb, time)
	self.Weapon["SetBomb" .. bomb](self.Weapon, time);
end

function POWERSUIT.MorphBall:RemainingBombs()

	local bombs = 0;
	for i = 1, 3 do
		if (self:GetNextBombTimeElapsed(i) >= self.Constants.Bomb.Delay) then bombs = bombs + 1; end
	end

	return bombs;
end

function POWERSUIT.MorphBall:CanBomb(bomb)
	return self:GetNextBombTime(bomb) == 0
		|| self:GetNextBombTimeElapsed(bomb) >= self.Constants.Bomb.Delay;
end

function POWERSUIT.MorphBall:UseBomb()

	if (!self:IsMorphEnabled() || !self:IsBombsEnabled() || !self:CanPowerBomb()) then return false; end

	for i = 1, 3 do
		if (self:CanBomb(i)) then
			self:SetNextBombTime(i, CurTime());
			return true;
		end
	end

	return false;
end

--
-- Power Bombs
-- 

function POWERSUIT.MorphBall:GetNextPowerBombTime()
	return self.Weapon:GetNextPowerBomb();
end

function POWERSUIT.MorphBall:GetNextPowerBombTimeElapsed()
	return CurTime() - self:GetNextPowerBombTime();
end

function POWERSUIT.MorphBall:SetNextPowerBombTime(time)
	self.Weapon:SetNextPowerBomb(time);
end

function POWERSUIT.MorphBall:UsePowerBombAmmo(amount)

	local current = self:GetPowerBombAmmo();
	if (self:GetPowerBombMaxAmmo() <= 0 || current < amount) then return false; end

	self.Weapon:SetPowerBombAmmo(current - amount);
	return true;
end

function POWERSUIT.MorphBall:CanPowerBomb()
	return self:GetNextPowerBombTimeElapsed() >= self.Constants.PowerBomb.Delay;
end

function POWERSUIT.MorphBall:UsePowerBomb()

	if (self:CanPowerBomb() && self:UsePowerBombAmmo(1)) then
		self:SetNextPowerBombTime(CurTime());
		return true;
	end

	return false;
end

--
-- Morph Ball Ammo
-- 

function POWERSUIT.MorphBall:GetPowerBombAmmo()
	return self.Weapon:GetPowerBombAmmo();
end

function POWERSUIT.MorphBall:AddPowerBombAmmo(amount)
	local current = self:GetPowerBombAmmo();
	return self:SetPowerBombAmmo(current + amount);
end

function POWERSUIT.MorphBall:SetPowerBombAmmo(amount)
	local max = self:GetPowerBombMaxAmmo();
	local ammo = math.Clamp(amount, 0, max);
	self.Weapon:SetPowerBombAmmo(ammo);
	return ammo;
end

function POWERSUIT.MorphBall:GetPowerBombMaxAmmo()
	return self.Weapon:GetPowerBombMaxAmmo();
end

function POWERSUIT.MorphBall:AddPowerBombMaxAmmo(amount)
	local current = self:GetPowerBombMaxAmmo();
	return self:SetPowerBombMaxAmmo(current + amount);
end

function POWERSUIT.MorphBall:SetPowerBombMaxAmmo(amount)
	local limit = self.Constants.PowerBomb.Limit;
	local maxAmmo = math.Clamp(amount, 0, limit);
	self.Weapon:SetPowerBombMaxAmmo(maxAmmo);
	local current = self:GetPowerBombAmmo();
	local ammo = math.Clamp(current, current, maxAmmo);
	self.Weapon:SetPowerBombAmmo(ammo);
	return ammo, maxAmmo;
end