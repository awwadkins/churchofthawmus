require('libraries/projectiles')
require('libraries/timers')
require('item_checks')

function thawmus_lift(keys)
	local caster = keys.caster
	local dist, rad = 100, 110

	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local front_target = origin + fv * dist

	local units = FindUnitsInRadius(caster:GetTeamNumber(), front_target, nil, rad, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	--units that get hit
	if #units > 0 then
		for _,unit in pairs(units) do
			--calculate the knockback
			local armor = checkForArmor(unit)

			local distance
			if keys.kbdist <= armor then
				distance = 50
			else
	        	distance = keys.kbdist - armor
	    	end

	    	local kbduration = distance / 1000
        	local height = distance / 10

			local kbTable =
			{
				should_stun = 0,
				knockback_duration = kbduration,
				duration = kbduration,
				knockback_distance = distance,
				knockback_height = height,
				center_x = caster:GetAbsOrigin().x,
				center_y = caster:GetAbsOrigin().y,
				center_z = caster:GetAbsOrigin().z
			}
			unit:AddNewModifier(caster, nil, "modifier_knockback", kbTable)
			keys.ability:ApplyDataDrivenModifier(caster, unit, "killer_debuff", {duration = kbduration + 0.5})
			EmitSoundOn("Hero_Sven.Attack.Impact", unit)
		end
	end
end

function thawmus_hammer(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin()
	local caster_vector = caster:GetForwardVector()
	local hammer =
	{
		EffectName = keys.EffectName,
		vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,30),
		fDistance = keys.proj_distance,
		fStartRadius = keys.proj_radius,
		fEndRadius = keys.proj_radius,
		Source = caster,
		vVelocity = caster_vector * keys.proj_speed,
		UnitBehavior = PROJECTILES_DESTROY,
		bMultipleHits = false,
		bIgnoreSource = true,
		TreeBehavior = PROJECTILES_NOTHING,
		bCutTrees = true,
		WallBehavior = PROJECTILES_NOTHING,
		GroundBehavior = PROJECTILES_NOTHING,
		fGroundOffset = 30, --was 30
		nChangeMax = 3,
		bRecreateOnChange = true,
		bZCheck = false,
		bGroundLock = true,
		draw = false,  --draw = {alpha=1, color=Vector(200,0,0)},

		UnitTest = function(self, unit)
			return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()
			end,

		OnUnitHit = function(self, unit)
      local target_difference = (unit:GetAbsOrigin() - origin):Length2D()
      print("targ diff: " .. target_difference)
			--calculate the knockback
			local armor = checkForArmor(unit)

			local distance
			if keys.kbdist <= armor then
				distance = 50
			else
      	distance = keys.kbdist - armor
    	end

    	local kbduration = distance / 1000
    	local height = distance / 10

      local kbTable = {}
      kbTable.should_stun = 0
      kbTable.knockback_duration = kbduration
      kbTable.duration = kbduration
      kbTable.knockback_distance = distance
      kbTable.knockback_height = height
      kbTable.center_x = self.pos.x
      kbTable.center_y = self.pos.y
      kbTable.center_z = self.pos.z

      unit:AddNewModifier(caster, nil, "modifier_knockback", kbTable)
      keys.ability:ApplyDataDrivenModifier(caster, unit, "killer_debuff", {duration = kbduration + 0.5})
      EmitSoundOn("Hero_Sven.Attack.Impact", unit)
		end,

		OnFinish = function(self, position)
			local hammer_back = self
			hammer_back.fDistance = (position - origin):Length2D()
			hammer_back.vSpawnOrigin = position
			hammer_back.vVelocity = Vector(-1,-1,0) * (caster_vector * keys.proj_speed)
			hammer_back.OnFinish = nil
			Projectiles:CreateProjectile(hammer_back)
		end,
	}

	Projectiles:CreateProjectile(hammer)
end

function thawmus_leap(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin()
	local target = keys.target_points[1]

	local speed = keys.leap_speed * 0.03
	local distance = (target - origin):Length2D()
	local direction = (target - origin):Normalized()
	local traveled = 0

	Timers:CreateTimer(0, function()
		if traveled < distance then
			origin = origin + direction * speed
			caster:SetAbsOrigin(origin)
			traveled = traveled + speed
			return 0.03
		end

		FindClearSpaceForUnit(caster, target, false)
	end)
end
