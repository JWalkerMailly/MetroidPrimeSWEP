
WGL = WGL || {};

function WGL.SetColor(color, value)
	color:SetUnpacked(value:Unpack());
	return color;
end

function WGL.LerpColor(t, from, to)
	return Color(
		Lerp(t, from.r, to.r),
		Lerp(t, from.g, to.g),
		Lerp(t, from.b, to.b),
		Lerp(t, from.a || 255, to.a || 255)
	);
end

function WGL.LerpColorEvent(base, change, value, rate, event, state, callback)

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

	return WGL.LerpColor(state.fraction, change, base);
end