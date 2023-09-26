
local MorphBallDamage          = WGLComponent:New(MORPHBALL, "Damage");
MorphBallDamage.DamageMaterial = Material("entities/morphball/damage");
MorphBallDamage.LastHealth     = 0;
MorphBallDamage.NextDamage     = 0;
MorphBallDamage.Models         = { ["Damage"] = Model("models/metroid/morphball/powersuit.mdl") };

function MorphBallDamage:Draw(health, pos, angles, scale)

	if (health < self.LastHealth) then
		self.NextDamage = CurTime() + 1;
	end

	-- Render red glow on morphball.
	if (CurTime() < self.NextDamage) then
		render.SetBlend(((math.sin(CurTime() * 50) * 0.5) + 0.5) * 0.52);
		render.MaterialOverride(self.DamageMaterial);
		self:DrawModel("Damage", pos, angles, scale, bodygroup, value, skin);
		render.MaterialOverride(nil);
		render.SetBlend(1);
	end

	self.LastHealth = health;
end