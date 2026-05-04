--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Common special keys shared across all platforms.
]]

return {
	Children = require("./Children"),
	OnEvent = require("./OnEvent"),
	OnChange = require("./OnChange"),
	Out = require("./Out"),
}
