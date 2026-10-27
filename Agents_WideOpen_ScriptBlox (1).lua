-- Agents Wideopen
-- LocalScript for YOUR OWN Roblox Studio experience.
-- Install in: StarterPlayer > StarterPlayerScripts
--
-- Controls:
--   Right Shift = show/hide the menu
--   N           = toggle noclip for your own character
--   Toggle      = enable/disable noclip
--   Minimize    = collapse/expand the menu
--
-- This is a Studio-friendly implementation. It does not use executor-only
-- functions, metatable hooks, or game-specific anti-cheat/remote interception.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "AgentsWideopenGui"
local noclipEnabled = false
local menuMinimized = false
local menuVisible = true

local character
local descendantAddedConnection
local characterAddedConnection
local heartbeatConnection

-- Remember each part's original collision state so it can be restored.
local originalCollision = {}

local function rememberAndSetNoCollide(instance)
	if not noclipEnabled or not instance:IsA("BasePart") then
		return
	end

	if originalCollision[instance] == nil then
		originalCollision[instance] = instance.CanCollide
	end

	instance.CanCollide = false
end

local function restoreCollisions()
	for part, canCollide in pairs(originalCollision) do
		if part and part.Parent then
			part.CanCollide = canCollide
		end
	end
	table.clear(originalCollision)
end

local function applyNoclipToCharacter()
	if not noclipEnabled or not character then
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			rememberAndSetNoCollide(descendant)
		end
	end
end

local function setNoclip(enabled)
	noclipEnabled = enabled

	if noclipEnabled then
		applyNoclipToCharacter()
	else
		restoreCollisions()
	end
end

local function bindCharacter(newCharacter)
	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	-- Restore old character parts before switching to the new character.
	restoreCollisions()
	character = newCharacter

	if character then
		descendantAddedConnection = character.DescendantAdded:Connect(function(instance)
			if noclipEnabled then
				rememberAndSetNoCollide(instance)
			end
		end)

		if noclipEnabled then
			applyNoclipToCharacter()
		end
	end
end

-- Remove a previous copy if the script is rerun in Studio.
local oldGui = playerGui:FindFirstChild(GUI_NAME)
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(250, 145)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(19, 16, 29)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(135, 76, 255)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(31, 23, 48)
header.BorderSizePixel = 0
header.Parent = mainFrame

-- Drag the menu by holding the title bar (including the title text).
local dragging = false
local dragStart
local startPosition

local function beginDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	dragging = true
	dragStart = input.Position
	startPosition = mainFrame.Position

	local endedConnection
	endedConnection = UserInputService.InputEnded:Connect(function(endedInput)
		if endedInput.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if endedConnection then
				endedConnection:Disconnect()
			end
		end
	end)
end

header.InputBegan:Connect(beginDrag)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 12)
headerCover.Position = UDim2.new(0, 0, 1, -12)
headerCover.BackgroundColor3 = header.BackgroundColor3
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -84, 1, 0)
title.Position = UDim2.fromOffset(13, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "AGENTS WIDEOPEN"
title.TextColor3 = Color3.fromRGB(239, 231, 255)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = header
title.InputBegan:Connect(beginDrag)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.fromOffset(30, 28)
minimizeButton.Position = UDim2.new(1, -39, 0, 7)
minimizeButton.BackgroundColor3 = Color3.fromRGB(65, 44, 96)
minimizeButton.BorderSizePixel = 0
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 18
minimizeButton.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 7)
minCorner.Parent = minimizeButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -26, 0, 25)
statusLabel.Position = UDim2.fromOffset(13, 51)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Noclip: OFF"
statusLabel.TextColor3 = Color3.fromRGB(194, 184, 211)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleNoclip"
toggleButton.Size = UDim2.new(1, -26, 0, 38)
toggleButton.Position = UDim2.fromOffset(13, 83)
toggleButton.BackgroundColor3 = Color3.fromRGB(91, 54, 145)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "ENABLE NOCLIP  [N]"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextSize = 12
toggleButton.AutoButtonColor = true
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Size = UDim2.new(1, -26, 0, 16)
footer.Position = UDim2.fromOffset(13, 123)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.Gotham
footer.Text = "Right Shift: menu  •  N: toggle"
footer.TextColor3 = Color3.fromRGB(139, 127, 159)
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = mainFrame

local function updateGui()
	if noclipEnabled then
		statusLabel.Text = "Noclip: ON"
		statusLabel.TextColor3 = Color3.fromRGB(192, 255, 210)
		toggleButton.Text = "DISABLE NOCLIP  [N]"
		toggleButton.BackgroundColor3 = Color3.fromRGB(43, 111, 79)
	else
		statusLabel.Text = "Noclip: OFF"
		statusLabel.TextColor3 = Color3.fromRGB(194, 184, 211)
		toggleButton.Text = "ENABLE NOCLIP  [N]"
		toggleButton.BackgroundColor3 = Color3.fromRGB(91, 54, 145)
	end

	statusLabel.Visible = not menuMinimized
	toggleButton.Visible = not menuMinimized
	footer.Visible = not menuMinimized
	mainFrame.Size = menuMinimized and UDim2.fromOffset(250, 42) or UDim2.fromOffset(250, 145)
	screenGui.Enabled = menuVisible
	minimizeButton.Text = menuMinimized and "+" or "−"
end

toggleButton.Activated:Connect(function()
	setNoclip(not noclipEnabled)
	updateGui()
end)

minimizeButton.Activated:Connect(function()
	menuMinimized = not menuMinimized
	updateGui()
end)

local dragConnection = UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		menuVisible = not menuVisible
		updateGui()
	elseif input.KeyCode == Enum.KeyCode.N then
		setNoclip(not noclipEnabled)
		updateGui()
	end
end)

characterAddedConnection = player.CharacterAdded:Connect(bindCharacter)
if player.Character then
	bindCharacter(player.Character)
end

-- Light safety pass in case another local system changes a character part's
-- collision setting while noclip is enabled.
heartbeatConnection = RunService.Heartbeat:Connect(function()
	if noclipEnabled then
		applyNoclipToCharacter()
	end
end)

updateGui()

-- Restore state if the LocalScript is removed or the GUI is destroyed.
script.Destroying:Connect(function()
	setNoclip(false)

	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
	end
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
	end
	if inputConnection then
		inputConnection:Disconnect()
	end
	if dragConnection then
		dragConnection:Disconnect()
	end
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end
end)
