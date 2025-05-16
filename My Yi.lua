-- MyUILibrary.lua
local MyUILibrary = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function makeUICorner(parent, radius)
	local corner = Instance.new("UICorner", parent)
	corner.CornerRadius = UDim.new(0, radius or 8)
	return corner
end

local function makeLabel(parent, text, size, color)
	local label = Instance.new("TextLabel", parent)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 0, size)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end

function MyUILibrary:CreateWindow(titleText)
	local gui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "MyUILib"

	local toggleBtn = Instance.new("TextButton", gui)
	toggleBtn.Size = UDim2.new(0, 30, 0, 30)
	toggleBtn.Position = UDim2.new(0, 10, 0, 10)
	toggleBtn.Text = "≡"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	makeUICorner(toggleBtn)

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 500, 0, 400)
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	makeUICorner(main, 12)

	local dragging, dragInput, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	main.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	toggleBtn.MouseButton1Click:Connect(function()
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

		local tabContent = Instance.new("Frame", contentHolder)
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false

		local layout = Instance.new("UIListLayout", tabContent)
		layout.Padding = UDim.new(0, 6)

		tabBtn.MouseButton1Click:Connect(function()
			for _, child in ipairs(contentHolder:GetChildren()) do
				if child:IsA("Frame") then child.Visible = false end
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

		function tabAPI:AddLabel(text)
			return makeLabel(tabContent, text, 30)
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
			local dropdown = Instance.new("TextButton", tabContent)
			dropdown.Size = UDim2.new(1, -20, 0, 30)
			dropdown.Position = UDim2.new(0, 10, 0, 0)
			dropdown.Text = name .. ": (Click to select)"
			dropdown.TextColor3 = Color3.new(1, 1, 1)
			dropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			dropdown.Font = Enum.Font.Gotham
			dropdown.TextSize = 14
			makeUICorner(dropdown)

			dropdown.MouseButton1Click:Connect(function()
				for _, option in ipairs(options) do
					callback(option)
					dropdown.Text = name .. ": " .. option
					wait(0.2)
					break
				end
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

		function tabAPI:AddKeybind(description, callback)
			local key = Enum.KeyCode.Unknown
			local btn = Instance.new("TextButton", tabContent)
			btn.Size = UDim2.new(1, -20, 0, 30)
			btn.Position = UDim2.new(0, 10, 0, 0)
			btn.Text = description .. ": [None]"
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			makeUICorner(btn)

			btn.MouseButton1Click:Connect(function()
				btn.Text = description .. ": [Press Key]"
				local conn
				conn = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode
						btn.Text = description .. ": [" .. key.Name .. "]"
						callback(key)
						conn:Disconnect()
					end
				end)
			end)

			UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == key then callback(key) end
			end)
		end

		function tabAPI:AddSlider(text, min, max, default, callback)
			local frame = Instance.new("Frame", tabContent)
			frame.Size = UDim2.new(1, -20, 0, 40)
			frame.Position = UDim2.new(0, 10, 0, 0)
			frame.BackgroundTransparency = 1

			local label = makeLabel(frame, text .. ": " .. default, 20)
			label.Position = UDim2.new(0, 0, 0, 0)

			local slider = Instance.new("Frame", frame)
			slider.Size = UDim2.new(1, 0, 0, 10)
			slider.Position = UDim2.new(0, 0, 0, 25)
			slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			makeUICorner(slider)

			local fill = Instance.new("Frame", slider)
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
			fill.BorderSizePixel = 0
			makeUICorner(fill)

			local dragging = false
			slider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
			end)
			slider.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)

			RunService.RenderStepped:Connect(function()
				if dragging then
					local mousePos = UserInputService:GetMouseLocation().X
					local rel = math.clamp((mousePos - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(rel, 0, 1, 0)
					local val = math.floor(min + (max - min) * rel)
					label.Text = text .. ": " .. val
					callback(val)
				end
			end)
		end

		function tabAPI:AddColorPicker(labelText, defaultColor, callback)
			local btn = Instance.new("TextButton", tabContent)
			btn.Size = UDim2.new(1, -20, 0, 30)
			btn.Position = UDim2.new(0, 10, 0, 0)
			btn.Text = labelText
			btn.BackgroundColor3 = defaultColor
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			makeUICorner(btn)

			btn.MouseButton1Click:Connect(function()
				-- Simple random color picker simulation
				local newColor = Color3.fromHSV(math.random(), 1, 1)
				btn.BackgroundColor3 = newColor
				callback(newColor)
			end)
		end

		return tabAPI
	end

	return tabs
end

return MyUILibrary
