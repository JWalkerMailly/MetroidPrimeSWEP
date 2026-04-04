
include("shared.lua");

MORPHBALL.TrailMaterial = Material("entities/morphball/powertrail");
MORPHBALL.GlowMaterial  = Material("models/metroid/morphball/glow");
MORPHBALL.GlowColor     = Color(0, 0, 0, 0);
MORPHBALL.LastGlowColor = Color(0, 0, 0, 0);
MORPHBALL.Center        = Vector(0, 0, 0);

local chargingColor  = Color(255, 238, 131, 1);
local innerGlowColor = Color(255, 255, 255, 1);

function MORPHBALL:GetClientVelocity()
	local velocity    = self:GetVelocity();
	local velocityFix = velocity:IsZero() && self:GetVelocityFix() || velocity;
	return velocityFix;
end

function MORPHBALL:SwapComponent(name, data, group, component)

	component = component || WGL.GetComponent(self, name);

	local model = component:OverrideModel(name, data.WorldModel);
	WGL.SetBodyGroupSkin(model, 0, data[group || "Group"], data.Skin);
	component.ModelScale = data.Scale;

	return model;
end

function MORPHBALL:HandleSuitSwap(suit, suitID, spider)

	local morphball = WGL.GetComponent(self, "MorphBall");
	if (suitID == self.Suit && spider == self.Spider) then
		return morphball:GetModel("MorphBall");
	end

	local data = self:GetSuitSwapData(suit, spider);
	if (!data || !data.WorldModel || !util.IsValidModel(data.WorldModel)) then
		suit = game.MetroidPrimeSuitVariants["Prime"][suitID];
		data = self:GetSuitSwapData(suit, spider);
	end

	local model = self:SwapComponent("MorphBall", data, nil, morphball);
	self:SwapComponent("Spawn",  data);
	self:SwapComponent("Damage", data);
	self:SwapComponent("Boost",  data, data.Boost && "Boost" || "Group");

	WGL.SetColor(self.LastGlowColor, data.Color);
	WGL.SetColor(self.GlowColor,     data.Color);

	self.Suit = suitID;
	self.Spider = spider;
	self.TrailMaterial = data.Trail;

	return model;
end

function MORPHBALL:Draw()

	-- Failsafe for weapon drops.
	if (!IsValid(self:GetPowerSuit()) || !IsValid(self:GetPowerSuit():GetOwner())) then return; end

	-- Only render if owner is valid.
	local owner = self:GetOwner();
	if (!IsValid(owner)) then return; end

	-- States setup for rendering.
	local frametime    = WGL.GetDeltaTime(self);
	local pos          = self:GetPos();
	local radius       = self.Radius;
	local velocity     = self:GetClientVelocity();
	local powerSuit    = self:GetPowerSuit();
	local morphball    = powerSuit.MorphBall;
	local suit, suitID = powerSuit:GetSuit();
	local spider       = morphball:IsSpiderEnabled();
	local charging     = morphball:ChargingStarted();
	local model        = self:HandleSuitSwap(suit, suitID, spider);

	-- Compute morphball glow color based on boost status.
	if (charging) then
		WGL.LerpColor(frametime * 3, self.LastGlowColor, chargingColor, self.LastGlowColor);
	else
		WGL.LerpColor(frametime * 20, self.LastGlowColor, self.GlowColor, self.LastGlowColor);
	end

	-- Simulate the morphball physics client-side and keep a reference to the angles and gyro sway for trail rendering.
	local angles, sway = WGL.Component(self, "MorphBall", self, owner, pos, velocity, radius, self:GetSpider(), frametime);
	WGL.Component(self, "Spawn",  pos, angles, frametime);
	WGL.Component(self, "Boost",  pos, angles, charging, frametime);
	WGL.Component(self, "Damage", owner:Health(), pos, angles);
	WGL.Component(self, "Trail",  morphball, pos, angles, sway, velocity, self.TrailMaterial, radius, frametime)

	-- Render dynamic lighting emanating from the morphball.
	self.Center:SetUnpacked(pos[1], pos[2], pos[3] + radius * 0.5);
	WGL.EmitLight(model, self.Center, self.LastGlowColor, 1000, 200, CurTime() + 0.1, 0, true, false);
	WGL.EmitLight(self, self.Center, innerGlowColor, 1000, 150, CurTime() + 0.1, 0, false, true);

	-- Draw inner glow.
	render.SetMaterial(self.GlowMaterial);
	render.DrawSprite(pos, 26, 26, (suit.MorphBall && suit.MorphBall.Glow) || color_white);
end