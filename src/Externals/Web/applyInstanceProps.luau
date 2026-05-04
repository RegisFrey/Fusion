local web = require("@web")
-- bit odd to be importing External inside an external
local External = require("../External")
local WebExternal = require("./WebExternal")
local Types = require("../../Types")
local External = require("../External")
local Observer = require("@fusion/Graph/Observer")
local peek = require("@fusion/State/peek")
local castToState = require("@fusion/State/castToState")

-- our apply property is different
local function applyProperty(instance, key, value)
	-- Handling parenting independently since HTML parentElement is read-only
	if key == "Parent" or key == "parent" then
		External.setParent(instance, value)
	else
		External.setProperty(instance, key, value)
	end
	-- How can we make this more generic to External?
	-- e.g. should External be providing applyProperty and then applyInstanceProps is more generic and shared using only External.* functions.
end

--
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

return applyInstanceProps
