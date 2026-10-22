-- Agents WideOpen — Performance UI
-- Visual slider interface matching the supplied reference image.
-- Sliders update their displayed percentages only; they do not modify game physics.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("AgentsWideOpenPerformance")
if existing then existing:Destroy() end

local purple = Color3.fromRGB(166, 65, 255)
local white = Color3.fromRGB(245, 245, 250)
local muted = Color3.fromRGB(190, 190, 200)
local trackColor = Color3.fromRGB(22, 22, 24)
local borderColor = Color3.fromRGB(48, 48, 52)

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpenPerformance"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "PerformancePanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.Size = UDim2.new(0, 640, 0, 418)
panel.BackgroundColor3 = Color3.fromRGB(5, 5, 6)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 17)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = borderColor
panelStroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 13)
title.Size = UDim2.new(1, -32, 0, 26)
title.Font = Enum.Font.GothamBold
title.Text = "◉  Agents WideOpen — Performance"
title.TextSize = 17
title.TextColor3 = white
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

-- Drag the window by its title.
local dragging, dragStart, panelStart = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        panelStart = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + delta.X, panelStart.Y.Scale, panelStart.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local function makeSlider(labelText, y, minVal, maxVal, initialVal, leftText, midText, rightText)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(16, y)
    label.Size = UDim2.new(1, -32, 0, 23)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextSize = 14
    label.TextColor3 = white
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = panel

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -16, 0, y)
    valueLabel.Size = UDim2.fromOffset(80, 23)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(initialVal) .. "%"
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = purple
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = panel

    local bar = Instance.new("Frame")
    bar.Name = labelText:gsub("%s", "") .. "Track"
    bar.Position = UDim2.fromOffset(16, y + 28)
    bar.Size = UDim2.new(1, -32, 0, 24)
    bar.BackgroundColor3 = trackColor
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = false
    bar.Parent = panel
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local ratio = (initialVal - minVal) / (maxVal - minVal)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(20, 20)
    knob.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local hit = Instance.new("TextButton")
    hit.Name = "SliderHitbox"
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Size = UDim2.new(1, 0, 1, 12)
    hit.Position = UDim2.new(0, 0, 0, -6)
    hit.ZIndex = 4
    hit.Parent = bar

    local left = Instance.new("TextLabel")
    left.BackgroundTransparency = 1
    left.Position = UDim2.new(0, 0, 1, 7)
    left.Size = UDim2.new(0.33, 0, 0, 16)
    left.Font = Enum.Font.Gotham
    left.Text = leftText
    left.TextSize = 11
    left.TextColor3 = muted
    left.TextXAlignment = Enum.TextXAlignment.Left
    left.Parent = bar

    local mid = Instance.new("TextLabel")
    mid.BackgroundTransparency = 1
    mid.AnchorPoint = Vector2.new(0.5, 0)
    mid.Position = UDim2.new(0.5, 0, 1, 7)
    mid.Size = UDim2.new(0.34, 0, 0, 16)
    mid.Font = Enum.Font.Gotham
    mid.Text = midText
    mid.TextSize = 11
    mid.TextColor3 = muted
    mid.TextXAlignment = Enum.TextXAlignment.Center
    mid.Parent = bar

    local right = Instance.new("TextLabel")
    right.BackgroundTransparency = 1
    right.AnchorPoint = Vector2.new(1, 0)
    right.Position = UDim2.new(1, 0, 1, 7)
    right.Size = UDim2.new(0.33, 0, 0, 16)
    right.Font = Enum.Font.Gotham
    right.Text = rightText
    right.TextSize = 11
    right.TextColor3 = muted
    right.TextXAlignment = Enum.TextXAlignment.Right
    right.Parent = bar

    local active = false
    local function update(x)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local r = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
        local v = math.floor((minVal + r * (maxVal - minVal)) / 5 + 0.5) * 5
        v = math.clamp(v, minVal, maxVal)
        local newR = (v - minVal) / (maxVal - minVal)
        valueLabel.Text = tostring(v) .. "%"
        knob.Position = UDim2.new(newR, 0, 0.5, 0)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
end

makeSlider("Top speed", 63, 50, 300, 150, "50%", "150%", "300%")
makeSlider("Acceleration", 163, 0, 200, 75, "0%", "100%", "200%")
makeSlider("Handling", 263, 0, 100, 20, "0%", "50%", "100%")

local note = Instance.new("TextLabel")
note.Name = "PreviewNote"
note.BackgroundTransparency = 1
note.Position = UDim2.fromOffset(16, 361)
note.Size = UDim2.new(1, -32, 0, 44)
note.Font = Enum.Font.Gotham
note.Text = "Preview only — these sliders demonstrate the intended menu and do not change the bike in Roblox."
note.TextSize = 12
note.TextColor3 = white
note.TextWrapped = true
note.TextXAlignment = Enum.TextXAlignment.Left
note.TextYAlignment = Enum.TextYAlignment.Top
note.Parent = panel

-- Right Shift hides/shows the panel.
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then panel.Visible = not panel.Visible end
end)
