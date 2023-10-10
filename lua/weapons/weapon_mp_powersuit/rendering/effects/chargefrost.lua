
local ChargeFrost  = WGLComponent:New(POWERSUIT, "ChargeFrost");
ChargeFrost.Ratio  = 0;
ChargeFrost.Models = {
	["Frost1"] = { Model("models/metroid/effects/icebeam_frost_1.mdl"), RENDERGROUP_VIEWMODEL },
	["Frost2"] = { Model("models/metroid/effects/icebeam_frost_2.mdl"), RENDERGROUP_VIEWMODEL },
	["Frost3"] = { Model("models/metroid/effects/icebeam_frost_3.mdl"), RENDERGROUP_VIEWMODEL }
}

function ChargeFrost:Initialize()
	self.Ratio = 0;
end

function ChargeFrost:Draw(pos, ang, ratio, color)

	-- Avoid ratio shrinking unless it is being reset.
	if (ratio > self.Ratio) then self.Ratio = ratio; end

	-- Render vent effect on viewmodel.
	render.SetBlend(WGL.Clamp(self.Ratio - 0.5) * 0.5);
	self:DrawModel("Frost1", pos - ang:Forward() *  5.0 + ang:Right() * -1.40 + ang:Up() * 1.40, ang, WGL.Clamp(self.Ratio * 1.66) * 40);
	self:DrawModel("Frost2", pos - ang:Forward() * 16.0 + ang:Right() * -1.85 + ang:Up() * 1.19, ang, WGL.Clamp(self.Ratio * 1.33) * 40);
	self:DrawModel("Frost3", pos - ang:Forward() * 20.9 + ang:Right() * -1.85 + ang:Up() * 3.00, ang, self.Ratio * 43);
	render.SetBlend(1);
end