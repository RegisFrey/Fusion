--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.

	If a key is used twice, an error will be thrown. This is done to avoid
	double assignments or double bindings. However, some special keys may want
	to enable such assignments - in which case unique keys should be used for
	each occurrence.
]]

local Types = require("../Types")
local External = require("../Externals/External")
-- Logging
-- Memory
local checkLifetime = require("../Memory/checkLifetime")
-- Graph
local Observer = require("../Graph/Observer")
-- State
local castToState = require("../State/castToState")
local peek = require("../State/peek")
-- Utility
local xtypeof = require("../Utility/xtypeof")

local function applyProperty(instance: any, property: string, value: unknown)
	External.applyProperty(instance, property, value)
end

local function bindProperty(scope: Types.Scope<unknown>, instance: any, property: string, value: Types.UsedAs<unknown>)
	if castToState(value) then
		local value = value :: Types.StateObject<unknown>
		checkLifetime.bOutlivesA(
			scope,
			instance,
			value.scope,
			value.oldestTask,
			checkLifetime.formatters.boundProperty,
			property
		)
		-- value is a state object - bind to changes
		Observer(scope, value :: any):onBind(function()
			if string.lower(property) == "parent" then
				External.setParent(instance, peek(value))
			else
				applyProperty(instance, property, peek(value))
			end
		end)
	else
		-- value is a constant - assign once only
		if string.lower(property) == "parent" then
			External.setParent(instance, value)
		else
			applyProperty(instance, property, value)
		end
	end
end

local function applyInstanceProps(scope: Types.Scope<unknown>, props: Types.PropertyTable, applyTo: any)
	local specialKeys = {
		self = {} :: { [Types.SpecialKey]: unknown },
		descendants = {} :: { [Types.SpecialKey]: unknown },
		ancestor = {} :: { [Types.SpecialKey]: unknown },
		observer = {} :: { [Types.SpecialKey]: unknown },
	}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			-- we shouldn't check parent here:
			-- if string.lower(key :: string) ~= "parent" then
			-- because bindProperty already handles parent setting
			bindProperty(scope, applyTo, key :: string, value)
		elseif keyType == "SpecialKey" then
			local stage = (key :: Types.SpecialKey).stage
			local keys = specialKeys[stage]
			if keys == nil then
				External.logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			External.logError("unrecognisedPropertyKey", nil, keyType)
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(scope, value, applyTo)
	end

	-- we already handle Parent in bindProperty and keyType = string
	-- if props.Parent ~= nil then
	-- 	bindProperty(scope, applyTo, "Parent", props.Parent)
	-- end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(scope, value, applyTo)
	end
end

return applyInstanceProps
