local WebExternal = require("./WebExternal")
local Types = require("@self/../../Types")
local External = require("@self/../External")
local Observer = require("@fusion/Graph/Observer")
local peek = require("@fusion/State/peek")
local castToState = require("@fusion/State/castToState")

-- our web based new is different:
-- No `Instance` type dependencies
-- No redundant instances (we are creating them on the HTML side)

-- our apply property is different
local function applyProperty(instance, key, value)
	-- Handling parenting independently since HTML parentElement is read-only
	if key == "Parent" or key == "parent" then
		WebExternal.setParent(instance, value)
	else
		WebExternal.setProperty(instance, key, value)
	end
end

-- The Roblox version of this handles more special keys
-- so we definitely will have some issues there
-- but the Roblox one is also very Instance / Instance API specific
local function applyInstanceProps(
	scope: Types.Scope<unknown>,
	props: Types.PropertyTable,
	applyTo: any -- HTMLElement?
)
	for key, value in pairs(props) do
		if type(key) == "table" and key.type == "SpecialKey" then
			key:apply(scope, value, applyTo)
		else
			local state = castToState(value)
			if state then
				table.insert(
					scope,
					Observer(value):onChange(function()
						applyProperty(applyTo, key, peek(value))
					end)
				)
				applyProperty(applyTo, key, peek(value))
			else
				applyProperty(applyTo, key, value)
			end
		end
	end
end

-- I've refactored the main New to match this one
-- e.g. moved env specific parts to createInstance
-- once we resolve the above functions
-- vs their equivalents in src/Instances/applyInstanceProps.luau
-- we can drop this bespoke New in favor of the External
local function New(scope, className)
	-- This might look appealing to try and cache. But please don't. The scope
	-- upvalue is shared between the two curried function calls, so this will
	-- open incredible cross-codebase wormholes like you've never seen before.
	return function(props)
		local instance = External.createInstance(scope, className, props)
		table.insert(scope, instance)
		applyInstanceProps(scope, props, instance)
		return instance
	end
end

return New
