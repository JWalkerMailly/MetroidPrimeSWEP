
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

	-- Render helpers.
	self:DrawGestureHelp();
end

function POWERSUIT:DrawGestureHelp()

	if (!GetConVar("mp_options_gesturehelp"):GetBool()) then return; end

	local halfW = ScrW() * 0.5;
	local halfH = ScrH() * 0.5;
	local zone  = ScrH() * GetConVar("mp_options_gesturedzone"):GetFloat();
	WGL.Circle(halfW - zone * 0.5, halfH - zone * 0.5, zone, zone, 8, 255, 255, 255, 50);
	WGL.Rect(halfW + self.LastGesture[1] - 4, halfH + self.LastGesture[2] - 4, 8, 8, 255, 0, 0, 255);
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