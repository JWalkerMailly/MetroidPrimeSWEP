
local ChargeVents  = WGLComponent:New(POWERSUIT, "ChargeVents");
ChargeVents.Models = {
	["Vents"] = { Model("models/metroid/effects/charge_vents.mdl"), RENDERGROUP_VIEWMODEL }
}

function ChargeVents:Draw(pos, ang, ratio, color)

	-- Render vent effect on viewmodel.
	render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255);
	render.SetBlend(WGL.Clamp(ratio - 0.5) * math.Rand(0.25, 0.5));
	self:DrawModel("Vents", pos - ang:Forward() * 20 + ang:Right() * 0 + ang:Up() * 2.6, ang);
	render.SetColorModulation(1, 1, 1);
	render.SetBlend(1);
end