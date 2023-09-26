
local ThermalVisor  = WGLComponent:New(POWERSUIT, "ThermalVisor");
ThermalVisor.Models = {
	["GUI"]         = Model("models/metroid/hud/thermalvisor/v_ui_context.mdl"),
	["GUIMenus"]    = Model("models/metroid/hud/v_ui_context.mdl"),
	["StaticGUI"]   = Model("models/metroid/hud/thermalvisor/v_staticgui.mdl")
};

-- Setup UV coordinates for numbers texture lookup.
local u = 20 / 340;
local v = 24 / 40;

local numbersUIMaterial    = Material("huds/numbers.png");
local missileMaterial      = Material("huds/thermal/missile");
local alertMaterial        = Material("huds/thermal/alert");
local arrowMaterial        = Material("huds/thermal/arrow");
local reticleBigMaterial   = Material("huds/thermal/reticle_big");
local reticleSmallMaterial = Material("huds/thermal/reticle_small");
local lockOuter            = Material("huds/thermal/lock_outer");
local static               = Material("huds/static");

local healthBarWarningColor = Color(227, 113, 47, 255);

function ThermalVisor:Initialize()
	self.MissileLerpFont      = {};
	self.LastReticleAlpha     = 0;
	self.LastReticleVector    = Vector(0, 0, 0);
	self.LastReticleMovement  = 0;
	self.LastReticleTarget    = NULL;
	self.LastReticleLerp      = 0;
	self.LastReticleLerpAlpha = 0;
	self.ReticleX             = 0;
	self.ReticleY             = 0;
	self.LastMouseX           = 0;
	self.LastMouseY           = 0;
end

function ThermalVisor:DrawHealthNotification(alpha)
	self.HealthBarColor = Color(255, 174 + 40 * alpha, 34 + 40 * alpha, 255);
	draw.SimpleText("Energy Low", "Metroid Prime Visor UI Small", 512, 132, Color(255, 174, 34, 255 * alpha), TEXT_ALIGN_CENTER);
end

function ThermalVisor:HealthNotificationCallback(weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_energy");
end

function ThermalVisor:DrawHealth(weapon)

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
		for i = 0,tanksTotal do
			WGL.Rect(438 + (i * 14), 107, 10, 8, 45, 70, 95, 255);
		end
	end

	-- Energy tanks.
	local tanks = weapon:ParseTanks(health);
	if (tanks > -1) then
		for i = 0,tanks do
			WGL.Rect(438 + (i * 14), 107, 10, 8, 116, 194, 255, 255);
		end
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
	WGL.Rect(429, 107, 4, 21, 93, 123, 183, 255);
	WGL.Rect(438, 121, 192, 5, 45, 70, 95, 255);
	WGL.Rect(438, 121, 192 * weapon:TankRatio(damage), 5, 78, 124, 165, 255);
	WGL.TextureUV(numbersUIMaterial, 392, 107, 17, 20, u * tens, 0, u + (u * tens), v, false, 93, 123, 183, 255);
	WGL.TextureUV(numbersUIMaterial, 410, 107, 17, 20, u * ones, 0, u + (u * ones), v, false, 93, 123, 183, 255);

	-- Render health notification system.
	self.HealthBarColor = Color(116, 194, 255, 255);
	weapon:HealthNotification(health, maxHealth, self.DrawHealthNotification, self.HealthNotificationCallback, self, weapon);

	-- Health bar.
	WGL.Rect(438, 121, 192 * weapon:TankRatio(self.HealthBarLerp), 5, WGL.LerpColorEvent(self.HealthBarColor, healthBarWarningColor, health, 0.75, "decrease", state):Unpack());
end

function ThermalVisor:DrawAlertNotification(dangerZone, alpha, visorOpacity)
	if (dangerZone) then
		draw.SimpleText("Damage",  "Metroid Prime Visor UI Small", 157, 262, Color(255, 0, 0, alpha * visorOpacity));
	else
		draw.SimpleText("Warning", "Metroid Prime Visor UI Small", 157, 262, Color(255, 174, 34, alpha * visorOpacity));
	end
end

function ThermalVisor:AlertNotificationCallback(_, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "warning");
end

function ThermalVisor:DrawAlert(weapon, visorOpacity)

	local alertRatio = weapon:GetDangerRatio();
	local baseAlpha  = 255 * visorOpacity;

	-- Render alert icon.
	WGL.TextureRot(alertMaterial, 233, 306, 74, 50, 1.1225, 93, 123, 183, baseAlpha);

	-- Render alert ratio.
	if (alertRatio > 0) then draw.SimpleText(math.Round(10 - (alertRatio * 10), 1), "Metroid Prime Visor UI Small", 295 + 86 * alertRatio, 272 - 112 * alertRatio, Color(45, 70, 95, baseAlpha), TEXT_ALIGN_RIGHT); end

	-- Render alert bar.
	WGL.TextureRot(arrowMaterial, 319 + 86 * alertRatio, 293 - 112 * alertRatio, 18, 20, -128.5, 93, 123, 183, baseAlpha);
	WGL.RectRotOrigin(330, 302, 5, 143, 217.5, 31, 43, 57, baseAlpha);
	WGL.RectRotOrigin(330, 302, 5, 143 * alertRatio, 217.5, 116, 194, 255, baseAlpha);
	weapon:DangerNotification(alertRatio, 0.9, self.DrawAlertNotification, self.AlertNotificationCallback, self, visorOpacity, weapon);
end

function ThermalVisor:DrawMissileNotification(remaining, alpha, visorOpacity)
	if (remaining > 0) then
		draw.SimpleText("Missiles", "Metroid Prime Visor UI Small", 822, 254, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_CENTER);
		draw.SimpleText("Low",      "Metroid Prime Visor UI Small", 822, 272, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_CENTER);
	else
		draw.SimpleText("Depleted", "Metroid Prime Visor UI Small", 785, 262, Color(255, 174, 34, alpha * visorOpacity));
	end
end

function ThermalVisor:MissileNotificationCallback(_, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_missiles");
end

function ThermalVisor:DrawMissiles(weapon, visorOpacity)

	local missiles     = weapon.ArmCannon:GetMissileAmmo();
	local maxMissiles  = weapon.ArmCannon:GetMissileMaxAmmo();
	local baseAlpha    = 255 * visorOpacity;
	local fontColor    = WGL.LerpColorEvent(Color(45, 70, 95, baseAlpha), Color(93, 123, 183, baseAlpha), missiles, 2, "change", self.MissileLerpFont);
	local missileRatio = (missiles / math.Clamp(maxMissiles, 1, maxMissiles + 1));

	-- Render missile icon.
	WGL.TextureRot(missileMaterial, 791, 306, 74, 50, -1.1225, 93, 123, 183, baseAlpha);

	-- Render missile count.
	draw.SimpleText(missiles, "Metroid Prime Visor UI Small", 732 - 86 * missileRatio, 272 - 112 * missileRatio, fontColor);

	-- Render missile bar.
	WGL.TextureRot(arrowMaterial, 705 - 86 * missileRatio, 293 - 112 * missileRatio, 18, 20, 128.5, 93, 123, 183, baseAlpha);
	WGL.RectRotOrigin(698, 299, 5, 143, 142.5, 31, 43, 57, baseAlpha);
	WGL.RectRotOrigin(698, 299, 5, 143 * missileRatio, 142.5, 116, 194, 255, baseAlpha);
	weapon:MissileNotification(missiles, maxMissiles, self.DrawMissileNotification, self.MissileNotificationCallback, self, visorOpacity, weapon);
end

function ThermalVisor:DrawReticle(weapon, w, h, visorOpacity)

	local nextTarget, validTarget, locked = weapon.Helmet:GetTarget(IN_SPEED);

	-- Reticle screen positioning.
	local cx        = w / 2;
	local cy        = h / 2;
	self.ReticleX   = cx;
	self.ReticleY   = cy;

	-- Setup reticle screen position.
	local screenPos = self.LastReticleVector;
	if (locked) then screenPos = Vector(cx, cy, 0); end

	-- Reticle alpha, this will modulate the auto lock and charge reticle.
	local alpha     = 255;
	local lerp      = self.LastReticleLerp;
	local lerpAlpha = self.LastReticleLerpAlpha;

	-- Reticle size lerp. This will be used to animate the reticle zooming in and out.
	if (!locked) then
		lerp      = Lerp(FrameTime() * 2, self.LastReticleLerp, 10);
		lerpAlpha = Lerp(FrameTime() * 10, self.LastReticleLerpAlpha, 0);
	else
		lerp      = Lerp(FrameTime() * 30, self.LastReticleLerp, 1);
		lerpAlpha = Lerp(FrameTime() * 30, self.LastReticleLerpAlpha, 255);
	end

	if (!validTarget && !locked) then

		-- No target found, reset everything back to the center of the screen.
		lerp      = Lerp(FrameTime(), self.LastReticleLerp, 0);
		alpha     = Lerp(FrameTime() * 10, self.LastReticleAlpha, 0);
		screenPos = LerpVector(FrameTime() * 10, self.LastReticleVector, Vector(cx + self.LastMouseX * 2, cy + self.LastMouseY * 2, 0));
		self.LastReticleTarget = NULL;
	else

		-- Best target swapped, reset animations and last target reference.
		if (self.LastReticleTarget != nextTarget) then
			self.LastReticleTarget   = nextTarget;
			self.LastReticleMovement = 0;
		end

		-- Last reticle movement is compounded every frame onto the screen position
		-- interpolation giving the snapping effect to each target.
		if (self.LastReticleMovement < 1 && validTarget) then
			local targetPosLocal     = nextTarget:WorldSpaceCenter():ToScreen();
			local targetPosVector    = Vector(targetPosLocal.x, targetPosLocal.y, 0);
			alpha                    = Lerp(FrameTime() * 10, self.LastReticleAlpha, 255);
			screenPos                = LerpVector(self.LastReticleMovement, self.LastReticleVector, targetPosVector);
			self.LastReticleMovement = Lerp(FrameTime(), self.LastReticleMovement, 1);
		end
	end

	-- Render small auto lock reticle if we are not currently targeting something.
	if (!locked) then
		self.ReticleX = screenPos[1];
		self.ReticleY = screenPos[2];
	else
		self.LastMouseX = 0;
		self.LastMouseY = 0;
		alpha = math.abs((lerpAlpha / 255) - 1) * 255;
	end

	-- Render lock on effect.
	WGL.TextureRot(lockOuter, 512, 300, 500 * lerp, 400 * lerp, 0, 93, 123, 183, lerpAlpha * visorOpacity);

	self.LastReticleLerp      = lerp;
	self.LastReticleAlpha     = alpha;
	self.LastReticleVector    = screenPos;
	self.LastReticleLerpAlpha = lerpAlpha;
end

function ThermalVisor:Draw(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)

	if (!hook.Run("MP.PreDrawThermalVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)) then

		local transitionFirst = WGL.Clamp(transition + transitionStart);
		local transitionLast  = WGL.Clamp(transition);

		-- Offload hud rendering operations to a separate render target.
		local w = ScrW();
		local h = ScrH();
		self:PushRenderTexture("rt_MPThermalVisor", 1024, 768, { ["$additive"] = 1 }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				surface.SetAlphaMultiplier(transitionLast);
				self:DrawReticle(weapon, w, h, visorOpacity);
				self:DrawHealth(weapon);
				self:DrawAlert(weapon, visorOpacity);
				self:DrawMissiles(weapon, visorOpacity);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		-- Offload hud menus rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPThermalVisorMenus", 1024, 768, { ["$additive"] = 1 }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				surface.SetAlphaMultiplier(transitionFirst * visorOpacity);
				local beamMenu  = WGL.GetComponent(weapon, "BeamMenu");
				local visorMenu = WGL.GetComponent(weapon, "VisorMenu");
				beamMenu:DrawText(beam);
				visorMenu:DrawText(visor);
				beamMenu:OverrideBlend(1);
				visorMenu:OverrideBlend(1);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		WGL.Start3D(widescreen);
		cam.IgnoreZ(true);

			-- Render UI portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPThermalVisor"));
			self:DrawModel("GUI", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render UI menus portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPThermalVisorMenus"));
			self:DrawModel("GUIMenus", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render the 3D static UI elements.
			render.SetColorModulation(guiColor.r, guiColor.g, guiColor.b);
			render.SetBlend(transition * visorOpacity);
			self:DrawModel("StaticGUI", guiPos, hudAngle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);

		cam.End3D();

		-- Render screen reticle.
		local fovCompensation = 1 - fovRatio;
		surface.SetAlphaMultiplier(transitionLast);
		WGL.TextureRot(reticleBigMaterial, ScrW() / 2 + self.LastMouseX, ScrH() / 2 + self.LastMouseY, WGL.Y(386 * fovCompensation), WGL.Y(386 * fovCompensation), 0, 93, 123, 183, 100);
		WGL.TextureRot(reticleSmallMaterial, self.ReticleX, self.ReticleY, WGL.Y(228 * fovCompensation), WGL.Y(228 * fovCompensation), 0, 93, 123, 183, 100);
		self.LastMouseX = Lerp(FrameTime() * 10, self.LastMouseX, LocalPlayer().__mp_MouseX || 0);
		self.LastMouseY = Lerp(FrameTime() * 10, self.LastMouseY, LocalPlayer().__mp_MouseY || 0);
		surface.SetAlphaMultiplier(1);

		-- Render static effect.
		local randU  = math.Rand(0, 0.1);
		local randV  = math.Rand(0, 0.5);
		if (transition != 0) then WGL.TextureUV(static, 0, 0, ScrW(), ScrH(), 0 + randU, 0 + randV, 0.9 + randU, 0.5 + randV, false, 225, 255, 255, 255); end
	end

	hook.Run("MP.PostDrawThermalVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity);
end