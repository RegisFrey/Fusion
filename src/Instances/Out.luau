--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs special keys for property tables which write property values to
	a Value state object.
]]

local Types = require("../Types")
local External = require("../Externals/External")

local keyCache: {[string]: Types.SpecialKey} = {}

local function Out(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "Out",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: any
			)
				-- TODO: better validation for Value objects
				if typeof(value) ~= "table" or (value :: any).kind ~= "State" or typeof((value :: any).set) ~= "function" then
					External.logError("invalidOutProperty", nil, propertyName)
				else
					local value = value :: Types.Value<unknown>
					table.insert(scope, External.observeChanges(applyTo, propertyName, function()
						value:set(External.getProperty(applyTo, propertyName))
					end))
				end
			end
		}
		keyCache[propertyName] = key
	end
	return key
end

return Out
