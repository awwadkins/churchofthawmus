function checkForArmor(unit)
	local armor = 0

	if unit:HasItemInInventory("item_armor_light") then
		armor = 140
	elseif unit:HasItemInInventory("item_armor_medium") then
		armor = 200
	elseif unit:HasItemInInventory("item_armor_heavy") then
		armor = 250
	end
	return armor
end
