
POWERSUIT.PowerSuit = {};

function POWERSUIT.PowerSuit:SetupDataTables(weapon)

	self.Constants = {

		Movement = {
			Gravity       = 1.2,
			WalkSpeed     = 260
		},

		SpaceJump = {
			Power         = 380,
			Dash          = 190,
			Delay         = 0.4
		},

		Dash = {
			Speed         = 700,
			AirSpeed      = 600,
			GroundSpeed   = 1800
		},

		Grapple = {
			Delay         = 0.4,
			BeamSpeed     = 1200,
			SwingSpeed    = 1.9,
			RotationSpeed = 45,
			SwingDistance = 200,
			MaxVelocity   = 375,
			MaxDistance   = 550
		}
	};

	self.State = {

		SpaceJump = {
			Enable        = false
		},

		Grapple = {
			Enable        = false
		},

		Suit1 = {
			Enable        = true
		},

		Suit2 = {
			Enable        = false
		},

		Suit3 = {
			Enable        = false
		},

		Suit4 = {
			Enable        = false
		}
	};

	weapon:NetworkVar("Bool",    24, "Suit1",     { KeyName = "suit1",       Edit = { order = 10, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",    25, "Suit2",     { KeyName = "suit2",       Edit = { order = 11, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",    26, "Suit3",     { KeyName = "suit3",       Edit = { order = 12, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",    27, "Suit4",     { KeyName = "suit4",       Edit = { order = 13, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",    28, "SpaceJump", { KeyName = "spacejump",   Edit = { order = 8, category = "General", type = "Boolean" } });
	weapon:NetworkVar("Bool",    29, "Grapple",   { KeyName = "grapplebeam", Edit = { order = 9, category = "General", type = "Boolean" } });

	weapon:NetworkVar("Int",     12, "JumpCount");
	weapon:NetworkVar("Float",   28, "JumpTime");

	weapon:NetworkVar("Int",     17, "IsDashing");
	weapon:NetworkVar("Int",     18, "WasMoving");

	weapon:NetworkVar("Bool",    30, "Grappling");
	weapon:NetworkVar("Bool",    31, "Grappled");
	weapon:NetworkVar("Float",   26, "GrappleRatio");

	weapon:NetworkVar("Int",     19, "SwingStart");
	weapon:NetworkVar("Int",     20, "Swinging");
	weapon:NetworkVar("Vector",   1, "SwingLastPos");
	weapon:NetworkVar("Vector",   2, "SwingStartPos");

	weapon:NetworkVar("Angle",    2, "SwingStartAngle");
	weapon:NetworkVar("Angle",    3, "SwingViewAngle");
	weapon:NetworkVar("Float",   29, "SwingStartTime");

	weapon:NetworkVar("Float",   30, "GrappleStart");
	weapon:NetworkVar("Float",   31, "GrappleStartTime");

	self.Weapon = weapon;
	if (SERVER) then self:LoadState(); end
end

function POWERSUIT.PowerSuit:SaveState()

	-- Update local state cache with current network information.
	local weapon = self.Weapon;
	self.State.SpaceJump.Enable = weapon:GetSpaceJump();
	self.State.Grapple.Enable   = weapon:GetGrapple();
	self.State.Suit1.Enable     = weapon:GetSuit1();
	self.State.Suit2.Enable     = weapon:GetSuit2();
	self.State.Suit3.Enable     = weapon:GetSuit3();
	self.State.Suit4.Enable     = weapon:GetSuit4();

	return self.State;
end

function POWERSUIT.PowerSuit:LoadState(state)

	-- Assign state to current instance.
	if (state) then self.State = state; end

	-- Initialize base variables.
	local weapon = self.Weapon;
	weapon:SetSpaceJump(self.State.SpaceJump.Enable);
	weapon:SetGrapple(self.State.Grapple.Enable);
	weapon:SetSuit1(self.State.Suit1.Enable);
	weapon:SetSuit2(self.State.Suit2.Enable);
	weapon:SetSuit3(self.State.Suit3.Enable);
	weapon:SetSuit4(self.State.Suit4.Enable);
end

function POWERSUIT.PowerSuit:Reset()
	self.Weapon:SetGrappling(false);
	self.Weapon:SetGrappleRatio(0);
end

function POWERSUIT.PowerSuit:GetSuit()

	local weapon = self.Weapon;
	if (weapon:GetSuit4())     then return 4;
	elseif (weapon:GetSuit3()) then return 3;
	elseif (weapon:GetSuit2()) then return 2;
	elseif (weapon:GetSuit1()) then return 1;
	end

	return 1;
end

function POWERSUIT.PowerSuit:IsSpaceJumpEnabled()
	return self.Weapon:GetSpaceJump();
end

function POWERSUIT.PowerSuit:EnableSpaceJump(enable)
	self.Weapon:SetSpaceJump(enable);
end

function POWERSUIT.PowerSuit:IsGrappleEnabled()
	return self.Weapon:GetGrapple();
end

function POWERSUIT.PowerSuit:EnableGrapple(enable)
	self.Weapon:SetGrapple(enable);
end

function POWERSUIT.PowerSuit:IsSuitEnabled(suit)
	return self.Weapon["GetSuit" .. suit](self.Weapon);
end

function POWERSUIT.PowerSuit:EnableSuit(suit, enable)
	self.Weapon["SetSuit" .. suit](self.Weapon, enable);
end

--
-- Space Jump
-- 

function POWERSUIT.PowerSuit:MaxJumpCount()
	return self:IsSpaceJumpEnabled() && 2 || 1;
end

function POWERSUIT.PowerSuit:SetJumpCount(count)
	self.Weapon:SetJumpCount(count);
end

function POWERSUIT.PowerSuit:AddJumpCount(count)
	local weapon = self.Weapon;
	weapon:SetJumpCount(weapon:GetJumpCount() + count);
end

function POWERSUIT.PowerSuit:GetJumpCount()
	return self.Weapon:GetJumpCount();
end

function POWERSUIT.PowerSuit:CanJump()
	return self.Weapon:GetJumpCount() < self:MaxJumpCount();
end

function POWERSUIT.PowerSuit:SetJumpTime(time)
	self.Weapon:SetJumpTime(time);
end

function POWERSUIT.PowerSuit:GetJumpTime()
	return self.Weapon:GetJumpTime();
end

function POWERSUIT.PowerSuit:CanAutoJump()
	return self:GetJumpTime() + self.Constants.SpaceJump.Delay >= CurTime();
end

--
-- Dashing
--

function POWERSUIT.PowerSuit:Dashing(dashing)
	self.Weapon:SetIsDashing(dashing && 1 || 0);
end

function POWERSUIT.PowerSuit:IsDashing()
	return self.Weapon:GetIsDashing() == 1;
end

function POWERSUIT.PowerSuit:Moving(moving)
	self.Weapon:SetWasMoving(moving && 1 || 0);
end

function POWERSUIT.PowerSuit:WasMoving()
	return self.Weapon:GetWasMoving() == 1;
end

--
-- Grapple Beam
-- 

function POWERSUIT.PowerSuit:IsGrappling()
	return self.Weapon:GetGrappling();
end

function POWERSUIT.PowerSuit:Grappling(grappling)
	self.Weapon:SetGrappling(grappling);
end

function POWERSUIT.PowerSuit:Grappled()
	return self.Weapon:GetGrappled();
end

function POWERSUIT.PowerSuit:SetGrappled(grappled)
	self.Weapon:SetGrappled(grappled);
end

function POWERSUIT.PowerSuit:GetGrappleRatio()
	return self.Weapon:GetGrappleRatio();
end

function POWERSUIT.PowerSuit:SetGrappleRatio(ratio)
	self.Weapon:SetGrappleRatio(ratio);
end

function POWERSUIT.PowerSuit:SetSwinging(swinging)
	self.Weapon:SetSwinging(swinging && 1 || 0);
end

function POWERSUIT.PowerSuit:IsSwinging()
	return self.Weapon:GetSwinging() == 1;
end

function POWERSUIT.PowerSuit:SetSwingStart(start)
	self.Weapon:SetSwingStart(start && 1 || 0);
end

function POWERSUIT.PowerSuit:GetSwingStart()
	return self.Weapon:GetSwingStart() == 1;
end

function POWERSUIT.PowerSuit:SetSwingLastPos(pos)
	self.Weapon:SetSwingLastPos(pos);
end

function POWERSUIT.PowerSuit:GetSwingLastPos()
	return self.Weapon:GetSwingLastPos();
end

function POWERSUIT.PowerSuit:SetSwingStartPos(pos)
	self.Weapon:SetSwingStartPos(pos);
end

function POWERSUIT.PowerSuit:GetSwingStartPos()
	return self.Weapon:GetSwingStartPos();
end

function POWERSUIT.PowerSuit:SetSwingStartAngle(ang)
	self.Weapon:SetSwingStartAngle(ang);
end

function POWERSUIT.PowerSuit:GetSwingStartAngle()
	return self.Weapon:GetSwingStartAngle();
end

function POWERSUIT.PowerSuit:SetSwingViewAngle(ang)
	self.Weapon:SetSwingViewAngle(ang);
end

function POWERSUIT.PowerSuit:GetSwingViewAngle()
	return self.Weapon:GetSwingViewAngle();
end

function POWERSUIT.PowerSuit:SetSwingStartTime(time)
	self.Weapon:SetSwingStartTime(time);
end

function POWERSUIT.PowerSuit:GetSwingStartTime()
	return self.Weapon:GetSwingStartTime();
end

function POWERSUIT.PowerSuit:SetGrappleStartTime(time)
	self.Weapon:SetGrappleStartTime(time);
end

function POWERSUIT.PowerSuit:GetGrappleStartTime()
	return self.Weapon:GetGrappleStartTime();
end

function POWERSUIT.PowerSuit:SetGrappleStart(time)
	self.Weapon:SetGrappleStart(time);
end

function POWERSUIT.PowerSuit:GetGrappleStart()
	return self.Weapon:GetGrappleStart();
end