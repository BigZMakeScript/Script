local RiceModeUiLib = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- Dragging function for mobile & PC
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startInputPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main UI Creation
function RiceModeUiLib:CreateWindow(title)
    local screenGui = create("ScreenGui", {
        Name = "RiceModeUI",
        Parent = game.CoreGui,
        ResetOnSpawn = false
    })

    local mainFrame = create("Frame", {
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.25, 0, 0.25, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = screenGui,
        Visible = true
    })
    makeDraggable(mainFrame)

    local uiCorner = create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })
    local uiStroke = create("UIStroke", {
        Color = Color3.fromRGB(255, 85, 85),
        Thickness = 2,
        Parent = mainFrame
    })

    local titleLabel = create("TextLabel", {
        Text = title or "RiceMode UI",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = mainFrame
    })

    local tabHolder = create("Frame", {
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = mainFrame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabHolder })

    local tabContent = create("Frame", {
        Size = UDim2.new(1, -120, 1, -30),
        Position = UDim2.new(0, 120, 0, 30),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })

    local tabs = {}

    function tabs:CreateTab(tabName)
        local button = create("TextButton", {
            Text = tabName,
            Size = UDim2.new(1, -10, 0, 40),
            Position = UDim2.new(0, 5, 0, #tabHolder:GetChildren() * 42),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Parent = tabHolder
        })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = button })

        local tabFrame = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 10, 0),
            ScrollBarThickness = 4,
            BackgroundTransparency = 1,
            Parent = tabContent,
            Visible = false,
            Name = tabName .. "_Tab"
        })

        button.MouseButton1Click:Connect(function()
            for _, child in ipairs(tabContent:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            tabFrame.Visible = true
        end)

        local elements = {}

        function elements:CreateButton(text, callback)
            local btn = create("TextButton", {
                Text = text,
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 16,
                Parent = tabFrame
            })
            create("UICorner", { Parent = btn })

            btn.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        function elements:CreateToggle(text, callback)
            local toggle = false
            local btn = create("TextButton", {
                Text = "[ OFF ] " .. text,
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 16,
                Parent = tabFrame
            })
            create("UICorner", { Parent = btn })

            btn.MouseButton1Click:Connect(function()
                toggle = not toggle
                btn.Text = (toggle and "[ ON ] " or "[ OFF ] ") .. text
                callback(toggle)
            end)
        end

        function elements:CreateTextBox(placeholder, callback)
            local box = create("TextBox", {
                PlaceholderText = placeholder,
                Text = "",
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 16,
                Parent = tabFrame
            })
            create("UICorner", { Parent = box })

            box.FocusLost:Connect(function()
                callback(box.Text)
            end)
        end

        function elements:CreateSlider(min, max, default, callback)
            local sliderFrame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                Parent = tabFrame
            })
            create("UICorner", { Parent = sliderFrame })

            local bar = create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 85, 85),
                Parent = sliderFrame
            })

            local label = create("TextLabel", {
                Text = tostring(default),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = sliderFrame
            })

            local dragging = false
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                dragging = false
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging then
                    local rel = input.Position.X - sliderFrame.AbsolutePosition.X
                    local perc = math.clamp(rel / sliderFrame.AbsoluteSize.X, 0, 1)
                    bar.Size = UDim2.new(perc, 0, 1, 0)
                    local val = math.floor(min + (max - min) * perc)
                    label.Text = tostring(val)
                    callback(val)
                end
            end)
        end

        function elements:CreateDropdown(name, list, callback)
            local drop = create("TextButton", {
                Text = name,
                Size = UDim2.new(1, -20, 0, 40),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 16,
                Parent = tabFrame
            })
            create("UICorner", { Parent = drop })

            local open = false
            local options = {}

            drop.MouseButton1Click:Connect(function()
                open = not open
                for _, btn in pairs(options) do
                    btn.Visible = open
                end
            end)

            for i, item in ipairs(list) do
                local opt = create("TextButton", {
                    Text = item,
                    Size = UDim2.new(1, -40, 0, 30),
                    Position = UDim2.new(0, 20, 0, 40 + (i - 1) * 32),
                    BackgroundColor3 = Color3.fromRGB(65, 65, 65),
                    TextColor3 = Color3.new(1, 1, 1),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    Parent = tabFrame,
                    Visible = false
                })
                create("UICorner", { Parent = opt })

                opt.MouseButton1Click:Connect(function()
                    callback(item)
                    drop.Text = name .. ": " .. item
                    open = false
                    for _, btn in pairs(options) do
                        btn.Visible = false
                    end
                end)
                table.insert(options, opt)
            end
        end

        return elements
    end

    -- UI Toggle keybind
    local keyBind = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == keyBind then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    return tabs
end

return RiceModeUiLib
