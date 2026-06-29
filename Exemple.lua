--// Universal ESP Example using Iridescent UI Library
--// Adapted to be 100% Universal (No game-specific features, supports R6 & R15)


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/brskofdp/iridecent-ui/refs/heads/main/Source.lua"))()

--// Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Camera = Workspace.CurrentCamera
local Client = Players.LocalPlayer

--// UI Setup
local Window = Library:Window({
	Name = "Universal ESP",
})

local ESPTab = Window:Tab({
	Name = "Visuals",
	Image = "rbxassetid://18870359747", -- Visuals Icon
})

local ESPCategory = ESPTab:Category({
	Name = "Player ESP"
})

local PlayerESPSection = ESPCategory:Section({
	Name = "Settings",
	Side = "Left"
})

local ChamsSection = ESPCategory:Section({
	Name = "Chams & Colors",
	Side = "Right"
})

--// UI Elements Configuration
PlayerESPSection:Toggle({
	Name = "Player ESP",
	Flag = "PlayerESP",
	Default = true
})

PlayerESPSection:Toggle({
	Name = "Bounding Box",
	Flag = "PlayerBoundingBox",
	Default = true
})

PlayerESPSection:Dropdown({
	Name = "Box Style",
	Flag = "PlayerBoxStyle",
	Options = {"Solid", "Corner"},
	Default = "Solid"
})

PlayerESPSection:Toggle({
	Name = "Name",
	Flag = "PlayerName",
	Default = true
})

PlayerESPSection:Toggle({
	Name = "Health Bar",
	Flag = "PlayerHealthbar",
	Default = true
})

PlayerESPSection:Toggle({
	Name = "Health Text",
	Flag = "PlayerHealth",
	Default = false
})

PlayerESPSection:Toggle({
	Name = "Show Health If Damaged Only",
	Flag = "PlayerShowHealthIfDamaged",
	Default = false
})

PlayerESPSection:Toggle({
	Name = "Distance",
	Flag = "PlayerDistance",
	Default = true
})

PlayerESPSection:Toggle({
	Name = "Equipped Tool",
	Flag = "PlayerWeapon",
	Default = true
})

PlayerESPSection:Toggle({
	Name = "Look Angle",
	Flag = "PlayerLookAngle",
	Default = false
})

PlayerESPSection:Toggle({
	Name = "Skeleton",
	Flag = "PlayerSkeleton",
	Default = false
})

PlayerESPSection:Toggle({
	Name = "Offscreen Arrow",
	Flag = "PlayerOffscreen",
	Default = false
})

PlayerESPSection:Slider({
	Name = "Offscreen Radius",
	Flag = "PlayerOffscreenRadius",
	Min = 50,
	Max = 500,
	Default = 150
})

--// Chams & Colors Settings
ChamsSection:Toggle({
	Name = "Chams",
	Flag = "PlayerChams",
	Default = false
})

ChamsSection:Dropdown({
	Name = "Chams Style",
	Flag = "PlayerChamsStyle",
	Options = {"Solid", "Glow"},
	Default = "Solid"
})

ChamsSection:Slider({
	Name = "Chams Refresh Rate",
	Flag = "ChamsRefreshRate",
	Min = 0.1,
	Max = 5,
	Decimal = 1,
	Default = 1
})

ChamsSection:Colorpicker({
	Name = "Visible Box Color",
	Flag = "PlayerVisibleColor",
	Default = {Color3.fromRGB(0, 255, 120), 0}
})

ChamsSection:Colorpicker({
	Name = "Occluded Box Color",
	Flag = "PlayerOccludedColor",
	Default = {Color3.fromRGB(255, 0, 50), 0}
})

ChamsSection:Colorpicker({
	Name = "Chams Visible Color",
	Flag = "PlayerChamsVisibleColor",
	Default = {Color3.fromRGB(0, 255, 120), 0.5}
})

ChamsSection:Colorpicker({
	Name = "Chams Occluded Color",
	Flag = "PlayerChamsOccludedColor",
	Default = {Color3.fromRGB(255, 0, 50), 0.5}
})

ChamsSection:Colorpicker({
	Name = "High Health Color",
	Flag = "PlayerHigherHealthColor",
	Default = {Color3.fromRGB(0, 255, 0), 0}
})

ChamsSection:Colorpicker({
	Name = "Low Health Color",
	Flag = "PlayerLowerHealthColor",
	Default = {Color3.fromRGB(255, 0, 0), 0}
})

--// Thread Manager
local Threads = {
	Render = {},
	Entities = {},
	Character = {},
	Input = {},
}
Threads.__index = Threads

function Threads:Run()
	local Success, Error = pcall(self.Function)
	if not Success and Error then
		warn("Error: " .. tostring(Error))
	end
end

function Threads.New(Name, Function, Priority)
	local Thread = setmetatable({
		Name = Name,
		Function = Function,
		Priority = Priority or "Render",
	}, Threads)

	local Index = #Threads[Thread.Priority] + 1
	Threads[Thread.Priority][Index] = Thread
	return Thread
end

--// Math Helpers
local Math = {}
function Math.RoundToIncrement(value, increment)
	return math.floor(value / increment + 0.5) * increment
end
function Math.FloorVector(vector)
	return Vector2.new(math.floor(vector.X), math.floor(vector.Y))
end

--// Visuals Drawing Helpers
local Visuals = { Hitmarkers = {} }
Visuals.ESPSpace = Instance.new("ScreenGui")
Visuals.ESPSpace.Parent = CoreGui
Visuals.ESPSpace.IgnoreGuiInset = true
Visuals.ESPSpace.DisplayOrder = 0
Visuals.ESPSpace.Name = "ESP Space"

Visuals.LOSFrame = Instance.new("Frame")
Visuals.LOSFrame.AnchorPoint = Vector2.new(0.5, 0)
Visuals.LOSFrame.BackgroundTransparency = 1
Visuals.LOSFrame.Size = UDim2.new(0, 500, 0, 500)
Visuals.LOSFrame.Parent = Visuals.ESPSpace
Visuals.LOSFrame.Position = UDim2.new(0.5, 0, 0, 100)

Visuals.LOSLayout = Instance.new("UIListLayout")
Visuals.LOSLayout.Parent = Visuals.LOSFrame
Visuals.LOSLayout.Padding = UDim.new(0, 3)

function Visuals.DrawLine()
	local Line = Drawing.new("Line")
	Line.Thickness = 1
	Line.Color = Color3.fromRGB(255, 255, 255)
	Line.Transparency = 1
	Line.Visible = false
	return Line
end

function Visuals.DrawOutline()
	local Line = Drawing.new("Line")
	Line.Thickness = 3
	Line.Color = Color3.fromRGB(0, 0, 0)
	Line.Transparency = 1
	Line.Visible = false
	return Line
end

function Visuals.IsPartVisible(Part)
	if not Part then return false end
	local Character = Client.Character
	local IgnoreList = {Character, Camera, Part.Parent}
	
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Blacklist
	Params.FilterDescendantsInstances = IgnoreList
	
	local Origin = Camera.CFrame.Position
	local Direction = Part.Position - Origin
	local Result = Workspace:Raycast(Origin, Direction, Params)
	
	return Result == nil
end

function Visuals.GetDistanceFromCenter(Position)
	local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
	if not OnScreen then return 9e9 end
	local ViewportSize = Camera.ViewportSize
	local Center = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
	return (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
end

--// Globals setup for UI compatibility
local Globals = {
	LastArmorCheck = tick(),
	ArmorIds = {},
	ArmorNames = {},
	FlaggedStaff = {}
}

function Globals.ApplyTextStroke(Object)
	local NewStroke = Instance.new("UIStroke")
	NewStroke.Parent = Object
	NewStroke.Thickness = 1
	NewStroke.Color = Color3.fromRGB(0, 0, 0)
	return NewStroke
end

function Globals:Tween(instance, tweenInfo, propertyTable)
	local NewTween = TweenService:Create(instance, tweenInfo, propertyTable)
	NewTween:Play()
	return NewTween
end

function Globals:Instance(Class, Properties)
	local Element = Instance.new(Class)
	for Key, Value in pairs(Properties) do 
		Element[Key] = Value
	end
	return Element
end

--// Entity Class definition
local EntityClass = {
	Main = {
		Cache = {},
		Functions = {},
	},
	Global = {},
	Flags = {},
	AnimationSpeed = 0.15,
	Font = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold),
	FontSize = 10,
	IgnoreNames = {
		["HumanoidRootPart"] = true
	},
	WeaponImages = {},
	ItemList = {}
}
EntityClass.Main.Functions.__index = EntityClass.Main.Functions

function EntityClass.Global:Create(Pointer, Data)
	local Object = setmetatable({
		Pointer = Pointer,
		Class = Data.Class,
		ClassType = Data.ClassType,
		Name = Pointer.Name,
		Adornments = {},
		LastUpdate = tick(),
		LastChamsRefresh = tick(),
		LastHealth = 0,
	}, EntityClass.Main.Functions)

	Object.Components = Object:CreateComponents()
	EntityClass.Main.Cache[Pointer] = Object
	return Object
end

function EntityClass.Main.Functions:Remove()
	local Components = self.Components
	if Components.LookAngle then Components.LookAngle:Remove() end
	if Components.LookAngleOutline then Components.LookAngleOutline:Remove() end

	for Index, Value in pairs(Components) do 
		if Index == "Corners" or Index == "LookAngle" or Index == "Skeleton" or Index == "LookAngleOutline" then continue end
		Value:Destroy()
	end

	if Components.Corners then
		for _, Value in pairs(Components.Corners) do 
			Value:Destroy()
		end
	end

	if Components.Skeleton then
		for _, Value in pairs(Components.Skeleton) do 
			Value:Remove()
		end
	end

	for _, AdornmentList in pairs(self.Adornments) do
		for _, Adornment in pairs(AdornmentList) do
			Adornment:Destroy()
		end
	end

	EntityClass.Main.Cache[self.Pointer] = nil
end

function EntityClass.Main.Functions:OnCharacterAdded(Character)
	self.CachedArmor = {}
	self.CachedItem = nil
end

function EntityClass.Main.Functions:CreateComponents()
	local Components = {}

	--// Box Outline
	Components.BoxOutline = Globals:Instance("Frame", {
		Parent = Visuals.ESPSpace,
		Visible = false,
		BackgroundTransparency = 1,
		ZIndex = 2,
	})

	Components.BoxOutlineStroke = Globals:Instance("UIStroke", {
		Parent = Components.BoxOutline,
		Thickness = 3,
		Color = Color3.fromRGB(0, 0, 0),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	--// Box Inline 
	Components.BoxInline = Globals:Instance("Frame", { 
		Parent = Components.BoxOutline,
		Visible = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 0, -1),
		Size = UDim2.new(1, 2, 1, 2),
		ZIndex = 2
	})

	Components.BoxInlineStroke = Globals:Instance("UIStroke", { 
		Parent = Components.BoxInline, 
		LineJoinMode = Enum.LineJoinMode.Miter, 
		Color = Color3.fromRGB(255, 255, 255)
	})

	--// Corners
	Components.FakeCornerBox = Globals:Instance("Frame", { 
		Parent = Components.BoxOutline, 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 4, 1, 2),
		Position = UDim2.new(0, -2, 0, -1),
	})

	local Corners = {}
	local CornerWidth = 0.3
	local CornerHeight = 0.3
	local Thickness = 1
	local Offset = -Thickness

	--// Inline Corners
	Corners[1] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(CornerWidth, 0, 0, Thickness), Position = UDim2.new(0, 0, 0, Offset), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[2] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(0, Thickness, CornerHeight, 0), Position = UDim2.new(0, 0, 0, Offset), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[3] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(CornerWidth, 0, 0, Thickness), Position = UDim2.new(1 - CornerWidth, 0, 0, Offset), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[4] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(0, Thickness, CornerHeight, 0), Position = UDim2.new(1, -Thickness, 0, Offset), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[5] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(0, Thickness, CornerHeight, 0), Position = UDim2.new(0, 0, 1 - CornerHeight, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[6] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(CornerWidth, 0, 0, Thickness), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[7] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(0, Thickness, CornerHeight, 0), Position = UDim2.new(1, -Thickness, 1 - CornerHeight, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })
	Corners[8] = Globals:Instance("Frame", { Parent = Components.FakeCornerBox, Size = UDim2.new(CornerWidth, 0, 0, Thickness), Position = UDim2.new(1 - CornerWidth, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 })

	--// Outline Corners
	for i = 9, 16 do
		local base = Corners[i - 8]:Clone()
		base.Parent = Components.FakeCornerBox
		base.BorderSizePixel = 1
		base.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Corners[i] = base
	end
	Components.Corners = Corners

	--// Healthbar 
	Components.Healthbar = Globals:Instance("Frame", { 
		Parent = Components.BoxOutline, 
		Size = UDim2.new(0, 1, 1, 4),
		Position = UDim2.new(0, -6, 0, -2),
		BackgroundColor3 = Color3.fromRGB(0, 255, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		Visible = false
	})

	Components.HealthbarBlackout = Globals:Instance("Frame", { 
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 0, 0, 0),
		Parent = Components.Healthbar,
		BorderSizePixel = 0,
		Visible = false
	})

	Components.Health = Globals:Instance("TextLabel", { 
		BackgroundTransparency = 1, 
		Parent = Components.HealthbarBlackout,
		Visible = false,
		FontFace = EntityClass.Font,
		TextSize = EntityClass.FontSize, 
		TextXAlignment = Enum.TextXAlignment.Right, 
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		Size = UDim2.new(0, 20, 0, 12),
		Position = UDim2.new(-1, -23, 0, -2)
	})
	Components.HealthStroke = Globals.ApplyTextStroke(Components.Health)

	--// Name 
	Components.Name = Globals:Instance("TextLabel", { 
		Parent = Components.BoxOutline, 
		FontFace = EntityClass.Font, 
		TextSize = EntityClass.FontSize, 
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 0, -17),
		TextStrokeTransparency = 1,
		Visible = false,
	})
	Components.NameStroke = Globals.ApplyTextStroke(Components.Name)

	--// Distance 
	Components.Distance = Globals:Instance("TextLabel", { 
		Parent = Components.BoxOutline,
		ZIndex = 1,
		TextSize = EntityClass.FontSize, 
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, 6),
		TextStrokeTransparency = 1,
		Visible = false,
		Text = "",
		BackgroundTransparency = 1,
		FontFace = EntityClass.Font, 
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
	Components.DistanceStroke = Globals.ApplyTextStroke(Components.Distance)

	--// Weapon 
	Components.Weapon = Globals:Instance("TextLabel", { 
		Parent = Components.BoxOutline,
		ZIndex = 1,
		TextSize = EntityClass.FontSize, 
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, 6),
		TextStrokeTransparency = 1,
		Visible = false,
		Text = "",
		BackgroundTransparency = 1,
		FontFace = EntityClass.Font, 
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
	Components.WeaponStroke = Globals.ApplyTextStroke(Components.Weapon)

	--// Offscreen 
	Components.OffscreenArrow = Globals:Instance("TextLabel", { 
		Text = "",
		TextSize = 14, 
		BackgroundTransparency = 1, 
		Size = UDim2.new(0, 20, 0, 20),
		Visible = false, 
		Parent = Visuals.ESPSpace
	})
	Components.ArrowStroke = Globals.ApplyTextStroke(Components.OffscreenArrow)

	--// LookAngle
	Components.LookAngle = Visuals.DrawLine()
	Components.LookAngleOutline = Visuals.DrawOutline()

	--// Skeleton
	Components.Skeleton = {
		Main = Visuals.DrawLine(),
		RL_line = Visuals.DrawLine(),
		LL_line = Visuals.DrawLine(),
		RightFoot = Visuals.DrawLine(),
		LeftFoot =  Visuals.DrawLine(),
		LeftArm = Visuals.DrawLine(),
		RightArm = Visuals.DrawLine(),
		RightElbow = Visuals.DrawLine(),
		LeftElbow = Visuals.DrawLine(),
		Hips = Visuals.DrawLine(),
		Shoulders = Visuals.DrawLine(),

		MainOutline = Visuals.DrawOutline(),
		RL_lineOutline = Visuals.DrawOutline(),
		LL_lineOutline = Visuals.DrawOutline(),
		RightFootOutline = Visuals.DrawOutline(),
		LeftFootOutline =  Visuals.DrawOutline(),
		LeftArmOutline = Visuals.DrawOutline(),
		RightArmOutline = Visuals.DrawOutline(),
		RightElbowOutline = Visuals.DrawOutline(),
		LeftElbowOutline = Visuals.DrawOutline(),
		HipsOutline = Visuals.DrawOutline(),
		ShouldersOutline = Visuals.DrawOutline(),
	}

	return Components
end

function EntityClass.Main.Functions:GetBoxSize()
	local Character = self.Character
	local Root = self.Root
	local CameraPosition = Camera.CFrame.Position

	if not Character or not Root then
		return { Visible = false, OnScreen = false, Root = nil }
	end

	if (CameraPosition - Root.Position).Magnitude > 2000 then
		return { Visible = false, OnScreen = false, Root = Root }
	end

	local MaxWidth, MaxHeight, MaxDepth = 10, 20, 10
	local BoundingPosition, BoundingSize = self:GetBoundingBox(Character, Root.CFrame)
	local HalfSize = BoundingSize / 2

	local ClampedSize = Vector3.new(
		math.min(HalfSize.X, MaxWidth / 2) * 2,
		math.min(HalfSize.Y, MaxHeight / 2) * 2,
		math.min(HalfSize.Z, MaxDepth / 2) * 2
	)

	local CornerOffsets = {
		Vector3.new( ClampedSize.X/2,  ClampedSize.Y/2,  ClampedSize.Z/2),
		Vector3.new( ClampedSize.X/2,  ClampedSize.Y/2, -ClampedSize.Z/2),
		Vector3.new( ClampedSize.X/2, -ClampedSize.Y/2,  ClampedSize.Z/2),
		Vector3.new( ClampedSize.X/2, -ClampedSize.Y/2, -ClampedSize.Z/2),
		Vector3.new(-ClampedSize.X/2,  ClampedSize.Y/2,  ClampedSize.Z/2),
		Vector3.new(-ClampedSize.X/2,  ClampedSize.Y/2, -ClampedSize.Z/2),
		Vector3.new(-ClampedSize.X/2, -ClampedSize.Y/2,  ClampedSize.Z/2),
		Vector3.new(-ClampedSize.X/2, -ClampedSize.Y/2, -ClampedSize.Z/2),
	}

	local MinX, MinY = math.huge, math.huge
	local MaxX, MaxY = -math.huge, -math.huge
	local OnScreenCount = 0

	local WorldToViewportPoint = Camera.WorldToViewportPoint

	for _, Offset in ipairs(CornerOffsets) do
		local WorldCorner = BoundingPosition:PointToWorldSpace(Offset)
		local ScreenPos, OnScreen = WorldToViewportPoint(Camera, WorldCorner)
		if OnScreen then
			OnScreenCount += 1
			MinX = math.min(MinX, ScreenPos.X)
			MinY = math.min(MinY, ScreenPos.Y)
			MaxX = math.max(MaxX, ScreenPos.X)
			MaxY = math.max(MaxY, ScreenPos.Y)
		end
	end

	if OnScreenCount == 0 and Character:FindFirstChild("Head") then
		local Visible = Visuals.IsPartVisible(Character.Head)
		return {
			Root = Root,
			OnScreen = false,
			RootPosition = Root.Position,
			Visible = Visible,
			VisiblePart = Visible and Character.Head or nil,
		}
	end

	local VisiblePart = nil
	local PartsToCheck = {
		Character:FindFirstChild("HumanoidRootPart"),
		Character:FindFirstChild("Head"),
		Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	}

	for _, Part in ipairs(PartsToCheck) do
		if Part and Part:IsA("BasePart") and Visuals.IsPartVisible(Part) then
			VisiblePart = Part
			break
		end
	end

	local Width = MaxX - MinX
	local Height = MaxY - MinY
	local Size = Math.FloorVector(Vector2.new(Width, Height))
	local Position = Math.FloorVector(Vector2.new(MinX, MinY))
	local Center2D = Vector2.new(Position.X + Size.X / 2, Position.Y + Size.Y / 2)

	return {
		Visible = VisiblePart ~= nil,
		VisiblePart = VisiblePart,
		Root = Root,
		RootPosition = Root.Position,
		Height = Height,
		Width = Width,
		Size = Size,
		Position = Position,
		Center2D = Center2D,
		OnScreen = OnScreenCount > 0,
	}
end

function EntityClass.Main.Functions:GetBoundingBox(Model, Orientation)
	local Parts = typeof(Model) == "Instance" and Model:GetChildren() or Model
	Orientation = Orientation or CFrame.new()

	local Inf = math.huge
	local MinX, MinY, MinZ = Inf, Inf, Inf
	local MaxX, MaxY, MaxZ = -Inf, -Inf, -Inf

	for _, Part in ipairs(Parts) do
		if Part:IsA("BasePart") then
			local Cf = Orientation:ToObjectSpace(Part.CFrame)
			local Sx, Sy, Sz = Part.Size.X, Part.Size.Y, Part.Size.Z
			local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Cf:components()

			local Wsx = 0.5 * (math.abs(R00) * Sx + math.abs(R01) * Sy + math.abs(R02) * Sz)
			local Wsy = 0.5 * (math.abs(R10) * Sx + math.abs(R11) * Sy + math.abs(R12) * Sz)
			local Wsz = 0.5 * (math.abs(R20) * Sx + math.abs(R21) * Sy + math.abs(R22) * Sz)

			MinX = math.min(MinX, X - Wsx)
			MinY = math.min(MinY, Y - Wsy)
			MinZ = math.min(MinZ, Z - Wsz)

			MaxX = math.max(MaxX, X + Wsx)
			MaxY = math.max(MaxY, Y + Wsy)
			MaxZ = math.max(MaxZ, Z + Wsz)
		end
	end

	local MinVec = Vector3.new(MinX, MinY, MinZ)
	local MaxVec = Vector3.new(MaxX, MaxY, MaxZ)
	local Middle = (MaxVec + MinVec) / 2
	local Cf = Orientation - Orientation.Position + Orientation:PointToWorldSpace(Middle)
	local Size = MaxVec - MinVec

	return Cf, Size
end

function EntityClass.Main.Functions:GetDistance()
	local root = self.Root
	if not root then return 9e9 end
	return math.floor((root.Position - Camera.CFrame.Position).Magnitude)
end

function EntityClass.Main.Functions:GetHealth()
	local Humanoid = self.Humanoid
	if not Humanoid then
		return 0, 100
	end
	return Humanoid.Health, Humanoid.MaxHealth
end

function EntityClass.Main.Functions:GetRoot()
	local character = self.Character
	if not character then return end
	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		self.Humanoid = Humanoid
	end
	return Humanoid and Humanoid.RootPart or character:FindFirstChild("HumanoidRootPart")
end

function EntityClass.Main.Functions:GetCharacter()
	return self.Pointer.Character
end

function EntityClass.Main.Functions:GetEquippedTool()
	local Character = self.Character
	if not Character then return nil end
	return Character:FindFirstChildOfClass("Tool")
end

function EntityClass.Main.Functions:ProjectSkeletonLine(part, offset)
	local pos = part.Position + (offset or Vector3.zero)
	local screenPos = Camera:WorldToViewportPoint(pos)
	return Math.FloorVector(Vector2.new(screenPos.X, screenPos.Y))
end

function EntityClass.Main.Functions:SetSkeletonLine(name, from, to, transparency, color)
	local line = self.Components.Skeleton[name]
	if line then
		line.Visible = true
		line.From = from
		line.To = to
		line.Color = color
		line.Transparency = 1 - transparency
	end

	local outline = self.Components.Skeleton[name .. "Outline"]
	if outline then
		outline.Visible = true
		outline.From = from
		outline.To = to
		outline.Transparency = 1 - transparency
	end
end

function EntityClass.Main.Functions:SetSkeletonsInvisible()
	if self.Components.Skeleton.RL_line.Visible then 
		for _, Line in pairs(self.Components.Skeleton) do 
			Line.Visible = false
		end
	end
end

function EntityClass.Main.Functions:Update()
	self.Character = self:GetCharacter()
	self.Root = self:GetRoot()
	self.Distance = self:GetDistance()
	self.CoreInformation = self:GetBoxSize() or {}

	local Components = self.Components

	if not self.Root then 
		Components.OffscreenArrow.Visible = false
		Components.BoxOutline.Visible = false
		Components.LookAngle.Visible = false
		Components.LookAngleOutline.Visible = false
		self:SetSkeletonsInvisible()
		return
	end

	local Health, MaxHealth = self:GetHealth()
	local CoreInformation = self.CoreInformation
	local Visible = CoreInformation.Visible
	local ClassType = self.ClassType
	local Flags = Library.Flags
	local StatusColor = not Visible and Flags[ClassType.."OccludedColor"].Value[1] or Flags[ClassType.."VisibleColor"].Value[1]

	self.IsDead = Health <= 0.1
	local Transparency = self.IsDead and 1 or 0

	Globals:Tween(Components.BoxInlineStroke, TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad), {
		Color = StatusColor
	})

	Globals:Tween(Components.BoxOutlineStroke, TweenInfo.new(EntityClass.AnimationSpeed + 0.25, Enum.EasingStyle.Quad), {
		Transparency = Transparency
	})

	local ComponentColor = Components.BoxInlineStroke.Color
	Transparency = Components.BoxOutlineStroke.Transparency
	local BoxCorners = Components.Corners
	local BottomBounds = 1

	local EquippedTool = self:GetEquippedTool()
	local HasItem = EquippedTool ~= nil

	if CoreInformation.OnScreen and Flags[ClassType.."ESP"].Value then
		Components.OffscreenArrow.Visible = false
		local CanShowWeapon = Flags[ClassType.."Weapon"]
		local TweenProperties = TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad)

		--// Chams Handling
		if tick() - self.LastChamsRefresh > Flags.ChamsRefreshRate.Value then
			self.LastChamsRefresh = tick()
			for _, Part in pairs(self.Character:GetChildren()) do
				if Part:IsA("BasePart") and not EntityClass.IgnoreNames[Part.Name] then
					if not self.Adornments[Part] then
						local Adornments = {}
						local Adornment
						for Vis = 1, 2 do
							if Part.Name == "Head" then
								Adornment = Globals:Instance("CylinderHandleAdornment", {
									Name = "",
									Adornee = Part,
									Parent = Part,
									ZIndex = Vis == 1 and 2 or 1,
									Height = Vis == 1 and 0.87 or 1.02,
									Radius = Vis == 1 and 0.5 or 0.65,
									CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0)),
									Visible = false,
									AlwaysOnTop = Vis == 1
								})
							else
								local SizeOffset = Vis == 1 and -0.05 or 0.05
								Adornment = Globals:Instance("BoxHandleAdornment", {
									Name = "",
									Adornee = Part,
									Parent = Part,
									ZIndex = Vis == 1 and 2 or 1,
									AlwaysOnTop = Vis == 1,
									Size = Part.Size + Vector3.new(SizeOffset, SizeOffset, SizeOffset),
									Visible = false
								})
							end
							Adornments[Vis] = Adornment
						end
						self.Adornments[Part] = Adornments
					else
						local Adornments = self.Adornments[Part]
						if Adornments then
							local OccludedColor = Flags[ClassType.."ChamsOccludedColor"].Value[1]
							local OccludedTransparency = Flags[ClassType.."ChamsOccludedColor"].Value[2]
							local ShouldShow = Flags[ClassType.."Chams"].Value
							local GlowChams = Flags[ClassType.."ChamsStyle"].Value == "Glow"
							local VisibleColor = Flags[ClassType.."ChamsVisibleColor"].Value[1]
							local VisibleTransparency = Flags[ClassType.."ChamsVisibleColor"].Value[2]

							Adornments[1].Visible = ShouldShow
							Adornments[1].Color3 = OccludedColor
							Adornments[1].Transparency = OccludedTransparency

							Adornments[2].Visible = ShouldShow
							Adornments[2].ZIndex = GlowChams and 9e9 or 1
							Adornments[2].AlwaysOnTop = GlowChams
							Adornments[2].Color3 = VisibleColor
							Adornments[2].Transparency = VisibleTransparency
						end
					end
				end
			end
		end

		Components.BoxOutline.Position = UDim2.new(0, CoreInformation.Position.X, 0, CoreInformation.Position.Y)
		Components.BoxOutline.Size = UDim2.new(0, CoreInformation.Size.X, 0, CoreInformation.Size.Y)
		Components.BoxOutline.Visible = true

		local CanUseSolid = Flags[ClassType.."BoundingBox"].Value and Flags[ClassType.."BoxStyle"].Value == "Solid"
		Components.BoxOutlineStroke.Enabled = CanUseSolid
		Components.BoxInlineStroke.Enabled = CanUseSolid

		ComponentColor = Components.BoxInlineStroke.Color
		Components.BoxInlineStroke.Transparency = Transparency

		for Index = 1, 16 do
			BoxCorners[Index].Visible = Flags[ClassType.."BoundingBox"].Value and Flags[ClassType.."BoxStyle"].Value == "Corner"
			if BoxCorners[Index].Visible then 
				if Index <= 8 then 
					BoxCorners[Index].ZIndex = 3
					BoxCorners[Index].BackgroundColor3 = ComponentColor
				end
				BoxCorners[Index].BackgroundTransparency = Transparency
			end
		end

		--// Health Bar
		if Flags[ClassType.."Healthbar"].Value then
			local HealthPercent = Health / MaxHealth
			if tostring(HealthPercent) == "nan" then
				HealthPercent = 0
			end

			local CalculatedSize = UDim2.new(1, 0, 1 - HealthPercent, 0)

			Components.HealthbarBlackout.Visible = true
			Components.Healthbar.Visible = true
			Components.Healthbar.BackgroundTransparency = Transparency
			Components.HealthbarBlackout.BackgroundTransparency = Transparency

			local ShowIfDamaged = Flags[ClassType.."ShowHealthIfDamaged"].Value
			local CanShowHealth = not ShowIfDamaged or (ShowIfDamaged and Health < MaxHealth)

			if Flags[ClassType.."Health"].Value and CanShowHealth then
				Components.Health.Visible = true
				Components.Health.Text = tostring(math.floor(HealthPercent * 100))
				Components.Health.TextTransparency = Transparency
				Components.HealthStroke.Transparency = Transparency
			else
				Components.Health.Visible = false
			end

			if Health ~= self.LastHealth then
				self.LastHealth = Health
				Globals:Tween(Components.HealthbarBlackout, TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad), {
					Size = CalculatedSize
				})

				local LerpedColor = Flags[ClassType.."LowerHealthColor"].Value[1]:lerp(Flags[ClassType.."HigherHealthColor"].Value[1], Health / MaxHealth)

				Globals:Tween(Components.Healthbar, TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad), {
					BackgroundColor3 = LerpedColor
				})
			end
		else
			Components.Healthbar.Visible = false
		end

		--// Name Tag
		if Flags[ClassType.."Name"].Value then
			Components.Name.Visible = true
			Components.NameStroke.Transparency = Transparency
			Components.Name.TextTransparency = Transparency
			Components.Name.Text = self.Name
			Components.Name.TextColor3 = ComponentColor
		else
			Components.Name.Visible = false
		end

		--// Distance Tag
		if Flags[ClassType.."Distance"].Value then
			Components.Distance.Visible = true
			Components.DistanceStroke.Transparency = Transparency
			Components.Distance.Text = tostring(self.Distance).." studs"
			Components.Distance.TextColor3 = ComponentColor
			Components.Distance.TextTransparency = Transparency
			Components.Distance.Position = UDim2.new(0, 0, 1, BottomBounds)
			BottomBounds += 8
		else
			Components.Distance.Visible = false
		end

		--// Weapon Tag (Equipped Tool)
		if CanShowWeapon and CanShowWeapon.Value then
			Components.Weapon.Visible = true
			if HasItem then
				Components.Weapon.Text = EquippedTool.Name
			else
				Components.Weapon.Text = "None"
			end

			Components.Weapon.TextColor3 = ComponentColor

			if not Components.Weapon:GetAttribute("IsTweening") then
				Components.Weapon:SetAttribute("IsTweening", true)

				local TargetY = HasItem and BottomBounds or (BottomBounds - 4)
				local WeaponTween = Globals:Tween(Components.Weapon, TweenProperties, {
					TextTransparency = HasItem and Transparency or 1,
					Position = UDim2.new(0, 0, 1, TargetY)
				})

				Globals:Tween(Components.WeaponStroke, TweenProperties, {
					Transparency = HasItem and Transparency or 1
				})

				WeaponTween.Completed:Connect(function()
					Components.Weapon:SetAttribute("IsTweening", false)
				end)
			end

			BottomBounds += 6
		else
			Components.Weapon.Visible = false
		end

		--// Look Angle
		if Flags[ClassType.."LookAngle"].Value and self.Character:FindFirstChild("Head") and not Library.IsOpen then
			local Head = self.Character.Head
			local HeadPos, HeadOnScreen = Camera:WorldToViewportPoint(Head.Position)
			local LookPos, LookOnScreen = Camera:WorldToViewportPoint(Head.Position + Head.CFrame.LookVector * 5)

			local Line = Components.LookAngle
			local Outline = Components.LookAngleOutline

			if HeadOnScreen and LookOnScreen then
				local From = Vector2.new(HeadPos.X, HeadPos.Y)
				local To = Vector2.new(LookPos.X, LookPos.Y)

				From = Math.FloorVector(From)
				To = Math.FloorVector(To)

				Line.Visible = true
				Line.From = From
				Line.To = To
				Line.Color = ComponentColor
				Line.Transparency = 1 - Transparency

				Outline.Visible = true
				Outline.From = From
				Outline.To = To
				Outline.Transparency = 1 - Transparency
			else
				Line.Visible = false
				Outline.Visible = false
			end
		else
			Components.LookAngle.Visible = false
			Components.LookAngleOutline.Visible = false
		end

		--// Skeleton
		if Flags[ClassType.."Skeleton"].Value and self.Character:FindFirstChild("Head") and not Library.IsOpen then
			local IsR15 = self.Character:FindFirstChild("UpperTorso") ~= nil
			local IsR6 = not IsR15 and self.Character:FindFirstChild("Torso") ~= nil

			if IsR15 then
				local Valid = true
				for _, Part in pairs({"UpperTorso", "RightUpperLeg", "LeftFoot", "RightFoot", "LeftUpperLeg", "LeftUpperArm", "RightUpperArm", "RightLowerArm", "RightHand", "LeftHand"}) do
					if not self.Character:FindFirstChild(Part) then
						Valid = false
						break
					end
				end

				if Valid then
					local Head = self:ProjectSkeletonLine(self.Character.Head)
					local RL = self:ProjectSkeletonLine(self.Character.RightUpperLeg)
					local LL = self:ProjectSkeletonLine(self.Character.LeftUpperLeg)

					local RightLeg = self:ProjectSkeletonLine(self.Character.RightUpperLeg, Vector3.new(0, 0.5, 0))
					local LeftLeg = self:ProjectSkeletonLine(self.Character.LeftUpperLeg, Vector3.new(0, 0.5, 0))

					local RightFoot = self:ProjectSkeletonLine(self.Character.RightFoot)
					local LeftFoot = self:ProjectSkeletonLine(self.Character.LeftFoot)

					local RightArm = self:ProjectSkeletonLine(self.Character.RightUpperArm, Vector3.new(0, 0.2, 0))
					local LeftArm = self:ProjectSkeletonLine(self.Character.LeftUpperArm, Vector3.new(0, 0.2, 0))

					local RightElbow = self:ProjectSkeletonLine(self.Character.RightLowerArm, Vector3.new(0, 0.2, 0))
					local LeftElbow = self:ProjectSkeletonLine(self.Character.LeftLowerArm, Vector3.new(0, 0.2, 0))

					local RightHand = self:ProjectSkeletonLine(self.Character.RightHand)
					local LeftHand = self:ProjectSkeletonLine(self.Character.LeftHand)

					self:SetSkeletonLine("RightFoot", RightFoot, RL, Transparency, ComponentColor)
					self:SetSkeletonLine("LeftFoot", LeftFoot, LL, Transparency, ComponentColor)

					self:SetSkeletonLine("LL_line", LeftLeg, LL, Transparency, ComponentColor)
					self:SetSkeletonLine("RL_line", RightLeg, RL, Transparency, ComponentColor)

					self:SetSkeletonLine("RightArm", RightArm, RightElbow, Transparency, ComponentColor)
					self:SetSkeletonLine("RightElbow", RightElbow, RightHand, Transparency, ComponentColor)

					self:SetSkeletonLine("LeftArm", LeftArm, LeftElbow, Transparency, ComponentColor)
					self:SetSkeletonLine("LeftElbow", LeftElbow, LeftHand, Transparency, ComponentColor)

					self:SetSkeletonLine("Main", Vector2.new((LeftLeg.X + RightLeg.X) / 2, LeftLeg.Y), Head, Transparency, ComponentColor)
					self:SetSkeletonLine("Hips", LeftLeg, RightLeg, Transparency, ComponentColor)
					self:SetSkeletonLine("Shoulders", RightArm, LeftArm, Transparency, ComponentColor)
				else
					self:SetSkeletonsInvisible()
				end
			elseif IsR6 then
				local Valid = true
				for _, Part in pairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
					if not self.Character:FindFirstChild(Part) then
						Valid = false
						break
					end
				end

				if Valid then
					local Head = self:ProjectSkeletonLine(self.Character.Head)
					local Torso = self:ProjectSkeletonLine(self.Character.Torso)
					local LeftArm = self:ProjectSkeletonLine(self.Character["Left Arm"])
					local RightArm = self:ProjectSkeletonLine(self.Character["Right Arm"])
					local LeftLeg = self:ProjectSkeletonLine(self.Character["Left Leg"])
					local RightLeg = self:ProjectSkeletonLine(self.Character["Right Leg"])

					self:SetSkeletonLine("Main", Head, Torso, Transparency, ComponentColor)
					self:SetSkeletonLine("Shoulders", LeftArm, RightArm, Transparency, ComponentColor)
					self:SetSkeletonLine("LeftArm", LeftArm, Torso, Transparency, ComponentColor)
					self:SetSkeletonLine("RightArm", RightArm, Torso, Transparency, ComponentColor)
					self:SetSkeletonLine("LL_line", LeftLeg, Torso, Transparency, ComponentColor)
					self:SetSkeletonLine("RL_line", RightLeg, Torso, Transparency, ComponentColor)
					self:SetSkeletonLine("Hips", LeftLeg, RightLeg, Transparency, ComponentColor)
					
					-- Hide unused R15 joints
					for _, LineName in pairs({"RightFoot", "LeftFoot", "RightElbow", "LeftElbow"}) do
						local line = self.Components.Skeleton[LineName]
						if line then line.Visible = false end
						local outline = self.Components.Skeleton[LineName .. "Outline"]
						if outline then outline.Visible = false end
					end
				else
					self:SetSkeletonsInvisible()
				end
			else
				self:SetSkeletonsInvisible()
			end
		else
			self:SetSkeletonsInvisible()
		end
	else
		Components.BoxOutline.Visible = false
		Components.LookAngle.Visible = false
		Components.LookAngleOutline.Visible = false
		self:SetSkeletonsInvisible()

		--// Offscreen Arrows
		if CoreInformation.Root and Flags[ClassType.."Offscreen"] and Flags[ClassType.."Offscreen"].Value then
			local ArrowRadius = Flags[ClassType.."OffscreenRadius"].Value
			local Arrow = Components.OffscreenArrow
			local Size = 14

			local ScreenSize = Camera.ViewportSize
			local Center = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
			local Position = CoreInformation.Root.Position
			local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)

			local Direction = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Unit
			local ClampedPosition = Center + Direction * ArrowRadius

			Arrow.TextSize = Size
			Arrow.Size = UDim2.new(0, 25, 0, 25)
			Arrow.Position = UDim2.new(0, ClampedPosition.X - Arrow.Size.X.Offset / 2, 0, ClampedPosition.Y - Arrow.Size.Y.Offset / 2)
			Arrow.Rotation = math.deg(math.atan2(Direction.Y, Direction.X)) + 90
			Arrow.Visible = true
			Arrow.TextColor3 = ComponentColor
			Arrow.TextTransparency = Transparency
			Components.ArrowStroke.Transparency = Transparency
		else
			Components.OffscreenArrow.Visible = false
		end
	end
end

--// Caching Loop
local function AddPlayer(Player)
	if Player == Client then return end
	
	local EntityObject = EntityClass.Global:Create(Player, {
		Class = "Player",
		ClassType = "Player"
	})

	Player.CharacterAdded:Connect(function(Character)
		EntityObject:OnCharacterAdded(Character)
	end)

	if Player.Character then
		EntityObject:OnCharacterAdded(Player.Character)
	end
end

for _, Player in pairs(Players:GetPlayers()) do
	AddPlayer(Player)
end

Players.PlayerAdded:Connect(AddPlayer)

Players.PlayerRemoving:Connect(function(Player)
	local EntityObject = EntityClass.Main.Cache[Player]
	if EntityObject then
		EntityObject:Remove()
	end
end)

--// Visuals and Entities Threads Setup
local EntityThread = Threads.New("Entity Handler", function()
	for _, Object in pairs(EntityClass.Main.Cache) do
		if tick() - Object.LastUpdate > 0.0145 then 
			Object.LastUpdate = tick()
			Object:Update()
		end
	end
end, "Entities")

--// Loop runner
RunService.RenderStepped:Connect(function(Delta)
	Globals.Delta = Delta 

	for _, Thread in pairs(Threads.Entities) do 
		Thread:Run()
	end

	for _, Thread in pairs(Threads.Render) do 
		Thread:Run()
	end
end)

Library:Notify("Universal ESP Loaded Successfully!", 5, Color3.fromRGB(0, 255, 120))
