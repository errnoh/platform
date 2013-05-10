Echo("Loading helper functions...")

local _G = getfenv(0)
local tinsert = _G.table.insert
local object = _G.object
local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

function printf(...) return Echo(string.format(...)) end

function abilityRange(ability)
  if ability:GetLevel() == 0 then
    return 0
  end
  local abilityRange = ability and (ability:GetRange() + core.GetExtraRange(unitSelf) + core.GetExtraRange(unitTarget)) or 0
  if abilityRange == 0 then
      --print(ability:GetTypeName())
      local skill = Collection.tAbilities[ability:GetTypeName()]
      if skill then
        local a = skill[ability:GetLevel()]
        abilityRange = a.range
      end
  end
  return abilityRange
end

function funcFilterGroupRange(tGroup, vecGroupCenter, nRange)
    if tGroup == nil or vecGroupCenter == nil or nRange == nil then return nil end
     
    local tTableTemp = {}
    local nRangeSq = nRange*nRange
    for id, unit in pairs(tGroup) do
        if Vector3.Distance2D(unit:GetPosition(), vecGroupCenter) < (nRangeSq) then
            tinsert(tTableTemp, unit)
        end
    end
 
    if #tTableTemp <= 0 then
        return nil
    else
        return tTableTemp
    end
end

function maxRange(unit)
  local nAttackRange = unit:GetAttackRange()
  local maxrange = nAttackRange
  for i=0,10 do
    local skill = unit:GetAbility(i)
    if not skill then
      break
    end
    -- Pitää lukea xmlstä damage. vrt skill:GetTypeName()
    if not skill:CanActivate() then
    else
      local ability = Collection.tAbilities[skill:GetTypeName()]
      if ability then
        local a = ability[skill:GetLevel()]
        if a.damage > 0 and abilityRange(skill) > maxrange then
          maxrange = abilityRange(skill)
        end
      end
    end
  end
  return maxrange
end

function maxDamage(unit, target)
  local count = 0
  local dist = Vector3.Distance2D(unit:GetPosition(), target:GetPosition())
  local nAttackRange = unit:GetAttackRange()
  if nAttackRange >= dist then
    count = count + unit:GetFinalAttackDamageMax()
  end
  for i=0,10 do
    local skill = unit:GetAbility(i)
    if not skill then
      break
    end
    if not skill:CanActivate() then
    else
      local ability = Collection.tAbilities[skill:GetTypeName()]
      if ability then
        local a = ability[skill:GetLevel()]
        if abilityRange(skill) >= dist then
          count = count+a.damage
        end
      end
    end
  end
  return count
end

function onExpRange(target)
  local hero = core.unitSelf
  local v1 = hero:GetPosition()
  local v2 = target:GetPosition()
  return Vector3.Distance2D(v1, v2) < 1000
end

-- Tee tästä oikeastaan iterable table tj..
function printUnit(unit)
  local hero = core.unitSelf
  local vecSelfPos = hero:GetPosition()
  local vecUnitPos = unit:GetPosition()
  local nUnitTeam = unit:GetTeam()
  local nSelfTeam = hero:GetTeam()
  local vecDistance2 = Vector3.Distance2DSq(vecSelfPos, vecUnitPos)
  local vecDistance = Vector3.Distance2D(vecSelfPos, vecUnitPos)
  local nAttackRange = maxRange(unit)
  local nSelfAttackRange = maxRange(hero)
  local bInAttackRange = vecDistance2 - nAttackRange*nAttackRange <= 0
  printf("  %s: %.0f (%.0f, %.0f) %s", unit:GetTypeName(), unit:GetHealth(), vecUnitPos.x, vecUnitPos.y, tostring(bInAttackRange))
end

-- on olemassa vector.unit joka on yksikkövektori suoraan.
function rangeVector(unit, target, nRange)
    local vecUnitPos = unit:GetPosition()
    local vecTargetPos = target:GetPosition()

    local x, y = vecUnitPos.x - vecTargetPos.x, vecUnitPos.y - vecTargetPos.y
    local dist = Vector3.Distance2D(vecTargetPos, vecUnitPos)
    x, y = x/dist*nRange, y/dist*nRange
    local v = vecUnitPos-Vector3.Create(x, y)
    return v
end

function printUnits(unittable)
  for key,value in pairs(unittable) do 
      print(key .. " " .. core.NumberElements(value) ..  "\n")
      local units = value
      for id, unit in pairs(units) do
        printUnit(unit)
      end
  end
end

function drawRanges(unittable)
  for key,value in pairs(unittable) do 
      local units = value
      for id, unit in pairs(units) do
        drawRange(unit)
      end
  end
end

function drawRange(unit)
  local hero = core.unitSelf
  local vecSelfPos = hero:GetPosition()
  local vecUnitPos = unit:GetPosition()
  local nUnitTeam = unit:GetTeam()
  local nSelfTeam = hero:GetTeam()
  local vecDistance2 = Vector3.Distance2DSq(vecSelfPos, vecUnitPos)
  local vecDistance = Vector3.Distance2D(vecSelfPos, vecUnitPos)
  local nAttackRange = maxRange(unit)
  local nSelfAttackRange = maxRange(hero)
  local bInAttackRange = vecDistance2 - nAttackRange*nAttackRange <= 0

  if nUnitTeam ~= nSelfTeam then
    if nAttackRange > vecDistance then
      nAttackRange = vecDistance
    end
    if nSelfAttackRange > vecDistance then
      nSelfAttackRange = vecDistance
    end
    core.DrawDebugArrow(vecUnitPos, rangeVector(unit, hero, nAttackRange), 'red')
    local color = 'white'
    if onExpRange(unit) then
      color = 'green'
    end
    if not unit:GetHealth() then
      Echo(unit:GetTypeName())
      return
    end
    if maxDamage(hero, unit) > unit:GetHealth() then
      color = 'yellow'
    end
    core.DrawDebugArrow(vecSelfPos, rangeVector(hero, unit, nSelfAttackRange), color)
  end
end

Echo("Loaded.")



--[[
local tDrawLine = {
    ["1"] = function (pos, height, color) drawline({34},pos,height,color) end,
    ["2"] = function (pos, height, color) drawline({3,10,12,20,48},pos,height,color) end,
    ["3"] = function (pos, height, color) drawline({3,12,34,48},pos,height,color) end,
    ["4"] = function (pos, height, color) drawline({5,12,34},pos,height,color) end,
    ["5"] = function (pos, height, color) drawline({3,5,12,40,48},pos,height,color) end,
    ["6"] = function (pos, height, color) drawline({12,17,40,48},pos,height,color) end,
    ["7"] = function (pos, height, color) drawline({3,34},pos,height,color) end,
    ["8"] = function (pos, height, color) drawline({3,12,17,34,48},pos,height,color) end,
    ["9"] = function (pos, height, color) drawline({3,5,12,34},pos,height,color) end,
    ["0"] = function (pos, height, color) drawline({3,17,34,48},pos,height,color) end,
}

local tPtval = {
    [3] = function(pos, height, color) core.DrawDebugLine(pos, pos + Vector3.new(height/2, 0), color) end,
    [5] = function(pos, height, color) core.DrawDebugLine(pos, pos + Vector3.new(0, height/2), color) end,
    [10] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(height/2,0), (pos + Vector3.new(height/2, 0)) + Vector3.new(0, height/2), color) end,
    [12] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(0,height/2), (pos + Vector3.new(0, height/2)) + Vector3.new(height/2, 0), color) end,
    [17] = function(pos, height, color) core.DrawDebugLine(pos, pos + Vector3.new(0, height), color) end,
    [20] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(0,height/2), (pos + Vector3.new(0, height/2)) + Vector3.new(0, height/2), color) end,
    [34] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(height/2, 0), (pos + Vector3.new(height/2, 0)) + Vector3.new(0, height), color) end,
    [40] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(height/2, height/2), (pos + Vector3.new(height/2, height/2)) + Vector3.new(0, height/2), color) end,
    [48] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(0, height), (pos + Vector3.new(0, height)) + Vector3.new(height/2, 0), color) end,
}

function drawline(ptvals, pos, height, color)
  for key,value in pairs(ptvals) do 
    --Echo(Vector3.new(pos.x, pos.y))
    --tPtval[value](pos, height, color)
  end      
end

function debugNumbers(value, pos, height, color)
  local str = tostring(value)
  for c in str:gmatch"." do
    tDrawLine[c](pos, height, color)
    pos.x = pos.x + height/(2/3)
  end
end
]]--