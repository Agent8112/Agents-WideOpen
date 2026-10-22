-- Agents WideOpen client UI
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- Intended for a Roblox experience you own/control. Requires the server script
-- AgentsWideOpenServer.lua in ServerScriptService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local tuneEvent = ReplicatedStorage:WaitForChild("AgentsBikeTuneRequest")

local purple = Color3.fromRGB(165, 75, 255)
local deepPurple = Color3.fromRGB(25, 10, 45)
local panelPurple = Color3.fromRGB(43, 20, 70)
local white = Color3.fromRGB(245, 239, 255)
local muted = Color3.fromRGB(190, 170, 215)

local values = {topSpeed = 150, acceleration = 150, handling = 100, noclip = false}

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpen"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(520, 410)
main.Position = UDim2.new(0.5, -260, 0.5, -205)
main.BackgroundColor3 = deepPurple
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local outline = Instance.new("UIStroke", main)
outline.Color = purple
outline.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 48)
title.Position = UDim2.fromOffset(18, 6)
title.BackgroundTransparency = 1
title.Text = "✦ AGENTS WIDEOPEN ✦"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = white
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 32)
close.Position = UDim2.new(1, -44, 0, 12)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextSize = 24
close.TextColor3 = white
close.BackgroundColor3 = panelPurple
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -28, 0, 38)
tabs.Position = UDim2.fromOffset(14, 58)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local function tabButton(text, xScale)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -5, 1, 0)
    b.Position = UDim2.new(xScale, xScale == 0 and 0 or 10, 0, 0)
    b.BackgroundColor3 = panelPurple
    b.TextColor3 = white
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = text
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local performanceTab = tabButton("BIKE PERFORMANCE", 0)
local visualTab = tabButton("VISUALS", 0.5)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -28, 1, -120)
content.Position = UDim2.fromOffset(14, 106)
content.BackgroundColor3 = panelPurple
content.BorderSizePixel = 0
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -28, 0, 34)
note.Position = UDim2.new(0, 14, 1, -42)
note.BackgroundTransparency = 1
note.TextColor3 = muted
note.TextSize = 11
note.Font = Enum.Font.Gotham
note.Text = "Right Shift: minimize/restore • Drag title bar to move"
note.Parent = main

local minimized = false
local expandedSize = main.Size
local function setMinimized(state)
    minimized = state
    main.Size = minimized and UDim2.fromOffset(520, 58) or expandedSize
    tabs.Visible = not minimized
    content.Visible = not minimized
    note.Visible = not minimized
    close.Text = minimized and "+" or "×"
end
close.Activated:Connect(function() setMinimized(not minimized) end)

-- Drag window with mouse or touch from title bar.
local dragging, dragStart, startPosition = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setMinimized(not minimized)
    end
end)

local function sendTune()
    tuneEvent:FireServer({
        topSpeed = values.topSpeed,
        acceleration = values.acceleration,
        handling = values.handling,
        noclip = values.noclip
    })
end

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do child:Destroy() end
end

local function makeSlider(labelText, key, minValue, maxValue, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 24)
    label.Position = UDim2.fromOffset(15, y)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = white
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Text = labelText .. ": " .. values[key] .. "%"
    label.Parent = content

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -30, 0, 12)
    bar.Position = UDim2.fromOffset(15, y + 31)
    bar.BackgroundColor3 = Color3.fromRGB(20, 8, 34)
    bar.BorderSizePixel = 0
    bar.Parent = content
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((values[key] - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = purple
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((values[key] - minValue) / (maxValue - minValue), 0, 0.5, 0)
    knob.BackgroundColor3 = white
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = purple
    knobStroke.Thickness = 2

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 18, 0, 30)
    hitbox.Position = UDim2.new(0, -9, 0.5, -15)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.ZIndex = 4
    hitbox.Parent = bar

    local draggingSlider = false
    local function update(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor((minValue + ratio * (maxValue - minValue)) / 5 + 0.5) * 5
        values[key] = math.clamp(v, minValue, maxValue)
        local r = (values[key] - minValue) / (maxValue - minValue)
        label.Text = labelText .. ": " .. values[key] .. "%"
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        sendTune()
    end
    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

local function renderPerformance()
    clearContent()
    makeSlider("Top speed", "topSpeed", 50, 300, 18)
    makeSlider("Acceleration", "acceleration", 0, 200, 94)
    makeSlider("Handling", "handling", 0, 100, 170)

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, -30, 0, 42)
    toggle.Position = UDim2.fromOffset(15, 250)
    toggle.BackgroundColor3 = values.noclip and purple or deepPurple
    toggle.TextColor3 = white
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.Text = "VEHICLE NOCLIP: " .. (values.noclip and "ON" or "OFF")
    toggle.Parent = content
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
    toggle.Activated:Connect(function()
        values.noclip = not values.noclip
        toggle.Text = "VEHICLE NOCLIP: " .. (values.noclip and "ON" or "OFF")
        toggle.BackgroundColor3 = values.noclip and purple or deepPurple
        sendTune()
    end)
    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -30, 0, 30)
    hint.Position = UDim2.fromOffset(15, 300)
    hint.BackgroundTransparency = 1
    hint.TextWrapped = true
    hint.TextColor3 = muted
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 11
    hint.Text = "Requires the server vehicle controller to apply tuning."
    hint.Parent = content
end

local function renderVisuals()
    clearContent()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 55)
    label.Position = UDim2.fromOffset(15, 15)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.TextColor3 = white
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Text = "Purple star theme enabled ✦"
    label.Parent = content
    local shadow = Instance.new("TextButton")
    shadow.Size = UDim2.new(1, -30, 0, 42)
    shadow.Position = UDim2.fromOffset(15, 82)
    shadow.BackgroundColor3 = deepPurple
    shadow.TextColor3 = white
    shadow.Font = Enum.Font.GothamBold
    shadow.TextSize = 14
    shadow.Text = "GLOBAL SHADOWS: " .. (Lighting.GlobalShadows and "ON" or "OFF")
    shadow.Parent = content
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 8)
    shadow.Activated:Connect(function()
        Lighting.GlobalShadows = not Lighting.GlobalShadows
        shadow.Text = "GLOBAL SHADOWS: " .. (Lighting.GlobalShadows and "ON" or "OFF")
    end)
end

performanceTab.Activated:Connect(renderPerformance)
visualTab.Activated:Connect(renderVisuals)
renderPerformance()
