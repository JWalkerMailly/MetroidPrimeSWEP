
local MorphBallSpawn         = WGLComponent:New(MORPHBALL, "Spawn");
MorphBallSpawn.ModelScale    = 0.9;
MorphBallSpawn.SpawnMaterial = Material("entities/morphball/ghost");
MorphBallSpawn.SpawnLerp     = 0;
MorphBallSpawn.Rotation      = Angle(0, 0, 0);
MorphBallSpawn.Models        = { ["Spawn"] = Model("models/metroid/morphball/powersuit.mdl") };

function MorphBallSpawn:Draw(pos, angles, frametime)

	-- Update spawn lerp for the morphball model.
	if (self.SpawnLerp < 1) then

		local scale  = self.ModelScale / 0.9;
		local lerp   = 0.65 * scale;
		local offset = 0.02 * scale;

		self.SpawnLerp = WGL.Clamp(self.SpawnLerp + frametime);
		self.Rotation:SetUnpacked(0, CurTime() * 360, 0);
		self.Rotation:Add(angles);
		render.SetBlend((1.0 - self.SpawnLerp) * 0.25);
		render.MaterialOverride(self.SpawnMaterial);
		self:DrawModel("Spawn", pos, self.Rotation, lerp - (self.SpawnLerp * lerp) + (self.ModelScale + offset));
		render.MaterialOverride(nil);
		render.SetBlend(1);
	end
end