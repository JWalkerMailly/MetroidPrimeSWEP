
-- -----------------------
-- HUD and Visor Rendering
-- -----------------------

POWERSUIT.Hooks["HUDPaintBackground"] = function(weapon)

	-- Do nothing if we do not persist HUD, or if the power suit is in use.
	if (!GetConVar("mp_options_keephud"):GetBool() || weapon:IsActiveWeapon(LocalPlayer())) then return; end

	-- Call to HUD renderer.
	weapon:DrawHUDBackground();
end

POWERSUIT.Hooks["SetupWorldFog"] = function(weapon)

	if (!weapon:IsActiveWeapon(LocalPlayer())) then return; end

	local visor = weapon:GetVisor();
	if (visor.Fog == nil) then return; end

	-- Render visor fog for shader color manipulation.
	local fogColor = visor.Fog.Color;
	render.FogMode(1);
	render.FogColor(fogColor.r, fogColor.g, fogColor.b);
	render.FogMaxDensity(visor.Fog.Density);
	render.FogStart(visor.Fog.Start);
	render.FogEnd(visor.Fog.End);
	return true;
end

POWERSUIT.Hooks["RenderScreenspaceEffects"] = function(weapon)

	if (!weapon:IsActiveWeapon(LocalPlayer())) then return; end

	-- Render visor shaders.
	local visor = weapon:GetVisor();
	if (visor.Shader == nil) then return; end
	visor.Shader();
end

POWERSUIT.Hooks["PreRender"] = function(weapon)

	if (!weapon:IsActiveWeapon(LocalPlayer())) then return; end

	-- Visor changed, cleanup materials before render operations.
	local visor  = weapon:GetVisor();
	weapon.CurrentVisor = weapon.CurrentVisor || visor.Key;
	if (visor.Key != weapon.CurrentVisor) then
		weapon.CurrentVisor = visor.Key;
		weapon:CleanupMaterialOverrides();
	end

	-- Handle visor material swapping for entities.
	if (visor.MaterialFilter) then weapon:HandleMaterialOverrides(visor);
	else weapon:CleanupMaterialOverrides(); end

	-- Current config does not use projected texture feature, remove it if it exists.
	if (visor.ProjectedTexture == nil && IsValid(weapon.ProjectedTexture)) then
		weapon.ProjectedTexture:Remove();
		weapon.ProjectedTexture = nil;
	end

	-- Current config uses a projected texture for lighting, create it if not already done.
	if (visor.ProjectedTexture != nil && !IsValid(weapon.ProjectedTexture)) then
		weapon.ProjectedTexture = ProjectedTexture();
		weapon.ProjectedTexture:SetEnableShadows(false);
	end

	-- Update projected texture with current visor.
	if (IsValid(weapon.ProjectedTexture)) then
		weapon.ProjectedTexture:SetTexture(visor.ProjectedTexture.Texture);
		weapon.ProjectedTexture:SetPos(EyePos());
		weapon.ProjectedTexture:SetAngles(EyeAngles());
		weapon.ProjectedTexture:SetFOV(visor.ProjectedTexture.FOV);
		weapon.ProjectedTexture:SetVerticalFOV(visor.ProjectedTexture.FOVV);
		weapon.ProjectedTexture:SetBrightness(visor.ProjectedTexture.Brightness);
		weapon.ProjectedTexture:SetFarZ(visor.ProjectedTexture.Distance);
		weapon.ProjectedTexture:SetLinearAttenuation(visor.ProjectedTexture.Attenuation);
		weapon.ProjectedTexture:Update();
	end
end

POWERSUIT.Hooks["PreDrawTranslucentRenderables"] = function(weapon, depth, sky, sky3D)

	if (sky || sky3D || !weapon:IsActiveWeapon(LocalPlayer())) then return; end

	-- Render scan/grapple points. We need to do so now in order for the sprites 
	-- to render in the world rather than in front of the world.
	WGL.Component(weapon, "ScanPoints",    weapon);
	WGL.Component(weapon, "GrapplePoints", weapon);
end

-- ----------------------------
-- Death Screen Rendering Hooks
-- ----------------------------

local deathRT = {};
local function GetDeathScreen()
	return WGL.GetRenderTexture(deathRT, "rt_MPDeathScreen", ScrW(), ScrH(), { ["$additive"] = 1, ["$vertexcolor"] = 1 }, true);
end

hook.Add("PreRender", "POWERSUIT.DeathScreenThink", function()

	local ply = LocalPlayer();

	-- Player is still alive, prevent drawing death screen.
	if (ply.__mp_DeathTime && ply:Health() > 0) then
		ply.__mp_DeathScreen = false;
		ply.__mp_DeathTime   = nil;
		return;
	end

	-- Player died, play death sound and raise flag to draw death screen on next frame.
	if (!ply.__mp_DeathScreen && ply.__mp_DeathTime) then
		surface.PlaySound("samus/death.wav");
		ply.__mp_DeathScreen = true;
	end
end);

POWERSUIT.Hooks["PostRender"] = function(weapon)

	local ply = LocalPlayer();
	if (ply:Health() > 0 && weapon:IsActiveWeapon(ply)) then

		-- Continuously capture scene while using powersuit and alive.
		render.CopyRenderTargetToTexture(GetDeathScreen());
		ply.__mp_DeathTime = CurTime();
	end
end

local white    = Material("huds/white_additive");
local noiseIn  = Material("huds/noise");
local noiseOut = Material("huds/noise2");
local vignette = Material("huds/vignette");
hook.Add("PostDrawHUD", "POWERSUIT.DeathScreenRender", function()

	-- Do nothing if death screen is not requested. Death time will only be
	-- valid if the player was using the powersuit upon the moment of death.
	local ply = LocalPlayer();
	local deathTime = ply.__mp_DeathTime;
	local deathScreen = ply.__mp_DeathScreen;
	if (!deathScreen || !deathTime) then return; end

	-- Texture size animations.
	local verticalFadeOut    = math.ease.InOutCubic(1 - WGL.Clamp((CurTime() - (deathTime + 0.4)) / 0.4));
	local verticalFadeSize   = math.Clamp(ScrH() * verticalFadeOut, ScrH() * 0.03, ScrH());
	local horizontalFadeOut  = 1 - WGL.Clamp((CurTime() - (deathTime + 0.95)) / 0.5);
	local horizontalFadeSize = math.Clamp(ScrW() * horizontalFadeOut, ScrH() * 0.03, ScrW());

	-- Texture fade animations.
	local alphaFade      = (1 - WGL.Clamp(CurTime() - (deathTime + 1.4)));
	local noiseFadeIn    = 255 * (WGL.Clamp((CurTime() - deathTime) / 0.15));
	local whiteFadeIn    = 200 * (WGL.Clamp(CurTime()  - (deathTime + 0.5)));
	local whiteFadeOut   = 100 * (1 - WGL.Clamp((CurTime()  - deathTime) / 0.4)) + 50 * alphaFade;
	local vignetteFadeIn = 255 * (WGL.Clamp((CurTime() - (deathTime + 0.3)) / 0.3));
	local noiseFadeOut   = 255 * (WGL.Clamp((CurTime() - (deathTime + 0.55)) / 0.2));
	local screenFadeOut  = 255 * alphaFade;

	-- Render death screen.
	local halfW = ScrW() / 2
	local halfH = ScrH() / 2;
	local randU = math.Rand(0, 0.1);
	local randV = math.Rand(0, 0.5);
	local _, death = GetDeathScreen();
	WGL.Rect(-1, -1, ScrW() + 2, ScrH() + 2, 0, 0, 0, 255);
	WGL.TextureRot(death,    halfW, halfH, horizontalFadeSize, verticalFadeSize, 0, screenFadeOut, screenFadeOut, screenFadeOut, screenFadeOut);
	WGL.TextureRot(white,    halfW, halfH, horizontalFadeSize, verticalFadeSize, 0, whiteFadeOut, whiteFadeOut, whiteFadeOut, whiteFadeOut);
	WGL.TextureUV(noiseIn,   halfW, halfH, horizontalFadeSize, verticalFadeSize, 0 + randU, 0 + randV, 0.9 + randU, 0.5 + randV, true, noiseFadeIn, noiseFadeIn, noiseFadeIn, noiseFadeIn * alphaFade);
	WGL.TextureUV(noiseOut,  halfW, halfH, horizontalFadeSize, verticalFadeSize, 0 + randU, 0 + randV, 0.9 + randU, 0.5 + randV, true, 255, 255, 255, noiseFadeOut * alphaFade);
	WGL.TextureRot(white,    halfW, halfH, horizontalFadeSize, verticalFadeSize, 0, whiteFadeIn, whiteFadeIn, whiteFadeIn, screenFadeOut);
	WGL.TextureRot(vignette, halfW, halfH, horizontalFadeSize, verticalFadeSize, 0, 255, 255, 255, vignetteFadeIn);
end);

-- ------------
-- Camera Hooks
-- ------------

POWERSUIT.Hooks["CreateMove"] = function(weapon, cmd)

	-- Keep mouse movement reference for rendering operations.
	LocalPlayer().__mp_MouseX = cmd:GetMouseX();
	LocalPlayer().__mp_MouseY = cmd:GetMouseY();
end

POWERSUIT.Hooks["InputMouseApply"] = function(weapon, cmd)

	if (!weapon:IsActiveWeapon(LocalPlayer())) then return; end

	-- Prevent mouse movement when locked onto a target.
	local _, _, locked = weapon.Helmet:GetTarget(IN_SPEED);
	local gesture = GetConVar("mp_options_gestures"):GetBool() && (input.IsButtonDown(weapon.GestureKey) || input.IsButtonDown(weapon.SelectorLayerKey)) || false;
	if (locked || gesture) then
		cmd:SetMouseX(0);
		cmd:SetMouseY(0);
		return true;
	end

	return false;
end

POWERSUIT.Hooks["CalcView"] = function(weapon, ply, viewPos, angles, fov)

	if (!weapon:IsActiveWeapon(ply)) then return; end

	-- Setup camera data for transitions.
	ply.__mp_LastViewPos      = ply.__mp_LastViewPos      || viewPos;
	ply.__mp_LastViewAngles   = ply.__mp_LastViewAngles   || angles;
	ply.__mp_CameraTransition = ply.__mp_CameraTransition || 1;

	-- Setup default view.
	local view = {
		origin       = viewPos,
		angles       = angles,
		fov          = ply.__mp_FOVTransition,
		drawviewer   = false
	};

	-- Delegate view rendering to morphball when we enter the vehicle.
	local vehicle = ply:GetVehicle();
	if (IsValid(weapon:GetMorphBall()) && IsValid(vehicle)) then
		ply.__mp_LastViewPos      = viewPos;
		ply.__mp_LastViewAngles   = angles;
		ply.__mp_CameraTransition = 0;
		return hook.Run("CalcVehicleView", vehicle, ply, view);
	end

	-- Camera transition out of morphball and into powersuit.
	ply.__mp_FOVTransition = Lerp(FrameTime() * 5, ply.__mp_FOVTransition || fov, ply:GetFOV());
	if (ply.__mp_CameraTransition < 1) then
		ply.__mp_CameraTransition = ply.__mp_CameraTransition + FrameTime() * 1.5;
		view.origin     = LerpVector(ply.__mp_CameraTransition, ply.__mp_LastViewPos, viewPos);
		view.angles     = LerpAngle(ply.__mp_CameraTransition, ply.__mp_LastViewAngles, angles);
		view.drawviewer = true;
		return view;
	end
end

POWERSUIT.Hooks["CalcVehicleView"] = function (weapon, vehicle, ply, view)

	-- Wait for morphball to be fully initialized before processing this hook.
	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall() || !morphball.Initialized) then return; end

	local camera     = weapon.MorphBall.Constants.Camera;
	local pos        = morphball:GetPos();
	local min        = WGL.OneVec * -camera.Offset;
	local max        = WGL.OneVec * camera.Offset;
	local fov        = 75 + math.Clamp(25 * (morphball:GetClientVelocity():Length() / morphball.MaxSpeed), 0, 25);
	local filter     = { ply, vehicle, morphball };

	-- Perform bound trace from morphball to camera position.
	local boundTrace = util.TraceHull({
		start        = pos,
		endpos       = pos + view.angles:Forward() * -camera.Radius,
		mins         = min,
		maxs         = max,
		filter       = filter,
		mask         = MASK_PLAYERSOLID_BRUSHONLY
	});

	-- Perform bound trace from camera position and up towards final view point.
	local upTrace    = util.TraceHull({
		start        = boundTrace.HitPos,
		endpos       = boundTrace.HitPos + WGL.UpVec * morphball.Radius * 2.5,
		mins         = min,
		maxs         = max,
		filter       = filter,
		mask         = MASK_PLAYERSOLID_BRUSHONLY
	});

	ply.__mp_FOVTransition = morphball:GetOnGround() && Lerp(FrameTime() * 2, ply.__mp_FOVTransition || view.fov, fov) || ply.__mp_FOVTransition;
	local finalView  = {
		origin       = upTrace.HitPos;
		angles       = view.angles + Angle(10, 0, 0);
		fov          = ply.__mp_FOVTransition,
		drawviewer   = false;
	};

	-- Setup camera transition data.
	morphball.__mp_CameraTransition = morphball.__mp_CameraTransition || 0;
	if (morphball.__mp_CameraTransition < 1) then
		morphball.__mp_CameraTransition = morphball.__mp_CameraTransition + FrameTime() * 1.4;
		finalView.origin = LerpVector(morphball.__mp_CameraTransition, ply.__mp_LastViewPos, finalView.origin);
		finalView.angles = LerpAngle(morphball.__mp_CameraTransition, ply.__mp_LastViewAngles, finalView.angles);
	end

	-- Update vehicle view and keep reference for transitions later.
	morphball:SetVehicleViewPos(finalView.origin);
	ply.__mp_LastViewPos    = finalView.origin;
	ply.__mp_LastViewAngles = finalView.angles;
	return finalView;
end

-- -----------------------
-- Grapple Beams Rendering
-- -----------------------

hook.Add("PreDrawTranslucentRenderables", "POWERSUIT.DrawLockOnIcons", function(depth, sky, sky3D)

	if (sky || sky3D) then return; end

	-- Render grapple beam.
	for k,v in player.Iterator() do

		-- Render grapple beam for all players.
		local hasPowerSuit, powersuit = v:UsingPowerSuit(true);
		if (hasPowerSuit) then WGL.Component(powersuit, "GrappleBeam", powersuit); end
	end
end);