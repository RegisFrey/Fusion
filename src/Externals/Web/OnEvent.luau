local web = require("@web")
local Types = require("@self/../../Types")
local External = require("@self/../External")

local keyCache = {}

local function OnEvent(eventName)
	local key = keyCache[eventName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "OnEvent",
			stage = "observer",
			apply = function(self, scope, callback, applyTo)
				if type(callback) ~= "function" then
					External.logError("invalidEventHandler", nil, eventName)
					return
				end

				-- I think the _native tracking might be both confusing and overly defensive
				if applyTo._native and web then
					-- Luau-web allows passing functions directly as callbacks
					applyTo._native.addEventListener(domEventName, callback)

					table.insert(scope, function()
						applyTo._native.removeEventListener(domEventName, callback)
					end)
				end
			end,
		}
		keyCache[eventName] = key
	end
	return key
end

return OnEvent
