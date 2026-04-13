
local MorphBallDamage          = WGLComponent:New(MORPHBALL, "Damage");
MorphBallDamage.ModelScale     = 0.9;
MorphBallDamage.DamageMaterial = Material("entities/morphball/damage");
MorphBallDamage.LastHealth     = 0;
MorphBallDamage.NextDamage     = 0;
MorphBallDamage.Models         = { ["Damage"] = Model("models/metroid/morphball/powersuit.mdl") };

function MorphBallDamage:Draw(health, pos, angles)

	if (health < self.LastHealth) then
		self.NextDamage = CurTime() + 1;
	end

	-- Render red glow on morphball.
	if (CurTime() < self.NextDamage) then

		local scale  = self.ModelScale / 0.9;
		local offset = 0.01 * scale;

		render.SetBlend(((math.sin(CurTime() * 50) * 0.5) + 0.5) * 0.52);
		render.MaterialOverride(self.DamageMaterial);
		self:DrawModel("Damage", pos, angles, self.ModelScale + offset);
		render.MaterialOverride(nil);
		render.SetBlend(1);

		if (!self.DamageSound) then
			surface.PlaySound("entities/morphball/damage.wav")
			self.DamageSound = true
		end
	else
		self.DamageSound = false
	end

	self.LastHealth = health;
end