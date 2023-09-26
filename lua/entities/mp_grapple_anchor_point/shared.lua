
-- Syntactic sugar.
ANCHOR = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("base_anim");

ANCHOR.RenderGroup = RENDERGROUP_BOTH;

ANCHOR.Spawnable = true;
ANCHOR.PrintName = "Grapple Anchor Point";
ANCHOR.Category  = "Metroid Prime";
ANCHOR.Size      = 10;

ANCHOR.LogBook   = {
	Description = "Analysis indicates a viable attach point for the Grapple Beam. To use the Grapple Beam, use the IN_SPEED key when the Grapple Point icon appears.",
	Left = Material("logbook/mp_grapple_anchor_point/left.png"),
	Right = Material("logbook/mp_grapple_anchor_point/right.png")
}

function ANCHOR:Initialize()

	if (SERVER) then
		self:SetModel("models/metroid/props/grappleanchor.mdl");
		self:SetCollisionGroup(COLLISION_GROUP_NONE);
		self:PhysicsInitSphere(self.Size, "default");
		self:SetCollisionBounds(WGL.OneVec * -self.Size, WGL.OneVec * self.Size);
		self:SetMoveType(MOVETYPE_FLY);
		self:PhysWake();
		self:DrawShadow(false);
	end
end