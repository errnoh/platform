local _G = getfenv(0)
local object = _G.object

runfile 'bots/core_herobot.lua'
runfile 'bots/teams/errnoh/helpers.lua'

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills
local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

local Clamp = core.Clamp

printf("Loading %s", object.heroName)

--printKV(core)
printTable(core)
Echo("----")

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
  printUnits(core.localUnits)

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
  self:oncombateventOld(EventData)

  -- custom code here
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride
