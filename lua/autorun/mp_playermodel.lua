
local playerModelSupport = nil;

hook.Add("PlayerPostThink", "POWERSUIT.PlayerModels", function(ply)

	-- PlayerModelSupport is a three state variable. Nil means we haven't checked if the models are present.
	-- False means the models are not present. True means the models are installed.
	if (playerModelSupport == false || !tobool(ply:GetInfo("mp_options_playermodel"))) then return; end

	-- Attempt to get powersuit data.
	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Avoid running hook if suit did not change.
	local suit, suitID = weapon:GetSuit();
	if (weapon.Suit == suitID) then
		return;
	else
		playerModelSupport = nil;
		weapon.Suit = suitID;
	end

	-- Check for player model support.
	if (playerModelSupport == nil) then playerModelSupport = util.IsValidModel(suit.WorldModel); end
	if (!playerModelSupport)       then return; end

	-- Apply suit model, skin and bodygroups to player now.
	WGL.ForceSetModel(ply, suit.WorldModel);
	WGL.SetBodyGroupSkin(ply, 1, suit.Group, suit.Skin);
end);

hook.Remove("StartCommand",       "morphball");
hook.Remove("SetupMove",          "morphball");
hook.Remove("CalcView",           "morphball");
hook.Remove("EntityTakeDamage",   "morphball");
hook.Remove("PlayerSwitchWeapon", "morphball");
hook.Remove("EntityTakeDamage",   "SuitBenefits");
hook.Remove("KeyPress",           "metroid_suitvalues");
hook.Remove("GetFallDamage",      "metroid_suitvalues");