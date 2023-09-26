
DEFINE_BASECLASS("base_anim");

-- Syntactic sugar and setup.
MORPHBALL               = ENT;
MORPHBALL.RenderGroup   = RENDERGROUP_BOTH;
MORPHBALL.Radius        = 17;
MORPHBALL.MaxSpeed      = 700;
MORPHBALL.MaxBoost      = 1600;
MORPHBALL.Acceleration  = 2000;
MORPHBALL.Deceleration  = 300;
MORPHBALL.MinSlope      = -0.05;

MORPHBALL.LogBook = {
	Description = "Morph Ball."
}

-- Shared files.
do
	include("events/movement.lua");
	include("events/bomb.lua");
	include("events/boost.lua");
	include("events/spider.lua");
end

-- Initialization files.
if (SERVER) then
	AddCSLuaFile("setup.lua");
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");

	AddCSLuaFile("events/movement.lua");
	AddCSLuaFile("events/bomb.lua");
	AddCSLuaFile("events/boost.lua");
	AddCSLuaFile("events/spider.lua");

	AddCSLuaFile("rendering/effects/spawn.lua");
	AddCSLuaFile("rendering/effects/boost.lua");
	AddCSLuaFile("rendering/effects/damage.lua");
	AddCSLuaFile("rendering/effects/trail.lua");
	AddCSLuaFile("rendering/simulations/morphball.lua");
end

-- Client initialization files.
if (CLIENT) then
	include("rendering/effects/spawn.lua");
	include("rendering/effects/boost.lua");
	include("rendering/effects/damage.lua");
	include("rendering/effects/trail.lua");
	include("rendering/simulations/morphball.lua");
end