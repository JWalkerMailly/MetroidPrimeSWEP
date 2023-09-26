
include("shared.lua");

local shell = WGL.ClientsideModel("models/metroid/effects/supermissile_ball.mdl");

function PROJECTILE:Draw()

	shell:SetModelScale(9);
	render.SetColorModulation(0 / 255, 0 / 255, 255 / 255);
	render.SetBlend(0.3);
	render.Model({
		model = shell:GetModel(),
		pos   = self:GetPos(),
		angle = Angle(0, 76, 0)
	}, shell);
	render.SetBlend(1);
	render.SetColorModulation(1, 1, 1);
end