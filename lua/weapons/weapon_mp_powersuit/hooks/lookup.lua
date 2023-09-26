
local function AddEntityToLookupCache(ent)

	-- Add logbook compatibility for entities that do not directly reference the API.
	local class   = ent:GetClass();
	local logBook = game.MetroidPrimeLogBook;
	if (logBook.Cache[class]) then
		ent.LogBook = logBook.Cache[class];
	end

	-- Add entity to material swap cache if it contains material swap logic.
	if (ent:HasHeatSignature() || ent:HasXRaySignature()) then
		game.MetroidPrimeMaterialSwaps[tostring(ent:EntIndex())] = ent;
	end

	-- Add entity to logbook cache if it can be scanned.
	if (!ent:CanBeScanned()) then return; end
	game.MetroidPrimeLogBook.Entities[tostring(ent:EntIndex())] = ent;
end

hook.Add("OnEntityCreated", "POWERSUIT.AddToEntityLookupCache",      AddEntityToLookupCache);
hook.Add("EntityRemoved",   "POWERSUIT.RemoveFromEntityLookupCache", function(ent)

	-- Delete entry from table to speed up rendering.
	game.MetroidPrimeMaterialSwaps[tostring(ent:EntIndex())] = nil;
	game.MetroidPrimeLogBook.Entities[tostring(ent:EntIndex())] = nil;
end);

hook.Add("SetupMove", "POWERSUIT.BuildEntityLookupCache", function(ply)

	-- Lookup cache is built only once to avoid overhead, eg, joining a server.
	if (ply.__mp_LookupCacheReady) then return; end
	for k,v in pairs(ents.GetAll()) do
		AddEntityToLookupCache(v);
	end

	ply.__mp_LookupCacheReady = true;
end);