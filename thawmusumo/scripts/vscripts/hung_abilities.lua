require('libraries/physics')
require('item_checks')

function hung_spray(keys)
  local caster = keys.caster
  local area = keys.area
  local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, area, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

  if #units > 0 then
		for _,unit in pairs(units) do
			--calculate the knockback
			local armor = checkForArmor(unit)

			local distance = keys.kbdist - armor
			if distance < 50 then
				distance = 50
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
			--apply modifiers
      unit:AddNewModifier(caster, nil, "modifier_knockback", kbTable)
			keys.ability:ApplyDataDrivenModifier(caster, unit, "killer_debuff", {duration = kbduration + 0.5})

      local modifier = unit:FindModifierByNameAndCaster("bounce_stacks", caster)

      if modifier == nil then
        keys.ability:ApplyDataDrivenModifier(caster, unit, "bounce_stacks", {duration = keys.stack_duration})
        modifier = unit:FindModifierByNameAndCaster("bounce_stacks", caster)
        modifier:IncrementStackCount()
      else
        modifier:IncrementStackCount()
        modifier:SetDuration(keys.stack_duration, true)
      end
			EmitSoundOn("Hero_Bristleback.ViscousGoo.Target", unit)
		end
	end
  --apply bounce stacks to self
  local self_modifier = caster:FindModifierByNameAndCaster("bounce_stacks", caster)

  if self_modifier == nil then
    keys.ability:ApplyDataDrivenModifier(caster, caster, "bounce_stacks", {duration = keys.stack_duration})
    modifier = caster:FindModifierByNameAndCaster("bounce_stacks", caster)
    modifier:IncrementStackCount()
  else
    modifier:IncrementStackCount()
    modifier:SetDuration(keys.stack_duration, true)
  end

end

function stack_destroyed(keys)
	local target = keys.target
  local caster = keys.caster
	local modifier = target:FindModifierByNameAndCaster("bounce_stacks", caster)
	if modifier ~= nil then
		if modifier:GetStackCount() > 1 then
			modifier:DecrementStackCount()
		elseif modifier:GetStackCount() == 1 then
			modifier:Destroy()
		end
	end
end

function hung_goo_bounce(keys)
  local caster = keys.caster
  local area = keys.target_radius
  local target = keys.target_points[1]
  local stack_dist = keys.stack_dist

  local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, area, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

  if #units > 0 then
		for _,unit in pairs(units) do
      local armor = checkForArmor(unit)
      local modifier = unit:FindModifierByNameAndCaster("bounce_stacks", caster)

      --set the unit as a physics unit
      if modifier ~= nil then
        if IsPhysicsUnit(unit) ~= true then
          Physics:Unit(unit)
          unit:SetGroundBehavior(PHYSICS_GROUND_LOCK)
          unit:FollowNavMesh(false)
          unit:PreventDI()
        end
        local direction = (target - unit:GetAbsOrigin()):Normalized()
        local stack_multiplier = unit:GetModifierStackCount("bounce_stacks", caster)

        --must be minimum distance w/ armor
        local distance = (stack_dist * stack_multiplier) - armor
        if distance < 50 then
          distance = 50
        end

        --push the unit
        unit:SetPhysicsVelocity(direction * distance)
        --remove stacks
        modifier:Destroy()
        --apply killer debuff on frames pushing unit
        unit:OnPhysicsFrame(function()
          if unit ~= caster then
            keys.ability:ApplyDataDrivenModifier(caster, unit, "killer_debuff", {duration = 0.5})
          end
        end)
      end
    end
  end
end
