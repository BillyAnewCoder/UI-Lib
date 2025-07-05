-- Enhanced Roblox UI Library - Compact and Modern Design
-- Improved spacing, sizing, and visual aesthetics

local library = { 
	flags = { };
	items = { };
}

local StarterGUI = game:GetService("Players").LocalPlayer.PlayerGui;
local CoreGui = game:FindFirstChild("CoreGui");
local textservice = game:GetService("TextService");
local httpservice = game:GetService("HttpService");
local tweenservice = game:GetService("TweenService");
local runservice = game:GetService("RunService");

-- Enhanced theme with modern colors and improved contrast
library.theme = {
	-- Main backgrounds - darker and more modern
	BackGround = Color3.fromRGB(20, 20, 25);
	BackGround2 = Color3.fromRGB(28, 28, 35);
	BackGroundHover = Color3.fromRGB(35, 35, 42);
	
	-- Borders - subtle but visible
	Border = Color3.fromRGB(45, 45, 52);
	BorderHover = Color3.fromRGB(88, 101, 242);
	
	-- Interactive elements
	Toggle = Color3.fromRGB(45, 45, 52);
	ToggleHover = Color3.fromRGB(55, 55, 62);
	Selected = Color3.fromRGB(88, 101, 242);
	SelectedHover = Color3.fromRGB(71, 82, 196);
	
	-- Typography
	Font = Enum.Font.Ubuntu; -- Changed from Enum.Font.Inter to Ubuntu
	TextSize = 13;
	TextColor = Color3.fromRGB(220, 221, 222);
	TextColorDimmed = Color3.fromRGB(163, 166, 170);
	
	-- Animation settings - faster and smoother
	AnimationSpeed = 0.15;
	HoverSpeed = 0.1;
	EasingStyle = Enum.EasingStyle.Quart;
	EasingDirection = Enum.EasingDirection.Out;
};

-- Animation utility functions
local function createTween(object, properties, duration, easingStyle, easingDirection)
	duration = duration or library.theme.AnimationSpeed
	easingStyle = easingStyle or library.theme.EasingStyle
	easingDirection = easingDirection or library.theme.EasingDirection
	
	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = tweenservice:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

local function addHoverEffect(object, hoverProperties, normalProperties)
	local isHovering = false
	
	object.MouseEnter:Connect(function()
		if not isHovering then
			isHovering = true
			createTween(object, hoverProperties, library.theme.HoverSpeed)
		end
	end)
	
	object.MouseLeave:Connect(function()
		if isHovering then
			isHovering = false
			createTween(object, normalProperties, library.theme.HoverSpeed)
		end
	end)
end

local function addClickEffect(object, clickScale)
	clickScale = clickScale or 0.96
	local originalSize = object.Size
	
	object.MouseButton1Down:Connect(function()
		createTween(object, {Size = UDim2.fromScale(originalSize.X.Scale * clickScale, originalSize.Y.Scale * clickScale)}, 0.08)
	end)
	
	object.MouseButton1Up:Connect(function()
		createTween(object, {Size = originalSize}, 0.12)
	end)
	
	object.MouseLeave:Connect(function()
		createTween(object, {Size = originalSize}, 0.12)
	end)
end

function library:CreateWindow(Keybind, Name)
	local window = { };
	window.keybind = Keybind or Enum.KeyCode.RightShift;
	window.name = Name or "UI Library";

	window.ScreenGui = Instance.new("ScreenGui");
	window.ScreenGui.Parent = (CoreGui or StarterGUI);
	window.ScreenGui.ResetOnSpawn = false;
	window.ScreenGui.DisplayOrder = 10;

	-- Enhanced dragging system
	local dragging, dragInput, dragStart, startPos
	local dragTween
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			
			if dragTween then dragTween:Cancel() end
			dragTween = createTween(window.Main, {Position = newPosition}, 0.03, Enum.EasingStyle.Linear)
		end
	end)

	local dragstart = function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Main.Position
			
			createTween(window.Main, {BackgroundColor3 = library.theme.BackGroundHover}, 0.1)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					createTween(window.Main, {BackgroundColor3 = library.theme.BackGround}, 0.2)
				end
			end)
		end
	end

	local dragend = function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end

	-- Smaller, more compact main window
	window.Main = Instance.new("TextButton", window.ScreenGui);
	window.Main.Size = UDim2.fromOffset(650, 380); -- Reduced from 800x450
	window.Main.BackgroundColor3 = library.theme.BackGround;
	window.Main.BorderSizePixel = 0;
	window.Main.Active = true;
	window.Main.AutoButtonColor = false;
	window.Main.Text = "";
	window.Main.InputBegan:Connect(dragstart)
	window.Main.InputChanged:Connect(dragend)
	
	-- Add rounded corners
	local mainCorner = Instance.new("UICorner", window.Main)
	mainCorner.CornerRadius = UDim.new(0, 12)
	
	-- Add subtle border
	local mainStroke = Instance.new("UIStroke", window.Main)
	mainStroke.Color = library.theme.Border
	mainStroke.Thickness = 1
	
	-- Window entrance animation
	window.Main.Position = UDim2.fromScale(0.5, 0.5)
	window.Main.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Main.Size = UDim2.fromOffset(0, 0)
	createTween(window.Main, {Size = UDim2.fromOffset(650, 380)}, 0.4, Enum.EasingStyle.Back)

	-- Subtle drop shadow
	local shadow = Instance.new("Frame", window.Main)
	shadow.Name = "Shadow"
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.8
	shadow.BorderSizePixel = 0
	shadow.Position = UDim2.fromOffset(3, 3)
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.ZIndex = window.Main.ZIndex - 1
	
	local shadowCorner = Instance.new("UICorner", shadow)
	shadowCorner.CornerRadius = UDim.new(0, 12)

	-- Compact right side panel
	window.RightSide = Instance.new("Frame", window.Main);
	window.RightSide.BackgroundColor3 = library.theme.BackGround2;
	window.RightSide.Size = UDim2.fromOffset(120, 380); -- Reduced width
	window.RightSide.BorderSizePixel = 0;
	window.RightSide.Position = UDim2.fromOffset(530, 0); -- Adjusted position

	-- Compact tabs holder
	window.TabsHolder = Instance.new("Frame", window.Main);
	window.TabsHolder.Position = UDim2.fromScale(0.025, 0.12); -- Adjusted positioning
	window.TabsHolder.Size = UDim2.fromOffset(90, 320); -- Reduced size
	window.TabsHolder.BackgroundTransparency = 1;

	window.UIListLayout = Instance.new("UIListLayout", window.TabsHolder);
	window.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	window.UIListLayout.Padding = UDim.new(0, 6); -- Reduced padding
	window.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;

	-- Thinner separator line
	window.line = Instance.new("Frame", window.Main);
	window.line.Position = UDim2.fromScale(0.18, 0.05);
	window.line.Size = UDim2.fromOffset(1, 360); -- Adjusted size
	window.line.BorderSizePixel = 0;
	window.line.BackgroundColor3 = library.theme.Border;

	-- Compact title with better typography
	window.Title = Instance.new("TextLabel", window.Main);
	window.Title.Position = UDim2.fromScale(0.025, 0.02);
	window.Title.Size = UDim2.fromOffset(150, 28); -- Reduced height
	window.Title.Text = window.name;
	window.Title.Font = library.theme.Font;
	window.Title.TextSize = 16; -- Slightly smaller
	window.Title.BackgroundTransparency = 1;
	window.Title.TextColor3 = library.theme.TextColor;
	window.Title.TextXAlignment = Enum.TextXAlignment.Left;
	local fontFace = window.Title.FontFace
	fontFace.Weight = Enum.FontWeight.SemiBold -- Less bold
	window.Title.FontFace = fontFace;

	-- Enhanced keybind toggle with smoother animation
	game:GetService("UserInputService").InputBegan:Connect(function(key)
		if key.KeyCode == window.keybind then
			if window.Main.Visible then
				createTween(window.Main, {
					Size = UDim2.fromOffset(0, 0),
					BackgroundTransparency = 1
				}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
				createTween(shadow, {BackgroundTransparency = 1}, 0.25)
				wait(0.25)
				window.Main.Visible = false
			else
				window.Main.Visible = true
				window.Main.BackgroundTransparency = 1
				window.Main.Size = UDim2.fromOffset(0, 0)
				shadow.BackgroundTransparency = 1
				createTween(window.Main, {
					Size = UDim2.fromOffset(650, 380),
					BackgroundTransparency = 0
				}, 0.25, Enum.EasingStyle.Back)
				createTween(shadow, {BackgroundTransparency = 0.8}, 0.25)
			end
		end
	end)

	window.Tabs = { };
	window.OpenedColorPickers = { };
	
	function window:UpdateKeyBind(Key)
		window.keybind = Key;
	end

	function window:CreateToggleButton()
		local ToggleButton = { };

		ToggleButton.Frame = Instance.new("Frame", window.ScreenGui);
		ToggleButton.Frame.Size = UDim2.fromOffset(120, 32); -- More compact
		ToggleButton.Frame.Position = UDim2.fromScale(0.02, 0.02);
		ToggleButton.Frame.Draggable = true;
		ToggleButton.Frame.Active = true;
		ToggleButton.Frame.BackgroundColor3 = library.theme.BackGround;
		ToggleButton.Frame.BorderSizePixel = 0;
		
		local corner = Instance.new("UICorner", ToggleButton.Frame)
		corner.CornerRadius = UDim.new(0, 8)
		
		local stroke = Instance.new("UIStroke", ToggleButton.Frame)
		stroke.Color = library.theme.Border
		stroke.Thickness = 1

		ToggleButton.Button = Instance.new("TextButton", ToggleButton.Frame);
		ToggleButton.Button.Size = UDim2.fromScale(1, 1);
		ToggleButton.Button.Position = UDim2.fromScale(0, 0);
		ToggleButton.Button.Text = "Toggle UI";
		ToggleButton.Button.TextColor3 = library.theme.TextColor;
		ToggleButton.Button.Font = library.theme.Font;
		ToggleButton.Button.TextSize = library.theme.TextSize;
		ToggleButton.Button.BackgroundTransparency = 1;
		ToggleButton.Button.AutoButtonColor = false;
		
		addHoverEffect(ToggleButton.Button, 
			{TextColor3 = library.theme.Selected},
			{TextColor3 = library.theme.TextColor}
		)
		addClickEffect(ToggleButton.Frame, 0.95)
		
		ToggleButton.Button.MouseButton1Click:Connect(function()
			window.Main.Visible = not window.Main.Visible;
			ToggleButton.Button.Text = window.Main.Visible and "Hide UI" or "Show UI"
			
			local targetColor = window.Main.Visible and library.theme.Selected or library.theme.TextColorDimmed
			createTween(ToggleButton.Button, {TextColor3 = targetColor}, 0.2)
		end)

		game:GetService("UserInputService").InputBegan:Connect(function(key)
			if key.KeyCode == window.keybind then
				ToggleButton.Button.Text = window.Main.Visible and "Hide UI" or "Show UI"
				local targetColor = window.Main.Visible and library.theme.Selected or library.theme.TextColorDimmed
				createTween(ToggleButton.Button, {TextColor3 = targetColor}, 0.2)
			end
		end)

		function ToggleButton:Update(Bool)
			if Bool then
				ToggleButton.Frame.BackgroundTransparency = 1
				ToggleButton.Frame.Size = UDim2.fromOffset(0, 0)
				createTween(ToggleButton.Frame, {BackgroundTransparency = 0}, 0.3)
				createTween(ToggleButton.Frame, {Size = UDim2.fromOffset(120, 32)}, 0.3, Enum.EasingStyle.Back)
			else
				createTween(ToggleButton.Frame, {BackgroundTransparency = 1}, 0.3)
				createTween(ToggleButton.Frame, {Size = UDim2.fromOffset(0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			end
			ToggleButton.Frame.Visible = Bool;
		end

		return ToggleButton;
	end

	function window:CreateTab(Name)
		local tab = { };

		tab.Button = Instance.new("TextButton", window.TabsHolder);
		tab.Button.Size = UDim2.fromOffset(110, 28); -- More compact
		tab.Button.BackgroundColor3 = library.theme.BackGround;
		tab.Button.Text = Name;
		tab.Button.TextColor3 = library.theme.TextColor;
		tab.Button.Font = library.theme.Font;
		tab.Button.TextSize = library.theme.TextSize;
		tab.Button.BorderSizePixel = 0;
		tab.Button.AutoButtonColor = false;
		
		local corner = Instance.new("UICorner", tab.Button)
		corner.CornerRadius = UDim.new(0, 6)
		
		addHoverEffect(tab.Button,
			{BackgroundColor3 = library.theme.BackGroundHover, TextColor3 = library.theme.Selected},
			{BackgroundColor3 = library.theme.BackGround, TextColor3 = library.theme.TextColor}
		)
		addClickEffect(tab.Button, 0.97)

		tab.Window = Instance.new("ScrollingFrame", window.Main);
		tab.Window.Name = Name .. "Tab";
		tab.Window.BackgroundTransparency = 1;
		tab.Window.Visible = false;
		tab.Window.Size = UDim2.fromOffset(530, 380); -- Adjusted for new layout
		tab.Window.Position = UDim2.fromOffset(120, 0);
		tab.Window.ScrollBarThickness = 2;
		tab.Window.ScrollBarImageColor3 = library.theme.Selected;
		tab.Window.BorderSizePixel = 0;

		tab.Left = Instance.new("Frame", tab.Window);
		tab.Left.Size = UDim2.fromOffset(250, 360); -- Adjusted size
		tab.Left.Position = UDim2.fromOffset(10, 10);
		tab.Left.BackgroundTransparency = 1;

		tab.UiListLayout = Instance.new("UIListLayout", tab.Left);
		tab.UiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		tab.UiListLayout.Padding = UDim.new(0, 8); -- Reduced padding
		tab.UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;

		tab.Right = Instance.new("Frame", tab.Window);
		tab.Right.Size = UDim2.fromOffset(250, 360); -- Adjusted size
		tab.Right.Position = UDim2.fromOffset(270, 10);
		tab.Right.BackgroundTransparency = 1;

		tab.UiListLayout1 = Instance.new("UIListLayout", tab.Right);
		tab.UiListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		tab.UiListLayout1.Padding = UDim.new(0, 8); -- Reduced padding
		tab.UiListLayout1.SortOrder = Enum.SortOrder.LayoutOrder;

		local block = false;
		function tab:SelectTab()
			if block then return end
			block = true;
			
			for i,v in pairs(window.Tabs) do
				if v ~= tab and v.Button then
					createTween(v.Button, {
						BackgroundColor3 = library.theme.BackGround,
						TextColor3 = library.theme.TextColor
					})
					v.Button.Name = "Tab";
					if v.Window then
						createTween(v.Window, {BackgroundTransparency = 1}, 0.15)
						wait(0.15)
						v.Window.Visible = false;
					end
				end
			end

			createTween(tab.Button, {
				BackgroundColor3 = library.theme.Selected,
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
			tab.Button.Name = "SelectedTab";
			
			tab.Window.Visible = true;
			tab.Window.BackgroundTransparency = 1;
			createTween(tab.Window, {BackgroundTransparency = 0}, 0.15)
			
			block = false;
		end

		if #window.Tabs == 0 then
			tab:SelectTab();
		end

		tab.Button.MouseButton1Down:Connect(function()
			tab:SelectTab();
		end)

		tab.SectorsLeft = { };
		tab.SectorsRight = { };

		function tab:CreateSector(Name, Side)
			local Sector = { };
			Sector.side = Side:lower() or "left"
			Sector.name = Name or ""

			Sector.Main = Instance.new("Frame", Sector.side == "left" and tab.Left or tab.Right);
			Sector.Main.BackgroundColor3 = library.theme.BackGround2;
			Sector.Main.BorderSizePixel = 0;
			Sector.Main.Name = Sector.name:gsub(" ", "") .. "Sector";
			Sector.Main.Size = UDim2.fromOffset(240, 40); -- More compact

			Sector.UICorner = Instance.new("UICorner", Sector.Main);
			Sector.UICorner.CornerRadius = UDim.new(0, 8); -- Smaller radius
			
			-- Subtle border
			local sectorStroke = Instance.new("UIStroke", Sector.Main)
			sectorStroke.Color = library.theme.Border
			sectorStroke.Thickness = 1

			Sector.Items = Instance.new("Frame", Sector.Main);
			Sector.Items.Position = UDim2.fromScale(0.5, 0);
			Sector.Items.Size = UDim2.fromOffset(220, 40); -- Adjusted size
			Sector.Items.AutomaticSize = Enum.AutomaticSize.Y;
			Sector.Items.BackgroundTransparency = 1;
			Sector.Items.AnchorPoint = Vector2.new(0.5, 0);

			Sector.UIListLayout = Instance.new("UIListLayout", Sector.Items);
			Sector.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
			Sector.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Sector.UIListLayout.Padding = UDim.new(0, 4); -- Reduced padding

			Sector.Name = Instance.new("TextLabel", Sector.Items);
			Sector.Name.BackgroundTransparency = 1;
			Sector.Name.Size = UDim2.fromOffset(220, 24); -- Smaller header
			Sector.Name.Text = Name;
			Sector.Name.TextColor3 = library.theme.TextColor;
			Sector.Name.Font = library.theme.Font;
			Sector.Name.TextSize = library.theme.TextSize + 1;
			Sector.Name.TextYAlignment = Enum.TextYAlignment.Center;
			local fontFace = Sector.Name.FontFace
			fontFace.Weight = Enum.FontWeight.Medium
			Sector.Name.FontFace = fontFace;

			table.insert(Sector.side:lower() == "left" and tab.SectorsLeft or tab.SectorsRight, Sector);

			function Sector:FixSize()
				local targetSize = UDim2.fromOffset(240, Sector.UIListLayout.AbsoluteContentSize.Y + 8) -- Reduced padding
				createTween(Sector.Main, {Size = targetSize}, 0.2)
				
				local sizeleft, sizeright = 0, 0;
				for i,v in pairs(tab.SectorsLeft) do
					sizeleft = sizeleft + v.Main.AbsoluteSize.Y;
				end
				for i,v in pairs(tab.SectorsRight) do
					sizeright = sizeright + v.Main.AbsoluteSize.Y;
				end
				tab.Window.CanvasSize = (sizeleft > sizeright and UDim2.fromOffset(530, sizeleft + 80) or UDim2.fromOffset(530, sizeright + 80))
			end
			
			function Sector:CreateToggle(Text, Defult, Callback, Flag)
				local Toggle = { };
				Toggle.text = Text or "";
				Toggle.default = Defult or false;
				Toggle.callback = Callback or function(value) end;
				Toggle.flag = Flag or Text or "";

				Toggle.value = Toggle.default;

				Toggle.Main = Instance.new("TextButton", Sector.Items);
				Toggle.Main.Size = UDim2.fromOffset(220, 28); -- More compact
				Toggle.Main.BackgroundColor3 = library.theme.BackGround;
				Toggle.Main.AutoButtonColor = false;
				Toggle.Main.Text = "";

				Toggle.UICorner = Instance.new("UICorner", Toggle.Main);
				Toggle.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(Toggle.Main,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)
				addClickEffect(Toggle.Main, 0.98)

				Toggle.Text = Instance.new("TextLabel", Toggle.Main);
				Toggle.Text.Position = UDim2.fromScale(0.05, 0);
				Toggle.Text.Size = UDim2.fromOffset(150, 28);
				Toggle.Text.Text = Text;
				Toggle.Text.TextColor3 = library.theme.TextColor;
				Toggle.Text.Font = library.theme.Font;
				Toggle.Text.TextSize = library.theme.TextSize;
				Toggle.Text.BackgroundTransparency = 1;
				Toggle.Text.TextXAlignment = Enum.TextXAlignment.Left;

				Toggle.Indicator = Instance.new("Frame", Toggle.Main);
				Toggle.Indicator.Position = UDim2.fromScale(0.88, 0.25);
				Toggle.Indicator.Size = UDim2.fromOffset(14, 14); -- Smaller indicator
				Toggle.Indicator.BackgroundColor3 = library.theme.Toggle;
				Toggle.Indicator.BorderSizePixel = 0;
				
				local indicatorCorner = Instance.new("UICorner", Toggle.Indicator)
				indicatorCorner.CornerRadius = UDim.new(0, 3)

				if Toggle.flag and Toggle.flag ~= "" then
					library.flags[Toggle.flag] = Toggle.default or false;
				end

				function Toggle:Set(value) 
					Toggle.value = value
					
					local targetColor = value and library.theme.Selected or library.theme.Toggle
					local targetTextColor = value and library.theme.Selected or library.theme.TextColor
					
					createTween(Toggle.Indicator, {BackgroundColor3 = targetColor}, 0.15)
					createTween(Toggle.Text, {TextColor3 = targetTextColor}, 0.15)
					
					-- Subtle scale animation
					local originalSize = Toggle.Indicator.Size
					createTween(Toggle.Indicator, {Size = UDim2.fromOffset(16, 16)}, 0.08)
					wait(0.08)
					createTween(Toggle.Indicator, {Size = originalSize}, 0.08)

					if Toggle.flag and Toggle.flag ~= "" then
						library.flags[Toggle.flag] = Toggle.value;
					end
					pcall(Toggle.callback, value);
				end

				Toggle.Main.MouseButton1Down:Connect(function()
					Toggle:Set(not Toggle.value);
				end)

				Toggle:Set(Toggle.default)
				Sector:FixSize();
				table.insert(library.items, Toggle);
				return Toggle;
			end

			function Sector:CreateSlider(Text, Min, Defult, Max, Decimals, Callback, Flag)
				local Slider = { };
				Slider.text = Text or "";
				Slider.callback = Callback or function(value) end;
				Slider.min = Min or 0;
				Slider.max = Max or 100;
				Slider.decimals = Decimals or 1;
				Slider.default = Defult or Slider.min;
				Slider.flag = Flag or Text or "";

				Slider.value = Slider.default;
				local dragging = false;

				Slider.Mainback = Instance.new("Frame", Sector.Items);
				Slider.Mainback.Size = UDim2.fromOffset(220, 28); -- More compact
				Slider.Mainback.BackgroundColor3 = library.theme.BackGround;
				Slider.Mainback.BorderSizePixel = 0;

				Slider.UICorner = Instance.new("UICorner", Slider.Mainback);
				Slider.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(Slider.Mainback,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)

				Slider.Text = Instance.new("TextLabel", Slider.Mainback);
				Slider.Text.Position = UDim2.fromScale(0.05, 0);
				Slider.Text.Size = UDim2.fromOffset(100, 28);
				Slider.Text.Text = Text;
				Slider.Text.TextColor3 = library.theme.TextColor;
				Slider.Text.Font = library.theme.Font;
				Slider.Text.TextSize = library.theme.TextSize;
				Slider.Text.BackgroundTransparency = 1;
				Slider.Text.TextXAlignment = Enum.TextXAlignment.Left;

				Slider.Main = Instance.new("TextButton", Slider.Mainback);
				Slider.Main.BackgroundColor3 = library.theme.Toggle;
				Slider.Main.Text = "";
				Slider.Main.Position = UDim2.fromScale(0.55, 0.25);
				Slider.Main.Size = UDim2.fromOffset(90, 14); -- Smaller slider
				Slider.Main.BorderSizePixel = 0;
				Slider.Main.AutoButtonColor = false;
				
				local sliderCorner = Instance.new("UICorner", Slider.Main)
				sliderCorner.CornerRadius = UDim.new(0, 7)

				Slider.Slider = Instance.new("Frame", Slider.Main);
				Slider.Slider.BackgroundColor3 = library.theme.Selected;
				Slider.Slider.BorderSizePixel = 0;
				Slider.Slider.Position = UDim2.fromScale(0, 0);
				Slider.Slider.Size = UDim2.fromOffset(45, 14);
				
				local sliderFillCorner = Instance.new("UICorner", Slider.Slider)
				sliderFillCorner.CornerRadius = UDim.new(0, 7)

				Slider.OutPutText = Instance.new("TextLabel", Slider.Main);
				Slider.OutPutText.Position = UDim2.fromScale(0, 0);
				Slider.OutPutText.Size = UDim2.fromOffset(90, 14);
				Slider.OutPutText.BackgroundTransparency = 1;
				Slider.OutPutText.Font = library.theme.Font;
				Slider.OutPutText.TextColor3 = library.theme.TextColor;
				Slider.OutPutText.TextSize = library.theme.TextSize - 1;
				Slider.OutPutText.Text = Slider.value;

				if Slider.flag and Slider.flag ~= "" then
					library.flags[Slider.flag] = Slider.default or Slider.min or 0;
				end

				function Slider:Get()
					return Slider.value;
				end

				function Slider:Set(value)
					Slider.value = math.clamp(math.round(value * Slider.decimals) / Slider.decimals, Slider.min, Slider.max);
					local percent = 1 - ((Slider.max - Slider.value) / (Slider.max - Slider.min));
					if Slider.flag and Slider.flag ~= "" then
						library.flags[Slider.flag] = Slider.value;
					end
					
					createTween(Slider.Slider, {
						Size = UDim2.fromOffset(percent * Slider.Main.AbsoluteSize.X, Slider.Main.AbsoluteSize.Y)
					}, 0.12, Enum.EasingStyle.Quart)
					
					Slider.OutPutText.Text = Slider.value;
					pcall(Slider.callback, Slider.value);
				end

				Slider:Set(Slider.default);

				function Slider:Refresh()
					local mousePos = game.Workspace.CurrentCamera:WorldToViewportPoint(game.Players.LocalPlayer:GetMouse().Hit.p);
					local percent = math.clamp(mousePos.X - Slider.Slider.AbsolutePosition.X, 0, Slider.Main.AbsoluteSize.X) / Slider.Main.AbsoluteSize.X;
					local value = math.floor((Slider.min + (Slider.max - Slider.min) * percent) * Slider.decimals) / Slider.decimals;
					value = math.clamp(value, Slider.min, Slider.max);
					Slider:Set(value);
				end

				Slider.Slider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true;
						createTween(Slider.Slider, {BackgroundColor3 = library.theme.SelectedHover}, 0.1)
						Slider:Refresh();
					end
				end)

				Slider.Slider.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false;
						createTween(Slider.Slider, {BackgroundColor3 = library.theme.Selected}, 0.2)
					end
				end)

				Slider.Main.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true;
						createTween(Slider.Slider, {BackgroundColor3 = library.theme.SelectedHover}, 0.1)
						Slider:Refresh();
					end
				end)

				Slider.Main.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false;
						createTween(Slider.Slider, {BackgroundColor3 = library.theme.Selected}, 0.2)
					end
				end)

				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						Slider:Refresh();
					end
				end)

				Sector:FixSize();
				table.insert(library.items, Slider);
				return Slider;
			end

			function Sector:CreateDropDown(Text, Items, Default, Multichoice, Callback, Flag)
				local DropDown = { };	
				DropDown.text = Text or "";
				DropDown.defaultitems = Items or { };
				DropDown.default = Default;
				DropDown.callback = Callback or function() end;
				DropDown.multichoice = Multichoice or false;
				DropDown.values = { };
				DropDown.flag = Flag or Text or "";

				DropDown.MainBack = Instance.new("TextButton", Sector.Items);
				DropDown.MainBack.BackgroundColor3 = library.theme.BackGround;
				DropDown.MainBack.AutoButtonColor = false;
				DropDown.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				DropDown.MainBack.Text = "";

				DropDown.UICorner = Instance.new("UICorner", DropDown.MainBack);
				DropDown.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(DropDown.MainBack,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)
				addClickEffect(DropDown.MainBack, 0.98)

				DropDown.TextLabel = Instance.new("TextLabel", DropDown.MainBack);
				DropDown.TextLabel.Text = DropDown.text;
				DropDown.TextLabel.BackgroundTransparency = 1;
				DropDown.TextLabel.TextColor3 = library.theme.TextColor;
				DropDown.TextLabel.TextSize = library.theme.TextSize;
				DropDown.TextLabel.Font = library.theme.Font;
				DropDown.TextLabel.Size = UDim2.fromOffset(100, 28);
				DropDown.TextLabel.Position = UDim2.fromScale(0.05, 0);
				DropDown.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

				DropDown.Main = Instance.new("TextButton", DropDown.MainBack);
				DropDown.Main.BackgroundColor3 = library.theme.Toggle;
				DropDown.Main.BorderSizePixel = 0;
				DropDown.Main.Position = UDim2.fromScale(0.55, 0.25);
				DropDown.Main.Size = UDim2.fromOffset(90, 14); -- Smaller dropdown
				DropDown.Main.TextSize = library.theme.TextSize - 1;
				DropDown.Main.TextColor3 = library.theme.TextColor;
				DropDown.Main.Font = library.theme.Font;
				DropDown.Main.AutoButtonColor = false;
				DropDown.Main.Text = "";
				
				local dropdownCorner = Instance.new("UICorner", DropDown.Main)
				dropdownCorner.CornerRadius = UDim.new(0, 3)

				DropDown.SelectedLable = Instance.new("TextLabel", DropDown.Main);
				DropDown.SelectedLable.Position = UDim2.fromOffset(4, 0);
				DropDown.SelectedLable.Size = UDim2.fromOffset(70, 14);
				DropDown.SelectedLable.BackgroundTransparency = 1;
				DropDown.SelectedLable.TextSize = library.theme.TextSize - 1;
				DropDown.SelectedLable.TextColor3 = library.theme.TextColor;
				DropDown.SelectedLable.Font = library.theme.Font;
				DropDown.SelectedLable.Text = DropDown.text;
				DropDown.SelectedLable.TextXAlignment = Enum.TextXAlignment.Left;

				DropDown.Arrow = Instance.new("TextLabel", DropDown.Main);
				DropDown.Arrow.Position = UDim2.fromScale(0.8, 0);
				DropDown.Arrow.Size = UDim2.fromOffset(14, 14);
				DropDown.Arrow.BackgroundTransparency = 1;
				DropDown.Arrow.TextSize = library.theme.TextSize - 2;
				DropDown.Arrow.TextColor3 = library.theme.TextColor;
				DropDown.Arrow.Font = library.theme.Font;
				DropDown.Arrow.Text = "▼";
				DropDown.Arrow.Rotation = 0;

				DropDown.Itemsframe = Instance.new("ScrollingFrame", DropDown.Main);
				DropDown.Itemsframe.BorderSizePixel = 0;
				DropDown.Itemsframe.BackgroundColor3 = library.theme.BackGround;
				DropDown.Itemsframe.Position = UDim2.fromOffset(0, DropDown.Main.Size.Y.Offset + 4);
				DropDown.Itemsframe.ScrollBarThickness = 1;
				DropDown.Itemsframe.ScrollBarImageColor3 = library.theme.Selected;
				DropDown.Itemsframe.ZIndex = 8;
				DropDown.Itemsframe.ScrollingDirection = "Y";
				DropDown.Itemsframe.Visible = false;
				DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Main.AbsoluteSize.X, 0);
				
				local itemsCorner = Instance.new("UICorner", DropDown.Itemsframe)
				itemsCorner.CornerRadius = UDim.new(0, 4)
				
				local itemsStroke = Instance.new("UIStroke", DropDown.Itemsframe)
				itemsStroke.Color = library.theme.Border
				itemsStroke.Thickness = 1

				DropDown.UIList = Instance.new("UIListLayout", DropDown.Itemsframe);
				DropDown.UIList.FillDirection = Enum.FillDirection.Vertical;
				DropDown.UIList.SortOrder = Enum.SortOrder.LayoutOrder;

				DropDown.IgnoreBackButtons = Instance.new("TextButton", DropDown.Main);
				DropDown.IgnoreBackButtons.BackgroundTransparency = 1;
				DropDown.IgnoreBackButtons.BorderSizePixel = 0;
				DropDown.IgnoreBackButtons.Position = UDim2.fromOffset(0, DropDown.Main.Size.Y.Offset + 4);
				DropDown.IgnoreBackButtons.Size = UDim2.new(0, 0, 0, 0);
				DropDown.IgnoreBackButtons.ZIndex = 7;
				DropDown.IgnoreBackButtons.Text = "";
				DropDown.IgnoreBackButtons.Visible = false;
				DropDown.IgnoreBackButtons.AutoButtonColor = false;

				if DropDown.flag and DropDown.flag ~= "" then
					library.flags[DropDown.flag] = DropDown.multichoice and { DropDown.default or DropDown.defaultitems[1] or "" } or (DropDown.default or DropDown.defaultitems[1] or "");
				end

				function DropDown:isSelected(item)
					for i, v in pairs(DropDown.values) do
						if v == item then
							return true;
						end
					end
					return false;
				end

				function DropDown:GetOptions()
					return DropDown.values;
				end

				function DropDown:updateText(text)
					if #text >= 12 then
						text = text:sub(1, 10) .. "..";
					end
					DropDown.SelectedLable.Text = text;
				end

				DropDown.Changed = Instance.new("BindableEvent");
				function DropDown:Set(value)
					if type(value) == "table" then
						DropDown.values = value;
						DropDown:updateText(table.concat(value, ", "));
						pcall(DropDown.callback, value);
					else
						DropDown:updateText(value);
						DropDown.values = { value };
						pcall(DropDown.callback, value);
					end

					DropDown.Changed:Fire(value)
					if DropDown.flag and DropDown.flag ~= "" then
						library.flags[DropDown.flag] = DropDown.multichoice and DropDown.values or DropDown.values[1];
					end
				end

				function DropDown:Get()
					return DropDown.multichoice and DropDown.values or DropDown.values[1];
				end

				DropDown.items = { }
				function DropDown:Add(v)
					local Item = Instance.new("TextButton", DropDown.Itemsframe);
					Item.BackgroundColor3 = library.theme.Toggle;
					Item.TextColor3 = library.theme.TextColor;
					Item.BorderSizePixel = 0;
					Item.Position = UDim2.fromOffset(0, 0);
					Item.Size = UDim2.fromOffset(90, 16); -- Smaller items
					Item.BackgroundTransparency = 0;
					Item.ZIndex = 9;
					Item.Text = v;
					Item.Name = v;
					Item.AutoButtonColor = false;
					Item.Font = library.theme.Font;
					Item.TextSize = library.theme.TextSize - 1;
					Item.TextXAlignment = Enum.TextXAlignment.Left;
					
					addHoverEffect(Item,
						{BackgroundColor3 = library.theme.SelectedHover, TextColor3 = Color3.fromRGB(255, 255, 255)},
						{BackgroundColor3 = library.theme.Toggle, TextColor3 = library.theme.TextColor}
					)

					Item.MouseButton1Down:Connect(function()
						if DropDown.multichoice then
							if DropDown:isSelected(v) then
								for i2, v2 in pairs(DropDown.values) do
									if v2 == v then
										table.remove(DropDown.values, i2);
									end
								end
								DropDown:Set(DropDown.values);
							else
								table.insert(DropDown.values, v);
								DropDown:Set(DropDown.values);
							end
							return
						else
							createTween(DropDown.Arrow, {Rotation = 0}, 0.15)
							createTween(DropDown.Itemsframe, {Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, 0)}, 0.15)
							wait(0.15)
							DropDown.Itemsframe.Visible = false;
							DropDown.Itemsframe.Active = false;
							DropDown.IgnoreBackButtons.Visible = false;
							DropDown.IgnoreBackButtons.Active = false;
						end

						DropDown:Set(v)
						return
					end)

					game:GetService("RunService").RenderStepped:Connect(function()
						if DropDown.multichoice and DropDown:isSelected(v) or DropDown.values[1] == v then
							Item.BackgroundColor3 = library.theme.Selected;
							Item.Text = v;
						else
							Item.BackgroundColor3 = library.theme.BackGround2;
							Item.Text = v;
						end
					end)

					table.insert(DropDown.items, v);
					DropDown.Itemsframe.Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, math.clamp(#DropDown.items * Item.AbsoluteSize.Y, 16, 120) + 2);
					DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Itemsframe.AbsoluteSize.X, (#DropDown.items * Item.AbsoluteSize.Y) + 2);

					DropDown.IgnoreBackButtons.Size = DropDown.Itemsframe.Size;
				end

				function DropDown:Remove(value)
					local item = DropDown.Itemsframe:FindFirstChild(value);
					if item then
						for i,v in pairs(DropDown.items) do
							if v == value then
								table.remove(DropDown.items, i);
							end
						end

						DropDown.Itemsframe.Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, math.clamp(#DropDown.items * item.AbsoluteSize.Y, 16, 120) + 2);
						DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Itemsframe.AbsoluteSize.X, (#DropDown.items * item.AbsoluteSize.Y) + 2);

						DropDown.IgnoreBackButtons.Size = DropDown.Itemsframe.Size;
						item:Remove();
					end
				end 

				for i,v in pairs(DropDown.defaultitems) do
					DropDown:Add(v);
				end

				if DropDown.default then
					DropDown:Set(DropDown.default);
				end

				local MouseButton1Down = function()
					if not DropDown.Itemsframe.Visible then
						if DropDown.items and #DropDown.items ~= 0 then
							createTween(DropDown.Arrow, {Rotation = 180}, 0.15)
							DropDown.Itemsframe.ScrollingEnabled = true;
							DropDown.Itemsframe.Visible = true;
							DropDown.Itemsframe.Active = true;
							DropDown.IgnoreBackButtons.Visible = true;
							DropDown.IgnoreBackButtons.Active = true;
							
							DropDown.Itemsframe.Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, 0)
							createTween(DropDown.Itemsframe, {
								Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, math.clamp(#DropDown.items * 16, 16, 120) + 2)
							}, 0.15)
						end
					else
						createTween(DropDown.Arrow, {Rotation = 0}, 0.15)
						createTween(DropDown.Itemsframe, {Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, 0)}, 0.15)
						wait(0.15)
						DropDown.Itemsframe.ScrollingEnabled = false;
						DropDown.Itemsframe.Visible = false;
						DropDown.Itemsframe.Active = false;
						DropDown.IgnoreBackButtons.Visible = false;
						DropDown.IgnoreBackButtons.Active = false;
					end
				end

				DropDown.MainBack.MouseButton1Down:Connect(MouseButton1Down)
				DropDown.Main.MouseButton1Down:Connect(MouseButton1Down)

				Sector:FixSize();
				table.insert(library.items, DropDown);
				return DropDown;
			end

			function Sector:CreateColorPicker(Text, Defult, CallBack, Flag)
				local ColorPicker = { };

				ColorPicker.callback = CallBack or function() end;
				ColorPicker.default = Defult or Color3.fromRGB(255, 255, 255);
				ColorPicker.value = ColorPicker.default;
				ColorPicker.flag = Flag or (Text or "");

				ColorPicker.MainBack = Instance.new("TextButton", Sector.Items);
				ColorPicker.MainBack.BackgroundColor3 = library.theme.BackGround;
				ColorPicker.MainBack.AutoButtonColor = false;
				ColorPicker.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				ColorPicker.MainBack.Text = "";

				ColorPicker.UiCorner = Instance.new("UICorner", ColorPicker.MainBack);
				ColorPicker.UiCorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(ColorPicker.MainBack,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)
				addClickEffect(ColorPicker.MainBack, 0.98)
				
				ColorPicker.Indicator = Instance.new("Frame", ColorPicker.MainBack);
				ColorPicker.Indicator.Position = UDim2.fromScale(0.88, 0.25);
				ColorPicker.Indicator.Size = UDim2.fromOffset(14, 14); -- Smaller indicator
				ColorPicker.Indicator.BackgroundColor3 = ColorPicker.default;
				ColorPicker.Indicator.BorderSizePixel = 0;
				
				local indicatorCorner = Instance.new("UICorner", ColorPicker.Indicator)
				indicatorCorner.CornerRadius = UDim.new(0, 3)
				
				local indicatorStroke = Instance.new("UIStroke", ColorPicker.Indicator)
				indicatorStroke.Color = library.theme.Border
				indicatorStroke.Thickness = 1

				ColorPicker.TextLabel = Instance.new("TextLabel", ColorPicker.MainBack);
				ColorPicker.TextLabel.Text = Text;
				ColorPicker.TextLabel.BackgroundTransparency = 1;
				ColorPicker.TextLabel.TextColor3 = library.theme.TextColor;
				ColorPicker.TextLabel.TextSize = library.theme.TextSize;
				ColorPicker.TextLabel.Font = library.theme.Font;
				ColorPicker.TextLabel.Size = UDim2.fromOffset(150, 28);
				ColorPicker.TextLabel.Position = UDim2.fromScale(0.05, 0);
				ColorPicker.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

				ColorPicker.MainPicker = Instance.new("TextButton", ColorPicker.MainBack);
				ColorPicker.MainPicker.Name = "picker";
				ColorPicker.MainPicker.ZIndex = 100;
				ColorPicker.MainPicker.Visible = false;
				ColorPicker.MainPicker.AutoButtonColor = false;
				ColorPicker.MainPicker.Text = "";
				ColorPicker.MainPicker.Size = UDim2.fromOffset(160, 180); -- Smaller picker
				ColorPicker.MainPicker.BorderSizePixel = 0;
				ColorPicker.MainPicker.BackgroundColor3 = library.theme.BackGround2;
				ColorPicker.MainPicker.Rotation = 0.000000000000001;
				ColorPicker.MainPicker.Position = UDim2.fromOffset(-ColorPicker.MainPicker.AbsoluteSize.X + ColorPicker.MainBack.AbsoluteSize.X, 15);
				window.OpenedColorPickers[ColorPicker.MainPicker] = false;
				
				local pickerCorner = Instance.new("UICorner", ColorPicker.MainPicker)
				pickerCorner.CornerRadius = UDim.new(0, 6)
				
				local pickerStroke = Instance.new("UIStroke", ColorPicker.MainPicker)
				pickerStroke.Color = library.theme.Border
				pickerStroke.Thickness = 1
				
				ColorPicker.hue = Instance.new("ImageLabel", ColorPicker.MainPicker);
				ColorPicker.hue.ZIndex = 101;
				ColorPicker.hue.Position = UDim2.new(0, 3, 0, 3);
				ColorPicker.hue.Size = UDim2.new(0, 152, 0, 152); -- Smaller hue selector
				ColorPicker.hue.Image = "rbxassetid://4155801252";
				ColorPicker.hue.ScaleType = Enum.ScaleType.Stretch;
				ColorPicker.hue.BackgroundColor3 = Color3.new(1, 0, 0);
				ColorPicker.hue.BorderColor3 = library.theme.Border;
				
				local hueCorner = Instance.new("UICorner", ColorPicker.hue)
				hueCorner.CornerRadius = UDim.new(0, 4)
				
				ColorPicker.hueselectorpointer = Instance.new("ImageLabel", ColorPicker.MainPicker);
				ColorPicker.hueselectorpointer.ZIndex = 101;
				ColorPicker.hueselectorpointer.BackgroundTransparency = 1;
				ColorPicker.hueselectorpointer.BorderSizePixel = 0;
				ColorPicker.hueselectorpointer.Position = UDim2.new(0, 0, 0, 0);
				ColorPicker.hueselectorpointer.Size = UDim2.new(0, 6, 0, 6); -- Smaller pointer
				ColorPicker.hueselectorpointer.Image = "rbxassetid://6885856475";
				
				ColorPicker.selector = Instance.new("TextLabel", ColorPicker.MainPicker);
				ColorPicker.selector.ZIndex = 100;
				ColorPicker.selector.Position = UDim2.new(0, 3, 0, 162);
				ColorPicker.selector.Size = UDim2.new(0, 153, 0, 8); -- Smaller selector
				ColorPicker.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				ColorPicker.selector.BorderColor3 = library.theme.Border;
				ColorPicker.selector.Text = "";
				
				local selectorCorner = Instance.new("UICorner", ColorPicker.selector)
				selectorCorner.CornerRadius = UDim.new(0, 4)
				
				ColorPicker.gradient = Instance.new("UIGradient", ColorPicker.selector);
				ColorPicker.gradient.Color = ColorSequence.new({ 
					ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
					ColorSequenceKeypoint.new(0.17, Color3.new(1, 0, 1)), 
					ColorSequenceKeypoint.new(0.33, Color3.new(0, 0, 1)), 
					ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
					ColorSequenceKeypoint.new(0.67, Color3.new(0, 1, 0)), 
					ColorSequenceKeypoint.new(0.83, Color3.new(1, 1, 0)), 
					ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
				})

				ColorPicker.pointer = Instance.new("Frame", ColorPicker.selector);
				ColorPicker.pointer.ZIndex = 101;
				ColorPicker.pointer.BackgroundColor3 = library.theme.Border;
				ColorPicker.pointer.Position = UDim2.new(0, 0, 0, 0);
				ColorPicker.pointer.Size = UDim2.new(0, 2, 0, 8);
				ColorPicker.pointer.BorderColor3 = library.theme.BackGround;

				if ColorPicker.flag and ColorPicker.flag ~= "" then
					library.flags[ColorPicker.flag] = ColorPicker.default;
				end

				function ColorPicker:RefreshHue()
					local x = (game.Players.LocalPlayer:GetMouse().X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X;
					local y = (game.Players.LocalPlayer:GetMouse().Y - ColorPicker.hue.AbsolutePosition.Y) / ColorPicker.hue.AbsoluteSize.Y;
					createTween(ColorPicker.hueselectorpointer, {
						Position = UDim2.new(math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 0.952 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 0, math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 0.885 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y, 0)
					}, 0.03)
					ColorPicker:Set(Color3.fromHSV(ColorPicker.color, math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 1 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 1 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y)));
				end

				function ColorPicker:RefreshSelector()
					local pos = math.clamp((game.Players.LocalPlayer:GetMouse().X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X, 0, 1);
					ColorPicker.color = 1 - pos;
					createTween(ColorPicker.pointer, {Position = UDim2.new(pos, 0, 0, 0)}, 0.03)
					ColorPicker.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1);

					local x = (ColorPicker.hueselectorpointer.AbsolutePosition.X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X;
					local y = (ColorPicker.hueselectorpointer.AbsolutePosition.Y - ColorPicker.hue.AbsolutePosition.Y) / ColorPicker.hue.AbsoluteSize.Y;
					ColorPicker:Set(Color3.fromHSV(ColorPicker.color, math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 1 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 1 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y)));
				end

				function ColorPicker:Set(value)
					local color = Color3.new(math.clamp(value.r, 0, 1), math.clamp(value.g, 0, 1), math.clamp(value.b, 0, 1));
					ColorPicker.value = color;
					if ColorPicker.flag and ColorPicker.flag ~= "" then
						library.flags[ColorPicker.flag] = color;
					end
					
					createTween(ColorPicker.Indicator, {BackgroundColor3 = color}, 0.15)
					pcall(ColorPicker.callback, color);
				end

				function ColorPicker:Get(value)
					return ColorPicker.value;
				end
				ColorPicker:Set(ColorPicker.default);

				local dragging_selector = false;
				local dragging_hue = false;

				ColorPicker.selector.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging_selector = true;
						ColorPicker:RefreshSelector();
					end
				end)

				ColorPicker.selector.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging_selector = false;
						ColorPicker:RefreshSelector();
					end
				end)

				ColorPicker.hue.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging_hue = true;
						ColorPicker:RefreshHue();
					end
				end)

				ColorPicker.hue.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging_hue = false;
						ColorPicker:RefreshHue();
					end
				end)

				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if dragging_selector and input.UserInputType == Enum.UserInputType.MouseMovement then
						ColorPicker:RefreshSelector();
					end
					if dragging_hue and input.UserInputType == Enum.UserInputType.MouseMovement then
						ColorPicker:RefreshHue();
					end
				end)

				local inputBegan = function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						for i,v in pairs(window.OpenedColorPickers) do
							if v and i ~= ColorPicker.MainPicker then
								createTween(i, {Size = UDim2.fromOffset(0, 0)}, 0.15)
								wait(0.15)
								i.Visible = false;
								window.OpenedColorPickers[i] = false;
							end
						end

						if not ColorPicker.MainPicker.Visible then
							ColorPicker.MainPicker.Visible = true;
							ColorPicker.MainPicker.Size = UDim2.fromOffset(0, 0)
							createTween(ColorPicker.MainPicker, {Size = UDim2.fromOffset(160, 180)}, 0.2, Enum.EasingStyle.Back)
						else
							createTween(ColorPicker.MainPicker, {Size = UDim2.fromOffset(0, 0)}, 0.15)
							wait(0.15)
							ColorPicker.MainPicker.Visible = false;
						end
						
						window.OpenedColorPickers[ColorPicker.MainPicker] = ColorPicker.MainPicker.Visible;
					end
				end

				ColorPicker.MainBack.InputBegan:Connect(inputBegan);
				
				Sector:FixSize();
				table.insert(library.items, ColorPicker);
				return ColorPicker;
			end

			function Sector:CreateKeyBind(Text, Default, CallBack, Flag)
				local keybind = { };
				keybind.text = Text or "";
				keybind.default = Default or "None";
				keybind.value = keybind.default;
				keybind.callback = CallBack or function() end;
				keybind.flag = Flag or Text or "";

				local shorter_keycodes = {
					["LeftShift"] = "LSHIFT",
					["RightShift"] = "RSHIFT",
					["LeftControl"] = "LCTRL",
					["RightControl"] = "RCTRL",
					["LeftAlt"] = "LALT",
					["RightAlt"] = "RALT"
				}

				local text = keybind.default == "None" and "None" or (shorter_keycodes[keybind.default.Name] or keybind.default.Name)

				keybind.MainBack = Instance.new("TextButton", Sector.Items);
				keybind.MainBack.BackgroundColor3 = library.theme.BackGround;
				keybind.MainBack.AutoButtonColor = false;
				keybind.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				keybind.MainBack.Text = "";

				keybind.UICorner = Instance.new("UICorner", keybind.MainBack);
				keybind.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(keybind.MainBack,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)
				addClickEffect(keybind.MainBack, 0.98)

				keybind.TextLabel = Instance.new("TextLabel", keybind.MainBack);
				keybind.TextLabel.Text = keybind.text;
				keybind.TextLabel.BackgroundTransparency = 1;
				keybind.TextLabel.TextColor3 = library.theme.TextColor;
				keybind.TextLabel.TextSize = library.theme.TextSize;
				keybind.TextLabel.Font = library.theme.Font;
				keybind.TextLabel.Size = UDim2.fromOffset(100, 28);
				keybind.TextLabel.Position = UDim2.fromScale(0.05, 0);
				keybind.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

				keybind.Main = Instance.new("TextButton", keybind.MainBack);
				keybind.Main.BorderSizePixel = 0;
				keybind.Main.BackgroundColor3 = library.theme.Toggle;
				keybind.Main.Size = UDim2.fromOffset(90, 14); -- Smaller keybind button
				keybind.Main.Position = UDim2.fromScale(0.55, 0.25);
				keybind.Main.Text = text;
				keybind.Main.Font = library.theme.Font;
				keybind.Main.TextColor3 = library.theme.TextColor;
				keybind.Main.TextSize = library.theme.TextSize - 1;
				keybind.Main.TextXAlignment = Enum.TextXAlignment.Center;
				keybind.Main.AutoButtonColor = false;
				
				local keybindCorner = Instance.new("UICorner", keybind.Main)
				keybindCorner.CornerRadius = UDim.new(0, 3)
				
				addHoverEffect(keybind.Main,
					{BackgroundColor3 = library.theme.ToggleHover, TextColor3 = library.theme.Selected},
					{BackgroundColor3 = library.theme.Toggle, TextColor3 = library.theme.TextColor}
				)
				
				keybind.Main.MouseButton1Down:Connect(function()
					keybind.Main.Text = "...";
					local pulseConnection
					pulseConnection = runservice.Heartbeat:Connect(function()
						if keybind.Main.Text == "..." then
							createTween(keybind.Main, {BackgroundColor3 = library.theme.Selected}, 0.5)
							wait(0.5)
							createTween(keybind.Main, {BackgroundColor3 = library.theme.Toggle}, 0.5)
						else
							pulseConnection:Disconnect()
						end
					end)
				end)

				if keybind.flag and keybind.flag ~= "" then
					library.flags[keybind.flag] = keybind.default;
				end

				function keybind:Set(key)
					if key == "None" then
						keybind.Main.Text = key;
						keybind.value = key;
						if keybind.flag and keybind.flag ~= "" then
							library.flags[keybind.flag] = key;
						end
						return
					end
					
					createTween(keybind.Main, {TextColor3 = library.theme.Selected}, 0.15)
					keybind.Main.Text = (shorter_keycodes[key.Name] or key.Name);
					keybind.value = key;
					if keybind.flag and keybind.flag ~= "" then
						library.flags[keybind.flag] = keybind.value;
					end
					
					wait(0.3)
					createTween(keybind.Main, {TextColor3 = library.theme.TextColor}, 0.15)
				end

				function keybind:Get()
					return keybind.value;
				end

				game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed then
						if keybind.Main.Text == "..." then
							if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Backspace then
								keybind:Set(input.KeyCode);
								pcall(keybind.callback, keybind.value);
							else
								keybind:Set("None");
							end
						end
					end
				end)

				Sector:FixSize();
				table.insert(library.items, keybind);
				return keybind;
			end

			function Sector:CreateCoppyText(Text)
				local CoppyText = { };

				CoppyText.MainBack = Instance.new("TextButton", Sector.Items);
				CoppyText.MainBack.BackgroundColor3 = library.theme.BackGround;
				CoppyText.MainBack.AutoButtonColor = false;
				CoppyText.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				CoppyText.MainBack.Text = "";

				CoppyText.UICorner = Instance.new("UICorner", CoppyText.MainBack);
				CoppyText.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(CoppyText.MainBack,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)

				CoppyText.TextLabel = Instance.new("TextBox", CoppyText.MainBack);
				CoppyText.TextLabel.Text = Text;
				CoppyText.TextLabel.ClearTextOnFocus = false;
				CoppyText.TextLabel.Interactable = true;
				CoppyText.TextLabel.TextEditable = false;
				CoppyText.TextLabel.Active = false;
				CoppyText.TextLabel.BackgroundTransparency = 1;
				CoppyText.TextLabel.TextColor3 = library.theme.TextColor;
				CoppyText.TextLabel.TextSize = library.theme.TextSize;
				CoppyText.TextLabel.Font = library.theme.Font;
				CoppyText.TextLabel.Size = UDim2.fromOffset(220, 28);
				CoppyText.TextLabel.Position = UDim2.fromScale(0, 0);
				CoppyText.TextLabel.TextXAlignment = Enum.TextXAlignment.Center;

				Sector:FixSize();
				table.insert(library.items, CoppyText);
				return CoppyText;
			end

			function Sector:CreateLable(Text)
				local Lable = { };

				Lable.MainBack = Instance.new("TextButton", Sector.Items);
				Lable.MainBack.BackgroundColor3 = library.theme.BackGround;
				Lable.MainBack.AutoButtonColor = false;
				Lable.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				Lable.MainBack.Text = "";

				Lable.UICorner = Instance.new("UICorner", Lable.MainBack);
				Lable.UICorner.CornerRadius = UDim.new(0, 6);

				Lable.TextLabel = Instance.new("TextLabel", Lable.MainBack);
				Lable.TextLabel.Text = Text;
				Lable.TextLabel.BackgroundTransparency = 1;
				Lable.TextLabel.TextColor3 = library.theme.TextColor;
				Lable.TextLabel.TextSize = library.theme.TextSize;
				Lable.TextLabel.Font = library.theme.Font;
				Lable.TextLabel.Size = UDim2.fromOffset(220, 28);
				Lable.TextLabel.Position = UDim2.fromScale(0, 0);
				Lable.TextLabel.TextXAlignment = Enum.TextXAlignment.Center;

				Sector:FixSize();
				table.insert(library.items, Lable);
				return Lable;
			end

			function Sector:CreateTextBox(Text, Default, Callback, Flag)
				local TextBox = { };
				TextBox.text = Text or "";
				TextBox.callback = Callback or function() end;
				TextBox.default = Default;
				TextBox.value = "";
				TextBox.flag = Flag or Text or "";

				TextBox.MainBack = Instance.new("TextButton", Sector.Items);
				TextBox.MainBack.BackgroundColor3 = library.theme.BackGround;
				TextBox.MainBack.AutoButtonColor = false;
				TextBox.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				TextBox.MainBack.Text = "";

				TextBox.UICorner = Instance.new("UICorner", TextBox.MainBack);
				TextBox.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(TextBox.MainBack,
					{BackgroundColor3 = library.theme.BackGroundHover},
					{BackgroundColor3 = library.theme.BackGround}
				)

				TextBox.TextLabel = Instance.new("TextLabel", TextBox.MainBack);
				TextBox.TextLabel.Text = TextBox.text;
				TextBox.TextLabel.BackgroundTransparency = 1;
				TextBox.TextLabel.TextColor3 = library.theme.TextColor;
				TextBox.TextLabel.TextSize = library.theme.TextSize;
				TextBox.TextLabel.Font = library.theme.Font;
				TextBox.TextLabel.Size = UDim2.fromOffset(100, 28);
				TextBox.TextLabel.Position = UDim2.fromScale(0.05, 0);
				TextBox.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

				TextBox.Main = Instance.new("TextBox", TextBox.MainBack);
				TextBox.Main.Position = UDim2.fromScale(0.55, 0.25);
				TextBox.Main.Size = UDim2.fromOffset(90, 14); -- Smaller textbox
				TextBox.Main.BackgroundColor3 = library.theme.Toggle;
				TextBox.Main.BorderSizePixel = 0;
				TextBox.Main.Text = "";
				TextBox.Main.TextColor3 = library.theme.TextColor;
				TextBox.Main.Font = library.theme.Font;
				TextBox.Main.TextSize = library.theme.TextSize - 1;
				TextBox.Main.ClearTextOnFocus = false;
				
				local textboxCorner = Instance.new("UICorner", TextBox.Main)
				textboxCorner.CornerRadius = UDim.new(0, 3)
				
				TextBox.Main.Focused:Connect(function()
					createTween(TextBox.Main, {
						BackgroundColor3 = library.theme.ToggleHover,
						BorderSizePixel = 1
					}, 0.15)
				end)
				
				TextBox.Main.FocusLost:Connect(function()
					createTween(TextBox.Main, {
						BackgroundColor3 = library.theme.Toggle,
						BorderSizePixel = 0
					}, 0.15)
				end)

				if TextBox.flag and TextBox.flag ~= "" then
					library.flags[TextBox.flag] = TextBox.default or ""
				end

				function TextBox:Set(text)
					TextBox.value = text
					TextBox.Main.Text = text
					if TextBox.flag and TextBox.flag ~= "" then
						library.flags[TextBox.flag] = text
					end
					pcall(TextBox.callback, text)
				end

				function TextBox:Get()
					return TextBox.value
				end

				if TextBox.default then 
					TextBox:Set(TextBox.default)
				end

				TextBox.Main.FocusLost:Connect(function()
					TextBox:Set(TextBox.Main.Text)
				end)

				Sector:FixSize();
				table.insert(library.items, TextBox);
				return TextBox;
			end

			function Sector:CreateButton(Text, Callback)
				local Button = { };
				Button.text = Text or ""
				Button.callback = Callback or function() end

				Button.MainBack = Instance.new("TextButton", Sector.Items);
				Button.MainBack.BackgroundColor3 = library.theme.BackGround;
				Button.MainBack.AutoButtonColor = false;
				Button.MainBack.Size = UDim2.fromOffset(220, 28); -- More compact
				Button.MainBack.Text = "";
				Button.MainBack.Text = Button.text;
				Button.MainBack.Font = library.theme.Font;
				Button.MainBack.TextColor3 = library.theme.TextColor;
				Button.MainBack.TextSize = library.theme.TextSize;

				Button.UICorner = Instance.new("UICorner", Button.MainBack);
				Button.UICorner.CornerRadius = UDim.new(0, 6);
				
				addHoverEffect(Button.MainBack,
					{BackgroundColor3 = library.theme.Selected, TextColor3 = Color3.fromRGB(255, 255, 255)},
					{BackgroundColor3 = library.theme.BackGround, TextColor3 = library.theme.TextColor}
				)
				addClickEffect(Button.MainBack, 0.98)
				
				Button.MainBack.MouseButton1Click:Connect(function()
					-- Add click ripple effect
					local ripple = Instance.new("Frame", Button.MainBack)
					ripple.Name = "Ripple"
					ripple.BackgroundColor3 = library.theme.Selected
					ripple.BackgroundTransparency = 0.5
					ripple.BorderSizePixel = 0
					ripple.Size = UDim2.fromOffset(0, 0)
					ripple.Position = UDim2.fromScale(0.5, 0.5)
					ripple.AnchorPoint = Vector2.new(0.5, 0.5)
					
					local rippleCorner = Instance.new("UICorner", ripple)
					rippleCorner.CornerRadius = UDim.new(1, 0)
					
					createTween(ripple, {
						Size = UDim2.fromOffset(250, 250),
						BackgroundTransparency = 1
					}, 0.4)
					
					game:GetService("Debris"):AddItem(ripple, 0.4)
					Button.callback()
				end);

				Sector:FixSize();
				return Button;
			end

			return Sector;
		end

		function tab:CreateConfig(side) 
			local ConfigSystem = { };

			ConfigSystem.configFolder = window.name;

			if isfolder and makefolder and listfiles and writefile and readfile and delfile then
				if (not isfolder(window.name)) then
					makefolder(window.name);
				end

				ConfigSystem.sector = tab:CreateSector("Configs", side or "left");

				local ConfigName = ConfigSystem.sector:CreateTextBox("Config Name", "", ConfigName, function() end, "");
				local default = tostring(listfiles(ConfigSystem.configFolder)[1] or ""):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", "");
				local Config = ConfigSystem.sector:CreateDropDown("Configs", {}, default, false, function() end, "");
				for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
					if v:find(".txt") then
						Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
					end
				end

				ConfigSystem.Create = ConfigSystem.sector:CreateButton("Create", function()
					for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
						Config:Remove(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
					end

					if ConfigName:Get() and ConfigName:Get() ~= "" then
						local config = {};

						for i,v in pairs(library.flags) do
							if (v ~= nil and v ~= "") then
								if (typeof(v) == "Color3") then
									config[i] = { v.R, v.G, v.B };
								elseif (tostring(v):find("Enum.KeyCode")) then
									config[i] = v.Name
								elseif (typeof(v) == "table") then
									config[i] = { v };
								else
									config[i] = v;
								end
							end
						end

						writefile(ConfigSystem.configFolder .. "/" .. ConfigName:Get() .. ".txt", httpservice:JSONEncode(config));

						for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
							if v:find(".txt") then
								Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
							end
						end
					end
				end)

				ConfigSystem.Save = ConfigSystem.sector:CreateButton("Save", function()
					local config = {}
					if Config:Get() and Config:Get() ~= "" then
						for i,v in pairs(library.flags) do
							if (v ~= nil and v ~= "") then
								if (typeof(v) == "Color3") then
									config[i] = { v.R, v.G, v.B };
								elseif (tostring(v):find("Enum.KeyCode")) then
									config[i] = "Enum.KeyCode." .. v.Name;
								elseif (typeof(v) == "table") then
									config[i] = { v };
								else
									config[i] = v;
								end
							end
						end

						writefile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt", httpservice:JSONEncode(config));
					end
				end)

				ConfigSystem.Load = ConfigSystem.sector:CreateButton("Load", function()
					local Success = pcall(readfile, ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt");
					if (Success) then
						pcall(function() 
							local ReadConfig = httpservice:JSONDecode(readfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt"));
							local NewConfig = {};

							for i,v in pairs(ReadConfig) do
								if (typeof(v) == "table") then
									if (typeof(v[1]) == "number") then
										NewConfig[i] = Color3.new(v[1], v[2], v[3]);
									elseif (typeof(v[1]) == "table") then
										NewConfig[i] = v[1];
									end
								elseif (tostring(v):find("Enum.KeyCode.")) then
									NewConfig[i] = Enum.KeyCode[tostring(v):gsub("Enum.KeyCode.", "")];
								else
									NewConfig[i] = v;
								end
							end

							library.flags = NewConfig;

							for i,v in pairs(library.flags) do
								for i2,v2 in pairs(library.items) do
									if (i ~= nil and i ~= "" and i ~= "Configs_Name" and i ~= "Configs" and v2.flag ~= nil) then
										if (v2.flag == i) then
											pcall(function() 
												v2:Set(v);
											end)
										end
									end
								end
							end
						end)
					end
				end)

				ConfigSystem.Delete = ConfigSystem.sector:CreateButton("Delete", function()
					for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
						Config:Remove(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
					end

					if (not Config:Get() or Config:Get() == "") then return end
					if (not isfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt")) then return; end;
					delfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt");

					for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
						if v:find(".txt") then
							Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
						end;
					end;
				end);
			else
				ConfigSystem.sector = tab:CreateSector("Configs", side or "left");
				ConfigSystem.sector:CreateLable("Your Executor Is Not Supported");
			end

			return ConfigSystem;
		end

		table.insert(window.Tabs, tab)
		return tab;
	end

	return window;
end

return library;
