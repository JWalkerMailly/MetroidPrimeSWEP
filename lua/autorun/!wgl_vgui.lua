
WGL = WGL || {};

function WGL.NumSlider(panel, text, command, bind, min, max, decimals, helpText)

	local slider = panel:NumSlider(text, nil, min, max, decimals);

	-- Override value changed to allow for concommands.
	slider.OnValueChanged = function(sender, value)
		if (!sender:IsEditing()) then return; end
		LocalPlayer():ConCommand(command .. " " .. tostring(math.Round(value, decimals)));
	end

	-- Handle value change in think hook using function bind.
	slider.Think = function()
		local val = bind();
		if (slider:GetValue() != val && !slider:IsEditing()) then slider:SetValue(val); end
	end

	if (helpText) then panel:ControlHelp(helpText); end
	return slider;
end

function WGL.CheckBox(panel, text, command, bind, helpText)

	local checkbox = panel:CheckBox(text, nil);

	-- Override value changed to allow for concommands.
	checkbox.OnChange = function(sender, value)
		LocalPlayer():ConCommand(command .. " " .. (value && "1" || "0"));
	end

	-- Handle value change in think hook using function bind.
	checkbox.Think = function()
		local val = bind();
		if (checkbox:GetValue() != val) then checkbox:SetChecked(val); end
	end

	if (helpText) then panel:ControlHelp(helpText); end
	return checkbox;
end