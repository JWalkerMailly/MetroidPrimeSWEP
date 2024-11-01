
include("setup.lua");

function POWERSUIT:SetupDataTables()

	self.Helmet:SetupDataTables(self);
	self.PowerSuit:SetupDataTables(self);
	self.ArmCannon:SetupDataTables(self);
	self.MorphBall:SetupDataTables(self);

	if (!CLIENT) then return; end
	self:MuzzleCallback("NextBeamMuzzle",      "MuzzleEffect");
	self:MuzzleCallback("NextChargeMuzzle",    "MuzzleBreakEffect");
	self:MuzzleCallback("NextComboMuzzle",     "MuzzleComboEffect");
	self:MuzzleCallback("NextComboLoopMuzzle", "MuzzleLoopEffect");
end

function POWERSUIT:Initialize()
	self:SetHoldType("pistol");
	WSL.InitializeSounds(self, self.Suits);
	WSL.InitializeSounds(self, self.Beams);
	WSL.InitializeSounds(self, self.Visors);
	self:CreateHooks();
end

function POWERSUIT:PrimaryAttack()
	if (!self:CanAttack() || self.ArmCannon:ChargingStarted()) then return; end
	if (self.ArmCannon:IsBeamOpen()) then return self:CloseBeam(self:GetBeam(), false, true); end
	self:NormalBeam();
end

function POWERSUIT:SecondaryAttack()
	if (!self:CanAttack() || self.ArmCannon:IsMissileComboBusy()) then return; end
	if (!self.ArmCannon:CanMissileFire()) then return self:MissileDeny(); end
	if (!self:GetOwner():KeyDown(IN_ATTACK)) then return self:Missile(); end
	self:StartMissileCombo();
end

function POWERSUIT:Think()

	self:LoadState();
	local armCannon = self.ArmCannon;
	local beamData  = self:GetBeam();
	local water     = beamData.ComboUnderWater;
	local loop      = beamData.ComboLoopDelay != nil;

	-- Statemachines event block. Timings and events are processed here.
	if (SERVER) then
		if (armCannon:ShouldMissileReset())                            then self:CloseBeam(beamData, false);  end
		if (armCannon:ShouldMissileComboReset(IN_ATTACK, loop, water)) then self:CloseMissileCombo(beamData); end
		if (armCannon:ShouldMissileReload())                           then self:MissileReload();             end
		if (armCannon:ShouldChargeBeamStart())                         then self:StartChargeBeam(beamData);   end
		if (armCannon:ShouldChargeBeamFire(IN_ATTACK))                 then self:ChargeBeam(beamData);        end
		if (armCannon:ShouldChargeBeamStop(IN_ATTACK))                 then self:StopChargeBeam(beamData);    end
		if (armCannon:ShouldMissileCombo())                            then self:MissileCombo(beamData);      end
		if (armCannon:ShouldMissileComboDrain(loop))                   then self:MissileComboLoop(beamData);  end
	end

	-- Think delegates.
	self:HelmetThink();
	self:BeamThink(beamData);
	self:ChargeBeamThink();
	self:ChangeComponentThink(beamData);
	self:NextThink(CurTime());
	return true;
end