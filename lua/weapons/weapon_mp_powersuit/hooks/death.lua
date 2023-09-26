
if (CLIENT) then

	local deathScreen = {};
	local white       = Material("huds/white_additive");
	local noiseIn     = Material("huds/noise");
	local noiseOut    = Material("huds/noise2");
	local vignette    = Material("huds/vignette");

	local function GetDeathScreen()
		return WGL.GetRenderTexture(deathScreen, "rt_MPDeathScreen", ScrW(), ScrH(), { ["$additive"] = 1, ["$vertexcolor"] = 1 }, true);
	end

	hook.Add("PreRender", "POWERSUIT.DeathScreenCapture", function()

		local ply = LocalPlayer();
		if (ply:Health() > 0) then

			-- Player is still alive, prevent drawing death screen.
			ply.__mp_DeathScreen = false;
			ply.__mp_DeathTime   = ply:UsingPowerSuit() && CurTime() || nil;
			return;
		end

		-- Player died, play death sound and raise flag to draw death screen on next frame.
		if (!ply.__mp_DeathScreen && ply.__mp_DeathTime) then
			surface.PlaySound("samus/death.wav");
			ply.__mp_DeathScreen = true;
		end
	end);

	hook.Add("PostRender", "POWERSUIT.DeathScreenCapture", function()

		local ply = LocalPlayer();
		if (ply:Health() > 0 && ply:UsingPowerSuit()) then

			-- Continuously capture scene while using powersuit and alive.
			render.CopyRenderTargetToTexture(GetDeathScreen());
		end
	end);

	hook.Add("PostDrawHUD", "POWERSUIT.DeathScreen", function()

		-- Do nothing if death screen is not requested. Death time will only be
		-- valid if the player was using the powersuit upon the moment of death.
		local ply = LocalPlayer();
		if (!ply.__mp_DeathScreen || !ply.__mp_DeathTime) then return; end

		-- Texture size animations.
		local verticalFadeOut    = math.ease.InOutCubic(1 - WGL.Clamp((CurTime() - (ply.__mp_DeathTime + 0.4)) / 0.4));
		local verticalFadeSize   = math.Clamp(ScrH() * verticalFadeOut, ScrH() * 0.03, ScrH());
		local horizontalFadeOut  = 1 - WGL.Clamp((CurTime() - (ply.__mp_DeathTime + 0.95)) / 0.5);
		local horizontalFadeSize = math.Clamp(ScrW() * horizontalFadeOut, ScrH() * 0.03, ScrW());

		-- Texture fade animations.
		local alphaFade      = (1 - WGL.Clamp(CurTime() - (ply.__mp_DeathTime + 1.4)));
		local noiseFadeIn    = 255 * (WGL.Clamp((CurTime() - ply.__mp_DeathTime) / 0.15));
		local whiteFadeIn    = 200 * (WGL.Clamp(CurTime()  - (ply.__mp_DeathTime + 0.5)));
		local whiteFadeOut   = 100 * (1 - WGL.Clamp((CurTime()  - ply.__mp_DeathTime) / 0.4)) + 50 * alphaFade;
		local vignetteFadeIn = 255 * (WGL.Clamp((CurTime() - (ply.__mp_DeathTime + 0.3)) / 0.3));
		local noiseFadeOut   = 255 * (WGL.Clamp((CurTime() - (ply.__mp_DeathTime + 0.55)) / 0.2));
		local screenFadeOut  = 255 * alphaFade;

		-- Render death screen.
		local randU = math.Rand(0, 0.1);
		local randV = math.Rand(0, 0.5);
		local _, death = GetDeathScreen();
		WGL.Rect(-1, -1,         ScrW() + 2, ScrH() + 2, 0, 0, 0, 255);
		WGL.TextureRot(death,    ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0, screenFadeOut, screenFadeOut, screenFadeOut, screenFadeOut);
		WGL.TextureRot(white,    ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0, whiteFadeOut, whiteFadeOut, whiteFadeOut, whiteFadeOut);
		WGL.TextureUV(noiseIn,   ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0 + randU, 0 + randV, 0.9 + randU, 0.5 + randV, true, noiseFadeIn, noiseFadeIn, noiseFadeIn, noiseFadeIn * alphaFade);
		WGL.TextureUV(noiseOut,  ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0 + randU, 0 + randV, 0.9 + randU, 0.5 + randV, true, 255, 255, 255, noiseFadeOut * alphaFade);
		WGL.TextureRot(white,    ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0, whiteFadeIn, whiteFadeIn, whiteFadeIn, screenFadeOut);
		WGL.TextureRot(vignette, ScrW() / 2, ScrH() / 2, horizontalFadeSize, verticalFadeSize, 0, 255, 255, 255, vignetteFadeIn);
	end);
end

if (SERVER) then

	hook.Add("PlayerPostThink", "POWERSUIT.DeathSound", function(ply)
		ply.__mp_DeathSound = ply:UsingPowerSuit();
	end);

	hook.Add("PlayerDeathSound", "POWERSUIT.DeathSound", function(ply)
		return ply.__mp_DeathSound;
	end);
end