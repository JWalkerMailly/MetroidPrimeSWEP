
local MorphBallHUD     = WGLComponent:New(POWERSUIT, "MorphBallHUD");
MorphBallHUD.BlackBars = 0;
MorphBallHUD.Numbers   = Material("huds/numbers.png");
MorphBallHUD.Bombs     = Material("huds/morphball/bomb.png");

-- Setup UV coordinates for numbers texture lookup.
local u = 20 / 340;
local v = 24 / 40;

local healthBarWarningColor = Color(227, 113, 47, 255);

function MorphBallHUD:Reset()
	self.BlackBars = 0;
end

function MorphBallHUD:HandleBlackBars(morphball)

	-- Handle black bars transition.
	if (morphball) then self.BlackBars = self.BlackBars + FrameTime();
	else self.BlackBars = self.BlackBars - FrameTime(); end
	self.BlackBars = WGL.Clamp(self.BlackBars);
	return self.BlackBars;
end

function MorphBallHUD:DrawBlackBars(height, helmOpacity)

	-- Render top and bottom black bars using transition state.
	WGL.Rect(0, -(WGL.Y(height) * (1 - self.BlackBars)),   ScrW(), WGL.Y(height),     0, 0, 0, 255 * helmOpacity);
	WGL.Rect(0, ScrH() - (WGL.Y(height) * self.BlackBars), ScrW(), WGL.Y(height) + 1, 0, 0, 0, 255 * helmOpacity);
end

function MorphBallHUD:DrawHealthNotification(alpha)
	self.HealthBarColor = Color(255, 174 + 40 * alpha, 34 + 40 * alpha, 255);
	draw.SimpleText("Energy Low", "Metroid Prime Visor UI Bold", 512, 28, Color(255, 174, 34, 255 * alpha), TEXT_ALIGN_CENTER);
end

function MorphBallHUD:HealthNotificationCallback(weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_energy");
end

function MorphBallHUD:DrawHealth(weapon)

	local state     = weapon.HealthState;
	local health    = LocalPlayer():Health();
	local maxHealth = weapon.Helmet:GetMaxEnergy() * 100 + 99;

	if (self.LastHealth == nil) then
		self.LastHealth    = health;
		self.HealthBarLerp = health;
	end

	-- Empty energy tanks.
	local tanksTotal = weapon:ParseTanks(maxHealth);
	if (tanksTotal > -1) then
		for i = 0,tanksTotal do WGL.Rect(126 + (i * 19), 19, 14, 14, 33, 43, 53, 255); end
	end

	-- Energy tanks.
	local tanks = weapon:ParseTanks(health);
	if (tanks > -1) then
		for i = 0,tanks do WGL.Rect(126 + (i * 19), 19, 14, 14, 116, 194, 255, 255); end
	end

	-- If health increase is greater than 2 energy tanks, simply set health.
	if (health - self.HealthBarLerp > 200) then
		self.HealthBarLerp = health;
	end

	-- This part is used to interpolate the health value upon health increase.
	if (health > self.HealthBarLerp) then
		self.HealthBarLerp = math.Clamp(self.HealthBarLerp + FrameTime() * 150, 0, health);
	end

	-- This portion is required to handle health increase and decrease animations.
	-- This avoids the concurrency that arises from updating the same health bar.
	if (health < self.LastHealth) then
		self.LastHealth    = health;
		self.HealthBarLerp = health;
	end

	-- Prepare damage values.
	local lastHealthTanks = weapon:ParseTanks(state.value);
	local healthIncrease = health > self.LastHealth || lastHealthTanks > tanks;
	local damage = WGL.DelayedLerp(self.HealthBarLerp, 50, 0.75, state, healthIncrease);
	if (healthIncrease) then self.LastHealth = health; end

	-- Render empty health bar, bar damage and health text.
	local tens, ones = weapon:AnimatedHealthText(health, 150, state);
	WGL.Rect(115, 19, 5, 42, 106, 165, 213, 255);
	WGL.Rect(126, 47, 261, 8, 45, 70, 95, 255);
	WGL.Rect(126, 47, 261 * weapon:TankRatio(damage), 8, 78, 124, 165, 255);
	WGL.TextureUV(self.Numbers, 62, 22, 22, 28, u * tens, 0, u + (u * tens), v, false, 106, 165, 213, 255);
	WGL.TextureUV(self.Numbers, 86, 22, 22, 28, u * ones, 0, u + (u * ones), v, false, 106, 165, 213, 255);

	-- Render health notification system.
	self.HealthBarColor = Color(106, 165, 213, 255);
	weapon:HealthNotification(health, maxHealth, self.DrawHealthNotification, self.HealthNotificationCallback, self, weapon);

	-- Health bar.
	WGL.Rect(126, 47, 261 * weapon:TankRatio(self.HealthBarLerp), 8, WGL.LerpColorEvent(self.HealthBarColor, healthBarWarningColor, health, 0.75, "decrease", state):Unpack());
end

function MorphBallHUD:DrawBombs(morphball, morphballValid)

	-- Setup morphball bomb references for rendering.
	local bombs = 0;
	local canPowerBomb = false;
	if (morphballValid) then
		bombs = morphball:RemainingBombs();
		canPowerBomb = morphball:CanPowerBomb();
	end

	local powerBombs        = morphball:GetPowerBombAmmo();
	local bombsEnabled      = morphball:IsBombsEnabled();
	local powerBombsEnabled = morphball:GetPowerBombMaxAmmo() > 0;

	-- Empty bomb slots.
	if (bombsEnabled) then
		for i = 0,2 do WGL.Texture(self.Bombs, 796 + (i * 26), 25, 26, 26, 45, 70, 95, 255); end
	end

	-- Powerbomb slot indicator.
	if (powerBombsEnabled) then
		WGL.Rect(876, 16, 6, 43, 106, 165, 213, 255);
		WGL.Texture(self.Bombs, 881, 17, 41, 41, 45, 70, 95, 255);
	end

	-- Only render remaining bombs when not using a powerbomb.
	if (canPowerBomb) then

		-- Render remaining bombs.
		if (bombsEnabled) then
			for i = 0,bombs - 1 do WGL.Texture(self.Bombs, 796 + (i * 26), 25, 26, 26, 106, 165, 213, 255); end
		end

		-- Render remaining powerbombs.
		if (powerBombsEnabled && powerBombs > 0) then
			WGL.Texture(self.Bombs, 881, 17, 41, 41, 106, 165, 213, 255);
		end
	end

	-- Render power bomb count.
	if (!powerBombsEnabled) then return; end
	local tens = math.floor(powerBombs / 10);
	local ones = math.floor(powerBombs - (tens * 10));
	WGL.TextureUV(self.Numbers, 926, 24, 22, 28, u * tens, 0, u + (u * tens), v, false, 106, 165, 213, 255);
	WGL.TextureUV(self.Numbers, 950, 24, 22, 28, u * ones, 0, u + (u * ones), v, false, 106, 165, 213, 255);
end

function MorphBallHUD:Draw(weapon)

	if (!hook.Run("MP.PreDrawMorphBallHUD", weapon)) then

		-- Setup player health reference.
		local helmOpacity    = GetConVar("mp_options_helmetopacity"):GetInt() / 100;
		local morphball      = weapon.MorphBall;
		local morphballValid = IsValid(weapon:GetMorphBall());
		if (self:HandleBlackBars(morphballValid) <= 0) then return; end

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPMorphBallHUD", 1024, 128, { ["$additive"] = "1" }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				self:DrawHealth(weapon);
				self:DrawBombs(morphball, morphballValid);

			cam.End2D();
		render.PopRenderTarget();

		-- Finally, render the morphball hud correctly scaled to the user's resolution.
		self:DrawBlackBars(76, helmOpacity);
		WGL.Texture(self:GetRenderTexture("rt_MPMorphBallHUD"), (ScrW() - WGL.Y(1024)) / 2, -(WGL.Y(76) * (1 - self.BlackBars)), WGL.Y(1024), WGL.Y(128), 255, 255, 255, 255);
	end

	hook.Run("MP.PostDrawMorphBallHUD", weapon);
end