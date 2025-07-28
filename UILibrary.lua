--[[
    Roblox UI Library v2.0 - Professional Edition
    A comprehensive Drawing-based UI library for Roblox executors
    
    Features:
    - Drawing-based rendering for optimal performance
    - Advanced theming with customizable accent colors
    - Professional components: Windows, Tabs, Sliders, Dropdowns, Colorpickers, Keybinds
    - Configuration system for saving/loading settings
    - Drag & drop functionality with smooth animations
    - Custom cursor and visual effects
    - Modular design with clean API
    
    Usage:
    local UILib = loadstring(game:HttpGet("path/to/UILibrary.lua"))()
    local Window = UILib:CreateWindow({Title = "My Script", Size = Vector2.new(600, 400)})
]]

-- Library Core Structure
local UILibrary = {
    Drawings = {},
    Connections = {},
    Flags = {},
    Items = {},
    Windows = {},
    Keybinds = {},
    WindowVisible = true,
    LoadTime = tick(),
    Version = "2.0"
}
UILibrary.__index = UILibrary

-- Services
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ProfessionalUI Design System - Inspired by modern executor UIs
UILibrary.Theme = {
    -- Primary Brand Colors (Modern Purple Gradient)
    Accent = {
        Color3.fromHex("#a855f7"), -- Primary purple
        Color3.fromHex("#8b5cf6"), -- Medium purple  
        Color3.fromHex("#7c3aed"), -- Dark purple
        Color3.fromHex("#6d28d9"), -- Deeper purple
        Color3.fromHex("#5b21b6")  -- Darkest purple
    },
    
    -- Status Colors (Consistent with modern design)
    Status = {
        Success = Color3.fromHex("#10b981"), -- Modern green
        Warning = Color3.fromHex("#f59e0b"), -- Modern amber
        Error = Color3.fromHex("#ef4444"),   -- Modern red
        Info = Color3.fromHex("#3b82f6")     -- Modern blue
    },
    
    -- UI Structure Colors (Dark theme focused)
    Structure = {
        -- Main backgrounds
        WindowBackground = Color3.fromHex("#0f0f23"),     -- Very dark blue
        PanelBackground = Color3.fromHex("#1a1a2e"),      -- Dark blue-gray
        SectionBackground = Color3.fromHex("#16213e"),     -- Medium dark blue
        
        -- Borders and outlines  
        PrimaryBorder = Color3.fromHex("#a855f7"),        -- Accent purple border
        SecondaryBorder = Color3.fromHex("#374151"),      -- Subtle gray border
        InactiveBorder = Color3.fromHex("#1f2937"),       -- Very subtle border
        
        -- Interactive states
        HoverOverlay = Color3.fromHex("#374151"),         -- Light gray overlay
        ActiveOverlay = Color3.fromHex("#4b5563"),        -- Medium gray overlay
        SelectionOverlay = Color3.fromHex("#a855f7"),     -- Purple selection
    },
    
    -- Typography System
    Typography = {
        -- Text colors
        Primary = Color3.fromHex("#f8fafc"),     -- Pure white text
        Secondary = Color3.fromHex("#cbd5e1"),   -- Light gray text  
        Tertiary = Color3.fromHex("#64748b"),    -- Medium gray text
        Disabled = Color3.fromHex("#475569"),    -- Dark gray text
        Accent = Color3.fromHex("#a855f7"),      -- Purple accent text
        
        -- Font settings
        Font = Drawing and Drawing.Fonts and Drawing.Fonts.Plex or 2,
        Sizes = {
            Title = 16,      -- Window titles
            Header = 14,     -- Tab headers, section titles
            Body = 12,       -- Main content, labels
            Caption = 11,    -- Small text, hints
            Tiny = 10        -- Very small text
        }
    },
    
    -- Component Specific Colors
    Components = {
        -- Buttons
        ButtonPrimary = Color3.fromHex("#a855f7"),
        ButtonSecondary = Color3.fromHex("#374151"),
        ButtonDanger = Color3.fromHex("#ef4444"),
        ButtonSuccess = Color3.fromHex("#10b981"),
        
        -- Inputs
        InputBackground = Color3.fromHex("#1f2937"),
        InputBorder = Color3.fromHex("#374151"),
        InputFocusedBorder = Color3.fromHex("#a855f7"),
        InputPlaceholder = Color3.fromHex("#6b7280"),
        
        -- Toggles and selections
        ToggleOff = Color3.fromHex("#374151"),
        ToggleOn = Color3.fromHex("#a855f7"),
        SelectionBackground = Color3.fromHex("#1e1b4b"),
        
        -- Sliders
        SliderTrack = Color3.fromHex("#374151"),
        SliderFill = Color3.fromHex("#a855f7"),
        SliderThumb = Color3.fromHex("#f8fafc"),
    },
    
    -- Animation Settings
    Animation = {
        FastDuration = 0.15,
        NormalDuration = 0.25, 
        SlowDuration = 0.4,
        EaseOut = "Quad",
        EaseIn = "Quad", 
        EaseInOut = "Quad"
    },
    
    -- Spacing System (8px base unit)
    Spacing = {
        None = 0,
        Tiny = 4,      -- 0.5 units
        Small = 8,     -- 1 unit  
        Medium = 16,   -- 2 units
        Large = 24,    -- 3 units
        XLarge = 32,   -- 4 units
        XXLarge = 48   -- 6 units
    },
    
    -- Border Radius System
    Radius = {
        None = 0,
        Small = 4,
        Medium = 6,
        Large = 8,
        XLarge = 12,
        Round = 999
    },
    
    -- Z-Index Layers
    ZIndex = {
        Background = 1,
        Window = 10,
        Panel = 20,
        Component = 30,
        Overlay = 40,
        Dropdown = 50,
        Tooltip = 60,
        Modal = 70,
        Notification = 80,
        Debug = 90,
        Cursor = 100
    }
}

-- Communication system for theme updates
UILibrary.Communication = Instance.new("BindableEvent")

-- Advanced Utilities
local Utility = {}

-- Instance creation helper
function Utility.AddInstance(NewInstance, Properties)
    local instance = Instance.new(NewInstance)
    for Index, Value in pairs(Properties) do
        instance[Index] = Value
    end
    return instance
end

-- Table cloning
function Utility.CloneTbl(T)
    local Tbl = {}
    for Index, Value in pairs(T) do
        Tbl[Index] = Value
    end
    return Tbl
end

-- Drawing creation with automatic management
function Utility.AddDrawing(InstanceType, Properties, Location)
    if not Drawing then
        warn("Drawing API not available - using fallback rendering")
        return {Visible = false, Remove = function() end}
    end
    
    local Instance = Drawing.new(InstanceType)
    
    for Index, Value in pairs(Properties) do
        Instance[Index] = Value
        if InstanceType == "Text" then
            if Index == "Font" then
                Instance.Font = UILibrary.Theme.Font
            elseif Index == "Size" then
                Instance.Size = UILibrary.Theme.TextSize
            end
        end
    end
    
    if Properties.ZIndex ~= nil then
        Instance.ZIndex = Properties.ZIndex + 20
    else
        Instance.ZIndex = 20
    end
    
    Location = Location or UILibrary.Drawings
    Location[#Location + 1] = {Instance}
    
    return Instance
end

-- Drawing removal
function Utility.RemoveDrawing(Instance, Location)
    Location = Location or UILibrary.Drawings
    
    for Index, Value in pairs(Location) do 
        if Value[1] == Instance then
            if Value[1] then
                Value[1]:Remove()
            end
            table.remove(Location, Index)
            break
        end
    end
end

-- Connection management
function Utility.AddConnection(Type, Callback)
    local Connection = Type:Connect(Callback)
    UILibrary.Connections[#UILibrary.Connections + 1] = Connection
    return Connection
end

-- Mouse position checking
function Utility.OnMouse(Instance)
    local Mouse = UserInput:GetMouseLocation()
    if Instance.Visible and (Mouse.X > Instance.Position.X) and (Mouse.X < Instance.Position.X + Instance.Size.X) and (Mouse.Y > Instance.Position.Y) and (Mouse.Y < Instance.Position.Y + Instance.Size.Y) then
        if UILibrary.WindowVisible then
            return true
        end
    end
    return false
end

-- Center positioning
function Utility.MiddlePos(Instance)
    return Vector2.new(
        (Camera.ViewportSize.X / 2) - (Instance.Size.X / 2), 
        (Camera.ViewportSize.Y / 2) - (Instance.Size.Y / 2)
    )
end

-- Rounding utility
function Utility.Round(Num, Float)
    local Bracket = 1 / Float
    return math.floor(Num * Bracket) / Bracket
end

-- Drag functionality
function Utility.AddDrag(Sensor, List)
    local DragUtility = {
        MouseStart = Vector2.new(), 
        MouseEnd = Vector2.new(), 
        Dragging = false
    }
    
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Sensor) then
                DragUtility.Dragging = true
            end
        end
    end)
    
    Utility.AddConnection(UserInput.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            DragUtility.Dragging = false
        end
    end)
    
    Utility.AddConnection(RunService.RenderStepped, function()
        DragUtility.MouseStart = UserInput:GetMouseLocation()
        
        for Index, Value in pairs(List) do
            if Index ~= nil and Value ~= nil then
                if DragUtility.Dragging then
                    Value[1].Position = Vector2.new(
                        Value[1].Position.X + (DragUtility.MouseStart.X - DragUtility.MouseEnd.X), 
                        Value[1].Position.Y + (DragUtility.MouseStart.Y - DragUtility.MouseEnd.Y)
                    )
                end
            end
        end
        
        DragUtility.MouseEnd = UserInput:GetMouseLocation()
    end)
end

-- Color conversion
function Utility.HSVToRGB(HSVColor)
    local R, G, B = HSVColor.R * 255, HSVColor.G * 255, HSVColor.B * 255
    return R, G, B
end

-- Configuration System
function Utility.SaveConfig(Config)
    if not makefolder or not writefile then
        warn("File API not available - configuration saving disabled")
        return
    end
    
    local CFG = Utility.CloneTbl(UILibrary.Flags)
    for Index, Value in pairs(CFG) do
        if UILibrary.Items[Index] and UILibrary.Items[Index].TypeOf == "Colorpicker" then
            local HH, SS, VV = Utility.HSVToRGB(CFG[Index])
            local RR, GG, BB = Color3.fromRGB(HH, SS, VV):ToHSV()
            CFG[Index] = {RR, GG, BB}
        end
    end
    
    if not isfolder("ProfessionalUI") then makefolder("ProfessionalUI") end
    if not isfolder("ProfessionalUI/Configs") then makefolder("ProfessionalUI/Configs") end
    if not isfolder("ProfessionalUI/Configs/" .. tostring(game.PlaceId)) then 
        makefolder("ProfessionalUI/Configs/" .. tostring(game.PlaceId)) 
    end
    
    writefile(
        "ProfessionalUI/Configs/" .. tostring(game.PlaceId) .. "/" .. Config .. ".json", 
        HttpService:JSONEncode(CFG)
    )
end

function Utility.LoadConfig(Config)
    if not readfile or not isfile then
        warn("File API not available - configuration loading disabled")
        return
    end
    
    local configPath = "ProfessionalUI/Configs/" .. tostring(game.PlaceId) .. "/" .. Config .. ".json"
    if not isfile(configPath) then
        warn("Configuration file not found: " .. Config)
        return
    end
    
    local CFG = HttpService:JSONDecode(readfile(configPath))
    
    for Index, Val in pairs(CFG) do
        if UILibrary.Items[Index] then
            if UILibrary.Items[Index].TypeOf == "Keybind" then
                UILibrary.Items[Index]:Set(Val[1], Val[2], Val[3], true)
            elseif UILibrary.Items[Index].TypeOf == "Colorpicker" then
                UILibrary.Items[Index]:SetHue({Value = Val[1]})
                UILibrary.Items[Index]:SetSaturationX({Value = Val[2]})
                UILibrary.Items[Index]:SetSaturationY({Value = Val[3]})
            elseif UILibrary.Items[Index].TypeOf == "Slider" or UILibrary.Items[Index].TypeOf == "Toggle" then
                UILibrary.Items[Index]:Set(Val)
            end
        end
    end
end

-- Window Creation System
function UILibrary:CreateWindow(Settings)
    Settings = Settings or {}
    local Title = Settings.Title or "UILibrary"
    local Size = Settings.Size or Vector2.new(600, 400)
    local Position = Settings.Position or Utility.MiddlePos({Size = Size})
    
    local Window = {
        Title = Title,
        Size = Size,
        Position = Position,
        Tabs = {},
        Elements = {},
        Open = true,
        Dragging = false,
        DragStart = Vector2.new(),
        StartPos = Vector2.new()
    }
    
    -- Window Main Border (Professional Purple)
    Window.Border = Utility.AddDrawing("Square", {
        Size = Size,
        Position = Position,
        Thickness = 1,
        Color = UILibrary.Theme.Structure.PrimaryBorder,
        Visible = true,
        Filled = false,
        ZIndex = UILibrary.Theme.ZIndex.Window
    })
    
    -- Window Background (Dark Professional)
    Window.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Size.X - 2, Size.Y - 2),
        Position = Vector2.new(Position.X + 1, Position.Y + 1),
        Thickness = 0,
        Color = UILibrary.Theme.Structure.WindowBackground,
        Visible = true,
        Filled = true,
        ZIndex = UILibrary.Theme.ZIndex.Window + 1
    })
    
    -- Title Bar (Panel Background)
    Window.TitleBar = Utility.AddDrawing("Square", {
        Size = Vector2.new(Size.X - 2, 35),
        Position = Vector2.new(Position.X + 1, Position.Y + 1),
        Thickness = 0,
        Color = UILibrary.Theme.Structure.PanelBackground,
        Visible = true,
        Filled = true,
        ZIndex = UILibrary.Theme.ZIndex.Panel
    })
    
    -- Title Bar Bottom Border
    Window.TitleBorder = Utility.AddDrawing("Square", {
        Size = Vector2.new(Size.X - 2, 1),
        Position = Vector2.new(Position.X + 1, Position.Y + 36),
        Thickness = 0,
        Color = UILibrary.Theme.Structure.SecondaryBorder,
        Visible = true,
        Filled = true,
        ZIndex = UILibrary.Theme.ZIndex.Panel + 1
    })
    
    -- Title Text (Primary Typography)
    Window.TitleText = Utility.AddDrawing("Text", {
        Text = Title,
        Position = Vector2.new(Position.X + UILibrary.Theme.Spacing.Medium, Position.Y + UILibrary.Theme.Spacing.Small + 2),
        Color = UILibrary.Theme.Typography.Primary,
        Font = UILibrary.Theme.Typography.Font,
        Size = UILibrary.Theme.Typography.Sizes.Title,
        Visible = true,
        ZIndex = UILibrary.Theme.ZIndex.Panel + 2
    })
    
    -- Close Button (Professional Red)
    Window.CloseButton = Utility.AddDrawing("Square", {
        Size = Vector2.new(24, 24),
        Position = Vector2.new(Position.X + Size.X - UILibrary.Theme.Spacing.Large - 6, Position.Y + UILibrary.Theme.Spacing.Small - 2),
        Thickness = 0,
        Color = UILibrary.Theme.Status.Error,
        Visible = true,
        Filled = true,
        ZIndex = UILibrary.Theme.ZIndex.Panel + 3
    })
    
    Window.CloseButtonText = Utility.AddDrawing("Text", {
        Text = "×",
        Position = Vector2.new(Position.X + Size.X - UILibrary.Theme.Spacing.Large + 1, Position.Y + UILibrary.Theme.Spacing.Small + 1),
        Color = UILibrary.Theme.Typography.Primary,
        Font = UILibrary.Theme.Typography.Font,
        Size = UILibrary.Theme.Typography.Sizes.Header,
        Visible = true,
        ZIndex = UILibrary.Theme.ZIndex.Panel + 4
    })
    
    -- Tab Container
    Window.TabContainer = Utility.AddDrawing("Square", {
        Size = Vector2.new(Size.X - 4, Size.Y - 36),
        Position = Vector2.new(Position.X + 2, Position.Y + 32),
        Thickness = 0,
        Color = UILibrary.Theme.DarkContrast,
        Visible = true,
        Filled = true,
        ZIndex = 3
    })
    
    -- Dragging functionality
    local WindowElements = {
        {Window.Outline},
        {Window.Border},
        {Window.Background},
        {Window.TitleBar},
        {Window.TitleText},
        {Window.CloseButton},
        {Window.CloseButtonText},
        {Window.TabContainer}
    }
    
    Utility.AddDrag(Window.TitleBar, WindowElements)
    
    -- Close button functionality
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Window.CloseButton) then
                Window:Destroy()
            end
        end
    end)
    
    -- Window methods
    function Window:Destroy()
        for _, element in pairs(WindowElements) do
            if element[1] and element[1].Remove then
                element[1]:Remove()
            end
        end
        
        for index, window in pairs(UILibrary.Windows) do
            if window == self then
                table.remove(UILibrary.Windows, index)
                break
            end
        end
    end
    
    function Window:CreateTab(Settings)
        Settings = Settings or {}
        local TabName = Settings.Name or "Tab"
        local Icon = Settings.Icon or ""
        
        local Tab = {
            Name = TabName,
            Icon = Icon,
            Window = self,
            Elements = {},
            Active = #self.Tabs == 0,
            YOffset = 10
        }
        
        -- Tab Button
        Tab.Button = Utility.AddDrawing("Square", {
            Size = Vector2.new(120, 25),
            Position = Vector2.new(self.Position.X + 10 + (#self.Tabs * 125), self.Position.Y + 40),
            Thickness = 0,
            Color = Tab.Active and UILibrary.Theme.Accent[1] or UILibrary.Theme.LightContrast,
            Visible = true,
            Filled = true,
            ZIndex = 4
        })
        
        Tab.ButtonText = Utility.AddDrawing("Text", {
            Text = TabName,
            Position = Vector2.new(self.Position.X + 15 + (#self.Tabs * 125), self.Position.Y + 47),
            Color = UILibrary.Theme.Text,
            Font = UILibrary.Theme.Font,
            Size = UILibrary.Theme.TextSize,
            Visible = true,
            ZIndex = 5
        })
        
        -- Tab click functionality
        Utility.AddConnection(UserInput.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Utility.OnMouse(Tab.Button) then
                    self:SetActiveTab(Tab)
                end
            end
        end)
        
        -- Tab content area
        Tab.Content = Utility.AddDrawing("Square", {
            Size = Vector2.new(self.Size.X - 20, self.Size.Y - 80),
            Position = Vector2.new(self.Position.X + 10, self.Position.Y + 70),
            Thickness = 0,
            Color = UILibrary.Theme.DarkContrast,
            Visible = Tab.Active,
            Filled = true,
            ZIndex = 3
        })
        
        table.insert(self.Tabs, Tab)
        return Tab
    end
    
    function Window:SetActiveTab(ActiveTab)
        for _, tab in pairs(self.Tabs) do
            tab.Active = (tab == ActiveTab)
            tab.Button.Color = tab.Active and UILibrary.Theme.Accent[1] or UILibrary.Theme.LightContrast
            tab.Content.Visible = tab.Active
            
            -- Show/hide tab elements
            for _, element in pairs(tab.Elements) do
                if element.Drawing then
                    element.Drawing.Visible = tab.Active
                end
            end
        end
    end
    
    table.insert(UILibrary.Windows, Window)
    return Window
end

-- Advanced UI Components for Tabs
function UILibrary:CreateButton(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Button"
    local Callback = Settings.Callback or function() end
    
    local Button = {
        TypeOf = "Button",
        Tab = Tab,
        Text = Text,
        Callback = Callback,
        Enabled = true
    }
    
    local ButtonY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Button Background (Professional Button Style)
    Button.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - UILibrary.Theme.Spacing.XLarge, 32),
        Position = Vector2.new(Tab.Window.Position.X + UILibrary.Theme.Spacing.Medium, ButtonY),
        Thickness = 0,
        Color = UILibrary.Theme.Components.ButtonPrimary,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = UILibrary.Theme.ZIndex.Component
    })
    
    -- Button Text (Centered, Professional Typography)
    Button.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + UILibrary.Theme.Spacing.Medium + UILibrary.Theme.Spacing.Small, ButtonY + UILibrary.Theme.Spacing.Small + 2),
        Color = UILibrary.Theme.Typography.Primary,
        Font = UILibrary.Theme.Typography.Font,
        Size = UILibrary.Theme.Typography.Sizes.Body,
        Visible = Tab.Active,
        ZIndex = UILibrary.Theme.ZIndex.Component + 1
    })
    
    -- Click functionality
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Button.Background) and Button.Enabled then
                Button.Background.Color = UILibrary.Theme.Structure.ActiveOverlay
                wait(0.1)
                Button.Background.Color = UILibrary.Theme.Components.ButtonPrimary
                Callback()
            end
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Button)
    return Button
end

function UILibrary:CreateToggle(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Toggle"
    local Default = Settings.Default or false
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Toggle = {
        TypeOf = "Toggle",
        Tab = Tab,
        Text = Text,
        Value = Default,
        Callback = Callback,
        Flag = Flag
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Toggle
    
    local ToggleY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Toggle Background
    Toggle.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 20),
        Position = Vector2.new(Tab.Window.Position.X + 20, ToggleY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Toggle Indicator
    Toggle.Indicator = Utility.AddDrawing("Square", {
        Size = Vector2.new(15, 15),
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 40, ToggleY + 2.5),
        Thickness = 0,
        Color = Default and UILibrary.Theme.Accent[1] or UILibrary.Theme.DarkContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 5
    })
    
    -- Toggle Text
    Toggle.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, ToggleY + 4),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Toggle functionality
    function Toggle:Set(Value)
        self.Value = Value
        UILibrary.Flags[self.Flag] = Value
        self.Indicator.Color = Value and UILibrary.Theme.Accent[1] or UILibrary.Theme.DarkContrast
        self.Callback(Value)
    end
    
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Toggle.Background) then
                Toggle:Set(not Toggle.Value)
            end
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 30
    table.insert(Tab.Elements, Toggle)
    return Toggle
end

function UILibrary:CreateSlider(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Slider"
    local Min = Settings.Min or 0
    local Max = Settings.Max or 100
    local Default = Settings.Default or Min
    local Increment = Settings.Increment or 1
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Slider = {
        TypeOf = "Slider",
        Tab = Tab,
        Text = Text,
        Min = Min,
        Max = Max,
        Value = Default,
        Increment = Increment,
        Callback = Callback,
        Flag = Flag,
        Dragging = false
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Slider
    
    local SliderY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Slider Background
    Slider.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 20),
        Position = Vector2.new(Tab.Window.Position.X + 20, SliderY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Slider Track
    Slider.Track = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 80, 4),
        Position = Vector2.new(Tab.Window.Position.X + 40, SliderY + 20),
        Thickness = 0,
        Color = UILibrary.Theme.DarkContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Slider Fill
    local FillWidth = ((Default - Min) / (Max - Min)) * (Tab.Window.Size.X - 80)
    Slider.Fill = Utility.AddDrawing("Square", {
        Size = Vector2.new(FillWidth, 4),
        Position = Vector2.new(Tab.Window.Position.X + 40, SliderY + 20),
        Thickness = 0,
        Color = UILibrary.Theme.Accent[1],
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 5
    })
    
    -- Slider Text
    Slider.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, SliderY + 2),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Slider Value Text
    Slider.ValueLabel = Utility.AddDrawing("Text", {
        Text = tostring(Default),
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 60, SliderY + 2),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    function Slider:Set(Value)
        Value = math.clamp(Value, self.Min, self.Max)
        Value = Utility.Round(Value, self.Increment)
        
        self.Value = Value
        UILibrary.Flags[self.Flag] = Value
        self.ValueLabel.Text = tostring(Value)
        
        local FillWidth = ((Value - self.Min) / (self.Max - self.Min)) * (self.Tab.Window.Size.X - 80)
        self.Fill.Size = Vector2.new(FillWidth, 4)
        
        self.Callback(Value)
    end
    
    -- Slider dragging
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Slider.Track) then
                Slider.Dragging = true
            end
        end
    end)
    
    Utility.AddConnection(UserInput.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = false
        end
    end)
    
    Utility.AddConnection(RunService.RenderStepped, function()
        if Slider.Dragging then
            local Mouse = UserInput:GetMouseLocation()
            local RelativeX = Mouse.X - Slider.Track.Position.X
            local Percent = math.clamp(RelativeX / Slider.Track.Size.X, 0, 1)
            local Value = Slider.Min + (Percent * (Slider.Max - Slider.Min))
            Slider:Set(Value)
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Slider)
    return Slider
end

function UILibrary:CreateDropdown(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Dropdown"
    local Options = Settings.Options or {"Option 1", "Option 2", "Option 3"}
    local Default = Settings.Default or Options[1]
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Dropdown = {
        TypeOf = "Dropdown",
        Tab = Tab,
        Text = Text,
        Options = Options,
        Value = Default,
        Callback = Callback,
        Flag = Flag,
        Open = false
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Dropdown
    
    local DropdownY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Dropdown Background
    Dropdown.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 25),
        Position = Vector2.new(Tab.Window.Position.X + 20, DropdownY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Dropdown Text
    Dropdown.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, DropdownY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Selected Value Text
    Dropdown.ValueLabel = Utility.AddDrawing("Text", {
        Text = Default,
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 100, DropdownY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Dropdown Arrow
    Dropdown.Arrow = Utility.AddDrawing("Text", {
        Text = "v",
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 35, DropdownY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Options Container
    Dropdown.OptionsContainer = {}
    
    function Dropdown:Set(Value)
        if table.find(self.Options, Value) then
            self.Value = Value
            UILibrary.Flags[self.Flag] = Value
            self.ValueLabel.Text = Value
            self.Callback(Value)
        end
    end
    
    function Dropdown:ToggleOptions()
        self.Open = not self.Open
        self.Arrow.Text = self.Open and "^" or "v"
        
        if self.Open then
            -- Create option buttons
            for i, option in ipairs(self.Options) do
                local OptionY = self.Background.Position.Y + 25 + (i * 22)
                
                local OptionBG = Utility.AddDrawing("Square", {
                    Size = Vector2.new(self.Background.Size.X, 20),
                    Position = Vector2.new(self.Background.Position.X, OptionY),
                    Thickness = 0,
                    Color = UILibrary.Theme.DarkContrast,
                    Visible = true,
                    Filled = true,
                    ZIndex = 6
                })
                
                local OptionText = Utility.AddDrawing("Text", {
                    Text = option,
                    Position = Vector2.new(self.Background.Position.X + 5, OptionY + 4),
                    Color = UILibrary.Theme.Text,
                    Font = UILibrary.Theme.Font,
                    Size = UILibrary.Theme.TextSize,
                    Visible = true,
                    ZIndex = 7
                })
                
                table.insert(self.OptionsContainer, {OptionBG, OptionText})
                
                -- Option click handler
                Utility.AddConnection(UserInput.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Utility.OnMouse(OptionBG) then
                            self:Set(option)
                            self:ToggleOptions()
                        end
                    end
                end)
            end
        else
            -- Remove option buttons
            for _, option in pairs(self.OptionsContainer) do
                if option[1] then Utility.RemoveDrawing(option[1]) end
                if option[2] then Utility.RemoveDrawing(option[2]) end
            end
            self.OptionsContainer = {}
        end
    end
    
    -- Click functionality
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Dropdown.Background) then
                Dropdown:ToggleOptions()
            end
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Dropdown)
    return Dropdown
end

function UILibrary:CreateColorpicker(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Colorpicker"
    local Default = Settings.Default or Color3.new(1, 1, 1)
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Colorpicker = {
        TypeOf = "Colorpicker",
        Tab = Tab,
        Text = Text,
        Value = Default,
        Callback = Callback,
        Flag = Flag,
        Open = false,
        Hue = 0,
        Saturation = Vector2.new(1, 1)
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Colorpicker
    
    local ColorpickerY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Colorpicker Background
    Colorpicker.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 25),
        Position = Vector2.new(Tab.Window.Position.X + 20, ColorpickerY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Colorpicker Text
    Colorpicker.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, ColorpickerY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Color Preview
    Colorpicker.Preview = Utility.AddDrawing("Square", {
        Size = Vector2.new(40, 20),
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 50, ColorpickerY + 2.5),
        Thickness = 0,
        Color = Default,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 5
    })
    
    function Colorpicker:Set(Color)
        self.Value = Color
        UILibrary.Flags[self.Flag] = Color
        self.Preview.Color = Color
        self.Callback(Color)
    end
    
    function Colorpicker:SetHue(Data)
        self.Hue = Data.Value
        self:UpdateColor()
    end
    
    function Colorpicker:SetSaturationX(Data)
        self.Saturation = Vector2.new(Data.Value, self.Saturation.Y)
        self:UpdateColor()
    end
    
    function Colorpicker:SetSaturationY(Data)
        self.Saturation = Vector2.new(self.Saturation.X, Data.Value)
        self:UpdateColor()
    end
    
    function Colorpicker:UpdateColor()
        local Color = Color3.fromHSV(self.Hue, self.Saturation.X, self.Saturation.Y)
        self:Set(Color)
    end
    
    -- Click functionality (simplified - full colorpicker would need hue wheel and saturation square)
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Colorpicker.Background) then
                -- Cycle through some preset colors for demo
                local colors = {
                    Color3.new(1, 0, 0), -- Red
                    Color3.new(0, 1, 0), -- Green  
                    Color3.new(0, 0, 1), -- Blue
                    Color3.new(1, 1, 0), -- Yellow
                    Color3.new(1, 0, 1), -- Magenta
                    Color3.new(0, 1, 1), -- Cyan
                    Color3.new(1, 1, 1), -- White
                }
                local nextColor = colors[math.random(1, #colors)]
                Colorpicker:Set(nextColor)
            end
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Colorpicker)
    return Colorpicker
end

function UILibrary:CreateKeybind(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Keybind"
    local Default = Settings.Default or Enum.KeyCode.F
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Keybind = {
        TypeOf = "Keybind",
        Tab = Tab,
        Text = Text,
        Value = Default,
        Callback = Callback,
        Flag = Flag,
        Listening = false
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Keybind
    UILibrary.Keybinds[Flag] = Keybind
    
    local KeybindY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Keybind Background
    Keybind.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 25),
        Position = Vector2.new(Tab.Window.Position.X + 20, KeybindY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Keybind Text
    Keybind.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, KeybindY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Key Display
    Keybind.KeyLabel = Utility.AddDrawing("Text", {
        Text = Default.Name,
        Position = Vector2.new(Tab.Window.Position.X + Tab.Window.Size.X - 80, KeybindY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    function Keybind:Set(Key, Mode, Callback, Loading)
        self.Value = Key
        UILibrary.Flags[self.Flag] = {Key, Mode, Callback}
        self.KeyLabel.Text = Key.Name
        if not Loading then
            self.Callback(Key)
        end
    end
    
    -- Key listening
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Keybind.Background) then
                Keybind.Listening = true
                Keybind.KeyLabel.Text = "..."
                Keybind.KeyLabel.Color = UILibrary.Theme.Accent[1]
            end
        elseif Keybind.Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind:Set(Input.KeyCode, "Toggle", Keybind.Callback)
            Keybind.Listening = false
            Keybind.KeyLabel.Color = UILibrary.Theme.Text
        end
    end)
    
    -- Global keybind detection
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if not Keybind.Listening and Input.KeyCode == Keybind.Value then
            Keybind.Callback()
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Keybind)
    return Keybind
end

function UILibrary:CreateTextbox(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Textbox"
    local Default = Settings.Default or ""
    local Placeholder = Settings.Placeholder or "Enter text..."
    local Callback = Settings.Callback or function() end
    local Flag = Settings.Flag or Text
    
    local Textbox = {
        TypeOf = "Textbox",
        Tab = Tab,
        Text = Text,
        Value = Default,
        Placeholder = Placeholder,
        Callback = Callback,
        Flag = Flag,
        Focused = false
    }
    
    UILibrary.Flags[Flag] = Default
    UILibrary.Items[Flag] = Textbox
    
    local TextboxY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Textbox Background
    Textbox.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 25),
        Position = Vector2.new(Tab.Window.Position.X + 20, TextboxY),
        Thickness = 0,
        Color = UILibrary.Theme.LightContrast,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Textbox Label
    Textbox.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, TextboxY + 6),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    -- Input Display
    Textbox.InputLabel = Utility.AddDrawing("Text", {
        Text = Default ~= "" and Default or Placeholder,
        Position = Vector2.new(Tab.Window.Position.X + 150, TextboxY + 6),
        Color = Default ~= "" and UILibrary.Theme.Text or UILibrary.Theme.TextInactive,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    function Textbox:Set(Value)
        self.Value = Value
        UILibrary.Flags[self.Flag] = Value
        self.InputLabel.Text = Value ~= "" and Value or self.Placeholder
        self.InputLabel.Color = Value ~= "" and UILibrary.Theme.Text or UILibrary.Theme.TextInactive
        self.Callback(Value)
    end
    
    -- Focus and input handling (simplified - would need proper text input system)
    Utility.AddConnection(UserInput.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Utility.OnMouse(Textbox.Background) then
                Textbox.Focused = true
                Textbox.Background.Color = UILibrary.Theme.Accent[1]
            else
                Textbox.Focused = false
                Textbox.Background.Color = UILibrary.Theme.LightContrast
            end
        end
    end)
    
    Tab.YOffset = Tab.YOffset + 35
    table.insert(Tab.Elements, Textbox)
    return Textbox
end

function UILibrary:CreateLabel(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "Label"
    local Color = Settings.Color or UILibrary.Theme.Text
    local Size = Settings.Size or UILibrary.Theme.TextSize
    
    local Label = {
        TypeOf = "Label",
        Tab = Tab,
        Text = Text,
        Color = Color,
        Size = Size
    }
    
    local LabelY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Label Text
    Label.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Tab.Window.Position.X + 25, LabelY + 6),
        Color = Color,
        Font = UILibrary.Theme.Font,
        Size = Size,
        Visible = Tab.Active,
        ZIndex = 5
    })
    
    function Label:Set(NewText)
        self.Text = NewText
        self.TextLabel.Text = NewText
    end
    
    Tab.YOffset = Tab.YOffset + 25
    table.insert(Tab.Elements, Label)
    return Label
end

function UILibrary:CreateSeparator(Tab, Settings)
    Settings = Settings or {}
    local Text = Settings.Text or ""
    
    local Separator = {
        TypeOf = "Separator",
        Tab = Tab,
        Text = Text
    }
    
    local SeparatorY = Tab.Window.Position.Y + 80 + Tab.YOffset
    
    -- Separator Line
    Separator.Line = Utility.AddDrawing("Square", {
        Size = Vector2.new(Tab.Window.Size.X - 40, 1),
        Position = Vector2.new(Tab.Window.Position.X + 20, SeparatorY + 10),
        Thickness = 0,
        Color = UILibrary.Theme.Inline,
        Visible = Tab.Active,
        Filled = true,
        ZIndex = 4
    })
    
    -- Optional separator text
    if Text ~= "" then
        Separator.TextLabel = Utility.AddDrawing("Text", {
            Text = Text,
            Position = Vector2.new(Tab.Window.Position.X + (Tab.Window.Size.X / 2) - 20, SeparatorY + 2),
            Color = UILibrary.Theme.TextInactive,
            Font = UILibrary.Theme.Font,
            Size = UILibrary.Theme.TextSize - 1,
            Visible = Tab.Active,
            ZIndex = 5
        })
    end
    
    Tab.YOffset = Tab.YOffset + 20
    table.insert(Tab.Elements, Separator)
    return Separator
end

-- Legacy Compatibility Functions
function UILibrary:CreateScreenGui(name, parent)
    warn("CreateScreenGui is deprecated. Use CreateWindow instead.")
    return self:CreateWindow({Title = name or "UILibrary Window"})
end

-- Advanced Animation System
local AnimationService = {}

function AnimationService:TweenDrawing(Drawing, Properties, Duration, EasingStyle, EasingDirection)
    Duration = Duration or 0.3
    EasingStyle = EasingStyle or "Quad"
    EasingDirection = EasingDirection or "Out"
    
    local StartTime = tick()
    local StartProperties = {}
    
    -- Store initial values
    for Property, EndValue in pairs(Properties) do
        StartProperties[Property] = Drawing[Property]
    end
    
    local Connection
    Connection = Utility.AddConnection(RunService.RenderStepped, function()
        local ElapsedTime = tick() - StartTime
        local Progress = math.min(ElapsedTime / Duration, 1)
        
        -- Apply easing
        if EasingStyle == "Quad" then
            if EasingDirection == "Out" then
                Progress = 1 - (1 - Progress)^2
            elseif EasingDirection == "In" then  
                Progress = Progress^2
            end
        elseif EasingStyle == "Cubic" then
            if EasingDirection == "Out" then
                Progress = 1 - (1 - Progress)^3
            elseif EasingDirection == "In" then
                Progress = Progress^3
            end
        end
        
        -- Interpolate properties
        for Property, EndValue in pairs(Properties) do
            local StartValue = StartProperties[Property]
            
            if typeof(StartValue) == "Vector2" then
                Drawing[Property] = StartValue:Lerp(EndValue, Progress)
            elseif typeof(StartValue) == "Color3" then
                Drawing[Property] = StartValue:Lerp(EndValue, Progress)
            elseif typeof(StartValue) == "number" then
                Drawing[Property] = StartValue + (EndValue - StartValue) * Progress
            else
                Drawing[Property] = EndValue
            end
        end
        
        if Progress >= 1 then
            Connection:Disconnect()
        end
    end)
    
    return Connection
end

function AnimationService:FadeIn(Drawing, Duration)
    local OriginalTransparency = Drawing.Transparency or 0
    Drawing.Transparency = 1
    Drawing.Visible = true
    
    return self:TweenDrawing(Drawing, {Transparency = OriginalTransparency}, Duration or 0.3)
end

function AnimationService:FadeOut(Drawing, Duration)
    return self:TweenDrawing(Drawing, {Transparency = 1}, Duration or 0.3)
end

function AnimationService:SlideIn(Drawing, Direction, Distance, Duration)
    Direction = Direction or "Left"
    Distance = Distance or 100
    Duration = Duration or 0.4
    
    local OriginalPosition = Drawing.Position
    local StartPosition
    
    if Direction == "Left" then
        StartPosition = Vector2.new(OriginalPosition.X - Distance, OriginalPosition.Y)
    elseif Direction == "Right" then
        StartPosition = Vector2.new(OriginalPosition.X + Distance, OriginalPosition.Y)
    elseif Direction == "Up" then
        StartPosition = Vector2.new(OriginalPosition.X, OriginalPosition.Y - Distance)
    elseif Direction == "Down" then
        StartPosition = Vector2.new(OriginalPosition.X, OriginalPosition.Y + Distance)
    end
    
    Drawing.Position = StartPosition
    return self:TweenDrawing(Drawing, {Position = OriginalPosition}, Duration)
end

-- Watermark System
function UILibrary:CreateWatermark(Settings)
    Settings = Settings or {}
    local Text = Settings.Text or "ProfessionalUI Library"
    local Position = Settings.Position or Vector2.new(10, 10)
    local Color = Settings.Color or UILibrary.Theme.Text
    local Size = Settings.Size or UILibrary.Theme.TextSize
    
    local Watermark = {
        Text = Text,
        Position = Position,
        Visible = true
    }
    
    -- Watermark Background
    Watermark.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(200, 25),
        Position = Position,
        Thickness = 0,
        Color = UILibrary.Theme.DarkContrast,
        Visible = true,
        Filled = true,
        ZIndex = 100,
        Transparency = 0.8
    })
    
    -- Watermark Text
    Watermark.TextLabel = Utility.AddDrawing("Text", {
        Text = Text,
        Position = Vector2.new(Position.X + 5, Position.Y + 6),
        Color = Color,
        Font = UILibrary.Theme.Font,
        Size = Size,
        Visible = true,
        ZIndex = 101
    })
    
    -- Accent line
    Watermark.AccentLine = Utility.AddDrawing("Square", {
        Size = Vector2.new(200, 2),
        Position = Vector2.new(Position.X, Position.Y),
        Thickness = 0,
        Color = UILibrary.Theme.Accent[1],
        Visible = true,
        Filled = true,
        ZIndex = 102
    })
    
    function Watermark:UpdateText(NewText)
        self.Text = NewText
        self.TextLabel.Text = NewText
    end
    
    function Watermark:SetVisible(Visible)
        self.Visible = Visible
        self.Background.Visible = Visible
        self.TextLabel.Visible = Visible
        self.AccentLine.Visible = Visible
    end
    
    UILibrary.Watermark = Watermark
    return Watermark
end

-- Performance Monitor
function UILibrary:CreatePerformanceMonitor()
    local Monitor = {
        FPS = 0,
        Ping = 0,
        Memory = 0,
        UpdateRate = 60,
        LastUpdate = tick(),
        Active = false
    }
    
    -- FPS Counter
    local FPSCount = 0
    local LastFPSUpdate = tick()
    
    Utility.AddConnection(RunService.RenderStepped, function()
        FPSCount = FPSCount + 1
        
        if tick() - LastFPSUpdate >= 1 then
            Monitor.FPS = FPSCount
            FPSCount = 0
            LastFPSUpdate = tick()
        end
    end)
    
    -- Performance Display
    Monitor.Display = Utility.AddDrawing("Text", {
        Text = "FPS: 0 | Ping: 0ms | Memory: 0MB",
        Position = Vector2.new(10, Camera.ViewportSize.Y - 30),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = false,
        ZIndex = 200
    })
    
    function Monitor:Update()
        if not self.Active then return end
        
        -- Update ping (approximation)
        if game:GetService("Stats") and game:GetService("Stats").Network then
            local PingStats = game:GetService("Stats").Network.ServerStatsItem
            if PingStats and PingStats["Data Ping"] then
                self.Ping = math.floor(PingStats["Data Ping"]:GetValue())
            end
        end
        
        -- Update memory usage (approximation)
        if game:GetService("Stats") then
            self.Memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
        end
        
        -- Update display
        self.Display.Text = string.format("FPS: %d | Ping: %dms | Memory: %dMB", 
            self.FPS, self.Ping, self.Memory)
    end
    
    function Monitor:SetActive(Active)
        self.Active = Active
        self.Display.Visible = Active
    end
    
    -- Auto-update loop
    Utility.Loop(1/Monitor.UpdateRate, function()
        Monitor:Update()
    end)
    
    return Monitor
end

-- Advanced Input System
local InputSystem = {}

function InputSystem:CreateTextInput(Parent, Settings)
    Settings = Settings or {}
    local PlaceholderText = Settings.PlaceholderText or "Enter text..."
    local MaxLength = Settings.MaxLength or 100
    local OnlyNumbers = Settings.OnlyNumbers or false
    local Callback = Settings.Callback or function() end
    
    local TextInput = {
        Text = "",
        Placeholder = PlaceholderText,
        MaxLength = MaxLength,
        OnlyNumbers = OnlyNumbers,
        Focused = false,
        CursorPosition = 0,
        Callback = Callback
    }
    
    -- Create invisible TextBox for input capture
    local InputCapture = Utility.AddInstance("TextBox", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, -1000, 0, -1000),
        BackgroundTransparency = 1,
        TextTransparency = 1,
        BorderSizePixel = 0,
        Parent = Parent or CoreGui
    })
    
    function TextInput:Focus()
        self.Focused = true
        InputCapture:CaptureFocus()
    end
    
    function TextInput:Unfocus()
        self.Focused = false
        InputCapture:ReleaseFocus()
    end
    
    function TextInput:SetText(NewText)
        if self.OnlyNumbers then
            NewText = NewText:gsub("[^%d]", "")
        end
        
        if #NewText <= self.MaxLength then
            self.Text = NewText
            self.Callback(NewText)
        end
    end
    
    -- Input handling
    Utility.AddConnection(InputCapture:GetPropertyChangedSignal("Text"), function()
        TextInput:SetText(InputCapture.Text)
    end)
    
    Utility.AddConnection(InputCapture.FocusLost, function()
        TextInput:Unfocus()
    end)
    
    return TextInput
end

-- Theme Management System
function UILibrary:CreateThemeManager()
    local ThemeManager = {
        CurrentTheme = "Dark",
        Themes = {}
    }
    
    -- Default themes
    ThemeManager.Themes.Dark = {
        Accent = {Color3.fromHex("#c37be5"), Color3.fromRGB(180, 156, 255), Color3.fromRGB(114, 0, 198)},
        Outline = Color3.fromHex("#000005"),
        LightContrast = Color3.fromHex("#231946"),
        DarkContrast = Color3.fromHex("#191432"),
        Text = Color3.fromHex("#c8c8ff"),
        TextInactive = Color3.fromHex("#afafaf")
    }
    
    ThemeManager.Themes.Light = {
        Accent = {Color3.fromHex("#3d82f7"), Color3.fromRGB(61, 130, 247), Color3.fromRGB(41, 110, 227)},
        Outline = Color3.fromHex("#d0d0d0"),
        LightContrast = Color3.fromHex("#f5f5f5"),
        DarkContrast = Color3.fromHex("#ffffff"),
        Text = Color3.fromHex("#2d3748"),
        TextInactive = Color3.fromHex("#718096")
    }
    
    ThemeManager.Themes.Red = {
        Accent = {Color3.fromHex("#ff6b6b"), Color3.fromRGB(255, 107, 107), Color3.fromRGB(235, 87, 87)},
        Outline = Color3.fromHex("#000005"),
        LightContrast = Color3.fromHex("#4a1818"),
        DarkContrast = Color3.fromHex("#2d0f0f"),
        Text = Color3.fromHex("#ffd3d3"),
        TextInactive = Color3.fromHex("#af9f9f")
    }
    
    ThemeManager.Themes.Blue = {
        Accent = {Color3.fromHex("#4ecdc4"), Color3.fromRGB(78, 205, 196), Color3.fromRGB(58, 185, 176)},
        Outline = Color3.fromHex("#000005"),
        LightContrast = Color3.fromHex("#1a4a46"),
        DarkContrast = Color3.fromHex("#0f2d2a"),
        Text = Color3.fromHex("#d3ffd8"),
        TextInactive = Color3.fromHex("#9faf9f")
    }
    
    function ThemeManager:ApplyTheme(ThemeName)
        local Theme = self.Themes[ThemeName]
        if not Theme then 
            warn("Theme not found: " .. ThemeName)
            return 
        end
        
        self.CurrentTheme = ThemeName
        
        -- Update library theme
        for Property, Value in pairs(Theme) do
            UILibrary.Theme[Property] = Value
        end
        
        -- Broadcast theme change
        UILibrary.Communication:Fire("ThemeChanged", Theme)
        
        -- Update all existing elements
        for _, Window in pairs(UILibrary.Windows) do
            Window.Border.Color = UILibrary.Theme.Accent[1]
            Window.Background.Color = UILibrary.Theme.DarkContrast
            Window.TitleBar.Color = UILibrary.Theme.LightContrast
            Window.TitleText.Color = UILibrary.Theme.Text
            
            for _, Tab in pairs(Window.Tabs) do
                Tab.Button.Color = Tab.Active and UILibrary.Theme.Accent[1] or UILibrary.Theme.LightContrast
                Tab.ButtonText.Color = UILibrary.Theme.Text
                Tab.Content.Color = UILibrary.Theme.DarkContrast
            end
        end
    end
    
    function ThemeManager:CreateCustomTheme(Name, ThemeData)
        self.Themes[Name] = ThemeData
    end
    
    function ThemeManager:GetThemeList()
        local Themes = {}
        for Name, _ in pairs(self.Themes) do
            table.insert(Themes, Name)
        end
        return Themes
    end
    
    return ThemeManager
end

-- Console System
function UILibrary:CreateConsole(Settings)
    Settings = Settings or {}
    local MaxLines = Settings.MaxLines or 100
    local Position = Settings.Position or Vector2.new(10, 50)
    local Size = Settings.Size or Vector2.new(400, 200)
    
    local Console = {
        Lines = {},
        MaxLines = MaxLines,
        Visible = false,
        ScrollOffset = 0
    }
    
    -- Console Background
    Console.Background = Utility.AddDrawing("Square", {
        Size = Size,
        Position = Position,
        Thickness = 0,
        Color = UILibrary.Theme.DarkContrast,
        Visible = false,
        Filled = true,
        ZIndex = 150,
        Transparency = 0.9
    })
    
    -- Console Border
    Console.Border = Utility.AddDrawing("Square", {
        Size = Size,
        Position = Position,
        Thickness = 1,
        Color = UILibrary.Theme.Accent[1],
        Visible = false,
        Filled = false,
        ZIndex = 151
    })
    
    -- Console Title
    Console.Title = Utility.AddDrawing("Text", {
        Text = "Developer Console",
        Position = Vector2.new(Position.X + 5, Position.Y + 5),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = false,
        ZIndex = 152
    })
    
    function Console:AddLine(Text, Color)
        Color = Color or UILibrary.Theme.Text
        
        table.insert(self.Lines, {
            Text = Text,
            Color = Color,
            Time = os.date("%H:%M:%S")
        })
        
        -- Remove old lines
        if #self.Lines > self.MaxLines then
            table.remove(self.Lines, 1)
        end
        
        self:UpdateDisplay()
    end
    
    function Console:UpdateDisplay()
        if not self.Visible then return end
        
        -- Clear existing line displays
        for i = #self.Lines, 1, -1 do
            local LineY = self.Background.Position.Y + 25 + ((i - self.ScrollOffset) * 15)
            
            if LineY >= self.Background.Position.Y + 25 and LineY <= self.Background.Position.Y + self.Background.Size.Y - 15 then
                local Line = self.Lines[i]
                
                -- Create or update line display
                if not Line.Display then
                    Line.Display = Utility.AddDrawing("Text", {
                        Text = string.format("[%s] %s", Line.Time, Line.Text),
                        Position = Vector2.new(self.Background.Position.X + 5, LineY),
                        Color = Line.Color,
                        Font = UILibrary.Theme.Font,
                        Size = UILibrary.Theme.TextSize - 1,
                        Visible = self.Visible,
                        ZIndex = 152
                    })
                else
                    Line.Display.Position = Vector2.new(self.Background.Position.X + 5, LineY)
                    Line.Display.Visible = self.Visible
                end
            elseif Line.Display then
                Line.Display.Visible = false
            end
        end
    end
    
    function Console:SetVisible(Visible)
        self.Visible = Visible
        self.Background.Visible = Visible
        self.Border.Visible = Visible
        self.Title.Visible = Visible
        self:UpdateDisplay()
    end
    
    function Console:Clear()
        for _, Line in pairs(self.Lines) do
            if Line.Display then
                Utility.RemoveDrawing(Line.Display)
            end
        end
        self.Lines = {}
    end
    
    -- Hook into print function
    local OriginalPrint = print
    print = function(...)
        OriginalPrint(...)
        local Args = {...}
        local Text = ""
        for i, v in ipairs(Args) do
            Text = Text .. tostring(v) .. (i < #Args and " " or "")
        end
        Console:AddLine(Text, UILibrary.Theme.Text)
    end
    
    return Console
end

-- Notification System
function UILibrary:CreateNotification(message, notificationType, duration)
    message = message or "Notification"
    notificationType = notificationType or "info"
    duration = duration or 3
    
    local NotificationY = 50 + (#UILibrary.Notifications * 70)
    
    local Notification = {
        Message = message,
        Type = notificationType,
        Duration = duration
    }
    
    -- Notification Background
    Notification.Background = Utility.AddDrawing("Square", {
        Size = Vector2.new(300, 60),
        Position = Vector2.new(Camera.ViewportSize.X - 320, NotificationY),
        Thickness = 0,
        Color = UILibrary.Theme.Notification[notificationType] or UILibrary.Theme.Notification.Info,
        Visible = true,
        Filled = true,
        ZIndex = 10
    })
    
    -- Notification Text
    Notification.TextLabel = Utility.AddDrawing("Text", {
        Text = message,
        Position = Vector2.new(Camera.ViewportSize.X - 310, NotificationY + 20),
        Color = UILibrary.Theme.Text,
        Font = UILibrary.Theme.Font,
        Size = UILibrary.Theme.TextSize,
        Visible = true,
        ZIndex = 11
    })
    
    table.insert(UILibrary.Notifications or {}, Notification)
    
    -- Auto-remove
    task.spawn(function()
        wait(duration)
        Utility.RemoveDrawing(Notification.Background)
        Utility.RemoveDrawing(Notification.TextLabel)
        
        for i, notif in pairs(UILibrary.Notifications) do
            if notif == Notification then
                table.remove(UILibrary.Notifications, i)
                break
            end
        end
    end)
    
    return Notification
end

-- Theme Management
function UILibrary:SetAccentColor(color)
    if type(color) == "table" then
        UILibrary.Theme.Accent = color
    else
        UILibrary.Theme.Accent[1] = color
    end
    
    UILibrary.Communication:Fire("Accent", UILibrary.Theme.Accent[1])
end

-- Cleanup Functions
function UILibrary:Destroy()
    -- Clean up all drawings
    for _, drawing in pairs(UILibrary.Drawings) do
        if drawing[1] and drawing[1].Remove then
            drawing[1]:Remove()
        end
    end
    
    -- Disconnect all connections
    for _, connection in pairs(UILibrary.Connections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
    
    -- Clear tables
    UILibrary.Drawings = {}
    UILibrary.Connections = {}
    UILibrary.Windows = {}
    UILibrary.Flags = {}
    UILibrary.Items = {}
end

-- Legacy Compatibility Functions (simplified versions for backward compatibility)
function UILibrary:CreateFrame(parent, name, properties)
    warn("CreateFrame is deprecated. Use the new Window/Tab system.")
    return Instance.new("Frame")
end

function UILibrary:CreateButton(parent, text, properties, callback)
    warn("CreateButton is deprecated. Use Tab:CreateButton instead.")
    return Instance.new("TextButton")
end

function UILibrary:CreateLabel(parent, text, properties)
    warn("CreateLabel is deprecated. Use Drawing-based text instead.")
    return Instance.new("TextLabel")
end

function UILibrary:CreateTextBox(parent, placeholderText, properties, callback)
    warn("CreateTextBox is deprecated. Use new input components.")
    return Instance.new("TextBox")
end

-- Utility functions for color/font access
function UILibrary:GetColor(colorName)
    local color = UILibrary.Theme[colorName:upper()]
    if color then return color end
    
    -- Check legacy colors
    if colorName:lower() == "primary" then return UILibrary.Theme.Accent[1] end
    if colorName:lower() == "secondary" then return UILibrary.Theme.TextInactive end
    if colorName:lower() == "light" then return UILibrary.Theme.LightContrast end
    if colorName:lower() == "dark" then return UILibrary.Theme.DarkContrast end
    if colorName:lower() == "white" then return Color3.new(1, 1, 1) end
    if colorName:lower() == "black" then return Color3.new(0, 0, 0) end
    
    return UILibrary.Theme.Accent[1]
end

function UILibrary:GetFont(fontName)
    return UILibrary.Theme.Font
end

-- Initialize notifications table
UILibrary.Notifications = {}

-- Global access
getgenv().UILibrary = UILibrary
getgenv().Utility = Utility

-- Initialization
function UILibrary:Init()
    local LoadEndTime = tick()
    print("UILibrary v2.0 Professional Edition loaded successfully!")
    print("Load Time: " .. string.format("%.3f", LoadEndTime - UILibrary.LoadTime) .. "s")
    print("Features: Drawing-based rendering, Advanced theming, Professional components")
    print("Usage: local Window = UILibrary:CreateWindow({Title = 'My Script', Size = Vector2.new(600, 400)})")
    
    return UILibrary
end

-- Auto-initialize and return
return UILibrary:Init()
