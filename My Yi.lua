-- My yi.lua
local MyUILibrary = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local function makeUICorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function makeDraggable(frame)
	local dragging, dragInput, startPos, startInputPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.Touch then
			dragging = true
			startPos = frame.Position
			startInputPos = input.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - startInputPos
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function MyUILibrary:CreateWindow(titleText)
	local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	gui.Name = "MyUILib"

	local toggleButton = Instance.new("TextButton", gui)
	toggleButton.Size = UDim2.new(0, 100, 0, 30)
	toggleButton.Position = UDim2.new(0, 10, 0, 10)
	toggleButton.Text = "Toggle UI"
	toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	makeUICorner(toggleButton)

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 500, 0, 400)
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	makeUICorner(main, 12)
	makeDraggable(main)

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
	makeUICorner(tabsHolder)

	local contentHolder = Instance.new("Frame", main)
	contentHolder.Size = UDim2.new(1, -120, 1, -40)
	contentHolder.Position = UDim2.new(0, 120, 0, 40)
	contentHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	makeUICorner(contentHolder)

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
		tabContent.BackgroundTransparency = 1
		tabContent.ScrollBarThickness = 6
		tabContent.Visible = false
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)

		local layout = Instance.new("UIListLayout", tabContent)
		layout.Padding = UDim.new(0, 6)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

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

		function tabAPI:AddTextBox(placeholder, callback)
			local box = Instance.new("TextBox", tabContent)
			box.Size = UDim2.new(1, -20, 0, 30)
			box.Position = UDim2.new(0, 10, 0, 0)
			box.PlaceholderText = placeholder
			box.Text = ""
			box.TextColor3 = Color3.new(1, 1, 1)
			box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			box.Font = Enum.Font.Gotham
			box.TextSize = 14
			makeUICorner(box)

			box.FocusLost:Connect(function()
				callback(box.Text)
			end)
		end

		function tabAPI:AddDropdown(name, options, callback)
			local dropdown = Instance.new("TextButton", tabContent)
			dropdown.Size = UDim2.new(1, -20, 0, 30)
			dropdown.Position = UDim2.new(0, 10, 0, 0)
			dropdown.Text = name .. ": (Click to select)"
			dropdown.TextColor3 = Color3.new(1, 1, 1)
			dropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			dropdown.Font = Enum.Font.Gotham
			dropdown.TextSize = 14
			makeUICorner(dropdown)

			local menuOpen = false
			local optionButtons = {}

			dropdown.MouseButton1Click:Connect(function()
				menuOpen = not menuOpen
				for _, btn in ipairs(optionButtons) do
					btn.Visible = menuOpen
				end
			end)

			for _, option in ipairs(options) do
				local optBtn = Instance.new("TextButton", tabContent)
				optBtn.Size = UDim2.new(1, -40, 0, 28)
				optBtn.Position = UDim2.new(0, 20, 0, 0)
				optBtn.Text = " - " .. option
				optBtn.TextColor3 = Color3.new(1, 1, 1)
				optBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
				optBtn.Font = Enum.Font.Gotham
				optBtn.TextSize = 14
				optBtn.Visible = false
				makeUICorner(optBtn)

				optBtn.MouseButton1Click:Connect(function()
					dropdown.Text = name .. ": " .. option
					callback(option)
					menuOpen = false
					for _, b in ipairs(optionButtons) do b.Visible = false end
				end)

				table.insert(optionButtons, optBtn)
			end
		end

		function tabAPI:AddSlider(name, min, max, default, callback)
			local frame = Instance.new("Frame", tabContent)
			frame.Size = UDim2.new(1, -20, 0, 40)
			frame.Position = UDim2.new(0, 10, 0, 0)
			frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			makeUICorner(frame)

			local label = Instance.new("TextLabel", frame)
			label.Size = UDim2.new(1, 0, 0.5, 0)
			label.BackgroundTransparency = 1
			label.Text = name .. ": " .. tostring(default)
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14

			local sliderBar = Instance.new("Frame", frame)
			sliderBar.Size = UDim2.new(1, -10, 0, 8)
			sliderBar.Position = UDim2.new(0, 5, 1, -12)
			sliderBar.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
			makeUICorner(sliderBar)

			local knob = Instance.new("Frame", sliderBar)
			knob.Size = UDim2.new(0, 10, 1, 0)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			makeUICorner(knob)

			local function updateKnob(x)
				local percent = math.clamp((x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
				local value = math.floor(min + (max - min) * percent)
				knob.Position = UDim2.new(percent, -5, 0, 0)
				label.Text = name .. ": " .. tostring(value)
				callback(value)
			end

			sliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					updateKnob(input.Position.X)
					local conn
					conn = UserInputService.InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == input.UserInputType then
							updateKnob(moveInput.Position.X)
						end
					end)
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							conn:Disconnect()
						end
					end)
				end
			end)
		end

		return tabAPI
	end

	return tabs
end

return MyUILibrary
