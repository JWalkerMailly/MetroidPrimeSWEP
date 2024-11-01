
function POWERSUIT:ResetCamera(ply)
	if (!IsValid(ply)) then return; end
	ply.__mp_FOVTransition = ply:GetFOV();
	ply.__mp_CameraTransition = 1;
end

function POWERSUIT:GetWalkBob(speed)
	return (LocalPlayer():OnGround() && LocalPlayer():GetVelocity():LengthSqr() > 2500) && math.sin(CurTime() * 17.422 * (speed || 1)) * 0.08 || 0;
end

function POWERSUIT:GetViewPunch(fov)

	-- Apply view punch positioning based on last networked data.
	self.LastViewPunch = Lerp(FrameTime() * 8, self.LastViewPunch, self.ArmCannon:GetViewPunch());
	return fov + self.LastViewPunch * 0.3;
end

function POWERSUIT:HandleMaterialOverrides(visor)

	for k,v in pairs(game.MetroidPrimeMaterialSwaps) do

		-- Apply material swap to valid entities.
		local override = visor.MaterialFilter(v);
		if (override) then
			v:SetMaterial(override);
			v.__mp_VisorOverride = true;
			continue;
		end

		-- Entity visor rules changed, reset material.
		if (v.__mp_VisorOverride) then
			v:SetMaterial(v:GetMaterial());
			v.__mp_VisorOverride = false;
		end
	end

	self.CleanupMaterials = true;
end

function POWERSUIT:CleanupMaterialOverrides()

	-- Remove color manipulation projection.
	if (IsValid(self.ProjectedTexture)) then
		self.ProjectedTexture:Remove();
		self.ProjectedTexture = nil;
	end

	if (!self.CleanupMaterials) then return; end
	for k,v in pairs(game.MetroidPrimeMaterialSwaps) do

		if (!v.__mp_VisorOverride) then continue; end

		-- Fallback to default texture.
		v:SetMaterial(v:GetMaterial());
		v.__mp_VisorOverride = false;
	end

	self.CleanupMaterials = false;
end

function POWERSUIT:ShouldResetView(ply)

	-- Prevent HUD and Beam sway if desired.
	if (!GetConVar("mp_options_hudsway"):GetBool()) then return true; end

	-- If we are moving, or our view is moving, or we are attacking, the view should reset.
	local mouseAction   = ply:KeyDown(IN_ATTACK) || ply:KeyDown(IN_ATTACK2);
	local movement      = ply:GetVelocity():LengthSqr() > 2500 || ply:KeyDown(IN_SPEED);
	local cursorPos     = Vector(input.GetCursorPos(), 0);
	local mouseMovement = cursorPos != self.LastCursorPos;
	local shouldReset   = mouseAction || movement || mouseMovement;

	-- Snap back to center angle during player input.
	self.ViewResetSpeed = shouldReset && 50 || 0.5;
	self.LastCursorPos  = cursorPos;
	return shouldReset;
end

function POWERSUIT:GetRandomViewAngle(maxPitch, maxYaw, pitchMod, yawMod, speed, container, maxDuration, maxWait)

	-- Calculate random modulation for sway effect.
	local randomSway = Angle(0, 0, 0);
	randomSway.p = WGL.Modulation(pitchMod, speed) * maxPitch;
	randomSway.y = WGL.Modulation(yawMod, speed) * maxYaw;

	if (CurTime() > container.Time) then

		-- This portion is responsible for switching states between a random angle and the default angle.
		if (container.Duration == nil) then container.Duration = CurTime() + math.Rand(maxDuration / 2, maxDuration); end
		if (CurTime() > container.Duration) then
			container.Duration = nil;
			container.Time = CurTime() + math.Rand(maxWait / 2, maxWait);
		end
	end

	-- Lerp between our random angle and the default angle (0, 0, 0) based on the current lerp factor.
	if (CurTime() < container.Time) then container.Lerp = Lerp(FrameTime() * self.ViewResetSpeed, container.Lerp, 0);
	else container.Lerp = Lerp(FrameTime() * 0.75, container.Lerp, 1); end
	return Lerp(container.Lerp, Angle(0, 0, 0), randomSway);
end

function POWERSUIT:LockView(ply)

	-- Handle lock on.
	local target, _, locked = self.Helmet:GetTarget(IN_SPEED);
	if (locked) then

		-- Handle lock on here in order to sync up with server. Don't update the view if we are locked onto a grapple anchor.
		local grappling = self.PowerSuit:IsGrappling() || self.PowerSuit:Grappled();
		local lockAngle = (!grappling || !target:IsGrappleAnchor()) && (target:GetLockOnPosition() - ply:EyePos()):Angle() || self.Helmet:GetLockAngle();
		ply:SetEyeAngles(lockAngle);

		return lockAngle;
	end
end

function POWERSUIT:CalcView(ply, pos, angle, fov)

	if (self:ShouldResetView(ply)) then
		self.ViewSway.Time     = CurTime() + math.Rand(6, 12);
		self.ViewSway.Duration = nil;
	end

	-- Compute final view angle based on modulated sway.
	self.LastViewSway  = self:GetRandomViewAngle(2.5, 10, 8, 11, 4, self.ViewSway, 12, 12);
	local finalAngle   = angle + self.LastViewSway;

	return pos, self:LockView(ply) || finalAngle, self:GetViewPunch(fov);
end

function POWERSUIT:GetViewModelRollPos(deg, angle)

	-- Magic values were calculated using Blender and the actual MDL.
	local translationAngle = math.rad(36.38 + deg * -1);
	local right = 5.6 - math.sin(translationAngle) * 9.4;
	local up = 7.6 - math.cos(translationAngle) * 9.4;
	return angle:Right() * right - angle:Up() * up;
end

function POWERSUIT:GetViewModelPosition(pos, angle)

	if (self:ShouldResetView(self:GetOwner())) then
		self.ViewModelSway.Time     = CurTime() + math.Rand(8, 16);
		self.ViewModelSway.Duration = nil;
	end

	-- Maintain viewmodel FOV setting.
	self.ViewModelFOV = GetConVar("mp_options_viewmodelfov"):GetInt();

	-- Compute final viewmodel angle based on sway and breathing.
	local breathing        = Angle(math.ease.InOutSine(math.sin(CurTime() * 1.2)) / 2, 0, 0);
	self.LastViewModelSway = self:GetRandomViewAngle(5, 7.5, 11, 8, 4, self.ViewModelSway, 12, 24);

	local owner            = self:GetOwner();
	local finalAngle       = (self:LockView(owner) || angle) + breathing + self.LastViewSway + self.LastViewModelSway;

	-- Get newest beam roll and decide if we should start rolling the viewmodel.
	local beamRoll = self.ArmCannon:GetBeamRoll();
	local beamRollBuffer = math.abs(beamRoll) - self.ViewModelRollBuffer;
	if (self.ViewModelRoll != beamRoll) then
		self.ViewModelRoll = beamRoll;
		self.ViewModelRollCompleted = false;
	end

	-- Roll not completed, lerp our current roll towards the newest roll.
	if (!self.ViewModelRollCompleted && math.abs(self.LastViewModelRoll) < beamRollBuffer) then
		self.LastViewModelRoll = Lerp(FrameTime() * 10, self.LastViewModelRoll, beamRoll);
	end

	-- Roll completed, set flag.
	if (math.abs(self.LastViewModelRoll) >= beamRollBuffer) then
		self.ViewModelRollCompleted = true;
	end

	-- Roll completed flag raised, begin lerping our roll back to 0 (initial).
	if (self.ViewModelRollCompleted) then
		self.LastViewModelRoll = Lerp(FrameTime() * 10, self.LastViewModelRoll, 0);
	end

	-- Compute viewmodel bob.
	local weaponBob = LerpVector(FrameTime() * 17.422, self.LastBobPos || Vector(0, 0, 0), angle:Right() * self:GetWalkBob(0.5) * 3 + Vector(0, 0, self:GetWalkBob() * 4));
	self.LastBobPos = weaponBob;

	-- Apply final roll and compute viewmodel position in local projection space.
	finalAngle.r = self.LastViewModelRoll;
	return pos + self:GetViewModelRollPos(self.LastViewModelRoll, angle) + self.LastBobPos, finalAngle;
end

function POWERSUIT:DrawViewModelEffects(vm, ply)

	-- Render viewmodel charge effects after drawing the viewmodel.
	local beamData = self:GetBeam();
	local reset    = self.ArmCannon:GetNextMissileComboResetTime();
	local combo    = reset != 0 && reset < CurTime();
	local ratio    = self.ArmCannon:GetChargeRatio();

	if (ratio == 0) then ratio = WGL.Clamp(1 - self.ArmCannon:GetMissileComboStartRatio() / 1.5); end
	if (ratio > 0) then

		local muzzle, ang = WGL.GetViewModelAttachmentPos(1, self.ViewModelFOV, nil, false, ply);
		if (beamData.Charge3DEffect) then
			WGL.Component(self, beamData.Charge3DEffect, muzzle, ang, ratio, beamData.ChargeBallColor);
		end

		-- Render 3D charge ball on end muzzle.
		if (ratio > 0.1 || combo) then
			if (beamData.ChargeBallColor) then WGL.Component(self, "ChargeBall", muzzle, ang, ratio, beamData.ChargeBallColor); end
		end

		-- Emit light during charge or during looping combo.
		local charge = (!combo && ratio || 1) * (math.sin(CurTime() * 10) / 4 + 0.75);
		if (!combo || (combo && beamData.ComboLoopDelay != nil)) then
			WGL.EmitLight(self, muzzle, beamData.ChargeColor, 0, charge * 100, CurTime() + 0.1, 6);
			WGL.EmitLight(vm, muzzle, beamData.ChargeColor, 0, charge * beamData.ChargeGlowSize, CurTime() + 0.1, 6, true);
		end
	else
		if (beamData.Charge3DEffect) then
			WGL.GetComponent(self, beamData.Charge3DEffect):Initialize();
		end
	end

	-- Handle ambient particle effects. Attach it to the viewmodel so emission stops when the model is changed.
	if (!IsValid(self.AmbientEffect) && beamData.AmbientEffect != nil && self.ArmCannon:CanBeamChange()) then
		self.AmbientEffect = CreateParticleSystem(vm, beamData.AmbientEffect, PATTACH_POINT_FOLLOW, 1);
		self.AmbientEffect:StartEmission();
	end

	-- Handle charge particle effects on beam.
	if (!IsValid(self.ChargeEffect) && self.ArmCannon:ChargeStarted()) then
		self.ChargeEffect = CreateParticleSystem(vm, beamData.ChargeEffect, PATTACH_POINT_FOLLOW, 1);
		self.ChargeEffect:StartEmission();
	end

	-- Stop charge effects when not charging.
	if (IsValid(self.ChargeEffect) && !self.ArmCannon:IsCharging()) then
		self.ChargeEffect:StopEmissionAndDestroyImmediately();
	end
end

function POWERSUIT:RenderScreen()
	self.IsFirstPerson = self.PostDrawViewModelRan;
	self.PostDrawViewModelRan = false;
end

function POWERSUIT:PreDrawViewModel(vm, weapon, ply)

	local visor = self:GetVisor();
	if (visor.ViewModelMaterials == nil) then return; end

	-- Override view model materials during render pass according to visor.
	if (visor.ViewModelExceptions != nil && visor.ViewModelExceptions[self.ArmCannon:GetBeam()]) then return; end
	render.MaterialOverrideByIndex(0, Material(visor.ViewModelMaterials .. "MAT_0_5")); -- Stripes
	render.MaterialOverrideByIndex(1, Material(visor.ViewModelMaterials .. "MAT_0_2")); -- Inner glow
	render.MaterialOverrideByIndex(2, Material(visor.ViewModelMaterials .. "MAT_0_7")); -- Buttons
	render.MaterialOverrideByIndex(3, Material(visor.ViewModelMaterials .. "MAT_0_0")); -- Core
	render.MaterialOverrideByIndex(4, Material(visor.ViewModelMaterials .. "MAT_0_4")); -- Sides
	render.MaterialOverrideByIndex(5, Material(visor.ViewModelMaterials .. "MAT_0_6")); -- Button canister
	render.MaterialOverrideByIndex(6, Material(visor.ViewModelMaterials .. "MAT_0_1")); -- Barrel
	render.MaterialOverrideByIndex(7, Material(visor.ViewModelMaterials .. "MAT_0_3")); -- Top
end

function POWERSUIT:PostDrawViewModel(vm, weapon, ply)

	-- Reset armcannon materials.
	render.MaterialOverrideByIndex(0, nil);
	render.MaterialOverrideByIndex(1, nil);
	render.MaterialOverrideByIndex(2, nil);
	render.MaterialOverrideByIndex(3, nil);
	render.MaterialOverrideByIndex(4, nil);
	render.MaterialOverrideByIndex(5, nil);
	render.MaterialOverrideByIndex(6, nil);
	render.MaterialOverrideByIndex(7, nil);
	self:DrawViewModelEffects(vm, ply);
	self.PostDrawViewModelRan = true;
end