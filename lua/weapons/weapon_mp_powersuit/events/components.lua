
function POWERSUIT:GetBeam()
	local beamID = self.ArmCannon:GetBeam();
	return self.Beams[beamID], beamID;
end

function POWERSUIT:GetVisor()
	local visorID = self.Helmet:GetVisor();
	return self.Visors[visorID], visorID;
end

function POWERSUIT:GetSuit()
	local suitID = self.PowerSuit:GetSuit();
	return self.Suits[suitID], suitID;
end

function POWERSUIT:SetBeamModel(viewModel, beamData)

	-- Swap view model.
	self.ViewModel = beamData.ViewModel;
	viewModel:SetWeaponModel(beamData.ViewModel, self);

	-- Swap world model.
	self.WorldModel = beamData.WorldModel;
	self:SetModel(beamData.WorldModel);
end

function POWERSUIT:UndoVisor(key)

	-- If the current visor was hiding the beam menu, default back to the initial visor.
	local visorData = self:GetVisor()
	if (!visorData.ShouldHideBeamMenu) then return false; end

	-- Reset visor if attempting to use specified key.
	if (self:GetOwner():KeyPressed(key)) then
		self:ChangeVisor(self.Helmet.Constants.Visor.Initial);
		self.Helmet:Reset();
	end

	return true;
end

function POWERSUIT:CanRequestComponent(ignoreOpenState)

	local owner = self:GetOwner();

	return CurTime() > (self.ChangeComponentRequestedNextTime || 0)
		&& !owner:KeyDown(IN_ATTACK) && !owner:KeyDown(IN_DUCK) && !owner:InVehicle()
		&& self:GetNextPrimaryFire() < CurTime() && self:GetNextSecondaryFire() < CurTime()
		&& !self.ArmCannon:IsBusy(ignoreOpenState) && self.MorphBall:CanMorph() && !IsValid(self:GetMorphBall());
end

function POWERSUIT:StartChangeComponent(component, visorLayer)

	-- Propagate to server.
	self.ArmCannon:SetNextBeamChangeTime(CurTime());
	net.Start("POWERSUIT.ChangeComponent");
		net.WriteEntity(self);
		net.WriteFloat(component);
		net.WriteBool(visorLayer);
	net.SendToServer();
end

function POWERSUIT:ChangeBeam(beam)

	local visorData = self:GetVisor();
	if (visorData.ShouldHideBeamMenu) then return; end

	-- Stop charge beam to prevent overlaps.
	local beamData, currentBeam = self:GetBeam();
	self:StopChargeBeam(beamData);

	-- Statemachines.
	local enabled, open = self.ArmCannon:StartBeamChange(beam);
	if (open)     then self:CloseBeam(beamData, currentBeam != beam); end
	if (!enabled) then return; end
	self.ArmCannon:SetBeam(beam);

	-- Animations.
	if (currentBeam == beam) then return WSL.PlaySound(self.Beams, "equipped"); end
	WGL.SendViewModelAnimation(self, ACT_VM_DRAW);
	WSL.PlaySound(self.Beams, "change");
	if (!open && beamData.BeamCloseSound) then WSL.PlaySound(self.Beams, "close"); end

	-- Raise event.
	hook.Run("MP.OnBeamChanged", self, currentBeam, beam);
end

function POWERSUIT:ChangeVisor(visor)

	local visorData, currentVisor = self:GetVisor();
	if (visorData.ShouldHideBeamMenu) then self.Helmet:Reset(); end

	-- Handle invalid requests.
	self.ArmCannon:SetNextBeamChangeTime(CurTime());
	if (!self.Helmet:IsVisorEnabled(visor) || currentVisor == visor) then return; end

	-- Statemachines.
	local nextVisorData = self.Visors[visor];
	self:SetNextFire(nextVisorData.BeamDelay, nextVisorData.BeamDelay);
	self.Helmet:SetVisor(visor);
	self.Helmet:StartVisorLoop(false);

	-- Animations.
	WSL.StopSound(visorData, "ambient", 0.5);
	WSL.PlaySound(visorData, "change");

	-- Raise event.
	hook.Run("MP.OnVisorChanged", self, currentVisor, visor);
	if (visorData.ShouldHideBeamMenu)     then return WGL.SendViewModelAnimation(self, ACT_VM_LOWERED_TO_IDLE); end
	if (nextVisorData.ShouldHideBeamMenu) then
		self:CloseBeam(self:GetBeam(), true);
		return WGL.SendViewModelAnimation(self, ACT_VM_IDLE_TO_LOWERED);
	end
end

function POWERSUIT:ChangeComponentThink(beamData, viewModel)

	-- Delegate call to beam and visor handlers.
	self:ChangeBeamThink(beamData, viewModel);
	self:ChangeVisorThink();

	-- Prevents beam change from being called multiple times in one request.
	if (!CLIENT || gui.IsGameUIVisible() || !self:CanRequestComponent(true)) then return;
	else self.ChangeComponentRequestedNextTime = 0; end

	-- Determine which layer is being requested.
	local visorLayer     = input.IsKeyDown(self.SelectorLayerKey);
	local selectionLayer = self.Beams;
	if (visorLayer) then selectionLayer = self.Visors; end

	-- Begin net message to request a component change on the server.
	local gestureKey = self:GetGestureKey();
	for component,data in ipairs(selectionLayer) do
		local componentKey = tonumber(selectionLayer[component].Key);
		if (input.IsKeyDown(componentKey) || gestureKey == componentKey) then
			self.ChangeComponentRequestedNextTime = CurTime() + self.ArmCannon.Constants.Beam.Request;
			self:StartChangeComponent(component, visorLayer);
			self:ResetGesture();
			break;
		end
	end
end

function POWERSUIT:ChangeBeamThink(beamData)

	local viewModel = self:GetOwner():GetViewModel();
	if (!IsValid(viewModel) || viewModel:GetModel() == beamData.ViewModel || !self.ArmCannon:CanBeamChangeAnim() || !self.MorphBall:CanMorph()) then return; end

	-- Swap beam models if it does not match current data.
	-- Play draw animation in order to reset new model.
	self:SetBeamModel(viewModel, beamData);
	WGL.SendViewModelAnimation(self, ACT_VM_DRAW);

	-- Delayed events.
	local syncDelay = FrameTime() * 2;
	self.ArmCannon:SetNextBeamOpenTime(CurTime() + syncDelay);
	self.ArmCannon:SetNextBeamOpenAnimTime(CurTime() + syncDelay);
end

function POWERSUIT:ChangeVisorThink()

	if (self.Helmet:IsVisorLooping()) then return; end

	-- Animations.
	local visorData = self:GetVisor();
	self.Helmet:StartVisorLoop(true);
	WSL.PlaySound(visorData, "ambient", 0.5, 1);
end

local gestureDown  = Vector(0, 1, 0);
local gestureRight = Vector(1, 0, 0);
function POWERSUIT:GetGestureKey()

	if (!GetConVar("mp_options_gestures"):GetBool()) then return; end

	-- Do nothing if a gesture is currently being processed.
	local startGesture = input.IsKeyDown(self.GestureKey) || input.IsKeyDown(self.SelectorLayerKey);
	if (!startGesture)       then return self:ResetGesture(); end
	if (self.LastGestureSet) then return self.LastGestureKey; end

	-- Parse mouse movement.
	local owner = LocalPlayer();
	local gestureAlpha  = GetConVar("mp_options_gesturealpha"):GetFloat();
	self.LastGesture[1] = self.LastGesture[1] + (owner.__mp_MouseX || 0) * gestureAlpha;
	self.LastGesture[2] = self.LastGesture[2] + (owner.__mp_MouseY || 0) * gestureAlpha;

	-- Do nothing if movement was within deadzone.
	local deadZone = ScrH() * GetConVar("mp_options_gesturedzone"):GetFloat() * 0.5;
	if (self.LastGesture:Length() < deadZone) then return; end

	-- Parse gesture quadrant.
	local gestureUDot = self.LastGesture:Dot(gestureDown);
	local gestureRDot = self.LastGesture:Dot(gestureRight);
	local gestureSlot = math.abs(gestureUDot) > math.abs(gestureRDot)
		&& (gestureUDot < 0 && "1" || "3")
		|| (gestureRDot > 0 && "2" || "4");

	-- Parse gesture key from quadrant.
	self.LastGestureSet = true;
	self.LastGestureKey = owner:GetInfoNum("mp_controls_selector" .. gestureSlot, -1);
	return self.LastGestureKey;
end

function POWERSUIT:ResetGesture()
	self.LastGestureSet = false;
	self.LastGestureKey = nil;
	self.LastGesture[1] = 0;
	self.LastGesture[2] = 0;
end

-- Change component networking code.
if (SERVER) then util.AddNetworkString("POWERSUIT.ChangeComponent"); end
net.Receive("POWERSUIT.ChangeComponent", function(length, ply)

	local powersuit  = net.ReadEntity();
	local component  = net.ReadFloat();
	local visorLayer = net.ReadBool();

	-- Safety check in case the networked information is invalid.
	if (!IsValid(powersuit) || powersuit:GetOwner() != ply) then return; end

	-- Determine which layer the request was for, either weapon or visor.
	if (!visorLayer) then powersuit:ChangeBeam(component);
	else powersuit:ChangeVisor(component); end
end);