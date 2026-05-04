local Types = require("@self/../../Types")
local External = require("@self/../External")
local Observer = require("@fusion/Graph/Observer")
local peek = require("@fusion/State/peek")
local castToState = require("@fusion/State/castToState")
local doCleanup = require("@fusion/Memory/doCleanup")
local WebExternal = require("./init")

local EXPERIMENTAL_AUTO_NAMING = false

return {
	type = "SpecialKey",
	kind = "Children",
	stage = "descendants",
	apply = function(self, scope, value, applyTo)
		local newParented = {}
		local oldParented = {}
	
		local newScopes = {}
		local oldScopes = {}
	
		local function updateChildren()
			oldParented, newParented = newParented, oldParented
			oldScopes, newScopes = newScopes, oldScopes
	
			local function processChild(child, autoName)
				local childType = type(child)
	
				-- Web modification: check for table with _jsElement instead of "Instance"
				if childType == "table" and child._native ~= nil then
					newParented[child] = true
					if oldParented[child] == nil then
						WebExternal.setParent(child, applyTo)
					else
						oldParented[child] = nil
					end
	
					if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
						WebExternal.setProperty(child, "Name", autoName)
					end
	
				elseif castToState(child) then
					local value = peek(child)
					if value ~= nil then
						processChild(value, autoName)
					end
	
					local childScope = oldScopes[child]
					if childScope == nil then
						childScope = {}
						Observer(childScope, child):onChange(updateChildren)
					else
						oldScopes[child] = nil
					end
	
					newScopes[child] = childScope
	
				elseif childType == "table" then
					for key, subChild in pairs(child) do
						local keyType = type(key)
						local subAutoName = nil
	
						if keyType == "string" then
							subAutoName = key
						elseif keyType == "number" and autoName ~= nil then
							subAutoName = autoName .. "_" .. key
						end
	
						processChild(subChild, subAutoName)
					end
	
				else
					External.logWarn("unrecognisedChildType", childType)
				end
			end
	
			if value ~= nil then
				processChild(value)
			end
	
			for oldInstance in pairs(oldParented) do
				WebExternal.setParent(oldInstance, nil)
			end
			table.clear(oldParented)
	
			for oldState, childScope in pairs(oldScopes) do
				doCleanup(childScope)
			end
			table.clear(oldScopes)
		end
	
		table.insert(scope, function()
			value = nil
			updateChildren()
		end)
	
		updateChildren()
	end
}
