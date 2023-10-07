
local CombatVisor  = WGLComponent:New(POWERSUIT, "CombatVisor");
CombatVisor.Models = {
	["GUI"]        = Model("models/metroid/hud/v_ui_context.mdl"),
	["Orbit"]      = Model("models/metroid/hud/v_orbit.mdl"),
	["StaticGUI"]  = Model("models/metroid/hud/combatvisor/v_staticgui.mdl")
};

-- Setup UV coordinates for numbers texture lookup.
local u = 20 / 340;
local v = 24 / 40;

local reticleMaterial     = Material("huds/combat/reticle");
local numbersUIMaterial   = Material("huds/numbers.png");
local missileMaterial     = Material("huds/combat/missile.png");
local alertMaterial       = Material("huds/combat/alert.png");
local arrowNoticeMaterial = Material("huds/combat/arrow_notice");
local arrowMaterial       = Material("huds/combat/arrow.png");
local arrowFlipMaterial   = Material("huds/combat/arrow_flip.png");
local bracketMaterial     = Material("huds/combat/bracket.png");
local radarMaterial       = Material("huds/combat/radar.png");
local radarDotMaterial    = Material("huds/combat/radar_dot");
local lockOuter           = Material("huds/combat/lock_outer");
local lockInner           = Material("huds/combat/lock_inner");
local lockCharge          = Material("huds/combat/charge");
local lockChargeTick      = Material("huds/combat/charge_tick");
local lockMissile         = Material("huds/combat/lock_missile");

local healthBarWarningColor = Color(227, 113, 47, 255);

function CombatVisor:Initialize()
	self.MissileLerpFont      = {};
	self.MaxRadarDistance     = 1200;
	self.LastReticleAlpha     = 0;
	self.LastReticleVector    = Vector(0, 0, 0);
	self.LastReticleMovement  = 0;
	self.LastReticleTarget    = NULL;
	self.LastReticleLerp      = 0;
	self.LastReticleLerpAlpha = 0;
	self.LastBeamOpenLerp     = 0;
end

function CombatVisor:DrawHealthNotification(alpha)
	self.HealthBarColor = Color(255, 174 + 40 * alpha, 34 + 40 * alpha, 255);
	draw.SimpleText("Energy Low", "Metroid Prime Visor UI Bold", 512, 50, Color(255, 174, 34, 255 * alpha), TEXT_ALIGN_CENTER);
end

function CombatVisor:HealthNotificationCallback(weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_energy");
end

function CombatVisor:DrawHealth(weapon)

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
			WGL.Rect(424 + (i * 18), 23, 13, 10, 45, 70, 95, 255);
		end
	end

	-- Energy tanks.
	local tanks = weapon:ParseTanks(health);
	if (tanks > -1) then
		for i = 0,tanks do
			WGL.Rect(424 + (i * 18), 23, 13, 10, 116, 194, 255, 255);
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
	WGL.Rect(412, 23, 5, 27, 93, 123, 153, 255);
	WGL.Rect(424, 40, 247, 6, 45, 70, 95, 255);
	WGL.Rect(424, 40, 247 * weapon:TankRatio(damage), 6, 78, 124, 165, 255);
	WGL.TextureUV(numbersUIMaterial, 362, 23, 20, 23, u * tens, 0, u + (u * tens), v, false, 93, 123, 153, 255);
	WGL.TextureUV(numbersUIMaterial, 383, 23, 20, 23, u * ones, 0, u + (u * ones), v, false, 93, 123, 153, 255);

	-- Render health notification system.
	self.HealthBarColor = Color(116, 194, 255, 255);
	weapon:HealthNotification(health, maxHealth, self.DrawHealthNotification, self.HealthNotificationCallback, self, weapon);

	-- Health bar.
	WGL.Rect(424, 40, 247 * weapon:TankRatio(self.HealthBarLerp), 6, WGL.LerpColorEvent(self.HealthBarColor, healthBarWarningColor, health, 0.75, "decrease", state):Unpack());
end

function CombatVisor:DrawAlertNotification(dangerZone, alpha, barOffset, visorOpacity)
	if (dangerZone) then
		draw.SimpleText("Damage",  "Metroid Prime Visor UI", 205, 128 + barOffset, Color(255, 0, 0, alpha * visorOpacity));
	else
		draw.SimpleText("Warning", "Metroid Prime Visor UI", 205, 128 + barOffset, Color(255, 174, 34, alpha * visorOpacity));
	end
end

function CombatVisor:AlertNotificationCallback(_, _, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "warning");
end

function CombatVisor:DrawAlert(weapon, visorOpacity)

	local state      = weapon.AlertState;
	local alertRatio = weapon:GetDangerRatio();
	local baseAlpha  = 255 * visorOpacity;
	local barOffset  = (143 - math.floor(143 * alertRatio));
	local baseColor  = Color(93, 123, 153, baseAlpha);
	if (alertRatio > 0.9) then baseColor = Color(227, 113, 47, baseAlpha); end

	-- Handle alert increase/decrease indicators.
	local r, g, b, a = WGL.LerpColorEvent(baseColor, Color(116, 194, 255, baseAlpha), alertRatio, 2, "change", state, function(event, fraction)
		if (event == "increase") then WGL.TextureRot(arrowNoticeMaterial, 180, 107 + barOffset, 32, 10, 0, 93, 123, 153,   Lerp(fraction, baseAlpha, 0)); end
		if (event == "decrease") then WGL.TextureRot(arrowNoticeMaterial, 180, 169 + barOffset, 32, 10, 180, 93, 123, 153, Lerp(fraction, baseAlpha, 0)); end
	end):Unpack();

	-- Render alert bar.
	WGL.Rect(132, 141, 6, 143, 45, 70, 95, baseAlpha);
	WGL.Rect(132, 141 + barOffset, 6, 143 * alertRatio, 116, 194, 255, baseAlpha);

	-- Render alert icon.
	WGL.TextureRot(bracketMaterial, 180, 118 + barOffset, 35, 12, 0,   r, g, b, a);
	WGL.TextureRot(bracketMaterial, 180, 158 + barOffset, 35, 12, 180, r, g, b, a);
	WGL.Texture(arrowFlipMaterial,  144, 131 + barOffset, 28, 16,      r, g, b, a);
	WGL.TextureRot(alertMaterial,   180, 138 + barOffset, 36, 28, 0,   r, g, b, a);
	weapon:DangerNotification(alertRatio, 0.9, self.DrawAlertNotification, self.AlertNotificationCallback, self, barOffset, visorOpacity, weapon);
end

function CombatVisor:DrawMissileNotification(remaining, alpha, barOffset, visorOpacity)
	if (remaining > 0) then
		draw.SimpleText("Missiles", "Metroid Prime Visor UI", 780, 116 + barOffset, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
		draw.SimpleText("Low",      "Metroid Prime Visor UI", 780, 136 + barOffset, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
	else
		draw.SimpleText("Depleted", "Metroid Prime Visor UI", 780, 126 + barOffset, Color(255, 174, 34, alpha * visorOpacity), TEXT_ALIGN_RIGHT);
	end
end

function CombatVisor:MissileNotificationCallback(_, _, weapon)
	WSL.PlaySoundPatch(weapon.Visors, "low_missiles");
end

function CombatVisor:DrawMissiles(weapon, visorOpacity)

	local state        = weapon.MissileState;
	local missiles     = weapon.ArmCannon:GetMissileAmmo();
	local maxMissiles  = weapon.ArmCannon:GetMissileMaxAmmo();
	local baseAlpha    = 255 * visorOpacity;
	local missileRatio = (missiles / math.Clamp(maxMissiles, 1, maxMissiles + 1));
	local barOffset    = (143 - math.floor(143 * missileRatio));
	local huns         = math.floor(missiles / 100);
	local tens         = math.floor(missiles % 100 / 10);
	local ones         = math.floor(missiles % 100 - (tens * 10));
	local fontPos      = 130 + barOffset;
	local r, g, b, a   = WGL.LerpColorEvent(Color(93, 123, 153, baseAlpha), Color(116, 194, 255, baseAlpha), missiles, 2, "change", state):Unpack();

	-- Render missile increase/decrease indicators.
	local fr, fg, fb, fa = WGL.LerpColorEvent(Color(45, 70, 95, baseAlpha),   Color(93, 123, 153, baseAlpha),  missiles, 2, "change", self.MissileLerpFont, function(event, fraction)
		if (event == "increase") then WGL.TextureRot(arrowNoticeMaterial, 842, 107 + barOffset, 32, 10, 0, 93, 123, 153,   Lerp(fraction, baseAlpha, 0)); end
		if (event == "decrease") then WGL.TextureRot(arrowNoticeMaterial, 842, 169 + barOffset, 32, 10, 180, 93, 123, 153, Lerp(fraction, baseAlpha, 0)); end
	end):Unpack();

	-- Missile combo notification will lerp the indicator colors to red if there are insufficient missiles while charging for missile combo.
	r, g, b, fr, fg, fb = weapon:MissileComboNotification(weapon, missiles, r, g, b, fr, fg, fb);

	-- Render missile bar.
	WGL.Rect(886, 141, 6, 143, 45, 70, 95, baseAlpha);
	WGL.Rect(886, 141 + barOffset, 6, 143 * missileRatio, 116, 194, 255, baseAlpha);

	-- Render missile icon.
	WGL.TextureRot(bracketMaterial, 842, 118 + barOffset, 35, 12, 0,   r, g, b, a);
	WGL.TextureRot(bracketMaterial, 842, 158 + barOffset, 35, 12, 180, r, g, b, a);
	WGL.Texture(arrowMaterial,      851, 131 + barOffset, 28, 16,      r, g, b, a);
	WGL.TextureRot(missileMaterial, 843, 138 + barOffset, 36, 28, 0,   r, g, b, a);

	-- Render missile count and notifications.
	if (missiles > 99) then WGL.TextureUV(numbersUIMaterial, 765, fontPos, 19, 15, u * huns, 0, u + (u * huns), v, false, fr, fg, fb, fa); end
	if (missiles > 9)  then WGL.TextureUV(numbersUIMaterial, 784, fontPos, 19, 15, u * tens, 0, u + (u * tens), v, false, fr, fg, fb, fa); end
	WGL.TextureUV(numbersUIMaterial, 803, fontPos, 19, 15, u * ones, 0, u + (u * ones), v, false, fr, fg, fb, fa);
	weapon:MissileNotification(missiles, maxMissiles, self.DrawMissileNotification, self.MissileNotificationCallback, self, barOffset, visorOpacity, weapon);
end

function CombatVisor:DrawRadarTarget(target)

	-- Draw central dot if target is LocalPlayer.
	if (target == LocalPlayer()) then return WGL.Texture(radarDotMaterial, 29, 29, 6, 6, 93, 123, 153, 100); end

	local targetPos   = target:GetPos();
	local maxDistance = self.MaxRadarDistance;
	local diff        = targetPos - LocalPlayer():GetPos();
	if (diff:LengthSqr() > (maxDistance * maxDistance)) then return; end

	-- Convert target world space to screen space and scale by radar size.
	local aim = LocalPlayer():GetAngles():Forward();
	local px  = (diff[1] / maxDistance);
	local py  = (diff[2] / maxDistance);
	local z   = math.sqrt(px * px + py * py);
	local phi = math.rad(math.deg(math.atan2(px, py)) - math.deg(math.atan2(aim[1], aim[2])) - 90);
	local cos = math.cos(phi) * z;
	local sin = math.sin(phi) * z;
	WGL.Texture(radarDotMaterial, 32 + cos * 60 / 2 - 2, 32 + sin * 60 / 2 - 2, 6, 6, 206, 146, 93, 255);
end

function CombatVisor:DrawRadar()

	-- Offload radar rendering to a new texture.
	self:PushRenderTexture("rt_MPRadar", 64, 64, { ["$additive"] = 1 }, false);
		cam.Start2D();

			-- Draw radar.
			render.ClearDepth();
			render.Clear(0, 0, 0, 0);
			render.SetColorModulation(1, 1, 1);
			WGL.Texture(radarMaterial, 0, 0, 64, 64, 93, 123, 153, 255);

			-- Draw radar targets.
			local players = player.GetAll();
			local npcs    = ents.FindByClass("*npc*");
			for k,_v in ipairs(players) do self:DrawRadarTarget(_v); end
			for k,_v in ipairs(npcs)    do self:DrawRadarTarget(_v); end

		cam.End2D();
	render.PopRenderTarget();

	-- Render radar.
	WGL.Texture(self:GetRenderTexture("rt_MPRadar"), 145, 45, 90, 65, 93, 123, 153, 255);
end

function CombatVisor:DrawReticle(weapon, target, validTarget, locked, fovRatio)

	local charge     = weapon.ArmCannon:GetChargeRatio();
	local beamOpen   = weapon.ArmCannon:IsBeamBusy();

	-- Reticle screen positioning.
	local cx         = ScrW() / 2;
	local cy         = ScrH() / 2;
	local reticleX   = cx;
	local reticleY   = cy;
	local screenPos  = self.LastReticleVector;
	if (locked) then screenPos = Vector(cx, cy, 0); end

	-- Reticle alpha, this will modulate the auto lock and charge reticle.
	local alpha      = 255;
	local lerp       = self.LastReticleLerp;
	local lerpAlpha  = self.LastReticleLerpAlpha;
	local missile    = self.LastBeamOpenLerp;

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
		screenPos = LerpVector(FrameTime() * 10, self.LastReticleVector, Vector(cx, cy, 0));
		self.LastReticleTarget = NULL;
	else

		-- Best target swapped, reset animations and last target reference.
		if (self.LastReticleTarget != target) then
			self.LastReticleTarget   = target;
			self.LastReticleMovement = 0;
		end

		-- Last reticle movement is compounded every frame onto the screen position
		-- interpolation giving the snapping effect to each target.
		if (self.LastReticleMovement < 1 && validTarget) then
			local targetPosLocal     = target:GetLockOnPosition():ToScreen();
			local targetPosVector    = Vector(targetPosLocal.x, targetPosLocal.y, 0);
			alpha                    = Lerp(FrameTime() * 10, self.LastReticleAlpha, 255);
			screenPos                = LerpVector(self.LastReticleMovement, self.LastReticleVector, targetPosVector);
			self.LastReticleMovement = Lerp(FrameTime(), self.LastReticleMovement, 1);
		end
	end

	-- Render small auto lock reticle if we are not currently targeting something.
	if (!locked) then
		reticleX = screenPos[1];
		reticleY = screenPos[2];
	else
		alpha = math.abs((lerpAlpha / 255) - 1) * 255;
	end

	-- Charge tick indicator.
	local chargeFull = 0;
	local chargeTick = math.Round(charge * 14);
	if (charge == 1) then chargeFull = (math.sin(CurTime() * 8) + 1) / 2; end

	if (beamOpen) then missile = Lerp(FrameTime() * 5, self.LastBeamOpenLerp, 1);
	else missile = Lerp(FrameTime() * 5, self.LastBeamOpenLerp, 0); end

	-- Render reticle.
	local fovCompensation = 1 - fovRatio;
	WGL.TextureRot(reticleMaterial, screenPos[1], screenPos[2], WGL.Y(162 * fovCompensation), WGL.Y(162 * fovCompensation), CurTime() * 100, 45, 70, 95, alpha);
	WGL.TextureRot(lockOuter,   reticleX, reticleY, WGL.Y(256 * fovCompensation) * lerp, WGL.Y(256 * fovCompensation) * lerp, CurTime() * 125, 93, 123, 153, lerpAlpha);
	WGL.TextureRot(lockInner,   reticleX, reticleY, WGL.Y(256 * fovCompensation) * lerp, WGL.Y(256 * fovCompensation) * lerp, CurTime() * -125, 116, 194, 255, lerpAlpha);
	WGL.TextureRot(lockCharge,  reticleX, reticleY, WGL.Y(290 * fovCompensation) * lerp, WGL.Y(290 * fovCompensation) * lerp, 0, WGL.LerpColor(chargeFull, Color(93, 123, 153, lerpAlpha), Color(116, 194, 255, lerpAlpha)):Unpack());
	WGL.TextureRot(lockMissile, reticleX, reticleY, WGL.Y(330 * fovCompensation) * lerp * missile, WGL.Y(330 * fovCompensation) * lerp * missile, 0, 255, 160, 0, lerpAlpha);
	WGL.TextureRot(lockMissile, reticleX, reticleY, WGL.Y(330 * fovCompensation) * lerp * missile, WGL.Y(330 * fovCompensation) * lerp * missile, 90, 255, 160, 0, lerpAlpha);

	-- Render reticle charge ticks.
	local r, g, b, a = WGL.LerpColor(chargeFull, Color(45, 70, 95, lerpAlpha), Color(100, 130, 160, lerpAlpha)):Unpack()
	local tickSize   = WGL.Y(290 * fovCompensation) * lerp;
	for i = 1, chargeTick do
		WGL.TextureRot(lockChargeTick, reticleX, reticleY, tickSize, tickSize, (i - 1) * 9, r, g, b, a);
	end

	self.LastReticleLerp      = lerp;
	self.LastReticleAlpha     = alpha;
	self.LastBeamOpenLerp     = missile;
	self.LastReticleVector    = screenPos;
	self.LastReticleLerpAlpha = lerpAlpha;
end

function CombatVisor:Draw(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)

	if (!hook.Run("MP.PreDrawCombatVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)) then

		local transitionFirst = WGL.Clamp(transition + transitionStart);
		local transitionLast  = WGL.Clamp(transition);
		local target, validTarget, locked = weapon.Helmet:GetTarget(IN_SPEED);

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPCombatVisor", 1024, 768, { ["$additive"] = 1 }, false);
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

				surface.SetAlphaMultiplier(transitionLast);
				self:DrawRadar();
				self:DrawHealth(weapon);
				self:DrawAlert(weapon, visorOpacity);
				self:DrawMissiles(weapon, visorOpacity);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		WGL.Start3D(widescreen);
		cam.IgnoreZ(true);

			-- Render UI portion of the GUI onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPCombatVisor"));
			self:DrawModel("GUI", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render the 3D static UI elements.
			render.SetColorModulation(guiColor.r, guiColor.g, guiColor.b);
			render.SetBlend(transition * visorOpacity);
			if (!locked) then
				local aimTrace = util.QuickTrace(EyePos(), EyeAngles():Forward() * 300, LocalPlayer());
				self:DrawModel("Orbit", aimTrace.HitPos, Angle(0, 0, 0), 3);
			end
			self:DrawModel("StaticGUI", guiPos, hudAngle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);

		cam.End3D();

		-- Render screen reticle.
		surface.SetAlphaMultiplier(transitionLast);
		self:DrawReticle(weapon, target, validTarget, locked, fovRatio);
		surface.SetAlphaMultiplier(1);
	end

	hook.Run("MP.PostDrawCombatVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity);
end