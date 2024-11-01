
local BeamChange         = WGLComponent:New(POWERSUIT, "BeamChange");
BeamChange.Transition    = 1;
BeamChange.TransitionOut = false;
BeamChange.Hologram      = Material("entities/beam/ghost");
BeamChange.Models        = { ["Intersection"] = { Model("models/metroid/hud/v_beamchange.mdl"), RENDERGROUP_VIEWMODEL } };

function BeamChange:DrawTransition(weapon)

	local muzzle, ang, vm = WGL.GetViewModelAttachmentPos(1, weapon.ViewModelFOV);
	local forward         = ang:Forward();
	local beamTransition  = muzzle + forward * (-18.25 + 18.25 * self.Transition);

	-- Perform clipping of the normal beam.
	local beamClip = render.EnableClipping(true);
	render.DepthRange(0, 0.01);
	render.PushCustomClipPlane(-forward, -forward:Dot(beamTransition));
	vm:DrawModel();
	render.PopCustomClipPlane();
	render.EnableClipping(beamClip);

	-- Render intersection plane sprite.
	self:DrawModel("Intersection", beamTransition, ang, 0.7);

	-- Perform clipping of the holo beam.
	local ghostClip = render.EnableClipping(true);
	render.PushCustomClipPlane(forward, forward:Dot(beamTransition));
	render.MaterialOverride(self.Hologram);
	vm:DrawModel();
	render.MaterialOverride(nil);
	render.PopCustomClipPlane();
	render.EnableClipping(ghostClip);
	render.DepthRange(0, 1);
end

function BeamChange:Draw(weapon, beamData, eyePos, eyeAngles)

	-- Do nothing if viewmodel matches with current beam data.
	self.CurrentModel = self.CurrentModel || beamData.ViewModel;
	if (self.CurrentModel == beamData.ViewModel) then
		self.TransitionOut = false;
		self.Transition = 1;
		return;
	end

	-- Beam transitioning in.
	if (self.Transition <= 1 && !self.TransitionOut) then self.Transition = self.Transition - FrameTime() * 5.6; end

	-- Beam midtransition flag.
	if (self.Transition <= -1) then self.TransitionOut = true; end

	-- Beam transitioning out.
	if (self.TransitionOut) then self.Transition = self.Transition + FrameTime() * 5.6; end

	-- Transition complete, save current model to prevent overhead.
	if (self.Transition >= 1) then self.CurrentModel = beamData.ViewModel; end

	-- Prevent rendering if not in first person.
	if (!weapon.IsFirstPerson) then return; end

	local w = ScrW();
	local h = ScrH();
	self:PushRenderTexture("rt_MPBeamChange", w, h, {}, true);

		-- Render a world view on top of the screen in order to hide the default viewmodel.
		render.RenderView({
			origin = eyePos,
			angles = eyeAngles,
			x = 0, y = 0,
			w = w, h = h,
			drawviewmodel = false,
			dopostprocess = true
		});

		WGL.ViewModelProjection(false, self.DrawTransition, self, weapon);
		hook.Call("RenderScreenspaceEffects");

	render.PopRenderTarget();

	-- Render final result on the screen to show the beam change animation.
	WGL.Texture(self:GetRenderTexture("rt_MPBeamChange"), 0, 0, ScrW(), ScrH(), 255, 255, 255, 255);
end