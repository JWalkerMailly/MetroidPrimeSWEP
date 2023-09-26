
function POWERSUIT:TankRatio(value)
	return ((value || 0) % 100) / 99;
end

function POWERSUIT:ParseTanks(value)
	return math.ceil(((value || 0) - 99) / 100) - 1;
end

function POWERSUIT:GetHealthWarning(health, maxHealth)
	return health <= math.Round(0.0492857 * maxHealth + 25.1207);
end

function POWERSUIT:HealthNotification(health, maxHealth, drawDelegate, notificationDelegate, sender, ...)

	if (!self:GetHealthWarning(health, maxHealth)) then return; end

	-- Play droning sound for low health.
	local alpha = math.sin(CurTime() * 12.25) / 2 + 0.5;
	if (alpha < 0.1 && !self.HealthLowCallback) then
		self.HealthLowCallback = true;
		notificationDelegate(sender, ...);
	end

	if (alpha > 0.9) then self.HealthLowCallback = false; end
	drawDelegate(sender, alpha, ...);
end

function POWERSUIT:AnimatedHealthText(health, rate, state)

	if (state.health == nil) then state.health = health; end
	if (health != state.health) then
		if (health > state.health) then
			if (health - state.health > 100) then state.health = health - (state.health % 100); end
			state.health = math.Clamp(state.health + FrameTime() * rate, 0, health);
		else
			if (state.health - health > 100) then state.health = health + (state.health % 100); end
			state.health = math.Clamp(state.health - FrameTime() * rate, health, state.health);
		end
	end

	local mod  = state.health % 100;
	local tens = math.floor(mod / 10);
	local ones = math.floor(mod - (tens * 10));
	return tens, ones;
end

function POWERSUIT:GetDangerWarning(danger)
	return danger > 0.75;
end

function POWERSUIT:DangerNotification(danger, threshold, drawDelegate, notificationDelegate, sender, ...)

	if (!self:GetDangerWarning(danger)) then
		self.DangerCallback = false;
		return;
	end

	local dangerZone = danger > threshold;
	local alpha = math.sin(CurTime() * 12.25 + 1.5) / 2 + 0.5;
	if (!self.DangerCallback && (!dangerZone || (dangerZone && alpha < 0.1))) then
		notificationDelegate(sender, ...);
		self.DangerCallback = true;
	end

	if (dangerZone && alpha > 0.9) then self.DangerCallback = false; end
	drawDelegate(sender, dangerZone, alpha * 100, ...);
end

function POWERSUIT:GetMissileWarning(missiles, maxMissiles)
	return maxMissiles >= 5 && missiles < 0.2 * maxMissiles;
end

function POWERSUIT:MissileNotification(missiles, maxMissiles, drawDelegate, notificationDelegate, sender, ...)

	if (missiles > 0) then self.MissilesDepletedCallback = false; end
	if (!self:GetMissileWarning(missiles, maxMissiles)) then
		self.MissilesLowCallback = false;
		self.MissilesDepletedCallback = false;
		return;
	end

	if (missiles <= 0 && !self.MissilesDepletedCallback) then
		self.MissilesLowCallback = false;
		self.MissilesDepletedCallback = true;
	end

	if (!self.MissilesLowCallback) then
		notificationDelegate(sender, ...);
		self.MissilesLowTime = CurTime() + 7.5;
		self.MissilesLowCallback = true;
	end

	if (CurTime() >= self.MissilesLowTime) then return; end
	local fadeOutRatio = WGL.Clamp((self.MissilesLowTime - CurTime()) / 2.5);
	local alpha = (math.sin(CurTime() * 12.25 + 3) / 2 + 0.5) * 100 * fadeOutRatio;
	drawDelegate(sender, missiles, alpha, ...);
end