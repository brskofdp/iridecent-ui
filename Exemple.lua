--[[
	Iridescent UI Library - Usage Example
	
	How to use:
	1. Upload Source.lua to GitHub and get the raw URL
	2. Replace the URL below with your raw GitHub link
	3. Run this script in your executor
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/Source.lua"))()

-- Create main window
local Window = Library:Window({
	Name = "My Script",
})

-- Create tabs (icons are optional, use rbxassetid or leave blank)
local Pages = {
	Main = Window:Tab({
		Name = "Main",
		Image = "", -- optional: "rbxassetid://..."
	}),
	
	Settings = Window:Tab({
		Name = "Settings",
		Image = "",
	}),
}

-- Add tab separator
Window:TabSeperator()

local Misc = Window:Tab({
	Name = "Misc",
	Image = "",
})

-- Create categories inside tabs
local MainCategories = {
	Player = Pages.Main:Category({
		Name = "Player",
	}),
	
	Combat = Pages.Main:Category({
		Name = "Combat",
	}),
}

-- Add sections inside categories (Side: "Left" or "Right")
local PlayerSection = MainCategories.Player:Section({
	Name = "Movement",
	Side = "Left",
})

-- Toggle
PlayerSection:Toggle({
	Name = "Fly",
	Flag = "Fly",
	Default = false,
	Callback = function(Value)
		print("Fly:", Value)
	end,
})

-- Toggle with tooltip
PlayerSection:Toggle({
	Name = "Speed",
	Flag = "Speed",
	Default = true,
	Tooltip = "Increases movement speed",
	Callback = function(Value)
		print("Speed:", Value)
	end,
})

-- Slider
PlayerSection:Slider({
	Name = "WalkSpeed",
	Flag = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Suffix = "s",
	Increment = 1,
	Callback = function(Value)
		print("WalkSpeed:", Value)
	end,
})

-- Dropdown
PlayerSection:Dropdown({
	Name = "Mode",
	Flag = "Mode",
	Options = { "Normal", "Silent", "Memory" },
	Default = "Normal",
	Callback = function(Value)
		print("Mode:", Value)
	end,
})

-- Button
PlayerSection:Button({
	Name = "Click Me",
	Callback = function()
		print("Button clicked!")
		Library:Notify("Button was pressed!", 3)
	end,
})

-- Separator
PlayerSection:Seperator()

-- Keybind
PlayerSection:Keybind({
	Name = "Toggle GUI",
	Flag = "ToggleGUI",
	Key = nil, -- nil = user must set it
	Mode = "Toggle",
	Callback = function()
		print("Keybind pressed!")
	end,
})

-- Textbox
PlayerSection:Textbox({
	Name = "Message",
	Flag = "Message",
	Default = "Hello!",
	Placeholder = "Type here...",
	Callback = function(Value)
		print("Text:", Value)
	end,
})

-- Colorpicker
local VisualsSection = MainCategories.Player:Section({
	Name = "Visuals",
	Side = "Right",
})

VisualsSection:Colorpicker({
	Name = "Crosshair Color",
	Flag = "CrosshairColor",
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(Value)
		print("Color:", Value[1], "Transparency:", Value[2])
	end,
})

-- Label
VisualsSection:Label({
	Name = "Info",
	Text = "This is a label showing information",
})

-- Paragraph
VisualsSection:Paragraph({
	Name = "Description",
	Text = "This is a paragraph element that supports longer text and will automatically wrap to multiple lines.",
})

-- Notifications
Library:Notify("Script loaded!", 3, Color3.fromRGB(63, 201, 176))

-- Config example (requires writefile/readfile support)
-- Library:SaveConfig("MyConfig")
-- Library:LoadConfig("MyConfig")

-- Access flags anytime
local FlyFlag = Library.Flags["Fly"]
if FlyFlag then
	print("Fly flag value:", FlyFlag.Value)
end

-- Change flag value programmatically
task.wait(2)
if FlyFlag then
	FlyFlag:Set(true)
end
