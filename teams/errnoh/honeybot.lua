<<<<<<< HEAD
--local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

runfile "bots/core_herobot.lua"
runfile "bots/teams/errnoh/helpers.lua"
=======
local _G = getfenv(0)
local object = _G.object

runfile 'bots/core_herobot.lua'
runfile 'bots/teams/errnoh/helpers.lua'
>>>>>>> cd8f7bcf9a9783a97789658fdbdb3d6ba67f8af7

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills
local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

<<<<<<< HEAD
local DEBUG = true


BotEcho(object:GetName()..' loading...')

printTableKeys(core)
=======
local Clamp = core.Clamp

printf("Loading %s", object.heroName)

--printKV(core)
printTable(core)
Echo("----")
>>>>>>> cd8f7bcf9a9783a97789658fdbdb3d6ba67f8af7

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
<<<<<<< HEAD
=======
  printUnits(core.localUnits)

>>>>>>> cd8f7bcf9a9783a97789658fdbdb3d6ba67f8af7
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
<<<<<<< HEAD
  if DEBUG then
    --printTable(EventData)
    for key,value in next,EventData,nil do 
      local o = {}
      o[key] = value
      Echo(encode(o)) 
    end
  end
=======
  printUnits(core.localUnits)
>>>>>>> cd8f7bcf9a9783a97789658fdbdb3d6ba67f8af7
  self:oncombateventOld(EventData)

  -- custom code here
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride
<<<<<<< HEAD

=======
>>>>>>> cd8f7bcf9a9783a97789658fdbdb3d6ba67f8af7
