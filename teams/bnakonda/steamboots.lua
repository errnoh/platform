local _G = getfenv(0)
local object = _G.object

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

object.SteamBootsLib = object.SteamBootsLib or {}
SteamBootsLib = object.SteamBootsLib
SteamBootsLib.desiredAttribute = "str"

--errors if not in core :(
function core.SteamBootsLibFindItemsOverride(botBrain)
	core.SteamBootsLibFindItemsOld(botBrain)
	if core.itemSteamBoots ~= nil and not core.itemSteamBoots:IsValid() then
		core.itemSteamBoots = nil
	end

	local inventory = core.unitSelf:GetInventory(true)
	for slot = 1, 6, 1 do
		local curItem = inventory[slot]
		if curItem ~= nil then
			if core.itemSteamBoots == nil and curItem:GetName() == "Item_Steamboots" then
				core.itemSteamBoots = core.WrapInTable(curItem)
			end
		end
	end
end

core.SteamBootsLibFindItemsOld = core.FindItems
core.FindItems = core.SteamBootsLibFindItemsOverride

local toggleDelay = 0
function object:SteamBootsLibonthinkOverride(tGameVariables)
	self:SteamBootsLibonthinkOld(tGameVariables)-- old think

	currentAttribute = self.SteamBootsLib.getAttributeBonus()
	if core.itemSteamBoots and currentAttribute ~= "" and currentAttribute ~= SteamBootsLib.desiredAttribute then
		if toggleDelay ~= 0 then
			toggleDelay = toggleDelay - 1 --not to spam faster than it can handle
		else
			--BotEcho(tostring(SteamBootsLib.getAttributeBonus()) .. " " .. SteamBootsLib.desiredAttribute)
			self:OrderItem(core.itemSteamBoots.object, false)
			toggleDelay = 5
		end
	end
end
object.SteamBootsLibonthinkOld = object.onthink
object.onthink 	= object.SteamBootsLibonthinkOverride

function SteamBootsLib.haveSteamBoots()
	return core.itemSteamBoots ~= nil
end

function SteamBootsLib.getAttributeBonus()
	if not core.itemSteamBoots then
		return ""
	end
	local attribute = core.itemSteamBoots:GetActiveModifierKey()
	if attribute == nil then
		--bug?
		return ""
	end
	return attribute
end

function SteamBootsLib.setAttributeBonus(attribute)
	if attribute == "str" or attribute == "agi" or attribute == "int" then
		SteamBootsLib.desiredAttribute = attribute
	end
end
