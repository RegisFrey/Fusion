--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Common special keys shared across all platforms.
]]

return {
	Children = require("@self/Children"),
	OnEvent = require("@self/OnEvent"),
	OnChange = require("@self/OnChange"),
	Out = require("@self//Out"),
}
