
local Helmet      = WGLComponent:New(POWERSUIT, "Helmet");
Helmet.HelmetBob  = Vector(0, 0, 0);
Helmet.LastBobPos = 0;
Helmet.Models     = { ["Helmet"] = Model("models/metroid/helmet/v_helmet.mdl") };

function Helmet:Draw(weapon, visor, pos, angle, blend, widescreen)

	WGL.Start3D(widescreen);
	cam.IgnoreZ(true);

		-- Helmet bob is used as smoothing when transitioning from walking to not walking.
		local bob = Lerp(FrameTime() * 17.422, self.LastBobPos, weapon:GetWalkBob());
		self.HelmetBob:SetUnpacked(0, 0, bob);
		self.HelmetBob:Add(pos);
		self.LastBobPos = bob;

		-- Render helmet from modelcache.
		render.SetBlend(blend);
		self:DrawModel("Helmet", self.HelmetBob, angle);
		render.SetBlend(1);

	cam.End3D();

	-- Draw visor ambient light onto helmet.
	if (visor.AmbientLight == nil) then return; end
	local ambientLight = visor.AmbientLight;
	WGL.EmitLight(self:GetModel("Helmet"), pos, ambientLight.Color, ambientLight.Decay, ambientLight.Size, CurTime() + FrameTime(), 0, false, true);
end