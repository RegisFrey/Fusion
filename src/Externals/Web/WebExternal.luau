local External = require("../External")
local web = require("./bridge")

local WebExternal = {}

WebExternal.policies = {
	allowWebLinks = true,
}

WebExternal.specialKeys = {}

function WebExternal.createInstance(scope, className, props)
	local native = web.createElement(className)

	-- TODO: Q: Why wrapping this in a table vs returning directly?
	-- I know we are using `_native` to detect it's an HTML element
	-- but can't there be a better way?
	-- e.g. what is actual shape of the web.createElement return
	-- and can't we use something about that shape to detect
	-- then we can cut this indirection / distracting noise.
	return {
		_native = native,
	}
end

function WebExternal.applyProperty(instance, key, value)
	if key == "Parent" or key == "parent" then
		WebExternal.setParent(instance, value)
	else
		web.setProperty(instance._native, key, value)
	end
end

function WebExternal.getProperty(instance, key)
	return web.getProperty(instance._native, key)
end

function WebExternal.setParent(instance, parent)
	local parentNative = if type(parent) == "table" then parent._native else parent
	web.setParent(instance._native, parentNative)
end

function WebExternal.connectEvent(instance, eventName, callback)
	return web.addEventListener(instance._native, eventName, callback)
end

function WebExternal.observeChanges(instance, propertyName, callback)
	return web.observeProperty(instance._native, propertyName, callback)
end

function WebExternal.isInstance(value)
	return type(value) == "table" and value._native ~= nil
end

function WebExternal.doTaskImmediate(resume)
	if type(web.queueMicrotask) == "function" then
		web.queueMicrotask(resume)
	else
		resume()
	end
end

function WebExternal.doTaskDeferred(resume)
	if type(web.setTimeout) == "function" then
		web.setTimeout(resume, 0)
	else
		resume()
	end
end

function WebExternal.doTaskAfter(seconds: number, callback: () -> ()): () -> ()
	local id = web.setTimeout(callback, seconds * 1000)
	return function()
		web.clearTimeout(id)
	end
end

function WebExternal.logErrorNonFatal(errorString)
	if web.console and web.console.error then
		web.console.error(errorString)
	else
		print("ERROR: " .. tostring(errorString))
	end
end

WebExternal.logWarn = function(msg)
	if web.console and web.console.warn then
		web.console.warn(msg)
	else
		print("WARN: " .. tostring(msg))
	end
end

local stopSchedulerFunc = nil

local function performUpdateStep()
	local timeInSeconds = 0
	if web.performance and web.performance.now then
		timeInSeconds = web.performance.now() / 1000
	else
		timeInSeconds = os.clock()
	end
	External.performUpdateStep(timeInSeconds)
end

function WebExternal.startScheduler()
	if stopSchedulerFunc ~= nil then
		return
	end

	if type(web.requestAnimationFrame) == "function" then
		local isRunning = true
		local function loop()
			if not isRunning then
				return
			end
			performUpdateStep()
			web.requestAnimationFrame(loop)
		end
		web.requestAnimationFrame(loop)

		stopSchedulerFunc = function()
			isRunning = false
		end
	else
		-- Fallback if no web env
		stopSchedulerFunc = function() end
	end
end

function WebExternal.stopScheduler()
	if stopSchedulerFunc ~= nil then
		stopSchedulerFunc()
		stopSchedulerFunc = nil
	end
end

return WebExternal
