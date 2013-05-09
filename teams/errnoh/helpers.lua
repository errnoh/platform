Echo("Loading helper functions...")

local _G = getfenv(0)
local object = _G.object
local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

function printf(...) return Echo(string.format(...)) end

function maxRange(unit)
  local nAttackRange = unit:GetAttackRange()
  local maxrange = nAttackRange
  for i=1,10 do
    local skill = unit:GetAbility(i)
    if not skill then
      break
    end
    -- Pitää lukea xmlstä damage. vrt skill:GetTypeName()
    if not skill:CanActivate() then
    else
      if skill:GetRange() > maxrange then
        maxrange = skill:GetRange()
      end
    end
  end
  return maxrange
end

-- TODO
function onExpRange(target)
end

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
    [10] = function(pos, height, color) core.DrawDebugLine(pos+Vector3.new(height/2,0), (pos + Vector3.new(height/2, 0)) + Vector3.new(0, height/2), color) end,
    [12] = function(pos, height, color) core.DrawDebugLine(pos+Vector3.new(0,height/2), (pos + Vector3.new(0, height/2)) + Vector3.new(height/2, 0), color) end,
    [17] = function(pos, height, color) core.DrawDebugLine(pos, pos + Vector3.new(0, height), color) end,
    [20] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(0,height/2), (pos + Vector3.new(0, height/2)) + Vector3.new(0, height/2), color) end,
    [34] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(height/2, 0), (pos + Vector3.new(height/2, 0)) + Vector3.new(0, height), color) end,
    [40] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(height/2, height/2), (pos + Vector3.new(height/2, height/2)) + Vector3.new(0, height/2), color) end,
    [48] = function(pos, height, color) core.DrawDebugLine(pos + Vector3.new(0, height), (pos + Vector3.new(0, height)) + Vector3.new(height/2, 0), color) end,
}

local function drawline(ptvals, pos, height, color)
  for key,value in pairs(ptvals) do 
    tPtval[value](pos, height, color)
  end      
end

function debugNumbers(value, pos, height, color)
  local str = tostring(value)
  for c in str:gmatch"." do
    tDrawLine[value](pos, height, color)
    pos.x = pos.x + height/(2/3)
  end
end

-- Tee tästä oikeastaan iterable table tj..
function printUnit(unit)
  local hero = core.unitSelf
  local vecSelfPos = hero:GetPosition()
  local vecUnitPos = unit:GetPosition()
  local nUnitTeam = unit:GetTeam()
  local nSelfTeam = hero:GetTeam()
  local vecDistance2 = Vector3.Distance2DSq(vecSelfPos, vecUnitPos)
  local nAttackRange = maxRange(unit)
  local nSelfAttackRange = maxRange(hero)
  local bInAttackRange = vecDistance2 - nAttackRange*nAttackRange <= 0
  --printf("  %s: %.0f (%.0f, %.0f) %s", unit:GetTypeName(), unit:GetHealth(), vecUnitPos.x, vecUnitPos.y, tostring(bInAttackRange))

  if nUnitTeam ~= nSelfTeam then
    core.DrawDebugArrow(vecUnitPos, rangeVector(unit, hero, nAttackRange), 'red')
    core.DrawDebugArrow(vecSelfPos, rangeVector(hero, unit, nSelfAttackRange), 'blue')
  end
end

-- on olemassa vector.unit joka on yksikkövektori suoraan.
-- löytyy myös v1:isClose(v2, .001) joka tarkastaa etäisyyden
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

Echo("Loaded.")
