--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs special keys for property tables which connect event listeners to
	an instance.
]]

local Types = require("../Types")
local External = require("../Externals/External")

local keyCache: {[string]: Types.SpecialKey} = {}

local function OnEvent(
	eventName: string
): Types.SpecialKey
	local key = keyCache[eventName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "OnEvent",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				callback: unknown,
				applyTo: any
			)
				if type(callback) ~= "function" then
					External.logError("invalidEventHandler", nil, eventName)
				else
					table.insert(scope, External.connectEvent(applyTo, eventName, callback :: any))
				end
			end
		}
		keyCache[eventName] = key
	end
	return key
end

return OnEvent
