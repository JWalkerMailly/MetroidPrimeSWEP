
local empty         = Model("models/metroid/hud/beammenu/v_empty.mdl");
local BeamMenu      = WGLComponent:New(POWERSUIT, "BeamMenu");
BeamMenu.Positions  = {};
BeamMenu.Blend      = 1;
BeamMenu.Transition = 1;
BeamMenu.TextAlpha  = 0;
BeamMenu.TextTime   = CurTime();
BeamMenu.Models = {
	["Beam1"]  = POWERSUIT.Beams[1].ModelName,
	["Beam2"]  = POWERSUIT.Beams[2].ModelName,
	["Beam3"]  = POWERSUIT.Beams[3].ModelName,
	["Beam4"]  = POWERSUIT.Beams[4].ModelName,
	["Empty1"] = empty,
	["Empty2"] = empty,
	["Empty3"] = empty,
	["Empty4"] = empty
};

function BeamMenu:Initialize()
	self.Current  = nil;
	self.Previous = nil;
end

function BeamMenu:DrawText(beamData)

	if (self.Transition < 1) then
		self.TextTime = CurTime();
		self.TextAlpha = 0;
	end

	if (beamData == nil || CurTime() <= self.TextTime) then return; end
	local finished = WGL.AnimatedText(beamData.DisplayName, "Metroid Prime Visor UI", beamData.DisplayPos, 380, Color(104, 157, 185, self.TextAlpha * self.Blend), TEXT_ALIGN_LEFT, self.TextTime, 0.035);
	if (!finished) then self.TextAlpha = 255;
	else self.TextAlpha = Lerp(FrameTime() * 3, self.TextAlpha, 0); end
end

function BeamMenu:OverrideBlend(blend)
	self.Blend = blend || 1;
end

function BeamMenu:Draw(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)

	local currentBeam = weapon.ArmCannon:GetBeam();
	if (self.Current == nil) then
		self.Current  = currentBeam;
		self.Previous = currentBeam;
	end

	if (self.Current != currentBeam) then
		self.Previous   = self.Current;
		self.Current    = currentBeam;
		self.Transition = -1;
	end

	-- Transition state upon beam change.
	if (self.Transition < 1) then
		self.Transition = self.Transition + FrameTime() * 3;
	end

	-- Beam icons relative positions in 3D HUD.
	local beamMenuBlend   = blend * self.Blend;
	local beamMenuForward = pos + forward * (9 - fovCompensation * 19.2);
	local beamMenuCenter  = pos + forward * (5 - fovCompensation * 14.2) + up * 2.6 + right * -3.9;
	self.Positions[1]     = beamMenuForward + up * 2.7 + right * -1.7;
	self.Positions[2]     = beamMenuForward + forward * -1 + up * 1.2 + right * -0.6;
	self.Positions[3]     = beamMenuForward + up * -0.4 + right * -1.7;
	self.Positions[4]     = beamMenuForward + forward * 0.85 + up * 1.2 + right * -2.75;

	WGL.Start3D(widescreen);
	cam.IgnoreZ(true);

		-- Render empty beam icons.
		render.SetColorModulation(0.5, 0.5, 0.5);
		render.SetBlend(beamMenuBlend);
		for i = 1,4 do self:DrawModel("Empty" .. i, self.Positions[i], angle); end
		render.SetBlend(1);
		render.SetColorModulation(1, 1, 1);

		-- Handle beam menu transitions for current and previous beams.
		local beamTransition          = WGL.Clamp(self.Transition + 1);
		self.Positions[self.Current]  = LerpVector(WGL.Clamp(self.Transition), self.Positions[self.Current], beamMenuCenter);
		self.Positions[self.Previous] = LerpVector(beamTransition, beamMenuCenter, self.Positions[self.Previous]);

		-- Render beam menu icons.
		for i = 1,4 do
			if (!weapon.ArmCannon:IsBeamEnabled(i)) then render.SetBlend(0);
			else render.SetBlend(beamMenuBlend); end
			self:DrawModel("Beam" .. i, self.Positions[i], angle);
			render.SetBlend(1);
		end

		-- Flicker animation for selected beam upon change.
		if (beamTransition < 1) then
			local flicker = math.sin(CurTime() * 40);
			render.SetColorModulation(flicker, flicker, flicker)
			render.SetBlend(0.5 * beamMenuBlend);
			self:DrawModel("Beam" .. self.Current, self.Positions[self.Current], angle);
			render.SetBlend(1);
			render.SetColorModulation(1, 1, 1);
		end

	cam.End3D();
end