
WGL = WGL || {};

function WGL.Perspective(widescreenFix, xPan, yPan, drawDelegate, ...)

	local noclip = WGL.Start3D(widescreenFix, 54, true);

		-- Turn eye angles to orient screen.
		local ang = EyeAngles();
		ang:RotateAroundAxis(ang:Right(), 90);

		-- Prepare screen angle for perspective.
		local dx = ang:Right();
		local dy = ang:Forward();
		local screenAng = dx:AngleEx(dx:Cross(dy));

		-- Apply perspective.
		if (xPan) then screenAng:RotateAroundAxis(screenAng:Right(),   xPan); end
		if (ypan) then screenAng:RotateAroundAxis(screenAng:Forward(), yPan); end

		-- Draw in perspective.
		cam.Start3D2D(EyePos() - EyeAngles():Forward() * -1000, screenAng, 1);
			drawDelegate(...);
		cam.End3D2D();

	DisableClipping(noclip);
	cam.End3D();
end

function WGL.ViewModelProjection(ignore, fov, drawDelegate, ...)

	-- Render in currently active projection space if needed.
	if (ignore) then return drawDelegate(...); end

	-- Render in viewmodel projection space.
	WGL.Start3D(false, fov || 62);
		drawDelegate(...);
	cam.End3D();
end

function WGL.ToViewModelProjection(pos, vmfov, fov, from, owner)

	local ply     = owner || LocalPlayer();
	local result  = ply:EyePos();
	local eyeAng  = ply:EyeAngles();
	local offset  = pos - result;
	local forward = eyeAng:Forward();
	local right   = eyeAng:Right();
	local up      = eyeAng:Up();
	local worldX  = math.tan((fov || ply:GetFOV()) * math.pi / 360);
	local viewX   = math.tan((vmfov || 62) * math.pi / 360);

	if (viewX == 0 || worldX == 0) then
		forward:Mul(forward:Dot(offset));
		result:Add(forward);
		return result;
	end

	local factor = from && (worldX / viewX) || (viewX / worldX);
	right:Mul(right:Dot(offset) * factor);
	up:Mul(up:Dot(offset) * factor);
	forward:Mul(forward:Dot(offset));
	result:Add(right);
	result:Add(up);
	result:Add(forward);
	return result;
end

function WGL.ToScreenFOV(pos, newFOV, oldFOV, w, h)

	local fov           = LocalPlayer():GetFOV();
	local screen        = pos:ToScreen();
	local width, height = w || ScrW(), h || ScrH();
	local aspect        = WGL.GetViewAspect(fov, w, h);
	local deltaFOV      = WGL.GetViewFOV((oldFOV || WGL.GetViewFOV(fov, width, height)) - newFOV, width, height, aspect) / 62;

	return {
		x = screen.x - (width / 2 - screen.x) * deltaFOV,
		y = screen.y - (height / 2 - screen.y) * deltaFOV
	}
end

function WGL.Start3D(widescreenFix, fov, noclip)

	local x, y       = 0, 0;
	local w, h       = ScrW(), ScrH();
	local origin     = EyePos();
	local angles     = EyeAngles();
	local _fov       = fov || LocalPlayer():GetFOV();
	local viewFOV    = widescreenFix && _fov || WGL.GetViewFOV(_fov, w, h);
	local viewAspect = widescreenFix && (WGL.Scaling.Width / WGL.Scaling.Height) || (w / h);

	cam.Start({ x = x, y = y, w = w, h = h, origin = origin, angles = angles, fov = viewFOV, aspect = viewAspect });

	-- Disable clipping if intended to be used for UI.
	if (noclip) then return DisableClipping(true); end
end

function WGL.GetViewFOV(fov, w, h, aspect)

	local _fov    = fov || 62;
	local _w      = w || ScrW();
	local _h      = h || ScrH();
	local _aspect = aspect || (WGL.Scaling.Width / WGL.Scaling.Height);
	return 360 / math.pi * math.atan(math.tan(_fov * math.pi / 360) * (_w / _h) / _aspect);
end

function WGL.GetViewAspect(fov, w, h)

	-- These are approximations and are not based on the actual view * model space projection.
	local delta  = (fov - 75) / 25;
	local aspect = 1.45 * math.log(w / h) + 0.61;
	return aspect + delta * (-0.129 * (aspect * aspect) - 0.093 * aspect + 0.282);
end