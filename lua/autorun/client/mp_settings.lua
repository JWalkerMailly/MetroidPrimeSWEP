
hook.Add("AddToolMenuTabs", "MetroidPrimeSettings", function()
	spawnmenu.AddToolTab("mpSettings", "Metroid Prime", "icon16/cog.png");
end);

hook.Add("AddToolMenuCategories", "MetroidPrimeSettings", function()
	spawnmenu.AddToolCategory("mpSettings", "mpCompatibility", "Compatibility");
	spawnmenu.AddToolCategory("mpSettings", "mpOptions", "Options");
	spawnmenu.AddToolCategory("mpSettings", "mpCheats", "Cheats");
end);

hook.Add("PopulateToolMenu", "MetroidPrimeSettings", function()

	-- Create Visor options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCompatibility", "mpPlayerModel", "Player Model", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("Replace Player Model", "mp_options_playermodel");
		panel:ControlHelp("\nReplaces player model when using the Power Suit. For player models, see workshop addon 2701609725.");
		panel:Button("Open Workshop", "mp_options_playermodel_get");
	end);

	-- Create controls options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpControls", "Controls", "", "", function(panel)

		panel:Clear();

		WGL.KeyMap(panel, "Visor Layer Key",  "mp_controls_selectorlayer", "\nDefines the visor layer key to use when changing visors.");
		WGL.KeyMap(panel, "Beam/Visor 1 Key", "mp_controls_selector1",     "\nDefines the key to use to swap to Beam/Visor 1.");
		WGL.KeyMap(panel, "Beam/Visor 2 Key", "mp_controls_selector2",     "\nDefines the key to use to swap to Beam/Visor 2.");
		WGL.KeyMap(panel, "Beam/Visor 3 Key", "mp_controls_selector3",     "\nDefines the key to use to swap to Beam/Visor 3.");
		WGL.KeyMap(panel, "Beam/Visor 4 Key", "mp_controls_selector4",     "\nDefines the key to use to swap to Beam/Visor 4.");
	end);

	-- Create Visor options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpVisor", "Visor", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("Auto Aim", "mp_options_autoaim");
		panel:ControlHelp("\nEnable or disable auto aim feature.");

		panel:NumSlider("Visor Opacity", "mp_options_visoropacity", 0, 100, 0);
		panel:ControlHelp("\nAdjusts the transparency of all UI elements except for health.");

		panel:NumSlider("Helmet Opacity", "mp_options_helmetopacity", 0, 100, 0);
		panel:ControlHelp("\nAdjusts the transparency of Samus's helmet.");

		panel:CheckBox("HUD Lag", "mp_options_hudlag");
		panel:ControlHelp("\nTurn helmet and UI lag on or off when moving the camera.");

		panel:CheckBox("Face Reflection", "mp_options_facereflection");
		panel:ControlHelp("\nEnable or disable Samus' face reflection on combat visor.");

		panel:CheckBox("Keep HUD", "mp_options_keephud");
		panel:ControlHelp("\nDisplay HUD even when the Power Suit is not in use as long as it is in inventory. Can cause conflicts with other addons.");
	end);

	-- Create Display options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpDisplay", "Display", "", "", function(panel)

		panel:Clear();

		panel:NumSlider("Field of View", "fov_desired", 75, 100, 0);
		panel:ControlHelp("\nAdjust FOV. This is the same setting found in Options / Video / Advanced. Metroid Prime's original setting is 75.");

		panel:NumSlider("Viewmodel FOV", "mp_options_viewmodelfov", 54, 76, 0);
		panel:ControlHelp("\nAdjust weapon forward position. May result in rendering issues. Default: 62.");

		panel:CheckBox("Widescreen Fix", "mp_options_widescreenfix");
		panel:ControlHelp("\nAdjust HUD to fill widescreen monitors.");
	end);

	-- Create Game options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpGame", "Game", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("Dynamic Lighting", "wgl_enable_dynamiclighting");
		panel:ControlHelp("\nEnables or disables dynamic lighting for projectiles and effects.");

		panel:CheckBox("Scan Dashing", "mp_cheats_scandashing");
		panel:ControlHelp("\nEnables or disables scan dashing as found in the first revision of Metroid Prime.");

		panel:NumSlider("Damage Given", "mp_cheats_damagegivenscale", 1, 10, 0);
		panel:ControlHelp("\nScales damage given by Power Suit and Morph Ball projectiles.");

		panel:NumSlider("Damage Taken", "mp_cheats_damagetakenscale", 1, 10, 0);
		panel:ControlHelp("\nScales damage taken when a player is using the Power Suit or the Morph Ball. This can also be interpreted as a Damage Multiplier.");
	end);

	-- Create State options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpState", "Save File", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("Auto Save", "mp_cheats_autosave");
		panel:ControlHelp("\nWrite to save file upon death or disconnect.");

		panel:Button("Save State", "mp_cheats_savestate");
		panel:ControlHelp("\nWrite to save file. Current values will be loaded by default during next session.");

		panel:Button("Delete State", "mp_cheats_deletestate");
		panel:ControlHelp("\nOverwrite save file with a new one. All progress will be lost.");
	end);

	-- Create General cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpGeneral", "General", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "Energy Tanks (Capacity)", "mp_cheats_set_energytankcapacity", function()
			return LocalPlayer():GetPowerSuitMaxEnergyTanks();
		end, 0, 14, 0, "\nAdjusts the player's max health.");

		WGL.NumSlider(panel, "Energy Tanks (Amount)", "mp_cheats_set_energytankamount", function()
			return LocalPlayer():GetPowerSuitEnergyTanks();
		end, 0, 14, 0, "\nAdjusts the player's health.");

		WGL.CheckBox(panel, "Combat Visor", "mp_cheats_enable_combatvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(1);
		end, "\nEnables or disables the default visor.");

		WGL.CheckBox(panel, "Scan Visor", "mp_cheats_enable_scanvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(2);
		end, "\nEnables or disables the scan visor. Scan nearby objects to display information using the IN_SPEED key.");

		WGL.CheckBox(panel, "Thermal Visor", "mp_cheats_enable_thermalvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(3);
		end, "\nEnables or disables the thermal visor. Display heat signatures from the environment or interact with electronics using the wave beam.");

		WGL.CheckBox(panel, "X-Ray Visor", "mp_cheats_enable_xrayvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(4);
		end, "\nEnables or disables the x-ray visor. Display hidden passages or invisible entities.");

		WGL.CheckBox(panel, "Space Jump Boots", "mp_cheats_enable_spacejump", function()
			return LocalPlayer():IsPowerSuitSpaceJumpEnabled();
		end, "\nEnables or disables space jump boots. Space jump boots allow double jumping.");

		WGL.CheckBox(panel, "Grapple Beam", "mp_cheats_enable_grapplebeam", function()
			return LocalPlayer():IsPowerSuitGrappleEnabled();
		end, "\nEnables or disables the grapple beam. Swing from viable anchor points using the IN_SPEED key.");

		WGL.CheckBox(panel, "Power Suit", "mp_cheats_enable_powersuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(1);
		end, "\nEnables or disables the default suit.");

		WGL.CheckBox(panel, "Varia Suit", "mp_cheats_enable_variasuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(2);
		end, "\nEnables or disables the varia suit. Take 10% less damage while active.");

		WGL.CheckBox(panel, "Gravity Suit", "mp_cheats_enable_gravitysuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(3);
		end, "\nEnables or disables the gravity suit. Take 20% less damage while active.");

		WGL.CheckBox(panel, "Phazon Suit", "mp_cheats_enable_phazonsuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(4);
		end, "\nEnables or disables the phazon suit. Take 50% less damage while active.");
	end);

	-- Create Weapons cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpWeapons", "Weapons", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "Missiles (Capacity)", "mp_cheats_set_missilecapacity", function()
			return LocalPlayer():GetPowerSuitMaxAmmo("Missile");
		end, 0, 250, 0, "\nAdjusts the player's max missile ammo capacity.");

		WGL.NumSlider(panel, "Missiles (Amount)", "mp_cheats_set_missileamount", function()
			return LocalPlayer():GetPowerSuitAmmo("Missile");
		end, 0, 250, 0, "\nAdjusts the player's missile ammo.");

		WGL.CheckBox(panel, "Charge Beam", "mp_cheats_enable_chargebeam", function()
			return LocalPlayer():IsPowerSuitChargeBeamEnabled();
		end, "\nEnables or disables charge beam feature. Charge beams by holding down the IN_ATTACK key.");

		WGL.CheckBox(panel, "Power Beam", "mp_cheats_enable_powerbeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(1);
		end, "\nEnables or disables the default beam.");

		WGL.CheckBox(panel, "Wave Beam", "mp_cheats_enable_wavebeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(2);
		end, "\nEnables or disables the wave beam. Interact with electronics by shooting at them using the thermal visor.");

		WGL.CheckBox(panel, "Ice Beam", "mp_cheats_enable_icebeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(3);
		end, "\nEnables or disables the ice beam.");

		WGL.CheckBox(panel, "Plasma Beam", "mp_cheats_enable_plasmabeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(4);
		end, "\nEnables or disables the plasma beam.");

		WGL.CheckBox(panel, "Super Missile", "mp_cheats_enable_supermissile", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(1);
		end, "\nEnables or disables super missiles. Fire a stronger missile using the IN_ATTACK2 key when power beam is fully charged.");

		WGL.CheckBox(panel, "Wavebuster", "mp_cheats_enable_wavebuster", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(2);
		end, "\nEnables or disables wavebuster. Fire a continuous electrical arc using the IN_ATTACK2 key when wave beam is fully charged.");

		WGL.CheckBox(panel, "Ice Spreader", "mp_cheats_enable_icespreader", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(3);
		end, "\nEnables or disables ice spreader. Fire an ice missile using the IN_ATTACK2 key when ice beam is fully charged.");

		WGL.CheckBox(panel, "Flamethrower", "mp_cheats_enable_flamethrower", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(4);
		end, "\nEnables or disables flamethrower. Fire a stream of fire using the IN_ATTACK2 key when plasma beam is fully charged.");
	end);

	-- Create Morph Ball cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpMorphBall", "Morph Ball", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "Power Bombs (Capacity)", "mp_cheats_set_powerbombcapacity", function()
			return LocalPlayer():GetPowerSuitPowerBombMaxAmmo();
		end, 0, 8, 0, "\nAdjusts the player's max power bomb capacity.");

		WGL.NumSlider(panel, "Power Bombs (Amount)", "mp_cheats_set_powerbombamount", function()
			return LocalPlayer():GetPowerSuitPowerBombAmmo();
		end, 0, 8, 0, "\nAdjusts the player's power bomb count.");

		WGL.CheckBox(panel, "Morph Ball", "mp_cheats_enable_morphball", function()
			return LocalPlayer():IsMorphBallEnabled();
		end, "\nEnables or disables morph ball. Morph into a ball using the IN_CROUCH key to navigate tight passages.");

		WGL.CheckBox(panel, "Bombs", "mp_cheats_enable_morphballbombs", function()
			return LocalPlayer():IsMorphBallBombsEnabled();
		end, "\nEnables or disables morph ball bombs. Drop bombs using the IN_ATTACK key while in morph ball mode.");

		WGL.CheckBox(panel, "Boost Ball", "mp_cheats_enable_morphballboost", function()
			return LocalPlayer():IsMorphBallBoostEnabled();
		end, "\nEnables or disables boost ball. Charge by holding down the IN_JUMP key and release for a temporary speed boost.");

		WGL.CheckBox(panel, "Spider Ball", "mp_cheats_enable_morphballspider", function()
			return LocalPlayer():IsMorphBallSpiderEnabled();
		end, "\nEnables or disables spider ball. Defy gravity by sticking onto metallic surfaces using the IN_SPEED key.");
	end);
end);