
include("shared.lua");

function POWERSUIT:Equip(owner)
	owner:SetBloodColor(BLOOD_COLOR_MECH);
end

function POWERSUIT:ShouldDropOnDie()
	return false;
end

function POWERSUIT:OnDrop()
	self:Remove();
end