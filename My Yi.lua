-- Rice Mode UI Library
-- Full-featured and mobile-friendly UI system

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(50, 50, 50),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(200, 200, 200),
    },
    Aqua = {
        Background = Color3.fromRGB(30, 40, 50),
        Accent = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(60, 70, 80),
    },
    Blood = {
        Background = Color3.fromRGB(40, 0, 0),
        Accent = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(80, 0, 0),
    }
}

local function SaveConfig(name, data)
    if isfile and writefile then
        writefile(name.."_config.json", HttpService:JSONEncode(data))
    end
end

local function LoadConfig(name)
    if isfile and readfile and isfile(name.."_config.json") then
        return HttpService:JSONDecode(readfile(name.."_config.json"))
    end
    return {}
end

local RiceMode = {}
function RiceMode:CreateWindow(cfg)
    cfg = cfg or {}
    local Theme = Themes[cfg.Theme or "Dark"] or Themes.Dark
    local SaveEnabled = cfg.SaveConfig
    local SaveData = LoadConfig(cfg.Name or "RiceMode")

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "RiceModeUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Holder = Instance.new("Frame", ScreenGui)
    Holder.Size = UDim2.new(0, 500, 0, 350)
    Holder.Position = UDim2.new(0.5, -250, 0.5, -175)
    Holder.BackgroundColor3 = Theme.Background
    Holder.BorderColor3 = Theme.Border
    Holder.BorderSizePixel = 2
    Holder.Name = "Holder"

    local UICorner = Instance.new("UICorner", Holder)
    UICorner.CornerRadius = UDim.new(0, 10)

    local DragToggle = false
    local DragInput, MousePos, FramePos

    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            DragToggle = true
            MousePos = input.Position
            FramePos = Holder.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    DragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if DragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - MousePos
            Holder.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + delta.X, FramePos.Y.Scale, FramePos.Y.Offset + delta.Y)
        end
    end)

    local Tabs = {}

    function Tabs:CreateTab(name)
        local tab = Instance.new("Frame", Holder)
        tab.Size = UDim2.new(1, -20, 1, -60)
        tab.Position = UDim2.new(0, 10, 0, 50)
        tab.BackgroundTransparency = 1
        tab.Name = name:gsub(" ", "")

        local layout = Instance.new("UIListLayout", tab)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local elements = {}

        function elements:CreateButton(text, callback)
            local btn = Instance.new("TextButton", tab)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = text
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.MouseButton1Click:Connect(callback)
        end

        function elements:CreateToggle(text, default, callback)
            local toggle = Instance.new("TextButton", tab)
            toggle.Size = UDim2.new(1, 0, 0, 30)
            toggle.Text = text
            toggle.BackgroundColor3 = default and Theme.Accent or Theme.Border
            toggle.TextColor3 = Theme.Text
            toggle.Font = Enum.Font.Gotham
            toggle.TextSize = 14
            toggle.MouseButton1Click:Connect(function()
                default = not default
                toggle.BackgroundColor3 = default and Theme.Accent or Theme.Border
                callback(default)
                if SaveEnabled then SaveData[text] = default SaveConfig(cfg.Name, SaveData) end
            end)
        end

        function elements:CreateSlider(text, min, max, default, callback)
            local frame = Instance.new("Frame", tab)
            frame.Size = UDim2.new(1, 0, 0, 40)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Text = text .. ": " .. tostring(default)
            label.TextColor3 = Theme.Text
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14

            local slider = Instance.new("TextButton", frame)
            slider.Size = UDim2.new(1, 0, 0, 15)
            slider.Position = UDim2.new(0, 0, 0, 25)
            slider.BackgroundColor3 = Theme.Border
            slider.Text = ""

            local fill = Instance.new("Frame", slider)
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local conn
                    conn = UserInputService.InputChanged:Connect(function(move)
                        if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                            local pos = move.Position.X - slider.AbsolutePosition.X
                            local pct = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(pct, 0, 1, 0)
                            local val = math.floor(min + (max - min) * pct)
                            label.Text = text .. ": " .. tostring(val)
                            callback(val)
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

        function elements:CreateTextBox(placeholder, callback)
            local box = Instance.new("TextBox", tab)
            box.Size = UDim2.new(1, 0, 0, 30)
            box.PlaceholderText = placeholder
            box.Text = ""
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.BackgroundColor3 = Theme.Border
            box.TextColor3 = Theme.Text
            box.FocusLost:Connect(function()
                callback(box.Text)
                if SaveEnabled then SaveData[placeholder] = box.Text SaveConfig(cfg.Name, SaveData) end
            end)
        end

        function elements:CreateDropdown(text, options, callback)
            local btn = Instance.new("TextButton", tab)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = text
            btn.BackgroundColor3 = Theme.Border
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                for _, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton", tab)
                    optBtn.Size = UDim2.new(1, 0, 0, 25)
                    optBtn.Text = "- " .. opt
                    optBtn.BackgroundColor3 = Theme.Accent
                    optBtn.TextColor3 = Theme.Text
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 13
                    optBtn.MouseButton1Click:Connect(function()
                        callback(opt)
                        for _, child in pairs(tab:GetChildren()) do
                            if child:IsA("TextButton") and child.Text:match("%- ") then child:Destroy() end
                        end
                    end)
                end
            end)
        end

        return elements
    end

    return Tabs
end

return RiceMode
-- Rice Mode UI Library
-- Full-featured and mobile-friendly UI system

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(50, 50, 50),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(200, 200, 200),
    },
    Aqua = {
        Background = Color3.fromRGB(30, 40, 50),
        Accent = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(60, 70, 80),
    },
    Blood = {
        Background = Color3.fromRGB(40, 0, 0),
        Accent = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(80, 0, 0),
    }
}

local function SaveConfig(name, data)
    if isfile and writefile then
        writefile(name.."_config.json", HttpService:JSONEncode(data))
    end
end

local function LoadConfig(name)
    if isfile and readfile and isfile(name.."_config.json") then
        return HttpService:JSONDecode(readfile(name.."_config.json"))
    end
    return {}
end

local RiceMode = {}
function RiceMode:CreateWindow(cfg)
    cfg = cfg or {}
    local Theme = Themes[cfg.Theme or "Dark"] or Themes.Dark
    local SaveEnabled = cfg.SaveConfig
    local SaveData = LoadConfig(cfg.Name or "RiceMode")

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "RiceModeUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Holder = Instance.new("Frame", ScreenGui)
    Holder.Size = UDim2.new(0, 500, 0, 350)
    Holder.Position = UDim2.new(0.5, -250, 0.5, -175)
    Holder.BackgroundColor3 = Theme.Background
    Holder.BorderColor3 = Theme.Border
    Holder.BorderSizePixel = 2
    Holder.Name = "Holder"

    local UICorner = Instance.new("UICorner", Holder)
    UICorner.CornerRadius = UDim.new(0, 10)

    local DragToggle = false
    local DragInput, MousePos, FramePos

    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            DragToggle = true
            MousePos = input.Position
            FramePos = Holder.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    DragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if DragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - MousePos
            Holder.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + delta.X, FramePos.Y.Scale, FramePos.Y.Offset + delta.Y)
        end
    end)

    local Tabs = {}

    function Tabs:CreateTab(name)
        local tab = Instance.new("Frame", Holder)
        tab.Size = UDim2.new(1, -20, 1, -60)
        tab.Position = UDim2.new(0, 10, 0, 50)
        tab.BackgroundTransparency = 1
        tab.Name = name:gsub(" ", "")

        local layout = Instance.new("UIListLayout", tab)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local elements = {}

        function elements:CreateButton(text, callback)
            local btn = Instance.new("TextButton", tab)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = text
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.MouseButton1Click:Connect(callback)
        end

        function elements:CreateToggle(text, default, callback)
            local toggle = Instance.new("TextButton", tab)
            toggle.Size = UDim2.new(1, 0, 0, 30)
            toggle.Text = text
            toggle.BackgroundColor3 = default and Theme.Accent or Theme.Border
            toggle.TextColor3 = Theme.Text
            toggle.Font = Enum.Font.Gotham
            toggle.TextSize = 14
            toggle.MouseButton1Click:Connect(function()
                default = not default
                toggle.BackgroundColor3 = default and Theme.Accent or Theme.Border
                callback(default)
                if SaveEnabled then SaveData[text] = default SaveConfig(cfg.Name, SaveData) end
            end)
        end

        function elements:CreateSlider(text, min, max, default, callback)
            local frame = Instance.new("Frame", tab)
            frame.Size = UDim2.new(1, 0, 0, 40)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Text = text .. ": " .. tostring(default)
            label.TextColor3 = Theme.Text
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14

            local slider = Instance.new("TextButton", frame)
            slider.Size = UDim2.new(1, 0, 0, 15)
            slider.Position = UDim2.new(0, 0, 0, 25)
            slider.BackgroundColor3 = Theme.Border
            slider.Text = ""

            local fill = Instance.new("Frame", slider)
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local conn
                    conn = UserInputService.InputChanged:Connect(function(move)
                        if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                            local pos = move.Position.X - slider.AbsolutePosition.X
                            local pct = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(pct, 0, 1, 0)
                            local val = math.floor(min + (max - min) * pct)
                            label.Text = text .. ": " .. tostring(val)
                            callback(val)
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

        function elements:CreateTextBox(placeholder, callback)
            local box = Instance.new("TextBox", tab)
            box.Size = UDim2.new(1, 0, 0, 30)
            box.PlaceholderText = placeholder
            box.Text = ""
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.BackgroundColor3 = Theme.Border
            box.TextColor3 = Theme.Text
            box.FocusLost:Connect(function()
                callback(box.Text)
                if SaveEnabled then SaveData[placeholder] = box.Text SaveConfig(cfg.Name, SaveData) end
            end)
        end

        function elements:CreateDropdown(text, options, callback)
            local btn = Instance.new("TextButton", tab)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = text
            btn.BackgroundColor3 = Theme.Border
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                for _, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton", tab)
                    optBtn.Size = UDim2.new(1, 0, 0, 25)
                    optBtn.Text = "- " .. opt
                    optBtn.BackgroundColor3 = Theme.Accent
                    optBtn.TextColor3 = Theme.Text
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 13
                    optBtn.MouseButton1Click:Connect(function()
                        callback(opt)
                        for _, child in pairs(tab:GetChildren()) do
                            if child:IsA("TextButton") and child.Text:match("%- ") then child:Destroy() end
                        end
                    end)
                end
            end)
        end

        return elements
    end

    return Tabs
end

return RiceMode
