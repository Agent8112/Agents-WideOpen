--[[
    Script title: Agents WideOpen
    Game: WideOpen Motorcycle
    Type: UI / client-side utility prototype
    Theme: Purple galaxy with stars

    FEATURES
      - Draggable purple-themed interface
      - Home, Performance, Customization, Noclip, and Settings tabs
      - Live FPS overlay
      - Local global-shadows preview toggle
      - Star-field visibility toggle
      - Keyboard shortcut (N) for the noclip STATUS indicator

    IMPORTANT
      This upload is a UI/utility prototype. It does not bypass WideOpen's
      collision or crash systems, modify server-side game state, unlock paid
      parts, or implement game-specific garage actions. The noclip switch is
      only a visual status indicator. Run as a LocalScript in your own Roblox
      Studio test place. Executor-specific hooks are intentionally excluded.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up a previous copy.
local previous = playerGui:FindFirstChild("AgentsWideOpen")
if previous then
    previous:Destroy()
end

local purple = Color3.fromRGB(176, 85, 255)
local brightPurple = Color3.fromRGB(220, 165, 255)
local dark = Color3.fromRGB(16, 10, 29)
local panel = Color3.fromRGB(29, 18, 48)
local muted = Color3.fromRGB(178, 154, 205)
local white = Color3.fromRGB(250, 245, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "AgentsWideOpen"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function round(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = instance
    return corner
end

local function outline(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or purple
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = instance
    return stroke
end

local function label(parent, text, size, position, fontSize, color, font)
    local obj = Instance.new("TextLabel")
    obj.BackgroundTransparency = 1
    obj.Size = size
    obj.Position = position
    obj.Text = text
    obj.TextColor3 = color or white
    obj.TextSize = fontSize or 14
    obj.Font = font or Enum.Font.Gotham
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.TextYAlignment = Enum.TextYAlignment.Center
    obj.Parent = parent
    return obj
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(650, 440)
main.Position = UDim2.new(0.5, -325, 0.5, -220)
main.BackgroundColor3 = dark
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
round(main, 14)
outline(main, purple, 2, 0.08)

-- Decorative star field behind the controls.
local stars = Instance.new("Frame")
stars.Name = "StarField"
stars.Size = UDim2.fromScale(1, 1)
stars.BackgroundTransparency = 1
stars.ZIndex = 0
stars.Parent = main

local rng = Random.new(912)
for i = 1, 70 do
    local star = Instance.new("TextLabel")
    star.Name = "Star" .. i
    star.BackgroundTransparency = 1
    star.Text = (i % 4 == 0) and "✦" or "·"
    star.TextColor3 = brightPurple
    star.TextTransparency = rng:NextNumber(0.18, 0.7)
    star.TextSize = rng:NextInteger(9, 20)
    star.Size = UDim2.fromOffset(22, 22)
    star.Position = UDim2.new(rng:NextNumber(0, 0.96), 0, rng:NextNumber(0, 0.95), 0)
    star.ZIndex = 0
    star.Parent = stars
end

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 74)
top.BackgroundColor3 = Color3.fromRGB(24, 13, 42)
top.BackgroundTransparency = 0.12
top.BorderSizePixel = 0
top.ZIndex = 1
top.Parent = main

local title = label(top, "✦  AGENTS WIDEOPEN", UDim2.new(1, -120, 0, 35),
    UDim2.fromOffset(18, 7), 23, brightPurple, Enum.Font.GothamBlack)
title.ZIndex = 2
local subtitle = label(top, "MOTORCYCLE UTILITIES  •  GALAXY EDITION",
    UDim2.new(1, -130, 0, 20), UDim2.fromOffset(20, 43), 10, muted)
subtitle.ZIndex = 2

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(36, 32)
close.Position = UDim2.new(1, -48, 0, 15)
close.BackgroundColor3 = panel
close.Text = "×"
close.TextColor3 = white
close.TextSize = 24
close.Font = Enum.Font.GothamBold
close.ZIndex = 3
close.Parent = top
round(close, 8)
outline(close, purple, 1, 0.25)
close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag window from the header.
local dragging = false
local dragInput
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
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

local dragConnection = UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Position = UDim2.fromOffset(12, 86)
sidebar.Size = UDim2.new(0, 155, 1, -98)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 14, 36)
sidebar.BackgroundTransparency = 0.1
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 1
sidebar.Parent = main
round(sidebar, 10)
outline(sidebar, purple, 1, 0.72)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 7)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 10)
sidePadding.PaddingLeft = UDim.new(0, 9)
sidePadding.PaddingRight = UDim.new(0, 9)
sidePadding.Parent = sidebar

local body = Instance.new("Frame")
body.Name = "PageBody"
body.Position = UDim2.fromOffset(180, 86)
body.Size = UDim2.new(1, -192, 1, -98)
body.BackgroundTransparency = 1
body.ZIndex = 1
body.Parent = main

local pageTitle = label(body, "Home", UDim2.new(1, 0, 0, 30),
    UDim2.fromOffset(2, 0), 19, brightPurple, Enum.Font.GothamBold)
pageTitle.ZIndex = 2

local pageContent = Instance.new("ScrollingFrame")
pageContent.Name = "PageContent"
pageContent.Position = UDim2.fromOffset(0, 36)
pageContent.Size = UDim2.new(1, 0, 1, -36)
pageContent.BackgroundTransparency = 1
pageContent.BorderSizePixel = 0
pageContent.ScrollBarThickness = 4
pageContent.ScrollBarImageColor3 = purple
pageContent.CanvasSize = UDim2.fromOffset(0, 0)
pageContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
pageContent.ZIndex = 1
pageContent.Parent = body

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 9)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = pageContent

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.PaddingRight = UDim.new(0, 6)
contentPadding.Parent = pageContent

local connections = {}
local fpsEnabled = false
local fpsLabel
local fpsFrames = 0
local fpsElapsed = 0
local graphicsPreview = false
local oldGlobalShadows = Lighting.GlobalShadows
local noclipUiEnabled = false

local function makeCard(titleText, description)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = panel
    card.BackgroundTransparency = 0.06
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, -4, 0, description and 76 or 58)
    card.ZIndex = 2
    card.Parent = pageContent
    round(card, 9)
    outline(card, purple, 1, 0.68)
    label(card, titleText, UDim2.new(1, -22, 0, 25),
        UDim2.fromOffset(12, 7), 14, brightPurple, Enum.Font.GothamBold).ZIndex = 3
    if description then
        local desc = label(card, description, UDim2.new(1, -22, 0, 32),
            UDim2.fromOffset(12, 34), 11, muted)
        desc.TextWrapped = true
        desc.ZIndex = 3
    end
    return card
end

local function addButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 34)
    button.Position = UDim2.fromOffset(10, 0)
    button.BackgroundColor3 = Color3.fromRGB(52, 30, 78)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = white
    button.TextSize = 12
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = true
    button.ZIndex = 4
    button.Parent = parent
    round(button, 7)
    outline(button, purple, 1, 0.65)
    button.Activated:Connect(function()
        callback(button)
    end)
    return button
end

local function clearPage()
    for _, child in ipairs(pageContent:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function showHome()
    clearPage()
    makeCard("Welcome to Agents WideOpen", "Purple galaxy interface • local utility preview")
    makeCard("Quick start", "Choose a section on the left to view available tools.")
    makeCard("Compatibility note", "WideOpen-specific collision hooks and garage actions are not implemented in this Studio-safe build.")
    local card = makeCard("Interface status", "Menu loaded successfully.")
    card.Size = UDim2.new(1, -4, 0, 58)
end

local function showPerformance()
    clearPage()
    makeCard("Performance tools", "These settings affect your local client only.")
    local fpsCard = makeCard("FPS counter", "Show or hide a live frames-per-second readout.")
    local fpsButton = addButton(fpsCard, "Enable FPS counter", function(button)
        fpsEnabled = not fpsEnabled
        button.Text = fpsEnabled and "Disable FPS counter" or "Enable FPS counter"
        if fpsEnabled and not fpsLabel then
            fpsLabel = Instance.new("TextLabel")
            fpsLabel.Name = "FPSOverlay"
            fpsLabel.Size = UDim2.fromOffset(150, 30)
            fpsLabel.Position = UDim2.fromOffset(12, 12)
            fpsLabel.BackgroundColor3 = dark
            fpsLabel.TextColor3 = brightPurple
            fpsLabel.Font = Enum.Font.GothamBold
            fpsLabel.TextSize = 14
            fpsLabel.ZIndex = 10
            fpsLabel.Parent = gui
            round(fpsLabel, 8)
            outline(fpsLabel, purple, 1)
        elseif not fpsEnabled and fpsLabel then
            fpsLabel:Destroy()
            fpsLabel = nil
        end
    end)
    fpsButton.Position = UDim2.new(0, 10, 1, -39)
    local gfxCard = makeCard("Low-graphics preview", "Toggle global shadows locally. Other effects may be controlled by the game.")
    local gfxButton = addButton(gfxCard, "Enable low-graphics preview", function(button)
        graphicsPreview = not graphicsPreview
        Lighting.GlobalShadows = graphicsPreview and false or oldGlobalShadows
        button.Text = graphicsPreview and "Disable low-graphics preview" or "Enable low-graphics preview"
    end)
    gfxButton.Position = UDim2.new(0, 10, 1, -39)
end

local function showCustomization()
    clearPage()
    makeCard("Motorcycle customization", "Use the official garage and in-game menus for actual bike upgrades.")
    local garageCard = makeCard("Open garage", "This standalone UI cannot open WideOpen's private garage without a supported game API.")
    local garageButton = addButton(garageCard, "Garage instructions", function()
        warn("Agents WideOpen: open the game's garage using its normal in-game interaction.")
    end)
    garageButton.Position = UDim2.new(0, 10, 1, -39)
    makeCard("Available options", "Paint, rims, exhausts, spoilers, and other parts depend on what the game officially supports.")
end

local function showNoclip()
    clearPage()
    makeCard("Noclip status", "This control is a status UI only; it does not disable WideOpen collision or crash systems.")
    local card = makeCard("Noclip UI toggle", "Use only with an authorized implementation in your own Roblox Studio game.")
    local button = addButton(card, "Noclip UI: OFF", function(btn)
        noclipUiEnabled = not noclipUiEnabled
        btn.Text = noclipUiEnabled and "Noclip UI: ON" or "Noclip UI: OFF"
        btn.BackgroundColor3 = noclipUiEnabled and Color3.fromRGB(67, 35, 100) or Color3.fromRGB(52, 30, 78)
    end)
    button.Position = UDim2.new(0, 10, 1, -39)
    makeCard("Shortcut", "Press N to switch this status indicator. It does not change collision behavior.")
end

local function showSettings()
    clearPage()
    makeCard("Settings", "Personalize the menu.")
    local starsCard = makeCard("Star field", "Toggle the decorative stars in the background.")
    local starsButton = addButton(starsCard, "Hide stars", function(button)
        stars.Visible = not stars.Visible
        button.Text = stars.Visible and "Hide stars" or "Show stars"
    end)
    starsButton.Position = UDim2.new(0, 10, 1, -39)
    local resetCard = makeCard("Reset local visuals", "Restore the original global-shadows setting.")
    local resetButton = addButton(resetCard, "Reset visuals", function()
        graphicsPreview = false
        Lighting.GlobalShadows = oldGlobalShadows
    end)
    resetButton.Position = UDim2.new(0, 10, 1, -39)
end

local pages = {
    Home = showHome,
    Performance = showPerformance,
    Customization = showCustomization,
    Noclip = showNoclip,
    Settings = showSettings,
}

local function openPage(name)
    pageTitle.Text = name
    (pages[name] or showHome)()
end

for index, name in ipairs({"Home", "Performance", "Customization", "Noclip", "Settings"}) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = name == "Home" and Color3.fromRGB(63, 35, 92) or panel
    button.BackgroundTransparency = name == "Home" and 0 or 0.25
    button.BorderSizePixel = 0
    button.Text = "✦   " .. name
    button.TextColor3 = white
    button.TextSize = 12
    button.Font = Enum.Font.GothamSemibold
    button.LayoutOrder = index
    button.ZIndex = 2
    button.Parent = sidebar
    round(button, 8)
    outline(button, purple, 1, 0.75)
    button.Activated:Connect(function()
        for _, sibling in ipairs(sidebar:GetChildren()) do
            if sibling:IsA("TextButton") then
                sibling.BackgroundColor3 = panel
                sibling.BackgroundTransparency = 0.25
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(63, 35, 92)
        button.BackgroundTransparency = 0
        openPage(name)
    end)
end

local shortcutConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.N and gui.Parent then
        noclipUiEnabled = not noclipUiEnabled
        if pageTitle.Text == "Noclip" then
            -- Refresh the page so the displayed status stays consistent.
            showNoclip()
        end
    end
end)
table.insert(connections, shortcutConnection)

local fpsConnection = RunService.RenderStepped:Connect(function(dt)
    if not fpsEnabled or not fpsLabel or not fpsLabel.Parent then
        return
    end
    fpsFrames += 1
    fpsElapsed += dt
    if fpsElapsed >= 0.5 then
        fpsLabel.Text = "✦  FPS: " .. math.floor(fpsFrames / fpsElapsed)
        fpsFrames = 0
        fpsElapsed = 0
    end
end)
table.insert(connections, fpsConnection)

gui.Destroying:Connect(function()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    if fpsLabel then
        fpsLabel:Destroy()
    end
    Lighting.GlobalShadows = oldGlobalShadows
end)

openPage("Home")
