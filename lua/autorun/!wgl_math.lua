
WGL = WGL || {};

function WGL.RandomInt(min, max, seed)
	return math.Clamp(math.floor(util.SharedRandom("WGL", min, max + 1, seed)), min, max);
end

function WGL.Clamp(value)
	return math.Clamp(value, 0, 1);
end

function WGL.GetDeltaTime(entity)

	-- Used to fix frametime during entity draw calls.
	if (entity.__wgl_FrameTime == nil) then entity.__wgl_FrameTime = CurTime(); end
	local frametime = CurTime() - entity.__wgl_FrameTime;
	entity.__wgl_FrameTime = CurTime();

	return frametime;
end

function WGL.ClampAngle(angle, target, yaw, pitch, roll, delta)

	-- Make a copy of the original angle to avoid modifying it.
	local result = Angle(angle[1], angle[2], angle[3]);
	if (math.AngleDifference(angle[1], target[1]) > pitch) then result[1] = target[1] + pitch; end
	if (math.AngleDifference(angle[2], target[2]) > yaw)   then result[2] = target[2] + yaw;   end
	if (math.AngleDifference(angle[3], target[3]) > roll)  then result[3] = target[3] + roll;  end
	if (math.AngleDifference(target[1], angle[1]) > pitch) then result[1] = target[1] - pitch; end
	if (math.AngleDifference(target[2], angle[2]) > yaw)   then result[2] = target[2] - yaw;   end
	if (math.AngleDifference(target[3], angle[3]) > roll)  then result[3] = target[3] - roll;  end
	return LerpAngle(delta || 1, result, angle);
end

function WGL.DelayedLerp(value, rate, delay, state, reset)

	-- Setup lerp storage, this trick forces pass by reference for the lerp parameter.
	if (state.value == nil || reset) then
		state.value = value;
		state.next = 0;
	end

	if (value < state.value) then
		if (state.next == 0) then
			state.next = CurTime() + delay;
		end
		if (CurTime() > state.next) then
			state.value = state.value - FrameTime() * rate;
		end
	else
		state.value = value;
		state.next = 0;
	end

	return state.value;
end

function WGL.Modulation(mod, rate, seed)

	local dirA  = ((mod % 2) == 0) && -1 || 1;
	local dirB  = (((mod % 7) % 2) == 0) && -1 || 1;
	local dirC  = (((mod % 3) % 2) == 0) && -1 || 1;
	local cellA = ((3 + mod * 7) % 13) * 0.029;
	local cellB = ((7 + mod * 11) % 23) * 0.017;
	local cellC = ((11 + mod * 3) % 37) * 0.007;

	return math.sin(CurTime() * cellA * dirA * rate + cellB * dirB * rate + (seed || 33))
		 * math.sin(CurTime() * cellB * dirC * rate + cellC * dirC * rate + (seed || 33))
		 * math.sin(CurTime() * cellC * dirA * rate + cellA * dirB * rate + (seed || 33));
end

function WGL.GoldenSpiralSpherePoints(count, offset, radius)

	local points = {};
	for i = 0,count do
		local phi     = math.acos(1 - 2 * (i + offset) / count);
		local theta   = math.pi * (1 + math.pow(5, offset)) * i;
		local x, y, z = math.cos(theta) * math.sin(phi) * radius, math.sin(theta) * math.sin(phi) * radius, math.cos(phi) * radius;
		table.insert(points, i + 1, Vector(x, y, z));
	end

	return points;
end

function WGL.SurfaceMarchingTrace(start, endpos, dir, nav, up, filter, mask)

	local surfaceTrace = util.TraceLine({
		start  = start,
		endpos = endpos,
		filter = filter,
		mask   = mask || MASK_PLAYERSOLID
	});

	-- We didn't hit anything, return last known results.
	local hitPos  = surfaceTrace.HitPos;
	if (!surfaceTrace.Hit) then return false, hitPos; end

	-- Prepare surface direction variables.
	local normal  = surfaceTrace.HitNormal;
	local right   = dir:AngleEx(up):Right();
	local degrees = nav * math.Round(math.deg(normal:Dot(right)), 2);
	local ang     = dir:AngleEx(up);

	-- Return surface marching data.
	if (degrees != 0) then ang:RotateAroundAxis(normal, degrees); end
	local forward = normal:Cross(ang:Right());
	return true, hitPos, forward, normal, forward:AngleEx(normal);
end

function WGL.SurfaceMarching(pos, dir, up, step, depth, filter, iterations, result, mask, i, stepper)

	-- Initialize recursive parameters.
	i = i || 0;
	if ((stepper && !stepper(i, pos, dir, up)) || i >= iterations) then return result end

	-- March concave surfaces.
	local start  = pos + up * depth;
	local endpos = pos + dir * step - up * depth;
	local hit, hitPos, forward, normal, ang = WGL.SurfaceMarchingTrace(start, endpos, dir, -1, up, filter, mask);
	if (hit) then
		table.insert(result, i + 1, { hitPos, ang });
		debugoverlay.Axis(hitPos, ang, 10, 10);
		return WGL.SurfaceMarching(hitPos, forward, normal, step, depth, filter, iterations, result, mask, i + 1, stepper);
	end

	-- March convex surfaces.
	endpos = hitPos - dir * step;
	hit, hitPos, forward, normal, ang = WGL.SurfaceMarchingTrace(hitPos, endpos, dir, 1, up, filter, mask);
	if (hit) then
		table.insert(result, i + 1, { hitPos, ang });
		debugoverlay.Axis(hitPos, ang, 10, 10);
		return WGL.SurfaceMarching(hitPos, forward, normal, step, depth, filter, iterations, result, mask, i + 1, stepper);
	end

	return result;
end

function WGL.Bezier(t, points, i, c)

	-- Initialize recursive parameters.
	if (i == nil) then i, c = 1, #points; end
	if (c == 1)   then return points[i]; end

	-- Recursively lerp given control points in order to approximate bezier position along spline.
	return WGL.Bezier(t, points, i, c - 1) * (1 - t) + WGL.Bezier(t, points, i + 1, c - 1) * t;
end

function WGL.Bezier2(t, p0, p1, p2, p3)
	
	local t1 = 1 - t;
	return t1 * t1 * t1 * p0
		+ 3 * t1 * t1 * t * p1
		+ 3 * t1 * t * t * p2
		+ t * t * t * p3;
end