-- WideOpen No-Crash / Noclip - revised client script
-- N = toggle | Purple menu | Minimize | Cleanup on re-execution
-- Client-side only; server-side collision/crash validation may still apply.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')
local WS = game:GetService('Workspace')
local player = Players.LocalPlayer
local env = getgenv()
if type(env.WideOpen_CleanUp) == 'function' then pcall(env.WideOpen_CleanUp) end
local enabled = true
local connections, changed = {}, setmetatable({}, {__mode='k'})
local original = env.WideOpen_Originals or {}
env.WideOpen_Originals = original
env.WideOpen_Noclip = true
local function active() return enabled and env.WideOpen_Noclip end
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function module(name)
    local folder = RS:FindFirstChild('Modules')
    local target = folder and folder:FindFirstChild(name)
    if not target then warn('[WideOpen] Missing module: '..name); return nil end
    local ok, result = pcall(require, target)
    if not ok or type(result) ~= 'table' then
        warn('[WideOpen] Cannot load '..name..': '..tostring(result))
        return nil
    end
    return result
end
local function wrap(modName, method, replacement)
    local mod = module(modName)
    if not mod or type(mod[method]) ~= 'function' then return end
    local key = modName..'.'..method
    if not original[key] then original[key] = mod[method] end
    local old = original[key]
    mod[method] = function(...)
        if active() then return replacement(...) end
        return old(...)
    end
end
wrap('CrashWalls', 'Cars', function(self)
    if self and type(self.ClearCars) == 'function' then pcall(self.ClearCars, self) end
end)
wrap('CrashWalls', 'Sweep', function() return nil end)
wrap('TrafficContact', 'Sweep', function() return nil, math.huge, 0, 1 end)
wrap('TrafficContact', 'Test', function() return nil, math.huge, 0 end)
wrap('ParkedVehicleContact', 'ResolveOne', function(_, _, _, maxPos, vel)
    return maxPos, vel, false
end)
wrap('ParkedVehicleContact', 'Resolve', function(_, pos, _, vel)
    return pos, vel, false
end)
wrap('PalmBeachPoliceContact', 'ResolveOne', function(_, _, _, _, maxPos, _, _, linVel)
    return maxPos, linVel, false, 0, Vector3.zero
end)
wrap('PalmBeachPoliceContact', 'step', function() end)
wrap('HighwayPoliceContact', 'step', function() end)
wrap('RideState', 'BeginCrash', function(cause, ...)
    if cause == nil or cause == 'traffic' or cause == 'police' or cause == 'car' or cause == 'wall' then
        return false
    end
    local old = original['RideState.BeginCrash']
    if old then return old(cause, ...) end
    return false
end)
-- Install the namecall hook at most once; it stays installed but is inert when disabled.
if type(hookmetamethod) == 'function' and type(getnamecallmethod) == 'function'
    and type(checkcaller) == 'function' and not env.WideOpen_NamecallInstalled then
    local previous
    local ok = pcall(function()
        previous = hookmetamethod(game, '__namecall', function(self, ...)
            if env.WideOpen_Noclip and not checkcaller() and getnamecallmethod() == 'FireServer' then
                local name = self.Name
                if name == 'ReportContact' or name == 'HighwayCopHit' or name == 'ReportCityCrash' then return end
                if name == 'CrashRagdoll' then
                    local action, cause = ...
                    if action == 'start' and (cause == 'traffic' or cause == 'police' or cause == 'car' or cause == 'wall') then return end
                end
            end
            return previous(self, ...)
        end)
    end)
    if ok then env.WideOpen_NamecallInstalled = true end
end
local function setGhost(part)
    if not part:IsA('BasePart') or part.Name == 'chassis_chassis' then return end
    if changed[part] == nil then changed[part] = part.CanCollide end
    if part.CanCollide then part.CanCollide = false end
end
local function scan(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do setGhost(obj) end
end
local function restore()
    for part, value in pairs(changed) do
        if part and part.Parent then pcall(function() part.CanCollide = value end) end
        changed[part] = nil
    end
end
local function scanWorld()
    if not active() then return end
    scan(WS:FindFirstChild('CrashWalls'))
    scan(WS:FindFirstChild('Traffic'))
    scan(WS:FindFirstChild('TrafficProxy'))
    local bikes = WS:FindFirstChild('ActiveBikes')
    if bikes then
        for _, bike in ipairs(bikes:GetChildren()) do
            local owner = bike:GetAttribute('OwnerUserId')
            if owner == player.UserId or (owner == nil and bike.Name:find(player.Name, 1, true)) then
                scan(bike)
            end
        end
    end
end
local gui = Instance.new('ScreenGui')
gui.Name = 'WideOpen_NoclipGUI'
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild('PlayerGui')
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(250, 112)
frame.Position = UDim2.new(0.04, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 17, 31)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
local corner = Instance.new('UICorner', frame)
corner.CornerRadius = UDim.new(0, 12)
local outline = Instance.new('UIStroke', frame)
outline.Color = Color3.fromRGB(135, 76, 235)
outline.Thickness = 1.5
local title = Instance.new('TextLabel', frame)
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.fromOffset(195, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(228, 213, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = 'WIDEOPEN  //  NO-CRASH'
local minimize = Instance.new('TextButton', frame)
minimize.Position = UDim2.new(1, -33, 0, 8)
minimize.Size = UDim2.fromOffset(24, 24)
minimize.BackgroundColor3 = Color3.fromRGB(47, 36, 68)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.Text = '−'
Instance.new('UICorner', minimize).CornerRadius = UDim.new(0, 6)
local toggle = Instance.new('TextButton', frame)
toggle.Position = UDim2.fromOffset(12, 42)
toggle.Size = UDim2.new(1, -24, 0, 39)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.AutoButtonColor = false
Instance.new('UICorner', toggle).CornerRadius = UDim.new(0, 8)
local hint = Instance.new('TextLabel', frame)
hint.BackgroundTransparency = 1
hint.Position = UDim2.fromOffset(12, 86)
hint.Size = UDim2.new(1, -24, 0, 18)
hint.Text = 'Press N to toggle  •  Drag to move'
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.TextColor3 = Color3.fromRGB(161, 148, 182)
local function update()
    toggle.Text = active() and '●  ENABLED  [N]' or '○  DISABLED  [N]'
    toggle.BackgroundColor3 = active() and Color3.fromRGB(95, 47, 166) or Color3.fromRGB(55, 42, 68)
    toggle.TextColor3 = active() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 184, 218)
end
local function setEnabled(value)
    enabled = value
    env.WideOpen_Noclip = value
    WS:SetAttribute('NFNC_NOCRASH', value)
    if value then scanWorld() else restore() end
    update()
end
connect(toggle.MouseButton1Click, function() setEnabled(not enabled) end)
local collapsed = false
connect(minimize.MouseButton1Click, function()
    collapsed = not collapsed
    frame.Size = collapsed and UDim2.fromOffset(250, 37) or UDim2.fromOffset(250, 112)
    toggle.Visible = not collapsed
    hint.Visible = not collapsed
    minimize.Text = collapsed and '+' or '−'
end)
connect(UIS.InputBegan, function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.N then setEnabled(not enabled) end
end)
-- Scan five times a second rather than on every render/physics frame.
local running = true
task.spawn(function()
    while running do
        if active() then pcall(scanWorld) end
        task.wait(0.2)
    end
end)
setEnabled(true)
env.WideOpen_CleanUp = function()
    running = false
    enabled = false
    env.WideOpen_Noclip = false
    restore()
    for _, c in ipairs(connections) do c:Disconnect() end
    for key, old in pairs(original) do
        local moduleName, method = key:match('^(.-)%.(.+)$')
        local folder = RS:FindFirstChild('Modules')
        local target = folder and folder:FindFirstChild(moduleName)
        if target then
            local ok, mod = pcall(require, target)
            if ok and type(mod) == 'table' then mod[method] = old end
        end
    end
    WS:SetAttribute('NFNC_NOCRASH', false)
    if gui.Parent then gui:Destroy() end
end
