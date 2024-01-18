
hook.Add("PlayerPostThink", "POWERSUIT.ClampHealth", function(ply)

	local isPowerSuit, weapon = ply:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Clamp player health to prevent going over energy tank capacity.
	local maxHealth = weapon.Helmet:GetMaxEnergy() * 100 + 99;
	if (ply:Armor() > 0)                 then ply:SetArmor(0);             end
	if (ply:Health() > maxHealth)        then ply:SetHealth(maxHealth);    end
	if (ply:GetMaxHealth() != maxHealth) then ply:SetMaxHealth(maxHealth); end
end);

hook.Add("GetFallDamage", "POWERSUIT.GetFallDamage", function(ply, damage)
	if (ply:UsingPowerSuit()) then return 0; end
end);

hook.Add("EntityTakeDamage", "POWERSUIT.GiveDamage", function(ent, damage)

	if (!IsValid(ent)) then return; end

	local attacker = damage:GetAttacker();
	if (!IsValid(attacker) || !attacker:IsPlayer()) then return; end

	-- Scale damage according to game multipler.
	if (!attacker:UsingPowerSuit()) then return; end
	damage:ScaleDamage(GetConVar("mp_cheats_damagegivenscale"):GetInt());
end);

hook.Add("EntityTakeDamage", "POWERSUIT.TakeDamage", function(ent, damage)

	if (!IsValid(ent) || !ent:IsPlayer()) then return; end

	local isPowerSuit, weapon = ent:UsingPowerSuit();
	if (!isPowerSuit) then return; end

	-- Scale damage according to current suit and game multiplier.
	damage:ScaleDamage(weapon:GetSuit().DamageScale);
	damage:ScaleDamage(GetConVar("mp_cheats_damagetakenscale"):GetInt());
end);