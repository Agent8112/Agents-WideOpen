-- Agents WideOpen - redesigned UI prototype
-- UI-only: sliders update their displayed values. This file intentionally does not
-- hook game modules, bypass crash/collision systems, or modify live vehicle physics.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("AgentsWideOpenUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpenUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

gui.Parent = PlayerGui

local purple = Color3.fromRGB(157, 91, 255)
local bg = Color3.fromRGB(17, 17, 22)
local panel = Color3.fromRGB(25, 25, 33)
local muted = Color3.fromRGB(157, 157, 174)
local white = Color3.fromRGB(244, 242, 250)

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(390, 300)
main.Position = UDim2.new(0.5, -195, 0.5, -150)
main.BackgroundColor3 = bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local outline = Instance.new("UIStroke", main)
outline.Color = Color3.fromRGB(63, 49, 86)
outline.Thickness = 1.2

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 54)
top.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)
local cover = Instance.new("Frame", top)
cover.Size = UDim2.new(1, 0, 0, 12)
cover.Position = UDim2.new(0, 0, 1, -12)
cover.BackgroundColor3 = top.BackgroundColor3
cover.BorderSizePixel = 0

local accent = Instance.new("Frame", top)
accent.Size = UDim2.new(0, 4, 0, 26)
accent.Position = UDim2.new(0, 15, 0, 14)
accent.BackgroundColor3 = purple
accent.BorderSizePixel = 0
Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel", top)
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(28, 8)
title.Size = UDim2.new(1, -90, 0, 22)
title.Font = Enum.Font.GothamBold
title.Text = "AGENTS  /  WIDEOPEN"
title.TextSize = 14
title.TextColor3 = white
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", top)
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(28, 29)
subtitle.Size = UDim2.new(1, -90, 0, 16)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "PERFORMANCE CONTROLS"
subtitle.TextSize = 9
subtitle.TextColor3 = muted
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local hint = Instance.new("TextLabel", top)
hint.BackgroundTransparency = 1
hint.AnchorPoint = Vector2.new(1, 0)
hint.Position = UDim2.new(1, -14, 0, 18)
hint.Size = UDim2.fromOffset(65, 18)
hint.Font = Enum.Font.GothamMedium
hint.Text = "RSHIFT"
hint.TextSize = 9
hint.TextColor3 = purple
hint.TextXAlignment = Enum.TextXAlignment.Right

local body = Instance.new("Frame", main)
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(16, 66)
body.Size = UDim2.new(1, -32, 1, -82)

local function makeSlider(name, minVal, maxVal, initial, y, suffix)
    local card = Instance.new("Frame", body)
    card.Name = name .. "Card"
    card.Position = UDim2.fromOffset(0, y)
    card.Size = UDim2.new(1, 0, 0, 65)
    card.BackgroundColor3 = panel
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", card)
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 7)
    label.Size = UDim2.new(1, -105, 0, 18)
    label.Font = Enum.Font.GothamSemibold
    label.Text = string.upper(name)
    label.TextSize = 11
    label.TextColor3 = white
    label.TextXAlignment = Enum.TextXAlignment.Left

    local value = Instance.new("TextLabel", card)
    value.Name = "Value"
    value.BackgroundTransparency = 1
    value.AnchorPoint = Vector2.new(1, 0)
    value.Position = UDim2.new(1, -12, 0, 7)
    value.Size = UDim2.fromOffset(85, 18)
    value.Font = Enum.Font.GothamBold
    value.Text = tostring(initial) .. suffix
    value.TextSize = 11
    value.TextColor3 = purple
    value.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", card)
    track.Name = "Track"
    track.Position = UDim2.fromOffset(12, 38)
    track.Size = UDim2.new(1, -24, 0, 5)
    track.BackgroundColor3 = Color3.fromRGB(53, 51, 64)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ratio = (initial - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = purple
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(13, 13)
    knob.BackgroundColor3 = white
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob)
    ks.Color = purple
    ks.Thickness = 1.5

    local current = initial
    local dragging = false
    local function setFromX(x)
        local left = track.AbsolutePosition.X
        local width = track.AbsoluteSize.X
        local r = math.clamp((x - left) / width, 0, 1)
        current = math.floor((minVal + (maxVal - minVal) * r) + 0.5)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        value.Text = tostring(current) .. suffix
        -- Display value only; connect to an authorized vehicle controller in your own game.
    end
    local hit = Instance.new("TextButton", track)
    hit.Name = "SliderInput"
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Size = UDim2.new(1, 16, 1, 20)
    hit.Position = UDim2.fromOffset(-8, -10)
    hit.ZIndex = 4
    hit.MouseButton1Down:Connect(function() dragging = true; setFromX(UserInputService:GetMouseLocation().X) end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(UserInputService:GetMouseLocation().X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return function() return current end
end

local getSpeed = makeSlider("Top Speed", 50, 300, 150, 0, "%")
local getAccel = makeSlider("Acceleration", 0, 200, 75, 73, "%")
local getHandling = makeSlider("Handling", 0, 100, 20, 146, "%")

local footer = Instance.new("TextLabel", main)
footer.BackgroundTransparency = 1
footer.Position = UDim2.new(0, 16, 1, -23)
footer.Size = UDim2.new(1, -32, 0, 14)
footer.Font = Enum.Font.Gotham
footer.Text = "UI PREVIEW  •  SLIDERS ARE NOT CONNECTED TO BIKE PHYSICS"
footer.TextSize = 8
footer.TextColor3 = muted
footer.TextXAlignment = Enum.TextXAlignment.Left

-- Drag window by its header.
local draggingWindow, dragStart, startPos = false, nil, nil
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWindow = false end
end)

local minimized = false
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        minimized = not minimized
        body.Visible = not minimized
        footer.Visible = not minimized
        main.Size = minimized and UDim2.fromOffset(390, 54) or UDim2.fromOffset(390, 300)
    end
end)

-- Keep values available for future integration with a vehicle controller you own.
_G.AgentsWideOpenGetSliderValues = function()
    return { topSpeedPercent = getSpeed(), accelerationPercent = getAccel(), handlingPercent = getHandling() }
end
