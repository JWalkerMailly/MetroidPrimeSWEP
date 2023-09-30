
local GrappleBeam          = WGLComponent:New(POWERSUIT, "GrappleBeam");
GrappleBeam.Sway           = 75;
GrappleBeam.Period         = 25;
GrappleBeam.FarResolution  = 40;
GrappleBeam.NearResolution = 16;
GrappleBeam.Beam           = Material("particles/grapplebeam/beam");
GrappleBeam.Glow           = Material("particles/grapplebeam/glow");

local grappleClawColor = Color(255, 255, 255, 15);
local grapplBlueColor  = Color(0, 0, 255, 255);

function GrappleBeam:Draw(weapon)

	local grappleRatio = weapon.PowerSuit:GetGrappleRatio();
	if (grappleRatio <= 0) then return; end

	local owner = weapon:GetOwner();
	local grappleStartPos;
	if (LocalPlayer() == owner) then
		local eyeAngles = owner:EyeAngles();
		grappleStartPos = owner:EyePos() - eyeAngles:Up() * 30 - eyeAngles:Right() * 30;
	else
		local handAttachmentID = owner:LookupAttachment("anim_attachment_LH");
		grappleStartPos = handAttachmentID > 0 && owner:GetAttachment(handAttachmentID).Pos || owner:GetPos();
	end

	local anchor, anchorValid = weapon.Helmet:GetTarget(IN_SPEED);
	if (!anchorValid) then return; end

	local maxDistance         = weapon.PowerSuit.Constants.Grapple.MaxDistance;
	local grappleEndPos       = LerpVector(grappleRatio, grappleStartPos, anchor:GetLockOnPosition());
	local grappleDirection    = grappleEndPos - grappleStartPos;
	local grappleAngle        = grappleDirection:Angle();
	local grappleUp           = grappleAngle:Up();
	local grappleRight        = grappleAngle:Right();
	local grappleBeamRatio    = WGL.Clamp(grappleDirection:Length() / maxDistance);
	local grappleBeamSway     = Lerp(grappleRatio, 30, 0);
	local grappleBeamHalfSway = grappleBeamSway * 0.5;
	local grappleResolution   = math.floor(Lerp(grappleBeamRatio, self.NearResolution, self.FarResolution));
	local grappleClawSize     = 86;
	grappleAngle:RotateAroundAxis(grappleDirection:GetNormalized(), grappleRatio * 45);

	-- Draw continuous beam when grappled onto anchor.
	if (grappleRatio == 1) then
		grappleClawSize = 43;
		render.SetMaterial(self.Beam);
		render.DrawBeam(grappleStartPos, grappleEndPos, 6, 0, 1, grappleClawColor);
	end

	-- Draw grapple claw glow effect.
	render.SetMaterial(self.Glow);
	render.DrawSprite(grappleEndPos, grappleClawSize, grappleClawSize);

	-- Render animated grapple beam.
	local time   = CurTime();
	local sway   = time * self.Sway;
	local period = self.Period;
	local data   = {};
	render.SetMaterial(self.Beam);
	for i = 0, grappleResolution do

		-- Compute start position of current beam segment.
		local startRatio, startPos, startSway, startSwayVec = nil, nil, nil, nil;
		if (i == 0) then
			startRatio   = i / grappleResolution;
			startPos     = Lerp(startRatio, grappleStartPos, grappleEndPos);
			startSway    = sway + period * startRatio;
			startSwayVec = grappleRight * math.sin(startSway) * grappleBeamSway + grappleUp * math.cos(startSway) * grappleBeamHalfSway;
		else
			startRatio, startPos, startSway, startSwayVec = unpack(data[i]);
		end

		-- Compute end position of current beam segment.
		local endRatio       = (i + 1) / grappleResolution;
		local endPos         = Lerp(endRatio, grappleStartPos, grappleEndPos);
		local endSway        = sway + period * endRatio;
		local endSwayVec     = grappleRight * math.sin(endSway) * grappleBeamSway + grappleUp * math.cos(endSway) * grappleBeamHalfSway;
		table.insert(data, i + 1, { endRatio, endPos, endSway, endSwayVec });

		-- Render grapple beam segment.
		grapplBlueColor.a    = math.random(0, 225);
		local randomTexStart = math.Rand(0, 0.25);
		local randomTexEnd   = math.Rand(0.75, 1);
		local segmentColor   = WGL.LerpColor(startRatio, color_white, grapplBlueColor);
		render.DrawBeam(startPos + startSwayVec, endPos + endSwayVec, 6 + math.Rand(0, 6), randomTexStart, randomTexEnd, segmentColor);
	end
end