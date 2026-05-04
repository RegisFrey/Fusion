--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local External = require(Fusion.Externals.External)

local SpecExternal = {}

SpecExternal.policies = {
	allowWebLinks = true,
}

local queue = {} :: { thread }

--[[
   Sends an immediate task to the external scheduler. Throws if none is set.
]]
function SpecExternal.doTaskImmediate(resume: () -> ())
	table.insert(queue, 1, coroutine.running())
	table.insert(queue, 1, coroutine.create(resume))
	coroutine.yield()
end

--[[
	Sends a deferred task to the external scheduler. Throws if none is set.
]]
function SpecExternal.doTaskDeferred(resume: () -> ())
	table.insert(queue, coroutine.create(resume))
end

function SpecExternal.deferSelfForTesting()
	table.insert(queue, coroutine.running())
	coroutine.yield()
end

--[[
	Errors in a different thread to preserve the flow of execution.
]]
function SpecExternal.logErrorNonFatal(errorString: string): ()
	-- silently discard
end

--[[
	Shows a warning message in the output.
]]
function SpecExternal.logWarn(errorString: string): ()
	-- silently discard
end

local doUpdateSteps = false

--[[
	Binds Fusion's update step to RunService step events.
]]
function SpecExternal.startScheduler()
	doUpdateSteps = true
end

--[[
	Unbinds Fusion's update step from RunService step events.
]]
function SpecExternal.stopScheduler()
	doUpdateSteps = false
end

--[[
	Unbinds Fusion's update step from RunService step events.
	Allows deterministic manually controlled scheduling during tests.
]]
function SpecExternal.step(currentTime: number)
	if doUpdateSteps then
		External.performUpdateStep(currentTime)
	end

	while true do
		local nextTask = table.remove(queue, 1)
		if nextTask == nil then
			break
		end
		local ok, result: string = coroutine.resume(nextTask)
		if not ok then
			warn("Error in spec scheduler: " .. result)
		end
	end
end

local defaultProps = require(Fusion.Externals.Roblox.defaultProps)

--
-- Instance methods
--

function SpecExternal.createInstance(scope: any, className: string, props: any): any
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

function SpecExternal.applyProperty(instance: any, key: string, value: any)
	local success, err = pcall(function()
		instance[key] = value
	end)

	if not success then
		-- We use a simplified version of RobloxExternal's logic here
		External.logErrorNonFatal("cannotAssignProperty", nil, instance.ClassName, key)
	end
end

function SpecExternal.getProperty(instance: any, key: string): any
	return instance[key]
end

function SpecExternal.setParent(instance: any, parent: any)
	instance.Parent = parent
end

function SpecExternal.connectEvent(instance: any, eventName: string, callback: (...any) -> ()): () -> ()
	local ok, event = pcall(function()
		return instance[eventName]
	end)
	if not ok or typeof(event) ~= "RBXScriptSignal" then
		External.logError("cannotConnectEvent", nil, instance.ClassName, eventName)
	end
	local connection = event:Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function SpecExternal.observeChanges(instance: any, propertyName: string, callback: () -> ()): () -> ()
	local ok, signal = pcall(instance.GetPropertyChangedSignal, instance, propertyName)
	if not ok then
		External.logError("cannotConnectChange", nil, instance.ClassName, propertyName)
	end
	local connection = signal:Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function SpecExternal.isInstance(value: any): boolean
	return typeof(value) == "Instance"
end

SpecExternal.specialKeys = {}

return SpecExternal
