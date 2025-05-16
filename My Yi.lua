--== UI Library Hoàn chỉnh ==-- local UserInputService = game:GetService("UserInputService") local TweenService = game:GetService("TweenService")

local Library = {} local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow(title) local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "CustomUI" ScreenGui.ResetOnSpawn = false ScreenGui.Parent = CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 0, 0.45, 0)
ToggleButton.Text = "Toggle UI"
ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = title or "UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local Tabs = {}

function Tabs:CreateTab(name)
    local Tab = {}

    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 100, 0, 25)
    TabButton.Position = UDim2.new(0, #MainFrame:GetChildren() * 100, 0, 30)
    TabButton.Text = name
    TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 1, -60)
    Container.Position = UDim2.new(0, 5, 0, 60)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Container

    TabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= Container and child.Name ~= "MainFrame" then
                child.Visible = false
            end
        end
        Container.Visible = true
    end)

    function Tab:AddLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.Text = text
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Parent = Container
    end

    function Tab:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 25)
        Button.Text = text
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Parent = Container
        Button.MouseButton1Click:Connect(callback)
    end

    function Tab:AddToggle(text, default, callback)
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(1, -10, 0, 25)
        Toggle.Text = text .. ": " .. tostring(default)
        Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Parent = Container
        local state = default
        Toggle.MouseButton1Click:Connect(function()
            state = not state
            Toggle.Text = text .. ": " .. tostring(state)
            callback(state)
        end)
    end

    function Tab:AddTextBox(text, placeholder, callback)
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -10, 0, 25)
        Box.PlaceholderText = placeholder
        Box.Text = ""
        Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.ClearTextOnFocus = false
        Box.Parent = Container
        Box.FocusLost:Connect(function()
            callback(Box.Text)
        end)
    end

    function Tab:AddSlider(text, min, max, default, callback)
        local Label = Instance.new("TextLabel")
        Label.Text = text .. ": " .. tostring(default)
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.BackgroundTransparency = 1
        Label.Parent = Container

        local Slider = Instance.new("TextButton")
        Slider.Size = UDim2.new(1, -10, 0, 20)
        Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        Slider.Text = ""
        Slider.Parent = Container

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BorderSizePixel = 0
        fill.Parent = Slider

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos)
            Label.Text = text .. ": " .. tostring(val)
            callback(val)
        end

        Slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        Slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    function Tab:AddDropdown(text, items, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 25)
        Button.Text = text .. ": " .. items[1]
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Parent = Container
        local index = 1
        Button.MouseButton1Click:Connect(function()
            index = index % #items + 1
            Button.Text = text .. ": " .. items[index]
            callback(items[index])
        end)
    end

    function Tab:AddColorPicker(text, default, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 25)
        Button.Text = text
        Button.BackgroundColor3 = default
        Button.TextColor3 = Color3.fromRGB(0, 0, 0)
        Button.Parent = Container
        Button.MouseButton1Click:Connect(function()
            callback(Button.BackgroundColor3)
        end)
    end

    return Tab
end

return Tabs

end

return Library
