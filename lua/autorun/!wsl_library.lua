
WSL = WSL || {};

function WSL.IterateSounds(ent, container, lambda)

	local _container = container || ent;

	-- Box sounds for entities since we can't parse userdata.
	for k,v in pairs(container || { ["Sounds"] = ent.Sounds }) do

		-- Recurse all subtables for sounds.
		if (istable(v)) then WSL.IterateSounds(ent, v, lambda); end
		if (k != "Sounds") then continue; end

		-- Initialize sound cache.
		_container.SoundsCache = _container.SoundsCache || {};
		for name,snd in pairs(v) do
			if (name == "BaseClass") then continue; end
			lambda(_container.SoundsCache, name, snd); 
		end
	end
end

function WSL.InitializeSounds(ent, container)

	-- Initialize all sounds on the supplied entity.
	WSL.IterateSounds(ent, container, function(cache, name, snd)
		cache[name] = CreateSound(ent, snd);
	end);
end

function WSL.PlaySoundPatch(container, name, volume, fade)

	local soundPatch = container.SoundsCache[name];
	if (soundPatch == nil) then return; end

	-- Reset.
	soundPatch:Stop();
	soundPatch:Play();
	soundPatch:ChangeVolume(volume || 1);

	-- Handle fade in.
	if (fade == nil) then return; end
	soundPatch:ChangeVolume(0);
	soundPatch:ChangeVolume(volume || 1, fade);
end

function WSL.PlaySound(container, name, volume, fade, noPrediction)

	-- Prediction support.
	if (!SERVER || !IsFirstTimePredicted()) then return; end
	WSL.PlaySoundPatch(container, name, volume, fade);
end

function WSL.StopSound(container, name, fade)

	local soundPatch = container.SoundsCache[name];
	if (!soundPatch) then return; end

	if (fade != nil) then soundPatch:FadeOut(fade);
	else soundPatch:Stop(); end
end

function WSL.CleanupSounds(ent, container)

	-- Stop all sounds now to cleanup stray loops.
	WSL.IterateSounds(ent, container, function(cache, name, snd)
		if (cache[name]) then cache[name]:Stop(); end
	end);
end