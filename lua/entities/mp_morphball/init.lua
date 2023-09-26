
include("shared.lua");

function MORPHBALL:Initialize()

	-- Make owner invisible while using the morphball.
	local owner = self:GetOwner();
	owner:SetNoDraw(true);

	-- Prepare physics sphere for our morphball.
	if (!game.SinglePlayer()) then self:NextThink(CurTime()); end
	self:SetModel("models/hunter/misc/sphere075x075.mdl");
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE);
	self:PhysicsInitSphere(self.Radius, "solidmetal");
	self:SetBloodColor(BLOOD_COLOR_MECH);
	self:SetLagCompensated(true);
	self:DrawShadow(true);
	self:PhysWake();

	-- Prepare morphball physics properties.
	local phys = self:GetPhysicsObject();
	phys:SetMaterial("combine_metal");
	phys:SetMass(90);

	-- Create vehicle entity in order to use the engines default vehicle module.
	self.Vehicle = ents.Create("prop_vehicle_prisoner_pod");
	self.Vehicle:SetMoveType(MOVETYPE_NONE);
	self.Vehicle:SetModel("models/nova/airboat_seat.mdl");
	self.Vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
	self.Vehicle:SetKeyValue("limitview", 0);
	self.Vehicle:SetPos(self:GetPos() - Vector(0, 0, self.Radius));
	self.Vehicle:SetAngles(self:GetAngles());
	self.Vehicle:SetOwner(self);
	self.Vehicle:Spawn();
	self.Vehicle:Activate();

	-- Make the vehicle entity "non-existant".
	local vehiclePhys = self.Vehicle:GetPhysicsObject();
	vehiclePhys:EnableDrag(false) ;
	vehiclePhys:EnableMotion(false);
	vehiclePhys:SetMass(1);
	self.Vehicle:SetNotSolid(true);
	self.Vehicle:SetNoDraw(true);
	self.Vehicle:DrawShadow(false);

	-- Setup resources and bind vehicle to entity.
	self:DeleteOnRemove(self.Vehicle);
	self:SetNWEntity("Vehicle", self.Vehicle);
	self:SetSurfaceNormal(WGL.UpVec);
	self:SetOnGround(true);
	WSL.InitializeSounds(self);
end

function MORPHBALL:OnTakeDamage(damageInfo)

	-- Transmit morphball damage to player.
	local owner = self:GetOwner();
	if (IsValid(owner)) then
		owner:TakeDamageInfo(damageInfo);
	end
end