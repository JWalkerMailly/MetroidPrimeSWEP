
function MORPHBALL:StartCharging(morphball)
	if (!morphball:IsBoostEnabled()) then return; end
	morphball:SetBoostChargeStartTime(CurTime());
end

function MORPHBALL:ChargeLoop(morphball)
	morphball:SetBoostChargeTime(CurTime());
	WSL.PlaySound(self, "charge");
end

function MORPHBALL:UseBoost(morphball)
	return morphball:ShouldChargeBallFire(IN_JUMP) && morphball:ChargingFull();
end

function MORPHBALL:Boost(owner, morphball)

	local physObject = self:GetPhysicsObject();
	if (!self:GetSpider()) then

		-- There are three directions to consider when boosting in order for the controls to feel
		-- responsive. First we must consider camera direction in order to apply boost relative to
		-- current "lookat" vector. Second is current direction, we don't want to apply boost in a 
		-- completely different direction, it should have weight. Last is input direction. We add them
		-- all up to get the best vector direction to apply boost.
		local eyeAngles        = owner:EyeAngles();
		local cameraDirection  = Angle(0, eyeAngles[2], eyeAngles[3]):Forward();
		local currentDirection = self:GetVelocity():GetNormalized();
		local desiredDirection = self:GetDirectionalInput(owner);

		-- Compute camera influence on boost direction. This way we can boost backwards without having
		-- to turn the camera around.
		local cameraInfluence = cameraDirection:Dot(desiredDirection);
		local moveDirection   = (cameraDirection * cameraInfluence + desiredDirection + currentDirection):GetNormalized();

		-- Boost ratio will act as a boost limiter in order to avoid going over max boost speed.
		local slope = math.abs(self:GetSlopeInfluence()) / 2;
		local boost = self.MaxBoost + (slope * self.MaxBoost);
		local boostRatio = self:GetVelocity():Length() / boost;
		physObject:AddVelocity(moveDirection * (boost - (boostRatio * boost)));
	else

		-- When using the spider ball, apply the boost force perpendicular to the surface we are on.
		local moveDirection = self:GetSurfaceNormal();
		physObject:AddVelocity(moveDirection * self.MaxBoost / 2);
	end

	-- Raise event.
	morphball:SetBoostTime(CurTime());
	WSL.PlaySound(self, "boost");
	hook.Run("MP.OnMorphBallBoost", self);
end

function MORPHBALL:StopCharging(morphball)
	morphball:SetBoostChargeTime(0);
	morphball:SetBoostChargeStartTime(0);
	WSL.StopSound(self, "charge");
end