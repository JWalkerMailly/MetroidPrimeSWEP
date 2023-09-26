
local empty          = Model("models/metroid/hud/visormenu/v_empty.mdl");
local VisorMenu      = WGLComponent:New(POWERSUIT, "VisorMenu");
VisorMenu.Positions  = {};
VisorMenu.Blend      = 1;
VisorMenu.Transition = 1;
VisorMenu.TextAlpha  = 0;
VisorMenu.TextTime   = CurTime();
VisorMenu.Models = {
	["Visor1"] = POWERSUIT.Visors[1].ModelName,
	["Visor2"] = POWERSUIT.Visors[2].ModelName,
	["Visor3"] = POWERSUIT.Visors[3].ModelName,
	["Visor4"] = POWERSUIT.Visors[4].ModelName,
	["Empty1"] = empty,
	["Empty2"] = empty,
	["Empty3"] = empty,
	["Empty4"] = empty
};

function VisorMenu:Initialize()
	self.Current  = nil;
	self.Previous = nil;
end

function VisorMenu:DrawText(visorData)

	if (self.Transition < 1) then
		self.TextTime = CurTime();
		self.TextAlpha = 0;
	end

	if (visorData == nil || CurTime() <= self.TextTime) then return; end
	local finished = WGL.AnimatedText(visorData.DisplayName, "Metroid Prime Visor UI", 250, 380, Color(104, 157, 185, self.TextAlpha * self.Blend), TEXT_ALIGN_LEFT, self.TextTime, 0.035);
	if (!finished) then self.TextAlpha = 255;
	else self.TextAlpha = Lerp(FrameTime() * 3, self.TextAlpha, 0); end
end

function VisorMenu:OverrideBlend(blend)
	self.Blend = blend || 1;
end

function VisorMenu:Draw(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)

	local currentVisor = weapon.Helmet:GetVisor();
	if (self.Current == nil) then
		self.Current  = currentVisor;
		self.Previous = currentVisor;
	end

	if (self.Current != currentVisor) then
		self.Previous   = self.Current;
		self.Current    = currentVisor;
		self.Transition = -1;
	end

	-- Transition state upon visor change.
	if (self.Transition < 1) then
		self.Transition = self.Transition + FrameTime() * 3;
	end

	-- Visor icons relative positions in 3D HUD.
	local visorMenuBlend   = blend * self.Blend;
	local visorMenuForward = pos + forward * (9 - fovCompensation * 19.2);
	local visorMenuCenter  = pos + forward * (5 - fovCompensation * 14.2) + up * 2.6 + right * 3.9;
	self.Positions[1]      = visorMenuForward + up * 2.7 + right * 1.7;
	self.Positions[2]      = visorMenuForward + forward * -1 + up * 1.2 + right * 0.6;
	self.Positions[3]      = visorMenuForward + up * -0.4 + right * 1.7;
	self.Positions[4]      = visorMenuForward + forward * 0.85 + up * 1.2 + right * 2.75;

	WGL.Start3D(widescreen);
	cam.IgnoreZ(true);

		-- Render empty visor icons.
		render.SetColorModulation(0.5, 0.5, 0.5);
		render.SetBlend(visorMenuBlend);
		for i = 1,4 do self:DrawModel("Empty" .. i, self.Positions[i], angle); end
		render.SetBlend(1);
		render.SetColorModulation(1, 1, 1);

		-- Handle visor menu transitions for current and previous visors.
		local visorTransition         = WGL.Clamp(self.Transition + 1);
		self.Positions[self.Current]  = LerpVector(WGL.Clamp(self.Transition), self.Positions[self.Current], visorMenuCenter);
		self.Positions[self.Previous] = LerpVector(visorTransition, visorMenuCenter, self.Positions[self.Previous]);

		-- Render visor menu icons.
		for i = 1,4 do
			if (!weapon.Helmet:IsVisorEnabled(i)) then render.SetBlend(0);
			else render.SetBlend(visorMenuBlend); end
			self:DrawModel("Visor" .. i, self.Positions[i], angle);
			render.SetBlend(1);
		end

		-- Flicker animation for selected visor upon change.
		if (visorTransition < 1) then
			local flicker = math.sin(CurTime() * 40);
			render.SetColorModulation(flicker, flicker, flicker)
			render.SetBlend(0.5 * visorMenuBlend);
			self:DrawModel("Visor" .. self.Current, self.Positions[self.Current], angle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);
		end

	cam.End3D();
end