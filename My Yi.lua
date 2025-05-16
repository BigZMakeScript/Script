-- MyUILibrary.lua
local MyUILibrary = {}

function MyUILibrary:CreateWindow(title, color)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "MyUILibrary"

    local ToggleButton = Instance.new("TextButton", ScreenGui)
    ToggleButton.Text = "⚙️"
    ToggleButton.Size = UDim2.new(0, 30, 0, 30)
    ToggleButton.Position = UDim2.new(0, 10, 0, 10)
    ToggleButton.BackgroundColor3 = color
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.Visible = true
    MainFrame.Active = true
    MainFrame.Draggable = true

    local UIListLayout = Instance.new("UIListLayout", MainFrame)
    UIListLayout.Padding = UDim.new(0, 5)

    ToggleButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    local tab = {}

    function tab:AddButton(text, callback)
        local btn = Instance.new("TextButton", MainFrame)
        btn.Text = text
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.MouseButton1Click:Connect(callback)
    end

    function tab:AddToggle(text, default, callback)
        local toggle = Instance.new("TextButton", MainFrame)
        toggle.Text = text .. ": " .. tostring(default)
        toggle.Size = UDim2.new(1, -10, 0, 30)
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggle.TextColor3 = Color3.new(1, 1, 1)
        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = text .. ": " .. tostring(state)
            callback(state)
        end)
    end

    function tab:AddDropdown(text, list, callback)
        local dropdown = Instance.new("TextButton", MainFrame)
        dropdown.Text = text .. " ▼"
        dropdown.Size = UDim2.new(1, -10, 0, 30)
        dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropdown.TextColor3 = Color3.new(1, 1, 1)

        local open = false
        local items = {}

        dropdown.MouseButton1Click:Connect(function()
            open = not open
            for _, item in ipairs(items) do
                item.Visible = open
            end
        end)

        for _, option in ipairs(list) do
            local opt = Instance.new("TextButton", MainFrame)
            opt.Text = "   " .. option
            opt.Size = UDim2.new(1, -20, 0, 25)
            opt.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            opt.TextColor3 = Color3.new(1, 1, 1)
            opt.Visible = false
            table.insert(items, opt)
            opt.MouseButton1Click:Connect(function()
                dropdown.Text = text .. ": " .. option
                for _, item in ipairs(items) do
                    item.Visible = false
                end
                open = false
                callback(option)
            end)
        end
    end

    function tab:AddSlider(text, min, max, default, callback)
        local frame = Instance.new("Frame", MainFrame)
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0.5, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Text = text .. ": " .. tostring(default)

        local slider = Instance.new("TextButton", frame)
        slider.Size = UDim2.new(1, 0, 0.5, 0)
        slider.Position = UDim2.new(0, 0, 0.5, 0)
        slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        slider.Text = ""

        local dragging = false

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local pct = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pct)
                label.Text = text .. ": " .. val
                callback(val)
            end
        end)
    end

    function tab:AddTextBox(labelText, placeholder, callback)
        local label = Instance.new("TextLabel", MainFrame)
        label.Text = labelText
        label.Size = UDim2.new(1, -10, 0, 20)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)

        local box = Instance.new("TextBox", MainFrame)
        box.PlaceholderText = placeholder
        box.Size = UDim2.new(1, -10, 0, 30)
        box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        box.TextColor3 = Color3.new(1, 1, 1)

        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                callback(box.Text)
            end
        end)
    end

    function MyUILibrary:AddTab(name)
        return tab
    end

    return MyUILibrary:AddTab("Main")
end

return MyUILibrary
