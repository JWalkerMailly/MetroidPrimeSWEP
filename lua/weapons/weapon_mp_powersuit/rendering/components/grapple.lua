
local GrapplePoints  = WGLComponent:New(POWERSUIT, "GrapplePoints");
GrapplePoints.Anchor = Material("huds/grapple");

local grappleUIColor   = Color(165, 105, 15, 255);
local grappleLockColor = Color(93, 123, 153, 255);

function GrapplePoints:Draw(weapon)

	local visor = weapon:GetVisor();
	if (visor.ShouldHideBeamMenu || visor.AllowLockAll || !weapon.PowerSuit:IsGrappleEnabled() || IsValid(weapon:GetMorphBall())) then return; end

	-- Iterate all viable anchors and render grapple sprites.
	local target, _, lockedOn = weapon.Helmet:GetTarget(IN_SPEED);
	for k,v in pairs(game.MetroidPrimeAnchors.Cache) do
		for x,y in pairs(ents.FindByClass(k)) do

			-- Add client side UI variables onto the entity for anchor rendering.
			if (y.GrappleUISize == nil) then
				y.GrappleUISize  = 52;
				y.GrappleUIColor = grappleUIColor;
			end

			-- Handle anchor size and color according to current target.
			if (y == target && !lockedOn) then
				y.GrappleUISize  = Lerp(FrameTime() * 1.5, y.GrappleUISize, 86);
				y.GrappleUIColor = WGL.LerpColor(FrameTime(), y.GrappleUIColor, grappleLockColor);
			else
				y.GrappleUISize  = Lerp(FrameTime(), y.GrappleUISize, 48);
				y.GrappleUIColor = WGL.LerpColor(FrameTime(), y.GrappleUIColor, grappleUIColor);
			end

			-- Render grapple anchor sprite.
			local pos      = y:GetLockOnPosition();
			local dir      = (EyePos() - pos);
			local forward  = dir:GetNormalized();
			local distance = dir:Length() / weapon.PowerSuit.Constants.Grapple.MaxDistance;
			local size     = math.Clamp(y.GrappleUISize * distance, 0, 86);
			local color    = y.GrappleUIColor;
			render.SetMaterial(self.Anchor);
			render.DrawSprite(pos + forward * size, size, size, color);
		end
	end
end