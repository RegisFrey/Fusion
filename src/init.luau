--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler
--[[
	The entry point for the Fusion library.
]]

local Types = require("@self/Types")
local External = require("@self/Externals/External")

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

if game then
	local RobloxExternal = require("@self/Externals/Roblox/RobloxExternal")
	External.setExternalProvider(RobloxExternal)
else
	local WebExternal = require("@self/Externals/Web/WebExternal")
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
	Contextual = require("@self/Utility/Contextual"),
	Safe = require("@self/Utility/Safe"),

	-- Memory
	deriveScope = require("@self/Memory/deriveScope"),
	doCleanup = require("@self/Memory/doCleanup"),
	innerScope = require("@self/Memory/innerScope"),
	insert = require("@self/Memory/insert"),
	scoped = require("@self/Memory/scoped"),

	-- Graph
	Observer = require("@self/Graph/Observer"),

	-- State
	Computed = require("@self/State/Computed"),
	ForKeys = require("@self/State/ForKeys") :: Types.ForKeysConstructor,
	ForPairs = require("@self/State/ForPairs") :: Types.ForPairsConstructor,
	ForValues = require("@self/State/ForValues") :: Types.ForValuesConstructor,
	peek = require("@self/State/peek"),
	Value = require("@self/State/Value"),

	-- Base API
	New = require("@self/Instances/New"),
	Child = require("@self/Instances/Child"),

	-- Animation
	Tween = require("@self/Animation/Tween"),
	Spring = require("@self/Animation/Spring"),
}

-- Mixin platform-specific special keys and behaviors
for name, value in pairs(External.getSpecialKeys()) do
	FusionTable[name] = value
end

local Fusion: Fusion = table.freeze(FusionTable :: any)

return Fusion
