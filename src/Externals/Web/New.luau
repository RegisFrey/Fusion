local WebExternal = require("./WebExternal")
local Types = require("../../Types")
local External = require("../External")
local Observer = require("@fusion/Graph/Observer")
local peek = require("@fusion/State/peek")
local castToState = require("@fusion/State/castToState")
local applyInstanceProps = require("./applyInstanceProps")
-- our web based new is different:
-- No `Instance` type dependencies
-- No redundant instances (we are creating them on the HTML side)

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
