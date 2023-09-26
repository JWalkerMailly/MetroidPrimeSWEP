
local debugState = 0;
hook.Add("Think", "DEBUG.InitializeDebug", function(ply)
	debugState = GetConVar("developer"):GetInt();
end);

--
-- Save State Events
--

hook.Add("MP.OnSaveState", "DEBUG.OnSaveState", function(powersuit)
	if (debugState > 1) then print("MP.OnSaveState", powersuit); end
end);

--
-- Visor Events
-- 

hook.Add("MP.OnVisorChanged", "DEBUG.OnVisorChanged", function(powersuit, previousVisor, nextVisor)
	if (debugState > 1) then print("MP.OnVisorChanged", powersuit, previousVisor, nextVisor); end
end);

hook.Add("MP.OnTargetChanged", "DEBUG.OnTargetChanged", function(powersuit, target)
	if (debugState > 1) then print("MP.OnTargetChanged", powersuit, target); end
end);

hook.Add("MP.OnScanCompleted", "DEBUG.OnScanCompleted", function(powersuit, target)
	if (debugState > 1) then print("MP.OnScanCompleted", powersuit, target); end
end);

--
-- Beam Events
-- 

hook.Add("MP.OnBeamChanged", "DEBUG.OnBeamChanged", function(powersuit, previousBeam, nextBeam)
	if (debugState > 1) then print("MP.OnBeamChanged", powersuit, previousBeam, nextBeam); end
end);

hook.Add("MP.ChargeBeamThink", "DEBUG.ChargeBeamThink", function(powersuit)
	if (debugState > 1) then print("MP.ChargeBeamThink", powersuit); end
end);

--
-- Morph Ball Events
-- 

hook.Add("MP.OnMorphBall", "DEBUG.OnMorphBall", function(ply, powersuit, morphball)
	if (debugState > 1) then print("MP.OnMorphBall", ply, powersuit, morphball); end
end);

hook.Add("MP.OnMorphBallUnmorph", "DEBUG.OnMorphBallUnmorph", function(ply, powersuit)
	if (debugState > 1) then print("MP.OnMorphBallUnmorph", ply, powersuit); end
end);

hook.Add("MP.OnMorphBallBoost", "DEBUG.OnMorphBallBoost", function(morphball)
	if (debugState > 1) then print("MP.OnMorphBallBoost", morphball); end
end);

hook.Add("MP.MorphBallSpiderThink", "DEBUG.MorphBallSpiderThink", function(morphball, surfaceParent, parentPhys, parentVelocity)
	if (debugState > 1) then print("MP.MorphBallSpiderThink", morphball, surfaceParent, parentPhys, parentVelocity); end
end);

--
-- Movement Events
-- 

hook.Add("MP.OnDash", "DEBUG.OnDash", function(ply, powersuit)
	if (debugState > 1) then print("MP.OnDash", ply, powersuit); end
end);

hook.Add("MP.GrappleBeamThink", "DEBUG.GrappleBeamThink", function(ply, powersuit, anchor)
	if (debugState > 1) then print("MP.GrappleBeamThink", ply, powersuit, anchor); return true; end
end);

--
-- Draw Events
--

hook.Add("MP.PreDrawPowerSuitHUD", "DEBUG.PreDrawPowerSuitHUD", function(weapon, damage)
	if (debugState > 2) then print("MP.PreDrawPowerSuitHUD", weapon, damage); end
end);

hook.Add("MP.PostDrawPowerSuitHUD", "DEBUG.PostDrawPowerSuitHUD", function(weapon, damage)
	if (debugState > 2) then print("MP.PostDrawPowerSuitHUD", weapon, damage); end
end);

hook.Add("MP.PreDrawBeamMenu", "DEBUG.PreDrawBeamMenu", function(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)
	if (debugState > 2) then print("MP.PreDrawBeamMenu", weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen); return true; end
end);

hook.Add("MP.PostDrawBeamMenu", "DEBUG.PostDrawBeamMenu", function(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)
	if (debugState > 2) then print("MP.PostDrawBeamMenu", weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen); end
end);

hook.Add("MP.PreDrawVisorMenu", "DEBUG.PreDrawVisorMenu", function(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)
	if (debugState > 2) then print("MP.PreDrawVisorMenu", weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen); return true; end
end);

hook.Add("MP.PostDrawVisorMenu", "DEBUG.PostDrawVisorMenu", function(weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen)
	if (debugState > 2) then print("MP.PostDrawVisorMenu", weapon, pos, angle, up, right, forward, fovCompensation, blend, widescreen); end
end);

hook.Add("MP.PreDrawMorphBallHUD", "DEBUG.PreDrawMorphBallHUD", function(weapon)
	if (debugState > 2) then print("MP.PreDrawMorphBallHUD", weapon); return true; end
end);

hook.Add("MP.PostDrawMorphBallHUD", "DEBUG.PostDrawMorphBallHUD", function(weapon)
	if (debugState > 2) then print("MP.PostDrawMorphBallHUD", weapon); end
end);

hook.Add("MP.PreDrawCombatVisor", "DEBUG.PreDrawCombatVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PreDrawCombatVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); return true; end
end);

hook.Add("MP.PostDrawCombatVisor", "DEBUG.PostDrawCombatVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PostDrawCombatVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); end
end);

hook.Add("MP.PreDrawScanVisor", "DEBUG.PreDrawScanVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PreDrawScanVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); return true; end
end);

hook.Add("MP.PostDrawScanVisor", "DEBUG.PostDrawScanVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PostDrawScanVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); end
end);

hook.Add("MP.PreDrawThermalVisor", "DEBUG.PreDrawThermalVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PreDrawThermalVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); return true; end
end);

hook.Add("MP.PostDrawThermalVisor", "DEBUG.PostDrawThermalVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PostDrawThermalVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); end
end);

hook.Add("MP.PreDrawXRayVisor", "DEBUG.PreDrawXRayVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PreDrawXRayVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); return true; end
end);

hook.Add("MP.PostDrawXRayVisor", "DEBUG.PostDrawXRayVisor", function(weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity)
	if (debugState > 2) then print("MP.PostDrawXRayVisor", weapon, beam, visor, hudPos, hudAngle, guiPos, guiColor, fovRatio, transition, transitionStart, widescreen, visorOpacity); end
end);