-- Generated from template
if thawmus_arena == nil then
	thawmus_arena = class({})
end

function Precache( context )
	--[[
	Precache things we know we'll use.  Possible file types include (but not limited to):
		PrecacheResource( "model", "*.vmdl", context )
		PrecacheResource( "soundfile", "*.vsndevts", context )
		PrecacheResource( "particle", "*.vpcf", context )
		PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	print("PRECACHE")
	PrecacheItemByNameSync("item_light_armor", context)
	PrecacheItemByNameSync("item_medium_armor", context)
	PrecacheItemByNameSync("item_heavy_armor", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)
	PrecacheUnitByNameSync("npc_dota_hero_techies", context)
	PrecacheUnitByNameSync("npc_dota_hero_nyx_assassin", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.CustomAddon = thawmus_arena()
	GameRules.CustomAddon:InitGameMode()
end

function thawmus_arena:InitGameMode()
	self.pointsLimit = 0
	self.direpoints = 0
	self.radpoints = 0
	print("GAME LOADED")
	GameRules:SetSameHeroSelectionEnabled(true)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(thawmus_arena, "entityKilled"), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(thawmus_arena, "gameStateChange"), self)
	--GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)
end

--[[Evaluate the state of the game
function thawmus_arena:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
]]

function thawmus_arena:gameStateChange()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local pCount = PlayerResource:GetPlayerCount()

		print("no of players: " .. pCount)
		--calculate score amount
		if pCount > 0 and pCount <= 3 then
			pointsLimit = 10
		elseif pCount >= 4 and pCount <= 5 then
			pointsLimit = 15
		elseif pCount >= 6 and pCount <=7 then
			pointsLimit = 20
		elseif pCount >=8 and pCount <= 9 then
			pointsLimit = 25
		else
			pointsLimit = 30
		end
		print("pointslimit: " .. pointsLimit)
		GameRules:SendCustomMessage("<font color='#58ACFA'>First team to </font>" ..
									pointsLimit .. "<font color='#58ACFA'> kills wins!</font>", 0, 0)
	end
end

function thawmus_arena:entityKilled()
	local limit = pointsLimit
	if GameRules.CustomAddon.radpoints == limit then
		print("radiant win")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	elseif GameRules.CustomAddon.direpoints == limit then
		print("dire win")
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	else
		GameRules:SendCustomMessage("<font color='#58ACFA'>First team to </font>" ..
									limit .. "<font color='#58ACFA'> kills wins!</font>", 0, 0)
	end
end
