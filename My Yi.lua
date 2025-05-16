local RiceModeUILib = {}

function RiceModeUILib:CreateWindow(title)
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "RiceModeUI"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Name = "MainUI"

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local TitleBar = Instance.new("TextLabel", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Text = title
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextColor3 = Color3.new(1,1,1)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleBar.TextSize = 16
    TitleBar.Name = "TitleBar"

    local TabsHolder = Instance.new("Frame", MainFrame)
    TabsHolder.Size = UDim2.new(0, 100, 1, -30)
    TabsHolder.Position = UDim2.new(0, 0, 0, 30)
    TabsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

    local TabsLayout = Instance.new("UIListLayout", TabsHolder)
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Padding = UDim.new(0, 5)

    local ContentFrame = Instance.new("Frame", MainFrame)
    ContentFrame.Size = UDim2.new(1, -100, 1, -30)
    ContentFrame.Position = UDim2.new(0, 100, 0, 30)
    ContentFrame.BackgroundTransparency = 1

    local UIElements = {}

    function UIElements:CreateTab(tabName)
        local TabButton = Instance.new("TextButton", TabsHolder)
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Text = tabName
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextColor3 = Color3.new(1,1,1)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

        local TabFrame = Instance.new("ScrollingFrame", ContentFrame)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 6
        TabFrame.BackgroundTransparency = 1
        TabFrame.Name = tabName .. "_Frame"

        local ListLayout = Instance.new("UIListLayout", TabFrame)
        ListLayout.Padding = UDim.new(0, 6)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        TabButton.MouseButton1Click:Connect(function()
            for _, v in ipairs(ContentFrame:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            TabFrame.Visible = true
        end)

        local Components = {}

        function Components:Button(text, callback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -12, 0, 30)
            Frame.BackgroundTransparency = 1

            local Btn = Instance.new("TextButton", Frame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = text
            Btn.Font = Enum.Font.Gotham
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.TextSize = 14

            Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(callback)
        end

        function Components:Toggle(text, callback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -12, 0, 30)
            Frame.BackgroundTransparency = 1

            local Toggle = Instance.new("TextButton", Frame)
            Toggle.Size = UDim2.new(1, 0, 1, 0)
            Toggle.Text = text .. ": OFF"
            Toggle.Font = Enum.Font.Gotham
            Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Toggle.TextColor3 = Color3.new(1,1,1)

            Instance.new("UICorner", Toggle)

            local state = false
            Toggle.MouseButton1Click:Connect(function()
                state = not state
                Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
                callback(state)
            end)
        end

        function Components:Slider(text, min, max, callback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -12, 0, 40)
            Frame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", Frame)
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextColor3 = Color3.new(1,1,1)
            Label.BackgroundTransparency = 1

            local SliderBack = Instance.new("Frame", Frame)
            SliderBack.Size = UDim2.new(1, 0, 0, 10)
            SliderBack.Position = UDim2.new(0, 0, 0, 25)
            SliderBack.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

            local Fill = Instance.new("Frame", SliderBack)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Fill.Size = UDim2.new(0, 0, 1, 0)

            local dragging = false
            local function update(input)
                local scale = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(scale, 0, 1, 0)
                local val = math.floor(min + (max - min) * scale)
                callback(val)
            end

            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        function Components:TextBox(text, callback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -12, 0, 30)
            Frame.BackgroundTransparency = 1

            local Box = Instance.new("TextBox", Frame)
            Box.Size = UDim2.new(1, 0, 1, 0)
            Box.PlaceholderText = text
            Box.Font = Enum.Font.Gotham
            Box.TextColor3 = Color3.new(1,1,1)
            Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

            Instance.new("UICorner", Box)
            Box.FocusLost:Connect(function()
                callback(Box.Text)
            end)
        end

        function Components:Dropdown(text, items, callback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -12, 0, 60)
            Frame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", Frame)
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Text = text
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.TextColor3 = Color3.new(1,1,1)

            local Dropdown = Instance.new("TextButton", Frame)
            Dropdown.Size = UDim2.new(1, 0, 0, 30)
            Dropdown.Position = UDim2.new(0, 0, 0, 25)
            Dropdown.Text = "Select"
            Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Dropdown.TextColor3 = Color3.new(1,1,1)
            Dropdown.Font = Enum.Font.Gotham

            Instance.new("UICorner", Dropdown)

            local Menu = Instance.new("Frame", Dropdown)
            Menu.Position = UDim2.new(0, 0, 1, 0)
            Menu.Size = UDim2.new(1, 0, 0, #items * 25)
            Menu.Visible = false
            Menu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

            local Layout = Instance.new("UIListLayout", Menu)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder

            for _, item in ipairs(items) do
                local Option = Instance.new("TextButton", Menu)
                Option.Size = UDim2.new(1, 0, 0, 25)
                Option.Text = item
                Option.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Option.TextColor3 = Color3.new(1,1,1)
                Option.Font = Enum.Font.Gotham
                Option.MouseButton1Click:Connect(function()
                    Dropdown.Text = item
                    Menu.Visible = false
                    callback(item)
                end)
            end

            Dropdown.MouseButton1Click:Connect(function()
                Menu.Visible = not Menu.Visible
            end)
        end

        return Components
    end

    -- Drag support (both PC and mobile)
    local dragging, dragInput, startPos, startInputPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = MainFrame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInputPos
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return UIElements
end

return RiceModeUILib
