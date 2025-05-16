-- MyUILibrary.lua (bản đầy đủ có Dropdown, Slider, Drag, Toggle UI)
local MyUILibrary = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function makeUICorner(parent, radius)
	local corner = Instance.new("UICorner", parent)
	corner.CornerRadius = UDim.new(0, radius or 8)
	return corner
end

function MyUILibrary:CreateWindow(titleText)
	local gui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "MyUILib"
	gui.ResetOnSpawn = false

	local toggleButton = Instance.new("TextButton", gui)
	toggleButton.Size = UDim2.new(0, 40, 0, 40)
	toggleButton.Position = UDim2.new(0, 10, 0, 10)
	toggleButton.Text = "☰"
	toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 20
	makeUICorner(toggleButton)

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 500, 0, 400)
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.Visible = true
	makeUICorner(main, 12)

	-- Drag support
	local dragging, dragInput, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	main.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	toggleButton.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)

	local title = Instance.new("TextLabel", main)
	title.Text = titleText
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24

	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(0, 120, 1, -40)
	tabsHolder.Position = UDim2.new(0, 0, 0, 40)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	makeUICorner(tabsHolder, 0)

	local contentHolder = Instance.new("Frame", main)
	contentHolder.Size = UDim2.new(1, -120, 1, -40)
	contentHolder.Position = UDim2.new(0, 120, 0, 40)
	contentHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	makeUICorner(contentHolder, 0)

	local tabs = {}

	function tabs:AddTab(tabName)
		local tabBtn = Instance.new("TextButton", tabsHolder)
		tabBtn.Size = UDim2.new(1, 0, 0, 40)
		tabBtn.Text = tabName
		tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)
		tabBtn.Font = Enum.Font.Gotham
		tabBtn.TextSize = 14
		makeUICorner(tabBtn)

		local tabContent = Instance.new("ScrollingFrame", contentHolder)
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.CanvasSize = UDim2.new(0, 0, 10, 0)
		tabContent.ScrollBarThickness = 6
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false

		local layout = Instance.new("UIListLayout", tabContent)
		layout.Padding = UDim.new(0, 6)

		tabBtn.MouseButton1Click:Connect(function()
			for _, child in ipairs(contentHolder:GetChildren()) do
				if child:IsA("ScrollingFrame") then
					child.Visible = false
				end
			end
			tabContent.Visible = true
		end)

		local tabAPI = {}

		function tabAPI:AddButton(text, callback)
			local btn = Instance.new("TextButton", tabContent)
			btn.Size = UDim2.new(1, -20, 0, 30)
			btn.Position = UDim2.new(0, 10, 0, 0)
			btn.Text = text
			btn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			makeUICorner(btn)
			btn.MouseButton1Click:Connect(callback)
		end

		function tabAPI:AddToggle(text, default, callback)
			local toggle = Instance.new("TextButton", tabContent)
			toggle.Size = UDim2.new(1, -20, 0, 30)
			toggle.Position = UDim2.new(0, 10, 0, 0)
			toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
			toggle.Text = text .. ": " .. tostring(default)
			toggle.TextColor3 = Color3.new(1, 1, 1)
			toggle.Font = Enum.Font.Gotham
			toggle.TextSize = 14
			makeUICorner(toggle)

			local state = default
			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
				toggle.Text = text .. ": " .. tostring(state)
				callback(state)
			end)
		end

		function tabAPI:AddDropdown(name, options, callback)
			local dropdown = Instance.new("Frame", tabContent)
			dropdown.Size = UDim2.new(1, -20, 0, 30 + (#options * 25))
			dropdown.Position = UDim2.new(0, 10, 0, 0)
			dropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			makeUICorner(dropdown)

			local button = Instance.new("TextButton", dropdown)
			button.Size = UDim2.new(1, 0, 0, 30)
			button.Text = name .. ": (Select)"
			button.TextColor3 = Color3.new(1, 1, 1)
			button.BackgroundTransparency = 1
			button.Font = Enum.Font.Gotham
			button.TextSize = 14

			local open = false
			for i, option in ipairs(options) do
				local optBtn = Instance.new("TextButton", dropdown)
				optBtn.Size = UDim2.new(1, 0, 0, 25)
				optBtn.Position = UDim2.new(0, 0, 0, 30 + ((i - 1) * 25))
				optBtn.Text = option
				optBtn.Visible = false
				optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				optBtn.TextColor3 = Color3.new(1, 1, 1)
				optBtn.Font = Enum.Font.Gotham
				optBtn.TextSize = 14
				makeUICorner(optBtn)

				optBtn.MouseButton1Click:Connect(function()
					button.Text = name .. ": " .. option
					callback(option)
					for _, child in ipairs(dropdown:GetChildren()) do
						if child:IsA("TextButton") and child ~= button then
							child.Visible = false
						end
					end
					open = false
				end)
			end

			button.MouseButton1Click:Connect(function()
				open = not open
				for _, child in ipairs(dropdown:GetChildren()) do
					if child:IsA("TextButton") and child ~= button then
						child.Visible = open
					end
				end
			end)
		end

		function tabAPI:AddSlider(name, min, max, default, callback)
			local frame = Instance.new("Frame", tabContent)
			frame.Size = UDim2.new(1, -20, 0, 40)
			frame.Position = UDim2.new(0, 10, 0, 0)
			frame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			makeUICorner(frame)

			local label = Instance.new("TextLabel", frame)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.Text = name .. ": " .. tostring(default)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14

			local bar = Instance.new("Frame", frame)
			bar.Size = UDim2.new(1, -20, 0, 10)
			bar.Position = UDim2.new(0, 10, 0, 25)
			bar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			makeUICorner(bar)

			local fill = Instance.new("Frame", bar)
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			makeUICorner(fill)

			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
				end
			end)
			bar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local relativeX = input.Position.X - bar.AbsolutePosition.X
					local percent = math.clamp(relativeX / bar.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(percent, 0, 1, 0)
					local value = math.floor(min + (max - min) * percent)
					label.Text = name .. ": " .. value
					callback(value)
				end
			end)
		end

		return tabAPI
	end

	return tabs
end

return MyUILibrary
