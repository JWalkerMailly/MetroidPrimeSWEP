
WGL = WGL || {};

WGL.ForceSetModel = FindMetaTable("Entity").SetModel;

function WGL.SetBodyGroupSkin(ent, group, value, skin)
	ent:SetBodygroup(group, value);
	ent:SetSkin(skin);
end

function WGL.ClientsideModel(model, renderGroup)

	local csEnt = ClientsideModel(model, renderGroup || RENDERGROUP_BOTH);
	csEnt:SetNoDraw(true);
	return csEnt;
end

function WGL.GetViewModelAttachmentPos(id, vmfov, fov, from, owner, localize)

	local ply    = owner || LocalPlayer();
	local vm     = ply:GetViewModel();
	local attach = vm:GetAttachment(id);
	local pos    = WGL.ToViewModelProjection(attach.Pos, vmfov, fov, from, owner, localize);

	return pos, attach.Ang, vm;
end

function WGL.SendClientsideAnimation(model, anim, speed)

	if (!IsValid(model)) then return; end
	model:ResetSequence(model:LookupSequence(anim));
	model:ResetSequenceInfo();
	model:SetCycle(0);
	model:SetPlaybackRate(math.Clamp(tonumber(speed || 1), 0.05, 3.05));
end

function WGL.SendViewModelAnimation(weapon, act, index, rate)

	if (!SERVER || !IsFirstTimePredicted()) then return; end

	-- Make sure owner didn't turn invalid.
	local owner = weapon:GetOwner();
	if (!IsValid(owner)) then return; end

	-- Make sure viewmodel is valid before proceeding.
	local vm = owner:GetViewModel(index);
	if (!IsValid(vm)) then return; end

	-- Make sure we are calling to a valid activity.
	local seq = vm:SelectWeightedSequence(act);
	if (seq == -1) then return; end

	-- Handle delay, the local function will revalidate the viewmodel.
	vm:SendViewModelMatchingSequence(seq);
	vm:SetPlaybackRate(rate || 1);
end