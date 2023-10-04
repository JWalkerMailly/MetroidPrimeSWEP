
-- Syntactic sugar and setup.
POWERSUIT               = SWEP;
POWERSUIT.PrintName     = "Power Suit";
POWERSUIT.Author        = "WLKRE";
POWERSUIT.Category      = "Metroid Prime";

POWERSUIT.SavePath      = "metroidprime";
POWERSUIT.Spawnable     = true;
POWERSUIT.Editable      = true;

POWERSUIT.WepSelectIcon = Material("weapons/weapon_mp_powersuit");
POWERSUIT.LogBook       = {
	Description = "The Power Suit is an advanced Chozo exoskeleton modified for use by Samus Aran."
};

-- Shared files.
do
	include("events/beam.lua");
	include("events/components.lua");
	include("events/movement.lua");
	include("events/helmet.lua");

	include("statemachines/bootloader.lua");
	include("statemachines/powersuit.lua");
	include("statemachines/armcannon.lua");
	include("statemachines/morphball.lua");
	include("statemachines/helmet.lua");

	include("configs/suits.lua");
	include("configs/beams.lua");
	include("configs/visors.lua");

	include("hooks/death.lua");
	include("hooks/lookup.lua");
end

-- Initialization files.
if (SERVER) then
	AddCSLuaFile("setup.lua");
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");

	AddCSLuaFile("events/beam.lua");
	AddCSLuaFile("events/components.lua");
	AddCSLuaFile("events/movement.lua");
	AddCSLuaFile("events/helmet.lua");

	AddCSLuaFile("statemachines/bootloader.lua");
	AddCSLuaFile("statemachines/powersuit.lua");
	AddCSLuaFile("statemachines/armcannon.lua");
	AddCSLuaFile("statemachines/morphball.lua");
	AddCSLuaFile("statemachines/helmet.lua");

	AddCSLuaFile("configs/suits.lua");
	AddCSLuaFile("configs/beams.lua");
	AddCSLuaFile("configs/visors.lua");

	AddCSLuaFile("rendering/view.lua");
	AddCSLuaFile("rendering/notifications.lua");

	AddCSLuaFile("rendering/components/helmet.lua");
	AddCSLuaFile("rendering/components/visormenu.lua");
	AddCSLuaFile("rendering/components/beammenu.lua");
	AddCSLuaFile("rendering/components/grapple.lua");
	AddCSLuaFile("rendering/components/scan.lua");

	AddCSLuaFile("rendering/visors/combat.lua");
	AddCSLuaFile("rendering/visors/scan.lua");
	AddCSLuaFile("rendering/visors/thermal.lua");
	AddCSLuaFile("rendering/visors/xray.lua");

	AddCSLuaFile("rendering/effects/chargeball.lua");
	AddCSLuaFile("rendering/effects/facereflection.lua");
	AddCSLuaFile("rendering/effects/beamchange.lua");
	AddCSLuaFile("rendering/effects/grapplebeam.lua");

	AddCSLuaFile("rendering/huds/morphball.lua");
	AddCSLuaFile("rendering/huds/powersuit.lua");

	AddCSLuaFile("hooks/server/damage.lua");
	AddCSLuaFile("hooks/server/vehicle.lua");
	AddCSLuaFile("hooks/server/movement.lua");
	AddCSLuaFile("hooks/server/spawn.lua");
	AddCSLuaFile("hooks/client/camera.lua");
	AddCSLuaFile("hooks/client/rendering.lua");
	AddCSLuaFile("hooks/death.lua");
	AddCSLuaFile("hooks/lookup.lua");

	include("hooks/server/damage.lua");
	include("hooks/server/vehicle.lua");
	include("hooks/server/movement.lua");
	include("hooks/server/spawn.lua");
end

-- Client initialization files.
if (CLIENT) then
	include("rendering/view.lua");
	include("rendering/notifications.lua");

	include("rendering/components/helmet.lua");
	include("rendering/components/visormenu.lua");
	include("rendering/components/beammenu.lua");
	include("rendering/components/grapple.lua");
	include("rendering/components/scan.lua");

	include("rendering/visors/combat.lua");
	include("rendering/visors/scan.lua");
	include("rendering/visors/thermal.lua");
	include("rendering/visors/xray.lua");

	include("rendering/effects/chargeball.lua");
	include("rendering/effects/facereflection.lua");
	include("rendering/effects/beamchange.lua");
	include("rendering/effects/grapplebeam.lua");

	include("rendering/huds/morphball.lua");
	include("rendering/huds/powersuit.lua");

	include("hooks/client/camera.lua");
	include("hooks/client/rendering.lua");
end

function POWERSUIT:Cleanup(autoSave)

	self:StopParticles();

	-- Prevent player from being stuck if frozen from morphball.
	local owner = self:GetOwner();
	if (IsValid(owner)) then
		if (SERVER) then owner:Freeze(false); end
		if (IsValid(owner:GetViewModel())) then owner:GetViewModel():StopParticles(); end
	end

	-- Reset statemachines.
	if (autoSave) then self:AutoSave(); end
	self.Helmet:Reset(true);
	self.ArmCannon:Reset();
	self.MorphBall:Reset();
	self.PowerSuit:Reset();

	-- Reset weapon timings.
	local beamData = self:GetBeam();
	self:StopChargeBeam(beamData);
	self:CloseMissileCombo(beamData);
	self:CloseBeam(beamData, true);

	-- Cleanup resources.
	WGL.CleanupComponents(self);
	WSL.CleanupSounds(self, self.Suits);
	WSL.CleanupSounds(self, self.Beams);
	WSL.CleanupSounds(self, self.Visors);

	-- Reset HUDs.
	if (!CLIENT) then return true; end
	WGL.GetComponent(self, "MorphBallHUD"):Reset();
	WGL.GetComponent(self, "PowerSuitHUD"):Reset(self, true);
	self:ResetCamera();
	return true;
end

function POWERSUIT:Deploy()
	self:GetOwner():SetNWEntity("MP.PowerSuit", self);
	return self:Cleanup();
end

function POWERSUIT:Holster()
	return self:Cleanup();
end

function POWERSUIT:OnRemove()
	self:Cleanup(true);
end