--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler
--[[
	The entry point for the Fusion library.
]]

local Types = require("./Types")
local External = require("./Externals/External")

type Fusion = Types.Fusion

export type Animatable = Types.Animatable
export type UsedAs<T> = Types.UsedAs<T>
export type Child = Types.Child
export type Computed<T> = Types.Computed<T>
export type Contextual<T> = Types.Contextual<T>
export type GraphObject = Types.GraphObject
export type For<KO, VO> = Types.For<KO, VO>
export type Observer = Types.Observer
export type PropertyTable = Types.PropertyTable
export type Scope<Constructors = Fusion> = Types.Scope<Constructors>
export type ScopedObject = Types.ScopedObject
export type SpecialKey = Types.SpecialKey
export type Spring<T> = Types.Spring<T>
export type StateObject<T> = Types.StateObject<T>
export type Task = Types.Task
export type Tween<T> = Types.Tween<T>
export type Use = Types.Use
export type Value<T, S = T> = Types.Value<T, S>
export type Version = Types.Version
export type TweenInfo = Types.TweenInfo

if game then
	local RobloxExternal = require("./Externals/Roblox/RobloxExternal")
	External.setExternalProvider(RobloxExternal)
else
	local WebExternal = require("./Externals/Web/WebExternal")
	External.setExternalProvider(WebExternal)
	-- For now web is our only other target
	-- so we can condition on game.
	-- but it'd be good to have a better way of choosing
	-- or providing an External
	-- perhaps we just make user need to call this?
end

local FusionTable = {
	-- General
	version = { major = 0, minor = 4, isRelease = false },
	Contextual = require("./Utility/Contextual"),
	Safe = require("./Utility/Safe"),

	-- Memory
	deriveScope = require("./Memory/deriveScope"),
	doCleanup = require("./Memory/doCleanup"),
	innerScope = require("./Memory/innerScope"),
	insert = require("./Memory/insert"),
	scoped = require("./Memory/scoped"),

	-- Graph
	Observer = require("./Graph/Observer"),

	-- State
	Computed = require("./State/Computed"),
	ForKeys = require("./State/ForKeys") :: Types.ForKeysConstructor,
	ForPairs = require("./State/ForPairs") :: Types.ForPairsConstructor,
	ForValues = require("./State/ForValues") :: Types.ForValuesConstructor,
	peek = require("./State/peek"),
	Value = require("./State/Value"),

	-- Base API
	New = require("./Instances/New"),
	Child = require("./Instances/Child"),

	-- Animation
	Tween = require("./Animation/Tween"),
	Spring = require("./Animation/Spring"),
	TweenInfo = require("./Animation/TweenService").TweenInfo,
	EasingStyle = require("./Animation/TweenService").EasingStyle,
	EasingDirection = require("./Animation/TweenService").EasingDirection,
}

-- Mixin platform-specific special keys and behaviors
local coreSpecialKeys = require("./Instances/defaultSpecialKeys")
for name, value in pairs(coreSpecialKeys) do
	FusionTable[name] = value
end

for name, value in pairs(External.getSpecialKeys()) do
	FusionTable[name] = value
end

local Fusion: Fusion = table.freeze(FusionTable :: any)

return Fusion
