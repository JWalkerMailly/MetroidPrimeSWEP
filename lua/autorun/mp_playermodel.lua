
hook.Add("PlayerPostThink", "POWERSUIT.PlayerModels", function(ply)

	if (!tobool(ply:GetInfo("mp_options_playermodel"))) then return; end

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Avoid running hook if suit did not change.
	local suit, suitID = weapon:GetSuit();
	if (weapon.Suit == suitID || !util.IsValidModel(suit.WorldModel)) then return; end

	-- Apply suit model, skin and bodygroups to player now.
	WGL.ForceSetModel(ply, suit.WorldModel);
	WGL.SetBodyGroupSkin(ply, 1, suit.Group, suit.Skin);
	weapon.Suit = suitID;
end);

hook.Remove("StartCommand",       "morphball");
hook.Remove("SetupMove",          "morphball");
hook.Remove("CalcView",           "morphball");
hook.Remove("EntityTakeDamage",   "morphball");
hook.Remove("PlayerSwitchWeapon", "morphball");
hook.Remove("EntityTakeDamage",   "SuitBenefits");
hook.Remove("KeyPress",           "metroid_suitvalues");
hook.Remove("GetFallDamage",      "metroid_suitvalues");