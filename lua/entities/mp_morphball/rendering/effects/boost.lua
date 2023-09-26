
local MorphBallBoost         = WGLComponent:New(MORPHBALL, "Boost");
MorphBallBoost.BoostMaterial = Material("entities/morphball/ghost");
MorphBallBoost.LastBlend     = 0;
MorphBallBoost.Models        = { ["Boost"] = Model("models/metroid/morphball/powersuit.mdl") };

function MorphBallBoost:Draw(pos, angles, charging, frametime)

	-- Setup ghost blending, this is only available while charging up the morphball boost and while boosting.
	if (charging) then self.LastBlend = Lerp(frametime * 0.6, self.LastBlend, 0.75);
	else self.LastBlend = Lerp(frametime * 4, self.LastBlend, 0); end
	if (self.LastBlend <= 0) then return; end

	-- Draw glowing boost model.
	render.MaterialOverride(self.BoostMaterial);
	render.SetBlend(self.LastBlend);
	self:DrawModel("Boost", pos, angles, 0.922);
	render.SetBlend(1);
	render.MaterialOverride(nil);
end