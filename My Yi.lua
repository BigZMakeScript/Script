-- Custom UI Library (Full)

local UILib = {}

-- Services local UIS = game:GetService("UserInputService")

-- Main GUI local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "CustomUILib" ScreenGui.ResetOnSpawn = false ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame") main.Size = UDim2.new(0, 400, 0, 300) main.Position = UDim2.new(0.3, 0, 0.3, 0) main.BackgroundColor3 = Color3.fromRGB(30, 30, 30) main.Parent = ScreenGui

local function makeUICorner(obj) local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0, 6) uic.Parent = obj end makeUICorner(main)

-- Drag support local dragging, dragInput, dragStart, startPos main.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = main.Position

input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then dragging = false end
	end)
end

end)

main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)

UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

-- Toggle UI Button local toggleBtn = Instance.new("TextButton") toggleBtn.Size = UDim2.new(0, 80, 0, 30) toggleBtn.Position = UDim2.new(0, 0, 0.45, 0) toggleBtn.Text = "Toggle UI" toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) toggleBtn.TextColor3 = Color3.new(1, 1, 1) toggleBtn.Parent = ScreenGui makeUICorner(toggleBtn)

toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- Tabs local tabHolder = Instance.new("Frame", main) tabHolder.Size = UDim2.new(0, 100, 1, 0) tabHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40) makeUICorner(tabHolder)

tabHolder.ClipsDescendants = true

local contentHolder = Instance.new("Frame", main) contentHolder.Position = UDim2.new(0, 100, 0, 0) contentHolder.Size = UDim2.new(1, -100, 1, 0) contentHolder.BackgroundTransparency = 1

local function createTab(name) local btn = Instance.new("TextButton", tabHolder) btn.Size = UDim2.new(1, 0, 0, 30) btn.Text = name btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) btn.TextColor3 = Color3.new(1, 1, 1) makeUICorner(btn)

local tabContent = Instance.new("Frame", contentHolder)
tabContent.Size = UDim2.new(1, 0, 1, 0)
tabContent.Visible = false
tabContent.BackgroundTransparency = 1

btn.MouseButton1Click:Connect(function()
	for _, v in pairs(contentHolder:GetChildren()) do
		v.Visible = false
	end
	tabContent.Visible = true
end)

local elements = {}

function elements:CreateLabel(text)
	local lbl = Instance.new("TextLabel", tabContent)
	lbl.Size = UDim2.new(1, -10, 0, 30)
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
end

function elements:CreateButton(text, callback)
	local btn = Instance.new("TextButton", tabContent)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	makeUICorner(btn)
	btn.MouseButton1Click:Connect(callback)
end

function elements:CreateToggle(text, callback)
	local state = false
	local btn = Instance.new("TextButton", tabContent)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Text = text .. ": OFF"
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	makeUICorner(btn)
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

function elements:CreateTextBox(placeholder, callback)
	local box = Instance.new("TextBox", tabContent)
	box.Size = UDim2.new(1, -10, 0, 30)
	box.PlaceholderText = placeholder
	box.Text = ""
	box.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	makeUICorner(box)
	box.FocusLost:Connect(function(enter)
		if enter then callback(box.Text) end
	end)
end

function elements:CreateSlider(text, min, max, default, callback)
	local frame = Instance.new("Frame", tabContent)
	frame.Size = UDim2.new(1, -10, 0, 40)
	frame.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.Text = text .. ": " .. default
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14

	local sliderBar = Instance.new("Frame", frame)
	sliderBar.Size = UDim2.new(1, 0, 0.5, 0)
	sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
	sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	makeUICorner(sliderBar)

	local knob = Instance.new("Frame", sliderBar)
	knob.Size = UDim2.new(0, 10, 1, 0)
	knob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)
	knob.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	makeUICorner(knob)

	local dragging = false
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	sliderBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local scale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
			knob.Position = UDim2.new(scale, 0, 0, 0)
			local val = math.floor((min + (max - min) * scale) + 0.5)
			label.Text = text .. ": " .. val
			callback(val)
		end
	end)
end

function elements:CreateDropdown(title, options, callback)
	local dropdown = Instance.new("TextButton", tabContent)
	dropdown.Size = UDim2.new(1, -10, 0, 30)
	dropdown.Text = title .. ": [Chọn]"
	dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	dropdown.TextColor3 = Color3.new(1, 1, 1)
	dropdown.Font = Enum.Font.Gotham
	dropdown.TextSize = 14
	makeUICorner(dropdown)

	local open = false
	dropdown.MouseButton1Click:Connect(function()
		open = not open
		if open then
			for _, item in ipairs(options) do
				local opt = Instance.new("TextButton", tabContent)
				opt.Size = UDim2.new(1, -20, 0, 25)
				opt.Text = item
				opt.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				opt.TextColor3 = Color3.new(1, 1, 1)
				opt.Font = Enum.Font.Gotham
				opt.TextSize = 13
				makeUICorner(opt)

				opt.MouseButton1Click:Connect(function()
					dropdown.Text = title .. ": " .. item
					callback(item)
					for _, v in pairs(tabContent:GetChildren()) do
						if v:IsA("TextButton") and v ~= dropdown then v:Destroy() end
					end
					open = false
				end)
			end
		else
			for _, v in pairs(tabContent:GetChildren()) do
				if v:IsA("TextButton") and v ~= dropdown then v:Destroy() end
			end
		end
	end)
end

function elements:CreateColorPicker(title, callback)
	local box = Instance.new("TextBox", tabContent)
	box.Size = UDim2.new(1, -10, 0, 30)
	box.PlaceholderText = title .. " (VD: 255,255,255)"
	box.Text = ""
	box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	makeUICorner(box)
	box.FocusLost:Connect(function(enter)
		if enter then
			local parts = string.split(box.Text, ",")
			if #parts == 3 then
				local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
				if r and g and b then
					callback(Color3.fromRGB(r, g, b))
				end
			end
		end
	end)
end

tabContent.Visible = #contentHolder:GetChildren() == 1
return elements

end

function UILib:CreateTab(name) return createTab(name) end

return UILib

