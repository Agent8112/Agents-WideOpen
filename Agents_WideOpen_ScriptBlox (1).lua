--[[
    Agents WideOpen - functional UI prototype
    Purple galaxy theme; designed for Roblox Studio / authorized test places.

    Working:
      * Draggable GUI, tabs, close button
      * Star field toggle
      * FPS counter
      * Local global-shadows preview toggle
      * UI-only noclip status indicator

    Not implemented:
      * WideOpen-specific crash/collision bypasses
      * Private garage APIs or game-specific motorcycle upgrades
      * Executor-only hooks
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
if not player then
    warn("Agents WideOpen must run on the client.")
    return
end
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("AgentsWideOpen")
if oldGui then oldGui:Destroy() end

local C = {
    purple = Color3.fromRGB(176, 85, 255),
    bright = Color3.fromRGB(220, 165, 255),
    dark = Color3.fromRGB(16, 10, 29),
    panel = Color3.fromRGB(29, 18, 48),
    muted = Color3.fromRGB(178, 154, 205),
    white = Color3.fromRGB(250, 245, 255),
    active = Color3.fromRGB(83, 45, 120),
}

local connections = {}
local destroyed = false
local fpsEnabled = false
local fpsLabel
local fpsFrames, fpsElapsed = 0, 0
local graphicsEnabled = false
local originalShadows = Lighting.GlobalShadows
local starsVisible = true
local noclipStatus = false
local currentPage = "Home"

local function track(connection)
    table.insert(connections, connection)
    return connection
end

local function new(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius or 9)}, obj)
end

local function stroke(obj, color, transparency, thickness)
    new("UIStroke", {
        Color = color or C.purple,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    }, obj)
end

local function text(parent, value, size, pos, fontSize, color, font, xAlign)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = value,
        Size = size,
        Position = pos,
        TextSize = fontSize or 13,
        TextColor3 = color or C.white,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = xAlign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local gui = new("ScreenGui", {
    Name = "AgentsWideOpen",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = new("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(660, 450),
    Position = UDim2.new(0.5, -330, 0.5, -225),
    BackgroundColor3 = C.dark,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(main, 14)
stroke(main, C.purple, 0.08, 2)

local starField = new("Frame", {
    Name = "StarField",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 0,
}, main)

local rng = Random.new(8112)
for i = 1, 64 do
    local s = new("TextLabel", {
        Name = "Star" .. i,
        BackgroundTransparency = 1,
        Text = i % 4 == 0 and "✦" or "·",
        TextColor3 = C.bright,
        TextTransparency = rng:NextNumber(0.2, 0.72),
        TextSize = rng:NextInteger(9, 19),
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(rng:NextNumber(0, 0.96), 0, rng:NextNumber(0, 0.95), 0),
        ZIndex = 0,
    }, starField)
end

local header = new("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = Color3.fromRGB(24, 13, 42),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, main)

text(header, "✦  AGENTS WIDEOPEN", UDim2.new(1, -90, 0, 34),
    UDim2.fromOffset(18, 7), 22, C.bright, Enum.Font.GothamBlack)
text(header, "MOTORCYCLE UTILITIES  •  PURPLE GALAXY", UDim2.new(1, -100, 0, 20),
    UDim2.fromOffset(20, 43), 10, C.muted)

local closeButton = new("TextButton", {
    Name = "Close",
    Size = UDim2.fromOffset(36, 32),
    Position = UDim2.new(1, -48, 0, 15),
    BackgroundColor3 = C.panel,
    Text = "×",
    TextColor3 = C.white,
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    ZIndex = 3,
}, header)
corner(closeButton, 8)
stroke(closeButton, C.purple, 0.25, 1)

-- Drag handling supports mouse and touch.
local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
track(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        track(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end))
    end
end))
track(header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))

local sidebar = new("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(12, 88),
    Size = UDim2.new(0, 160, 1, -100),
    BackgroundColor3 = Color3.fromRGB(22, 14, 36),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ZIndex = 1,
}, main)
corner(sidebar, 10)
stroke(sidebar, C.purple, 0.72, 1)
new("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9),
}, sidebar)
new("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local body = new("Frame", {
    Name = "PageBody",
    Position = UDim2.fromOffset(184, 88),
    Size = UDim2.new(1, -196, 1, -100),
    BackgroundTransparency = 1,
    ZIndex = 1,
}, main)
local pageTitle = text(body, "Home", UDim2.new(1, 0, 0, 30),
    UDim2.fromOffset(2, 0), 19, C.bright, Enum.Font.GothamBold)

local content = new("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.fromOffset(0, 36),
    Size = UDim2.new(1, 0, 1, -36),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.purple,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 1,
}, body)
new("UIPadding", {
    PaddingBottom = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 6),
}, content)
new("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function card(titleText, description, height)
    local f = new("Frame", {
        BackgroundColor3 = C.panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -4, 0, height or (description and 84 or 60)),
        ZIndex = 2,
    }, content)
    corner(f, 9)
    stroke(f, C.purple, 0.68, 1)
    text(f, titleText, UDim2.new(1, -22, 0, 25),
        UDim2.fromOffset(12, 6), 14, C.bright, Enum.Font.GothamBold).ZIndex = 3
    if description then
        text(f, description, UDim2.new(1, -22, 0, 38),
            UDim2.fromOffset(12, 32), 11, C.muted).ZIndex = 3
    end
    return f
end

local function button(parent, caption, callback)
    local b = new("TextButton", {
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.new(0, 10, 1, -40),
        BackgroundColor3 = Color3.fromRGB(52, 30, 78),
        BorderSizePixel = 0,
        Text = caption,
        TextColor3 = C.white,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = true,
        ZIndex = 4,
    }, parent)
    corner(b, 7)
    stroke(b, C.purple, 0.65, 1)
    track(b.Activated:Connect(function() callback(b) end))
    return b
end

local function showHome()
    clearContent()
    card("Welcome to Agents WideOpen", "Purple galaxy interface with working local utility controls.")
    card("Performance", "Open the Performance tab for an FPS counter and local shadow preview.")
    card("Customization", "Use the game's official garage for bike upgrades. This UI does not have access to private garage APIs.")
    card("Feature status", "Noclip is a status indicator only; it does not change game collision behavior.")
end

local bikeTunePreview = {topSpeed = 150, acceleration = 100, handling = 50}

local function addTuneSlider(titleText, key, minValue, maxValue, height)
    local f = card(titleText, "Preview setting — not connected to WideOpen's live bike physics.", height or 94)
    local valueLabel = text(f, tostring(bikeTunePreview[key]) .. "%", UDim2.fromOffset(58, 24),
        UDim2.new(1, -72, 0, 7), 13, C.bright, Enum.Font.GothamBold, Enum.TextXAlignment.Right)

    local trackFrame = new("Frame", {
        Size = UDim2.new(1, -24, 0, 10),
        Position = UDim2.fromOffset(12, 53),
        BackgroundColor3 = C.dark,
        BorderSizePixel = 0,
    }, f)
    corner(trackFrame, 8)

    local ratio = (bikeTunePreview[key] - minValue) / (maxValue - minValue)
    local fill = new("Frame", {
        Size = UDim2.new(ratio, 0, 1, 0),
        BackgroundColor3 = C.purple,
        BorderSizePixel = 0,
    }, trackFrame)
    corner(fill, 8)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(ratio, 0, 0.5, 0),
        BackgroundColor3 = C.white,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, trackFrame)
    corner(knob, 8)
    stroke(knob, C.purple, 0, 2)

    local hitbox = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 4,
    }, trackFrame)

    local draggingSlider = false
    local function setValue(x)
        local r = math.clamp((x - trackFrame.AbsolutePosition.X) / trackFrame.AbsoluteSize.X, 0, 1)
        local v = math.floor((minValue + r * (maxValue - minValue)) / 5 + 0.5) * 5
        bikeTunePreview[key] = math.clamp(v, minValue, maxValue)
        local newRatio = (bikeTunePreview[key] - minValue) / (maxValue - minValue)
        valueLabel.Text = tostring(bikeTunePreview[key]) .. "%"
        fill.Size = UDim2.new(newRatio, 0, 1, 0)
        knob.Position = UDim2.new(newRatio, 0, 0.5, 0)
    end
    track(hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            setValue(input.Position.X)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setValue(input.Position.X)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end))
end

local function showPerformance()
    clearContent()
    card("Bike tuning", "Interactive sliders for top speed, acceleration, and handling. These are UI previews until connected to an authorized vehicle controller.", 70)
    addTuneSlider("Top speed", "topSpeed", 50, 300, 82)
    addTuneSlider("Acceleration", "acceleration", 0, 200, 82)
    addTuneSlider("Handling", "handling", 0, 100, 82)

    local fpsCard = card("FPS counter", "Displays an FPS overlay in the top-left corner.", 88)
    local fpsButton = button(fpsCard, fpsEnabled and "Disable FPS counter" or "Enable FPS counter", function(b)
        fpsEnabled = not fpsEnabled
        b.Text = fpsEnabled and "Disable FPS counter" or "Enable FPS counter"
        if fpsEnabled and not fpsLabel then
            fpsLabel = new("TextLabel", {
                Name = "FPSOverlay",
                Size = UDim2.fromOffset(150, 30),
                Position = UDim2.fromOffset(12, 12),
                BackgroundColor3 = C.dark,
                TextColor3 = C.bright,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                ZIndex = 10,
            }, gui)
            corner(fpsLabel, 8)
            stroke(fpsLabel, C.purple, 0, 1)
        elseif not fpsEnabled and fpsLabel then
            fpsLabel:Destroy()
            fpsLabel = nil
        end
    end)
    fpsButton.Name = "ToggleFPS"

    local shadowCard = card("Low-graphics preview", "Toggle local global shadows to reduce visual effects.", 88)
    local shadowButton = button(shadowCard,
        graphicsEnabled and "Disable low-graphics preview" or "Enable low-graphics preview",
        function(b)
            graphicsEnabled = not graphicsEnabled
            Lighting.GlobalShadows = not graphicsEnabled and originalShadows or false
            b.Text = graphicsEnabled and "Disable low-graphics preview" or "Enable low-graphics preview"
        end)
    shadowButton.Name = "ToggleShadows"
end

local function showCustomization()
    clearContent()
    card("Motorcycle customization", "This menu cannot change WideOpen's private bike data without an official supported API.")
    local c = card("Open the official garage", "Use the game's normal garage interaction to change paint, rims, exhaust, and other supported parts.", 88)
    button(c, "Garage instructions", function()
        warn("Agents WideOpen: use the in-game garage to customize your motorcycle.")
    end)
    card("Why upgrades are not wired here", "The provided source only contained collision/crash hooks and a small toggle; it did not include garage customization functions.")
end

local function showNoclip()
    clearContent()
    card("Noclip status", "UI indicator only. It does not disable WideOpen's collision, crash, or police systems.")
    local c = card("Status indicator", "Press N or click below to change the displayed status.", 88)
    local b = button(c, noclipStatus and "Noclip status: ON" or "Noclip status: OFF", function(btn)
        noclipStatus = not noclipStatus
        btn.Text = noclipStatus and "Noclip status: ON" or "Noclip status: OFF"
        btn.BackgroundColor3 = noclipStatus and C.active or Color3.fromRGB(52, 30, 78)
    end)
    b.Name = "NoclipStatus"
end

local function showSettings()
    clearContent()
    card("Settings", "Personalize the interface.")
    local starCard = card("Star field", "Show or hide the purple decorative stars.", 88)
    button(starCard, starsVisible and "Hide stars" or "Show stars", function(b)
        starsVisible = not starsVisible
        starField.Visible = starsVisible
        b.Text = starsVisible and "Hide stars" or "Show stars"
    end)
    local resetCard = card("Reset graphics", "Restore the original global-shadows setting.", 88)
    button(resetCard, "Reset visuals", function()
        graphicsEnabled = false
        Lighting.GlobalShadows = originalShadows
        showSettings()
    end)
end

local pages = {
    Home = showHome,
    Performance = showPerformance,
    Customization = showCustomization,
    Noclip = showNoclip,
    Settings = showSettings,
}

local function openPage(name)
    currentPage = name
    pageTitle.Text = name
    local renderPage = pages[name] or showHome
    renderPage()
end

local navButtons = {}
for index, name in ipairs({"Home", "Performance", "Customization", "Noclip", "Settings"}) do
    local b = new("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = name == "Home" and C.active or C.panel,
        BackgroundTransparency = name == "Home" and 0 or 0.22,
        BorderSizePixel = 0,
        Text = "✦   " .. name,
        TextColor3 = C.white,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        LayoutOrder = index,
        ZIndex = 2,
    }, sidebar)
    corner(b, 8)
    stroke(b, C.purple, 0.75, 1)
    navButtons[name] = b
    track(b.Activated:Connect(function()
        for _, other in pairs(navButtons) do
            other.BackgroundColor3 = C.panel
            other.BackgroundTransparency = 0.22
        end
        b.BackgroundColor3 = C.active
        b.BackgroundTransparency = 0
        openPage(name)
    end))
end


-- Open Performance by default so the sliders are visible immediately.
for name, b in pairs(navButtons) do
    b.BackgroundColor3 = name == "Performance" and C.active or C.panel
    b.BackgroundTransparency = name == "Performance" and 0 or 0.22
end
openPage("Performance")

track(UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.N and gui.Parent then
        noclipStatus = not noclipStatus
        if currentPage == "Noclip" then showNoclip() end
    end
end))

track(RunService.RenderStepped:Connect(function(dt)
    if destroyed or not fpsEnabled or not fpsLabel or not fpsLabel.Parent then return end
    fpsFrames += 1
    fpsElapsed += dt
    if fpsElapsed >= 0.5 then
        fpsLabel.Text = "✦  FPS: " .. math.floor(fpsFrames / fpsElapsed)
        fpsFrames, fpsElapsed = 0, 0
    end
end))

local minimized = false
local expandedSize = main.Size
local function setMinimized(state)
    minimized = state
    main.Size = minimized and UDim2.fromOffset(660, 76) or expandedSize
    sidebar.Visible = not minimized
    body.Visible = not minimized
    closeButton.Text = minimized and "+" or "×"
end

track(closeButton.Activated:Connect(function()
    setMinimized(not minimized)
end))
track(UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        setMinimized(not minimized)
    end
end))

gui.Destroying:Connect(function()
    destroyed = true
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    if fpsLabel then fpsLabel:Destroy() end
    Lighting.GlobalShadows = originalShadows
end)

-- Keep the Performance page open so the sliders are visible on startup.

-- Startup indicator: confirms the GUI was created successfully.
local startupToast = new("TextLabel", {
    Name = "AgentsStartupToast",
    Size = UDim2.fromOffset(250, 32),
    Position = UDim2.new(1, -262, 0, 12),
    BackgroundColor3 = C.dark,
    Text = "✦ Agents WideOpen loaded",
    TextColor3 = C.bright,
    TextSize = 12,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 20,
}, gui)
corner(startupToast, 8)
stroke(startupToast, C.purple, 0, 1)
task.delay(3, function()
    if startupToast and startupToast.Parent then startupToast:Destroy() end
end)
