local _G = getfenv(0)
local object = _G.object

object.behaviorLib = object.behaviorLib or {}
local core, eventsLib, behaviorLib, metadata = object.core, object.eventsLib, object.behaviorLib, object.metadata

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

object.IlluLib = object.IlluLib or {}
IlluLib = object.IlluLib


--override old functions
function object.core.newSortUnitsAndBuildings(tUnitList, tSortedUnits, bHeroesAsMemoryUnits)
	--TODO: consolidate this with the SortBuildings
	StartProfile('setup')
	tSortedUnits = tSortedUnits or {}
	
	tSortedUnits.enemyCreeps	= tSortedUnits.enemyCreeps or {}
	tSortedUnits.enemyHeroes	= tSortedUnits.enemyHeroes or {}
	tSortedUnits.tEnemyUnits	= tSortedUnits.tEnemyUnits or {}
	tSortedUnits.enemyBuildings	= tSortedUnits.enemyBuildings or {}
	tSortedUnits.enemyRax		= tSortedUnits.enemyRax or {}
	tSortedUnits.enemyTowers	= tSortedUnits.enemyTowers or {}
	tSortedUnits.enemies		= tSortedUnits.enemies or {}
	
	tSortedUnits.allyCreeps		= tSortedUnits.allyCreeps or {}
	tSortedUnits.allyHeroes		= tSortedUnits.allyHeroes or {}
	tSortedUnits.allyIllusions  = tSortedUnits.allyIllusions or {}
	tSortedUnits.allyUnits		= tSortedUnits.allyUnits or {}
	tSortedUnits.allyBuildings	= tSortedUnits.allyBuildings or {}
	tSortedUnits.allyRax		= tSortedUnits.allyRax or {}
	tSortedUnits.allyTowers		= tSortedUnits.allyTowers or {}
	tSortedUnits.allies			= tSortedUnits.allies or {}
	
	local allyTeam = object.core.myTeam
	local enemyTeam = object.core.enemyTeam

	local teamBotBrain = core.teamBotBrain
	StopProfile()

	StartProfile('Loop')
	for key,curUnit in pairs(tUnitList) do
		if curUnit~= nil and curUnit ~= core.unitSelf then  
			StartProfile('Inner part')
			local id = curUnit:GetUniqueID()
			if curUnit:GetTeam() == allyTeam then
				if curUnit:IsHero() and bHeroesAsMemoryUnits then
					curUnit = teamBotBrain:CreateMemoryUnit(curUnit)
				end
				
				tSortedUnits.allies[id] = curUnit
				
				if curUnit:IsBuilding() then
					tSortedUnits.allyBuildings[id] = curUnit
					
					if curUnit:IsTower() then
						tSortedUnits.allyTowers[id] = curUnit
					elseif curUnit:IsUnitType("Well") and curUnit:GetCanAttack() then
						tSortedUnits.allyTowers[id] = curUnit
					elseif curUnit:IsRax() then
						tSortedUnits.allyRax[id] = curUnit					
					end
				else
					tSortedUnits.allyUnits[id] = curUnit
					
					if curUnit:IsHero() then
						if object.IlluLib.IsIllusion(curUnit) then
							tSortedUnits.allyIllusions[id] = curUnit
						else
							tSortedUnits.allyHeroes[id] = curUnit
						end
					elseif not core.IsCourier(curUnit) then
						tSortedUnits.allyCreeps[id] = curUnit
					end	
				end
			elseif curUnit:GetTeam() == enemyTeam then
				if curUnit:IsHero() and bHeroesAsMemoryUnits then
					curUnit = teamBotBrain:CreateMemoryUnit(curUnit)
				end
				
				tSortedUnits.enemies[id] = curUnit
				
				if curUnit:IsBuilding() then
					tSortedUnits.enemyBuildings[id] = curUnit
					
					if curUnit:IsTower() then
						tSortedUnits.enemyTowers[id] = curUnit
					elseif curUnit:IsUnitType("Well") and curUnit:GetCanAttack() then
						tSortedUnits.enemyTowers[id] = curUnit
					elseif curUnit:IsRax() then
						tSortedUnits.enemyRax[id] = curUnit					
					end
				else
					tSortedUnits.tEnemyUnits[id] = curUnit
					
					if curUnit:IsHero() then
						tSortedUnits.enemyHeroes[id] = curUnit
					else
						tSortedUnits.enemyCreeps[id] = curUnit
					end	
				end
			end
			StopProfile()
		end
	end
	StopProfile()
	return tSortedUnits
end

object.core.oldSortUnitsAndBuildings = object.core.SortUnitsAndBuildings
object.core.SortUnitsAndBuildings =object.core.newSortUnitsAndBuildings


core.tKillIlluChatKeys={
	"oops...",
	"You're using illus!", --you're using coconuts
	"You've got two empty illus, and your ordering them around.", -- You've got two empty halves of coconuts ...
	"How do you dare to use Illusions",
	"I dont use illus. You shouldn't either." --lies
}
function ProcessKillChatOverride(unitTarget, sTargetPlayerName)
	if table.contains(core.teamBotBrain.tEnemyHeroes, unitTarget) then
		core.oldProcessKillChat(unitTarget, sTargetPlayerName)
	else
		if math.random(10) == 1 then
			core.AllChat(core.tKillIlluChatKeys[math.random(#core.tKillIlluChatKeys)])
		end
	end
end

core.oldProcessKillChat = core.ProcessKillChat
core.ProcessKillChat = ProcessKillChatOverride


function newAssessLocalUnits(botBrain, vecPosition, nRadius)
	StartProfile('Assess local units')
	
--[[ some unused things by s2
	StartProfile('Setup')
		local unitSelf = core.unitSelf
		vecPosition = vecPosition or unitSelf:GetPosition()
		nRadius = nRadius or core.localCreepRange
		local nMask = core.UNIT_MASK_ALIVE + core.UNIT_MASK_UNIT + core.UNIT_MASK_HERO + core.UNIT_MASK_BUILDING
	StopProfile()
]]--
	
	StartProfile('GetUnits')
		--local tUnits,tSortedUnits = HoN.GetUnitsInRadius(vecPosition, nRadius, nMask, true, unitSelf)
		--local tUnits = botBrain:GetLocalUnits()
		local tSortedUnits = botBrain:GetLocalUnitsSorted()
	StopProfile()
	
	-- BotEcho('local creep range '..core.localCreepRange)
	-- BotEcho('units in range '..core.localCreepRange..': '..core.NumberElements(tUnits))
	-- BotEcho('myTeam '..core.myTeam..'  enemyTeam'..core.enemyTeam)
	
	tSortedUnits.allyIllusions = {}

	StartProfile('Loop')
		local teamBotBrain = core.teamBotBrain
		local tAllyHeroes = tSortedUnits.AllyHeroes
		local tAllyUnits = tSortedUnits.AllyUnits
		local tAllies = tSortedUnits.Allies
		for nUID,unitAlly in pairs(tAllyHeroes) do
			if core.teamBotBrain.tAllyHeroes[nUID] == nil then
				tSortedUnits.allyIllusions[nUID] = unitAlly
				table.remove(tSortedUnits.AllyHeroes, nUID)
			else
				tAllyHeroes[nUID] = teamBotBrain:CreateMemoryUnit(unitAlly)
				tAllyUnits[nUID] = tAllyHeroes[nUID]
			end
			tAllies[nUID] = tAllyHeroes[nUID]
		end
		local tEnemyHeroes = tSortedUnits.EnemyHeroes
		local tEnemyUnits = tSortedUnits.EnemyUnits
		local tEnemies = tSortedUnits.Enemies
		for nUID,unitEnemy in pairs(tEnemyHeroes) do
			tEnemyHeroes[nUID] = teamBotBrain:CreateMemoryUnit(unitEnemy)
			tEnemyUnits[nUID] = tEnemyHeroes[nUID]
			tEnemies[nUID] = tEnemyHeroes[nUID]
		end	
	StopProfile()
		
	StopProfile()
	return tSortedUnits
end

local oldAssessLocalUnits = core.AssessLocalUnits
core.AssessLocalUnits = newAssessLocalUnits

-- New functions
function object.IlluLib.myIllusions()
	if core.tControllableUnits ~= nil then
		local sortedUnits = {}
		core.SortUnitsAndBuildings(core.tControllableUnits["InventoryUnits"], sortedUnits, true)
		return sortedUnits["allyIllusions"]
	else
		return {}
	end
end

function object.IlluLib.IsIllusion(unit)
	if unit:GetTeam() ~= object.core.myTeam then --Dont "cheat"
		return false
	end
	return not table.contains(core.teamBotBrain.tAllyHeroes, unit)
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end
