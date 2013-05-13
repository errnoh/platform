local _G = getfenv(0)
local object = _G.object

object.behaviorLib = object.behaviorLib or {}
local core, behaviorLib, pairs, tinsert = object.core, object.behaviorLib, _G.pairs, _G.table.insert

behaviorLib.towerToDeny = nil
function behaviorLib.DenyUtility(botBrain)
	if core.nDifficulty == core.nEASY_DIFFICULTY then
		--dont deny on easy
		return 0
	end
	for _,tower in pairs(core.localUnits["AllyTowers"]) do --There should be 1 or 0
		if tower:GetHealthPercent() < 0.10 then
			if core.NumberElements(core.localUnits["Enemies"]) == 0 then
				--no one here so just deny it
				behaviorLib.towerToDeny = tower
				return 50
			end
			if core.nDifficulty == core.nHARD_DIFFICULTY then
				--On hard try deny when thers enemies near
				if tower:GetHealth() <= core.unitSelf:GetAttackDamageMin() * (1 - tower:GetPhysicalResistance()) then
					--deny it NOW
					if core.GetAbsoluteAttackRangeToUnit(core.unitSelf, behaviorLib.towerToDeny, true) > Vector3.Distance2DSq(core.unitSelf:GetPosition(), tower:GetPosition()) then
						--more priority if we are actually close enought
						behaviorLib.towerToDeny = tower
						return 55
					end
					behaviorLib.towerToDeny = tower
					return 50
				else
					if tower:GetHealthPercent() < 0.05 then
						if core.GetAbsoluteAttackRangeToUnit(core.unitSelf, behaviorLib.towerToDeny, true) < Vector3.Distance2DSq(core.unitSelf:GetPosition(), tower:GetPosition()) then
							--To walk near and get ready
							--melee heroes particularly
							behaviorLib.towerToDeny = tower
							return 45
						end
					end
				end
			end
		end
	end
	return 0
end

function behaviorLib.DenyExecute(botBrain)
	actionTaken = false
	if core.NumberElements(core.localUnits["Enemies"]) == 0 then
		actionTaken = core.OrderAttack(botBrain, core.unitSelf, behaviorLib.towerToDeny)
	else
		if core.GetAbsoluteAttackRangeToUnit(core.unitSelf, behaviorLib.towerToDeny, true) >= Vector3.Distance2DSq(core.unitSelf:GetPosition(), behaviorLib.towerToDeny:GetPosition()) then
			if behaviorLib.towerToDeny:GetHealth() <= core.unitSelf:GetAttackDamageMin() * (1 - behaviorLib.towerToDeny:GetPhysicalResistance()) then
				actionTaken = core.OrderAttack(botBrain, core.unitSelf, behaviorLib.towerToDeny)
			end
		else
			actionTaken = core.OrderMoveToUnit(botBrain, core.unitSelf, behaviorLib.towerToDeny, true, false)
		end
	end
	return actionTaken
end

behaviorLib.DenyBehavior = {}
behaviorLib.DenyBehavior["Utility"] = behaviorLib.DenyUtility
behaviorLib.DenyBehavior["Execute"] = behaviorLib.DenyExecute
behaviorLib.DenyBehavior["Name"] = "Deny"
tinsert(behaviorLib.tBehaviors, behaviorLib.DenyBehavior)
