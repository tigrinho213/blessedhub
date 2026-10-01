--[[
    BLESSED HUB - UNIVERSAL & NPC EDITION (ENGLISH)
    LocalScript (StarterPlayer > StarterPlayerScripts)
]]

--========================================================
-- OPTIMIZED LOCALIZATIONS
--========================================================

local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local CFrame_new = CFrame.new
local UDim2_fromOffset = UDim2.fromOffset
local UDim2_fromScale = UDim2.fromScale
local Color3_fromRGB = Color3.fromRGB

local math_clamp = math.clamp
local math_floor = math.floor
local math_rad = math.rad
local table_insert = table.insert
local table_find = table.find

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--========================================================
-- CONFIG
--========================================================

local Config = {
    UI = { Open = true, ToggleKey = Enum.KeyCode.F4 },
    Aimbot = { Enabled = false, HoldToAim = true, TargetNPCs = true, Smoothness = 20, TargetPart = "Head", FOV = 150, ShowFOV = true },
    ESP = { Enabled = true, IncludeNPCs = true, Name = false, Box = false, Chams = false, Distance = false, Tracers = false, HealthBar = false },
    Globe = { NoFog = false, FullBright = false, HitboxEnabled = false, HitboxSize = 10 },
    Character = { SpeedEnabled = false, Speed = 16, Fly = false, FlySpeed = 50, SpinBot = false, SpinSpeed = 100, Noclip = false, InfiniteJump = false },
    World = { ClockTime = 14 }
}

--========================================================
-- COLORS
--========================================================

local Purple = Color3_fromRGB(145, 70, 255)
local PurpleLight = Color3_fromRGB(190, 120, 255)
local PurpleDark = Color3_fromRGB(65, 25, 100)
local OrangeNPC = Color3_fromRGB(255, 140, 0)

local Background = Color3_fromRGB(12, 7, 18)
local Panel = Color3_fromRGB(25, 16, 36)
local White = Color3_fromRGB(245, 240, 255)
local Gray = Color3_fromRGB(165, 155, 180)
local Green = Color3_fromRGB(80, 255, 145)
local Red = Color3_fromRGB(255, 75, 75)

--========================================================
-- CLEAN OLD UI
--========================================================

local old = PlayerGui:FindFirstChild("BlessedHub")
if old then old:Destroy() end

--========================================================
-- SCREEN GUI & COMPONENTS
--========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlessedHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local function Corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end

local function Stroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Purple
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function NewText(parent, text, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or White
    label.Font = Enum.Font.Gotham
    label.TextSize = size or 14
    label.Parent = parent
    return label
end

--========================================================
-- FOV CIRCLE
--========================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2_new(0.5, 0.5)
FOVCircle.Position = UDim2_fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle
Stroke(FOVCircle, PurpleLight, 0.3, 1.5)

--========================================================
-- MAIN INTERFACE
--========================================================

local BackgroundFrame = Instance.new("Frame")
BackgroundFrame.Size = UDim2_fromScale(1, 1)
BackgroundFrame.BackgroundColor3 = Color3_fromRGB(8, 4, 14)
BackgroundFrame.BackgroundTransparency = 0.15
BackgroundFrame.BorderSizePixel = 0
BackgroundFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2_fromOffset(570, 48)
TopBar.Position = UDim2_fromOffset(math_floor((Camera.ViewportSize.X - 570) / 2), 20)
TopBar.BackgroundColor3 = Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui
Corner(TopBar, 12)
Stroke(TopBar, Purple, 0.25, 1.5)

local TopTitle = NewText(TopBar, "BLESSED HUB", 16, White)
TopTitle.Size = UDim2_fromOffset(180, 48)
TopTitle.Position = UDim2_fromOffset(16, 0)
TopTitle.Font = Enum.Font.GothamBold
TopTitle.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = NewText(TopBar, "FPS: --", 14, Green)
FPSLabel.Size = UDim2_fromOffset(100, 48)
FPSLabel.Position = UDim2_fromOffset(350, 0)
FPSLabel.Font = Enum.Font.GothamBold

local PingLabel = NewText(TopBar, "PING: --", 14, White)
PingLabel.Size = UDim2_fromOffset(100, 48)
PingLabel.Position = UDim2_fromOffset(460, 0)
PingLabel.Font = Enum.Font.GothamBold

local Main = Instance.new("Frame")
Main.Size = UDim2_fromOffset(820, 550)
Main.Position = UDim2_fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2_new(0.5, 0.5)
Main.BackgroundColor3 = Panel
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Corner(Main, 16)
Stroke(Main, Purple, 0.18, 1.5)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2_fromOffset(82, 550)
Sidebar.BackgroundColor3 = Background
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Corner(Sidebar, 16)

local SideLayout = Instance.new("UIListLayout")
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Padding = UDim.new(0, 12)
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 18)
SidePadding.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2_fromOffset(715, 525)
Content.Position = UDim2_fromOffset(100, 12)
Content.BackgroundTransparency = 1
Content.Parent = Main

local PageTitle = NewText(Content, "Aimbot", 23, White)
PageTitle.Size = UDim2_fromOffset(715, 42)
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Font = Enum.Font.GothamBold

--========================================================
-- PAGES & TABS
--========================================================

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2_fromOffset(715, 477)
    page.Position = UDim2_fromOffset(0, 48)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content
    Pages[name] = page
    return page
end

local AimPage = CreatePage("Aimbot")
local ESPPage = CreatePage("ESP")
local CharacterPage = CreatePage("Character")
local GlobePage = CreatePage("Globe")
local SettingsPage = CreatePage("Settings")
AimPage.Visible = true

local function CreateTab(icon, title, page)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(55, 55)
    button.BackgroundColor3 = Panel
    button.Text = icon
    button.TextColor3 = Gray
    button.TextSize = 22
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = Sidebar
    Corner(button, 12)

    button.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
        PageTitle.Text = title
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Panel
                child.TextColor3 = Gray
            end
        end
        button.BackgroundColor3 = PurpleDark
        button.TextColor3 = White
    end)
    return button
end

local DefaultTab = CreateTab("🎯", "Aimbot", AimPage)
DefaultTab.BackgroundColor3 = PurpleDark
DefaultTab.TextColor3 = White
CreateTab("👁", "ESP", ESPPage)
CreateTab("♙", "Character", CharacterPage)
CreateTab("🌐", "Globe", GlobePage)
CreateTab("⚙", "Settings", SettingsPage)

--========================================================
-- UI CONTROLS
--========================================================

local function Section(parent, text, y)
    local label = NewText(parent, text, 16, PurpleLight)
    label.Size = UDim2_fromOffset(370, 32)
    label.Position = UDim2_fromOffset(0, y)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function Checkbox(parent, text, tableRef, key, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(370, 36)
    button.Position = UDim2_fromOffset(0, y)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2_fromOffset(20, 20)
    box.Position = UDim2_fromOffset(0, 8)
    box.BackgroundColor3 = Background
    box.BorderSizePixel = 0
    box.Parent = button
    Corner(box, 5)
    Stroke(box, Purple, 0.35)

    local check = NewText(box, "✓", 14, White)
    check.Size = UDim2_fromScale(1, 1)
    check.Font = Enum.Font.GothamBold
    check.Visible = tableRef[key] or false

    local label = NewText(button, text, 14, White)
    label.Size = UDim2_fromOffset(338, 36)
    label.Position = UDim2_fromOffset(32, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left

    button.MouseButton1Click:Connect(function()
        tableRef[key] = not tableRef[key]
        check.Visible = tableRef[key]
        if callback then callback(tableRef[key]) end
    end)
end

local function Slider(parent, text, tableRef, key, minValue, maxValue, y, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2_fromOffset(370, 65)
    holder.Position = UDim2_fromOffset(0, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local label = NewText(holder, text, 14, White)
    label.Size = UDim2_fromOffset(300, 25)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = NewText(holder, tostring(tableRef[key]), 14, PurpleLight)
    valueLabel.Size = UDim2_fromOffset(65, 25)
    valueLabel.Position = UDim2_fromOffset(305, 0)
    valueLabel.Font = Enum.Font.GothamBold

    local bar = Instance.new("Frame")
    bar.Size = UDim2_fromOffset(370, 7)
    bar.Position = UDim2_fromOffset(0, 37)
    bar.BackgroundColor3 = Background
    bar.BorderSizePixel = 0
    bar.Parent = holder
    Corner(bar, 5)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Purple
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Corner(fill, 5)

    local function Update(positionX)
        local percent = math_clamp((positionX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math_floor(minValue + (maxValue - minValue) * percent)
        tableRef[key] = value
        valueLabel.Text = tostring(value)
        fill.Size = UDim2_fromScale(percent, 1)
        if callback then callback(value) end
    end

    fill.Size = UDim2_fromScale(math_clamp((tableRef[key] - minValue) / (maxValue - minValue), 0, 1), 1)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function Dropdown(parent, text, tableRef, key, options, y)
    local holder = Instance.new("Frame")
    holder.Size = UDim2_fromOffset(370, 48)
    holder.Position = UDim2_fromOffset(0, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    NewText(holder, text, 14, White).Size = UDim2_fromOffset(140, 48)

    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(200, 34)
    button.Position = UDim2_fromOffset(170, 7)
    button.BackgroundColor3 = Background
    button.Text = tostring(tableRef[key])
    button.TextColor3 = White
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Parent = holder
    Corner(button, 7)
    Stroke(button, Purple, 0.5)

    local index = table_find(options, tableRef[key]) or 1
    button.MouseButton1Click:Connect(function()
        index = (index % #options) + 1
        tableRef[key] = options[index]
        button.Text = tostring(options[index])
    end)
end

local function ActionButton(parent, text, color, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(370, 42)
    button.Position = UDim2_fromOffset(0, y)
    button.BackgroundColor3 = color or Purple
    button.Text = text
    button.TextColor3 = White
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = parent

    Corner(button, 8)
    button.MouseButton1Click:Connect(callback)
    return button
end

--========================================================
-- TAB SETUP
--========================================================

Section(AimPage, "AIMBOT SETTINGS", 0)
Checkbox(AimPage, "Enable Aimbot / AimLock", Config.Aimbot, "Enabled", 40)
Checkbox(AimPage, "Hold Right Mouse Button", Config.Aimbot, "HoldToAim", 76)
Checkbox(AimPage, "Target NPCs & Entities", Config.Aimbot, "TargetNPCs", 112)
Checkbox(AimPage, "Show FOV Circle", Config.Aimbot, "ShowFOV", 148)
Slider(AimPage, "Smoothness", Config.Aimbot, "Smoothness", 1, 100, 184)
Dropdown(AimPage, "Target Part", Config.Aimbot, "TargetPart", {"Head", "HumanoidRootPart", "Torso"}, 254)
Slider(AimPage, "FOV Radius", Config.Aimbot, "FOV", 30, 600, 308)

Section(ESPPage, "ESP SETTINGS", 0)
Checkbox(ESPPage, "Enable ESP System", Config.ESP, "Enabled", 40)
Checkbox(ESPPage, "Include NPCs / Examination", Config.ESP, "IncludeNPCs", 76)
Checkbox(ESPPage, "Show Name", Config.ESP, "Name", 112)
Checkbox(ESPPage, "Show Distance", Config.ESP, "Distance", 148)
Checkbox(ESPPage, "3D Box", Config.ESP, "Box", 184)
Checkbox(ESPPage, "Chams (Highlight)", Config.ESP, "Chams", 220)
Checkbox(ESPPage, "Tracers (Lines)", Config.ESP, "Tracers", 256)
Checkbox(ESPPage, "Show Health Bar", Config.ESP, "HealthBar", 292)

Section(CharacterPage, "MOVEMENT & CHARACTER", 0)
Checkbox(CharacterPage, "Custom Speed", Config.Character, "SpeedEnabled", 40)
Slider(CharacterPage, "Walk Speed", Config.Character, "Speed", 16, 250, 80)
Checkbox(CharacterPage, "Fly Mode", Config.Character, "Fly", 150)
Slider(CharacterPage, "Fly Speed", Config.Character, "FlySpeed", 10, 300, 190)
Checkbox(CharacterPage, "Spin Bot", Config.Character, "SpinBot", 260)
Slider(CharacterPage, "Spin Speed", Config.Character, "SpinSpeed", 10, 500, 300)
Checkbox(CharacterPage, "Noclip (Walk Through Walls)", Config.Character, "Noclip", 370)
Checkbox(CharacterPage, "Infinite Jump", Config.Character, "InfiniteJump", 410)

Section(GlobePage, "WORLD VISUALS", 0)
Checkbox(GlobePage, "Remove Fog", Config.Globe, "NoFog", 40)
Checkbox(GlobePage, "Full Brightness", Config.Globe, "FullBright", 76)
Section(GlobePage, "HITBOX EXPANDER (ALL)", 130)
Checkbox(GlobePage, "Expand Target Hitbox (ALL)", Config.Globe, "HitboxEnabled", 170)
Slider(GlobePage, "Hitbox Size", Config.Globe, "HitboxSize", 2, 50, 210)

Section(SettingsPage, "CONFIGURATION MANAGER", 0)
local ConfigNameBox = Instance.new("TextBox")
ConfigNameBox.Size = UDim2_fromOffset(370, 42)
ConfigNameBox.Position = UDim2_fromOffset(0, 42)
ConfigNameBox.BackgroundColor3 = Background
ConfigNameBox.TextColor3 = White
ConfigNameBox.PlaceholderColor3 = Gray
ConfigNameBox.PlaceholderText = "Configuration name..."
ConfigNameBox.Font = Enum.Font.Gotham
ConfigNameBox.TextSize = 14
ConfigNameBox.Parent = SettingsPage
Corner(ConfigNameBox, 8)
Stroke(ConfigNameBox, Purple, 0.5)

-- Save & Load Config Functions
ActionButton(SettingsPage, "SAVE CONFIG", Purple, 94, function()
    local name = ConfigNameBox.Text ~= "" and ConfigNameBox.Text or "default"
    pcall(function()
        if writefile then
            writefile(name .. "_blessedhub.json", HttpService:JSONEncode(Config))
            print("[Blessed Hub] Config saved: " .. name)
        end
    end)
end)

ActionButton(SettingsPage, "LOAD CONFIG", PurpleDark, 144, function()
    local name = ConfigNameBox.Text ~= "" and ConfigNameBox.Text or "default"
    pcall(function()
        if readfile and isfile and isfile(name .. "_blessedhub.json") then
            local data = HttpService:JSONDecode(readfile(name .. "_blessedhub.json"))
            for category, keys in pairs(data) do
                if Config[category] then
                    for k, v in pairs(keys) do
                        Config[category][k] = v
                    end
                end
            end
            print("[Blessed Hub] Config loaded: " .. name)
        end
    end)
end)

-- Server Utilities
ActionButton(SettingsPage, "REJOIN SERVER", Color3_fromRGB(40, 120, 220), 194, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

ActionButton(SettingsPage, "SERVER HOP", Color3_fromRGB(120, 40, 220), 244, function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)

ActionButton(SettingsPage, "CLOSE HUB", Red, 294, function()
    Config.UI.Open = false
    Main.Visible = false
    TopBar.Visible = false
    BackgroundFrame.Visible = false
end)

--========================================================
-- OPTIMIZED NOCLIP CACHE & INFINITE JUMP
--========================================================

local LocalCharacterParts = {}
local function CacheCharacterParts(character)
    LocalCharacterParts = {}
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            table_insert(LocalCharacterParts, part)
        end
    end
end

if LocalPlayer.Character then CacheCharacterParts(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    CacheCharacterParts(char)
end)

RunService.Stepped:Connect(function()
    if Config.Character.Noclip then
        for i = 1, #LocalCharacterParts do
            local p = LocalCharacterParts[i]
            if p and p.Parent then
                p.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Character.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--========================================================
-- UNIVERSAL ENTITY / NPC & PLAYER SCANNER
--========================================================

local EntityCache = {}

local function ClearEntityESP(model)
    if EntityCache[model] then
        for _, obj in pairs(EntityCache[model]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "table" and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
        EntityCache[model] = nil
    end
end

local function IsValidEntity(model)
    if not model or not model:IsA("Model") or model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("LowerTorso")
    if hum and hum.Health > 0 and root then
        return true
    end
    return false
end

local function SetupEntityESP(model)
    if EntityCache[model] or not IsValidEntity(model) then return end

    local player = Players:GetPlayerFromCharacter(model)
    local isPlayer = player ~= nil

    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    local head = model:FindFirstChild("Head") or root
    local hum = model:FindFirstChildOfClass("Humanoid")

    if not root or not hum then return end

    local data = {
        Model = model,
        Root = root,
        Head = head,
        Humanoid = hum,
        IsPlayer = isPlayer,
        Name = isPlayer and player.DisplayName or model.Name
    }

    local mainColor = isPlayer and Purple or OrangeNPC
    local boxColor = isPlayer and PurpleLight or OrangeNPC

    -- Highlight (Chams)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = mainColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = White
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = model
    data.Highlight = highlight

    -- Box 3D
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = root
    box.Size = Vector3_new(4, 6, 2)
    box.Color3 = boxColor
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.Visible = false
    box.Parent = root
    data.Box = box

    -- Billboard (Name/Distance/HealthBar)
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2_fromOffset(200, 50)
        billboard.StudsOffset = Vector3_new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Enabled = false
        billboard.Parent = head

        local nameLabel = NewText(billboard, "", 13, White)
        nameLabel.Size = UDim2_fromOffset(200, 20)
        nameLabel.Font = Enum.Font.GothamBold

        local healthLabel = NewText(billboard, "", 11, Green)
        healthLabel.Position = UDim2_fromOffset(0, 20)
        healthLabel.Size = UDim2_fromOffset(200, 18)
        healthLabel.Font = Enum.Font.GothamBold

        data.Billboard = billboard
        data.NameLabel = nameLabel
        data.HealthLabel = healthLabel
    end

    -- Tracer Line (UI Frame Fallback)
    local tracerFrame = Instance.new("Frame")
    tracerFrame.AnchorPoint = Vector2_new(0.5, 0.5)
    tracerFrame.BackgroundColor3 = mainColor
    tracerFrame.BorderSizePixel = 0
    tracerFrame.Visible = false
    tracerFrame.Parent = ScreenGui
    data.Tracer = tracerFrame

    EntityCache[model] = data

    hum.Died:Connect(function()
        ClearEntityESP(model)
    end)
end

-- Scan Workspace for NPCs and Players periodically
task.spawn(function()
    while true do
        task.wait(1.5)
        for model, data in pairs(EntityCache) do
            if not model or not model.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
                ClearEntityESP(model)
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and IsValidEntity(obj) then
                SetupEntityESP(obj)
            end
        end
    end
end)

--========================================================
-- HITBOX EXPANDER FOR ALL (PLAYERS + NPCS)
--========================================================

task.spawn(function()
    while true do
        task.wait(0.2)
        for model, data in pairs(EntityCache) do
            if model and model.Parent and data.Root and data.Humanoid and data.Humanoid.Health > 0 then
                if Config.Globe.HitboxEnabled then
                    local size = Config.Globe.HitboxSize
                    if data.Root.Size.X ~= size then
                        data.Root.Size = Vector3_new(size, size, size)
                        data.Root.Transparency = 0.7
                        data.Root.Color = data.IsPlayer and Purple or OrangeNPC
                        data.Root.Material = Enum.Material.ForceField
                        data.Root.CanCollide = false
                    end
                elseif data.Root.Transparency ~= 1 then
                    data.Root.Size = Vector3_new(2, 2, 1)
                    data.Root.Transparency = 1
                end
            end
        end
    end
end)

--========================================================
-- PERFORMANCE MONITOR (1 SEC INTERVAL)
--========================================================

task.spawn(function()
    local frames = 0
    RunService.RenderStepped:Connect(function() frames += 1 end)

    while true do
        task.wait(1)
        FPSLabel.Text = "FPS: " .. tostring(frames)
        frames = 0

        pcall(function()
            local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
            if pingItem then
                PingLabel.Text = "PING: " .. math_floor(pingItem:GetValue()) .. "ms"
            end
        end)
    end
end)

--========================================================
-- AIMBOT TARGET FINDER (PLAYERS + NPCS)
--========================================================

local function GetClosestTarget()
    local closest, shortestDist = nil, Config.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for model, data in pairs(EntityCache) do
        if model and model.Parent and data.Humanoid and data.Humanoid.Health > 0 then
            local isPlayer = data.IsPlayer
            if isPlayer or (not isPlayer and Config.Aimbot.TargetNPCs) then
                local targetPart = model:FindFirstChild(Config.Aimbot.TargetPart) or data.Head or data.Root
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2_new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

--========================================================
-- MAIN RENDER LOOP
--========================================================

RunService.RenderStepped:Connect(function(dt)
    -- UI FOV Circle
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
    if FOVCircle.Visible then
        local sz = Config.Aimbot.FOV * 2
        FOVCircle.Size = UDim2_fromOffset(sz, sz)
    end

    -- AIMBOT
    if Config.Aimbot.Enabled then
        local aiming = not Config.Aimbot.HoldToAim or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if aiming then
            local target = GetClosestTarget()
            if target then
                local targetCF = CFrame_new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, math_clamp(1 / (Config.Aimbot.Smoothness / 5), 0.01, 1))
            end
        end
    end

    -- LOCAL CHARACTER (Speed, Fly, Spin)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        if hum then
            hum.WalkSpeed = Config.Character.SpeedEnabled and Config.Character.Speed or 16
        end

        if root then
            if Config.Character.Fly then
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

                root.AssemblyLinearVelocity = dir.Magnitude > 0 and (dir.Unit * Config.Character.FlySpeed) or Vector3.zero
            end

            if Config.Character.SpinBot then
                root.CFrame *= CFrame.Angles(0, math_rad(Config.Character.SpinSpeed * dt), 0)
            end
        end
    end

    -- ESP UPDATE (PLAYERS & NPCS)
    if Config.ESP.Enabled then
        for model, data in pairs(EntityCache) do
            local isAllowed = data.IsPlayer or Config.ESP.IncludeNPCs
            if isAllowed and model and model.Parent then
                if data.Highlight then data.Highlight.Enabled = Config.ESP.Chams end
                if data.Box then data.Box.Visible = Config.ESP.Box end

                -- Billboard Name & Distance
                if data.Billboard and data.Head then
                    local show = Config.ESP.Name or Config.ESP.Distance or Config.ESP.HealthBar
                    data.Billboard.Enabled = show
                    if show then
                        local dist = math_floor((Camera.CFrame.Position - data.Head.Position).Magnitude)
                        data.NameLabel.Text = (Config.ESP.Name and data.Name or "") .. (Config.ESP.Distance and " [" .. dist .. "m]" or "")
                        if Config.ESP.HealthBar and data.Humanoid then
                            local hp = math_floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100)
                            data.HealthLabel.Text = "HP: " .. hp .. "%"
                            data.HealthLabel.Visible = true
                        else
                            data.HealthLabel.Visible = false
                        end
                    end
                end

                -- Tracers
                if Config.ESP.Tracers and data.Root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(data.Root.Position)
                    if onScreen and data.Tracer then
                        local startPos = Vector2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        local endPos = Vector2_new(screenPos.X, screenPos.Y)
                        local distance = (endPos - startPos).Magnitude
                        local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)

                        data.Tracer.Size = UDim2_fromOffset(distance, 1.5)
                        data.Tracer.Position = UDim2_fromOffset((startPos.X + endPos.X) / 2, (startPos.Y + endPos.Y) / 2)
                        data.Tracer.Rotation = math.deg(angle)
                        data.Tracer.Visible = true
                    elseif data.Tracer then
                        data.Tracer.Visible = false
                    end
                elseif data.Tracer then
                    data.Tracer.Visible = false
                end
            else
                if data.Highlight then data.Highlight.Enabled = false end
                if data.Box then data.Box.Visible = false end
                if data.Billboard then data.Billboard.Enabled = false end
                if data.Tracer then data.Tracer.Visible = false end
            end
        end
    end

    -- WORLD / LIGHTING
    Lighting.FogEnd = Config.Globe.NoFog and 100000 or 10000
    Lighting.Brightness = Config.Globe.FullBright and 3 or 1
end)

-- Keyboard Input
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.UI.ToggleKey then
        Config.UI.Open = not Config.UI.Open
        Main.Visible = Config.UI.Open
        TopBar.Visible = Config.UI.Open
        BackgroundFrame.Visible = Config.UI.Open
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        Config.Character.Noclip = not Config.Character.Noclip
    end
end)

print("[Blessed Hub] Loaded successfully!")
print("[Blessed Hub] Toggle Menu: F4 | Toggle Noclip: ]")
