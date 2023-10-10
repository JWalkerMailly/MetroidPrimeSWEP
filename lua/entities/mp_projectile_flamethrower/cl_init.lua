
include("shared.lua");

PROJECTILE.Resolution = 16;

-- Flamethrower rendering resources.
local core       = Material("particles/plasmabeam/plasmacore");
local inner      = Material("particles/plasmabeam/plasmainner");
local innerColor = Color(255, 255, 255, 255);
local outerColor = Color(50, 50, 50, 255);
local fire       = {
	Material("particles/plasmabeam/plasmafire1"),
	Material("particles/plasmabeam/plasmafire2")
}

function PROJECTILE:DrawBeam(points)

	-- Failsafe.
	if (!self.SpawnTime) then return; end

	-- Render flamethrower effect.
	local data       = {};
	local time       = CurTime();
	local resolution = self.Resolution;
	render.SetMaterial(core);
	render.StartBeam(resolution + 1);
	for i = 0,resolution do
		local t      = i / resolution;
		local pos    = WGL.Bezier(t, points);
		local width  = (1 - t / 2);
		innerColor.a = 255 * (1 - t);
		table.insert(data, i + 1, { t, width, pos, innerColor.a });
		render.AddBeam(pos, 5.5 * width, t, innerColor);
	end
	render.EndBeam();

	-- Render inner part of the spline.
	local timeDiv10 = time / 10;
	render.SetMaterial(inner);
	render.StartBeam(resolution + 1);
	for i = 0,resolution do
		local splineData = data[i + 1];
		outerColor.a     = splineData[4];
		render.AddBeam(splineData[3], 2 * splineData[2], timeDiv10, outerColor);
	end
	render.EndBeam();

	-- Render fire effects.
	local fadeIn = WGL.Clamp((CurTime() - self.SpawnTime) / 0.75);
	for i = 1, resolution do
		local loop = ((CurTime() + (i / resolution) * 1.5) % 1.5) / 1.5;
		local pos  = WGL.Bezier(loop, points);
		local size = 16 * loop * math.Rand(0.75 + loop, 2.5) + 6;
		render.SetMaterial(fire[math.random(1, 2)]);
		render.DrawSprite(pos, size, size, Color(255, 255, 255, (1 - loop) * 255 * fadeIn * math.Rand(0.2, 1)));
	end
end

function PROJECTILE:Draw()

	local endPos = self.EndPos;
	if (endPos == nil)    then return; end

	local owner = self:GetOwner();
	if (!IsValid(owner))  then return; end

	local weapon = self:GetWeapon();
	if (!IsValid(weapon)) then return; end

	-- If rendering on client, use viewmodel muzzle pos, else, use world attachment pos.
	local ang     = nil
	local muzzle  = nil;
	local isLocal = LocalPlayer() == owner;
	if (isLocal) then
		local fov      = owner:GetFOV();
		local fovRatio = 1 - (75 / fov) + 1;
		muzzle, ang    = WGL.GetViewModelAttachmentPos(1, weapon.ViewModelFOV, fov, false, owner, true);
		muzzle         = muzzle - ang:Forward() * fovRatio;
		endPos         = WGL.ToViewModelProjection(endPos, weapon.ViewModelFOV, fov, false, owner);
	else
		ang    = owner:EyeAngles();
		muzzle = weapon:GetAttachment(1).Pos;
	end

	-- Prepare beam rendering values.
	local forward  = owner:GetAimVector();
	local distance = muzzle:Distance(endPos) / 2;
	local points   = {
		muzzle,
		muzzle + forward * distance,
		endPos
	};

	-- Render beam effect.
	WGL.ViewModelProjection(!isLocal, weapon.ViewModelFOV, self.DrawBeam, self, points);
end