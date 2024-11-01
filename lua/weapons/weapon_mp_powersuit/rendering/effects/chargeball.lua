
local ChargeBall  = WGLComponent:New(POWERSUIT, "ChargeBall");
ChargeBall.Angle  = Angle(0, 0, 0);
ChargeBall.Models = {
	["Ball"] = { Model("models/metroid/effects/chargeball.mdl"), RENDERGROUP_VIEWMODEL },
	["Glow"] = { Model("models/metroid/effects/chargeglow.mdl"), RENDERGROUP_VIEWMODEL }
}

function ChargeBall:Draw(pos, ang, ratio, color)

	-- Setup rendering matrix.
	local modelMatrix = Matrix();
	modelMatrix:Rotate(ang);

	-- Apply random rotation similar to the original game.
	self.Angle:RotateAroundAxis(Vector(0, 1, -1), 25 * FrameTime() / math.pow(math.ease.InBounce(ratio + 0.01), 4));
	modelMatrix:Rotate(self.Angle);

	-- Render charge ball angles using rendering matrix.
	local scale = math.ease.InBounce(math.Clamp(ratio + 0.15, 0, 1.05)) * 6.25;
	render.DepthRange(0, 0.25);
	render.SetBlend(color.a);
	render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255);
	self:DrawModel("Ball", pos, modelMatrix:GetAngles(), scale);
	render.SetColorModulation(1, 1, 1);
	render.SetBlend(1);
	modelMatrix = nil;

	-- Render charge glow over charge ball. (specular)
	render.SetBlend(0.8);
	self:DrawModel("Glow", pos, ang, scale);
	render.SetBlend(1);
end