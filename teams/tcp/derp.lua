--local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

runfile "bots/core_herobot.lua"
--runfile "bots/teams/tcp/json.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills
local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

local DEBUG = true

BotEcho(object:GetName()..' loading...')

-- DEBUG: We have math, string and coroutine exported. Print _G if needed
for key,value in next,_G.coroutine,nil do BotEcho(key) end

---------------------------------------------------------------
--            SkillBuild override                            --
-- Handles hero skill building. To customize just write own  --
---------------------------------------------------------------
-- @param: none
-- @return: none
function object:SkillBuildOverride()
  object:SkillBuildOld()
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
  if DEBUG then
    for key,value in next,EventData,nil do 
  	  local o = {}
  	  o[key] = value
  	  BotEcho(encode(o)) 
    end
  end
  self:oncombateventOld(EventData)

  -- custom code here
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride

