
local ScanVisor   = WGLComponent:New(POWERSUIT, "ScanVisor");
ScanVisor.Models  = {
	["GUI"]       = Model("models/metroid/hud/v_ui_context.mdl"),
	["StaticGUI"] = Model("models/metroid/hud/scanvisor/v_staticgui.mdl")
};

local linesMaterial         = Material("huds/scan/line");
local reticleMaterial       = Material("huds/scan/reticle");
local topMaterial           = Material("huds/scan/top.png");
local sideMaterial          = Material("huds/scan/side.png");
local cornerMaterial        = Material("huds/scan/corner.png");
local descriptionMaterial   = Material("huds/scan/description");
local endParagraphMaterial  = Material("huds/scan/endparagraph");
local nextParagraphMaterial = Material("huds/scan/nextparagraph");

local paragraphTextColor = Color(97, 139, 159, 255);

function ScanVisor:Initialize()

	-- Log book references for rendering.
	self.LogBook              = {};
	self.LogBookText          = nil;
	self.LogBookEntity        = NULL;
	self.LogBookDuration      = 1.33;
	self.CurrentParagraph     = 1;

	-- Scan states and flags.
	self.ScanTime             = 0;
	self.ScanDelay            = 0.186;
	self.ScanStart            = nil;
	self.ScanFinish           = nil;
	self.ScanDuration         = 1.33;
	self.ScanComplete         = false;
	self.ScanCompleteTime     = 0;
	self.ScanRaised           = false;
	self.ScanLowered          = false;

	-- Rendering interpolations.
	self.MenuLerp             = 1;
	self.ReticleLerp          = 0;
	self.LastLogLerp          = 0;
	self.LastScanLerp         = 0;
	self.LastMenuLerp         = 1;
	self.LastCompleteLerp     = 0;
	self.LastReticleAlpha     = 0;
	self.LastReticleVector    = Vector(0, 0, 0);
	self.LastReticleMovement  = 0;
	self.LastReticleTarget    = NULL;
	self.LastReticleLerp      = 0;
	self.LastReticleLerpAlpha = 0;
end

function ScanVisor:ResetScan()
	self.ScanTime     = 0;
	self.ScanStart    = nil;
	self.ScanRaised   = false;
	self.ScanComplete = false;
end

function ScanVisor:ResetLogBook()
	self.LogBook          = nil;
	self.LogBookText      = nil;
	self.LogBookEntity    = NULL;
	self.CurrentParagraph = 1;
end

function ScanVisor:HandleLogBook(weapon, currentTarget)

	local logBook        = currentTarget.LogBook || {};
	self.LogBookDuration = logBook.ScanDuration || self.ScanDuration;

	-- Do nothing if we are still scanning the entity.
	if (self.ScanComplete || self.ScanTime < self.LogBookDuration) then return; end

	-- Log book acquired, stop scanning sound and set default info.
	self.ScanComplete = true;
	WSL.PlaySoundPatch(weapon.Visors, "scan_complete");
	WSL.StopSound(weapon.Visors, "scanning");

	-- Set current logbook reference to the scanned entity.
	-- Process entity description into current logbook text container.
	self.LogBook       = logBook;
	self.LogBookText   = WGL.FitText(self.LogBook.Description, "Metroid Prime LogBook", 505, 128, 30) || { { "No information found." } };
	self.LogBookEntity = currentTarget;

	-- Raise serverside event upon scan completion.
	net.Start("POWERSUIT.ScanCompleted");
		net.WriteEntity(weapon);
		net.WriteEntity(currentTarget);
	net.SendToServer();
	hook.Run("MP.OnScanCompleted", weapon, currentTarget);
end

function ScanVisor:StartScan(weapon)

	-- Anti spam.
	if (CurTime() - (self.ScanFinish || 0) < self.ScanDelay) then return; end

	-- Begin scan loop.
	self.MenuLerp = 0;
	if (self.ScanStart == nil) then
		self:ResetLogBook();
		self.ScanStart = CurTime();
		self.ScanLowered = false;
		WSL.PlaySoundPatch(weapon.Visors, "scan_start");
		WSL.PlaySoundPatch(weapon.Visors, "scanning");
	end

	-- Raise scan.
	if (CurTime() - self.ScanStart > self.ScanDelay && !self.ScanRaised) then
		WSL.PlaySoundPatch(weapon.Visors, "scan_raise");
		self.ScanRaised = true;
	end

	-- Scan completion states.
	if (self.ScanComplete) then
		self.ScanCompleteTime = CurTime() + 0.23;
	else
		self.ScanTime = math.Clamp(CurTime() - self.ScanStart, 0, self.LogBookDuration);
	end
end

function ScanVisor:StopScan(weapon)

	-- Anti spam.
	if (CurTime() - (self.ScanStart || 0) < self.ScanDelay / 2) then return; end

	-- Stop scan loop.
	self.MenuLerp = 1;
	if (self.ScanStart != nil) then
		self:ResetScan();
		self.ScanFinish = CurTime();
		WSL.PlaySoundPatch(weapon.Visors, "scan_lower");
		WSL.StopSound(weapon.Visors, "scanning");
	end

	-- Lower scan.
	if (CurTime() - self.ScanCompleteTime + self.ScanDelay > self.ScanDelay && !self.ScanLowered && self.ScanFinish != nil) then
		WSL.PlaySoundPatch(weapon.Visors, "scan_end");
		self.ScanLowered = true;
	end
end

function ScanVisor:HandleScanning(weapon, transition)

	-- Update logbook with current target
	local currentTarget, targetValid, lockedOn = weapon.Helmet:GetTarget(IN_SPEED);
	self:HandleLogBook(weapon, currentTarget);

	-- Handle scan state transitions.
	if (lockedOn && transition == 1) then
		self:StartScan(weapon);
	else
		self:StopScan(weapon);
	end

	-- Update completion lerp, this will be used for pane rendering.
	if (self.ScanComplete) then
		self.LastCompleteLerp = Lerp(FrameTime() * 2, self.LastCompleteLerp, 1);
	else
		self.LastCompleteLerp = Lerp(FrameTime() * 5, self.LastCompleteLerp, 0);
	end

	-- Delay reticle reset when completing a scan.
	if (CurTime() > self.ScanCompleteTime) then
		self.LastScanLerp = Lerp(FrameTime() * 9, self.LastScanLerp, 1 - self.MenuLerp);
	end

	-- Update reticle and menu lerp. Return current target data for reticle rendering.
	self.LastLogLerp  = Lerp(FrameTime() * 9,  self.LastLogLerp, 1 - self.MenuLerp);
	self.ReticleLerp  = Lerp(FrameTime() * 15, self.ReticleLerp, transition);
	self.LastMenuLerp = Lerp(FrameTime() * 10, self.LastMenuLerp, self.MenuLerp * 1.3);
	return currentTarget, targetValid;
end

function ScanVisor:DrawLeftPane(image, x, alpha, widescreen)
	WGL.Perspective(widescreen, -70, _, function()
		WGL.Texture(image, x + -610, -122, 135, 240, 150, 150, 150, alpha)
	end);
end

function ScanVisor:DrawRightPane(image, x, alpha, widescreen)
	WGL.Perspective(widescreen, 70, _, function()
		WGL.Texture(image, x + 473, -122, 135, 240, 150, 150, 150, alpha)
	end);
end

function ScanVisor:DrawInfoPane(weapon, x)

	-- Render text to a fixed size render target in order to be compatible with all resolutions.
	self:PushRenderTexture("rt_MPScanDescription", 512, 256, { ["$additive"] = 1, ["$vertexalpha"] = 1, ["$vertexcolor"] = 1 }, false);
		cam.Start2D();

			render.ClearDepth();
			render.Clear(0, 0, 0, 0);
			render.SetColorModulation(1, 1, 1);

			if (self.LogBookText != nil) then

				-- Begin iterating paragraphs when pressing secondary attack.
				local paragraphs = #self.LogBookText;
				if (self.ScanComplete && LocalPlayer():KeyPressed(IN_ATTACK2) && self.CurrentParagraph != paragraphs) then
					self.CurrentParagraph = self.CurrentParagraph + 1;
					WSL.PlaySoundPatch(weapon.Visors, "scan_paragraph");
				end

				-- Render paragraph lines.
				WGL.Paragraph(self.LogBookText[self.CurrentParagraph], "Metroid Prime LogBook", 0, 0, 30, paragraphTextColor);

				-- Render end of log book and next paragraph icons.
				if (paragraphs <= 1 || self.CurrentParagraph == paragraphs) then
					WGL.Texture(endParagraphMaterial,  228, 140, 39, 42, 136, 214, 255, 255);
				else
					WGL.Texture(nextParagraphMaterial, 228, 140, 39, 40, 136, 214, 255, 255);
				end
			end

		cam.End2D();
	render.PopRenderTarget();

	-- Draw description area.
	local descriptionWidth = WGL.Y(540);
	WGL.Texture(self:GetRenderTexture("rt_MPScanDescription"), x - WGL.Y(248), WGL.Y(560), WGL.Y(512), WGL.Y(256), 255, 255, 255, self.LastLogLerp * 255);
	WGL.Texture(descriptionMaterial, x - descriptionWidth / 2, descriptionWidth, descriptionWidth, WGL.Y(256),     150, 150, 150, self.LastLogLerp * 255);
end

function ScanVisor:DrawCrosshair(nextTarget, nextTargetValid, scanFOV, viewFOV)

	-- Reticle screen positioning.
	local w         = ScrW();
	local h         = ScrH();
	local cx        = w / 2;
	local cy        = h / 2;
	local screenPos = self.LastReticleVector;
	if (nextTargetValid) then screenPos = Vector(cx, cy, 0); end

	-- Reticle alpha, this will modulate the auto lock and charge reticle.
	local alpha     = 255;
	local lerp      = self.LastReticleLerp;
	local lerpAlpha = self.LastReticleLerpAlpha;

	-- Reticle size lerp. This will be used to animate the reticle zooming in and out.
	if (!nextTargetValid) then
		lerp      = Lerp(FrameTime() * 2, self.LastReticleLerp, 10);
		lerpAlpha = Lerp(FrameTime() * 20, self.LastReticleLerpAlpha, 0);
	else
		lerp      = Lerp(FrameTime() * 20, self.LastReticleLerp, 1);
		lerpAlpha = Lerp(FrameTime() * 5, self.LastReticleLerpAlpha, 255);
	end

	if (!nextTargetValid) then

		-- No target found, reset everything back to the center of the screen.
		lerp      = Lerp(FrameTime(), self.LastReticleLerp, 100);
		alpha     = Lerp(FrameTime() * 10, self.LastReticleAlpha, 0);
		screenPos = LerpVector(FrameTime() * 10, self.LastReticleVector, Vector(cx, cy, 0));
		self.LastReticleTarget = NULL;
	else

		-- Best target swapped, reset animations and last target reference.
		if (self.LastReticleTarget != nextTarget) then
			self.LastReticleTarget   = nextTarget;
			self.LastReticleMovement = 0;
		end

		-- Last reticle movement is compounded every frame onto the screen position
		-- interpolation giving the snapping effect to each target.
		if (self.LastReticleMovement < 1 && nextTargetValid) then
			local targetPosLocal     = WGL.ToScreenFOV(nextTarget:GetLockOnPosition(), scanFOV, viewFOV, w, h);
			local targetPosVector    = Vector(targetPosLocal.x, targetPosLocal.y, 0);
			alpha                    = Lerp(FrameTime() * 10, self.LastReticleAlpha, 255);
			screenPos                = LerpVector(self.LastReticleMovement, self.LastReticleVector, targetPosVector);
			self.LastReticleMovement = Lerp(FrameTime() / 2, self.LastReticleMovement, 1);
		end
	end

	local reticleX     = screenPos[1];
	local reticleY     = screenPos[2];
	local reticleSize  = WGL.Y(41) * lerp;
	local halfRetSize  = reticleSize / 2;
	local reticleWidth = WGL.Y(4);
	local lineX        = reticleX - reticleWidth / 2;
	local lineY        = reticleY - reticleWidth / 2;
	WGL.TextureRot(reticleMaterial, reticleX, reticleY, reticleSize, reticleSize, 0, 255, 255, 255, lerpAlpha);
	WGL.Texture(linesMaterial, 0, lineY, reticleX - halfRetSize, reticleWidth, 255, 255, 255, lerpAlpha);
	WGL.Texture(linesMaterial, reticleX + halfRetSize, lineY, w, reticleWidth, 255, 255, 255, lerpAlpha);
	WGL.Texture(linesMaterial, lineX, 0, reticleWidth, reticleY - halfRetSize, 255, 255, 255, lerpAlpha);
	WGL.Texture(linesMaterial, lineX, reticleY + halfRetSize, reticleWidth, h, 255, 255, 255, lerpAlpha);

	if (nextTargetValid) then alpha = math.abs((lerpAlpha / 255) - 1) * 255; end
	self.LastReticleLerp      = lerp;
	self.LastReticleAlpha     = alpha;
	self.LastReticleVector    = screenPos;
	self.LastReticleLerpAlpha = lerpAlpha;
end

function ScanVisor:DrawReticle(weapon, nextTarget, nextTargetValid, w, h, transition, transitionLast, widescreen)

	local scrW    = ScrW();
	local scrH    = ScrH();
	local scrW2   = scrW / 2;
	local scrH2   = scrH / 2;
	local viewFOV = WGL.GetViewFOV(LocalPlayer():GetFOV(), scrW, scrH);
	local scanFOV = viewFOV - (viewFOV * 0.15 * transition);
	self:PushRenderTexture("rt_MPScanReticle", scrW, scrH, { ["$translucent"] = 1, ["$vertexalpha"] = 1, ["$vertexcolor"] = 1 }, true);
		cam.Start2D();

			render.ClearDepth();
			render.Clear(0, 0, 0, 0);
			render.SetColorModulation(1, 1, 1);

			-- Draw world into texture for UV effects.
			-- Raise flag to also render scan points during render view pass.
			weapon.RenderScanPoints = true;
			render.RenderView({
				origin = EyePos(),
				angles = EyeAngles(),
				x = 0, y = 0,
				w = scrW, h = scrH,
				fov = scanFOV,
				drawviewmodel = false
			});
			weapon.RenderScanPoints = false;

			-- Render scan crosshair and finish with postprocessing.
			self:DrawCrosshair(nextTarget, nextTargetValid, scanFOV, viewFOV);
			hook.Call("RenderScreenspaceEffects");
		cam.End2D();
	render.PopRenderTarget();

	-- Dim the whole scene.
	WGL.Rect(0, 0, scrW, scrH, 0, 0, 0, self.LastCompleteLerp * 200);
	WGL.Rect(0, 0, scrW, scrH, 0, 0, 0, transition * 125);

	-- Perform scene clipping of render texture.
	local u1, v1 = (scrW2 - w / 2) / scrW, (scrH2 - h / 2) / scrH;
	local u2, v2 = (scrW2 + w / 2) / scrW, (scrH2 + h / 2) / scrH;
	local x, y   = WGL.TextureUV(self:GetRenderTexture("rt_MPScanReticle"), scrW2, scrH2, w, h, u1, v1, u2, v2, true, 255, 255, 255, 255);

	-- Draw border.
	surface.SetDrawColor(55, 86, 102, 255 * transitionLast);
	surface.DrawOutlinedRect(x, y, w, h, WGL.Y(2));

	-- Draw corners.
	local cornerSize = WGL.Y(108);
	WGL.TextureRot(cornerMaterial, x, y, cornerSize, cornerSize,           0, 255, 255, 255, 255);
	WGL.TextureRot(cornerMaterial, x, y + h, cornerSize, cornerSize,      90, 255, 255, 255, 255);
	WGL.TextureRot(cornerMaterial, x + w, y + h, cornerSize, cornerSize, 180, 255, 255, 255, 255);
	WGL.TextureRot(cornerMaterial, x + w, y, cornerSize, cornerSize,     270, 255, 255, 255, 255);

	-- Draw reticle sides.
	local sideSize = WGL.Y(24);
	WGL.TextureRot(sideMaterial, x, y + h / 2, sideSize, sideSize,       0, 255, 255, 255, 255);
	WGL.TextureRot(sideMaterial, x + w, y + h / 2, sideSize, sideSize, 180, 255, 255, 255, 255);

	-- Draw reticle top and bottom.
	local topSize = WGL.Y(47);
	WGL.TextureRot(topMaterial, x + w / 2, y, topSize, topSize,       0, 255, 255, 255, 255);
	WGL.TextureRot(topMaterial, x + w / 2, y + h, topSize, topSize, 180, 255, 255, 255, 255);

	-- Draw scan progression bar.
	local scanWidth = WGL.Y(188);
	local scanProgress = self.ScanTime / self.LogBookDuration;
	WGL.Rect(scrW2 - scanWidth / 2, WGL.Y(524), scanWidth * scanProgress, WGL.Y(8), 136, 214, 255, self.LastScanLerp * 255);

	-- Render info pane.
	self:DrawInfoPane(weapon, scrW2);

	-- Render panes.
	if (nextTargetValid && self.LogBookEntity == nextTarget && self.LogBook != nil) then

		local panePos   = widescreen && 180 || WGL.X(180);
		local paneLerp  = (1 - WGL.Clamp(self.LastCompleteLerp * 1.5));
		local paneAlpha = WGL.Clamp(self.LastCompleteLerp * 1.5) * 255;

		-- Render left pane.
		local leftPane = self.LogBook.Left;
		if (leftPane != nil) then self:DrawLeftPane(leftPane, -panePos * paneLerp, paneAlpha, widescreen); end

		-- Render right pane.
		local rightPane = self.LogBook.Right;
		if (rightPane != nil) then self:DrawRightPane(rightPane, panePos * paneLerp, paneAlpha, widescreen); end
	end
end

function ScanVisor:Draw(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)

	if (!hook.Run("MP.PreDrawScanVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)) then

		local transitionFirst = WGL.Clamp(transition + transitionStart);
		local transitionLast  = WGL.Clamp(transition);

		local nextTarget, nextTargetValid = self:HandleScanning(weapon, transitionLast);
		local reticleWidth  = WGL.Y(583) - WGL.Y(263) * self.LastScanLerp;
		local reticleHeight = WGL.Y(212) + WGL.Y(80)  * self.LastScanLerp;

		surface.SetAlphaMultiplier(self.ReticleLerp);
		self:DrawReticle(weapon, nextTarget, nextTargetValid, reticleWidth, reticleHeight, self.ReticleLerp, transitionLast, widescreen);
		surface.SetAlphaMultiplier(1);

		-- Offload hud rendering operations to a separate render target.
		self:PushRenderTexture("rt_MPScanVisor", 1024, 768, { ["$additive"] = 1 }, false);
			cam.Start2D();

				render.ClearDepth();
				render.Clear(0, 0, 0, 0);
				render.SetColorModulation(1, 1, 1);

				surface.SetAlphaMultiplier(transitionFirst * visorOpacity);
				local beamMenu  = WGL.GetComponent(weapon, "BeamMenu");
				local visorMenu = WGL.GetComponent(weapon, "VisorMenu");
				beamMenu:DrawText(beam);
				visorMenu:DrawText(visor);
				beamMenu:OverrideBlend(self.LastMenuLerp);
				visorMenu:OverrideBlend(self.LastMenuLerp);
				surface.SetAlphaMultiplier(1);

				surface.SetAlphaMultiplier(transitionLast);
				WGL.GetComponent(weapon, "CombatVisor"):DrawHealth(weapon);
				surface.SetAlphaMultiplier(1);

			cam.End2D();
		render.PopRenderTarget();

		WGL.Start3D(widescreen);
		cam.IgnoreZ(true);

			-- Render UI portion of the hud onto the curved visor.
			render.MaterialOverride(self:GetRenderTexture("rt_MPScanVisor"));
			self:DrawModel("GUI", hudPos, hudAngle);
			render.MaterialOverride(nil);

			-- Render the 3D static UI elements.
			render.SetColorModulation(guiColor.r, guiColor.g, guiColor.b);
			render.SetBlend(transition * visorOpacity);
			self:DrawModel("StaticGUI", guiPos, hudAngle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);

		cam.End3D();
	end

	hook.Run("MP.PostDrawScanVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity);
end