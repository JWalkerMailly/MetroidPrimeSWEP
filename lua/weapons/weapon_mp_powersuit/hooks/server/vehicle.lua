
hook.Add("CanPlayerEnterVehicle", "MORPHBALL.CanEnter", function(ply, vehicle, role)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Make sure the armcannon is not busy before entering a vehicle.
	return !weapon.ArmCannon:IsBusy();
end);

hook.Add("CanExitVehicle", "MORPHBALL.CanLeave", function(vehicle, ply)

	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall()) then return; end

	-- AABB test to see if the player can exit the morphball.
	local bottom, top = ply:GetHull();
	local groundPos   = morphball:GetPos();
	local unmorphHull = util.TraceHull({
		start  = groundPos,
		endpos = groundPos,
		mins   = bottom,
		maxs   = top,
		filter = { ply, morphball, vehicle },
		mask   = MASK_PLAYERSOLID
	});

	local powersuit = morphball:GetPowerSuit();
	local canExit   = !unmorphHull.StartSolid && !unmorphHull.Hit;
	local canMorph  = powersuit.MorphBall:CanMorph();
	if (!canExit && canMorph) then
		powersuit.MorphBall:SetNextMorphTime(CurTime());
		WSL.PlaySound(morphball, "stuck");
	end

	return canExit;
end);

hook.Add("PlayerLeaveVehicle", "MORPHBALL.Leave", function(ply, vehicle)

	local morphball = vehicle:GetOwner();
	if (!morphball:IsMorphBall()) then return; end

	-- Match the player's velocity and direction to the morphball before removing it.
	local ang = morphball:GetVelocity():Angle();
	ply:SetEyeAngles(Angle(0, ply:LocalEyeAngles()[2] - 90, 0));
	ply:SetPos(morphball:GetPos() - Vector(0, 0, 11));
	ply:SetVelocity(morphball:GetVelocity() * 0.75);

	-- Update statemachines.
	local powersuit = morphball:GetPowerSuit();
	powersuit.MorphBall:SetNextMorphTime(CurTime());

	-- Remove morphball on exit.
	morphball:StopCharging(powersuit.MorphBall);
	ply:EmitSound("entities/morphball/unmorph.wav");
	SafeRemoveEntity(morphball);

	-- Raise event.
	hook.Run("MP.OnMorphBallUnmorph", ply, powersuit);
end);