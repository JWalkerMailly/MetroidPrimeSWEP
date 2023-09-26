
WGL = WGL || {};
WGLComponent = {};
WGLComponent.__index = WGLComponent;

function WGLComponent:New(context, name)

	local object  = {
		Initialized    = false,
		Models         = {},
		ModelCache     = {},
		RenderTargets  = {},
		RenderTextures = {}
	};

	setmetatable(object, WGLComponent);
	if (context.WGLComponents == nil) then
		context.WGLComponents = {};
	end

	-- Register component to parent.
	context.WGLComponents[name] = object;
	return object;
end

function WGLComponent:Initialize(...)
	-- Override.
end

function WGLComponent:Draw(...)
	-- Override.
end

function WGLComponent:Cleanup(...)
	-- Override.
end

function WGLComponent:PreDraw(...)

	if (self.Initialized) then return; end
	self:Initialize(...);
	self.Initialized = true;
end

function WGLComponent:InitializeModel(name)

	local model = self.Models[name];
	if (!istable(model)) then
		self.ModelCache[name] = WGL.ClientsideModel(model);
	else
		self.ModelCache[name] = WGL.ClientsideModel(model[1], model[2]);
	end

	return self.ModelCache[name];
end

function WGLComponent:GetModel(name)

	local model = self.ModelCache[name];
	if (!IsValid(model)) then
		return self:InitializeModel(name);
	end

	return model;
end

function WGLComponent:DrawModel(name, pos, ang, scale, bodygroup, value, skin, frameAdvance)

	-- Safely retrieve model from cache.
	local model = self:GetModel(name);
	if (skin)      then model:SetSkin(skin); end
	if (bodygroup) then model:SetBodygroup(bodygroup, value); end
	if (scale)     then model:SetModelScale(scale || 1); end

	render.Model({
		model = model:GetModel(),
		pos   = pos,
		angle = ang
	}, model);

	-- Manually frame advance clientside model animations.
	if (frameAdvance) then model:FrameAdvance(); end
end

function WGLComponent:SendModelAnimation(name, anim)
	local model = self:GetModel(name);
	WGL.SendClientsideAnimation(model, anim, 1);
end

function WGLComponent:GetRenderTexture(name)
	return self.RenderTextures[name];
end

function WGLComponent:PushRenderTexture(name, w, h, options, dynamic)
	render.PushRenderTarget(WGL.GetRenderTexture(self, name, w, h, options, dynamic));
end

function WGLComponent:CleanupModels()

	-- Cleanup all clientside models for the given component.
	if (self.ModelCache == nil) then return; end
	for k,v in pairs(self.ModelCache) do
		SafeRemoveEntity(self.ModelCache[k]);
	end
end

setmetatable(WGLComponent, {__call = WGLComponent.New });

function WGL.GetComponent(context, name)
	return context.WGLComponents[name];
end

function WGL.Component(context, name, ...)

	local component = context.WGLComponents[name];
	component:PreDraw(...);
	return component:Draw(...);
end

function WGL.CleanupComponent(context, name, ...)

	-- Cleanup all clientside models since they have a limited number of slots on a server.
	local component = context.WGLComponents[name];
	component:CleanupModels();
	component:Cleanup(...);
end

function WGL.CleanupComponents(context, ...)

	if (!CLIENT) then return; end

	-- Cleanup all components.
	for k,v in pairs(context.WGLComponents) do
		WGL.CleanupComponent(context, k, ...);
	end
end