
function POWERSUIT:AutoSave()
	if (GetConVar("mp_cheats_autosave"):GetBool()) then self:SaveState(true); end
end

function POWERSUIT:LoadState(config)

	-- We auto load state once per instance.
	if (self.StateIdentifier != nil && config == nil) then return false; end

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