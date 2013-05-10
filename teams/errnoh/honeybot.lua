local _G = getfenv(0)
local object = _G.object

runfile 'bots/core_herobot.lua'
runfile 'bots/teams/errnoh/helpers.lua'
runfile 'bots/teams/errnoh/abilities.lua'
runfile 'bots/lib/rune_controlling/init.lua'

object.heroName = object:GetName()

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills
local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, asin, min, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.asin, _G.math.min, _G.math.max, _G.math.random
 

local Clamp = core.Clamp

printf("Loading %s", object.heroName)

--printTable(core)

object.tSkills = {
  0, 1, 0, 1, 0,
  3, 0, 1, 2, 2,
  3, 2, 2, 1, 4,
  3, 4, 4, 4, 4,
  4, 4, 4, 4, 4
}

-- Ring of the Teacher -- armor, dmg, manaregen. (500)
-- Ring of Sorcery olisi käytännössä manaboots ilman bootsia. + armor.

-- Abyssal Skull olisi jopa kohtalaisen halpa armor + lifesteal

behaviorLib.MidVsMeleeItems = {"Item_Ringmail", "Item_PlatedGreaves", "Item_Platemail", "Item_HungrySpirit"}
behaviorLib.LateVsMeleeItems = {"Item_FrostfieldPlate", "Item_LifeSteal5", "Item_LifeSteal4"}
-- LifeSteal5 == Abyssal Skull, LifeSteal4 == Symbol of Rage
behaviorLib.MidVsCasterItems = {"Item_MysticVestments", "Item_TrinketOfRestoration", "Item_MagicArmor2", "Item_Steamboots" }
behaviorLib.LateVsCasterItems = {"Item_BarrierIdol", "Item_Immunity","Item_ManaBurn1"}
-- MagicArmor2 == Shamans Headdress, ManaBurn1 == Nullfire Blade
behaviorLib.StartingItems = { "Item_Bottle", "Item_MinorTotem", "Item_MinorTotem", "Item_TrinketOfRestoration" }
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

---------------------------------------------------------------
--            SkillBuild override                            --
-- Handles hero skill building. To customize just write own  --
---------------------------------------------------------------
-- @param: none
-- @return: none
function object:SkillBuildOverride()
  object:SkillBuildOld()
  local unitSelf = self.core.unitSelf
  if  skills.abilQ == nil then
      skills.abilQ = unitSelf:GetAbility(0)
      skills.abilW = unitSelf:GetAbility(1)
      skills.abilE = unitSelf:GetAbility(2)
      skills.abilR = unitSelf:GetAbility(3)
      skills.abilAttributeBoost = unitSelf:GetAbility(4)
  end
end
object.SkillBuildOld = object.SkillBuild
object.SkillBuild = object.SkillBuildOverride

------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
  self:onthinkOld(tGameVariables)
  if core.localUnits then
    drawRanges(core.localUnits)
  end

  -- custom code here
end
object.onthinkOld = object.onthink
object.onthink = object.onthinkOverride

----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function object:oncombateventOverride(EventData)
  printUnits(core.localUnits)
  --[[
  for key,value in pairs(core.localUnits['EnemyHeroes']) do 
    for k,v in pairs(value:GetInventory(true)) do 
      print(v:GetTypeName())
    end
  end
  ]]--
  self:oncombateventOld(EventData)

  -- custom code here
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride

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
  
  if skills.abilQ:CanActivate() then
    val = val + object.moonbeamUpBonus
  end
  
  if skills.abilR:CanActivate() then
    val = val + object.ultUpBonus
  end
  val = val + (core.unitSelf:GetManaPercent() - 0.5) * 30

  local creeps = funcFilterGroupRange(core.localUnits["EnemyCreeps"], hero:GetPosition(), abilityRange(skills.abilR))
  local heroes = funcFilterGroupRange(core.localUnits["EnemyHeroes"], hero:GetPosition(), abilityRange(skills.abilR))
  if skills.abilR:CanActivate() and core.NumberElements(creeps) <= 1 and core.NumberElements(heroes) > 0 then
    return 99
  end
  return val
end
behaviorLib.CustomHarassUtilityOld = behaviorLib.CustomHarassUtility
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   


BotEcho("Bot loaded.")

--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
-- @param botBrain: CBotBrain
-- @return: none
--
local function HarassHeroExecuteOverride(botBrain)
    local unitSelf = core.unitSelf
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end

    local vecMyPosition = unitSelf:GetPosition() 
    local vecTargetPosition = unitTarget:GetPosition()
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
    
    --local bCanSee = core.CanSeeUnit(botBrain, unitTarget)    
    bCanSee = true
    local bActionTaken = false
    
    -- Stop the bot from trying to harass heroes while dead
    if not bActionTaken and not unitSelf:IsAlive() then
        bActionTaken = true
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

    if bCanSee and not bActionTaken then
        core.DrawDebugArrow(unitSelf:GetPosition(), unitTarget:GetPosition(), 'red')

        local nTargetDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), unitTarget:GetPosition())

        -- core.OrderAbilityEntity(botBrain, ability, unitTarget, bInterruptAttacks, bQueueCommand)
        local abilBeam = skills.abilQ
        local abilMulti = skills.abilW
        local abilUltimate = skills.abilR
        if abilBeam:CanActivate() then
            bActionTaken = core.OrderAbilityEntity(botBrain, abilBeam, unitTarget)
        end
        if abilUltimate:CanActivate() then
            local creeps = funcFilterGroupRange(core.localUnits["EnemyCreeps"], unitSelf:GetPosition(), abilityRange(skills.abilR))
            if core.NumberElements(creeps) == 0 then
              local nRange = 700
              if nTargetDistanceSq < (nRange * nRange) then
                  return core.OrderAbility(botBrain, abilUltimate)
              end
            end
        end
    end
    
    if not bActionTaken then
        --return behaviorLib.harassExecuteOld(botBrain)
        return behaviorLib.AttackCreepsUtility(botBrain) 
    end 
end
-- overload the behaviour stock function with custom 
behaviorLib.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

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
 


local function funcFindItemsOverride(botBrain)
    local unitSelf = core.unitSelf

    if core.itemBottle ~= nil and not core.itemBottle:IsValid() then
        core.itemBottle = nil
    end
     
    if core.itemCodex ~= nil and not core.itemCodex:IsValid() then
        core.itemCodex = nil
    end
  
    if core.itemHellflower ~= nil and not core.itemHellflower:IsValid() then
        core.itemHellflower = nil
    end
     
    if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
        core.itemSheepstick = nil
    end
      
        local inventory = unitSelf:GetInventory(true)
        for slot = 1, 12, 1 do
            local curItem = inventory[slot]
            if curItem then
                if core.itemBottle == nil and curItem:GetName() == "Item_Bottle" then
                    core.itemBottle = core.WrapInTable(curItem)
                elseif core.itemCodex == nil and curItem:GetName() == "Item_Nuke" then
                    core.itemCodex = core.WrapInTable(curItem)
                elseif core.itemHellflower == nil and curItem:GetName() == "Item_Silence" then
                    core.itemHellflower = core.WrapInTable(curItem)
                elseif core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
                    core.itemSheepstick = core.WrapInTable(curItem)
                end
            end
        end
    return true
end 
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

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

function behaviorLib.UltimateUtility(botBrain)

  if not skills.abilR:CanActivate() then
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
  if core.NumberElements(localUnits["tEnemyUnits"]) <= skills.abilR:GetLevel() + 1 then
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
  bActionTaken = core.OrderAbility(botBrain, skills.abilR)

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