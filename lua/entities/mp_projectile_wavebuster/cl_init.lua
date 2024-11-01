
include("shared.lua");

PROJECTILE.RenderData       = {};
PROJECTILE.RenderFPS        = 1 / 60;
PROJECTILE.Resolution       = 64;
PROJECTILE.SplineStep       = 4;
PROJECTILE.SplineResolution = 16;

-- Wave buster rendering resources.
local core       = Material("particles/wavebeam/bustercore");
local shell      = Material("particles/wavebeam/bustershell");
local swirl      = Material("particles/wavebeam/swirl");
local coreColors = {
	Color(255, 0, 255),
	Color(255, 255, 255),
	Color(0, 0, 255),
	Color(255, 0, 0)
}

function PROJECTILE:UpdateRenderData(muzzle, up, right, endPos)

	-- Wait for next render update.
	local time = CurTime();
	local resolution = self.Resolution;

	-- Prepare spline date for bezier spline computations.
	local waveTime          = 4000 * FrameTime();
	local pseudoRandomUp    = up * math.Clamp(math.sin(2 * time * 10) + math.cos(math.pi * time), -0.5, 1) * 25;
	local pseudoRandomRight = right * (math.cos(2 * time) + math.sin(math.pi * time * 10)) * 25;
	local pseudoRandomEnd   = self.EndNormal * math.abs(pseudoRandomUp[3]) * 2;

	-- Choose a random color for the buster core. Purple is the most frequent,
	-- followed by white, blue and red equally.
	local randomColor = math.random(11);
	if (randomColor <= 4)                    then randomColor = 1; end
	if (randomColor > 4 && randomColor <= 7) then randomColor = 2; end
	if (randomColor > 7 && randomColor <= 9) then randomColor = 3; end
	if (randomColor > 9)                     then randomColor = 4; end
	local coreColor = coreColors[randomColor];

	-- Compute bezier spline at defined FPS.
	local time25    = time * 25;
	self.RenderData = {};
	for i = 0,resolution do
		local t         = i / resolution;
		local wave      = math.cos((time + t) * waveTime) / 2 + 0.5;
		local pos       = WGL.Bezier2(t, muzzle, muzzle + pseudoRandomUp + pseudoRandomRight, endPos + pseudoRandomEnd, endPos);
		local swirlTime = i / 1.5 - time25;
		local swirlPos  = right * math.cos(swirlTime) * 5 + up * math.sin(swirlTime) * 5;
		table.insert(self.RenderData, i + 1, { t, wave, pos, swirlPos, coreColor });
	end

	-- Raise next update flag.
	return time, resolution, self.RenderData;
end

function PROJECTILE:DrawBeam(muzzle, ang, endPos)

	local up               = ang:Up();
	local right            = ang:Right();
	local splineStep       = self.SplineStep;
	local splineResolution = self.SplineResolution;
	local time, resolution, renderData = self:UpdateRenderData(muzzle, up, right, endPos);

	-- Render inner part of the spline. We also store the computed data 
	-- for faster lookup when rendering the outer part of the spline.
	render.SetMaterial(core);
	render.StartBeam(splineResolution + 1);
	local data = renderData[1];
	render.AddBeam(muzzle, 1.5 + data[2] * 1.5, data[1], data[5]);
	for i = 1,resolution,splineStep do
		data = renderData[i + 1];
		render.AddBeam(data[3], 1.5 + data[2] * 1.5, data[1], data[5]);
	end
	render.EndBeam();

	-- Render outer part of the spline.
	local timeDiv10 = time / 10;
	render.SetMaterial(shell);
	render.StartBeam(splineResolution + 1);
	data = renderData[1];
	render.AddBeam(muzzle, 4 + data[2] * 3, timeDiv10, color_white);
	for i = 1,resolution,splineStep do
		data = renderData[i + 1];
		render.AddBeam(data[3], 4 + data[2] * 3, timeDiv10, color_white);
	end
	render.EndBeam();

	-- Render swirling part of the effect.
	render.SetMaterial(swirl);
	render.StartBeam(resolution + 1);
	render.AddBeam(muzzle, 4, time, color_white);
	render.AddBeam(muzzle, 4, 1 / resolution + time, color_white);
	render.AddBeam(muzzle, 4, 2 / resolution + time, color_white);
	for i = 3,resolution do
		data = renderData[i + 1];
		render.AddBeam(data[3] + data[4], 4, i / resolution + time, color_white);
	end
	render.EndBeam();
end

function PROJECTILE:Draw()

	local endPos = self.EndPos;
	if (endPos == nil) then return; end

	local owner = self:GetOwner();
	if (!IsValid(owner)) then return; end

	local weapon = self:GetWeapon();
	if (!IsValid(weapon)) then return; end

	-- Randomize wavebuster hit position if not target is found.
	if (!self.ValidTarget) then endPos = endPos + VectorRand(-7, 7); end

	-- If rendering on client, use viewmodel muzzle pos, else, use world attachment pos.
	local ang          = nil;
	local muzzle       = nil;
	local localPlayer  = LocalPlayer();
	local isLocal      = localPlayer == owner && weapon.IsFirstPerson && WGL.IsFirstPerson(localPlayer);
	if (isLocal) then
		local fov      = owner:GetFOV();
		local fovRatio = 1 - (75 / fov) + 1;
		muzzle, ang    = WGL.GetViewModelAttachmentPos(1, weapon.ViewModelFOV, fov, false, owner, true);
		muzzle         = muzzle - ang:Forward() * fovRatio;
		endPos         = WGL.ToViewModelProjection(endPos, weapon.ViewModelFOV, fov, false, owner, true);
	else
		ang    = owner:EyeAngles();
		muzzle = weapon:GetAttachment(1).Pos;
	end

	-- Render beam effect.
	WGL.ViewModelProjection(!isLocal, self.DrawBeam, self, muzzle, ang, endPos);
end