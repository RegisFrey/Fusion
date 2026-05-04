--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A shim for Roblox's TweenService, providing easing functions on all platforms.
	Easing functions are ported from the Godot engine's implementation, which
	matches Roblox's behavior.
]]

local EasingStyle = {
	Linear = 0,
	Quad = 1,
	Cubic = 2,
	Quart = 3,
	Quint = 4,
	Sine = 5,
	Back = 6,
	Bounce = 7,
	Elastic = 8,
	Exponential = 9,
	Circular = 10,
}

local EasingDirection = {
	In = 0,
	Out = 1,
	InOut = 2,
}

local Types = require("../Types")

export type EasingStyle = number
export type EasingDirection = number

export type TweenInfo = Types.TweenInfo

local TweenInfo = {}
TweenInfo.__index = TweenInfo

function TweenInfo.new(
	time: number?,
	easingStyle: EasingStyle?,
	easingDirection: EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?
): TweenInfo
	local self = setmetatable({}, TweenInfo)
	self.Time = time or 1
	self.EasingStyle = easingStyle or EasingStyle.Quad
	self.EasingDirection = easingDirection or EasingDirection.Out
	self.RepeatCount = repeatCount or 0
	self.Reverses = reverses or false
	self.DelayTime = delayTime or 0
	return (self :: any) :: TweenInfo
end

-- Math implementation
local PI = math.pi
local cos = math.cos
local sin = math.sin
local pow = math.pow
local sqrt = math.sqrt

local function bounce(t: number): number
	local n1 = 7.5625
	local d1 = 2.75
	if t < 1 / d1 then
		return n1 * t * t
	elseif t < 2 / d1 then
		t -= 1.5 / d1
		return n1 * t * t + 0.75
	elseif t < 2.5 / d1 then
		t -= 2.25 / d1
		return n1 * t * t + 0.9375
	else
		t -= 2.625 / d1
		return n1 * t * t + 0.984375
	end
end

local function getEasingValue(alpha: number, style: EasingStyle, direction: EasingDirection): number
	if style == EasingStyle.Linear then
		return alpha
	elseif style == EasingStyle.Sine then
		if direction == EasingDirection.In then
			return 1 - cos((alpha * PI) / 2)
		elseif direction == EasingDirection.Out then
			return sin((alpha * PI) / 2)
		elseif direction == EasingDirection.InOut then
			return -(cos(PI * alpha) - 1) / 2
		end
	elseif style == EasingStyle.Back then
		local c1 = 1.70158
		local c3 = c1 + 1
		if direction == EasingDirection.In then
			return c3 * alpha * alpha * alpha - c1 * alpha * alpha
		elseif direction == EasingDirection.Out then
			return 1 + c3 * (alpha - 1)^3 + c1 * (alpha - 1)^2
		elseif direction == EasingDirection.InOut then
			local c2 = c1 * 1.525
			if alpha < 0.5 then
				return ((2 * alpha)^2 * ((c2 + 1) * 2 * alpha - c2)) / 2
			else
				return ((2 * alpha - 2)^2 * ((c2 + 1) * (alpha * 2 - 2) + c2) + 2) / 2
			end
		end
	elseif style == EasingStyle.Quad then
		if direction == EasingDirection.In then
			return alpha * alpha
		elseif direction == EasingDirection.Out then
			return 1 - (1 - alpha) * (1 - alpha)
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return 2 * alpha * alpha
			else
				return 1 - (-2 * alpha + 2)^2 / 2
			end
		end
	elseif style == EasingStyle.Quart then
		if direction == EasingDirection.In then
			return alpha * alpha * alpha * alpha
		elseif direction == EasingDirection.Out then
			return 1 - (1 - alpha)^4
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return 8 * alpha^4
			else
				return 1 - (-2 * alpha + 2)^4 / 2
			end
		end
	elseif style == EasingStyle.Quint then
		if direction == EasingDirection.In then
			return alpha^5
		elseif direction == EasingDirection.Out then
			return 1 - (1 - alpha)^5
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return 16 * alpha^5
			else
				return 1 - (-2 * alpha + 2)^5 / 2
			end
		end
	elseif style == EasingStyle.Bounce then
		if direction == EasingDirection.In then
			return 1 - bounce(1 - alpha)
		elseif direction == EasingDirection.Out then
			return bounce(alpha)
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return (1 - bounce(1 - 2 * alpha)) / 2
			else
				return (1 + bounce(2 * alpha - 1)) / 2
			end
		end
	elseif style == EasingStyle.Elastic then
		if alpha == 0 or alpha == 1 then
			return alpha
		end
		local c4 = (2 * PI) / 3
		if direction == EasingDirection.In then
			return -2^(10 * alpha - 10) * sin((alpha * 10 - 10.75) * c4)
		elseif direction == EasingDirection.Out then
			return 2^(-10 * alpha) * sin((alpha * 10 - 0.75) * c4) + 1
		elseif direction == EasingDirection.InOut then
			local c5 = (2 * PI) / 4.5
			if alpha < 0.5 then
				return -(2^(20 * alpha - 10) * sin((20 * alpha - 11.125) * c5)) / 2
			else
				return (2^(-20 * alpha + 10) * sin((20 * alpha - 11.125) * c5)) / 2 + 1
			end
		end
	elseif style == EasingStyle.Exponential then
		if alpha == 0 or alpha == 1 then
			return alpha
		end
		if direction == EasingDirection.In then
			return 2^(10 * alpha - 10)
		elseif direction == EasingDirection.Out then
			return 1 - 2^(-10 * alpha)
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return 2^(20 * alpha - 10) / 2
			else
				return (2 - 2^(-20 * alpha + 10)) / 2
			end
		end
	elseif style == EasingStyle.Circular then
		if direction == EasingDirection.In then
			return 1 - sqrt(1 - alpha^2)
		elseif direction == EasingDirection.Out then
			return sqrt(1 - (alpha - 1)^2)
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return (1 - sqrt(1 - (2 * alpha)^2)) / 2
			else
				return (sqrt(1 - (-2 * alpha + 2)^2) + 1) / 2
			end
		end
	elseif style == EasingStyle.Cubic then
		if direction == EasingDirection.In then
			return alpha^3
		elseif direction == EasingDirection.Out then
			return 1 - (1 - alpha)^3
		elseif direction == EasingDirection.InOut then
			if alpha < 0.5 then
				return 4 * alpha^3
			else
				return 1 - (-2 * alpha + 2)^3 / 2
			end
		end
	end

	return alpha
end

local TweenService = {}
TweenService.EasingStyle = EasingStyle
TweenService.EasingDirection = EasingDirection
TweenService.TweenInfo = TweenInfo

function TweenService:GetValue(alpha: number, style: EasingStyle, direction: EasingDirection): number
	if game then
		return (game:GetService("TweenService") :: any):GetValue(alpha, style, direction)
	else
		return getEasingValue(alpha, style, direction)
	end
end

return TweenService
