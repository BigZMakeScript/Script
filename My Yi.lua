-- Rice Mode UI Library local RiceUI = {}

-- Configurable Theme RiceUI.Theme = { Primary = Color3.fromRGB(85, 170, 255), Secondary = Color3.fromRGB(40, 40, 40), Background = Color3.fromRGB(25, 25, 25), TextColor = Color3.fromRGB(255, 255, 255) }

-- Services local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local UserInputService = game:GetService("UserInputService") local TweenService = game:GetService("TweenService")

-- UI Creation Helper local function create(class, props) local inst = Instance.new(class) for i, v in pairs(props) do inst[i] = v end return inst end

-- Main UI Container function RiceUI:CreateWindow(title) local ScreenGui = create("ScreenGui", { Name = "RiceModeUI", ResetOnSpawn = false, Parent = game:GetService("CoreGui") })

local ToggleButton = create("TextButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 100, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    Text = "Toggle UI",
    BackgroundColor3 = RiceUI.Theme.Primary,
    TextColor3 = RiceUI.Theme.TextColor
})

local MainFrame = create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 450, 0, 300),
    Position = UDim2.new(0.5, -225, 0.5, -150),
    BackgroundColor3 = RiceUI.Theme.Background,
    Visible = true
})

create("UICorner", {Parent = MainFrame})

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TabsHolder = create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 100, 1, 0),
    BackgroundColor3 = RiceUI.Theme.Secondary
})

create("UICorner", {Parent = TabsHolder})

local Pages = {}
local Tabs = {}

function RiceUI:CreateTab(tabName)
    local TabButton = create("TextButton", {
        Parent = TabsHolder,
        Size = UDim2.new(1, 0, 0, 30),
        Text = tabName,
        BackgroundColor3 = RiceUI.Theme.Primary,
        TextColor3 = RiceUI.Theme.TextColor
    })

    local Page = create("ScrollingFrame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -110, 1, -10),
        Position = UDim2.new(0, 110, 0, 5),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 2, 0)
    })

    local UIListLayout = create("UIListLayout", {
        Parent = Page,
        Padding = UDim.new(0, 6)
    })

    TabButton.MouseButton1Click:Connect(function()
        for _, pg in pairs(Pages) do pg.Visible = false end
        Page.Visible = true
    end)

    table.insert(Pages, Page)
    Tabs[tabName] = Page

    local tabAPI = {}

    function tabAPI:Button(text, callback)
        local btn = create("TextButton", {
            Parent = Page,
            Size = UDim2.new(1, -10, 0, 30),
            Text = text,
            BackgroundColor3 = RiceUI.Theme.Primary,
            TextColor3 = RiceUI.Theme.TextColor
        })
        btn.MouseButton1Click:Connect(callback)
    end

    function tabAPI:Toggle(text, callback)
        local state = false
        local toggle = create("TextButton", {
            Parent = Page,
            Size = UDim2.new(1, -10, 0, 30),
            Text = text .. ": OFF",
            BackgroundColor3 = RiceUI.Theme.Secondary,
            TextColor3 = RiceUI.Theme.TextColor
        })
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = text .. (state and ": ON" or ": OFF")
            callback(state)
        end)
    end

    function tabAPI:Slider(text, min, max, default, callback)
        local sliderFrame = create("Frame", {
            Parent = Page,
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = RiceUI.Theme.Secondary
        })
        create("UICorner", {Parent = sliderFrame})

        local label = create("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(1, 0, 0, 20),
            Text = text .. ": " .. tostring(default),
            BackgroundTransparency = 1,
            TextColor3 = RiceUI.Theme.TextColor
        })

        local bar = create("Frame", {
            Parent = sliderFrame,
            Size = UDim2.new(1, -20, 0, 10),
            Position = UDim2.new(0, 10, 0, 25),
            BackgroundColor3 = RiceUI.Theme.Primary
        })

        create("UICorner", {Parent = bar})

        local dragging = false
        local current = default

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            dragging = false
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.Position then
                local rel = input.Position.X - bar.AbsolutePosition.X
                local percent = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
                current = math.floor((max - min) * percent + min)
                label.Text = text .. ": " .. tostring(current)
                callback(current)
            end
        end)
    end

    function tabAPI:Textbox(text, callback)
        local box = create("TextBox", {
            Parent = Page,
            Size = UDim2.new(1, -10, 0, 30),
            Text = text,
            BackgroundColor3 = RiceUI.Theme.Secondary,
            TextColor3 = RiceUI.Theme.TextColor
        })
        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
    end

    function tabAPI:Dropdown(text, options, callback)
        local selected = options[1]
        local dropdown = create("TextButton", {
            Parent = Page,
            Size = UDim2.new(1, -10, 0, 30),
            Text = text .. ": " .. selected,
            BackgroundColor3 = RiceUI.Theme.Secondary,
            TextColor3 = RiceUI.Theme.TextColor
        })

        dropdown.MouseButton1Click:Connect(function()
            local menu = create("Frame", {
                Parent = dropdown,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, #options * 30),
                BackgroundColor3 = RiceUI.Theme.Secondary
            })
            for _, opt in pairs(options) do
                local optBtn = create("TextButton", {
                    Parent = menu,
                    Size = UDim2.new(1, 0, 0, 30),
                    Text = opt,
                    BackgroundColor3 = RiceUI.Theme.Secondary,
                    TextColor3 = RiceUI.Theme.TextColor
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    dropdown.Text = text .. ": " .. selected
                    menu:Destroy()
                    callback(selected)
                end)
            end
        end)
    end

    return tabAPI
end

return RiceUI

end

return RiceUI

