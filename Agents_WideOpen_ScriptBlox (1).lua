-- Agents WideOpen: Purple UI redesign
-- Safe UI-only remake of the attached script.
-- The original file uses executor hooks to suppress crash/contact systems and
-- alter collision behavior in a live game. Those hooks are intentionally not
-- reproduced here. This toggle is a UI/state example, not a working game noclip.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("AgentsWideOpen")
if oldGui then oldGui:Destroy() end

local noclipEnabled = false
local minimized = false
local connections = {}

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpen"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(320, 188)
main.Position = UDim2.new(0.04, 0, 0.38, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 15, 32)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(157, 93, 255)
outline.Thickness = 1.5
outline.Parent = main

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = Color3.fromRGB(74, 35, 130)
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = top

local coverBottom = Instance.new("Frame")
coverBottom.Size = UDim2.new(1, 0, 0, 12)
coverBottom.Position = UDim2.new(0, 0, 1, -12)
coverBottom.BackgroundColor3 = top.BackgroundColor3
coverBottom.BorderSizePixel = 0
coverBottom.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -86, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "AGENTS  //  WIDEOPEN"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 26)
minimize.Position = UDim2.new(1, -36, 0, 8)
minimize.BackgroundColor3 = Color3.fromRGB(103, 56, 171)
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 16
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.AutoButtonColor = true
minimize.Parent = top
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 22)
status.Position = UDim2.fromOffset(14, 54)
status.BackgroundTransparency = 1
status.Text = "FEATURE CONTROL"
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextColor3 = Color3.fromRGB(190, 164, 235)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipToggle"
noclipButton.Size = UDim2.new(1, -28, 0, 42)
noclipButton.Position = UDim2.fromOffset(14, 83)
noclipButton.BackgroundColor3 = Color3.fromRGB(52, 35, 76)
noclipButton.BorderSizePixel = 0
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextSize = 13
noclipButton.TextColor3 = Color3.fromRGB(232, 219, 255)
noclipButton.AutoButtonColor = true
noclipButton.Parent = main
Instance.new("UICorner", noclipButton).CornerRadius = UDim.new(0, 9)

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(121, 79, 179)
buttonStroke.Thickness = 1
buttonStroke.Parent = noclipButton

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -28, 0, 32)
note.Position = UDim2.fromOffset(14, 136)
note.BackgroundTransparency = 1
note.Text = "UI toggle only — connect to your own game's collision system."
note.Font = Enum.Font.Gotham
note.TextSize = 10
note.TextWrapped = true
note.TextColor3 = Color3.fromRGB(167, 153, 190)
note.TextXAlignment = Enum.TextXAlignment.Left
note.Parent = main

local function refresh()
    if noclipEnabled then
        noclipButton.Text = "NOCLIP  •  ON"
        noclipButton.BackgroundColor3 = Color3.fromRGB(104, 54, 170)
        buttonStroke.Color = Color3.fromRGB(194, 151, 255)
    else
        noclipButton.Text = "NOCLIP  •  OFF"
        noclipButton.BackgroundColor3 = Color3.fromRGB(52, 35, 76)
        buttonStroke.Color = Color3.fromRGB(121, 79, 179)
    end
end

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    refresh()
end)

local function setMinimized(value)
    minimized = value
    for _, child in ipairs(main:GetChildren()) do
        if child ~= top and child ~= mainCorner and child ~= outline then
            child.Visible = not minimized
        end
    end
    main.Size = minimized and UDim2.fromOffset(320, 42) or UDim2.fromOffset(320, 188)
    minimize.Text = minimized and "+" or "—"
end

minimize.Activated:Connect(function()
    setMinimized(not minimized)
end)

table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setMinimized(not minimized)
    end
end))

-- Drag the panel by its top bar.
local dragging = false
local dragInput, dragStart, startPos

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))

refresh()
gui.Parent = playerGui

-- Optional cleanup callable in this environment.
_G.AgentsWideOpenCleanup = function()
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    if gui.Parent then gui:Destroy() end
end
