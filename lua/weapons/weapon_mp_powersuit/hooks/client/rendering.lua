
local currentVisor     = nil;
local projectedTexture = nil;
local cleanupMaterials = false;

local function CleanupMaterialOverrides()

	if (!cleanupMaterials) then return; end
	for k,v in pairs(game.MetroidPrimeMaterialSwaps) do

		if (!v.__mp_VisorOverride) then continue; end

		-- Falback to default texture.
		v:SetMaterial(v:GetMaterial());
		v.__mp_VisorOverride = false;
	end

	cleanupMaterials = false;
end

local function HandleMaterialOverrides(visor)

	for k,v in pairs(game.MetroidPrimeMaterialSwaps) do

		-- Apply material swap to valid entities.
		local override = visor.MaterialFilter(v);
		if (override) then
			v:SetMaterial(override);
			v.__mp_VisorOverride = true;
			continue;
		end

		-- Entity visor rules changed, reset material.
		if (v.__mp_VisorOverride) then
			v:SetMaterial(v:GetMaterial());
			v.__mp_VisorOverride = false;
		end
	end

	cleanupMaterials = true;
end

hook.Add("PreRender", "POWERSUIT.VisorProjectedTexture", function()

	local isPowerSuit, weapon = LocalPlayer():UsingPowerSuit();
	if (!isPowerSuit) then

		-- Remove color manipulation projection.
		if (IsValid(projectedTexture)) then
			projectedTexture:Remove();
			projectedTexture = nil;
		end

		return CleanupMaterialOverrides();
	end

	-- Visor changed, cleanup materials before render operations.
	local visor  = weapon:GetVisor();
	currentVisor = currentVisor || visor.Key;
	if (visor.Key != currentVisor) then
		currentVisor = visor.Key;
		CleanupMaterialOverrides();
	end

	-- Handle visor material swapping for entities.
	if (visor.MaterialFilter) then HandleMaterialOverrides(visor);
	else CleanupMaterialOverrides(); end

	-- Current config does not use projected texture feature, remove it if it exists.
	if (visor.ProjectedTexture == nil && IsValid(projectedTexture)) then
		projectedTexture:Remove();
		projectedTexture = nil;
	end

	-- Current config uses a projected texture for lighting, create it if not already done.
	if (visor.ProjectedTexture != nil && !IsValid(projectedTexture)) then
		projectedTexture = ProjectedTexture();
		projectedTexture:SetEnableShadows(false);
	end

	-- Update projected texture with current visor.
	if (IsValid(projectedTexture)) then
		projectedTexture:SetTexture(visor.ProjectedTexture.Texture);
		projectedTexture:SetPos(EyePos());
		projectedTexture:SetAngles(EyeAngles());
		projectedTexture:SetFOV(visor.ProjectedTexture.FOV);
		projectedTexture:SetVerticalFOV(visor.ProjectedTexture.FOVV);
		projectedTexture:SetBrightness(visor.ProjectedTexture.Brightness);
		projectedTexture:SetFarZ(visor.ProjectedTexture.Distance);
		projectedTexture:SetLinearAttenuation(visor.ProjectedTexture.Attenuation);
		projectedTexture:Update();
	end
end);

hook.Add("SetupWorldFog", "POWERSUIT.VisorFog", function()

	local isPowerSuit, weapon = LocalPlayer():UsingPowerSuit();
	if (!isPowerSuit) then return; end

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
end);

hook.Add("RenderScreenspaceEffects", "POWERSUIT.DrawVisorShaders", function()

	local isPowerSuit, weapon = LocalPlayer():UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Render visor shaders.
	local visor = weapon:GetVisor();
	if (visor.Shader == nil) then return; end
	visor.Shader();
end);

hook.Add("PreDrawTranslucentRenderables", "POWERSUIT.DrawLockOnIcons", function(depth, sky, sky3D)

	if (sky || sky3D) then return; end

	local isPowerSuit, weapon;

	-- Render grapple beam.
	for k,v in pairs(player.GetAll()) do

		local hasPowerSuit, powersuit = v:UsingPowerSuit(true);
		if (v == LocalPlayer()) then isPowerSuit, weapon = hasPowerSuit, powersuit; end

		-- Render grapple beam for all players.
		if (hasPowerSuit) then WGL.Component(powersuit, "GrappleBeam", powersuit); end
	end

	-- Render scan/grapple points. We need to do so now in order for the sprites 
	-- to render in the world rather than in front of the world.
	if (!isPowerSuit) then return; end
	WGL.Component(weapon, "ScanPoints", weapon);
	WGL.Component(weapon, "GrapplePoints", weapon);
end);

hook.Add("PreDrawEffects", "POWERSUIT.DrawViewModelEffects", function()

	local isPowerSuit, weapon = LocalPlayer():UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- We must setup a viewmodel projection space for the following operations to be valid.
	-- The projection space will allow us to correctly position the effect at the viewmodel's muzzle.
	-- We also can't use the viewmodel rendering hooks as they conflict with the visor material swaps.
	WGL.ViewModelProjection(false, weapon.ViewModelFOV, weapon.DrawViewModelEffects, weapon);
end);

hook.Add("HUDPaintBackground", "POWERSUIT.PersistHUD", function()

	-- Do nothing if we do not persist HUD, or if the power suit is in use.
	local owner = LocalPlayer();
	if (!GetConVar("mp_options_keephud"):GetBool() || owner:UsingPowerSuit()) then return; end

	local powersuit = owner:GetPowerSuit();
	if (!powersuit) then return; end

	-- Call to HUD renderer.
	powersuit:DrawHUDBackground();
end);