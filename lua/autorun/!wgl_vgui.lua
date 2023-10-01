
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

function WGL.KeyMap(panel, text, convar, helpText)

	-- Create key map title.
	local dFormKeyLabel = vgui.Create("DLabel", panel);
	dFormKeyLabel:DockMargin(8, 8, 8, 0);
	dFormKeyLabel:Dock(TOP);
	dFormKeyLabel:SetText(text);
	panel:AddItem(panel);

	-- Create key map bound to convar.
	local dFormKey = vgui.Create("DBinder", panel);
	dFormKey:SetValue(LocalPlayer():GetInfo(convar));
	dFormKey:SetConVar(convar);
	panel:AddItem(dFormKey);

	if (helpText) then panel:ControlHelp(helpText); end
	return dFormKey;
end