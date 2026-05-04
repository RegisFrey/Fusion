--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Types = require("../Types")
local External = require("../Externals/External")

local keyCache: {[string]: Types.SpecialKey} = {}

local function OnChange(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "OnChange",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				callback: unknown,
				applyTo: any
			)
				if typeof(callback) ~= "function" then
					External.logError("invalidChangeHandler", nil, propertyName)
				else
					local callback = callback :: (...unknown) -> (...unknown)
					table.insert(scope, External.observeChanges(applyTo, propertyName, function()
						callback(External.getProperty(applyTo, propertyName))
					end))
				end
			end
		}
		keyCache[propertyName] = key
	end
	return key
end

return OnChange
