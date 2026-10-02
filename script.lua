--[[
    BLESSED HUB - ULTIMATE HIGHLIGHT, ESP & VIEWMODEL EDITION
    LocalScript (StarterPlayer > StarterPlayerScripts)
]]

--========================================================
-- OPTIMIZED LOCALIZATIONS & SERVICES
--========================================================

local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local CFrame_new = CFrame.new
local UDim2_fromOffset = UDim2.fromOffset
local UDim2_fromScale = UDim2.fromScale
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV

local math_clamp = math.clamp
local math_floor = math.floor
local table_insert = table.insert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--========================================================
-- CONFIG
--========================================================

local SYSTEM_KEY = "OmTaX2WWLZCABL12"
local KeyVerified = false

local Config = {
    UI = { Open = true, ToggleKey = Enum.KeyCode.F4 },
    Hands = {
        Enabled = false,
        OffsetX = 0,
        OffsetY = 0,
        OffsetZ = 0,
        Material = "ForceField",
        ColorR = 145, ColorG = 70, ColorB = 255,
        Rainbow = false,
        Transparency = 3
    },
    Aimbot = {
        Enabled = false,
        HoldToAim = true,
        TargetNPCs = true,
        TargetPlayers = true,
        Smoothness = 20,
        TargetPart = "Head",
        FOV = 150,
        ShowFOV = true,
        FOVColorR = 190, FOVColorG = 120, FOVColorB = 255
    },
    ESP = {
        Enabled = true,
        IncludePlayers = true,
        IncludeNPCs = true,
        Name = true,
        Distance = true,
        Health = true,
        
        -- Caixas 3D & Marcadores
        Box3D = false,
        BoxColorR = 255, BoxColorG = 140, BoxColorB = 0,
        BoxTransparency = 4,
        HeadDot = false,
        HeadDotSize = 4,
        
        -- Highlight / Chams
        ChamsEnabled = false,
        ChamsFillR = 145, ChamsFillG = 70, ChamsFillB = 255,
        ChamsFillTransparency = 5,
        ChamsOutlineR = 255, ChamsOutlineG = 255, ChamsOutlineB = 255,
        ChamsOutlineTransparency = 0,
        ChamsAlwaysOnTop = true,
        ChamsRainbow = false
    },
    Globe = {
        NoFog = false,
        FullBright = false,
        HitboxEnabled = false,
        HitboxSize = 5,
        HitboxTarget = "Head",
        HitboxTransparency = 5,
        MaxDistance = 400,
        FixedFOVEnabled = false,
        FixedFOV = 120,
        Gravity = 196.2
    },
    Character = {
        SpeedEnabled = false, Speed = 16,
        Fly = false, FlySpeed = 50,
        SpinBot = false, SpinSpeed = 100,
        Noclip = false, InfiniteJump = false
    },
    Crosshair = {
        Enabled = false, Size = 10, Gap = 4, Thickness = 2,
        ColorR = 255, ColorG = 255, ColorB = 255, Rainbow = false
    }
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
-- FOV CIRCLE & CROSSHAIR
--========================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2_new(0.5, 0.5)
FOVCircle.Position = UDim2_fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui
Corner(FOVCircle, 1000)
local FOVStroke = Stroke(FOVCircle, PurpleLight, 0.3, 1.5)

local CrosshairFolder = Instance.new("Folder")
CrosshairFolder.Name = "Crosshair"
CrosshairFolder.Parent = ScreenGui

local CH_Top = Instance.new("Frame", CrosshairFolder)
local CH_Bottom = Instance.new("Frame", CrosshairFolder)
local CH_Left = Instance.new("Frame", CrosshairFolder)
local CH_Right = Instance.new("Frame", CrosshairFolder)

for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do
    line.BorderSizePixel = 0
    line.Visible = false
end

--========================================================
-- KEY SYSTEM OVERLAY
--========================================================

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2_fromOffset(400, 230)
KeyFrame.Position = UDim2_fromScale(0.5, 0.5)
KeyFrame.AnchorPoint = Vector2_new(0.5, 0.5)
KeyFrame.BackgroundColor3 = Panel
KeyFrame.Parent = ScreenGui
Corner(KeyFrame, 16)
Stroke(KeyFrame, Purple, 0.2, 1.5)

local KeyTitle = NewText(KeyFrame, "BLESSED HUB - KEY SYSTEM", 18, White)
KeyTitle.Size = UDim2_fromOffset(400, 40)
KeyTitle.Position = UDim2_fromOffset(0, 15)
KeyTitle.Font = Enum.Font.GothamBold

local KeySub = NewText(KeyFrame, "Insira a chave de acesso para liberar o painel", 12, Gray)
KeySub.Size = UDim2_fromOffset(400, 20)
KeySub.Position = UDim2_fromOffset(0, 50)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2_fromOffset(320, 42)
KeyInput.Position = UDim2_fromOffset(40, 90)
KeyInput.BackgroundColor3 = Background
KeyInput.Text = ""
KeyInput.PlaceholderText = "Digite a Key aqui..."
KeyInput.TextColor3 = White
KeyInput.PlaceholderColor3 = Gray
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.Parent = KeyFrame
Corner(KeyInput, 8)
Stroke(KeyInput, Purple, 0.4)

local KeyButton = Instance.new("TextButton")
KeyButton.Size = UDim2_fromOffset(320, 40)
KeyButton.Position = UDim2_fromOffset(40, 150)
KeyButton.BackgroundColor3 = Purple
KeyButton.Text = "VERIFICAR KEY"
KeyButton.TextColor3 = White
KeyButton.Font = Enum.Font.GothamBold
KeyButton.TextSize = 14
KeyButton.Parent = KeyFrame
Corner(KeyButton, 8)

--========================================================
-- MAIN INTERFACE
--========================================================

local BackgroundFrame = Instance.new("Frame")
BackgroundFrame.Size = UDim2_fromScale(1, 1)
BackgroundFrame.BackgroundColor3 = Color3_fromRGB(8, 4, 14)
BackgroundFrame.BackgroundTransparency = 0.15
BackgroundFrame.Visible = false
BackgroundFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2_fromOffset(570, 48)
TopBar.Position = UDim2_fromOffset(math_floor((Camera.ViewportSize.X - 570) / 2), 20)
TopBar.BackgroundColor3 = Panel
TopBar.Visible = false
TopBar.Parent = ScreenGui
Corner(TopBar, 12)
Stroke(TopBar, Purple, 0.25, 1.5)

local TopTitle = NewText(TopBar, "BLESSED HUB - FULL EDITION", 16, White)
TopTitle.Size = UDim2_fromOffset(280, 48)
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
Main.Size = UDim2_fromOffset(850, 560)
Main.Position = UDim2_fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2_new(0.5, 0.5)
Main.BackgroundColor3 = Panel
Main.Visible = false
Main.Parent = ScreenGui
Corner(Main, 16)
Stroke(Main, Purple, 0.18, 1.5)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2_fromOffset(82, 560)
Sidebar.BackgroundColor3 = Background
Sidebar.Parent = Main
Corner(Sidebar, 16)

local SideLayout = Instance.new("UIListLayout")
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Padding = UDim.new(0, 10)
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 15)
SidePadding.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2_fromOffset(745, 535)
Content.Position = UDim2_fromOffset(95, 12)
Content.BackgroundTransparency = 1
Content.Parent = Main

local PageTitle = NewText(Content, "Mãos & Armas", 22, White)
PageTitle.Size = UDim2_fromOffset(745, 38)
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Font = Enum.Font.GothamBold

--========================================================
-- SCROLLABLE PAGES GENERATOR
--========================================================

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2_fromOffset(745, 485)
    page.Position = UDim2_fromOffset(0, 40)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Purple
    page.CanvasSize = UDim2_fromOffset(0, 800)
    page.Visible = false
    page.Parent = Content
    Pages[name] = page
    return page
end

local HandsPage = CreatePage("Mãos & Armas")
local AimPage = CreatePage("Aimbot")
local ESPPage = CreatePage("ESP & Visuals")
local CharacterPage = CreatePage("Character")
local GlobePage = CreatePage("Globe & World")
local SettingsPage = CreatePage("Settings")
HandsPage.Visible = true

local function CreateTab(icon, title, page)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(55, 50)
    button.BackgroundColor3 = Panel
    button.Text = icon
    button.TextColor3 = Gray
    button.TextSize = 20
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = Sidebar
    Corner(button, 10)

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

local DefaultTab = CreateTab("🤚", "Mãos & Armas", HandsPage)
DefaultTab.BackgroundColor3 = PurpleDark
DefaultTab.TextColor3 = White
CreateTab("🎯", "Aimbot", AimPage)
CreateTab("👁", "ESP & Visuals", ESPPage)
CreateTab("♙", "Character", CharacterPage)
CreateTab("🌐", "Globe & World", GlobePage)
CreateTab("⚙", "Settings", SettingsPage)

--========================================================
-- UI CONTROLS BUILDER
--========================================================

local function Section(parent, text, x, y)
    local label = NewText(parent, text, 15, PurpleLight)
    label.Size = UDim2_fromOffset(350, 28)
    label.Position = UDim2_fromOffset(x, y)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function Checkbox(parent, text, tableRef, key, x, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(350, 32)
    button.Position = UDim2_fromOffset(x, y)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2_fromOffset(18, 18)
    box.Position = UDim2_fromOffset(0, 7)
    box.BackgroundColor3 = Background
    box.Parent = button
    Corner(box, 4)
    Stroke(box, Purple, 0.35)

    local check = NewText(box, "✓", 13, White)
    check.Size = UDim2_fromScale(1, 1)
    check.Font = Enum.Font.GothamBold
    check.Visible = tableRef[key] or false

    local label = NewText(button, text, 13, White)
    label.Size = UDim2_fromOffset(320, 32)
    label.Position = UDim2_fromOffset(28, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left

    button.MouseButton1Click:Connect(function()
        tableRef[key] = not tableRef[key]
        check.Visible = tableRef[key]
        if callback then callback(tableRef[key]) end
    end)
end

local function Slider(parent, text, tableRef, key, minValue, maxValue, x, y, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2_fromOffset(350, 55)
    holder.Position = UDim2_fromOffset(x, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local label = NewText(holder, text, 13, White)
    label.Size = UDim2_fromOffset(280, 22)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = NewText(holder, tostring(tableRef[key]), 13, PurpleLight)
    valueLabel.Size = UDim2_fromOffset(60, 22)
    valueLabel.Position = UDim2_fromOffset(290, 0)
    valueLabel.Font = Enum.Font.GothamBold

    local bar = Instance.new("Frame")
    bar.Size = UDim2_fromOffset(350, 6)
    bar.Position = UDim2_fromOffset(0, 32)
    bar.BackgroundColor3 = Background
    bar.Parent = holder
    Corner(bar, 4)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Purple
    fill.Parent = bar
    Corner(fill, 4)

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

local function Dropdown(parent, text, tableRef, key, options, x, y)
    local holder = Instance.new("Frame")
    holder.Size = UDim2_fromOffset(350, 42)
    holder.Position = UDim2_fromOffset(x, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    NewText(holder, text, 13, White).Size = UDim2_fromOffset(130, 42)

    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(200, 30)
    button.Position = UDim2_fromOffset(150, 6)
    button.BackgroundColor3 = Background
    button.Text = tostring(tableRef[key])
    button.TextColor3 = White
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = holder
    Corner(button, 6)
    Stroke(button, Purple, 0.5)

    local index = table.find(options, tableRef[key]) or 1
    button.MouseButton1Click:Connect(function()
        index = (index % #options) + 1
        tableRef[key] = options[index]
        button.Text = tostring(options[index])
    end)
end

local function ActionButton(parent, text, color, x, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2_fromOffset(350, 38)
    button.Position = UDim2_fromOffset(x, y)
    button.BackgroundColor3 = color or Purple
    button.Text = text
    button.TextColor3 = White
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = parent

    Corner(button, 8)
    button.MouseButton1Click:Connect(callback)
    return button
end

--========================================================
-- FULL TAB CONFIGURATIONS
--========================================================

-- 1. MÃOS & ARMAS (VIEWMODEL) PAGE
Section(HandsPage, "MODIFICADOR DE POSIÇÃO (HAND OFFSET)", 0, 0)
Checkbox(HandsPage, "Ativar Modificador de Mão", Config.Hands, "Enabled", 0, 32)
Slider(HandsPage, "Posição Offset X (Esquerda / Direita)", Config.Hands, "OffsetX", -10, 10, 0, 68)
Slider(HandsPage, "Posição Offset Y (Cima / Baixo)", Config.Hands, "OffsetY", -10, 10, 0, 128)
Slider(HandsPage, "Posição Offset Z (Frente / Trás)", Config.Hands, "OffsetZ", -10, 10, 0, 188)

Section(HandsPage, "MATERIAL & PALETA DE CORES", 375, 0)
Dropdown(HandsPage, "Material da Mão", Config.Hands, "Material", {"ForceField", "Neon", "Glass", "SmoothPlastic"}, 375, 32)
Checkbox(HandsPage, "Modo Rainbow (Cores RGB)", Config.Hands, "Rainbow", 375, 80)
Slider(HandsPage, "Cor Vermelha (R)", Config.Hands, "ColorR", 0, 255, 375, 116)
Slider(HandsPage, "Cor Verde (G)", Config.Hands, "ColorG", 0, 255, 375, 176)
Slider(HandsPage, "Cor Azul (B)", Config.Hands, "ColorB", 0, 255, 375, 236)
Slider(HandsPage, "Transparência das Mãos", Config.Hands, "Transparency", 0, 10, 375, 296)

-- 2. AIMBOT PAGE
Section(AimPage, "CONFIGURAÇÕES DE MIRA E ALVO", 0, 0)
Checkbox(AimPage, "Ativar Aimbot", Config.Aimbot, "Enabled", 0, 32)
Checkbox(AimPage, "Segurar Botão Direito do Mouse", Config.Aimbot, "HoldToAim", 0, 68)
Checkbox(AimPage, "Mirar em Jogadores", Config.Aimbot, "TargetPlayers", 0, 104)
Checkbox(AimPage, "Mirar em IAs / NPCs / Zumbis", Config.Aimbot, "TargetNPCs", 0, 140)
Dropdown(AimPage, "Parte do Corpo do Alvo", Config.Aimbot, "TargetPart", {"Head", "HumanoidRootPart", "Torso"}, 0, 176)
Slider(AimPage, "Suavidade (Smoothness)", Config.Aimbot, "Smoothness", 1, 100, 0, 222)

Section(AimPage, "CÍRCULO FOV", 375, 0)
Checkbox(AimPage, "Exibir Círculo FOV", Config.Aimbot, "ShowFOV", 375, 32)
Slider(AimPage, "Raio do FOV", Config.Aimbot, "FOV", 30, 600, 375, 68)
Slider(AimPage, "FOV Cor Vermelha (R)", Config.Aimbot, "FOVColorR", 0, 255, 375, 128)
Slider(AimPage, "FOV Cor Verde (G)", Config.Aimbot, "FOVColorG", 0, 255, 375, 188)
Slider(AimPage, "FOV Cor Azul (B)", Config.Aimbot, "FOVColorB", 0, 255, 375, 248)

-- 3. ESP & VISUALS PAGE (LOTADO DE OPÇÕES DE HIGHLIGHT)
Section(ESPPage, "SISTEMA PRINCIPAL & FILTROS", 0, 0)
Checkbox(ESPPage, "Ativar Sistema ESP Geral", Config.ESP, "Enabled", 0, 32)
Checkbox(ESPPage, "Incluir Jogadores", Config.ESP, "IncludePlayers", 0, 68)
Checkbox(ESPPage, "Incluir IAs / NPCs / Zumbis", Config.ESP, "IncludeNPCs", 0, 104)
Checkbox(ESPPage, "Exibir Nome da Entidade", Config.ESP, "Name", 0, 140)
Checkbox(ESPPage, "Exibir Distância em Metros", Config.ESP, "Distance", 0, 176)
Checkbox(ESPPage, "Exibir Barra / Texto de Vida", Config.ESP, "Health", 0, 212)

Section(ESPPage, "HIGHLIGHT & CHAMS AVANÇADO", 375, 0)
Checkbox(ESPPage, "Ativar Highlight / Chams", Config.ESP, "ChamsEnabled", 375, 32)
Checkbox(ESPPage, "Wallhack Mode (Always On Top)", Config.ESP, "ChamsAlwaysOnTop", 375, 68)
Checkbox(ESPPage, "Rainbow Highlights", Config.ESP, "ChamsRainbow", 375, 104)

Slider(ESPPage, "Preenchimento R (Fill R)", Config.ESP, "ChamsFillR", 0, 255, 375, 140)
Slider(ESPPage, "Preenchimento G (Fill G)", Config.ESP, "ChamsFillG", 0, 255, 375, 200)
Slider(ESPPage, "Preenchimento B (Fill B)", Config.ESP, "ChamsFillB", 0, 255, 375, 260)
Slider(ESPPage, "Transparência do Preenchimento", Config.ESP, "ChamsFillTransparency", 0, 10, 375, 320)

Slider(ESPPage, "Contorno R (Outline R)", Config.ESP, "ChamsOutlineR", 0, 255, 375, 380)
Slider(ESPPage, "Contorno G (Outline G)", Config.ESP, "ChamsOutlineG", 0, 255, 375, 440)
Slider(ESPPage, "Contorno B (Outline B)", Config.ESP, "ChamsOutlineB", 0, 255, 375, 500)
Slider(ESPPage, "Transparência do Contorno", Config.ESP, "ChamsOutlineTransparency", 0, 10, 375, 560)

Section(ESPPage, "CAIXA 3D & PONTO NA CABEÇA", 0, 260)
Checkbox(ESPPage, "Ativar Caixas 3D (3D Box)", Config.ESP, "Box3D", 0, 292)
Slider(ESPPage, "Caixa 3D Cor Vermelha (R)", Config.ESP, "BoxColorR", 0, 255, 0, 328)
Slider(ESPPage, "Caixa 3D Cor Verde (G)", Config.ESP, "BoxColorG", 0, 255, 0, 388)
Slider(ESPPage, "Caixa 3D Cor Azul (B)", Config.ESP, "BoxColorB", 0, 255, 0, 448)
Slider(ESPPage, "Transparência da Caixa 3D", Config.ESP, "BoxTransparency", 0, 10, 0, 508)

Checkbox(ESPPage, "Ativar Ponto na Cabeça (Head Dot)", Config.ESP, "HeadDot", 0, 568)
Slider(ESPPage, "Tamanho do Ponto da Cabeça", Config.ESP, "HeadDotSize", 1, 10, 0, 604)

-- 4. CHARACTER PAGE
Section(CharacterPage, "MOVIMENTO & CHARACTER", 0, 0)
Checkbox(CharacterPage, "Velocidade Personalizada", Config.Character, "SpeedEnabled", 0, 32)
Slider(CharacterPage, "Velocidade (WalkSpeed)", Config.Character, "Speed", 16, 250, 0, 68)
Checkbox(CharacterPage, "Modo Voo (Fly Mode)", Config.Character, "Fly", 0, 128)
Slider(CharacterPage, "Velocidade de Voo", Config.Character, "FlySpeed", 10, 300, 0, 164)
Checkbox(CharacterPage, "Noclip (Atravessar Paredes)", Config.Character, "Noclip", 0, 224)
Checkbox(CharacterPage, "Pulo Infinito (Infinite Jump)", Config.Character, "InfiniteJump", 0, 260)
Checkbox(CharacterPage, "SpinBot (Girar Personagem)", Config.Character, "SpinBot", 0, 296)
Slider(CharacterPage, "Velocidade do SpinBot", Config.Character, "SpinSpeed", 10, 500, 0, 332)

ActionButton(CharacterPage, "Click Teleport (Para a posição do Mouse)", PurpleDark, 0, 400, function()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = mouse.Hit + Vector3_new(0, 3, 0)
        end
    end
end)

-- 5. GLOBE & WORLD PAGE
Section(GlobePage, "VISUAL MUNDO & ILUMINAÇÃO", 0, 0)
Checkbox(GlobePage, "Travar Câmera FOV (120)", Config.Globe, "FixedFOVEnabled", 0, 32)
Slider(GlobePage, "Ajustar Gravidade do Jogo", Config.Globe, "Gravity", 0, 300, 0, 68, function(val)
    Workspace.Gravity = val
end)

Section(GlobePage, "EXPANDIDOR DE HITBOX (HITBOX EXPANDER)", 0, 140)
Checkbox(GlobePage, "Ativar Expansor de Hitbox", Config.Globe, "HitboxEnabled", 0, 172)
Dropdown(GlobePage, "Alvo do Expansor", Config.Globe, "HitboxTarget", {"Head", "HumanoidRootPart"}, 0, 208)
Slider(GlobePage, "Tamanho da Hitbox", Config.Globe, "HitboxSize", 2, 50, 0, 254)
Slider(GlobePage, "Transparência da Hitbox", Config.Globe, "HitboxTransparency", 0, 10, 0, 314)
Slider(GlobePage, "Alcance Máximo em Metros", Config.Globe, "MaxDistance", 50, 500, 0, 374)

Section(GlobePage, "MIRA PERSONALIZADA (CROSSHAIR)", 375, 0)
Checkbox(GlobePage, "Ativar Mira Personalizada", Config.Crosshair, "Enabled", 375, 32)
Checkbox(GlobePage, "Mira Rainbow RGB", Config.Crosshair, "Rainbow", 375, 68)
Slider(GlobePage, "Tamanho da Mira", Config.Crosshair, "Size", 2, 30, 375, 104)
Slider(GlobePage, "Abertura Central (Gap)", Config.Crosshair, "Gap", 0, 20, 375, 164)
Slider(GlobePage, "Espessura da Linha", Config.Crosshair, "Thickness", 1, 6, 375, 224)
Slider(GlobePage, "Mira Cor Vermelha (R)", Config.Crosshair, "ColorR", 0, 255, 375, 284)
Slider(GlobePage, "Mira Cor Verde (G)", Config.Crosshair, "ColorG", 0, 255, 375, 344)
Slider(GlobePage, "Mira Cor Azul (B)", Config.Crosshair, "ColorB", 0, 255, 375, 404)

-- 6. SETTINGS PAGE
Section(SettingsPage, "GERENCIADOR & TECLAS", 0, 0)
ActionButton(SettingsPage, "FECHAR HUB", Red, 0, 32, function()
    Config.UI.Open = false
    Main.Visible = false
    TopBar.Visible = false
    BackgroundFrame.Visible = false
end)

--========================================================
-- KEY VALIDATION SYSTEM
--========================================================

KeyButton.MouseButton1Click:Connect(function()
    if KeyInput.Text == SYSTEM_KEY then
        KeyVerified = true
        KeyFrame:Destroy()
        
        BackgroundFrame.Visible = true
        TopBar.Visible = true
        Main.Visible = true
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "KEY INCORRETA! Tente novamente."
        KeyInput.PlaceholderColor3 = Red
    end
end)

--========================================================
-- TOGGLE UI KEYBIND (F4)
--========================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.UI.ToggleKey then
        Config.UI.Open = not Config.UI.Open
        
        if KeyVerified then
            Main.Visible = Config.UI.Open
            TopBar.Visible = Config.UI.Open
            BackgroundFrame.Visible = Config.UI.Open
        else
            KeyFrame.Visible = Config.UI.Open
        end
    end
end)

--========================================================
-- INFINITE JUMP
--========================================================

UserInputService.JumpRequest:Connect(function()
    if Config.Character.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

--========================================================
-- ADVANCED ESP & HIGHLIGHT ENGINE
--========================================================

local EntityCache = {}

local function ClearEntityESP(model)
    if EntityCache[model] then
        for _, obj in pairs(EntityCache[model]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        EntityCache[model] = nil
    end
end

local function GetEntityRoot(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") 
        or model:FindFirstChild("Torso") 
        or model:FindFirstChild("UpperTorso") 
        or model.PrimaryPart
end

local function IsValidEntity(model)
    if not model or not model:IsA("Model") or model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    local root = GetEntityRoot(model)
    if hum and hum.Health > 0 and root then
        return true
    end
    return false
end

local function SetupEntityESP(model)
    if EntityCache[model] or not IsValidEntity(model) then return end

    local player = Players:GetPlayerFromCharacter(model)
    local isPlayer = player ~= nil

    local root = GetEntityRoot(model)
    local head = model:FindFirstChild("Head") or root
    local hum = model:FindFirstChildWhichIsA("Humanoid")

    if not root or not hum then return end

    local data = {
        Model = model,
        Root = root,
        Head = head,
        Humanoid = hum,
        IsPlayer = isPlayer,
        Name = isPlayer and player.DisplayName or model.Name
    }

    -- Highlight / Chams
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.Enabled = false
    highlight.Parent = model
    data.Highlight = highlight

    -- 3D Box
    local box3d = Instance.new("BoxHandleAdornment")
    box3d.Adornee = root
    box3d.Size = Vector3_new(4, 6, 2)
    box3d.AlwaysOnTop = true
    box3d.Visible = false
    box3d.Parent = root
    data.Box3D = box3d

    -- Head Dot
    if head then
        local headDot = Instance.new("SphereHandleAdornment")
        headDot.Adornee = head
        headDot.Radius = 0.5
        headDot.Color3 = PurpleLight
        headDot.AlwaysOnTop = true
        headDot.Visible = false
        headDot.Parent = head
        data.HeadDot = headDot

        -- Billboard Info (Nome, Distância, Vida)
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2_fromOffset(200, 50)
        billboard.StudsOffset = Vector3_new(0, 3.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Enabled = false
        billboard.Parent = head

        local infoLabel = NewText(billboard, "", 12, White)
        infoLabel.Size = UDim2_fromScale(1, 1)
        infoLabel.Font = Enum.Font.GothamBold
        data.Billboard = billboard
        data.InfoLabel = infoLabel
    end

    EntityCache[model] = data

    hum.Died:Connect(function()
        ClearEntityESP(model)
    end)
end

-- Varredura e Atualização de Entidades
task.spawn(function()
    while true do
        task.wait(0.1)
        local camPos = Camera.CFrame.Position

        for model, data in pairs(EntityCache) do
            if not model or not model.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
                ClearEntityESP(model)
            else
                local isPlayer = data.IsPlayer
                local allowed = Config.ESP.Enabled and ((isPlayer and Config.ESP.IncludePlayers) or (not isPlayer and Config.ESP.IncludeNPCs))

                if allowed then
                    local dist = math_floor((camPos - data.Root.Position).Magnitude)

                    -- Highlight Chams Update
                    if data.Highlight then
                        data.Highlight.Enabled = Config.ESP.ChamsEnabled
                        if Config.ESP.ChamsEnabled then
                            local fillColor = Config.ESP.ChamsRainbow and Color3_fromHSV((tick() % 5) / 5, 1, 1)
                                              or Color3_fromRGB(Config.ESP.ChamsFillR, Config.ESP.ChamsFillG, Config.ESP.ChamsFillB)
                            local outlineColor = Color3_fromRGB(Config.ESP.ChamsOutlineR, Config.ESP.ChamsOutlineG, Config.ESP.ChamsOutlineB)

                            data.Highlight.FillColor = fillColor
                            data.Highlight.FillTransparency = Config.ESP.ChamsFillTransparency / 10
                            data.Highlight.OutlineColor = outlineColor
                            data.Highlight.OutlineTransparency = Config.ESP.ChamsOutlineTransparency / 10
                            data.Highlight.DepthMode = Config.ESP.ChamsAlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                        end
                    end

                    -- 3D Box Update
                    if data.Box3D then
                        data.Box3D.Visible = Config.ESP.Box3D
                        if Config.ESP.Box3D then
                            data.Box3D.Color3 = Color3_fromRGB(Config.ESP.BoxColorR, Config.ESP.BoxColorG, Config.ESP.BoxColorB)
                            data.Box3D.Transparency = Config.ESP.BoxTransparency / 10
                        end
                    end

                    -- Head Dot Update
                    if data.HeadDot then
                        data.HeadDot.Visible = Config.ESP.HeadDot
                        if Config.ESP.HeadDot then
                            data.HeadDot.Radius = Config.ESP.HeadDotSize / 5
                        end
                    end

                    -- Info Billboard
                    if data.Billboard and data.InfoLabel then
                        local showText = Config.ESP.Name or Config.ESP.Distance or Config.ESP.Health
                        data.Billboard.Enabled = showText
                        if showText then
                            local text = ""
                            if Config.ESP.Name then text = text .. data.Name .. "\n" end
                            if Config.ESP.Distance then text = text .. "[" .. tostring(dist) .. "m] " end
                            if Config.ESP.Health then
                                local hp = math_floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100)
                                text = text .. "(" .. tostring(hp) .. "% HP)"
                            end
                            data.InfoLabel.Text = text
                        end
                    end
                else
                    if data.Highlight then data.Highlight.Enabled = false end
                    if data.Box3D then data.Box3D.Visible = false end
                    if data.HeadDot then data.HeadDot.Visible = false end
                    if data.Billboard then data.Billboard.Enabled = false end
                end
            end
        end

        -- Scanner de novos modelos no mapa
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and IsValidEntity(obj) then
                SetupEntityESP(obj)
            end
        end
    end
end)

--========================================================
-- HAND / VIEWMODEL MODIFIER ENGINE
--========================================================

local function ApplyHandModifiers(part, color)
    if part and part:IsA("BasePart") then
        local mat = Enum.Material[Config.Hands.Material] or Enum.Material.ForceField
        part.Material = mat
        part.Color = color
        part.Transparency = Config.Hands.Transparency / 10
    end
end

RunService.RenderStepped:Connect(function()
    if Config.Hands.Enabled then
        local color = Config.Hands.Rainbow and Color3_fromHSV((tick() % 5) / 5, 1, 1) 
                      or Color3_fromRGB(Config.Hands.ColorR, Config.Hands.ColorG, Config.Hands.ColorB)

        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") or child:IsA("Accoutrement") then
                for _, part in ipairs(child:GetDescendants()) do
                    if part:IsA("BasePart") then
                        ApplyHandModifiers(part, color)
                    end
                end
            end
        end

        local char = LocalPlayer.Character
        if char then
            for _, partName in ipairs({"RightArm", "LeftArm", "Right UpperArm", "Left UpperArm", "Right Hand", "Left Hand"}) do
                local part = char:FindFirstChild(partName)
                if part then ApplyHandModifiers(part, color) end
            end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                ApplyHandModifiers(tool.Handle, color)
            end
        end
    end

    -- CROSSHAIR RENDER
    if Config.Crosshair.Enabled then
        local center = UserInputService:GetMouseLocation()
        local color = Config.Crosshair.Rainbow and Color3_fromHSV((tick() % 5) / 5, 1, 1) 
                      or Color3_fromRGB(Config.Crosshair.ColorR, Config.Crosshair.ColorG, Config.Crosshair.ColorB)
        local sz, gap, th = Config.Crosshair.Size, Config.Crosshair.Gap, Config.Crosshair.Thickness

        CH_Top.Size = UDim2_fromOffset(th, sz); CH_Top.Position = UDim2_fromOffset(center.X - (th/2), center.Y - gap - sz); CH_Top.BackgroundColor3 = color; CH_Top.Visible = true
        CH_Bottom.Size = UDim2_fromOffset(th, sz); CH_Bottom.Position = UDim2_fromOffset(center.X - (th/2), center.Y + gap); CH_Bottom.BackgroundColor3 = color; CH_Bottom.Visible = true
        CH_Left.Size = UDim2_fromOffset(sz, th); CH_Left.Position = UDim2_fromOffset(center.X - gap - sz, center.Y - (th/2)); CH_Left.BackgroundColor3 = color; CH_Left.Visible = true
        CH_Right.Size = UDim2_fromOffset(sz, th); CH_Right.Position = UDim2_fromOffset(center.X + gap, center.Y - (th/2)); CH_Right.BackgroundColor3 = color; CH_Right.Visible = true
    else
        CH_Top.Visible = false; CH_Bottom.Visible = false; CH_Left.Visible = false; CH_Right.Visible = false
    end
end)

--========================================================
-- CAMERA FOV OVERRIDE
--========================================================

RunService:BindToRenderStep("FixedFOV", Enum.RenderPriority.Camera.Value + 1, function()
    if Config.Globe.FixedFOVEnabled then
        Camera.FieldOfView = Config.Globe.FixedFOV
    end
end)

--========================================================
-- PERFORMANCE MONITOR
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
