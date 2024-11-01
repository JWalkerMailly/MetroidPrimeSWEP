
function POWERSUIT:AutoSave()
	if (GetConVar("mp_cheats_autosave"):GetBool()) then self:SaveState(true); end
end

function POWERSUIT:LoadControls()
	local owner = self:GetOwner();
	self.GestureKey       = owner:GetInfoNum("mp_controls_gesture",       81);
	self.SelectorLayerKey = owner:GetInfoNum("mp_controls_selectorlayer", 15);
	self.Beams[1].Key     = owner:GetInfoNum("mp_controls_selector1",     88);
	self.Beams[2].Key     = owner:GetInfoNum("mp_controls_selector2",     91);
	self.Beams[3].Key     = owner:GetInfoNum("mp_controls_selector3",     90);
	self.Beams[4].Key     = owner:GetInfoNum("mp_controls_selector4",     89);
	self.Visors[1].Key    = owner:GetInfoNum("mp_controls_selector1",     88);
	self.Visors[2].Key    = owner:GetInfoNum("mp_controls_selector4",     89);
	self.Visors[3].Key    = owner:GetInfoNum("mp_controls_selector3",     90);
	self.Visors[4].Key    = owner:GetInfoNum("mp_controls_selector2",     91);
end

function POWERSUIT:LoadState(config)

	-- We auto load state once per instance.
	if (self.StateIdentifier != nil && config == nil) then return false; end

	-- Reload controls.
	self:LoadControls();

	-- Bootloader identifier.
	local owner = self:GetOwner();
	local steamID = owner:SteamID64();
	self.StateIdentifier = steamID;

	-- Apply base energy tanks.
	if (!SERVER) then return false; end
	owner:SetHealth(self.Helmet:GetEnergy() * 100 + 99);
	owner:SetMaxHealth(self.Helmet:GetMaxEnergy() * 100 + 99);

	-- Save states loading.
	local saveState = nil;
	if (config == nil) then

		if (!self:GetLoadSaveFile()) then return false; end
		local savePath = self.SavePath .. "/" .. steamID;
		local saveFile = savePath .. "/powersuit.json";

		-- If this is the first state instance, create it.
		if (!file.Exists(saveFile, "DATA")) then
			file.CreateDir(savePath);
			self:SaveState();
		end

		-- Load the previous known state onto the powersuit.
		local state = file.Read(saveFile);
		if (state == nil) then return false; end
		saveState = util.JSONToTable(state);
	else

		-- Use the provided sate configuration file.
		saveState = config;
	end

	-- Refresh state cache.
	self.Helmet:LoadState(saveState.Helmet);
	self.PowerSuit:LoadState(saveState.PowerSuit);
	self.ArmCannon:LoadState(saveState.ArmCannon);
	self.MorphBall:LoadState(saveState.MorphBall);

	-- Swap beam models now.
	local beamData  = self:GetBeam();
	local viewModel = owner:GetViewModel();
	self:SetBeamModel(viewModel, beamData);

	-- Apply energy tanks from configuration file.
	owner:SetHealth(self.Helmet:GetEnergy() * 100 + 99);
	owner:SetMaxHealth(self.Helmet:GetMaxEnergy() * 100 + 99);
	return true;
end

function POWERSUIT:SaveState(persistHealth)

	-- Prevent saving state if identifier is invalid or if using another player's powersuit instance.
	local owner = self:GetOwner();
	if (!SERVER || self.StateIdentifier == nil || !IsValid(owner) || owner:SteamID64() != self.StateIdentifier) then return false; end

	-- Prepare save state directories.
	file.CreateDir(self.SavePath .. "/" .. self.StateIdentifier);

	-- Persist health on auto saves.
	if (persistHealth && owner:Health() > 0) then self.Helmet:SetEnergy((owner:Health() - 99) / 100); end

	-- Push states to json file to persist.
	local save     = {};
	save.Helmet    = self.Helmet:SaveState();
	save.PowerSuit = self.PowerSuit:SaveState();
	save.ArmCannon = self.ArmCannon:SaveState();
	save.MorphBall = self.MorphBall:SaveState();
	file.Write(self.SavePath .. "/" .. self.StateIdentifier .. "/powersuit.json", util.TableToJSON(save, true));
	hook.Run("MP.OnSaveState", self);
	return true;
end

function POWERSUIT:DeleteState(reload)

	-- Make sure the current state is valid.
	local owner = self:GetOwner();
	if (!SERVER || self.StateIdentifier == nil || !IsValid(owner) || owner:SteamID64() != self.StateIdentifier) then return false; end

	-- Make sure the save file exists before attempting to delete it.
	local savePath = self.SavePath .. "/" .. self.StateIdentifier;
	local saveFile = savePath .. "/powersuit.json";
	if (!file.Exists(saveFile, "DATA")) then return false; end

	-- Delete save file.
	file.Delete(saveFile);
	if (!reload) then return true; end

	-- Reload entire weapon state after deleting save file to create a new one.
	local class = self:GetClass();
	owner:StripWeapon(class);
	owner:Give(class);
	owner:SelectWeapon(class);
	return true;
end

hook.Add("PlayerInitialSpawn", "POWERSUIT.RestoreState", function(ply, transition)
	if (transition) then ply.__mp_RestoreState = true; end
end);

hook.Add("SetupMove", "POWERSUIT.RestoreState", function(ply, move, cmd)

	if (!ply.__mp_RestoreState) then return; end

	local forceSelect = false;
	local currentWeapon = ply:GetActiveWeapon();
	for k,v in ipairs(ply:GetWeapons()) do

		if (!v:IsPowerSuit(true)) then continue; end

		-- Cleanup stray Morph Balls now.
		local morphball = v:GetMorphBall();
		if (IsValid(morphball)) then
			forceSelect = true;
			morphball:Remove();
			ply:ExitVehicle();
		end

		-- Reload weapon entirely in order to refresh entire state.
		local weaponClass = v:GetClass();
		ply:StripWeapon(weaponClass);
		ply:Give(weaponClass);

		-- Reequip powersuit if it was active after a map change.
		if (forceSelect || currentWeapon == v) then
			local vehicle = ply:GetAllowWeaponsInVehicle();
			ply:SetAllowWeaponsInVehicle(true);
			ply:SelectWeapon(weaponClass);
			timer.Simple(math.Clamp(FrameTime() * 16, 0.24, 0.24 * 16), function() ply:SetAllowWeaponsInVehicle(vehicle); end);
		end
	end

	-- Clear state restore cache.
	ply.__mp_RestoreState = nil;
end);