-- Agents WideOpen - redesigned menu shell
-- This file provides a redesigned UI and a Noclip toggle state.
-- It intentionally does not include executor hooks or bypass WideOpen's collision/crash systems.
-- For a game you own, connect onNoclipChanged to your own authorized vehicle/collision controller.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("AgentsWideOpenMenu")
if old then old:Destroy() end

local noclipEnabled = false
local minimized = false
local function onNoclipChanged(enabled)
    -- Connect this callback to your own game's collision controller in Roblox Studio.
    -- No live-game bypass is performed by this menu shell.
end

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpenMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(330, 220)
panel.Position = UDim2.new(0.5, -165, 0.5, -110)
panel.BackgroundColor3 = Color3.fromRGB(17, 17, 24)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local outline = Instance.new("UIStroke", panel)
outline.Color = Color3.fromRGB(135, 75, 255)
outline.Thickness = 1.5

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(29, 21, 44)
header.BorderSizePixel = 0
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 12)
headerCover.Position = UDim2.new(0, 0, 1, -12)
headerCover.BackgroundColor3 = header.BackgroundColor3
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(15, 0)
title.Size = UDim2.new(1, -70, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "AGENTS  /  WIDEOPEN"
title.TextColor3 = Color3.fromRGB(235, 225, 255)
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(30, 28)
minimize.Position = UDim2.new(1, -40, 0, 10)
minimize.BackgroundColor3 = Color3.fromRGB(73, 45, 110)
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(16, 59)
subtitle.Size = UDim2.new(1, -32, 0, 22)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "MOVEMENT OPTIONS"
subtitle.TextColor3 = Color3.fromRGB(155, 145, 175)
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Name = "NoclipToggle"
toggle.Position = UDim2.fromOffset(16, 91)
toggle.Size = UDim2.new(1, -32, 0, 52)
toggle.BackgroundColor3 = Color3.fromRGB(35, 31, 45)
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.TextColor3 = Color3.fromRGB(230, 225, 240)
toggle.Parent = panel
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 9)
local toggleStroke = Instance.new("UIStroke", toggle)
toggleStroke.Color = Color3.fromRGB(90, 78, 112)
toggleStroke.Thickness = 1

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(16, 154)
status.Size = UDim2.new(1, -32, 0, 34)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(150, 145, 165)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Toggle state only. Connect to your own Studio game's collision controller."
status.Parent = panel

local function refresh()
    if noclipEnabled then
        toggle.Text = "NOCLIP  •  ON"
        toggle.BackgroundColor3 = Color3.fromRGB(52, 35, 78)
        toggle.TextColor3 = Color3.fromRGB(210, 180, 255)
        toggleStroke.Color = Color3.fromRGB(155, 95, 255)
    else
        toggle.Text = "NOCLIP  •  OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(35, 31, 45)
        toggle.TextColor3 = Color3.fromRGB(230, 225, 240)
        toggleStroke.Color = Color3.fromRGB(90, 78, 112)
    end
end
refresh()

toggle.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    refresh()
    onNoclipChanged(noclipEnabled)
end)

minimize.Activated:Connect(function()
    minimized = not minimized
    subtitle.Visible = not minimized
    toggle.Visible = not minimized
    status.Visible = not minimized
    panel.Size = minimized and UDim2.fromOffset(330, 48) or UDim2.fromOffset(330, 220)
    minimize.Text = minimized and "+" or "—"
end)

-- Right Shift minimizes/restores the panel.
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        minimized = not minimized
        subtitle.Visible = not minimized
        toggle.Visible = not minimized
        status.Visible = not minimized
        panel.Size = minimized and UDim2.fromOffset(330, 48) or UDim2.fromOffset(330, 220)
        minimize.Text = minimized and "+" or "—"
    end
end)

-- Drag the window by its header.
local dragging = false
local dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
