
sm_PowerSuit = {};
sm_PowerSuit.__index = sm_PowerSuit;

function sm_PowerSuit:New(weapon)

	local object = {};
	object.Constants = {

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

	object.State = {

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

	object.Weapon = weapon;
	setmetatable(object, sm_PowerSuit);
	object:SetupDataTables();
	return object;
end

function sm_PowerSuit:SetupDataTables()

	local weapon = self.Weapon;

	WGL.AddProperty(weapon, "Suit1",        "Bool", { KeyName = "suit1",       Edit = { order = 10, category = "Suits", type = "Boolean" } });
	WGL.AddProperty(weapon, "Suit2",        "Bool", { KeyName = "suit2",       Edit = { order = 11, category = "Suits", type = "Boolean" } });
	WGL.AddProperty(weapon, "Suit3",        "Bool", { KeyName = "suit3",       Edit = { order = 12, category = "Suits", type = "Boolean" } });
	WGL.AddProperty(weapon, "Suit4",        "Bool", { KeyName = "suit4",       Edit = { order = 13, category = "Suits", type = "Boolean" } });
	WGL.AddProperty(weapon, "SpaceJump",    "Bool", { KeyName = "spacejump",   Edit = { order = 8, category = "General", type = "Boolean" } });
	WGL.AddProperty(weapon, "Grapple",      "Bool", { KeyName = "grapplebeam", Edit = { order = 9, category = "General", type = "Boolean" } });

	WGL.AddProperty(weapon, "Grappling",    "Bool");
	WGL.AddProperty(weapon, "Grappled",     "Bool");
	WGL.AddProperty(weapon, "GrappleRatio", "Float");

	if (SERVER) then self:LoadState(); end
end

function sm_PowerSuit:SaveState()

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

function sm_PowerSuit:LoadState(state)

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

function sm_PowerSuit:Reset()
	self.Weapon:SetGrappling(false);
	self.Weapon:SetGrappleRatio(0);
end

function sm_PowerSuit:GetSuit()

	local weapon = self.Weapon;
	if (weapon:GetSuit4())     then return 4;
	elseif (weapon:GetSuit3()) then return 3;
	elseif (weapon:GetSuit2()) then return 2;
	elseif (weapon:GetSuit1()) then return 1;
	end

	return 1;
end

function sm_PowerSuit:IsSpaceJumpEnabled()
	return self.Weapon:GetSpaceJump();
end

function sm_PowerSuit:EnableSpaceJump(enable)
	self.Weapon:SetSpaceJump(enable);
end

function sm_PowerSuit:IsGrappleEnabled()
	return self.Weapon:GetGrapple();
end

function sm_PowerSuit:EnableGrapple(enable)
	self.Weapon:SetGrapple(enable);
end

function sm_PowerSuit:IsSuitEnabled(suit)
	return self.Weapon["GetSuit" .. suit](self.Weapon);
end

function sm_PowerSuit:EnableSuit(suit, enable)
	self.Weapon["SetSuit" .. suit](self.Weapon, enable);
end

--
-- Grapple Beam
-- 

function sm_PowerSuit:IsGrappling()
	return self.Weapon:GetGrappling();
end

function sm_PowerSuit:Grappling(grappling)
	self.Weapon:SetGrappling(grappling);
end

function sm_PowerSuit:Grappled()
	return self.Weapon:GetGrappled();
end

function sm_PowerSuit:SetGrappled(grappled)
	self.Weapon:SetGrappled(grappled);
end

function sm_PowerSuit:GetGrappleRatio()
	return self.Weapon:GetGrappleRatio();
end

function sm_PowerSuit:SetGrappleRatio(ratio)
	self.Weapon:SetGrappleRatio(ratio);
end

setmetatable(sm_PowerSuit, {__call = sm_PowerSuit.New });