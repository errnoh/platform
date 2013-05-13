
local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic         = true
object.bRunBehaviors    = true
object.bUpdates         = true
object.bUseShop         = true

object.bRunCommands     = true 
object.bMoveCommands     = true
object.bAttackCommands     = true
object.bAbilityCommands = true
object.bOtherCommands     = true

object.bReportBehavior = false
object.bDebugUtility = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core         = {}
object.eventsLib     = {}
object.metadata     = {}
object.behaviorLib     = {}
object.skills         = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"
runfile "bots/teams/anakonda/illusions.lua"
runfile "bots/teams/anakonda/deny.lua"
runfile "bots/teams/anakonda/steamboots.lua"
runfile "bots/teams/anakonda/jungleLib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(' loading krixi')

--bot "global" vars
--To keep track status of 2nd skill
object.bouncing = true
object.alive = true

--To keep track day/night cycle
object.isDay = true

--Constants
object.heroName = 'Hero_Krixi'
behaviorLib.diveThreshold = 90

-- skillbuild table, 0=beam, 1=bounce, 2=aura, 3=ult, 4=attri
object.tSkills = {
    2, 0, 0, 1, 0,
    3, 0, 2, 2, 1, 
    3, 2, 1, 1, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

--   item buy order.
behaviorLib.StartingItems  = {"2 Item_DuckBoots", "2 Item_MinorTotem", "Item_HealthPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_HelmOfTheVictim", "Item_Steamboots"}
behaviorLib.MidItems  = {"Item_Sicarius", "Item_Immunity","Item_ManaBurn2"}
behaviorLib.LateItems  = {"Item_WhisperingHelm", "Item_LifeSteal4", "Item_Evasion"}

------------------------------
--     skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
	core.VerboseLog("skillbuild()")

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
	local unitSelf = self.core.unitSelf
	if skills.moonbeam == nil then
		skills.moonbeam = unitSelf:GetAbility(0)
		skills.bounce = unitSelf:GetAbility(1)
		skills.aura = unitSelf:GetAbility(2)
		skills.ult = unitSelf:GetAbility(3)
		skills.abilAttributeBoost = unitSelf:GetAbility(4)
	end
	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end

	local nlev = unitSelf:GetLevel()
	local nlevpts = unitSelf:GetAbilityPointsAvailable()
	for i = nlev, nlev+nlevpts do
		unitSelf:GetAbility( object.tSkills[i] ):LevelUp()

		--initialy set aura and bounce to heroes only
		if nlev == 1 then
			object.toggleAura(self, false)
		end
		if nlev == 2 then
			object.toggleBounce(self, false)
		end
	end
end

---------------------------
-- Find geo and shrunken --
---------------------------
local function funcFindItemsOverride(botBrain)
	object.FindItemsOld(botBrain)
	if core.itemGeometer ~= nil and not core.itemGeometer:IsValid() then
		core.itemGeometer = nil
	end
	if core.itemShrunkenHead ~= nil and not core.itemShrunkenHead:IsValid() then
		core.itemShrunkenHead = nil
	end
	if core.itemSymbolofRage ~= nil and not core.itemSymbolofRage:IsValid() then
		core.itemSymbolofRage = nil
	end
	if core.itemWhisperingHelm ~= nil and not core.itemWhisperingHelm:IsValid() then
		core.itemWhisperingHelm = nil
	end

	local inventory = core.unitSelf:GetInventory(true)
	for slot = 1, 6, 1 do
		local curItem = inventory[slot]
		if curItem ~= nil then
			if core.itemGeometer == nil and not curItem:IsRecipe() and curItem:GetName() == "Item_ManaBurn2" then
				core.itemGeometer = core.WrapInTable(curItem)
			elseif core.itemShrunkenHead == nil and not curItem:IsRecipe() and curItem:GetName() == "Item_Immunity" then
				core.itemShrunkenHead = core.WrapInTable(curItem)
			elseif core.itemSymbolofRage == nil and curItem:GetName() == "Item_LifeSteal4" then
				core.itemSymbolofRage = core.WrapInTable(curItem)
			elseif core.itemWhisperingHelm == nil and curItem:GetName() == "Item_WhisperingHelm" then
				core.itemWhisperingHelm = core.WrapInTable(curItem)
			end
		end
	end
end

object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

---------------------------
--    onthink override   --
-- Called every bot tick --
---------------------------
function object:onthinkOverride(tGameVariables)
	self:onthinkOld(tGameVariables)-- old think
	local heroPos = core.unitSelf:GetPosition()
	if (core.unitSelf:IsAlive() and core.localUnits~=nil)then
		if not object.alive then
			--To keep track status of 2nd skill
			object.alive = true
			object.bouncing = true
			object.toggleBounce(self, false)
		end

		-- Keep illus near
		for _, illu in pairs(object.IlluLib.myIllusions()) do
			if Vector3.Distance2DSq(illu:GetPosition(), heroPos) > 400*400 then
				core.OrderMoveToPos(self, illu, heroPos, false)
			end
		end
	end

	if not core.unitSelf:IsAlive() then
		--To keep track status of 2nd skill
		object.alive = false
	end

	--keep track of day/night only to say something stupid in all chat
	local time = HoN.GetMatchTime() --This is time since the 0:00 mark (nil if before)

	if time ~= 0 then
		local day = math.floor(HoN.GetMatchTime()/(7.5*60*1000)) % 2
		--BotEcho(day)

		if day == 0 and not object.isDay then
			--Good morning
			object.isDay = true
		elseif day == 1 and object.isDay then
			--gnight
			object.isDay = false
			if math.random(5) == 1 then --math.random(upper) generates integer numbers between 1 and upper.
				local randomMessageId = math.random(#core.nightMessages)
				core.AllChat(core.nightMessages[randomMessageId])
			end
		end
	end

	--track jungle
	self.jungleLib.assess(self)

	--track jungle minions
	if core.tControllableUnits ~= nil then
		for _,unit in pairs(core.tControllableUnits["AllUnits"]) do
			if not table.contains(core.tControllableUnits["InventoryUnits"], unit) then
				if core.unitSelf:IsAlive() then
					if Vector3.Distance2DSq(unit:GetPosition(), heroPos) > 700*700 then
						core.OrderFollow(self, unit, core.unitSelf, false)
					end
				else
					core.OrderMoveToPos(core.allyWell:GetPosition())
				end
			end
		end
	end
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride


local function PushExecuteOverride(botBrain)
	object.toggleBounce(botBrain, true)
	object.toggleAura(botBrain, true)
	object.PushExecuteOld(botBrain)
	object.SteamBootsLib.setAttributeBonus("agi")
end
object.PushExecuteOld = behaviorLib.PushBehavior["Execute"]
behaviorLib.PushBehavior["Execute"] = PushExecuteOverride

function behaviorLib.newPositionSelfExecute(botBrain)
	object.toggleBounce(botBrain, false)
	object.toggleAura(botBrain, false)
	behaviorLib.oldPositionSelfExecute(botBrain)
end
behaviorLib.oldPositionSelfExecute = behaviorLib.PositionSelfBehavior["Execute"]
behaviorLib.PositionSelfBehavior["Execute"] = behaviorLib.newPositionSelfExecute

----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
object.geometerUseBonus = 15
object.ultUseBonus = 65
object.beamUseBonus = 5
object.SymbolofRageUseBonus = 40
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local addBonus = 0
	
	if EventData.Type == "Ability" then
		--BotEcho("ABILILTY EVENT!  InflictorName: "..EventData.InflictorName)		
		if EventData.InflictorName == "Ability_Krixi1" then
			addBonus = addBonus + object.beamUseBonus
		elseif EventData.InflictorName == "Ability_Krixi4" then
			addBonus = addBonus + object.ultUseBonus
		end
	elseif EventData.Type == "Item" then
		if core.itemGeometer ~= nil and EventData.InflictorName == core.itemGeometer:GetName() then
			addBonus = addBonus + object.geometerUseBonus
		elseif EventData.InflictorName == "Item_LifeSteal4" then
			addBonus = addBonus + object.SymbolofRageUseBonus
		end
	end
	
	if addBonus > 0 then
		--decay before we add
		core.DecayBonus(self)
	
		core.nHarassBonus = core.nHarassBonus + addBonus
	end
end
object.oncombateventOld = object.oncombatevent
object.oncombatevent 	= object.oncombateventOverride

function behaviorLib.RetreatFromThreatExecuteOverride(botBrain)
	bActionTaken = false
	if core.NumberElements(core.localUnits["EnemyHeroes"]) > 0 then
		if core.itemGeometer and core.itemGeometer:CanActivate() then
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, core.itemGeometer, false, false)
		end
	end

	if not bActionTaken then
		behaviorLib.RetreatFromThreatExecuteOld(botBrain)
	end
	object.SteamBootsLib.setAttributeBonus("str")
end
behaviorLib.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = behaviorLib.RetreatFromThreatExecuteOverride

------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number

object.moonbeamUpBonus = 5
object.ultUpBonus = 20
object.geometerUpBonus = 5
local function CustomHarassUtilityFnOverride(hero)
	local val = 0
	
	if skills.moonbeam:CanActivate() then
		val = val + object.moonbeamUpBonus
	end
	
	if skills.ult:CanActivate() then
		val = val + object.ultUpBonus
	end

	if core.itemGeometer ~= nil then
		if core.itemGeometer:CanActivate() then
			val = val + object.geometerUpBonus
		end
	end
	val = val + (core.unitSelf:GetManaPercent() - 0.5) * 30
	return val

end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   

--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
-- @param botBrain: CBotBrain
-- @return: none
--
object.geometerUseThreshold = 55
object.moonbeamThreshold = 35
object.ultTheresholds = {95, 80, 65}
local function HarassHeroExecuteOverride(botBrain)
	object.SteamBootsLib.setAttributeBonus("agi")
	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return false --Target is invalid, move on to the next behavior
	end

	if not core.CanSeeUnit(botBrain, unitTarget) then
		return object.harassExecuteOld(botBrain)
	end

	--some vars
	local unitSelf = core.unitSelf
	local vecMyPosition = unitSelf:GetPosition()
	local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
	local nMyExtraRange = core.GetExtraRange(unitSelf)

	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)

	local nLastHarassUtility = behaviorLib.lastHarassUtil
	local bCanSee = core.CanSeeUnit(botBrain, unitTarget)

	local bActionTaken = false

	----------------------------------------------------------------------------
	local ultcd = skills.ult:GetActualRemainingCooldownTime()/1000

	local saveManaBonus = 0
	if unitSelf:GetManaPercent() > 0.5 then
		saveManaBonus = 100
	else
		if ultcd > 100 then
			saveManaBonus = 100
		else
			saveManaBonus = ultcd
		end
	end

	if not bActionTaken then
		if skills.moonbeam:CanActivate() and nLastHarassUtility + saveManaBonus > object.moonbeamThreshold + 100 then
			bActionTaken = core.OrderAbilityEntity(botBrain, skills.moonbeam, unitTarget)
		end
	end

	if not bActionTaken then
		if nLastHarassUtility > object.geometerUseThreshold and core.itemGeometer and core.itemGeometer:CanActivate() then
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, core.itemGeometer, false, false)
		end
	end

	if not bActionTaken then
		--at higher levels this overpowers ult behavior with lastHarassUtil like 150
		if skills.ult:CanActivate() and nLastHarassUtility > object.ultTheresholds[skills.ult:GetLevel()] and nTargetDistanceSq < 700 * 700 then
			bActionTaken = behaviorLib.ultBehavior["Execute"](botBrain)
		end
	end

	for _, illu in pairs(object.IlluLib.myIllusions()) do
		core.OrderAttack(botBrain, illu, unitTarget)
	end

	-- for minotaur in minotaurs
	for _,unit in pairs(core.tControllableUnits["AllUnits"]) do
		if not table.contains(core.tControllableUnits["InventoryUnits"], unit) then
			if unit:GetTypeName() == "Neutral_Minotaur" then
				core.AllChat("minotaur i choose you")
				stun = unit:GetAbility(0)
				if stun:CanActivate() and Vector3.Distance2DSq(vecTargetPosition, unit:GetPosition()) < 250 * 250 then
					core.OrderAbility(botBrain, stun, true, false)
				else
					core.OrderAttack(botBrain, unit, unitTarget)
				end
			end
		end
	end

	if not bActionTaken then
		if core.itemSymbolofRage and core.itemSymbolofRage:CanActivate() and unitSelf:GetHealthPercent() < 0.6 then
			botBrain:OrderItem(core.itemSymbolofRage.object)
		end
		return object.harassExecuteOld(botBrain)
	end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--to use it when there are good change and harashero is too afraid
function behaviorLib.UltimateUtility(botBrain)

	if not skills.ult:CanActivate() then
		return 0
	end

	local selfPos = core.unitSelf:GetPosition()

	--range of ult is 700, check 800 cause we are going to move during ult
	--check heroes in range 600, they try to run
	local unitlist = HoN.GetUnitsInRadius(selfPos, 800, core.UNIT_MASK_UNIT + core.UNIT_MASK_HERO + core.UNIT_MASK_ALIVE)
	local localUnits = {}
	core.SortUnitsAndBuildings(unitlist, localUnits, true)

	local enemyheroes = {}

	for _, hero in pairs(localUnits["enemyHeroes"]) do
		if Vector3.Distance2DSq(selfPos, hero:GetPosition()) < 600*600 then
			tinsert(enemyheroes, hero)
		end
	end

	if core.NumberElements(enemyheroes) == 0 then
		return 0
	end

	local utilityvalue = 0
	if core.NumberElements(localUnits["tEnemyUnits"]) <= skills.ult:GetLevel() + 1 then
		utilityvalue = utilityvalue + 30
	end
	if core.NumberElements(localUnits["tEnemyUnits"]) == core.NumberElements(enemyheroes) then
		utilityvalue = utilityvalue + 40
	elseif core.NumberElements(localUnits["tEnemyUnits"]) < core.NumberElements(enemyheroes) *2 then
		utilityvalue = utilityvalue + 20
	end
	return utilityvalue * core.unitSelf:GetHealthPercent()
end

--press R to kill
function behaviorLib.UltimateExecute(botBrain)
	bActionTaken = core.OrderAbility(botBrain, skills.ult)

	if core.itemShrunkenHead and bActionTaken then
		botBrain:OrderItem(core.itemShrunkenHead.object, false)
	end
	return bActionTaken
end

behaviorLib.ultBehavior = {}
behaviorLib.ultBehavior["Utility"] = behaviorLib.UltimateUtility
behaviorLib.ultBehavior["Execute"] = behaviorLib.UltimateExecute
behaviorLib.ultBehavior["Name"] = "mq Ultimate"
tinsert(behaviorLib.tBehaviors, behaviorLib.ultBehavior)

--Behavior to break channels
behaviorLib.enemyToStun = nil
function behaviorLib.stunUtility(botBrain)
	if not skills.moonbeam:CanActivate() then
		return 0
	end

	for _,enemy in pairs(core.localUnits["EnemyHeroes"]) do
		if enemy:IsChanneling() or enemy:HasState("State_ManaPotion") or enemy:HasState("State_HealthPotion") then
			behaviorLib.enemyToStun = enemy
			return 75
		end
	end
	return 0
end

function behaviorLib.stunExecute(botBrain)
	return core.OrderAbilityEntity(botBrain, skills.moonbeam, behaviorLib.enemyToStun)
end

behaviorLib.stunBehavior = {}
behaviorLib.stunBehavior["Utility"] = behaviorLib.stunUtility
behaviorLib.stunBehavior["Execute"] = behaviorLib.stunExecute
behaviorLib.stunBehavior["Name"] = "stun"
tinsert(behaviorLib.tBehaviors, behaviorLib.stunBehavior)

function behaviorLib.dominationUtility(botBrain)
	if not core.itemWhisperingHelm or not core.itemWhisperingHelm:CanActivate() and core.NumberElements(core.localUnits["neutrals"]) == 0 then
		return 0
	end
	if core.NumberElements(core.localUnits["neutrals"]) ~= 0 then
		return 35
	end
	--push 22 defend 23
	return 22
end

function behaviorLib.dominationExecute(botBrain)
	local unitSelf = core.unitSelf
	local myPos=unitSelf:GetPosition()
	local campPos, campid = object.jungleLib.getNearestCampPos(myPos,0,110)
	if not campid or not campPos then
		return false
	end
	local camp = object.jungleLib.jungleSpots[campid]
	if not camp then
		return false
	end

	if Vector3.Distance2DSq(campPos, myPos) > 1000 * 1000 then
		core.OrderMoveToPos(botBrain, core.unitSelf, campPos)
	else
		local uUnits=HoN.GetUnitsInRadius(myPos, 600, core.UNIT_MASK_ALIVE + core.UNIT_MASK_UNIT)
		if core.itemWhisperingHelm and core.itemWhisperingHelm:CanActivate() then
			for _, unit in pairs(uUnits) do

				if unit:GetTypeName() == "Neutral_Minotaur" and unit:GetTeam() ~= core.myTeam and unit:GetTeam() ~= core.enemyTeam then
					core.AllChat("minotaur")
					botBrain:OrderItemEntity(core.itemWhisperingHelm.object or core.itemWhisperingHelm, unit.object or unit)
					return true
				end
			end
		end

		if core.NumberElements(uUnits)~=0 and core.NumberElements(core.localUnits["neutrals"])~=0 then
			local nHighestHealth=0
			local highestUnit=nil
			--creep with highest hp
			for _,unit in pairs(uUnits) do
				if unit:GetHealth()>nHighestHealth then
					highestUnit=unit
					nHighestHealth=unit:GetHealth()
				end
			end
			if highestUnit then

				local dist=Vector3.Distance2DSq(myPos, highestUnit:GetPosition())
				if dist < 350*350 then
					botBrain:OrderEntity(unitSelf.object, "Attack", highestUnit.object, "None")
				end
			else
							
				object.toggleBounce(botBrain, true)
				return core.OrderAttackPosition(botBrain, unitSelf, campPos,false,false)--attackmove
			end
		else

			object.toggleBounce(botBrain, true)
			return core.OrderAttackPosition(botBrain, unitSelf, campPos,false,false)--attackmove
		end
	end
end

behaviorLib.dominationBehavior = {}
behaviorLib.dominationBehavior["Utility"] = behaviorLib.dominationUtility
behaviorLib.dominationBehavior["Execute"] = behaviorLib.dominationExecute
behaviorLib.dominationBehavior["Name"] = "whispering helm domination"
tinsert(behaviorLib.tBehaviors, behaviorLib.dominationBehavior)

--Attack to pets
behaviorLib.minionToAttack = nil
behaviorLib.extraAttackMinionsRange = 75
function behaviorLib.attackEnemyMinionsUtility(botBrain)
	local enemies = core.localUnits["Enemies"]
	local weakestMinion = nil
	local minionhp = 99999999

	utility = 0
	for _, unit in pairs(enemies) do
		if not unit:IsInvulnerable() and not unit:IsHero() and unit:GetOwnerPlayer() ~= nil then
			local distance = Vector3.Distance2DSq(core.unitSelf:GetPosition(), unit:GetPosition())
			if core.GetAbsoluteAttackRangeToUnit(core.unitSelf, unit, true) + behaviorLib.extraAttackMinionsRange >= distance then
				local hp = unit:GetHealth()
				if hp < minionhp then
					weakestMinion = unit
					minionhp = hp
				end
			end
		end
	end
	if weakestMinion ~= nil then
		behaviorLib.minionToAttack = weakestMinion
		if weakestMinion:GetHealth() <= core.unitSelf:GetAttackDamageMin() * (1 - weakestMinion:GetPhysicalResistance()) then
			utility = 25
		else
			--PositionSelf 20 and AttackCreeps 21
			utility = 20.5
		end
	end
	return utility
end

function behaviorLib.attackEnemyMinionsExecute(botBrain)
	return core.OrderAttack(botBrain, core.unitSelf, behaviorLib.minionToAttack)
end

behaviorLib.attackEnemyMinionsBehavior = {}
behaviorLib.attackEnemyMinionsBehavior["Utility"] = behaviorLib.attackEnemyMinionsUtility
behaviorLib.attackEnemyMinionsBehavior["Execute"] = behaviorLib.attackEnemyMinionsExecute
behaviorLib.attackEnemyMinionsBehavior["Name"] = "attack to enemy minions"
tinsert(behaviorLib.tBehaviors, behaviorLib.attackEnemyMinionsBehavior)

--Helppers for bounce and aura
function object.toggleAura(botBrain, state)
	if object.getAuraState() == state or skills.aura:CanActivate() then
		return false
	end
	core.OrderAbility(botBrain, skills.aura)
	return true
end


function object.toggleBounce(botBrain, state)
	if object.getBounceState() == state or not skills.bounce:CanActivate() then
		return false
	end

	core.OrderAbility(botBrain, skills.bounce)
	object.bouncing = not object.bouncing
	return true
end

--true when target is "all" false when heroes only
function object.getAuraState()
	if skills.aura:GetLevel() == 0 then
		return false
	end
	return skills.aura:GetActiveModifierKey() ~= "krixiauratoggle_heroes"
end

function object.getBounceState()
	if skills.bounce:GetLevel() == 0 then
		return false
	end
	return object.bouncing 
end

--Messages
core.tKillChatKeys={
	"Shot by the Moon.",
	"Harvest moon.",
	"Feel the power of the moon.",
	"Take one and pass it on.",
	"One to the other."
}

core.tDeathChatKeys = {
	"Carried away by a moonlight shadow.",
	"I was looking the moon beams."
}

core.tRespawnChatKeys = {
	"By the moonlight.",
	"Moonlight guide me."
}

core.nightMessages = {
	"Oh full moon tonight",
	"Blue moon rises",
	"Under the moon."
}

BotEcho('finished loading krixi')