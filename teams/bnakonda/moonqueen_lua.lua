
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
runfile "bots/teams/bnakonda/deny.lua"
runfile "bots/teams/bnakonda/steamboots.lua"
runfile 'bots/lib/rune_controlling/init.lua'

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho('Loading BQueen')

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

behaviorLib.MidVsMeleeItems = {"Item_Ringmail", "Item_PlatedGreaves", "Item_Platemail", "Item_HungrySpirit"}
behaviorLib.LateVsMeleeItems = {"Item_FrostfieldPlate", "Item_LifeSteal5", "Item_LifeSteal4"}
-- LifeSteal5 == Abyssal Skull, LifeSteal4 == Symbol of Rage
behaviorLib.MidVsCasterItems = {"Item_MysticVestments", "Item_TrinketOfRestoration", "Item_MagicArmor2", "Item_Steamboots" }
behaviorLib.LateVsCasterItems = {"Item_BarrierIdol", "Item_Immunity","Item_ManaBurn1"}
-- MagicArmor2 == Shamans Headdress, ManaBurn1 == Nullfire Blade
behaviorLib.StartingItems = { "Item_Bottle", "Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_TrinketOfRestoration" }
behaviorLib.LaneItems = { "Item_Marchers"}
behaviorLib.MidItems = {}
behaviorLib.LateItems = {}

function core:BotBrainCoreInitializeOverride(tGameVariables)
  core:BotBrainCoreInitializeOld(tGameVariables)
  local tHeroes = HoN.GetHeroes(core.enemyTeam)
  for _, unitHero in pairs(tHeroes) do
    if unitHero:GetTypeName() == "Hero_Rampage" then
      Echo("Against rampage, yikes.")
      behaviorLib.MidItems = behaviorLib.MidVsMeleeItems
      behaviorLib.LateItems = behaviorLib.LateVsMeleeItems
      return
    end
  end
  Echo("Against something else")
  behaviorLib.MidItems = behaviorLib.MidVsCasterItems
  behaviorLib.LateItems = behaviorLib.LateVsCasterItems
end
core.BotBrainCoreInitializeOld = core.BotBrainCoreInitialize
core.BotBrainCoreInitialize = core.BotBrainCoreInitializeOverride

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

    if core.itemBottle ~= nil and not core.itemBottle:IsValid() then
        core.itemBottle = nil
    end
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
			elseif core.itemBottle == nil and curItem:GetName() == "Item_Bottle" then
                core.itemBottle = core.WrapInTable(curItem)
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
	end

	if not core.unitSelf:IsAlive() then
		--To keep track status of 2nd skill
		object.alive = false
	end

	if core.tControllableUnits ~= nil then
		for _,unit in pairs(core.tControllableUnits["InventoryUnits"]) do
			if core.IsCourier(unit) then
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
	if core.unitSelf:GetHealthPercent() > 0.8 and core.unitSelf:GetManaPercent() > 0.8 then
		val = val*2
	end
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

	    -- Illusions
    funcIllusionLogic(botBrain, unitTarget)
 
    -- Bottle
    if not bActionTaken then
        core.FindItems()
        local itemBottle = core.itemBottle
        if itemBottle then
            -- Use if the bot has an offensive rune bottled
            if useBottlePowerup(itemBottle, nTargetDistanceSq) then
                bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBottle)
            elseif getBottleCharges(itemBottle) > 0 and not unitSelf:HasState("State_Bottle") then
                -- Use if we need mana and it is safe to drink
                local nCurTimeMS = HoN.GetGameTime()
                if unitSelf:GetManaPercent() < .2 and (not (eventsLib.recentDotTime > nCurTimeMS) or not (#eventsLib.incomingProjectiles["all"] > 0)) then
                    bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBottle)
                end
            end
        end
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


local function funcIllusionLogic(botBrain, unitTarget)
    local playerSelf = core.unitSelf:GetOwnerPlayer()
    local tAllyHeroes = HoN.GetHeroes(core.myTeam)
    local tIllusions = {}
    for nUID, unitHero in pairs(tAllyHeroes) do
        if core.teamBotBrain.tAllyHeroes[nUID] == nil then
            if unitHero:GetOwnerPlayer() == playerSelf then
                tinsert(tIllusions, unitHero)
            end
        end
    end
 
    if #tIllusions > 0 then
        for _, unitIllusion in pairs(tIllusions) do
            core.OrderAttack(botBrain, unitIllusion, unitTarget)
        end
    end
    return
end
 

------------------------------------
--          Bottle Logic          --
------------------------------------
 
 
-- Returns whether or not to use the powerup
local function useBottlePowerup(itemBottle, nDistanceTargetSq)
    local sPowerup = itemBottle:GetActiveModifierKey()
 
 
    if sPowerup == "bottle_damage" then
        return true
    elseif sPowerup == "bottle_illusion" then
        return true
    elseif sPowerup == "bottle_movespeed" then
        return true
    elseif sPowerup == "bottle_regen" then
        return false
    elseif sPowerup == "bottle_stealth" then
        if nDistanceTargetSq > (700 * 700) then
            return true
        end
    end
     
    return false
end
 
 
-- Returns the number of charges in the bottle
local function getBottleCharges(itemBottle)
    local sModifierKey = itemBottle:GetActiveModifierKey()
 
 
    if sModifierKey == "bottle_empty" then
        return 0
    elseif sModifierKey == "bottle_1" then
        return 1
    elseif sModifierKey == "bottle_2" then
        return 2
    elseif sModifierKey == "" then
        return 3
    -- Bottle has a rune in it
    else
        return 4
    end
end
 
 
----------------------------------------------
--          UseHealthRegen Overide          --
----------------------------------------------
 
 
behaviorLib.nBottleUtility = 0
 
 
-- Modify UseHealthRegen to work with Bottle
local function UseHealthRegenUtilityOveride(botBrain)
    core.FindItems()
    local itemBottle = core.itemBottle
    if itemBottle then
        if getBottleCharges(itemBottle) > 0 then
            local unitSelf = core.unitSelf
            local nHealthMissing = unitSelf:GetMaxHealth() - unitSelf:GetHealth()
         
            local nHealAmount = 135
            local nUtilityThreshold = 20
             
            local vecPoint = Vector3.Create(nHealAmount, nUtilityThreshold)
            local vecOrigin = Vector3.Create(100, -15)
            behaviorLib.nBottleUtility = core.ATanFn(nHealthMissing, vecPoint, vecOrigin, 100)
        else
            behaviorLib.nBottleUtility = 0
        end
    end
     
    nUtility = object.UseHealthRegenUtilityOld(botBrain)
     
    nUtility = max(behaviorLib.nBottleUtility, nUtility)
    nUtility = Clamp(nUtility, 0, 100)
     
    return nUtility
end
 
 local function UseHealthRegenExecuteOveride(botBrain)
    local bActionTaken = false
    local unitSelf = core.unitSelf
    local vecSelfPos = unitSelf:GetPosition()
 
 
    if unitSelf:HasState("State_Bottle") or unitSelf:HasState("State_PowerupRegen") or unitSelf:HasState("State_Fade_Ability4_Stealth") then
        bActionTaken = true
    end
     
    if not bActionTaken then
        if behaviorLib.nBottleUtility > behaviorLib.nBlightsUtility and behaviorLib.nBottleUtility > behaviorLib.nHealthPotUtility then
            core.FindItems()
            local itemBottle = core.itemBottle
            if itemBottle then
                if getBottleCharges(itemBottle) > 0 then
                    --assess local units to see if they are in nRange, retreat until out of nRange * 1.15
                    --also don't use if we are taking DOT damage
                    local threateningUnits = {}
                    local curTimeMS = HoN.GetGameTime()
 
 
                    for id, unit in pairs(core.localUnits["EnemyUnits"]) do
                        local absRange = core.GetAbsoluteAttackRangeToUnit(unit, unitSelf)
                        local nDist = Vector3.Distance2D(vecSelfPos, unit:GetPosition())
                        if nDist < absRange * 1.15 then
                            local unitPair = {}
                            unitPair[1] = unit
                            unitPair[2] = (absRange * 1.15 - nDist)
                            tinsert(threateningUnits, unitPair)
                        end
                    end
 
 
                    if core.NumberElements(threateningUnits) > 0 or eventsLib.recentDotTime > curTimeMS or #eventsLib.incomingProjectiles["all"] > 0 then
                        --retreat.  determine best "away from threat" vector
                        local awayVec = Vector3.Create()
                        local totalExcessRange = 0
                        for key, unitPair in pairs(threateningUnits) do
                            local unitAwayVec = Vector3.Normalize(vecSelfPos - unitPair[1]:GetPosition())
                            awayVec = awayVec + unitAwayVec * unitPair[2]
                        end
 
 
                        if core.NumberElements(threateningUnits) > 0 then
                            awayVec = Vector3.Normalize(awayVec)
                        end
 
 
                        --average awayVec with "retreat" vector
                        local retreatVec = Vector3.Normalize(behaviorLib.PositionSelfBackUp() - vecSelfPos)
                        local moveVec = Vector3.Normalize(awayVec + retreatVec)
 
 
                        bActionTaken = core.OrderMoveToPosClamp(botBrain, unitSelf, vecSelfPos + moveVec * core.moveVecMultiplier, false)
                    else
                        bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBottle)
                    end
                end
            end
        end
    end
     
    if not bActionTaken then
        return object.useHealthRegenExecuteOld(botBrain)
    end
end
object.UseHealthRegenUtilityOld = behaviorLib.UseHealthRegenBehavior["Utility"]
behaviorLib.UseHealthRegenBehavior["Utility"] = UseHealthRegenUtilityOveride
object.useHealthRegenExecuteOld = behaviorLib.UseHealthRegenBehavior["Execute"]
behaviorLib.UseHealthRegenBehavior["Execute"] = UseHealthRegenExecuteOveride

-------------------------------------------------
--          HealAtWellExecute Overide          --
-------------------------------------------------
 
 
local function HealAtWellOveride(botBrain)
    local bActionTaken = false
    local unitSelf = core.unitSelf
  
    -- Use Bottle at well
     if not bActionTaken then
        core.FindItems()
        local itemBottle = core.itemBottle
        if itemBottle then
            if not unitSelf:HasState("State_Bottle") then
                if getBottleCharges(itemBottle) > 0 then
                    local unitAllyWell = core.allyWell
                    if unitAllyWell then
                        local nWellDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), unitAllyWell:GetPosition())
                        if nWellDistanceSq < (400 * 400) then
                            bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBottle)
                        end
                    end
                end
            end
        end
    end
  
    if not bActionTaken then
        return object.HealAtWellBehaviorOld(botBrain)
    end
end
object.HealAtWellBehaviorOld = behaviorLib.HealAtWellBehavior["Execute"]
behaviorLib.HealAtWellBehavior["Execute"] = HealAtWellOveride


BotEcho('Boom loaded')