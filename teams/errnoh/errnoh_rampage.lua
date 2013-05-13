--####################################################################
--####################################################################
--#                                                                 ##
--#                       Bot Initiation                            ##
--#                                                                 ##
--####################################################################
--####################################################################

local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

runfile "bots/core_herobot.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

-- Annetan lokaalit helpommat nimet asioille
local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(object:GetName()..' loading <hero>_main...')

--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'errnoh_<hero>'


--   item buy order. internal names  
--   iterated over until all items in the present item variable are bought
behaviorLib.StartingItems = { "Item_RunesOfTheBlight", "Item_IronBuckler", "Item_LoggersHatchet" }
behaviorLib.LaneItems = { "Item_Marchers", "Item_Lifetube", "Item_ManaBattery" }
behaviorLib.MidItems = { "Item_EnhancedMarchers", "Item_Shield2", "Item_PowerSupply", "Item_MysticVestments" }
behaviorLib.LateItems = { "Item_Immunity", "Item_DaemonicBreastplate" }

-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
  1, 2, 1, 0, 1,
  3, 1, 2, 2, 2,
  3, 0, 0, 0, 4,
  3, 4, 4, 4, 4,
  4, 4, 4, 4, 4
}

local CHARGE_NONE, CHARGE_STARTED, CHARGE_TIMER, CHARGE_WARP = 0, 1, 2, 3

object.charged = CHARGE_NONE

-- bonus agression points if a skill/item is available for use


-- bonus agression points that are applied to the bot upon successfully using a skill/item


--thresholds of aggression the bot must reach to use these abilities





--####################################################################
--####################################################################
--#                                                                 ##
--#   bot function overrides                                        ##
--#                                                                 ##
--####################################################################
--####################################################################

------------------------------
--     skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
    core.VerboseLog("skillbuild()")

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
    local unitSelf = self.core.unitSelf
    if  skills.abilQ == nil then
        skills.abilQ = unitSelf:GetAbility(0)
        skills.abilW = unitSelf:GetAbility(1)
        skills.abilE = unitSelf:GetAbility(2)
        skills.abilR = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
    end
    if unitSelf:GetAbilityPointsAvailable() <= 0 then
        return
    end
    
    local nlev = unitSelf:GetLevel()
    local nlevpts = unitSelf:GetAbilityPointsAvailable()
    for i = nlev, nlev+nlevpts do
        unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
    end
end

------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

    -- custom code here
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride




----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function object:oncombateventOverride(EventData)
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent     = object.oncombateventOverride



------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
    return 99
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
local function HarassHeroExecuteOverride(botBrain)
    
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end
    
    
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
    
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
   
    -- DEBUG
    if bCanSee then
        core.DrawDebugArrow(unitSelf:GetPosition(), unitTarget:GetPosition(), 'cyan')

        local nTargetDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), unitTarget:GetPosition())

        -- core.OrderAbilityEntity(botBrain, ability, unitTarget, bInterruptAttacks, bQueueCommand)
        --
        local abilUltimate = skills.abilR
        local abilSlow = skills.abilW
        local abilBash = skills.abilE
        local abilCharge = skills.abilQ
        if abilCharge:CanActivate() then
            bActionTaken = core.OrderAbilityEntity(botBrain, abilCharge, unitTarget)
        end
        if abilSlow:CanActivate() then
            local nRange = 300
            if nTargetDistanceSq < (nRange * nRange) then
                return core.OrderAbility(botBrain, abilSlow)
            end
        end
        if abilUltimate:CanActivate() then
            local nRange = abilUltimate:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                bActionTaken = core.OrderAbilityEntity(botBrain, abilUltimate, unitTarget)
            end
        end
    end
    
    
    if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

function PositionSelfTraverseLaneFnOverride(botBrain)
        local bDebugLines = true
        local bDebugEchos = false

        --if botBrain.myName == 'ShamanBot' then bDebugEchos = true bDebugLines = true end

        local myPos = core.unitSelf:GetPosition()
        local desiredPos = nil
        if bDebugEchos then BotEcho("In PositionSelfTraverseLane") end
        local tLane = core.tMyLane
        if tLane then
                local vecFurthest = core.GetFurthestCreepWavePos(tLane, core.bTraverseForward)
                if vecFurthest then
                        desiredPos = vecFurthest
                else
                        if bDebugEchos then BotEcho("PositionSelfTraverseLane - can't fine furthest creep wave pos in lane " .. tLane.sLaneName) end
                        desiredPos = core.enemyMainBaseStructure:GetPosition()
                end
        else
                BotEcho('PositionSelfTraverseLane - unable to get my lane!')
        end

        if bDebugLines then
                core.DrawDebugArrow(myPos, desiredPos, 'white')
        end

        --

        local enemy = GetEnemy(botBrain)
        if enemy then
            local abilCharge = skills.abilQ
            if abilCharge:CanActivate() then
                BotEcho('LANE PRKL')
                core.OrderAbilityEntity(botBrain, abilCharge, enemy)
            end
        end

        --

        return desiredPos
end
behaviorLib.PositionSelfTraverseLane = PositionSelfTraverseLaneFnOverride   


----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function object:oncombateventOverride(EventData)
  self:oncombateventOld(EventData)

  if EventData.Type == "Ability" and EventData.InflictorName == "Ability_Rampage1" then
    self.charged = CHARGE_STARTED
  elseif EventData.Type == "State_End" and EventData.StateName == "State_Rampage_Ability1_Timer" then
    if self.charged == CHARGE_STARTED then
      self.charged = CHARGE_NONE
    end
  elseif EventData.Type == "State" and EventData.StateName == "State_Rampage_Ability1_Warp" then
    self.charged = CHARGE_WARP
  elseif EventData.Type == "State_End" and EventData.StateName == "State_Rampage_Ability1_Warp" then
    self.charged = CHARGE_NONE
  elseif EventData.Type == "Death" then
    self.charged = CHARGE_NONE
  end
end
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride

function GetEnemy(botBrain)
        local bDebugEchos = true

        --if core.unitSelf:GetTypeName() == "Hero_Predator" then bDebugEchos = true end

        local nUtility = 0
        local unitTarget = nil

        local unitSelf = core.unitSelf
        local nMyID = unitSelf:GetUniqueID()
        local vecMyPosition = unitSelf:GetPosition()

        local tLocalEnemies = core.CopyTable(core.localUnits["EnemyHeroes"])
        local function fnIsHero(unit)
                return unit:IsHero()
        end

        core.teamBotBrain:AddMemoryUnitsToTable(tLocalEnemies, core.enemyTeam, vecMyPosition, nil, fnIsHero)

        if not core.IsTableEmpty(tLocalEnemies) then
                local unitClosestEnemyTower = core.GetClosestEnemyTower(vecMyPosition)
                local nAllyThreatRange = 1200
                local nHalfAllyThreatRange = nAllyThreatRange * 0.5

                local tLocalAllies = core.CopyTable(core.localUnits["AllyHeroes"])
                tLocalAllies[unitSelf:GetUniqueID()] = unitSelf --include myself in the threat calculations
                local nTotalAllyThreat = 0
                local nMyThreat = 0
                local nMyDefense = 0

                local nTotalEnemyThreat = 0
                local nLowestEnemyDefense = 999999
                local unitWeakestEnemy = nil
                local nHighestEnemyThreat = 0

                --local references to loop functions, to increase performance
                local nHarassBonus = core.nHarassBonus
                local funcGetThreat = behaviorLib.GetThreat
                local funcGetDefense = behaviorLib.GetDefense
                local nHarassUtilityWeight = behaviorLib.harassUtilityWeight
                local funcProxToEnemyTowerUtility    =  behaviorLib.ProxToEnemyTowerUtility
                local funcLethalityDifferenceUtility = behaviorLib.LethalityDifferenceUtility
                local funcCustomHarassUtility        = behaviorLib.CustomHarassUtility
                local funcAttackAdvantageUtility     = behaviorLib.AttackAdvantageUtility
                local funcInRangeUtility             = behaviorLib.InRangeUtility               

                local nMyProxToEnemyTowerUtility = funcProxToEnemyTowerUtility(unitSelf, unitClosestEnemyTower)

                if bDebugEchos then BotEcho("HarassHeroNew") end

                --Enemies
                for nID, unitEnemy in pairs(tLocalEnemies) do
                        local nThreat = funcGetThreat(unitEnemy)
                        nTotalEnemyThreat = nTotalEnemyThreat + nThreat
                        if nThreat > nHighestEnemyThreat then
                                nHighestEnemyThreat = nThreat
                        end

                        local nDefense = funcGetDefense(unitEnemy)
                        if nDefense < nLowestEnemyDefense then
                                nLowestEnemyDefense = nDefense
                                unitWeakestEnemy = unitEnemy
                        end

                        if bDebugEchos then BotEcho(nID..": "..unitEnemy:GetTypeName().."  threat: "..Round(nThreat).."  defense: "..Round(nDefense)) end
                end

                --Aquire a target
                --TODO: based on mix of priority target (high threat) v weak (low defense)
                return unitWeakestEnemy
        end
        return false
end

local function ChargeTarget(botBrain, unitSelf, abilCharge)
  local tEnemyHeroes = HoN.GetHeroes(core.enemyTeam)
  local utility = 0
  local unitTarget = nil
  local nTarget = 0
  for nUID, unit in pairs(tEnemyHeroes) do
    if core.CanSeeUnit(botBrain, unit) and unit:IsAlive() and (not unitTarget or unit:GetHealth() < unitTarget:GetHealth()) then
      unitTarget = unit
      nTarget = nUID
    end
  end
  if unitTarget then
    local damageLevels = {100,140,180,220}
    local chargeDamage = damageLevels[abilCharge:GetLevel()]
    local estimatedHP = unitTarget:GetHealth() - chargeDamage
    if estimatedHP < 200 then
      utility = 20
    end
    if unitTarget:GetManaPercent() < 30 then
      utility = utility + 5
    end
    local level = unitTarget:GetLevel()
    local ownLevel = unitSelf:GetLevel()
    if level < ownLevel then
      utility = utility + 5 * (ownLevel - level)
    else
      utility = utility - 10 * (ownLevel - level)
    end
    local vecTarget = unitTarget:GetPosition()
    for nUID, unit in pairs(tEnemyHeroes) do
      if nUID ~= nTarget and core.CanSeeUnit(botBrain, unit) and Vector3.Distance2DSq(vecTarget, unit:GetPosition()) < (500 * 500) then
        utility = utility - 5
      end
    end
  end
  return unitTarget, utility
end

local function ChargeUtility(botBrain)
  local abilCharge = skills.abilQ
  local unitSelf = core.unitSelf
  if object.charged ~= CHARGE_NONE then
    return 9999
  end
  if not abilCharge:CanActivate() then
    return 0
  end
  local unitTarget, utility = ChargeTarget(botBrain, unitSelf, abilCharge)
  if unitTarget then
    object.chargeTarget = unitTarget
    return utility
  end
  return 0
end

local function ChargeExecute(botBrain)
  local abilCharge = skills.abilQ
  local bActionTaken = false
  if botBrain.charged ~= CHARGE_NONE then
    return true
  end
  if not object.chargeTarget then
    return false
  end
  if abilCharge:CanActivate() then
    bActionTaken = core.OrderAbilityEntity(botBrain, abilCharge, object.chargeTarget)
  end
  return bActionTaken
end

local ChargeBehavior = {}
ChargeBehavior["Utility"] = ChargeUtility
ChargeBehavior["Execute"] = ChargeExecute
ChargeBehavior["Name"] = "Charge like a boss"
tinsert(behaviorLib.tBehaviors, ChargeBehavior)

