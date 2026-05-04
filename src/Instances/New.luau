--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Types = require("../Types")
local External = require("../Externals/External")
local applyInstanceProps = require("./applyInstanceProps")

-- TODO: RESOLVE/IMPROVE: Typing gets tricky, e.g. RobloxExternal returns an Instance. WebExternal should return the HTMLElement.
type Component = (Types.PropertyTable) -> any

local function New(scope: Types.Scope<unknown>, className: string)
	-- This might look appealing to try and cache. But please don't. The scope
	-- upvalue is shared between the two curried function calls, so this will
	-- open incredible cross-codebase wormholes like you've never seen before.
	return function(props: Types.PropertyTable): any
		local instance = External.createInstance(scope, className, props)
		table.insert(scope, instance)
		applyInstanceProps(scope, props, instance)
		return instance
	end
end

return New
