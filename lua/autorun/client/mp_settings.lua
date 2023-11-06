
hook.Add("AddToolMenuTabs", "MetroidPrimeSettings", function()
	spawnmenu.AddToolTab("mpSettings", "#mp.settings.title", "icon16/cog.png");
end);

hook.Add("AddToolMenuCategories", "MetroidPrimeSettings", function()
	spawnmenu.AddToolCategory("mpSettings", "mpCompatibility", "#mp.settings.compatibility");
	spawnmenu.AddToolCategory("mpSettings", "mpOptions", "#mp.settings.options");
	spawnmenu.AddToolCategory("mpSettings", "mpCheats", "#mp.settings.cheats");
end);

hook.Add("PopulateToolMenu", "MetroidPrimeSettings", function()

	-- Create Visor options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCompatibility", "mpPlayerModel", "#mp.settings.compatibility.playermodel.title", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("#mp.settings.compatibility.playermodel.text", "mp_options_playermodel");
		panel:ControlHelp("#mp.settings.compatibility.playermodel.help");
		panel:Button("#mp.settings.compatibility.playermodel.button", "mp_options_playermodel_get");
	end);

	-- Create controls options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpControls", "#mp.settings.options.controls.title", "", "", function(panel)

		panel:Clear();

		WGL.KeyMap(panel, "#mp.settings.options.controls.visorlayer.text", "mp_controls_selectorlayer", "#mp.settings.options.controls.visorlayer.help");
		WGL.KeyMap(panel, "#mp.settings.options.controls.component1.text", "mp_controls_selector1",     "#mp.settings.options.controls.component1.help");
		WGL.KeyMap(panel, "#mp.settings.options.controls.component2.text", "mp_controls_selector2",     "#mp.settings.options.controls.component2.help");
		WGL.KeyMap(panel, "#mp.settings.options.controls.component3.text", "mp_controls_selector3",     "#mp.settings.options.controls.component3.help");
		WGL.KeyMap(panel, "#mp.settings.options.controls.component4.text", "mp_controls_selector4",     "#mp.settings.options.controls.component4.help");
	end);

	-- Create gestures options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpGestures", "#mp.settings.options.gestures.title", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("#mp.settings.options.gestures.enable.text", "mp_options_gestures");
		panel:ControlHelp("#mp.settings.options.gestures.enable.help");

		WGL.KeyMap(panel, "#mp.settings.options.gestures.key.text", "mp_controls_gesture", "#mp.settings.options.gestures.key.help");

		panel:NumSlider("#mp.settings.options.gestures.deadzone.text", "mp_options_gesturedzone", 0.1, 1, 3);
		panel:ControlHelp("#mp.settings.options.gestures.deadzone.help");

		panel:NumSlider("#mp.settings.options.gestures.sensitivity.text", "mp_options_gesturealpha", 0.1, 1, 3);
		panel:ControlHelp("#mp.settings.options.gestures.sensitivity.help");

		panel:CheckBox("#mp.settings.options.gestures.helper.text", "mp_options_gesturehelp");
		panel:ControlHelp("#mp.settings.options.gestures.helper.help");
	end);

	-- Create Visor options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpVisor", "#mp.settings.options.visor.title", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("#mp.settings.options.visor.autoaim.text", "mp_options_autoaim");
		panel:ControlHelp("#mp.settings.options.visor.autoaim.help");

		panel:NumSlider("#mp.settings.options.visor.hudopacity.text", "mp_options_visoropacity", 0, 100, 0);
		panel:ControlHelp("#mp.settings.options.visor.hudopacity.help");

		panel:NumSlider("#mp.settings.options.visor.helmetopacity.text", "mp_options_helmetopacity", 0, 100, 0);
		panel:ControlHelp("#mp.settings.options.visor.helmetopacity.help");

		panel:CheckBox("#mp.settings.options.visor.hudlag.text", "mp_options_hudlag");
		panel:ControlHelp("#mp.settings.options.visor.hudlag.help");

		panel:CheckBox("#mp.settings.options.visor.facereflection.text", "mp_options_facereflection");
		panel:ControlHelp("#mp.settings.options.visor.facereflection.help");

		panel:CheckBox("#mp.settings.options.visor.keephud.text", "mp_options_keephud");
		panel:ControlHelp("#mp.settings.options.visor.keephud.help");
	end);

	-- Create Display options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpDisplay", "#mp.settings.options.display.title", "", "", function(panel)

		panel:Clear();

		panel:NumSlider("#mp.settings.options.display.fov.text", "fov_desired", 75, 100, 0);
		panel:ControlHelp("#mp.settings.options.display.fov.help");

		panel:NumSlider("#mp.settings.options.display.vmfov.text", "mp_options_viewmodelfov", 54, 76, 0);
		panel:ControlHelp("#mp.settings.options.display.vmfov.help");

		panel:CheckBox("#mp.settings.options.display.widescreen.text", "mp_options_widescreenfix");
		panel:ControlHelp("#mp.settings.options.display.widescreen.help");
	end);

	-- Create Game options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpOptions", "mpGame", "#mp.settings.options.game.title", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("#mp.settings.options.game.lighting.text", "wgl_enable_dynamiclighting");
		panel:ControlHelp("#mp.settings.options.game.lighting.help");

		panel:CheckBox("#mp.settings.options.game.scandash.text", "mp_cheats_scandashing");
		panel:ControlHelp("#mp.settings.options.game.scandash.help");

		panel:NumSlider("#mp.settings.options.game.damagegiven.text", "mp_cheats_damagegivenscale", 1, 10, 0);
		panel:ControlHelp("#mp.settings.options.game.damagegiven.help");

		panel:NumSlider("#mp.settings.options.game.damagetaken.text", "mp_cheats_damagetakenscale", 1, 10, 0);
		panel:ControlHelp("#mp.settings.options.game.damagetaken.help");
	end);

	-- Create State options menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpState", "#mp.settings.options.state.title", "", "", function(panel)

		panel:Clear();

		panel:CheckBox("#mp.settings.options.state.autosave.text", "mp_cheats_autosave");
		panel:ControlHelp("#mp.settings.options.state.autosave.help");

		panel:Button("#mp.settings.options.state.save.text", "mp_cheats_savestate");
		panel:ControlHelp("#mp.settings.options.state.save.help");

		panel:Button("#mp.settings.options.state.delete.text", "mp_cheats_deletestate");
		panel:ControlHelp("#mp.settings.options.state.delete.help");
	end);

	-- Create General cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpGeneral", "#mp.settings.cheats.general.title", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "#mp.settings.cheats.general.etankcapacity.text", "mp_cheats_set_energytankcapacity", function()
			return LocalPlayer():GetPowerSuitMaxEnergyTanks();
		end, 0, 14, 0, "#mp.settings.cheats.general.etankcapacity.help");

		WGL.NumSlider(panel, "#mp.settings.cheats.general.etankamount.text", "mp_cheats_set_energytankamount", function()
			return LocalPlayer():GetPowerSuitEnergyTanks();
		end, 0, 14, 0, "#mp.settings.cheats.general.etankamount.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.combatvisor.text", "mp_cheats_enable_combatvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(1);
		end, "#mp.settings.cheats.general.combatvisor.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.scanvisor.text", "mp_cheats_enable_scanvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(2);
		end, "#mp.settings.cheats.general.scanvisor.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.thermalvisor.text", "mp_cheats_enable_thermalvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(3);
		end, "#mp.settings.cheats.general.thermalvisor.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.xrayvisor.text", "mp_cheats_enable_xrayvisor", function()
			return LocalPlayer():IsPowerSuitVisorEnabled(4);
		end, "#mp.settings.cheats.general.xrayvisor.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.spacejump.text", "mp_cheats_enable_spacejump", function()
			return LocalPlayer():IsPowerSuitSpaceJumpEnabled();
		end, "#mp.settings.cheats.general.spacejump.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.grapple.text", "mp_cheats_enable_grapplebeam", function()
			return LocalPlayer():IsPowerSuitGrappleEnabled();
		end, "#mp.settings.cheats.general.grapple.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.powersuit.text", "mp_cheats_enable_powersuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(1);
		end, "#mp.settings.cheats.general.powersuit.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.variasuit.text", "mp_cheats_enable_variasuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(2);
		end, "#mp.settings.cheats.general.variasuit.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.gravitysuit.text", "mp_cheats_enable_gravitysuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(3);
		end, "#mp.settings.cheats.general.gravitysuit.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.general.phazonsuit.text", "mp_cheats_enable_phazonsuit", function()
			return LocalPlayer():IsPowerSuitSuitEnabled(4);
		end, "#mp.settings.cheats.general.phazonsuit.help");
	end);

	-- Create Weapons cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpWeapons", "#mp.settings.cheats.weapons.title", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "#mp.settings.cheats.weapons.missilecapacity.text", "mp_cheats_set_missilecapacity", function()
			return LocalPlayer():GetPowerSuitMaxAmmo("Missile");
		end, 0, 250, 0, "#mp.settings.cheats.weapons.missilecapacity.help");

		WGL.NumSlider(panel, "#mp.settings.cheats.weapons.missileamount.text", "mp_cheats_set_missileamount", function()
			return LocalPlayer():GetPowerSuitAmmo("Missile");
		end, 0, 250, 0, "#mp.settings.cheats.weapons.missileamount.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.chargebeam.text", "mp_cheats_enable_chargebeam", function()
			return LocalPlayer():IsPowerSuitChargeBeamEnabled();
		end, "#mp.settings.cheats.weapons.chargebeam.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.powerbeam.text", "mp_cheats_enable_powerbeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(1);
		end, "#mp.settings.cheats.weapons.powerbeam.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.wavebeam.text", "mp_cheats_enable_wavebeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(2);
		end, "#mp.settings.cheats.weapons.wavebeam.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.icebeam.text", "mp_cheats_enable_icebeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(3);
		end, "#mp.settings.cheats.weapons.icebeam.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.plasmabeam.text", "mp_cheats_enable_plasmabeam", function()
			return LocalPlayer():IsPowerSuitBeamEnabled(4);
		end, "#mp.settings.cheats.weapons.plasmabeam.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.supermissile.text", "mp_cheats_enable_supermissile", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(1);
		end, "#mp.settings.cheats.weapons.supermissile.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.wavebuster.text", "mp_cheats_enable_wavebuster", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(2);
		end, "#mp.settings.cheats.weapons.wavebuster.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.icespreader.text", "mp_cheats_enable_icespreader", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(3);
		end, "#mp.settings.cheats.weapons.icespreader.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.weapons.flamethrower.text", "mp_cheats_enable_flamethrower", function()
			return LocalPlayer():IsPowerSuitMissileComboEnabled(4);
		end, "#mp.settings.cheats.weapons.flamethrower.help");
	end);

	-- Create Morph Ball cheats menu.
	spawnmenu.AddToolMenuOption("mpSettings", "mpCheats", "mpMorphBall", "#mp.settings.cheats.morphball.title", "", "", function(panel)

		panel:Clear();

		WGL.NumSlider(panel, "#mp.settings.cheats.morphball.pbombcapacity.text", "mp_cheats_set_powerbombcapacity", function()
			return LocalPlayer():GetPowerSuitPowerBombMaxAmmo();
		end, 0, 8, 0, "#mp.settings.cheats.morphball.pbombcapacity.help");

		WGL.NumSlider(panel, "#mp.settings.cheats.morphball.pbombamount.text", "mp_cheats_set_powerbombamount", function()
			return LocalPlayer():GetPowerSuitPowerBombAmmo();
		end, 0, 8, 0, "#mp.settings.cheats.morphball.pbombamount.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.morphball.morphball.text", "mp_cheats_enable_morphball", function()
			return LocalPlayer():IsMorphBallEnabled();
		end, "#mp.settings.cheats.morphball.morphball.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.morphball.bombs.text", "mp_cheats_enable_morphballbombs", function()
			return LocalPlayer():IsMorphBallBombsEnabled();
		end, "#mp.settings.cheats.morphball.bombs.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.morphball.boost.text", "mp_cheats_enable_morphballboost", function()
			return LocalPlayer():IsMorphBallBoostEnabled();
		end, "#mp.settings.cheats.morphball.boost.help");

		WGL.CheckBox(panel, "#mp.settings.cheats.morphball.spider.text", "mp_cheats_enable_morphballspider", function()
			return LocalPlayer():IsMorphBallSpiderEnabled();
		end, "#mp.settings.cheats.morphball.spider.help");
	end);
end);