--!strict
--!nolint LocalUnused
--!nolint LocalShadow

--[[
	Roblox implementation for Fusion's abstract provider layer.
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Types = require("@self/../../Types")
local External = require("@self/../External")
local defaultProps = require("@self/defaultProps")

local RobloxExternal = {}

RobloxExternal.policies = {
	allowWebLinks = RunService:IsStudio(),
}

RobloxExternal.specialKeys = {
	Attribute = require("@self/Attribute"),
	AttributeChange = require("@self/AttributeChange"),
	AttributeOut = require("@self/AttributeOut"),
	Tag = require("@self/Tag"),
	Hydrate = require("@self/Hydrate"),
}

--[[
   Sends an immediate task to the external provider. Throws if none is set.
]]
function RobloxExternal.doTaskImmediate(resume: () -> ())
	task.spawn(resume)
end

--[[
	Sends a deferred task to the external provider. Throws if none is set.
]]
function RobloxExternal.doTaskDeferred(resume: () -> ())
	task.defer(resume)
end

--[[
	Errors in a different thread to preserve the flow of execution.
]]
function RobloxExternal.logErrorNonFatal(errorString: string)
	task.spawn(error, errorString, 0)
end

--[[
	Shows a warning message in the output.
]]
RobloxExternal.logWarn = warn

--[[
	Sends an update step to Fusion using the Roblox clock time.
]]
local function performUpdateStep()
	External.performUpdateStep(os.clock())
end

--[[
	Binds Fusion's update step to RunService step events.
]]
local stopSchedulerFunc = nil :: (() -> ())?
function RobloxExternal.startScheduler()
	if stopSchedulerFunc ~= nil then
		return
	end
	if RunService:IsClient() then
		-- In cases where multiple Fusion modules are running simultaneously,
		-- this prevents collisions.
		local id = "FusionUpdateStep_" .. HttpService:GenerateGUID()
		RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, performUpdateStep)
		stopSchedulerFunc = function()
			RunService:UnbindFromRenderStep(id)
		end
	else
		local connection = RunService.Heartbeat:Connect(performUpdateStep)
		stopSchedulerFunc = function()
			connection:Disconnect()
		end
	end
end

--[[
	Unbinds Fusion's update step from RunService step events.
]]
function RobloxExternal.stopScheduler()
	if stopSchedulerFunc ~= nil then
		stopSchedulerFunc()
		stopSchedulerFunc = nil
	end
end

function RobloxExternal.createInstance(
	scope: Types.Scope<unknown>,
	className: string,
	props: Types.PropertyTable
): Instance
	local ok, instance = pcall(Instance.new, className)
	if not ok then
		External.logError("cannotCreateClass", nil, className)
	end

	local classDefaults = defaultProps[className]
	if classDefaults ~= nil then
		for defaultProp, defaultValue in pairs(classDefaults) do
			(instance :: any)[defaultProp] = defaultValue
		end
	end
	return instance
end

local function setProperty_unsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(instance: Instance, property: string)
	(instance :: any)[property] = (instance :: any)[property]
end

function RobloxExternal.applyProperty(instance: Instance, key: string, value: any)
	local success, err = pcall(setProperty_unsafe, instance, key, value)

	if not success then
		if not pcall(testPropertyAssignable, instance, key) then
			External.logErrorNonFatal("cannotAssignProperty", nil, instance.ClassName, key)
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[key])

			if givenType == expectedType then
				-- We can't use parseError here easily without importing it,
				-- but External.logErrorNonFatal expects a string.
				External.logErrorNonFatal("propertySetError", nil, tostring(err))
			else
				External.logErrorNonFatal("invalidPropertyType", nil, instance.ClassName, key, expectedType, givenType)
			end
		end
	end
end

function RobloxExternal.getProperty(instance: Instance, key: string): any
	return (instance :: any)[key]
end

function RobloxExternal.setParent(instance: Instance, parent: Instance?)
	instance.Parent = parent
end

function RobloxExternal.connectEvent(instance: Instance, eventName: string, callback: (...any) -> ()): () -> ()
	local connection = (instance :: any)[eventName]:Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function RobloxExternal.observeChanges(instance: Instance, propertyName: string, callback: () -> ()): () -> ()
	local connection = instance:GetPropertyChangedSignal(propertyName):Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function RobloxExternal.isInstance(value: any): boolean
	return typeof(value) == "Instance"
end

return RobloxExternal
