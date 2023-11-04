
local XRayVisor   = WGLComponent:New(POWERSUIT, "XRayVisor");
XRayVisor.Models  = {
	["GUI"]       = Model("models/metroid/hud/xrayvisor/v_ui_context.mdl"),
	["GUIMenus"]  = Model("models/metroid/hud/v_ui_context.mdl"),
	["GUINotifs"] = Model("models/metroid/hud/thermalvisor/v_ui_context.mdl"),
	["StaticGUI"] = Model("models/metroid/hud/xrayvisor/v_staticgui.mdl")
};

-- Setup UV coordinates for numbers texture lookup.
local u = 20 / 340;
local v = 24 / 40;

local reticleMaterial      = Material("huds/xray/reticle");
local numbersUIMaterial    = Material("huds/numbers.png");
local missileMaterial      = Material("huds/xray/missile");
local alertMaterial        = Material("huds/xray/alert");
local reticleBigMaterial   = Material("huds/xray/reticle_big");
local reticleSmallMaterial = Material("huds/xray/reticle_small");

local healthBarWarningColor = Color(227, 113, 47, 255);

function XRayVisor:Initialize()
	self.MissileLerpFont     = {};
	self.HealthBarColor      = Color(116, 194, 255, 255);
	self.LastReticleVector   = Vector(0, 0, 0);
	self.LastReticleMovement = 0;
	self.LastReticleTarget   = NULL;
	self.LastReticleLerp     = 0;
	self.LastMouseX          = 0;
	self.LastMouseY          = 0;
end

function XRayVisor:DrawHealth(weapon, health, maxHealth)

	local state = weapon.HealthState;
	if (self.LastHealth == nil) then
		self.LastHealth    = health;
		self.HealthBarLerp = health;
	end

	-- Empty energy tanks.
	local tanksTotal = weapon:ParseTanks(maxHealth);
	if (tanksTotal > -1) then
		for i = 0,tanksTotal do
			WGL.Rect(400 + (i * 12), 12, 9, 11, 45, 70, 95, 255);
		end
	end

	-- Energy tanks.
	local tanks = weapon:ParseTanks(health);
	if (tanks > -1) then
		for i = 0,tanks do
			WGL.Rect(400 + (i * 12), 12, 9, 11, 116, 194, 255, 255);
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
		self.LastHealth = health;
		self.HealthBarLerp = health;
	end

	-- Prepare damage values.
	local lastHealthTanks = weapon:ParseTanks(state.value);
	local healthIncrease = health > self.LastHealth || lastHealthTanks > tanks;
	local damage = WGL.DelayedLerp(self.HealthBarLerp, 50, 0.75, state, healthIncrease);
	if (healthIncrease) then self.LastHealth = health; end

	-- Render empty health bar, bar damage and health text.
	local tens, ones = weapon:AnimatedHealthText(health, 150, state);
	WGL.Rect(393, 12, 3, 32, 93, 123, 153, 255);
	WGL.Rect(400, 33, 165, 8, 45, 70, 95, 255);
	WGL.Rect(400, 33, 165 * weapon:TankRatio(damage), 8, 78, 124, 165, 255);
	WGL.TextureUV(numbersUIMaterial, 353, 12, 17, 30, u * tens, 0, u + (u * tens), v, false, 93, 123, 153, 255);
	WGL.TextureUV(numbersUIMaterial, 371, 12, 17, 30, u * ones, 0, u + (u * ones), v, false, 93, 123, 153, 255);

	-- Health bar.
	WGL.Rect(400, 33, 165 * weapon:TankRatio(self.HealthBarLerp), 8, WGL.LerpColorEvent(self.HealthBarColor, healthBarWarningColor, health, 0.75, "decrease", state):Unpack());
end

function XRayVisor:DrawAlert(alertRatio, visorOpacity)

	-- Render alert bar.
	local baseAlpha = 255 * visorOpacity;
	WGL.Rect(60, 19, 190, 8, 45, 70, 95, baseAlpha);
	WGL.Rect(60, 19, 190 * alertRatio, 8, 116, 194, 255, baseAlpha);
end

function XRayVisor:DrawMissiles(missiles, maxMissiles, visorOpacity)

	-- Render missiles bar.
	local baseAlpha = 255 * visorOpacity;
	local missileRatio = (missiles / math.Clamp(maxMissiles, 1, maxMissiles + 1));
	WGL.Rect(674, 37, 190, 8, 45, 70, 95, baseAlpha);
	WGL.Rect(674, 37, 190 * missileRatio, 8, 116, 194, 255, baseAlpha);
end

function XRayVisor:DrawHealthNotification(alpha)
	self.HealthBarColor = Color(255, 174 + 40 * alpha, 34 + 40 * alpha, 255);
	draw.SimpleText("Energy Low", "Metroid Prime Visor UI Small", 512, 132, Color(255, 174, 34, 255 * alpha), TEXT_ALIGN_CENTER);
end

function XRayVisor:HealthNotificationCallback(weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_energy");
end

function XRayVisor:DrawAlertNotification(dangerZone, alpha, visorOpacity)
	if (dangerZone) then
		draw.SimpleText("Damage",  "Metroid Prime Visor UI Small", 300, 280, Color(255, 0, 0, alpha * visorOpacity));
	else
		draw.SimpleText("Warning", "Metroid Prime Visor UI Small", 300, 280, Color(255, 174, 34, alpha * visorOpacity));
	end
end

function XRayVisor:AlertNotificationCallback(_, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "warning");
end

function XRayVisor:DrawMissileNotification(remaining, alpha, visorOpacity)
	if (remaining > 0) then
		draw.SimpleText("Missiles", "Metroid Prime Visor UI Small", 726, 268, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
		draw.SimpleText("Low",      "Metroid Prime Visor UI Small", 726, 290, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
	else
		draw.SimpleText("Depleted", "Metroid Prime Visor UI Small", 726, 280, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
	end
end

function XRayVisor:MissileNotificationCallback(_, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_missiles");
end

function XRayVisor:DrawNotifications(weapon, health, maxHealth, alertRatio, missiles, maxMissiles, visorOpacity)

	local baseAlpha = 255 * visorOpacity;

	-- Render health notification system.
	self.HealthBarColor = Color(116, 194, 255, 255);
	weapon:HealthNotification(health, maxHealth, self.DrawHealthNotification, self.HealthNotificationCallback, self, weapon);

	-- Render alert ratio.
	if (alertRatio > 0) then draw.SimpleText(math.Round(10 - (alertRatio * 10), 1), "Metroid Prime Visor UI Small", 160, 280, Color(45, 70, 95, baseAlpha)); end
	WGL.TextureRot(alertMaterial, 234, 288, 46, 26, 0, 93, 123, 153, baseAlpha);
	weapon:DangerNotification(alertRatio, 0.9, self.DrawAlertNotification, self.AlertNotificationCallback, self, visorOpacity, weapon);

	-- Render missile count.
	local r, g, b, a     = 93, 123, 153, baseAlpha;
	local fr, fg, fb, fa = WGL.LerpColorEvent(Color(45, 70, 95, baseAlpha), Color(93, 123, 153, baseAlpha), missiles, 2, "change", self.MissileLerpFont):Unpack();
	r, g, b, fr, fg, fb  = weapon:MissileComboNotification(weapon, missiles, r, g, b, fr, fg, fb);
	draw.SimpleText(missiles, "Metroid Prime Visor UI Small", 867, 280, Color(fr, fg, fb, fa), TEXT_ALIGN_RIGHT);
	WGL.TextureRot(missileMaterial, 790, 287, 32, 22, 0, r, g, b, a);
	weapon:MissileNotification(missiles, maxMissiles, self.DrawMissileNotification, self.MissileNotificationCallback, self, visorOpacity, weapon);
end

function XRayVisor:DrawReticle(weapon, fovRatio, visorOpacity)

	local nextTarget, validTarget, locked = weapon.Helmet:GetTarget(IN_SPEED);

	-- Reticle screen positioning.
	local cx        = ScrW() / 2;
	local cy        = ScrH() / 2;
	local reticleX  = cx;
	local reticleY  = cy;
	local lerp      = self.LastReticleLerp;

	-- Setup reticle screen position.
	local screenPos = self.LastReticleVector;
	if (locked) then screenPos = Vector(cx, cy, 0); end

	-- Reticle size lerp. This will be used to animate the reticle zooming in and out.
	if (!locked) then
		lerp = Lerp(FrameTime() * 10, self.LastReticleLerp, 1);
	else
		lerp = Lerp(FrameTime() * 15, self.LastReticleLerp, 0.75);
	end

	if (!validTarget && !locked) then

		-- No target found, reset everything back to the center of the screen.
		lerp      = Lerp(FrameTime() * 10, self.LastReticleLerp, 1);
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
			local targetPosLocal     = nextTarget:GetLockOnPosition():ToScreen();
			local targetPosVector    = Vector(targetPosLocal.x, targetPosLocal.y, 0);
			screenPos                = LerpVector(self.LastReticleMovement, self.LastReticleVector, targetPosVector);
			self.LastReticleMovement = Lerp(FrameTime(), self.LastReticleMovement, 1);
		end
	end

	-- Render small auto lock reticle if we are not currently targeting something.
	if (!locked) then
		reticleX = screenPos[1];
		reticleY = screenPos[2];
	else
		self.LastMouseX = 0;
		self.LastMouseY = 0;
	end

	-- Render reticle.
	local fovCompensation = 1 - fovRatio;
	WGL.TextureRot(reticleMaterial, reticleX, reticleY, WGL.Y(162 * fovCompensation), WGL.Y(162 * fovCompensation), CurTime() * -100, 165, 165, 195, 100);
	WGL.TextureRot(reticleBigMaterial, cx, cy, WGL.Y(360 * fovCompensation) * lerp, WGL.Y(360 * fovCompensation) * lerp, 0, 165, 165, 195, 50 * visorOpacity);
	WGL.TextureRot(reticleSmallMaterial, cx, cy, WGL.Y(305 * fovCompensation) * lerp, WGL.Y(305 * fovCompensation) * lerp, LocalPlayer():EyeAngles().y, 165, 165, 195, 50 * visorOpacity);

	self.LastReticleLerp   = lerp;
	self.LastReticleVector = screenPos;
	self.LastMouseX        = Lerp(FrameTime() * 10, self.LastMouseX, LocalPlayer().__mp_MouseX || 0);
	self.LastMouseY        = Lerp(FrameTime() * 10, self.LastMouseY, LocalPlayer().__mp_MouseY || 0);
end

function XRayVisor:Draw(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)

	if (!hook.Run("MP.PreDrawXRayVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)) then

		local transitionFirst = WGL.Clamp(transition + transitionStart);
		local transitionLast  = WGL.Clamp(transition);
		local health          = LocalPlayer():Health();
		local alertRatio      = weapon:GetDangerRatio();
		local maxHealth       = weapon.Helmet:GetMaxEnergy() * 100 + 99;
		local missiles        = weapon.ArmCannon:GetMissileAmmo();
		local maxMissiles     = weapon.ArmCannon:GetMissileMaxAmmo();

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPXRayVisor", 1024, 64, { ["$additive"] = 1 }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				surface.SetAlphaMultiplier(transitionLast);
				self:DrawHealth(weapon, health, maxHealth);
				self:DrawAlert(alertRatio, visorOpacity);
				self:DrawMissiles(missiles, maxMissiles, visorOpacity);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPXRayVisorMenus", 1024, 768, { ["$additive"] = 1 }, false);
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

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPXRayVisorNotifications", 1024, 768, { ["$additive"] = 1 }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				surface.SetAlphaMultiplier(transitionLast);
				self:DrawNotifications(weapon, health, maxHealth, alertRatio, missiles, maxMissiles, visorOpacity);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		WGL.Start3D(widescreen);
		cam.IgnoreZ(true);

			-- Render UI portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPXRayVisor"));
			self:DrawModel("GUI", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render UI menus portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPXRayVisorMenus"));
			self:DrawModel("GUIMenus", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render UI notifications portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPXRayVisorNotifications"));
			self:DrawModel("GUINotifs", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render the 3D static UI elements.
			render.SetColorModulation(guiColor.r, guiColor.g, guiColor.b);
			render.SetBlend(transition * visorOpacity);
			self:DrawModel("StaticGUI", guiPos, hudAngle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);

		cam.End3D();

		-- Render screen reticle.
		surface.SetAlphaMultiplier(transitionLast);
		self:DrawReticle(weapon, fovRatio, visorOpacity);
		surface.SetAlphaMultiplier(1);
	end

	hook.Run("MP.PostDrawXRayVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity);
end