
WGL = WGL || {};

function WGL.SetColor(color, value)
	color:SetUnpacked(value:Unpack());
	return color;
end

function WGL.LerpColorRaw(t, r1, g1, b1, a1, r2, g2, b2, a2, out)

	local r = Lerp(t, r1, r2);
	local g = Lerp(t, g1, g2);
	local b = Lerp(t, b1, b2);
	local a = Lerp(t, a1 || 255, a2 || 255);

	if (out) then
		out:SetUnpacked(r, g, b, a);
		return out;
	end

	return Color(r, g, b, a);
end

function WGL.LerpColor(t, from, to, out)
	return WGL.LerpColorRaw(t, from.r, from.g, from.b, from.a, to.r, to.g, to.b, to.a, out);
end

function WGL.LerpColorEventRaw(r1, g1, b1, a1, r2, g2, b2, a2, value, rate, event, state, callback)

	if (state.previous == nil) then
		state.fraction = 1;
		state.previous = value;
	end

	if (event == "increase" || event == "change") then
		if (value > state.previous) then
			state.fraction = 0;
			state.previous = value;
			state.event = "increase";
		else
			if (event != "change") then state.previous = value; end
		end
	end

	if (event == "decrease" || event == "change") then
		if (value < state.previous) then
			state.fraction = 0;
			state.previous = value;
			state.event = "decrease";
		else
			if (event != "change") then state.previous = value; end
		end
	end

	if (state.fraction < 1) then
		state.fraction = WGL.Clamp(state.fraction + FrameTime() * rate);
	end

	if (callback != nil) then
		callback(state.event, state.fraction);
	end

	state.color = WGL.LerpColorRaw(state.fraction, r2, g2, b2, a2, r1, g1, b1, a1, state.color);

	return state.color;
end

function WGL.LerpColorEvent(base, change, value, rate, event, state, callback)
	return WGL.LerpColorEventRaw(base.r, base.g, base.b, base.a, change.r, change.g, change.b, change.a, value, rate, event, state, callback);
end