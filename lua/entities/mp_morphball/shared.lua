
include("setup.lua");

-- Sound properties
MORPHBALL.Sounds = {
	["roll"]   = Sound("entities/morphball/roll.wav"),
	["boost"]  = Sound("entities/morphball/boost.wav"),
	["charge"] = Sound("entities/morphball/charge.wav"),
	["spider"] = Sound("entities/morphball/spider.wav"),
	["stuck"]  = Sound("weapons/missile/empty.wav")
};

function MORPHBALL:SetupDataTables()

	-- Initialization flag used for camera hook.
	self.Initialized = true;
	WGL.AddProperty(self, "PowerSuit",       "Entity");
	WGL.AddProperty(self, "VelocityFix",     "Vector");
	WGL.AddProperty(self, "VehicleViewPos",  "Vector");
	WGL.AddProperty(self, "SurfaceNormal",   "Vector");
	WGL.AddProperty(self, "SurfaceParent",   "Entity");
	WGL.AddProperty(self, "SurfaceVelocity", "Vector");
	WGL.AddProperty(self, "OnGround",        "Bool");
	WGL.AddProperty(self, "Spider",          "Bool");
	WGL.AddProperty(self, "BombJumpTime",    "Float");
end

function MORPHBALL:Think()

	-- Failsafe for weapon drops.
	if (!IsValid(self:GetPowerSuit()) || !IsValid(self:GetPowerSuit():GetOwner())) then
		if (SERVER) then self:Remove(); end
		return;
	end

	-- Always set the vehicle's position to match the morphball, both on client and server.
	-- We can't parent the vehicle to the morphball or it would constantly roll around.
	local vehicle = self:GetNWEntity("Vehicle");
	if (IsValid(vehicle)) then vehicle:SetPos(self:GetPos() - Vector(0, 0, self.Radius)); end

	if (SERVER) then

		local owner = self:GetOwner();
		local morphball = self:GetPowerSuit().MorphBall;
		self:SetPhysicsAttacker(owner, 1);

		-- Statemachines event block. This is the core of the system, every event will be called in this block.
		if (self:ShouldUnfreeze(owner, morphball)) then owner:Freeze(false); end
		if (self:ShouldUnmorph(owner))             then owner:ExitVehicle(); end
		if (self:UseBomb(owner, morphball))        then self:Bomb(owner); end
		if (self:UsePowerBomb(owner, morphball))   then self:PowerBomb(owner); end
		if (self:UseBoost(morphball))              then self:Boost(owner, morphball); end
		if (morphball:ShouldChargeStart(IN_JUMP))  then self:StartCharging(morphball); end
		if (morphball:ShouldChargeLoop())          then self:ChargeLoop(morphball); end
		if (morphball:ShouldChargeStop(IN_JUMP))   then self:StopCharging(morphball); end
	end

	-- Call to the move delegate in order to start moving the morphball according to player inputs.
	self:NextThink(CurTime());
	return true;
end

function MORPHBALL:OnRemove()

	-- Make player visible again.
	local owner = self:GetOwner();
	if (IsValid(owner)) then
		owner:SetNoDraw(false);
		owner:Freeze(false);
	end

	-- Dispose of resources.
	WSL.CleanupSounds(self);
	WGL.CleanupComponents(self);
end