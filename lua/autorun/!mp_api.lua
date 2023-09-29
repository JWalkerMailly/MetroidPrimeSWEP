
local _player = FindMetaTable("Player");
local _entity = FindMetaTable("Entity");

-- ----------------------------------------------
-- OPTIONS API
-- ----------------------------------------------

CreateConVar("mp_cheats_autosave",         "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT }, nil, 0, 1);
CreateConVar("mp_cheats_damagetakenscale", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT }, nil, 1, 10);
CreateConVar("mp_cheats_damagegivenscale", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT }, nil, 1, 10);
CreateConVar("mp_cheats_scandashing",      "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT }, nil, 0, 1);

CreateClientConVar("mp_options_viewmodelfov",   "62", true, false);
CreateClientConVar("mp_options_widescreenfix",   "0", true, false);
CreateClientConVar("mp_options_visoropacity",  "100", true, false, "", 0, 100);
CreateClientConVar("mp_options_helmetopacity", "100", true, false, "", 0, 100);
CreateClientConVar("mp_options_hudlag",          "1", true, false);
CreateClientConVar("mp_options_facereflection",  "1", true, false);
CreateClientConVar("mp_options_playermodel",     "1", true, true);
CreateClientConVar("mp_options_autoaim",         "1", true, true);
if (CLIENT) then concommand.Add("mp_options_playermodel_get", function(ply) gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2701609725"); end); end

-- ----------------------------------------------
-- ENUMS
-- ----------------------------------------------

DMG_MP_NULL    = 0;
DMG_MP_POWER   = 1;
DMG_MP_WAVE    = 2;
DMG_MP_ICE     = 4;
DMG_MP_PLASMA  = 8;
DMG_MP_BOMB    = 16;
DMG_MP_SPECIAL = 32;

-- ----------------------------------------------
-- UTILITIES API
-- ----------------------------------------------

function _player:GetPowerSuit()
	local powersuit = self:GetWeapon("weapon_mp_powersuit");
	if (powersuit == nil || powersuit.StateIdentifier == nil) then return nil; end
	return powersuit;
end

-- lua_run print(Entity(1):UsingPowerSuit());
function _player:UsingPowerSuit(ignoreState)
	if (!IsValid(self)) then return false; end
	local powersuit = self:GetActiveWeapon();
	return IsValid(powersuit) && powersuit:GetClass() == "weapon_mp_powersuit" && (ignoreState || powersuit.StateIdentifier != nil), powersuit;
end

-- lua_run print(Entity(1):UsingMorphBall());
function _player:UsingMorphBall()
	local isPowerSuit, powersuit = self:UsingPowerSuit();
	local morphball = isPowerSuit && powersuit:GetMorphBall() || nil;
	return isPowerSuit && IsValid(morphball), morphball;
end

function _entity:IsMorphBall()
	return IsValid(self) && self:GetClass() == "mp_morphball";
end

function _entity:IsGrappleAnchor()
	return game.MetroidPrimeAnchors.Cache[self:GetClass()];
end

-- lua_run print(Entity(1):SavePowerSuitState());
if (SERVER) then concommand.Add("mp_cheats_savestate", function(ply, cmd, args) ply:SavePowerSuitState(); end, nil, nil, FCVAR_CHEAT); end
function _player:SavePowerSuitState()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit:SaveState(true);
end

-- lua_run print(Entity(1):LoadPowerSuitState("metroidprime/endgame.json"));
function _player:LoadPowerSuitState(json)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit:LoadState(util.JSONToTable(file.Read(json, "DATA")));
end

function _entity:SetIgnitable(ignitable)
	self:SetNWBool("Ignitable", ignitable);
end

function _entity:IsIgnitable()
	return self:GetNWBool("Ignitable", true);
end

-- ----------------------------------------------
-- POWERSUIT API
-- ----------------------------------------------

-- lua_run print(Entity(1):GetPowerSuitAmmo("Missile"));
function _player:GetPowerSuitAmmo(type)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:GetAmmo(type);
end

-- lua_run print(Entity(1):AddPowerSuitAmmo("Missile", 50));
function _player:AddPowerSuitAmmo(type, amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:AddAmmo(type, amount);
end

-- lua_run print(Entity(1):SetPowerSuitAmmo("Missile", 50));
if (SERVER) then concommand.Add("mp_cheats_set_missileamount", function(ply, cmd, args) ply:SetPowerSuitAmmo("Missile", tonumber(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitAmmo(type, amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:SetAmmo(type, amount);
end

-- lua_run print(Entity(1):GetPowerSuitMaxAmmo("Missile"));
function _player:GetPowerSuitMaxAmmo(type)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:GetMaxAmmo(type);
end

-- lua_run print(Entity(1):AddPowerSuitMaxAmmo("Missile", 50));
function _player:AddPowerSuitMaxAmmo(type, amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:AddMaxAmmo(type, amount);
end

-- lua_run print(Entity(1):SetPowerSuitMaxAmmo("Missile", 0));
if (SERVER) then concommand.Add("mp_cheats_set_missilecapacity", function(ply, cmd, args) ply:SetPowerSuitMaxAmmo("Missile", tonumber(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitMaxAmmo(type, amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.ArmCannon:SetMaxAmmo(type, amount);
end

-- lua_run print(Entity(1):IsPowerSuitBeamEnabled(4));
function _player:IsPowerSuitBeamEnabled(index)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.ArmCannon:IsBeamEnabled(index);
end

-- lua_run print(Entity(1):EnablePowerSuitBeam(4, false));
if (SERVER) then concommand.Add("mp_cheats_enable_powerbeam",  function(ply, cmd, args) ply:EnablePowerSuitBeam(1, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_wavebeam",   function(ply, cmd, args) ply:EnablePowerSuitBeam(2, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_icebeam",    function(ply, cmd, args) ply:EnablePowerSuitBeam(3, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_plasmabeam", function(ply, cmd, args) ply:EnablePowerSuitBeam(4, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitBeam(index, enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.ArmCannon:EnableBeam(index, enable);
	return true;
end

-- lua_run print(Entity(1):IsPowerSuitChargeBeamEnabled());
function _player:IsPowerSuitChargeBeamEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.ArmCannon:IsChargeBeamEnabled();
end

-- lua_run print(Entity(1):EnablePowerSuitChargeBeam(false));
if (SERVER) then concommand.Add("mp_cheats_enable_chargebeam", function(ply, cmd, args) ply:EnablePowerSuitChargeBeam(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitChargeBeam(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.ArmCannon:EnableChargeBeam(enable);
	return true;
end

-- lua_run print(Entity(1):IsPowerSuitMissileComboEnabled(1));
function _player:IsPowerSuitMissileComboEnabled(index)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.ArmCannon:IsMissileComboEnabled(index);
end

-- lua_run print(Entity(1):EnablePowerSuitMissileCombo(1, false));
if (SERVER) then concommand.Add("mp_cheats_enable_supermissile", function(ply, cmd, args) ply:EnablePowerSuitMissileCombo(1, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_wavebuster",   function(ply, cmd, args) ply:EnablePowerSuitMissileCombo(2, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_icespreader",  function(ply, cmd, args) ply:EnablePowerSuitMissileCombo(3, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_flamethrower", function(ply, cmd, args) ply:EnablePowerSuitMissileCombo(4, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitMissileCombo(index, enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.ArmCannon:EnableMissileCombo(index, enable);
	return true;
end

-- ----------------------------------------------
-- SUIT API
-- ----------------------------------------------

-- Prepare anchors table for compatibility.
game.MetroidPrimeAnchors = {};
game.MetroidPrimeAnchors.Cache = { ["mp_grapple_anchor_point"] = true };
function game.MetroidPrimeAnchors.Add(class)
	game.MetroidPrimeAnchors.Cache[class] = true;
end

-- lua_run print(Entity(1):IsPowerSuitSpaceJumpEnabled());
function _player:IsPowerSuitSpaceJumpEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.PowerSuit:IsSpaceJumpEnabled();
end

-- lua_run print(Entity(1):EnablePowerSuitSpaceJump(true));
if (SERVER) then concommand.Add("mp_cheats_enable_spacejump", function(ply, cmd, args) ply:EnablePowerSuitSpaceJump(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitSpaceJump(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.PowerSuit:EnableSpaceJump(enable);
	return true;
end

-- lua_run print(Entity(1):IsPowerSuitGrappleEnabled());
function _player:IsPowerSuitGrappleEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.PowerSuit:IsGrappleEnabled();
end

-- lua_run print(Entity(1):EnablePowerSuitGrapple(1));
if (SERVER) then concommand.Add("mp_cheats_enable_grapplebeam", function(ply, cmd, args) ply:EnablePowerSuitGrapple(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitGrapple(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.PowerSuit:EnableGrapple(enable);
	return true;
end

-- lua_run print(Entity(1):IsPowerSuitSuitEnabled(1));
function _player:IsPowerSuitSuitEnabled(suit)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.PowerSuit:IsSuitEnabled(suit);
end

-- lua_run print(Entity(1):EnablePowerSuitSuit(2, true));
if (SERVER) then concommand.Add("mp_cheats_enable_powersuit",   function(ply, cmd, args) ply:EnablePowerSuitSuit(1, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_variasuit",   function(ply, cmd, args) ply:EnablePowerSuitSuit(2, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_gravitysuit", function(ply, cmd, args) ply:EnablePowerSuitSuit(3, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_phazonsuit",  function(ply, cmd, args) ply:EnablePowerSuitSuit(4, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitSuit(suit, enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.PowerSuit:EnableSuit(suit, enable);
	return true;
end

-- ----------------------------------------------
-- VISOR API
-- ----------------------------------------------

-- Prepare threats table for compatibility.
game.MetroidPrimeThreats = {};
game.MetroidPrimeThreats.Cache = {
	["env_fire"] = true,
	["trigger_hurt"] = true,
	["point_hurt"] = true
};
function game.MetroidPrimeThreats.Add(class)
	game.MetroidPrimeThreats.Cache[class] = true;
end

-- Prepare log book cache for compatibility.
game.MetroidPrimeLogBook = {};
game.MetroidPrimeLogBook.Cache = {
	["npc_rollermine"] = { Description = "They see me rollin'." },
	["sent_ball"] = { Description = "An edible bouncy ball." }
};

function game.MetroidPrimeLogBook.Add(class, logbook)
	game.MetroidPrimeLogBook.Cache[class] = logbook;
end

local ignoreCollisionGroups = {
	[COLLISION_GROUP_DEBRIS]          = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER]  = true,
	[COLLISION_GROUP_BREAKABLE_GLASS] = true,
	[COLLISION_GROUP_IN_VEHICLE]      = true,
	[COLLISION_GROUP_VEHICLE_CLIP]    = true,
	[COLLISION_GROUP_PROJECTILE]      = true,
	[COLLISION_GROUP_DOOR_BLOCKER]    = true,
	[COLLISION_GROUP_PASSABLE_DOOR]   = true,
	[COLLISION_GROUP_DISSOLVING]      = true,
	[COLLISION_GROUP_PUSHAWAY]        = true,
	[LAST_SHARED_COLLISION_GROUP]     = true
}

-- Prepare logbook lookup table to avoid using ents.GetAll later.
game.MetroidPrimeLogBook.Entities = {};
function _entity:CanBeScanned()

	-- Make sure we can't scan ourselves.
	if (CLIENT && self == LocalPlayer()) then return false; end

	-- Entity has to be solid.
	local isSolid = self:IsSolid();
	if (!isSolid) then return false end

	-- Ignore unecessary collision groups.
	if (ignoreCollisionGroups[self:GetCollisionGroup()]) then return false; end

	-- Entity has to be a player, a vehicle, or a NPC.
	local isVehicle = self:IsVehicle();
	if (string.find(self:GetClass(), "^prop_") && !isVehicle) then return false end
	if (!self:IsScripted() && !self:IsWeapon() && !isVehicle && !WGL.IsAlive(self)) then return false end

	return true;
end

function _entity:GetLogBookData()

	local logbook = self.LogBook;
	if (!logbook) then return nil; end

	-- Return logbook data in simplified format.
	return logbook.Description, logbook.Left, logbook.Right, logbook.ScanDuration;
end

-- lua_run print(Entity(1):GetPowerSuitEnergyTanks());
function _player:GetPowerSuitEnergyTanks()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.Helmet:GetEnergy();
end

-- lua_run print(Entity(1):AddPowerSuitEnergyTanks(1, true));
function _player:AddPowerSuitEnergyTanks(amount, norefill)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	local energy = powersuit.Helmet:AddEnergy(amount);
	if (!norefill) then self:SetHealth(energy * 100 + 99); end
	return energy;
end

-- lua_run print(Entity(1):SetPowerSuitEnergyTanks(1, true));
if (SERVER) then concommand.Add("mp_cheats_set_energytankamount", function(ply, cmd, args) ply:SetPowerSuitEnergyTanks(tonumber(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitEnergyTanks(amount, norefill)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	local energy = powersuit.Helmet:SetEnergy(amount);
	if (!norefill) then self:SetHealth(energy * 100 + 99); end
	return energy;
end

-- lua_run print(Entity(1):GetPowerSuitMaxEnergyTanks());
function _player:GetPowerSuitMaxEnergyTanks()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.Helmet:GetMaxEnergy();
end

-- lua_run print(Entity(1):AddPowerSuitMaxEnergyTanks(1, true));
function _player:AddPowerSuitMaxEnergyTanks(amount, refill)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	local energy, maxEnergy = powersuit.Helmet:AddMaxEnergy(amount, refill);
	local maxHealth = maxEnergy * 100 + 99;
	self:SetMaxHealth(maxHealth);
	if (refill) then self:SetHealth(maxHealth); end

	return energy, maxEnergy;
end

-- lua_run print(Entity(1):SetPowerSuitMaxEnergyTanks(1, true));
if (SERVER) then concommand.Add("mp_cheats_set_energytankcapacity", function(ply, cmd, args) ply:SetPowerSuitMaxEnergyTanks(tonumber(args[1]), tobool(args[2])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitMaxEnergyTanks(amount, refill)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	local energy, maxEnergy = powersuit.Helmet:SetMaxEnergy(amount, refill);
	local maxHealth = maxEnergy * 100 + 99;
	self:SetMaxHealth(maxHealth);
	if (refill) then self:SetHealth(maxHealth); end

	return energy, maxEnergy;
end

-- lua_run print(Entity(1):IsPowerSuitVisorEnabled(2));
function _player:IsPowerSuitVisorEnabled(index)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.Helmet:IsVisorEnabled(index);
end

-- lua_run print(Entity(1):EnablePowerSuitVisor(2, false));
if (SERVER) then concommand.Add("mp_cheats_enable_combatvisor",  function(ply, cmd, args) ply:EnablePowerSuitVisor(1, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_scanvisor",    function(ply, cmd, args) ply:EnablePowerSuitVisor(2, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_thermalvisor", function(ply, cmd, args) ply:EnablePowerSuitVisor(3, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
if (SERVER) then concommand.Add("mp_cheats_enable_xrayvisor",    function(ply, cmd, args) ply:EnablePowerSuitVisor(4, tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnablePowerSuitVisor(index, enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.Helmet:EnableVisor(index, enable);
	return true;
end

function _entity:SetXRayHot(hot)

	if (!IsValid(self)) then return false; end
	self:SetNWBool("XRayVisorHot", hot);
	return hot;
end

function _entity:SetXRayCold(cold)

	if (!IsValid(self)) then return false; end
	self:SetNWBool("XRayVisorCold", cold);
	return cold;
end

function _entity:IsXRayHot()

	if (!IsValid(self)) then return false; end
	return self:GetNWBool("XRayVisorHot", false);
end

function _entity:IsXRayCold()

	if (!IsValid(self)) then return false; end
	return self:GetNWBool("XRayVisorCold", false);
end

function _entity:SetThermalHot(hot)

	if (!IsValid(self)) then return false; end
	self:SetNWBool("ThermalVisorHot", hot);
	return hot;
end

function _entity:SetThermalCold(cold)

	if (!IsValid(self)) then return false; end
	self:SetNWBool("ThermalVisorCold", cold);
	return cold;
end

function _entity:IsThermalHot()

	if (!IsValid(self)) then return false; end
	return self:GetNWBool("ThermalVisorHot", false);
end

function _entity:IsThermalCold()

	if (!IsValid(self)) then return false; end
	return self:GetNWBool("ThermalVisorCold", false);
end

-- Prepare material swap table for faster lookups during rendering.
game.MetroidPrimeMaterialSwaps = {};
function _entity:HasHeatSignature()
	return (WGL.IsAlive(self) || self:IsScripted() || self:IsVehicle() || self:IsThermalHot()) && !self:IsThermalCold();
end

function _entity:HasXRaySignature()
	return self:IsXRayHot() || self:IsXRayCold();
end

-- ----------------------------------------------
-- MORPHBALL API
-- ----------------------------------------------

game.MetroidPrimeSpiderSurfaces = {}
game.MetroidPrimeSpiderSurfaces.Cache = {
	["canister"]              = true,
	["chain"]                 = true,
	["chainlink"]             = true,
	["combine_metal"]         = true,
	["crowbar"]               = true,
	["floating_metal_barrel"] = true,
	["grenade"]               = true,
	["gunship"]               = true,
	["metal"]                 = true,
	["metal_barrel"]          = true,
	["metal_bouncy"]          = true,
	["Metal_Box"]             = true,
	["metal_seafloorcar"]     = true,
	["metalgrate"]            = true,
	["metalpanel"]            = true,
	["metalvent"]             = true,
	["metalvehicle"]          = true,
	["paintcan"]              = true,
	["popcan"]                = true,
	["roller"]                = true,
	["slipperymetal"]         = true,
	["solidmetal"]            = true,
	["strider"]               = true,
	["weapon"]                = true
};

function game.MetroidPrimeSpiderSurfaces.Add(surfaceProp)
	game.MetroidPrimeSpiderSurfaces.Cache[surfaceProp] = true;
end

-- lua_run print(Entity(1):IsMorphBallEnabled());
function _player:IsMorphBallEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.MorphBall:IsMorphEnabled();
end

-- lua_run print(Entity(1):EnableMorphBall(false));
if (SERVER) then concommand.Add("mp_cheats_enable_morphball", function(ply, cmd, args) ply:EnableMorphBall(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnableMorphBall(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.MorphBall:EnableMorph(enable);
	return true;
end

-- lua_run print(Entity(1):IsMorphBallBombsEnabled());
function _player:IsMorphBallBombsEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.MorphBall:IsBombsEnabled();
end

-- lua_run print(Entity(1):EnableMorphBallBombs(false));
if (SERVER) then concommand.Add("mp_cheats_enable_morphballbombs", function(ply, cmd, args) ply:EnableMorphBallBombs(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnableMorphBallBombs(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.MorphBall:EnableBombs(enable);
	return true;
end

-- lua_run print(Entity(1):IsMorphBallBoostEnabled());
function _player:IsMorphBallBoostEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.MorphBall:IsBoostEnabled();
end

-- lua_run print(Entity(1):EnableMorphBallBoost(false));
if (SERVER) then concommand.Add("mp_cheats_enable_morphballboost", function(ply, cmd, args) ply:EnableMorphBallBoost(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnableMorphBallBoost(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.MorphBall:EnableBoost(enable);
	return true;
end

-- lua_run print(Entity(1):IsMorphBallSpiderEnabled());
function _player:IsMorphBallSpiderEnabled()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	return powersuit.MorphBall:IsSpiderEnabled();
end

-- lua_run print(Entity(1):EnableMorphBallSpider(false));
if (SERVER) then concommand.Add("mp_cheats_enable_morphballspider", function(ply, cmd, args) ply:EnableMorphBallSpider(tobool(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:EnableMorphBallSpider(enable)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return false; end
	powersuit.MorphBall:EnableSpider(enable);
	return true;
end

-- lua_run print(Entity(1):GetPowerSuitPowerBombAmmo());
function _player:GetPowerSuitPowerBombAmmo()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:GetPowerBombAmmo();
end

-- lua_run print(Entity(1):AddPowerSuitPowerBombAmmo(50));
function _player:AddPowerSuitPowerBombAmmo(amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:AddPowerBombAmmo(amount);
end

-- lua_run print(Entity(1):SetPowerSuitPowerBombAmmo(50));
if (SERVER) then concommand.Add("mp_cheats_set_powerbombamount", function(ply, cmd, args) ply:SetPowerSuitPowerBombAmmo(tonumber(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitPowerBombAmmo(amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:SetPowerBombAmmo(amount);
end

-- lua_run print(Entity(1):GetPowerSuitPowerBombMaxAmmo());
function _player:GetPowerSuitPowerBombMaxAmmo()

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:GetPowerBombMaxAmmo();
end

-- lua_run print(Entity(1):AddPowerSuitPowerBombMaxAmmo(1));
function _player:AddPowerSuitPowerBombMaxAmmo(amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:AddPowerBombMaxAmmo(amount);
end

-- lua_run print(Entity(1):SetPowerSuitPowerBombMaxAmmo(0));
if (SERVER) then concommand.Add("mp_cheats_set_powerbombcapacity", function(ply, cmd, args) ply:SetPowerSuitPowerBombMaxAmmo(tonumber(args[1])); end, nil, nil, FCVAR_CHEAT); end
function _player:SetPowerSuitPowerBombMaxAmmo(amount)

	local powersuit = self:GetPowerSuit();
	if (powersuit == nil) then return nil; end
	return powersuit.MorphBall:SetPowerBombMaxAmmo(amount);
end