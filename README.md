# Iridescent UI Library

A Roblox UI library extracted from the Iridescent script. Provides a clean, modern UI framework for executor scripts.

## Installation

1. Upload `Source.lua` to a GitHub repository
2. Get the raw URL (e.g. `https://raw.githubusercontent.com/username/repo/main/Source.lua`)
3. Load it in your script:

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()
```

## Quick Start

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:Window({
    Name = "My Script",
})

local Tab = Window:Tab({
    Name = "Main",
    Image = "", -- optional: "rbxassetid://..."
})

local Category = Tab:Category({
    Name = "Player",
})

local Section = Category:Section({
    Name = "Movement",
    Side = "Left",
})

Section:Toggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = false,
    Callback = function(Value) end,
})

Section:Slider({
    Name = "Speed",
    Flag = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Increment = 1,
    Callback = function(Value) end,
})
```

## API Reference

### Library:Window(data)
Creates the main window.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Window name |

### Window:Tab(data)
Creates a tab on the left sidebar.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Tab name |
| `Image` | string | rbxassetid for icon (optional) |

### Window:TabSeperator()
Adds a visual separator between tabs.

### Tab:Category(data)
Creates a collapsible category in the top bar.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Category name |

### Category:Section(data)
Creates a section (panel) inside a category.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Section title |
| `Side` | string | `"Left"` or `"Right"` |

### Section:Toggle(data)
Creates a toggle switch.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier for flags/config |
| `Default` | boolean | Initial state (optional) |
| `Callback` | function | Called with `(bool)` when toggled |
| `Tooltip` | string | Hover tooltip (optional) |
| `Risky` | boolean | If true, name shows in red (optional) |

### Section:Slider(data)
Creates a slider.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier |
| `Min` | number | Minimum value |
| `Max` | number | Maximum value |
| `Default` | number | Initial value (optional) |
| `Suffix` | string | Text appended to value (e.g. `"px"`) |
| `Increment` | number | Step size |
| `Callback` | function | Called with `(number)` on change |

### Section:Button(data)
Creates a clickable button.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Button text |
| `Callback` | function | Called on click |

### Section:Dropdown(data)
Creates a dropdown selector.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier |
| `Options` | table | Array of string options |
| `Default` | string | Initial selection (optional) |
| `Callback` | function | Called with `(string)` on selection |

### Section:Textbox(data)
Creates a text input field.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier |
| `Default` | string | Initial text (optional) |
| `Placeholder` | string | Placeholder text (optional) |
| `Callback` | function | Called with `(string)` on blur |

### Section:Colorpicker(data)
Creates a color picker.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier |
| `Default` | Color3 | Initial color (optional) |
| `Callback` | function | Called with `({Color3, transparency})` |

### Section:Keybind(data)
Creates a keybind selector.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Label text |
| `Flag` | string | Unique identifier |
| `Key` | table | Initial key (optional, set to nil) |
| `Mode` | string | `"Toggle"` or `"Hold"` |
| `Callback` | function | Called on key press |

### Section:Paragraph(data)
Creates a multi-line text block.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Internal name |
| `Text` | string | Content text |

### Section:Label(data)
Creates a single-line label.

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Internal name |
| `Text` | string | Display text |

### Section:Seperator()
Adds a visual separator line inside a section.

### Library:Notify(text, duration, color)
Shows a notification.

| Field | Type | Description |
|-------|------|-------------|
| `text` | string | Notification message |
| `duration` | number | Seconds to display (default 3) |
| `color` | Color3 | Accent color (default teal) |

### Library:SaveConfig(name)
Saves all flag values to a JSON file.

```lua
Library:SaveConfig("MyConfig")
```

### Library:LoadConfig(name)
Loads flag values from a JSON file.

```lua
Library:LoadConfig("MyConfig")
```

### Accessing Flag Values

All UI elements with a `Flag` are registered in `Library.Flags`:

```lua
local toggle = Library.Flags["MyFlag"]
print(toggle.Value) -- current value
toggle:Set(true)    -- set value programmatically
```

## Notes

- The window toggles with **RightShift** key by default
- Right-click the window title bar to minimize/restore
- The window can be dragged by the top bar
- Images referenced by `Library.ShadowImage`, `Library.OutlineShadowImage`, etc. use rbxassetids - customize by changing those fields
- Config system requires an executor with `writefile`/`readfile` support
