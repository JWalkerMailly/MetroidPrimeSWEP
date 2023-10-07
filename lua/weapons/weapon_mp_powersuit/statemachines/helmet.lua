
POWERSUIT.Helmet = {};

function POWERSUIT.Helmet:SetupDataTables(weapon)

	self.Constants = {

		Energy = {
			Limit           = 14
		},

		Visor = {
			Initial         = 1,
			LockOnFPS       = 1 / 15,
			LockOnTime      = 3,
			LockOnDistance  = 1200,
			LockOnCosine    = 0.85,
			AimAssistAngle  = 0.994,
			AimAssistFrames = 15,
			DangerDistance  = 512
		}
	};

	self.State = {

		Energy = {
			Base            = 0,
			Max             = 0
		},

		Visor1 = {
			Enable          = true
		},

		Visor2 = {
			Enable          = true
		},

		Visor3 = {
			Enable          = false
		},

		Visor4 = {
			Enable          = false
		}
	};

	weapon:NetworkVar("Bool",  15, "Visor1Enabled", { KeyName = "visor1", Edit = { order = 4, category = "Visors", type = "Boolean" } });
	weapon:NetworkVar("Bool",  16, "Visor2Enabled", { KeyName = "visor2", Edit = { order = 5, category = "Visors", type = "Boolean" } });
	weapon:NetworkVar("Bool",  17, "Visor3Enabled", { KeyName = "visor3", Edit = { order = 6, category = "Visors", type = "Boolean" } });
	weapon:NetworkVar("Bool",  18, "Visor4Enabled", { KeyName = "visor4", Edit = { order = 7, category = "Visors", type = "Boolean" } });

	weapon:NetworkVar("Float", 27, "Energy",    { KeyName = "energytanks",    Edit = { order = 3, category = "General", type = "Int", min = 0, max = 14 } });
	weapon:NetworkVar("Int",   13, "MaxEnergy", { KeyName = "maxenergytanks", Edit = { order = 2, category = "General", type = "Int", min = 0, max = 14 } });

	weapon:NetworkVar("Int",   14, "VisorType");
	weapon:NetworkVar("Bool",  19, "VisorLoop");

	weapon:NetworkVar("Entity", 1, "Target");
	weapon:NetworkVar("Angle",  0, "LockAngle");

	self.Weapon = weapon;
	if (SERVER) then self:LoadState(); end
end

function POWERSUIT.Helmet:SaveState()

	-- Update local state cache with current network information.
	local weapon = self.Weapon;
	self.State.Energy.Max    = weapon:GetMaxEnergy();
	self.State.Energy.Base   = weapon:GetEnergy();
	self.State.Visor1.Enable = weapon:GetVisor1Enabled();
	self.State.Visor2.Enable = weapon:GetVisor2Enabled();
	self.State.Visor3.Enable = weapon:GetVisor3Enabled();
	self.State.Visor4.Enable = weapon:GetVisor4Enabled();

	return self.State;
end

function POWERSUIT.Helmet:LoadState(state)

	-- Assign state to current instance.
	if (state) then self.State = state; end

	-- Initialize base variables.
	local weapon = self.Weapon;
	weapon:SetVisorType(self.Constants.Visor.Initial);
	weapon:SetMaxEnergy(self.State.Energy.Max);
	weapon:SetEnergy(self.State.Energy.Base);
	weapon:SetVisor1Enabled(self.State.Visor1.Enable);
	weapon:SetVisor2Enabled(self.State.Visor2.Enable);
	weapon:SetVisor3Enabled(self.State.Visor3.Enable);
	weapon:SetVisor4Enabled(self.State.Visor4.Enable);
end

function POWERSUIT.Helmet:Reset(resetVisor)
	if (resetVisor) then self.Weapon:SetVisorType(self.Constants.Visor.Initial); end
	self.Weapon:SetTarget(NULL);
end

function POWERSUIT.Helmet:GetVisor()
	return self.Weapon:GetVisorType();
end

function POWERSUIT.Helmet:SetVisor(visor)
	self.Weapon:SetVisorType(visor);
end

function POWERSUIT.Helmet:GetAimAssistAngle()
	return self.Constants.Visor.AimAssistAngle;
end

function POWERSUIT.Helmet:GetLockAngle()
	return self.Weapon:GetLockAngle();
end

function POWERSUIT.Helmet:SetLockAngle(angle)
	self.Weapon:SetLockAngle(angle);
end

function POWERSUIT.Helmet:IsVisorEnabled(index)
	return self.Weapon["GetVisor" .. index .. "Enabled"](self.Weapon);
end

function POWERSUIT.Helmet:EnableVisor(index, enable)
	self.Weapon["SetVisor" .. index .. "Enabled"](self.Weapon, enable);
end

--
-- Visor Animations
-- 

function POWERSUIT.Helmet:IsVisorLooping()
	return self.Weapon:GetVisorLoop();
end

function POWERSUIT.Helmet:StartVisorLoop(loop)
	self.Weapon:SetVisorLoop(loop);
end

--
-- Energy Tanks
-- 

function POWERSUIT.Helmet:GetEnergy()
	return self.Weapon:GetEnergy();
end

function POWERSUIT.Helmet:AddEnergy(amount)
	local current = self:GetEnergy();
	return self:SetEnergy(current + amount);
end

function POWERSUIT.Helmet:SetEnergy(amount)
	local max = self:GetMaxEnergy();
	local energy = math.Clamp(amount, -0.99, max)
	self.Weapon:SetEnergy(energy);
	return energy;
end

function POWERSUIT.Helmet:GetMaxEnergy()
	return self.Weapon:GetMaxEnergy();
end

function POWERSUIT.Helmet:AddMaxEnergy(amount, refill)
	local current = self:GetMaxEnergy();
	return self:SetMaxEnergy(current + amount, refill);
end

function POWERSUIT.Helmet:SetMaxEnergy(amount, refill)
	local limit = self.Constants.Energy.Limit;
	local maxEnergy = math.Clamp(amount, 0, limit);
	self.Weapon:SetMaxEnergy(maxEnergy);
	local current = self.Weapon:GetEnergy();
	local energy = refill && maxEnergy || math.Clamp(current, current, maxEnergy);
	self.Weapon:SetEnergy(energy);
	return energy, maxEnergy;
end

--
-- Target System
-- 

function POWERSUIT.Helmet:GetTarget(input)
	local target = self.Weapon:GetTarget();
	local valid  = IsValid(target);
	return target, valid, valid && self.Weapon:GetOwner():KeyDown(input);
end

function POWERSUIT.Helmet:SetTarget(target)
	self.Weapon:SetTarget(target);
end