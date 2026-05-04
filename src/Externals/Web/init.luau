local web = require("@web")
-- The @web require is an alias that our bundler will replace
-- with a table of exposed web functions / constants
-- perhaps we provide a stub in files for proper typing / autocomplete
-- then bundler connects that stub to a proper bridge variable
local External = require("@self/../External")

local WebExternal = {}

WebExternal.policies = {
	allowWebLinks = true,
}

WebExternal.specialKeys = {
	New = require("./New"),
	Children = require("./Children"),
	OnEvent = require("./OnEvent"),
}

function WebExternal.createInstance(scope, className, props)
	local native = web.createElement(className)

	return {
		_native = native,
	}
end

function WebExternal.setProperty(instance, key, value)
	web.setProperty(instance._native, key, value)
end

function WebExternal.setParent(instance, parent)
	local parentNative = if type(parent) == "table" then parent._native else parent
	web.setParent(instance._native, parentNative)
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
