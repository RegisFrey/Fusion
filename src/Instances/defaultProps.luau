--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.
]]

return {
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},

	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Active = true,
	},

	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		PixelsPerStud = 50,
	},

	Frame = {
		BorderSizePixel = 0,
	},

	ScrollingFrame = {
		BorderSizePixel = 0,
	},

	TextLabel = {
		BorderSizePixel = 0,
	},

	TextButton = {
		BorderSizePixel = 0,
		AutoButtonColor = false,
	},

	TextBox = {
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
	},

	ImageLabel = {
		BorderSizePixel = 0,
	},

	ImageButton = {
		BorderSizePixel = 0,
		AutoButtonColor = false,
	},

	ViewportFrame = {
		BorderSizePixel = 0,
	},

	VideoFrame = {
		BorderSizePixel = 0,
	},

	CanvasGroup = {
		BorderSizePixel = 0,
	},

	SpawnLocation = {
		Duration = 0,
	},

	BoxHandleAdornment = {
		ZIndex = 0,
	},
	ConeHandleAdornment = {
		ZIndex = 0,
	},
	CylinderHandleAdornment = {
		ZIndex = 0,
	},
	ImageHandleAdornment = {
		ZIndex = 0,
	},
	LineHandleAdornment = {
		ZIndex = 0,
	},
	SphereHandleAdornment = {
		ZIndex = 0,
	},
	WireframeHandleAdornment = {
		ZIndex = 0,
	},

	Part = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	TrussPart = {
		Anchored = true,
		Size = Vector3.one * 2,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	MeshPart = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	CornerWedgePart = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	VehicleSeat = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},
}
