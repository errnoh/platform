local _G = getfenv(0)
local object = _G.object

object.core = object.core or {}
local core, eventsLib, behaviorLib, metadata = object.core, object.eventsLib, object.behaviorLib, object.metadata

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local sqrtTwo = math.sqrt(2)
	
-- Math functions --

-- the following several functions take in various points and variables to create a mathematical function F(x),
--   and then return the value of F at x.  This is very useful for creating and easily tweaking utility funcitons.
function core.CubicRootFn(x, vMax, vMin, bDebug)
	bDebug = bDebug or false

	-- y = h*( (x - originX)/w ) + originY
	local h = (vMax.y - vMin.y)/2
	local w = (vMax.x - vMin.x)/2
	local originY = (vMax.y + vMin.y)/2
	local originX = (vMax.x + vMin.x)/2
	
	if bDebug then
		Echo( format("CubicRootFn(%g, v(%g, %g), v(%g, %g))", x, vMax.x, vMax.y, vMin.x, vMin.y) )
		Echo( format( "%g*( ((x - %g)/%g)^(1/3)) + %g)", h, originX, w, originY) )
	end
	
	local val = 0
	local base = (x - originX)/w
	if base < 0 then
		local absBase = abs((x - originX)/w)
		val = -1*h*( (absBase)^(1/3) ) + originY
	elseif base > 0 then
		val = h*( ((x - originX)/w)^(1/3)) + originY
	end
	
	return val
end

function core.ExponentialFn(x, vPositivePoint, vOrigin, order, bDebug)
	bDebug = bDebug or false
	
	local w = (vPositivePoint.x - vOrigin.x)
	local h = (vPositivePoint.y - vOrigin.y)
	
	local val = h * ((x-vOrigin.x)/w) ^ order + vOrigin.y
	
	if bDebug then
		Echo( format("ExponentialFn(%g, v(%g, %g), v(%g, %g), %g)", 
		  x, vPositivePoint.x, vPositivePoint.y, vOrigin.x, vOrigin.y, order) )	
				
		Echo( format( "%g*( ((x - %g)/%g)^(%g) ) + %g", 
		  h, vOrigin.x, w, order, vOrigin.y) )
	end	
	
	return val
end

function core.UnbalancedSRootFn(x, vMaxIn, vMinIn, vOrigin, order, bDebug)
	-- an S shaped (think cubic) function with differeing curves on the left and right
	bDebug = bDebug or false
	
	if not vOrigin then
		return core.CubicRootFn(x, vMaxIn, vMinIn, bDebug)
	end
	
	if bDebug then
		Echo( format("UnbalancedSRootFn(%g, v(%g, %g), v(%g, %g), v(%g, %g), %d)", 
			x, vMaxIn.x, vMaxIn.y, vMinIn.x, vMinIn.y, vOrigin.x, vOrigin.y, order) )
		
		if true then
			local vMax = vMaxIn
			local vMin = vMinIn
			vMin = vOrigin + (vOrigin - vMax)
			
			local h = (vMax.y - vMin.y)/2
			local w = (vMax.x - vMin.x)/2
			local originY = vOrigin.y
			local originX = vOrigin.x			
				
			Echo( format( "x right of origin: %g*( ((x - %g)/%g)^(1/%g) ) + %g", h, originX, w, order, originY) )
		end
		if true then
			local vMax = vMaxIn
			local vMin = vMinIn
			vMax = vOrigin + (vOrigin - vMin)
			
			local h = (vMax.y - vMin.y)/2
			local w = (vMax.x - vMin.x)/2
			local originY = vOrigin.y
			local originX = vOrigin.x			
				
			Echo( format( "x left of origin: %g*( ((x - %g)/%g)^(1/%g) ) + %g", h, originX, w, order, originY) )
		end
	end	
	
	local vMax = vMaxIn
	local vMin = vMinIn
	if x > vOrigin.x then
		vMin = vOrigin + (vOrigin - vMax)
	else
		vMax = vOrigin + (vOrigin - vMin)
	end
	
	-- y = h*( ((x - originX)/w )^(1/order) ) + originY
	local h = (vMax.y - vMin.y)/2
	local w = (vMax.x - vMin.x)/2
	local originY = vOrigin.y
	local originX = vOrigin.x
	
	local val = 0
	local base = (x - originX)/w
	if base < 0 then
		local absBase = abs((x - originX)/w)
		val = -1*h*( (absBase)^(1/order) ) + originY
	elseif base > 0 then
		val = h*( ((x - originX)/w)^(1/order) ) + originY
	end
	
	return val
end

function core.ExpDecay(x, yIntercept, xIntercept, order, bDebug)
	bDebug = bDebug or false

	local y = -1*( ((yIntercept)^(order)/xIntercept) * x ) ^ (1/order) + yIntercept
	
	if bDebug then
		Echo(format("ExpDecay(%g, %g, %g, %g)", x, yIntercept, xIntercept, order))
		Echo(format("  -1*( ((%g)^(%g)/%g) * %g ) ^ (1/%g) + %g", yIntercept, order, xIntercept, x, order, yIntercept))
	end
	
	return y
end

function core.ParabolicDecayFn(x, maxVal, zero, bDebug)
	local y = -1 * maxVal * (x/zero)^2 + maxVal
	
	if bDebug then
		Echo(format("ParabolicDecayFn(%g, %g, %g)", x, maxVal, zero))
		Echo(format("  -1 * %g * (x/%g)^2 + %g", maxVal, zero, maxVal))
	end
	
	return y
end

function core.ATanFn(x, vPoint, vOrigin, nLimit, bDebug)
	--Arctangent functions have a vertical asymptote of 0 and a horizontal asymptote of pi/2 and 
	--	increase in a convex slope between.  This function computes an ATan function based on your
	--	parameters and gives you the y value of the functions
	--
	--	vPoint is a static point on the line.
	--	vOrigin is the origin of the function.
	--	nLimit is the asymptote of the ATan function
	--
	--  This function will take those two points and the limit and comupte an ATan function that fits it
	
	--To get the right shape, we set our threshold and adjust the origin until the shape looks right
	--	Adding true to the end of the ATanFn() call will output the resultant function so you can graph it
	local bDebug = bDebug or false
	-- y = h * atan(x/w)*(2/pi)
	-- (0,0) (w,h/2) (inf, h)
	
	local h = nLimit
	local w = (vPoint.x-vOrigin.x) / tan(pi/2 * (vPoint.y-vOrigin.y)/nLimit)

	local y = h * atan((x-vOrigin.x)/w)*(2/pi) + vOrigin.y
	
	if bDebug then
		Echo(format("ATanFn(%g, (%g,%g), (%g,%g), %g)", x, vPoint.x, vPoint.y, vOrigin.x, vOrigin.y, nLimit))
		Echo(format("  %g * atan((x-%g)/%g)*(2/pi) + %g", h, vOrigin.x, w, vOrigin.y))
	end
	
	return y
end

function core.RandomReal(nMin, nMax)
	nMin = nMin or 0
	nMax = nMax or 1
	return random() * (nMax - nMin) + nMin
end

function core.RotateVec2DRad(vector, radians)
	local x = vector.x * cos(radians) - vector.y * sin(radians)
	local y = vector.x * sin(radians) + vector.y * cos(radians)
	
	return Vector3.Create(x, y)
end

function core.RotateVec2D(vector, degrees)
	local radians = (degrees * pi) / 180
	return core.RotateVec2DRad(vector, radians)
end

function core.AngleBetween(vec1, vec2)
	local radians = acos(Vector3.Dot(Vector3.Normalize(vec1), Vector3.Normalize(vec2)))
	return radians
end

function core.RadToDeg(x)
	return x * 180 / pi
end

function core.DegToRad(x)
	return x * pi / 180
end

function core.MSToS(x)
	return x / 1000
end

function core.SToMS(x)
	return x * 1000
end

function core.MinToS(x)
	return x * 60
end

function core.MinToMS(x)
	return x * 60 * 1000
end

-- If value is within [low, high] keep it.
-- Otherwise return low or high, depending if the value is higher or lower.
function core.Clamp(val, low, high)
	local retVal = val
	if low <= high then
		if low ~= nil and retVal < low then
			retVal = low
		end	
		
		if high ~= nil and retVal > high then
			retVal = high
		end
	end
	
	return retVal
end

