
local FaceReflection  = WGLComponent:New(POWERSUIT, "Face");
FaceReflection.Models = { ["Face"] = Model("models/metroid/samus/v_face.mdl") };

function FaceReflection:Draw(eyePos, eyeAngles, blend)

	-- Prepare positioning data. The face is rendered behind us in order to receive
	-- lighting as if it was reflected off the skin and onto the visor of the helmet.
	local w        = ScrW();
	local h        = ScrH();
	local up       = eyeAngles:Up() * 0.1;
	local forward  = eyeAngles:Forward() * 30;
	local camAngle = eyeAngles + Angle(-eyeAngles[1] * 2, 180, -eyeAngles[3] * 2);
	self:PushRenderTexture("rt_MPFaceReflection", w, h, { ["$additive"] = 1, ["$vertexalpha"] = 1, ["$alpha"] = 0.8 }, true);
		cam.Start3D(eyePos + up + forward, camAngle, WGL.GetViewFOV(10), 0, 0, w, h);

			render.ClearDepth();
			render.Clear(0, 0, 0, 0);

			-- Render Samus' face.
			render.SetBlend(blend);
			self:DrawModel("Face", eyePos, eyeAngles, 1, nil, nil, nil, true);
			render.SetBlend(1);

		cam.End3D();
	render.PopRenderTarget();

	-- Render final result on the screen to show the simulated face reflection effect.
	local lighting = render.GetLightColor(eyePos);
	local lightIntensity = WGL.Clamp(1 - ((lighting.r + lighting.g + lighting.b) / 3) * 2.5);
	WGL.TextureUV(self:GetRenderTexture("rt_MPFaceReflection"), 0, 0, ScrW(), ScrH(), 1, 0, 0, 1, false, 255, 255, 255, 255 * lightIntensity);
end