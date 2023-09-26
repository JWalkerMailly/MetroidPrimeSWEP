
include("shared.lua");

MORPHBALL.TrailMaterial = Material("entities/morphball/powertrail");
MORPHBALL.GlowMaterial  = Material("models/metroid/morphball/glow");
MORPHBALL.GlowColor     = Color(0, 0, 0, 0);
MORPHBALL.LastGlowColor = Color(0, 0, 0, 0);

local chargingColor  = Color(255, 238, 131, 1);
local innerGlowColor = Color(255, 255, 255, 1);

function MORPHBALL:GetClientVelocity()
	local velocity    = self:GetVelocity();
	local velocityFix = velocity:IsZero() && self:GetVelocityFix() || velocity;
	return velocityFix;
end

function MORPHBALL:HandleSuitSwap(model, suit, suitID, spider)

	-- Handle suit and spider model swaps.
	if (suitID == self.Suit && spider == self.Spider) then return; end
	if (spider && suit.SpiderBall.Model) then
		WGL.SetBodyGroupSkin(model,                                               0, suit.SpiderBall.Group, suit.SpiderBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Spawn"):GetModel("Spawn"),   0, suit.SpiderBall.Group, suit.SpiderBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Boost"):GetModel("Boost"),   0, suit.SpiderBall.Glass, suit.SpiderBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Damage"):GetModel("Damage"), 0, suit.SpiderBall.Group, suit.SpiderBall.Skin);
		WGL.SetColor(self.LastGlowColor, suit.SpiderBall.Color);
		WGL.SetColor(self.GlowColor, suit.SpiderBall.Color);
		self.TrailMaterial = suit.SpiderBall.Trail;
	else
		WGL.SetBodyGroupSkin(model,                                               0, suit.MorphBall.Group, suit.MorphBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Spawn"):GetModel("Spawn"),   0, suit.MorphBall.Group, suit.MorphBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Boost"):GetModel("Boost"),   0, suit.MorphBall.Group, suit.MorphBall.Skin);
		WGL.SetBodyGroupSkin(WGL.GetComponent(self, "Damage"):GetModel("Damage"), 0, suit.MorphBall.Group, suit.MorphBall.Skin);
		WGL.SetColor(self.LastGlowColor, suit.MorphBall.Color);
		WGL.SetColor(self.GlowColor, suit.MorphBall.Color);
		self.TrailMaterial = suit.MorphBall.Trail;
	end

	self.Suit   = suitID;
	self.Spider = spider;
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
	local center       = pos + Vector(0, 0, radius / 2);
	local velocity     = self:GetClientVelocity();
	local powerSuit    = self:GetPowerSuit();
	local morphball    = powerSuit.MorphBall;
	local suit, suitID = powerSuit:GetSuit();
	local spider       = morphball:IsSpiderEnabled();
	local charging     = morphball:ChargingStarted();
	local model        = WGL.GetComponent(self, "MorphBall"):GetModel("MorphBall");
	self:HandleSuitSwap(model, suit, suitID, spider);

	-- Compute morphball glow color based on boost status.
	if (charging) then
		self.LastGlowColor = WGL.LerpColor(frametime * 3, self.LastGlowColor, chargingColor);
	else
		self.LastGlowColor = WGL.LerpColor(frametime * 20, self.LastGlowColor, self.GlowColor);
	end

	-- Simulate the morphball physics client-side and keep a reference to the angles and gyro sway for trail rendering.
	local angles, sway = WGL.Component(self, "MorphBall", self, owner, pos, velocity, radius, self:GetSpider(), frametime);
	WGL.Component(self, "Spawn",  pos, angles, frametime);
	WGL.Component(self, "Boost",  pos, angles, charging, frametime);
	WGL.Component(self, "Damage", owner:Health(), pos, angles, 0.91);
	WGL.Component(self, "Trail",  morphball, pos, angles, sway, velocity, self.TrailMaterial, radius, frametime)

	-- Render dynamic lighting emanating from the morphball.
	WGL.EmitLight(model, center, self.LastGlowColor, 1000, 200, CurTime() + 0.1, 0, true, false);
	WGL.EmitLight(self, center, innerGlowColor, 1000, 150, CurTime() + 0.1, 0, false, true);

	-- Draw inner glow.
	render.SetMaterial(self.GlowMaterial);
	render.DrawSprite(pos, 26, 26, suit.MorphBall.Glow);
end