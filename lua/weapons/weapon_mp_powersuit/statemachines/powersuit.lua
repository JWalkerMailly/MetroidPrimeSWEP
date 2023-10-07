
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

	weapon:NetworkVar("Bool",  24, "Suit1",     { KeyName = "suit1",       Edit = { order = 10, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",  25, "Suit2",     { KeyName = "suit2",       Edit = { order = 11, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",  26, "Suit3",     { KeyName = "suit3",       Edit = { order = 12, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",  27, "Suit4",     { KeyName = "suit4",       Edit = { order = 13, category = "Suits", type = "Boolean" } });
	weapon:NetworkVar("Bool",  28, "SpaceJump", { KeyName = "spacejump",   Edit = { order = 8, category = "General", type = "Boolean" } });
	weapon:NetworkVar("Bool",  29, "Grapple",   { KeyName = "grapplebeam", Edit = { order = 9, category = "General", type = "Boolean" } });

	weapon:NetworkVar("Bool",  30, "Grappling");
	weapon:NetworkVar("Bool",  31, "Grappled");
	weapon:NetworkVar("Float", 26, "GrappleRatio");

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