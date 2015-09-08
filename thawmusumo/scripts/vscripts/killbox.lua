--radiant - 2
--dire    - 3

function killhero(keys)
	local activator = keys.activator
	local lvltime = {3,3,3,3,3,5,5,5,5,5,5,5,5,5,5,10,10,10,10,10,10,10,10,10,10}
	local time = lvltime[activator:GetLevel()]

	if(activator:IsHero()) then
		print("team number: " .. activator:GetTeam())
		--give points
		if(activator:IsAlive()) then
			print("unit is alive")
			if activator:GetTeam() == 2 then
				GameRules.CustomAddon.direpoints = GameRules.CustomAddon.direpoints + 1
			elseif activator:GetTeam() == 3 then
				GameRules.CustomAddon.radpoints = GameRules.CustomAddon.radpoints + 1
			end
			GameRules:SendCustomMessage("<font color='#336600'>Radiant: </font>" .. GameRules.CustomAddon.radpoints, 0, 0)
			GameRules:SendCustomMessage("<font color='#FF0000'>Dire:    </font>" .. GameRules.CustomAddon.direpoints, 0, 0)
		end
		--kill unit based on owner of the killer debuff
		if(activator:HasModifier("killer_debuff")) then
			local mod = activator:FindModifierByName("killer_debuff")
			local owner = mod:GetCaster();

			local damageTable =
			{
				victim = activator,
				attacker = owner,
				damage = activator:GetMaxHealth(),
				damage_type = DAMAGE_TYPE_PURE
			}

			ApplyDamage(damageTable)
			if activator:IsAlive() == false then
				activator:SetTimeUntilRespawn(time)
			end
		else --suicide
			local damageTable =
			{
				victim = activator,
				attacker = activator,
				damage = activator:GetMaxHealth(),
				damage_type = DAMAGE_TYPE_PURE
			}

			ApplyDamage(damageTable)
			if activator:IsAlive() == false then
				activator:SetTimeUntilRespawn(time)
			end
		end
	end
end
