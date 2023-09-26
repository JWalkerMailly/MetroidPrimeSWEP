
include("shared.lua");

local core   = WGL.ClientsideModel("models/metroid/effects/supermissile_ball.mdl");
local shell  = WGL.ClientsideModel("models/metroid/effects/supermissile_ball.mdl");
local trail1 = WGL.ClientsideModel("models/metroid/effects/supermissile_ball.mdl");
local trail2 = WGL.ClientsideModel("models/metroid/effects/supermissile_ball.mdl");

function PROJECTILE:Draw()

	-- Failsafe.
	if (!self.SpawnTime) then return; end

	core:SetModelScale(6);
	render.SetColorModulation(255 / 255, 235 / 255, 0 / 255);
	render.SetBlend(0.25);
	render.Model({
		model = core:GetModel(),
		pos   = self:GetPos(),
		angle = Angle(0, 180, 0)
	}, core);
	render.SetBlend(1);
	render.SetColorModulation(1, 1, 1);

	shell:SetModelScale(8.5);
	render.SetColorModulation(255 / 255, 200 / 255, 0 / 255);
	render.SetBlend(0.15);
	render.Model({
		model = shell:GetModel(),
		pos   = self:GetPos(),
		angle = Angle(0, 76, 0)
	}, shell);
	render.SetBlend(1);
	render.SetColorModulation(1, 1, 1);

	if (CurTime() > self.SpawnTime + 0.1) then
		trail1:SetModelScale(6);
		render.SetColorModulation(255 / 255, 200 / 255, 0 / 255);
		render.SetBlend(0.25);
		render.Model({
			model = trail1:GetModel(),
			pos   = self:GetPos() - self:GetAngles():Forward() * 15,
			angle = Angle(0, 180, 0)
		}, trail1);
		render.SetBlend(1);
		render.SetColorModulation(1, 1, 1);
	end

	if (CurTime() > self.SpawnTime + 0.2) then
		trail2:SetModelScale(6);
		render.SetColorModulation(255 / 255, 200 / 255, 0 / 255);
		render.SetBlend(0.25);
		render.Model({
			model = trail2:GetModel(),
			pos   = self:GetPos() - self:GetAngles():Forward() * 30,
			angle = Angle(0, 180, 0)
		}, trail2);
		render.SetBlend(1);
		render.SetColorModulation(1, 1, 1);
	end
end