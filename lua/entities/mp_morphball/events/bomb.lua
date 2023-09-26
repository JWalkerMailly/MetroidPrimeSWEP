
function MORPHBALL:UseBomb(owner, morphball)
	if (!owner:KeyDown(IN_ATTACK)) then self.BombingInput = false; end
	return owner:KeyDown(IN_ATTACK) && !self.BombingInput && morphball:UseBomb();
end

function MORPHBALL:UsePowerBomb(owner, morphball)
	if (!owner:KeyDown(IN_ATTACK2)) then self.PowerBombingInput = false; end
	return owner:KeyDown(IN_ATTACK2) && !self.PowerBombingInput && morphball:UsePowerBomb();
end

function MORPHBALL:DropBomb(owner, type)

	local bomb = ents.Create(type);
	bomb:SetPos(self:GetPos());
	bomb:SetOwner(owner);
	bomb:SetMorphBall(self);
	bomb:Spawn();
	return bomb;
end

function MORPHBALL:Bomb(owner)
	self:DropBomb(owner, "mp_bomb");
	self.BombingInput = true;
end

function MORPHBALL:PowerBomb(owner)
	self:DropBomb(owner, "mp_powerbomb");
	self.PowerBombingInput = true;
end