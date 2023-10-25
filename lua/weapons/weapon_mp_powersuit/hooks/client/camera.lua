
local morphBallCameraOffset = 5;
local morphBallCameraRadius = 155;

function POWERSUIT:ResetCamera()
	local owner = self:GetOwner();
	if (!IsValid(owner)) then return; end
	owner.__mp_FOVTransition = owner:GetFOV();
	owner.__mp_CameraTransition = 1;
end

hook.Add("CreateMove", "POWERSUIT.CameraMove", function(cmd)

	-- Keep mouse movement reference for rendering operations.
	LocalPlayer().__mp_MouseX = cmd:GetMouseX();
	LocalPlayer().__mp_MouseY = cmd:GetMouseY();
end);

hook.Add("InputMouseApply", "POWERSUIT.LockCamera", function(cmd)

	local isPowerSuit, weapon = LocalPlayer():UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Prevent mouse movement when locked onto a target.
	local _, _, locked = weapon.Helmet:GetTarget(IN_SPEED);
	local gesture = GetConVar("mp_options_gestures"):GetBool() && (input.IsKeyDown(weapon.GestureKey) || input.IsKeyDown(weapon.SelectorLayerKey)) || false;
	if (locked || gesture) then
		cmd:SetMouseX(0);
		cmd:SetMouseY(0);
		return true;
	end

	return false;
end);

hook.Add("CalcView", "POWERSUIT.CameraView", function(ply, viewPos, angles, fov)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Setup camera data for transitions.
	ply.__mp_LastViewPos      = ply.__mp_LastViewPos      || viewPos;
	ply.__mp_LastViewAngles   = ply.__mp_LastViewAngles   || angles;
	ply.__mp_CameraTransition = ply.__mp_CameraTransition || 1;

	-- Setup default view.
	local view = {
		origin       = viewPos,
		angles       = angles,
		fov          = ply.__mp_FOVTransition,
		drawviewer   = false
	};

	-- Delegate view rendering to morphball when we enter the vehicle.
	local vehicle = ply:GetVehicle();
	if (IsValid(weapon:GetMorphBall()) && IsValid(vehicle)) then
		ply.__mp_LastViewPos      = viewPos;
		ply.__mp_LastViewAngles   = angles;
		ply.__mp_CameraTransition = 0;
		return hook.Run("CalcVehicleView", vehicle, ply, view);
	end

	-- Camera transition out of morphball and into powersuit.
	ply.__mp_FOVTransition = Lerp(FrameTime() * 5, ply.__mp_FOVTransition || fov, ply:GetFOV());
	if (ply.__mp_CameraTransition < 1) then
		ply.__mp_CameraTransition = ply.__mp_CameraTransition + FrameTime() * 1.5;
		view.origin     = LerpVector(ply.__mp_CameraTransition, ply.__mp_LastViewPos, viewPos);
		view.angles     = LerpAngle(ply.__mp_CameraTransition, ply.__mp_LastViewAngles, angles);
		view.drawviewer = true;
		return view;
	end
end);

hook.Add("CalcVehicleView", "MORPHBALL.CameraView", function (vehicle, ply, view)

	-- Wait for morphball to be fully initialized before processing this hook.
	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall() || !morphball.Initialized) then return; end

	local pos        = morphball:GetPos();
	local min        = WGL.OneVec * -morphBallCameraOffset;
	local max        = WGL.OneVec * morphBallCameraOffset;
	local fov        = 75 + math.Clamp(25 * (morphball:GetClientVelocity():Length() / morphball.MaxSpeed), 0, 25);
	local filter     = { ply, vehicle, morphball };

	-- Perform bound trace from morphball to camera position.
	local boundTrace = util.TraceHull({
		start        = pos,
		endpos       = pos + view.angles:Forward() * -morphBallCameraRadius,
		mins         = min,
		maxs         = max,
		filter       = filter,
		mask         = MASK_PLAYERSOLID_BRUSHONLY
	});

	-- Perform bound trace from camera position and up towards final view point.
	local upTrace    = util.TraceHull({
		start        = boundTrace.HitPos,
		endpos       = boundTrace.HitPos + WGL.UpVec * morphball.Radius * 2.5,
		mins         = min,
		maxs         = max,
		filter       = filter,
		mask         = MASK_PLAYERSOLID_BRUSHONLY
	});

	ply.__mp_FOVTransition = morphball:GetOnGround() && Lerp(FrameTime() * 2, ply.__mp_FOVTransition || view.fov, fov) || ply.__mp_FOVTransition;
	local finalView  = {
		origin       = upTrace.HitPos;
		angles       = view.angles + Angle(10, 0, 0);
		fov          = ply.__mp_FOVTransition,
		drawviewer   = false;
	};

	-- Setup camera transition data.
	morphball.__mp_CameraTransition = morphball.__mp_CameraTransition || 0;
	if (morphball.__mp_CameraTransition < 1) then
		morphball.__mp_CameraTransition = morphball.__mp_CameraTransition + FrameTime() * 1.4;
		finalView.origin = LerpVector(morphball.__mp_CameraTransition, ply.__mp_LastViewPos, finalView.origin);
		finalView.angles = LerpAngle(morphball.__mp_CameraTransition, ply.__mp_LastViewAngles, finalView.angles);
	end

	-- Update vehicle view and keep reference for transitions later.
	morphball:SetVehicleViewPos(finalView.origin);
	ply.__mp_LastViewPos    = finalView.origin;
	ply.__mp_LastViewAngles = finalView.angles;
	return finalView;
end);