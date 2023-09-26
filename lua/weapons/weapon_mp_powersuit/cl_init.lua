
include("shared.lua");

local hideHUD = {
	["CHudAmmo"]                  = true,
	["CHudBattery"]               = true,
	["CHudCrosshair"]             = true,
	["CHudCloseCaption"]          = true,
	["CHudDamageIndicator"]       = true,
	["CHudDeathNotice"]           = true,
	["CHudGeiger"]                = true,
	["CHudHealth"]                = true,
	["CHudHintDisplay"]           = true,
	["CHudPoisonDamageIndicator"] = true,
	["CHudSecondaryAmmo"]         = true,
	["CHudSquadStatus"]           = true,
	["CHudTrain"]                 = true,
	["CHudVehicle"]               = true,
	["CHudWeapon"]                = true,
	["CHudZoom"]                  = true,
	["CHUDQuickInfo"]             = true,
	["CHudSuitPower"]             = true
}

function POWERSUIT:HUDShouldDraw(name)
	if (hideHUD[name]) then return false;
	else return true; end
end

function POWERSUIT:DrawHUDBackground()

	-- Wait for statemachines to be ready.
	if (self.StateIdentifier == nil) then return; end

	-- Render HUDs.
	local damage = math.pow((self.HealthState.next || 0) - CurTime(), 3) * 1.5;
	WGL.Texture(self.DamageFlash, 0, 0, ScrW(), ScrH(), 255, 200, 0, 20 * WGL.Clamp(damage));
	WGL.Component(self, "PowerSuitHUD", self, damage);
	WGL.Component(self, "MorphBallHUD", self, damage);
end

function POWERSUIT:DrawWeaponSelection(x, y, wide, tall, alpha)

	-- Draw weapon icon with dynamic beam.
	local beamData = self:GetBeam();
	WGL.Texture(self.WepSelectIcon, x, y + tall * 0.1, wide, wide / 2, 255, 255, 255, alpha);
	WGL.Texture(beamData.Icon, x + wide / 2.02, y + tall / 2.4, wide / 4.8, wide / 4.8, 255, 255, 255, alpha);
end

function POWERSUIT:FireAnimationEvent(pos, ang, event, options)
	return true;
end