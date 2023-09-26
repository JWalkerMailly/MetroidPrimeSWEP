
include("shared.lua");

function ENT:ChunkExists(pos)

	-- Initialize chunk partition if not already done.
	self.ChunkTests[pos[1]] = self.ChunkTests[pos[1]] || {};
	self.ChunkTests[pos[1]][pos[2]] = self.ChunkTests[pos[1]][pos[2]] || {};

	-- Chunks are of the structure chunk[x][y][z]. This offers the
	-- highest level of precision when querying for chunk validity.
	return self.ChunkTests[pos[1]][pos[2]][pos[3]];
end

function ENT:GetChunkSurface(pos, size)

	local chunkHull  = Vector(0.5, 0.5, 0.5) * size;
	local chunkTrace = util.TraceHull({
		start  = pos,
		endpos = pos,
		mins   = -chunkHull,
		maxs   = chunkHull,
		mask   = MASK_SOLID_BRUSHONLY
	});

	-- Check for chunk validity before processing surface data.
	if (!chunkTrace.Hit && chunkTrace.FractionLeftSolid == 0) then return; end

	-- Attempt to find surface in up local space.
	local surfaceValid, surfacePos, surfaceNormal = self:ChunkHasSurface(pos, Vector(0, 0, 1), size);
	if (surfaceValid) then return surfacePos, surfaceNormal; end

	-- Attempt to find surface in forward local space.
	surfaceValid, surfacePos, surfaceNormal = self:ChunkHasSurface(pos, Vector(1, 0, 0), size);
	if (surfaceValid) then return surfacePos, surfaceNormal; end

	-- Attempt to find surface in rigth local space.
	surfaceValid, surfacePos, surfaceNormal = self:ChunkHasSurface(pos, Vector(0, 1, 0), size);
	if (surfaceValid) then return surfacePos, surfaceNormal; end

	return nil;
end

function ENT:ChunkHasSurface(pos, dir, size)

	local traceDepth   = size * 0.99;
	local surfaceTrace = util.TraceLine({
		start  = pos + dir * traceDepth,
		endpos = pos - dir * traceDepth,
		mask   = MASK_SOLID_BRUSHONLY
	});

	-- Attempt to find surface from cardinal direction.
	if (surfaceTrace.AllSolid || !surfaceTrace.HitWorld || (!surfaceTrace.Hit && surfaceTrace.FractionLeftSolid == 0)) then return false; end
	if (surfaceTrace.HitNormal != Vector()) then return true, surfaceTrace.HitPos, surfaceTrace.HitNormal; end

	surfaceTrace = util.TraceLine({
		start  = pos - dir * traceDepth,
		endpos = pos + dir * traceDepth,
		mask   = MASK_SOLID_BRUSHONLY
	});

	-- Attempt to find surface from inverse cardinal direction.
	if (surfaceTrace.AllSolid || !surfaceTrace.HitWorld || (!surfaceTrace.Hit && surfaceTrace.FractionLeftSolid == 0)) then return false; end
	if (surfaceTrace.HitNormal != Vector()) then return true, surfaceTrace.HitPos, surfaceTrace.HitNormal; end

	return false;
end

function ENT:Draw()

	-- Failsafe.
	if (!self.SpawnTime) then return; end

	-- Fade out all ice caps found in chunk data.
	for k,v in pairs(self.ChunkData) do
		v:SetColor(Color(255, 255, 255, math.Clamp((1 - (CurTime() - self.SpawnTime) / self.LifeTime) * 255, 0, 255)));
	end
end

function ENT:OnRemove()

	-- Cleanup all client side models upon removal.
	for k,v in pairs(self.ChunkData) do
		if (IsValid(v)) then SafeRemoveEntity(v); end
	end
end