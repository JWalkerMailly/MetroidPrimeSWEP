
local PowerSuitHUD         = WGLComponent:New(POWERSUIT, "PowerSuitHUD");
PowerSuitHUD.CurrentVisor  = nil;
PowerSuitHUD.PreviousVisor = nil;
PowerSuitHUD.Transition    = 0;
PowerSuitHUD.FromMorphBall = false;
PowerSuitHUD.LastAngleLag  = EyeAngles();
PowerSuitHUD.LastVisorLag  = EyeAngles();
PowerSuitHUD.LagRate       = 7;
PowerSuitHUD.VisorRate     = 11;
PowerSuitHUD.MorphBallRate = 15;
PowerSuitHUD.ScanLines     = Material("huds/transition.png");

function PowerSuitHUD:Reset(weapon, resetTransition)

	if (self.CurrentVisor == nil) then return; end
	if (resetTransition) then self.Transition = 0; end
	WGL.GetComponent(weapon, "BeamMenu"):Initialize();
	WGL.GetComponent(weapon, "VisorMenu"):Initialize();
	WGL.GetComponent(weapon, weapon.Visors[self.CurrentVisor].Hud):Initialize();
	WGL.GetComponent(weapon, weapon.Visors[self.PreviousVisor].Hud):Initialize();
	self.PreviousVisor = nil;
	self.CurrentVisor = nil;
end

function PowerSuitHUD:Draw(weapon, damage)

	-- PowerSuit HUD rendering only if we are not in MorphBall to save performance.
	if (IsValid(weapon:GetMorphBall())) then
		self.FromMorphBall = true;
		self.Transition    = -self.MorphBallRate;
		self.LastAngleLag  = EyeAngles();
		self.LastVisorLag  = EyeAngles();
		self:Reset(weapon);
		return;
	end

	if (self.CurrentVisor == nil) then
		self.CurrentVisor  = weapon.Helmet:GetVisor();
		self.PreviousVisor = self.CurrentVisor;
		self.LastAngleLag  = EyeAngles();
		self.LastVisorLag  = EyeAngles();
	end

	-- Statemachine data.
	local beamData     = weapon:GetBeam();
	local visorData    = weapon:GetVisor();
	local currentVisor = weapon.Helmet:GetVisor();

	local widescreen   = GetConVar("mp_options_widescreenfix"):GetBool();
	local visorOpacity = GetConVar("mp_options_visoropacity"):GetInt() / 100;
	local helmOpacity  = GetConVar("mp_options_helmetopacity"):GetInt() / 100;
	local hudLag       = GetConVar("mp_options_hudlag"):GetBool() && !weapon.PowerSuit:IsGrappling();
	local faceReflect  = GetConVar("mp_options_facereflection"):GetBool() && visorData.ShouldReflectFace;

	-- Visor lag variables.
	local eyePos       = EyePos();
	local eyeAngles    = EyeAngles();
	local frameTime    = FrameTime();
	local hudAngle     = LerpAngle(frameTime * self.LagRate, WGL.ClampAngle(self.LastAngleLag, eyeAngles, 2.3, 1.8, 0.8, frameTime), eyeAngles);
	local visorAngle   = LerpAngle(frameTime * self.LagRate, WGL.ClampAngle(self.LastVisorLag, eyeAngles, 3.3, 1.8, 0.8, frameTime), eyeAngles);
	self.LastAngleLag  = hudAngle;
	self.LastVisorLag  = visorAngle;

	-- Visor lag on/off.
	hudAngle           = !hudLag && eyeAngles || WGL.ClampAngle(hudAngle, eyeAngles, 2, 1.5, 0.5, frameTime);
	visorAngle         = !hudLag && eyeAngles || WGL.ClampAngle(visorAngle, eyeAngles, 3, 1.5, 0.5, frameTime);

	-- Visor angle variables.
	local visorUp      = visorAngle:Up();
	local visorRight   = visorAngle:Right();
	local visorForward = visorAngle:Forward();

	-- Visor position variables.
	local fov          = LocalPlayer():GetFOV();
	local fovRatio     = 1 - (75 / fov);
	local hudPos       = eyePos + hudAngle:Forward() * (12 - fovRatio * 23);
	local visorPos     = eyePos + visorForward * (12 - fovRatio * 23);
	local guiPos       = visorPos;
	local guiColor     = Color(visorData.GuiColor.r, visorData.GuiColor.g, visorData.GuiColor.b);

	-- Handle transition states for morphball and visor change. If we are transitioning from
	-- the morphball, reset all visor states to default to avoid animation overlaps. If we
	-- are not transitioning from morphball but we are switching visors, use visor transitions.
	if (!self.FromMorphBall) then
		if (self.CurrentVisor != currentVisor) then
			self.PreviousVisor = self.CurrentVisor;
			self.CurrentVisor  = currentVisor;
			self.Transition    = -self.VisorRate;
		end
	else
		self.CurrentVisor  = currentVisor;
		self.PreviousVisor = currentVisor;
		WGL.GetComponent(weapon, "VisorMenu").Current  = currentVisor;
		WGL.GetComponent(weapon, "VisorMenu").Previous = currentVisor;
	end

	-- Transition interpolation.
	if (self.Transition < 1) then
		self.Transition = math.Clamp(self.Transition + frameTime * self.MorphBallRate, -self.MorphBallRate, 1);
	else
		self.FromMorphBall = false;
	end

	-- Prevent gui color overlap when switching visors if colors differ.
	if (self.Transition < 0) then
		local previousVisor = weapon.Visors[self.PreviousVisor];
		guiColor = Color(previousVisor.GuiColor.r, previousVisor.GuiColor.g, previousVisor.GuiColor.b);
	end

	-- Handle static GUI shake and color lerp upon taking damage.
	if (damage > 0) then
		guiColor = WGL.LerpColor(WGL.Clamp(damage), guiColor, Color(0.89, 0.44, 0.18));
		guiPos = guiPos + Vector(WGL.Modulation(9, 500) * damage, WGL.Modulation(3, 500) * damage, WGL.Modulation(11, 500) * damage);
	end

	-- Draw beam change animation before any other rendering.
	WGL.Component(weapon, "BeamChange", weapon, beamData, eyePos, eyeAngles);

	-- Render current visor.
	hook.Run("MP.PreDrawPowerSuitHUD", weapon, damage);
	WGL.Component(weapon, weapon.Visors[self.CurrentVisor].Hud, weapon, beamData, visorData, visorPos, visorAngle, guiPos, guiColor, fovRatio, self.Transition, 1, widescreen, visorOpacity);

	-- Render past visor transitioning upon change.
	local transitionOut = 1 - WGL.Clamp(self.Transition + self.VisorRate - 1);
	if (!self.FromMorphBall && self.Transition < 1) then
		WGL.Component(weapon, weapon.Visors[self.PreviousVisor].Hud, weapon, beamData, visorData, visorPos, visorAngle, guiPos, guiColor, fovRatio, transitionOut, 0, widescreen, visorOpacity);
	else
		render.SetBlend(WGL.Clamp(self.Transition + 1));
	end

	-- Render face reflection.
	local currentBlend = render.GetBlend();
	if (faceReflect) then WGL.Component(weapon, "Face", eyePos, eyeAngles, currentBlend * self.Transition); end

	-- Render beam menu component.
	local beamMenuBlend   = visorData.ShouldHideBeamMenu  && transitionOut || currentBlend;
	local beamMenuOpacity = beamMenuBlend * visorOpacity;
	if (!hook.Run("MP.PreDrawBeamMenu",   weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, beamMenuOpacity, widescreen)) then
		WGL.Component(weapon, "BeamMenu", weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, beamMenuOpacity, widescreen);
	end
	hook.Run("MP.PostDrawBeamMenu", weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, beamMenuOpacity, widescreen);

	-- Render visor menu component.
	local visorMenuBlend   = visorData.ShouldHideVisorMenu && transitionOut || currentBlend;
	local visorMenuOpacity = visorMenuBlend * visorOpacity;
	if (!hook.Run("MP.PreDrawVisorMenu",   weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, visorMenuOpacity, widescreen)) then
		WGL.Component(weapon, "VisorMenu", weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, visorMenuOpacity, widescreen);
	end
	hook.Run("MP.PostDrawVisorMenu", weapon, eyePos, visorAngle, visorUp, visorRight, visorForward, fovRatio, visorMenuOpacity, widescreen);

	-- Render Helmet over all elements.
	hook.Run("MP.PostDrawPowerSuitHUD", weapon, damage);
	WGL.Component(weapon, "Helmet", weapon, visorData, hudPos, hudAngle, currentBlend * helmOpacity, widescreen);

	-- Render scan lines during morphball transition.
	if (!(self.Transition < 1 && self.FromMorphBall)) then return; end
	local fadeInOut = WGL.Clamp(-math.abs((((self.Transition + 5) / (self.MorphBallRate - 5) * 2) - 0.5) * 2.0) + 1.0);
	WGL.Texture(self.ScanLines, 0, 0, ScrW(), ScrH(), 255, 255, 255, fadeInOut * 20);
end