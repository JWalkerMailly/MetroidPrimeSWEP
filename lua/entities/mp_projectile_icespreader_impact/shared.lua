
if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("base_anim");

ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Model       = "models/metroid/effects/icecap.mdl";
ENT.Size 	    = 20;
ENT.LifeTime    = 5;
ENT.Spread      = 1000;
ENT.Frames      = 3;
ENT.MaxTests    = 32;
ENT.Cardinals   = {
	Vector( 1,  0,  0),
	Vector(-1,  0,  0),
	Vector( 0,  1,  0),
	Vector( 0, -1,  0),
	Vector( 0,  0,  1),
	Vector( 0,  0, -1)
};

function ENT:Initialize()

	-- Spawn time used for fadeout.
	self.SpawnTime = CurTime();

	-- Make entity "static".
	if (!SERVER) then return; end
	self:SetModel(self.Model);
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_FLY);
	self:SetNotSolid(true);
	self:PhysWake();
	self:DrawShadow(false);
end

function ENT:SpawnIce(pos, normal)

	-- Apply random offset and angle to chunk surface placement.
	local iceAng = normal:Angle();
	local icePos = pos + iceAng:Up() * math.random(0, self.Size * 0.25) + iceAng:Right() * math.random(0, self.Size * 0.25);
	iceAng:RotateAroundAxis(iceAng:Forward(), math.random(0, 360));

	-- Create clientside ice effect at given chunk.
	local icecap = ClientsideModel(self.Model);
	icecap:SetRenderMode(RENDERMODE_TRANSALPHA);
	icecap:SetPos(icePos);
	icecap:SetAngles(iceAng);
	icecap:Spawn();
	return icecap;
end

function ENT:IceSpread()

	for i = 1, self.MaxTests do

		self.ChunkIndex = self.ChunkIndex + 1;

		-- Acquire a new world chunk to find a new surface. Do nothing if we overlap a previous chunk.
		local chunkDir = self.Cardinals[WGL.RandomInt(1, 6, self.ChunkIndex)] * self.Size;
		local chunk    = self.ChunkCache[WGL.RandomInt(1, #self.ChunkCache, -self.ChunkIndex)] + chunkDir;
		if (self:ChunkExists(chunk)) then continue; end

		-- Attempt to acquire surface data from chunk.
		local pos, normal = self:GetChunkSurface(self:GetPos() + chunk, self.Size)
		if (!pos) then continue; end

		-- Spawn ice on given surface and save chunk data for future iterations and cleanup.
		table.insert(self.ChunkCache, chunk);
		table.insert(self.ChunkData, self:SpawnIce(pos, normal));
		self.ChunkTests[chunk[1]][chunk[2]][chunk[3]] = true;
		break;
	end
end

function ENT:Think()

	-- Cleanup entity if lifetime is expired.
	if (SERVER && CurTime() > self.SpawnTime + self.LifeTime) then return SafeRemoveEntity(self); end
	if (!CLIENT) then return; end

	-- Chunk data setup for surface acquisition.
	local pos = self:GetPos();
	if (!self.ChunkCache) then
		self.ChunkData  = {};
		self.ChunkTests = {};
		self.ChunkCache = { Vector() };
		self.ChunkIndex = pos[1] + pos[2] + pos[3];
	end

	-- Do nothing if ice has spread far enough.
	if (self.ChunkIndex - (pos[1] + pos[2] + pos[3]) > self.Spread) then return; end

	-- Ice spread algorithm. We subdivide the world into discrete sized chunks
	-- to trace against in order to obtain surface data for clientside ice spread.
	-- This is heavily based on @Mee's moss spread algorithm. (workshop 2826441666)
	for frame = 1, self.Frames do self:IceSpread(); end
end