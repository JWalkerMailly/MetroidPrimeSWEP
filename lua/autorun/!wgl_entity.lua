
WGL = WGL || {};

WGL.UpVec  = Vector(0, 0, 1);
WGL.OneVec = Vector(1, 1, 1);

WGL.DTSlots = {
	["String"] = 4,
	["Bool"]   = 32,
	["Float"]  = 32,
	["Int"]    = 32,
	["Vector"] = 32,
	["Angle"]  = 32,
	["Entity"] = 32
}

function WGL.IsAlive(ent)
	return ent:IsPlayer() || ent:IsNPC() || ent:IsNextBot() || string.find(ent:GetClass(), "*npc*");
end

CreateClientConVar("wgl_enable_dynamiclighting", "1", true, false, "Enable or disable DLights.", 0, 1);
function WGL.EmitLight(entity, pos, color, decay, size, dietime, style, noModels, noWorld)

	if (!GetConVar("wgl_enable_dynamiclighting"):GetBool()) then return NULL; end
	local light = DynamicLight(entity:EntIndex());
	if (light) then
		light.pos        = pos;
		light.r          = color.r;
		light.g          = color.g;
		light.b          = color.b;
		light.brightness = color.a;
		light.Decay      = decay;
		light.Size       = size;
		light.DieTime    = dietime;
		light.style      = style;
		light.nomodel    = noModels || false;
		light.noworld    = noWorld || false;
	end

	return light;
end

function WGL.EmitTrail(entity, material, attachment, color, additive, size, endSize, life)

	local trail = util.SpriteTrail(
		entity,
		attachment,
		color,
		additive,
		size,
		endSize,
		life,
		1 / (size + endSize) * 0.5,
		material
	);

	trail:SetKeyValue("rendermode", "3");
	trail:SetKeyValue("renderfx", "14");
	return trail;
end

function WGL.TraceCollision(ent, reset, filter, endPos, mask)

	-- Reset collision detection for dynamic checks.
	if (reset) then ent.__wgl_LastPosition = nil; end

	-- Frame of reference for future checks.
	ent.__wgl_LastPosition  = ent.__wgl_LastPosition  || ent:GetPos();
	ent.__wgl_LastCollision = ent.__wgl_LastCollision || {};

	-- Begin lag compensation for collision check.
	local owner      = ent:GetOwner()  || NULL;
	local parent     = ent:GetParent() || NULL;
	local validOwner = IsValid(owner) && owner:IsPlayer();
	if (validOwner && ent:IsLagCompensated()) then owner:LagCompensation(true); end

	-- Start collision prediction.
	local min, max  = ent:GetCollisionBounds();
	local pos       = ent:GetPos();
	local lastPos   = !endPos && ent.__wgl_LastPosition || ent:GetPos();
	local posDelta  = pos - lastPos;
	local speed     = posDelta:Length();
	local direction = posDelta:GetNormalized();
	local velocity  = direction * speed;
	local nextPos   = !endPos && (pos + velocity) || endPos;
	util.TraceHull({
		start  = lastPos,
		endpos = nextPos,
		maxs   = max, mins = min,
		filter = filter || { ent, owner, parent },
		output = ent.__wgl_LastCollision,
		mask   = mask || MASK_PLAYERSOLID
	});

	-- Debug collision prediction when using developer mode.
	debugoverlay.SweptBox(lastPos, nextPos, min, max, ent:GetAngles(), 1, Color(0, 255, 0));

	-- Restore lag compensation.
	if (validOwner) then owner:LagCompensation(false); end
	ent.__wgl_LastPosition = ent:GetPos();
	return ent.__wgl_LastCollision, ent.__wgl_LastPosition, velocity;
end