--[[
	Iridescent UI Library
	Extracted and cleaned from the leaked Iridescent script
	
	Usage:
		local Library = loadstring(game:HttpGet("raw github link here"))()
		local Window = Library:Window({ Name = "My Script" })
]]

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local Globals = {}

function Globals:Tween(...)
	local Tween = TweenService:Create(...)
	Tween:Play()
	return Tween
end

function Globals:Instance(Class, Properties)
	local Element = Instance.new(Class)
	for Key, Value in Properties do
		Element[Key] = Value
	end
	return Element
end

function Globals:DeepCopy(Table)
	local Copy = {}
	for k, v in pairs(Table) do
		if type(v) == "table" then
			Copy[k] = Globals:DeepCopy(v)
		else
			Copy[k] = v
		end
	end
	return Copy
end

local Math = {}

local Theme = {
	Accent = Color3.fromRGB(63, 201, 176),
	DarkAccent = Color3.fromRGB(63, 201, 176),
	AccentedHighlight = Color3.fromRGB(63, 201, 176),
}

local Library = {
	NotificationList = {},
	IsOpen = false,
	CategoryPause = 0.2,
	CategoryTransitionSpeed = 0.25,
	HighlightSpeed = 0.25,
	PageTransitionSpeed = 0.2,
	Windows = {},
	Flags = {},
	Font = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium),
	BoldFont = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold),
	Connections = {},
	Keybinds = {
		MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
		ButtonA = "A", ButtonB = "B", ButtonX = "X", ButtonY = "Y",
		ButtonStart = "STRT", ButtonSelect = "SELT",
		ButtonL1 = "L1", ButtonR1 = "R1", ButtonL2 = "L2", ButtonR2 = "R2",
		ButtonL3 = "L3", ButtonR3 = "R3",
		DPadUp = "DUP", DPadDown = "DDN", DPadLeft = "DLT", DPadRight = "DRT",
		W = "W", A = "A", S = "S", D = "D",
		Space = "SPC", LeftShift = "LSFT", RightShift = "RSFT",
		LeftControl = "LCTL", RightControl = "RCTL",
		LeftAlt = "LALT", RightAlt = "RALT",
		Enter = "ENT", Escape = "ESC", Backspace = "BS",
		Tab = "TAB", CapsLock = "CAPS",
		Insert = "INS", Delete = "DEL",
		Home = "HOME", EndKey = "END",
		PageUp = "PGUP", PageDown = "PGDN",
		Up = "UP", Down = "DN", Left = "LT", Right = "RT",
		Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
		Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
		F1 = "F1", F2 = "F2", F3 = "F3", F4 = "F4", F5 = "F5",
		F6 = "F6", F7 = "F7", F8 = "F8", F9 = "F9", F10 = "F10", F11 = "F11", F12 = "F12",
		Minus = "-", Equals = "=",
		LeftBracket = "[", RightBracket = "]",
		Semicolon = ";", Quote = "'",
		Comma = ",", Period = ".", Slash = "/", Backslash = "\\", Grave = "`",
	},
	ShadowImage = "rbxassetid://6014261993",
	OutlineShadowImage = "rbxassetid://93984335181980",
	DropdownImage = "rbxassetid://106970154099045",
	ColorwheelImage = "rbxassetid://6042338876",
	TransparencyImage = "rbxassetid://96978989117558",
	LogoImage = "http://www.roblox.com/asset/?id=71404918936585",
	HotKeysImage = "",
	ModeratorImage = "",
	ArmorImage = "",
}

Library.Theme = Theme
Library.__index = Library

Library.Notifications = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	DisplayOrder = 1,
	IgnoreGuiInset = true,
})

Library.HeadsUp = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	DisplayOrder = 1,
	IgnoreGuiInset = true,
	Enabled = true,
})

function Library:Connection(Name, Signal, Function)
	local Connection = Signal:Connect(Function)
	self.Connections[Name] = {
		Signal = Signal,
		Function = Function,
		Connection = Connection,
	}
	return self.Connections[Name]
end

function Library:Disconnect(Name)
	local Conn = self.Connections[Name]
	if Conn then
		Conn.Connection:Disconnect()
		self.Connections[Name] = nil
	end
end

function Library:DisconnectAll()
	for Name, Conn in pairs(self.Connections) do
		Conn.Connection:Disconnect()
	end
	table.clear(self.Connections)
end

function Library:DoCallback(Callback, Data)
	local Success, Error = pcall(Callback, Data)
	if not Success and Error then
		return "Failed", Error
	end
	return Success
end

function Library:FormatValue(incr, val)
	if incr < 1 then
		return string.format("%.2f", val)
	else
		return tostring(math.floor(val + 0.5))
	end
end

function Library:GetInputName(input)
	if input and input.UserInputType then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return input.KeyCode.Name
		elseif input.UserInputType.Name:match("Mouse") then
			return input.UserInputType.Name
		else
			return "Unknown"
		end
	end
end

function Library:FormatKeyName(name)
	if Library.Keybinds[name] then
		return Library.Keybinds[name]
	elseif #name > 4 then
		return name:sub(1, 4)
	end
	return name
end

function Library:GetConfig()
	local Flags = self.Flags
	local Save = {}
	for Flag, Data in Flags do
		local Class = Data.Class
		local Value = Data.Value
		if Class == "Toggle" then
			Save[Flag] = Value
		elseif Class == "Colorpicker" then
			Save[Flag] = {
				[1] = { Value[1].R, Value[1].G, Value[1].B },
				[2] = Value[2],
			}
		elseif Class == "Slider" then
			Save[Flag] = Value
		elseif Class == "TextBox" then
			Save[Flag] = Value
		elseif Class == "Dropdown" then
			Save[Flag] = Value
		elseif Class == "Keybind" then
			if Data.Key then
				local Key = {
					Type = Data.Key.Type,
					Value = Data.Key.Value.Name,
				}
				Save[Flag] = Key
			end
		end
	end
	return HttpService:JSONEncode(Save)
end

function Library:SaveConfig(Name, ConfigFolder)
	ConfigFolder = ConfigFolder or "Iridescent/Configs"
	local CurrentConfig = Library:GetConfig()
	writefile(ConfigFolder .. "/" .. Name .. ".json", CurrentConfig)
end

function Library:LoadConfig(Name, ConfigFolder)
	ConfigFolder = ConfigFolder or "Iridescent/Configs"
	local FilePath = ConfigFolder .. "/" .. Name .. ".json"
	if not isfile(FilePath) then
		Library:Notify("Configuration failed to load\nFile does not exist!", 4, Color3.fromRGB(255, 0, 0))
		return
	end
	local Config = readfile(FilePath)
	local DecodedConfig = HttpService:JSONDecode(Config)
	for Flag, FlagData in DecodedConfig do
		local RealFlag = Library.Flags[Flag]
		if not RealFlag then continue end
		if RealFlag.Class == "Colorpicker" then
			local Color = Color3.new(FlagData[1][1], FlagData[1][2], FlagData[1][3])
			task.spawn(function()
				RealFlag:Set({ Color, FlagData[2] })
			end)
			continue
		elseif RealFlag.Class == "Keybind" then
			task.spawn(function()
				local input = {}
				if FlagData.Type == "MouseButton" then
					input.UserInputType = Enum.UserInputType[FlagData.Value]
				elseif FlagData.Type == "KeyCode" then
					input.UserInputType = Enum.UserInputType.Keyboard
					input.KeyCode = Enum.KeyCode[FlagData.Value]
				else
					input.UserInputType = Enum.UserInputType[FlagData.Value]
				end
				RealFlag:SetKey(input)
			end)
			continue
		end
		task.spawn(function()
			RealFlag:Set(FlagData)
		end)
	end
end

function Library:CreateHotkeysPanel()
	local Hotkeys = { Keys = 0 }
	local Components = {}
	Hotkeys.__index = Hotkeys

	Components["Hotkeys"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 20, 0.5, 0),
		Size = UDim2.new(0, 215, 0, 30),
		Name = "Hotkeys",
		Parent = Library.HeadsUp,
		Visible = false,
	})

	Components["HotkeysCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["Hotkeys"],
	})

	Components["HotkeysStroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["Hotkeys"],
	})

	Components["HotkeysTitleArea"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 25),
		Parent = Components["Hotkeys"],
	})

	Components["HotkeysTitleCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["HotkeysTitleArea"],
	})

	Components["HotkeysTitlestroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["HotkeysTitleArea"],
	})

	Components["HotkeysTitle"] = Globals:Instance("TextLabel", {
		Font = Enum.Font.SourceSansSemibold,
		Text = "Hotkeys",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 35, 0, 0),
		Size = UDim2.new(1, -35, 1, 0),
		Parent = Components["HotkeysTitleArea"],
	})

	Components["HotkeysImage"] = Globals:Instance("ImageLabel", {
		Image = Library.HotKeysImage,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.new(0.0116279069, 20, 1, -5),
		Parent = Components["HotkeysTitleArea"],
	})

	Components["HotkeysActive"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 30),
		Size = UDim2.new(1, -10, 0, 33),
		Parent = Components["Hotkeys"],
	})

	Components["UIListLayout"] = Globals:Instance("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Components["HotkeysActive"],
	})

	Components["HotkeysShadowHolder"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0,
		Parent = Components["Hotkeys"],
	})

	Components["HotkeysShadow"] = Globals:Instance("ImageLabel", {
		Image = Library.ShadowImage,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageTransparency = 0.8,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 47, 1, 47),
		ZIndex = 0,
		Parent = Components["HotkeysShadowHolder"],
	})

	Hotkeys.Components = Components

	function Hotkeys:Add(Name, Key)
		self.Keys += 1
		local Hotkey = {}
		Hotkey["Container"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Name = Name,
			Parent = Components["HotkeysActive"],
		})
		Hotkey["NameLabel"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = Name,
			TextColor3 = Color3.fromRGB(129, 129, 129),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = Hotkey["Container"],
		})
		Hotkey["KeyLabel"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = Library:FormatKeyName(Key),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 1),
			Size = UDim2.new(1, 0, 1, 0),
			Parent = Hotkey["Container"],
		})
		return Hotkey
	end

	return Hotkeys
end

function Library:CreateModeratorsPanel()
	local ModPanel = {}
	local Components = {}
	ModPanel.__index = ModPanel

	Components["ModeratorPanel"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 249, 0.5, 0),
		Size = UDim2.new(0, 170, 0, 30),
		Parent = Library.HeadsUp,
		Visible = false,
	})

	Components["ModeratorCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["ModeratorPanel"],
	})

	Components["ModeratorStroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["ModeratorPanel"],
	})

	Components["ModeratorTitleArea"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 25),
		Parent = Components["ModeratorPanel"],
	})

	Components["ModeratorTitleCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["ModeratorTitleArea"],
	})

	Components["ModeratorTitlestroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["ModeratorTitleArea"],
	})

	Components["ModeratorTitle"] = Globals:Instance("TextLabel", {
		Font = Enum.Font.SourceSansSemibold,
		Text = "Moderators",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 35, 0, 0),
		Size = UDim2.new(1, -35, 1, 0),
		Parent = Components["ModeratorTitleArea"],
	})

	Components["ModeratorImage"] = Globals:Instance("ImageLabel", {
		Image = Library.ModeratorImage,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.new(0.0116279069, 20, 1, -5),
		Parent = Components["ModeratorTitleArea"],
	})

	Components["Active"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 30),
		Size = UDim2.new(1, -10, 0, 33),
		Parent = Components["ModeratorPanel"],
	})

	Components["UIListLayout"] = Globals:Instance("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Components["Active"],
	})

	Components["ShadowHolder"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0,
		Parent = Components["ModeratorPanel"],
	})

	Components["Shadow"] = Globals:Instance("ImageLabel", {
		Image = Library.ShadowImage,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageTransparency = 0.8,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 47, 1, 47),
		ZIndex = 0,
		Parent = Components["ShadowHolder"],
	})

	ModPanel.Components = Components

	function ModPanel:AddUser(Name)
		local Container = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Name = Name,
			Parent = Components["Active"],
		})
		local NameLabel = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = Name,
			TextColor3 = Color3.fromRGB(129, 129, 129),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = Container,
		})
		return Container
	end

	return ModPanel
end

function Library:CreateArmorPanel()
	local ArmorPanel = {}
	local Components = {}
	ArmorPanel.__index = ArmorPanel

	Components["ArmorPanel"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -851, 0.5, 0),
		Size = UDim2.new(0, 170, 0, 30),
		Parent = Library.HeadsUp,
		Visible = false,
	})

	Components["ArmorCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["ArmorPanel"],
	})

	Components["ArmorStroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["ArmorPanel"],
	})

	Components["ArmorTitleArea"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 25),
		Parent = Components["ArmorPanel"],
	})

	Components["ArmorTitleCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["ArmorTitleArea"],
	})

	Components["ArmorTitlestroke"] = Globals:Instance("UIStroke", {
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["ArmorTitleArea"],
	})

	Components["ArmorTitle"] = Globals:Instance("TextLabel", {
		Font = Enum.Font.SourceSansSemibold,
		Text = "Armor",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 35, 0, 0),
		Size = UDim2.new(1, -35, 1, 0),
		Parent = Components["ArmorTitleArea"],
	})

	Components["ArmorImage"] = Globals:Instance("ImageLabel", {
		Image = Library.ArmorImage,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.new(0.0116279069, 20, 1, -5),
		Parent = Components["ArmorTitleArea"],
	})

	Components["Active"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 30),
		Size = UDim2.new(1, -10, 0, 33),
		Parent = Components["ArmorPanel"],
	})

	Components["UIListLayout"] = Globals:Instance("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Components["Active"],
	})

	Components["ShadowHolder"] = Globals:Instance("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0,
		Parent = Components["ArmorPanel"],
	})

	Components["Shadow"] = Globals:Instance("ImageLabel", {
		Image = Library.ShadowImage,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageTransparency = 0.8,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 47, 1, 47),
		ZIndex = 0,
		Parent = Components["ShadowHolder"],
	})

	ArmorPanel.Components = Components

	function ArmorPanel:Set(armor)
		if armor <= 0 then
			self.Components.ArmorPanel.Visible = false
			return
		end
		self.Components.ArmorPanel.Visible = true
		self.Components.Active.Text = armor
	end

	return ArmorPanel
end

function Library:Window(WindowData)
	local Window = {
		Name = WindowData.Name,
		Tabs = {},
		Sections = {},
		Components = {},
		PlayerImage = WindowData.PlayerImage,
		Open = true,
		IsOpen = true,
	}

	Library.IsOpen = true

	Window.ArmorPanel = self:CreateArmorPanel()
	Window.ModPanel = self:CreateModeratorsPanel()
	Window.Hotkeys = self:CreateHotkeysPanel()
	Window.__index = Window

	local Components = {}

	do -- Components
		Components["UI"] = Globals:Instance("ScreenGui", {
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Name = "UI",
			Parent = CoreGui,
			DisplayOrder = 3,
		})

		Components["Outline"] = Globals:Instance("TextButton", {
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 14,
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(11, 11, 11),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 3, 0),
			Size = UDim2.new(0, 650, 0, 470),
			Name = "Outline",
			Parent = Components["UI"],
		})

		Components["OutlineCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = Components["Outline"],
		})

		Components["WindowNotifications"] = Globals:Instance("Frame", {
			Position = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Name = "Notifications",
			Parent = Components.Outline,
		})

		Components["LeftSideElements"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 14, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 50, 1, 0),
			Name = "LeftSideElements",
			Parent = Components["Outline"],
		})

		Components["LeftSideElmentsCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = Components["LeftSideElements"],
		})

		Components["LeftSideFixIGNORE"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 14, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -2, 0, 0),
			Size = UDim2.new(0, 3, 1, 0),
			Name = "LeftSideFixIGNORE",
			Parent = Components["LeftSideElements"],
		})

		Components["LeftSideOutline"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Name = "LeftSideOutline",
			Parent = Components["LeftSideFixIGNORE"],
		})

		Components["LogoSpace"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 50),
			Name = "LogoSpace",
			Parent = Components["LeftSideElements"],
		})

		Components["Logo"] = Globals:Instance("ImageLabel", {
			Image = Library.LogoImage,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -10, 1, -10),
			Name = "Logo",
			Parent = Components["LogoSpace"],
		})

		Components["TabsHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 50),
			Size = UDim2.new(1, 0, 1, -106),
			Name = "TabsHolder",
			Parent = Components["LeftSideElements"],
		})

		Components["TabsScrollingFrame"] = Globals:Instance("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(1, 0, 1, 0),
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 0,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -3),
			Size = UDim2.new(1, 0, 1, 3),
			Name = "TabsScrollingFrame",
			Parent = Components["TabsHolder"],
		})

		Components["ScrollingFrameListLayout"] = Globals:Instance("UIListLayout", {
			Padding = UDim.new(0, 13),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Components["TabsScrollingFrame"],
		})

		Components["UIPadding"] = Globals:Instance("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 1),
			Parent = Components["TabsScrollingFrame"],
		})

		Components["TabFadeTop"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -10),
			Size = UDim2.new(1, 0, 0, 20),
			Name = "TabFadeTop",
			Parent = Components["TabsHolder"],
		})

		Components["TabFadeTopGradient"] = Globals:Instance("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 14)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 14)),
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = Components["TabFadeTop"],
		})

		Components["TabFadeBottom"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -20),
			Size = UDim2.new(1, 0, 0, 20),
			Name = "TabFadeBottom",
			Parent = Components["TabsHolder"],
		})

		Components["TabFadeBottomGradient"] = Globals:Instance("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 14)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 14)),
			}),
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = Components["TabFadeBottom"],
		})

		Components["PlayerIconHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -50),
			Size = UDim2.new(1, 0, 0, 50),
			Name = "PlayerIconHolder",
			Parent = Components["LeftSideElements"],
		})

		Components["TopSideElements"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 14, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 52, 0, 0),
			Size = UDim2.new(1, -52, 0, 50),
			Name = "TopSideElements",
			Parent = Components["Outline"],
			ClipsDescendants = true,
		})

		Components["TopSideElementsCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = Components["TopSideElements"],
		})

		Components["TopSideElementsFix"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 14, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -2),
			Size = UDim2.new(1, 0, 0, 3),
			Name = "TopSideElementsFix",
			Parent = Components["TopSideElements"],
		})

		Components["TopSideOutline"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			Name = "TopSideOutline",
			Parent = Components["TopSideElementsFix"],
		})

		Components["Categorys"] = Globals:Instance("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0.5, 0),
			Size = UDim2.new(1, -30, 1, -30),
			Name = "Categorys",
			Parent = Components["TopSideElements"],
		})

		Components["Pages"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 64, 0, 62),
			Size = UDim2.new(0, 573, 0, 395),
			Name = "Pages",
			Parent = Components["Outline"],
		})

		Components["PageHider"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(11, 11, 11),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 64, 0, 62),
			Size = UDim2.new(0, 573, 0, 395),
			Name = "PageHider",
			Parent = Components["Outline"],
		})

		Components["PageFadeBottom"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -20),
			Size = UDim2.new(1, 0, 0, 20),
			Name = "PageFadeBottom",
			Parent = Components["Pages"],
			ZIndex = 2000,
		})

		Components["PageFadeTopGradient"] = Globals:Instance("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 11, 11)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 11, 11)),
			}),
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.43, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = Components["PageFadeBottom"],
		})

		Components["PageFadeTop"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -2),
			Size = UDim2.new(1, 0, 0, 20),
			Name = "PageFadeTop",
			Parent = Components["Pages"],
			ZIndex = 2000,
		})

		Components["PageFadeTopGradient1"] = Globals:Instance("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 11, 11)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 11, 11)),
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.43, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = Components["PageFadeTop"],
		})

		Components["OutlineShadowHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
			Parent = Components["Outline"],
		})

		Components["OutlineShadow"] = Globals:Instance("ImageLabel", {
			Image = Library.OutlineShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 77, 1, 77),
			ZIndex = 0,
			Parent = Components["OutlineShadowHolder"],
		})

		Components["OutlineShadowInner"] = Globals:Instance("ImageLabel", {
			Image = Library.OutlineShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.5,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 27, 1, 27),
			ZIndex = 0,
			Parent = Components["OutlineShadowHolder"],
		})
	end

	do -- Dragging
		local Dragging, DragInput, DragStart, StartPos
		Components["TopSideElements"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPos = Components["Outline"].Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		Components["TopSideElements"].InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				local Delta = input.Position - DragStart
				Components["Outline"].Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
			end
		end)
	end

	do -- Open/Close
		Components["Outline"].MouseButton2Down:Connect(function()
			Window.Open = not Window.Open
			if Window.Open then
				Window:OpenWindow()
			else
				Window:Close()
			end
		end)
		UserInputService.InputBegan:Connect(function(inp)
			if inp.KeyCode == Enum.KeyCode.RightShift and not UserInputService:GetFocusedTextBox() then
				Window.Open = not Window.Open
				Library.IsOpen = Window.Open
				Window:SetVisibility(Window.Open)
			end
		end)
	end

	function Window:Notify(txt, duration)
		-- placeholder
	end

	function Window:OpenWindow()
		local outline = self.Components.Outline
		self.Components.UI.Enabled = true
		local currentX = outline.Position.X
		local targetPosition = UDim2.new(currentX.Scale, currentX.Offset, 0.5, 0)
		if self.CurrentTween then
			self.CurrentTween:Cancel()
			self.CurrentTween = nil
		end
		outline.Position = UDim2.new(currentX.Scale, currentX.Offset, outline.Position.Y.Scale, outline.Position.Y.Offset)
		self.CurrentTween = Globals:Tween(outline, TweenInfo.new(0.25), {
			Position = targetPosition,
		})
		local completedConnection
		completedConnection = self.CurrentTween.Completed:Connect(function()
			self.CurrentTween = nil
			self.IsOpen = true
			if completedConnection then completedConnection:Disconnect() end
		end)
	end

	function Window:Close()
		local outline = self.Components.Outline
		if self.CurrentTween then
			self.CurrentTween:Cancel()
			self.CurrentTween = nil
		end
		self.CurrentTween = Globals:Tween(outline, TweenInfo.new(0.25), {
			Position = UDim2.new(0.5, 0, 3, 0),
		})
		local completedConnection
		completedConnection = self.CurrentTween.Completed:Connect(function()
			self.CurrentTween = nil
			self.Components.UI.Enabled = false
			if completedConnection then completedConnection:Disconnect() end
		end)
	end

	function Window:SetVisibility(bool)
		self.Components.UI.Enabled = bool
		for _, v in self.Components.UI:GetDescendants() do
			if v:IsA("ImageLabel") or v:IsA("ImageButton") then
				v.Visible = bool
			end
		end
		self.IsOpen = bool
	end

	function Window:SetTab(Tab)
		if self.CurrentTab == Tab then return end
		self.CurrentTab = Tab
		self.CurrentCategory = nil
		for _, Page in self.Components.Categorys:GetChildren() do
			if Page:IsA("Frame") then
				Page.Visible = false
			end
		end
		for _, TabButton in self.Components.TabsScrollingFrame:GetChildren() do
			if TabButton:IsA("TextButton") then
				local Image = TabButton:FindFirstChild("TabImage")
				if Image then
					Image:SetAttribute("Opened", false)
					Globals:Tween(Image, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
						ImageColor3 = Color3.fromRGB(126, 126, 126),
					})
				end
			end
		end
		local TabImage = Tab.Components.TabImage
		TabImage:SetAttribute("Opened", true)
		Globals:Tween(TabImage, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
			ImageColor3 = Color3.fromRGB(255, 255, 255),
		})

		for _, Page in self.Components.Categorys:GetChildren() do
			if not Page:IsA("Frame") or table.find({ "PageFadeTop", "PageFadeBottom" }, Page.Name) then
				continue
			end
			Page.Visible = Page.Name == Tab.Name
		end
	end

	function Window:TabSeperator()
		local Tab = { Name = "Seperator" }
		local Components = {}

		Components["TabSeparatorHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 35, 0, 1),
			Parent = self.Components["TabsScrollingFrame"],
		})

		Components["TabSeparatorLine"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -7, 1, 0),
			Parent = Components["TabSeparatorHolder"],
		})

		Tab.Components = Components
		return Tab
	end

	function Window:Tab(TabData)
		local Tab = {
			Name = TabData.Name,
			Image = TabData.Image,
			Categories = {},
			CategoryOrder = {},
		}
		Tab.__index = Tab
		local Components = {}

		do -- Components
			Components["NewTabButtonHolder"] = Globals:Instance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(15, 15, 15),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 35, 0, 35),
				Name = Tab.Name,
				Parent = self.Components["TabsScrollingFrame"],
				Text = "",
				AutoButtonColor = false,
			})

			Components["TabImage"] = Globals:Instance("ImageLabel", {
				Image = Tab.Image,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ImageColor3 = Color3.fromRGB(126, 126, 126),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 25, 0, 25),
				Name = "TabImage",
				Parent = Components["NewTabButtonHolder"],
			})

			Components["CategoryHolder"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Name = Tab.Name,
				Parent = Window.Components["Categorys"],
				Visible = false,
			})

			Components["CategoryListLayout"] = Globals:Instance("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "CategoryHolderLayout",
				Parent = Components["CategoryHolder"],
			})
		end

		do -- Connections
			local TabButton = Components["NewTabButtonHolder"]
			Library:Connection("TabHandler_" .. Tab.Name, TabButton.MouseButton1Down, function()
				Window:SetTab(Tab)
			end)
			Library:Connection("TabMouseEnter_" .. Tab.Name, Components.NewTabButtonHolder.MouseEnter, function()
				Globals:Tween(Components["TabImage"], TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					ImageColor3 = Color3.fromRGB(255, 255, 255),
				})
			end)
			Library:Connection("TabMouseLeave_" .. Tab.Name, Components.NewTabButtonHolder.MouseLeave, function()
				if Components["TabImage"]:GetAttribute("Opened") then return end
				Globals:Tween(Components["TabImage"], TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					ImageColor3 = Color3.fromRGB(126, 126, 126),
				})
			end)
		end

		function Tab:Category(CategoryData)
			local Category = {
				Name = CategoryData.Name,
				Sections = {},
				Parent = Tab,
				IsOpen = false,
			}
			Category.__index = Category
			local Components = {}

			Components["CategoryHolder"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 573, 0, 12),
				Name = CategoryData.Name,
				Parent = Components["CategoryHolder"],
				ClipsDescendants = true,
			})

			Components["CategoryTitleButton"] = Globals:Instance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(19, 19, 19),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				Name = "CategoryTitleButton",
				Parent = Components["CategoryHolder"],
				Text = "",
				AutoButtonColor = false,
			})

			Components["CategoryTitleCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 3),
				Parent = Components["CategoryTitleButton"],
			})

			Components["CategoryStroke"] = Globals:Instance("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(24, 24, 24),
				Parent = Components["CategoryTitleButton"],
			})

			Components["CategoryTitle"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = CategoryData.Name,
				TextColor3 = Color3.fromRGB(129, 129, 129),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -10, 1, 0),
				Parent = Components["CategoryTitleButton"],
			})

			Components["CategoryImage"] = Globals:Instance("ImageLabel", {
				Image = Library.DropdownImage,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 10, 0, 5),
				Parent = Components["CategoryTitleButton"],
			})

			Components["SectionHolder"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 28),
				Size = UDim2.new(1, 0, 0, 0),
				Parent = Components["CategoryHolder"],
			})

			Components["SectionListLayout"] = Globals:Instance("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Parent = Components["SectionHolder"],
			})

			Category.Components = Components

			table.insert(Tab.CategoryOrder, Category)

			-- Category expand/collapse
			Components["CategoryTitleButton"].MouseButton1Down:Connect(function()
				Category.IsOpen = not Category.IsOpen
				local TargetSize = Category.IsOpen and UDim2.new(0, 573, 0, 395) or UDim2.new(0, 573, 0, 12)
				Globals:Tween(Components["CategoryHolder"], TweenInfo.new(Library.CategoryTransitionSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = TargetSize,
				})
				Globals:Tween(Components["CategoryImage"], TweenInfo.new(Library.CategoryTransitionSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Rotation = Category.IsOpen and 90 or 0,
				})
			end)

			Tab.Categories[CategoryData.Name] = Category

			function Category:Section(SectionData)
				local Section = {
					Name = SectionData.Name,
					Side = SectionData.Side or "Left",
					Parent = Category,
				}
				Section.__index = Section
				local Components = {}

				Components["SectionHolder"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(18, 18, 18),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 275, 0, 28),
					Name = SectionData.Name,
					Parent = Components["SectionHolder"],
				})

				Components["SectionHolderCorner"] = Globals:Instance("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = Components["SectionHolder"],
				})

				Components["SectionStroke"] = Globals:Instance("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(24, 24, 24),
					Parent = Components["SectionHolder"],
				})

				Components["SectionTitle"] = Globals:Instance("TextLabel", {
					Font = Enum.Font.SourceSansSemibold,
					Text = SectionData.Name,
					TextColor3 = Color3.fromRGB(129, 129, 129),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Center,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20),
					Parent = Components["SectionHolder"],
				})

				Components["SectionSeperator"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 20),
					Size = UDim2.new(1, -10, 0, 1),
					Parent = Components["SectionHolder"],
				})

				Components["SectionSeperatorHolder"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, 0),
					ZIndex = 2,
					Parent = Components["SectionSeperator"],
				})

				Components["SectionSeperatorFrame"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(24, 24, 24),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 1),
					Name = "SectionSeperatorFrame",
					Parent = Components["SectionSeperatorHolder"],
				})

				Components["SectionElements"] = Globals:Instance("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 24),
					Size = UDim2.new(1, -10, 1, -24),
					Parent = Components["SectionHolder"],
				})

				Components["SectionElementsListLayout"] = Globals:Instance("UIListLayout", {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Components["SectionElements"],
				})

				Components["SectionElementsPadding"] = Globals:Instance("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					Parent = Components["SectionElements"],
				})

				Section.Components = Components
				table.insert(Category.Sections, Section)

				function Components:SetVisibility(visible)
					Components.SectionSeperatorHolder.Visible = visible
				end

				function Section:Toggle(ToggleData)
					local Toggle = {
						Name = ToggleData.Name,
						Flag = ToggleData.Flag,
						Value = false,
						Default = ToggleData.Default or false,
						Callback = ToggleData.Callback or function() end,
						Tooltip = ToggleData.Tooltip or nil,
						Risky = ToggleData.Risky,
						Class = "Toggle",
					}
					Toggle.__index = Toggle
					local Components = {}

					do -- Components
						Components["ToggleHolder"] = Globals:Instance("TextButton", {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = Toggle.Tooltip and UDim2.new(1, 0, 0, 38) or UDim2.new(1, 0, 0, 20),
							Name = "ToggleHolder",
							Parent = Section.Components["SectionElements"],
							Text = "",
							AutoButtonColor = false,
						})

						Components["ToggleTitle"] = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSansSemibold,
							Text = Toggle.Name,
							TextColor3 = not Toggle.Risky and Color3.fromRGB(129, 129, 129) or Color3.fromRGB(150, 14, 23),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 15),
							Name = "ToggleTitle",
							Parent = Components["ToggleHolder"],
						})

						Components["ToggleButton"] = Globals:Instance("TextLabel", {
							Text = "",
							TextSize = 14,
							BackgroundColor3 = Color3.fromRGB(11, 11, 11),
							BorderSizePixel = 0,
							Position = UDim2.new(1, -15, 0, 0),
							Size = UDim2.new(0, 15, 0, 15),
							Name = "ToggleButton",
							Parent = Components["ToggleHolder"],
						})

						Components["ToggleButtonCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["ToggleButton"],
						})

						Components["ToggleStroke"] = Globals:Instance("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(24, 24, 24),
							Parent = Components["ToggleButton"],
						})

						Components["ToggleDropshadowContainer"] = Globals:Instance("Frame", {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 0,
							Parent = Components["ToggleButton"],
						})

						Components["ToggleDropshadow"] = Globals:Instance("ImageLabel", {
							Image = Library.ShadowImage,
							ImageColor3 = Library.Theme.Accent,
							ImageTransparency = 0.5,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(49, 49, 450, 450),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(1, 27, 1, 27),
							ZIndex = 0,
							Visible = false,
							Parent = Components["ToggleDropshadowContainer"],
						})

						Components["ToggleTooltip"] = Toggle.Tooltip and Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSans,
							Text = Toggle.Tooltip,
							TextColor3 = Color3.fromRGB(84, 84, 84),
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0, 0, 0, 17),
							Size = UDim2.new(1, 0, 0, 20),
							Name = "ToggleTooltip",
							Parent = Components["ToggleHolder"],
						})
					end

					Toggle.Components = Components
					Library.Flags[Toggle.Flag] = Toggle

					Toggle.Value = Toggle.Default

					if Toggle.Default then
						Components["ToggleButton"].BackgroundColor3 = Library.Theme.Accent
						Components["ToggleDropshadow"].Visible = true
					end

					function Toggle:Set(bool)
						bool = bool or false
						self.Value = bool
						Components["ToggleButton"].BackgroundColor3 = bool and Library.Theme.Accent or Color3.fromRGB(11, 11, 11)
						Components["ToggleDropshadow"].Visible = bool
						Library:DoCallback(self.Callback, bool)
					end

					Components["ToggleHolder"].MouseButton1Down:Connect(function()
						Toggle:Set(not Toggle.Value)
					end)

					return Toggle
				end

				function Section:Slider(SliderData)
					local Slider = {
						Name = SliderData.Name,
						Flag = SliderData.Flag,
						Min = SliderData.Min or 0,
						Max = SliderData.Max or 100,
						Value = SliderData.Default or SliderData.Min or 0,
						Default = SliderData.Default or SliderData.Min or 0,
						Suffix = SliderData.Suffix or "",
						Increment = SliderData.Increment or 1,
						Callback = SliderData.Callback or function() end,
						Class = "Slider",
					}
					Slider.__index = Slider
					local Components = {}

					Components["SliderHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 38),
						Name = "SliderHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["SliderTopFrame"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 15),
						Parent = Components["SliderHolder"],
					})

					Components["SliderTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = SliderData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["SliderTopFrame"],
					})

					Components["SliderValue"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = Library:FormatValue(Slider.Increment, Slider.Value) .. Slider.Suffix,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Right,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["SliderTopFrame"],
					})

					Components["SliderBar"] = Globals:Instance("Frame", {
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 20),
						Size = UDim2.new(1, 0, 0, 4),
						Parent = Components["SliderHolder"],
					})

					Components["SliderBarCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(1, 0),
						Parent = Components["SliderBar"],
					})

					Components["SliderBarFill"] = Globals:Instance("Frame", {
						BackgroundColor3 = Library.Theme.Accent,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 0, 1, 0),
						Parent = Components["SliderBar"],
					})

					Components["SliderBarFillCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(1, 0),
						Parent = Components["SliderBarFill"],
					})

					Components["SliderButton"] = Globals:Instance("TextButton", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, -3, 0, -4),
						Size = UDim2.new(1, 6, 0, 12),
						Parent = Components["SliderBar"],
						Text = "",
						AutoButtonColor = false,
					})

					Slider.Components = Components
					Library.Flags[Slider.Flag] = Slider

					local function UpdateSlider(input)
						local BarSize = Components["SliderBar"].AbsoluteSize.X
						if BarSize <= 0 then return end
						local Percent = math.clamp((input.Position.X - Components["SliderBar"].AbsolutePosition.X) / BarSize, 0, 1)
						local RawValue = Slider.Min + (Slider.Max - Slider.Min) * Percent
						if Slider.Increment and Slider.Increment > 0 then
							RawValue = math.round(RawValue / Slider.Increment) * Slider.Increment
						end
						RawValue = math.clamp(RawValue, Slider.Min, Slider.Max)
						local Fraction = (RawValue - Slider.Min) / (Slider.Max - Slider.Min)
						Components["SliderBarFill"].Size = UDim2.new(Fraction, 0, 1, 0)
						Components["SliderValue"].Text = Library:FormatValue(Slider.Increment, RawValue) .. Slider.Suffix
						Slider.Value = RawValue
						Library:DoCallback(Slider.Callback, RawValue)
					end

					if Slider.Default ~= Slider.Min then
						local Fraction = (Slider.Default - Slider.Min) / (Slider.Max - Slider.Min)
						Components["SliderBarFill"].Size = UDim2.new(Fraction, 0, 1, 0)
					end

					local SliderDragging = false
					Components["SliderButton"].MouseButton1Down:Connect(function(input)
						SliderDragging = true
						UpdateSlider(input)
					end)
					Components["SliderButton"].MouseButton1Up:Connect(function()
						SliderDragging = false
					end)
					Components["SliderButton"].MouseLeave:Connect(function()
						SliderDragging = false
					end)
					Components["SliderButton"].InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							Components["SliderBarFill"].BackgroundColor3 = Library.Theme.AccentedHighlight
						end
					end)
					Components["SliderButton"].InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							Components["SliderBarFill"].BackgroundColor3 = Library.Theme.Accent
						end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if SliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
							UpdateSlider(input)
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							SliderDragging = false
						end
					end)

					function Slider:Set(val)
						val = math.clamp(val, Slider.Min, Slider.Max)
						local Fraction = (val - Slider.Min) / (Slider.Max - Slider.Min)
						Components["SliderBarFill"].Size = UDim2.new(Fraction, 0, 1, 0)
						Components["SliderValue"].Text = Library:FormatValue(Slider.Increment, val) .. Slider.Suffix
						Slider.Value = val
						Library:DoCallback(Slider.Callback, val)
					end

					return Slider
				end

				function Section:Button(ButtonData)
					local Button = {
						Name = ButtonData.Name,
						Callback = ButtonData.Callback or function() end,
						Class = "Button",
					}
					Button.__index = Button
					local Components = {}

					Components["ButtonHolder"] = Globals:Instance("TextButton", {
						BackgroundColor3 = Color3.fromRGB(13, 13, 13),
						BorderColor3 = Color3.fromRGB(24, 24, 24),
						BorderSizePixel = 1,
						Size = UDim2.new(1, 0, 0, 25),
						Name = "ButtonHolder",
						Parent = Section.Components["SectionElements"],
						Text = "",
						AutoButtonColor = false,
					})

					Components["ButtonCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["ButtonHolder"],
					})

					Components["ButtonTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = ButtonData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Center,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["ButtonHolder"],
					})

					Components["ButtonShadowHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 0,
						Parent = Components["ButtonHolder"],
					})

					Components["ButtonShadow"] = Globals:Instance("ImageLabel", {
						Image = Library.ShadowImage,
						ImageColor3 = Library.Theme.Accent,
						ImageTransparency = 0.5,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(49, 49, 450, 450),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 27, 1, 27),
						ZIndex = 0,
						Visible = false,
						Parent = Components["ButtonShadowHolder"],
					})

					Button.Components = Components

					Components["ButtonHolder"].MouseButton1Down:Connect(function()
						Library:DoCallback(Button.Callback)
					end)

					Components["ButtonHolder"].MouseEnter:Connect(function()
						Components["ButtonShadow"].Visible = true
					end)

					Components["ButtonHolder"].MouseLeave:Connect(function()
						Components["ButtonShadow"].Visible = false
					end)

					return Button
				end

				function Section:Dropdown(DropdownData)
					local Dropdown = {
						Name = DropdownData.Name,
						Flag = DropdownData.Flag,
						Options = DropdownData.Options or {},
						Value = DropdownData.Default or (DropdownData.Options and DropdownData.Options[1]) or "None",
						Default = DropdownData.Default or (DropdownData.Options and DropdownData.Options[1]) or "None",
						Callback = DropdownData.Callback or function() end,
						Class = "Dropdown",
					}
					Dropdown.__index = Dropdown
					local Components = {}
					local DropdownOpen = false

					Components["DropdownHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 35),
						Name = "DropdownHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["DropdownTop"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = Components["DropdownHolder"],
					})

					Components["DropdownTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = DropdownData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["DropdownTop"],
					})

					Components["DropdownButton"] = Globals:Instance("TextButton", {
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 18),
						Size = UDim2.new(1, 0, 0, 20),
						Parent = Components["DropdownHolder"],
						Text = "",
						AutoButtonColor = false,
					})

					Components["DropdownButtonCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["DropdownButton"],
					})

					Components["DropdownStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(24, 24, 24),
						Parent = Components["DropdownButton"],
					})

					Components["DropdownCurrent"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = Dropdown.Value,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 10, 0, 0),
						Size = UDim2.new(1, -30, 1, 0),
						Parent = Components["DropdownButton"],
					})

					Components["DropdownArrow"] = Globals:Instance("ImageLabel", {
						Image = Library.DropdownImage,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(1, -12, 0.5, 0),
						Size = UDim2.new(0, 12, 0, 12),
						Parent = Components["DropdownButton"],
					})

					Components["DropdownListHolder"] = Globals:Instance("ScrollingFrame", {
						CanvasSize = UDim2.new(1, 0, 0, 0),
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						ScrollBarImageTransparency = 1,
						ScrollBarThickness = 0,
						Active = true,
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 20),
						Size = UDim2.new(1, 0, 0, 0),
						Visible = false,
						ClipsDescendants = true,
						Parent = Components["DropdownHolder"],
					})

					Components["DropdownListLayout"] = Globals:Instance("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Components["DropdownListHolder"],
					})

					Components["DropdownListPadding"] = Globals:Instance("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						Parent = Components["DropdownListHolder"],
					})

					Dropdown.Components = Components
					Library.Flags[Dropdown.Flag] = Dropdown

					local function RefreshDropdown()
						for _, v in Components["DropdownListHolder"]:GetChildren() do
							if v:IsA("TextButton") then v:Destroy() end
						end
						for _, Option in DropdownData.Options do
							local OptionButton = Globals:Instance("TextButton", {
								BackgroundColor3 = Color3.fromRGB(13, 13, 13),
								BorderColor3 = Color3.fromRGB(24, 24, 24),
								BorderSizePixel = 1,
								Size = UDim2.new(1, 0, 0, 20),
								Name = Option,
								Text = "",
								AutoButtonColor = false,
								Parent = Components["DropdownListHolder"],
							})
							local OptionButtonCorner = Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Parent = OptionButton,
							})
							local OptionLabel = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Option,
								TextColor3 = Color3.fromRGB(129, 129, 129),
								TextSize = 14,
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								Parent = OptionButton,
							})
							OptionButton.MouseButton1Down:Connect(function()
								Dropdown:Set(Option)
							end)
						end
					end

					RefreshDropdown()

					local function SetOpen(bool)
						DropdownOpen = bool
						Components["DropdownListHolder"].Visible = bool
						local Count = #DropdownData.Options
						Components["DropdownListHolder"].Size = bool and UDim2.new(1, 0, 0, math.min(Count * 20 + 10, 20 * 5 + 10)) or UDim2.new(1, 0, 0, 0)
						Components["DropdownListHolder"].CanvasSize = UDim2.new(1, 0, 0, Count * 20 + 10)
					end

					Components["DropdownButton"].MouseButton1Down:Connect(function()
						SetOpen(not DropdownOpen)
					end)

					UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							local Success, Region = pcall(function()
								return Components["DropdownListHolder"].AbsolutePosition, Components["DropdownListHolder"].AbsoluteSize
							end)
							if Success and Region then
								local MousePos = Vector2.new(input.Position.X, input.Position.Y)
								local RegionPos, RegionSize = Region
								local Bounds = Rect.new(RegionPos.X, RegionPos.Y, RegionPos.X + RegionSize.X, RegionPos.Y + RegionSize.Y)
								if DropdownOpen and not Bounds:Contains(MousePos) then
									local ButtonPos = Components["DropdownButton"].AbsolutePosition
									local ButtonSize = Components["DropdownButton"].AbsoluteSize
									local ButtonBounds = Rect.new(ButtonPos.X, ButtonPos.Y, ButtonPos.X + ButtonSize.X, ButtonPos.Y + ButtonSize.Y)
									if not ButtonBounds:Contains(MousePos) then
										SetOpen(false)
									end
								end
							end
						end
					end)

					function Dropdown:Set(val)
						Dropdown.Value = val
						Components["DropdownCurrent"].Text = val
						for _, Child in Components["DropdownListHolder"]:GetChildren() do
							if Child:IsA("TextButton") then
								Child.BackgroundColor3 = Child.Name == val and Library.Theme.Accent or Color3.fromRGB(13, 13, 13)
							end
						end
						Library:DoCallback(Dropdown.Callback, val)
						SetOpen(false)
					end

					return Dropdown
				end

				function Section:Textbox(TextboxData)
					local Textbox = {
						Name = TextboxData.Name,
						Flag = TextboxData.Flag,
						Value = TextboxData.Default or "",
						Default = TextboxData.Default or "",
						Placeholder = TextboxData.Placeholder or "",
						Callback = TextboxData.Callback or function() end,
						Class = "TextBox",
					}
					Textbox.__index = Textbox
					local Components = {}

					Components["TextboxHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 35),
						Name = "TextboxHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["TextboxTop"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = Components["TextboxHolder"],
					})

					Components["TextboxTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = TextboxData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["TextboxTop"],
					})

					Components["TextboxBox"] = Globals:Instance("TextBox", {
						Font = Enum.Font.SourceSansSemibold,
						Text = TextboxData.Default or TextboxData.Placeholder or "",
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderColor3 = Color3.fromRGB(84, 84, 84),
						PlaceholderText = TextboxData.Placeholder or "",
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 18),
						Size = UDim2.new(1, 0, 0, 20),
						ClearTextOnFocus = false,
						Parent = Components["TextboxHolder"],
					})

					Components["TextboxCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["TextboxBox"],
					})

					Components["TextboxStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(24, 24, 24),
						Parent = Components["TextboxBox"],
					})

					Textbox.Components = Components
					Library.Flags[Textbox.Flag] = Textbox

					local function SetText(self)
						local Text = self.Text
						local tempString = Text:gsub("\n", "")
						self.Text = tempString
						Textbox.Value = tempString
						Library:DoCallback(Textbox.Callback, tempString)
					end

					Components["TextboxBox"].FocusLost:Connect(SetText)

					function Textbox:Set(val)
						val = tostring(val)
						Textbox.Value = val
						Components["TextboxBox"].Text = val
						Library:DoCallback(Textbox.Callback, val)
					end

					return Textbox
				end

				function Section:Colorpicker(ColorpickerData)
					local Colorpicker = {
						Name = ColorpickerData.Name,
						Flag = ColorpickerData.Flag,
						Value = { ColorpickerData.Default or Color3.fromRGB(255, 255, 255), 1 },
						Default = ColorpickerData.Default or Color3.fromRGB(255, 255, 255),
						Callback = ColorpickerData.Callback or function() end,
						Class = "Colorpicker",
					}
					Colorpicker.__index = Colorpicker
					local Components = {}
					local ColorpickerOpen = false
					local DraggingHue, DraggingColor, DraggingTransparency = false, false, false

					Components["ColorpickerHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 40),
						Name = "ColorpickerHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["ColorpickerTop"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = Components["ColorpickerHolder"],
					})

					Components["ColorpickerTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = ColorpickerData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["ColorpickerTop"],
					})

					Components["ColorpickerPreview"] = Globals:Instance("ImageLabel", {
						Image = Library.TransparencyImage,
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 6, 0, 6),
						Position = UDim2.new(0, 0, 0, 18),
						Size = UDim2.new(0, 20, 0, 20),
						Parent = Components["ColorpickerHolder"],
					})

					Components["ColorpickerPreviewColor"] = Globals:Instance("Frame", {
						BackgroundColor3 = Colorpicker.Value[1],
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["ColorpickerPreview"],
					})

					Components["ColorpickerPreviewCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["ColorpickerPreview"],
					})

					Components["ColorpickerPreviewColorCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["ColorpickerPreviewColor"],
					})

					Components["ColorpickerPreviewStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(24, 24, 24),
						Parent = Components["ColorpickerPreview"],
					})

					Components["ColorpickerDrop"] = Globals:Instance("Frame", {
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 24, 0, 18),
						Size = UDim2.new(1, -24, 0, 0),
						Visible = false,
						Parent = Components["ColorpickerHolder"],
					})

					Components["ColorpickerDropCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["ColorpickerDrop"],
					})

					Components["ColorpickerDropStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(24, 24, 24),
						Parent = Components["ColorpickerDrop"],
					})

					local function UpdateDropSize()
						local YSize = 0
						if ColorpickerOpen then
							YSize = 140 + 20 + 8 + 20
						end
						Components["ColorpickerDrop"].Size = UDim2.new(1, -24, 0, YSize)
					end

					Colorpicker.Components = Components
					Library.Flags[Colorpicker.Flag] = Colorpicker

					local function SetOpen(bool)
						ColorpickerOpen = bool
						Components["ColorpickerDrop"].Visible = bool
						UpdateDropSize()
					end

					Components["ColorpickerPreview"].InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							SetOpen(not ColorpickerOpen)
						end
					end)

					-- Color wheel
					do
						Components["ColorWheel"] = Globals:Instance("ImageLabel", {
							Image = Library.ColorwheelImage,
							Position = UDim2.new(0, 7, 0, 7),
							Size = UDim2.new(0, 140, 0, 140),
							Parent = Components["ColorpickerDrop"],
						})

						Components["ColorWheelSelection"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(0, 3, 0, 3),
							ZIndex = 10,
							Parent = Components["ColorpickerDrop"],
						})

						Components["ColorWheelSelectionCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(1, 0),
							Parent = Components["ColorWheelSelection"],
						})

						local WheelConnection
						local function UpdateColorWheel(input)
							local WheelPos = Components["ColorWheel"].AbsolutePosition
							local WheelSize = Components["ColorWheel"].AbsoluteSize
							local RelativePos = Vector2.new(
								math.clamp(input.Position.X - WheelPos.X, 0, WheelSize.X),
								math.clamp(input.Position.Y - WheelPos.Y, 0, WheelSize.Y)
							)
							local Center = WheelSize / 2
							local Distance = (RelativePos - Center).Magnitude
							local Radius = WheelSize.X / 2
							if Distance > Radius then
								RelativePos = Center + (RelativePos - Center).Unit * Radius
							end
							local Hue = math.atan2(RelativePos.Y - Center.Y, RelativePos.X - Center.X) / (math.pi * 2) + 0.5
							local Sat = (RelativePos - Center).Magnitude / Radius
							local Color = Color3.fromHSV(Hue % 1, math.clamp(Sat, 0, 1), 1)
							Components["ColorWheelSelection"].Position = UDim2.new(0, RelativePos.X - 1.5, 0, RelativePos.Y - 1.5)
							Colorpicker.Value[1] = Color
							Components["ColorpickerPreviewColor"].BackgroundColor3 = Color
							Library:DoCallback(Colorpicker.Callback, Colorpicker.Value)
						end

						Components["ColorWheel"].InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								DraggingColor = true
								UpdateColorWheel(input)
							end
						end)

						UserInputService.InputChanged:Connect(function(input)
							if DraggingColor and input.UserInputType == Enum.UserInputType.MouseMovement then
								UpdateColorWheel(input)
							end
						end)
					end

					-- Hue bar
					do
						Components["HueBar"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 152, 0, 7),
							Size = UDim2.new(0, 8, 0, 140),
							Parent = Components["ColorpickerDrop"],
						})

						Components["HueBarGradient"] = Globals:Instance("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
							}),
							Rotation = 270,
							Parent = Components["HueBar"],
						})

						Components["HueBarSelection"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 4, 0, 3),
							ZIndex = 10,
							Parent = Components["HueBar"],
						})

						Components["HueBarSelectionCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(1, 0),
							Parent = Components["HueBarSelection"],
						})

						local function UpdateHue(input)
							local BarPos = Components["HueBar"].AbsolutePosition
							local BarSize = Components["HueBar"].AbsoluteSize
							local RelativeY = math.clamp(input.Position.Y - BarPos.Y, 0, BarSize.Y)
							local Hue = RelativeY / BarSize.Y
							local _, Sat, Val = Colorpicker.Value[1]:ToHSV()
							local Color = Color3.fromHSV(Hue, Sat or 1, Val or 1)
							Components["HueBarSelection"].Position = UDim2.new(0, -2, 0, RelativeY - 1.5)
							Colorpicker.Value[1] = Color
							Components["ColorpickerPreviewColor"].BackgroundColor3 = Color
							Library:DoCallback(Colorpicker.Callback, Colorpicker.Value)
						end

						Components["HueBar"].InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								DraggingHue = true
								UpdateHue(input)
							end
						end)

						UserInputService.InputChanged:Connect(function(input)
							if DraggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
								UpdateHue(input)
							end
						end)
					end

					-- Transparency slider
					do
						Components["TransparencyBg"] = Globals:Instance("ImageLabel", {
							Image = Library.TransparencyImage,
							ScaleType = Enum.ScaleType.Tile,
							TileSize = UDim2.new(0, 6, 0, 6),
							Position = UDim2.new(0, 7, 0, 152),
							Size = UDim2.new(0, 140, 0, 8),
							Parent = Components["ColorpickerDrop"],
						})

						Components["TransparencyBar"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 1, 0),
							Parent = Components["TransparencyBg"],
						})

						Components["TransparencyGradient"] = Globals:Instance("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
							}),
							Parent = Components["TransparencyBar"],
						})

						Components["TransparencyCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(1, 0),
							Parent = Components["TransparencyBg"],
						})

						Components["TransparencySelection"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(0, 3, 1, 4),
							ZIndex = 10,
							Parent = Components["TransparencyBg"],
						})

						Components["TransparencySelectionCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(1, 0),
							Parent = Components["TransparencySelection"],
						})

						local function UpdateTransparency(input)
							local BarPos = Components["TransparencyBg"].AbsolutePosition
							local BarSize = Components["TransparencyBg"].AbsoluteSize
							local RelativeX = math.clamp(input.Position.X - BarPos.X, 0, BarSize.X)
							local Trans = 1 - (RelativeX / BarSize.X)
							Components["TransparencySelection"].Position = UDim2.new(0, RelativeX - 1.5, 0, -2)
							Colorpicker.Value[2] = Trans
							Library:DoCallback(Colorpicker.Callback, Colorpicker.Value)
						end

						Components["TransparencyBg"].InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								DraggingTransparency = true
								UpdateTransparency(input)
							end
						end)

						UserInputService.InputChanged:Connect(function(input)
							if DraggingTransparency and input.UserInputType == Enum.UserInputType.MouseMovement then
								UpdateTransparency(input)
							end
						end)
					end

					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingHue = false
							DraggingColor = false
							DraggingTransparency = false
						end
					end)

					function Colorpicker:Set(val)
						if type(val) == "table" and val[1] then
							Colorpicker.Value = val
							Components["ColorpickerPreviewColor"].BackgroundColor3 = val[1]
							Library:DoCallback(Colorpicker.Callback, val)
						end
					end

					return Colorpicker
				end

				function Section:Keybind(KeybindData)
					local Keybind = {
						Name = KeybindData.Name,
						Flag = KeybindData.Flag,
						Key = KeybindData.Key or nil,
						Mode = KeybindData.Mode or "Toggle",
						Callback = KeybindData.Callback or function() end,
						Value = false,
						Class = "Keybind",
					}
					Keybind.__index = Keybind
					local Components = {}
					local Binding = false

					Components["KeybindHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 35),
						Name = "KeybindHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["KeybindTop"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = Components["KeybindHolder"],
					})

					Components["KeybindTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = KeybindData.Name,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["KeybindTop"],
					})

					Components["KeybindButton"] = Globals:Instance("TextButton", {
						Font = Enum.Font.SourceSansSemibold,
						Text = KeybindData.Key and Library:FormatKeyName(KeybindData.Key.Value.Name) or "None",
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						BackgroundColor3 = Color3.fromRGB(11, 11, 11),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 18),
						Size = UDim2.new(1, 0, 0, 20),
						AutoButtonColor = false,
						Parent = Components["KeybindHolder"],
					})

					Components["KeybindButtonText"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = KeybindData.Key and Library:FormatKeyName(KeybindData.Key.Value.Name) or "None",
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["KeybindButton"],
					})

					Components["KeybindCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = Components["KeybindButton"],
					})

					Components["KeybindStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(24, 24, 24),
						Parent = Components["KeybindButton"],
					})

					Keybind.Components = Components
					Library.Flags[Keybind.Flag] = Keybind

					Components["KeybindButton"].MouseButton1Down:Connect(function()
						Binding = true
						Components["KeybindButtonText"].Text = "..."
					end)

					UserInputService.InputBegan:Connect(function(input)
						if not Binding then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Binding = false
							Keybind:SetKey(input)
						elseif input.UserInputType.Name:match("Mouse") then
							Binding = false
							Keybind:SetKey(input)
						end
					end)

					if Keybind.Key then
						Keybind:SetKey(Keybind.Key)
					end

					function Keybind:SetKey(input)
						self.Key = input
						local Name = input.UserInputType == Enum.UserInputType.Keyboard and Library:FormatKeyName(input.KeyCode.Name) or input.UserInputType.Name
						Components["KeybindButtonText"].Text = Name
					end

					return Keybind
				end

				function Section:Paragraph(ParagraphData)
					local Paragraph = {
						Name = ParagraphData.Name,
						Text = ParagraphData.Text or ParagraphData.Content or "",
						Class = "Paragraph",
					}
					Paragraph.__index = Paragraph
					local Components = {}

					Components["ParagraphHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 0),
						Name = "ParagraphHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["ParagraphText"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSans,
						Text = Paragraph.Text,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						Parent = Components["ParagraphHolder"],
					})

					Paragraph.Components = Components
					return Paragraph
				end

				function Section:Label(LabelData)
					local Label = {
						Name = LabelData.Name,
						Text = LabelData.Text or LabelData.Content or LabelData.Name,
						Class = "Label",
					}
					Label.__index = Label
					local Components = {}

					Components["LabelHolder"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 20),
						Name = "LabelHolder",
						Parent = Section.Components["SectionElements"],
					})

					Components["LabelText"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = Label.Text,
						TextColor3 = Color3.fromRGB(129, 129, 129),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = Components["LabelHolder"],
					})

					Label.Components = Components
					return Label
				end

				function Section:Seperator()
					local Components = {}
					Components["SectionSeperatorHolder"] = Globals:Instance("Frame", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 0, 0, 0),
						ZIndex = 2,
						Parent = Section.Components["SectionSeperator"],
					})
					Components["SectionSeperatorFrame"] = Globals:Instance("Frame", {
						BackgroundColor3 = Color3.fromRGB(24, 24, 24),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 1),
						Name = "SectionSeperatorFrame",
						Parent = Components["SectionSeperatorHolder"],
					})
					return Components
				end

				-- Auto-size the section holder
				local function SizeSection()
					local YSize = 24
					for _, Child in Section.Components["SectionElements"]:GetChildren() do
						if Child:IsA("Frame") then
							YSize = YSize + Child.AbsoluteSize.Y + 5
						end
					end
					Section.Components["SectionHolder"].Size = UDim2.new(0, 275, 0, YSize)
				end

				local SizeConnection = Section.Components["SectionElements"].ChildAdded:Connect(function()
					task.wait()
					SizeSection()
				end)

				local SizeConnection2 = Section.Components["SectionElements"].ChildRemoved:Connect(function()
					task.wait()
					SizeSection()
				end)

				return Section
			end

			table.insert(Tab.Categories, Category)
			return Category
		end

		table.insert(Window.Tabs, Tab)
		return Tab
	end

	Window.Components = Components
	Library.Window = Window
	return Window
end

function Library:Notify(txt, duration, color)
	duration = duration or 3
	color = color or Color3.fromRGB(63, 201, 176)
	local Components = {}
	local Padding = 12
	local IconSize = 25
	local TextPadding = 5
	local LabelFontSize = 14
	local BottomBufferSize = 4

	local TemporaryLabel = Instance.new("TextLabel")
	TemporaryLabel.Size = UDim2.new(1, 0, 1, 0)
	TemporaryLabel.TextSize = LabelFontSize
	TemporaryLabel.Font = Enum.Font.SourceSansBold
	TemporaryLabel.Text = txt
	TemporaryLabel.TextWrapped = true
	TemporaryLabel.Parent = Library.Notifications
	TemporaryLabel.Visible = false
	task.wait()
	local TextBounds = TemporaryLabel.TextBounds
	TemporaryLabel:Destroy()

	local NotificationHeight = math.max(TextBounds.Y + BottomBufferSize, IconSize)
	local NotificationWidth = IconSize + TextBounds.X + TextPadding * 2

	local YPosition = 75
	for _, NotificationData in ipairs(Library.NotificationList) do
		YPosition = YPosition + NotificationData.Height + Padding
	end

	Components["NewNotification"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		BorderSizePixel = 0,
		Position = UDim2.new(0, -NotificationWidth - 20, 0, YPosition),
		Size = UDim2.new(0, NotificationWidth, 0, NotificationHeight),
		Parent = Library.Notifications,
	})

	Components["NotificationCorner"] = Globals:Instance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = Components["NewNotification"],
	})

	Components["NotificationStroke"] = Globals:Instance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(24, 24, 24),
		Parent = Components["NewNotification"],
	})

	Components["NotificationSideLine"] = Globals:Instance("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 1, -10),
		Parent = Components["NewNotification"],
	})

	Components["NotificationText"] = Globals:Instance("TextLabel", {
		Font = Enum.Font.SourceSansBold,
		RichText = true,
		Text = txt,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = LabelFontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -10, 1, 0),
		Parent = Components["NewNotification"],
	})

	table.insert(Library.NotificationList, {
		Height = NotificationHeight,
		Components = Components,
	})

	Globals:Tween(Components["NewNotification"], TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 10, 0, YPosition),
	})

	task.delay(duration, function()
		if not Components["NewNotification"] then return end
		Globals:Tween(Components["NewNotification"], TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, -NotificationWidth - 20, 0, YPosition),
		})
		task.delay(0.5, function()
			if not Components["NewNotification"] then return end
			Components["NewNotification"]:Destroy()
			table.remove(Library.NotificationList, 1)
		end)
	end)
end

return Library
