--girls hmu

-- Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

-- Config
local Config = {
    RapidFire = true,
    AutoFire = true,
    FireRate = 0.01,
    FlySpeed = 18,
    FlyEnabled = false,
    ESP = true,
    CamlockEnabled = false,
    CamlockSmoothness = 0.92,
    UIVisible = false,
    ShootFromSky = false,
    SpreadRapidFire = false,
    SpreadCount = 5,
    AutoStomp = false,
    StompRange = 10,
    WalkSpeed = 16,
    Keybinds = {},
    MobileAutoFire = false,
    Whitelist = {},
    SilentAim = false,
    FOV = 80,
    ShowFOV = true,
    KillAll = false,
    Aimbot = false,
    NoRecoil = false,
    InfiniteJump = false,
    SpeedHack = false,
    Wallhack = false,
    Noclip = false,
    AutoFarm = false,
    AntiAFK = false,
}

-- Runtime
local mouse = LocalPlayer
local OriginalValues = {}
local mouseDown = false
local touchDown = false
local camlockTarget = nil
local flying = false
local velocity, gyro = nil, nil
local lastStompTime = 0
local stompCooldown = 0.5
local isMobile = UserInputService.TouchEnabled
local password = "33333"
local authenticated = false
local originalWalkSpeed = 16
local FOVCircle = nil
local currentTab = "Rapid"
local wallhackParts = {}
local antiAFKConnection = nil
local noclipLoop = nil
local infiniteJumpConnection = nil

-- Typing guard
local isTyping = false
local function markTyping(state) isTyping = state end

-- ---------- Mobile Touch Controls ----------
local touchStartPos = nil
local touchStartTime = 0

if isMobile then
    local TouchOverlay = Instance.new("Frame")
    TouchOverlay.Size = UDim2.new(1, 0, 1, 0)
    TouchOverlay.Position = UDim2.new(0, 0, 0, 0)
    TouchOverlay.BackgroundTransparency = 1
    TouchOverlay.Active = true
    TouchOverlay.Parent = game.CoreGui
    TouchOverlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    TouchOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchDown = true
            touchStartPos = input.Position
            touchStartTime = tick()
        end
    end)
    
    TouchOverlay.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchDown = false
            touchStartPos = nil
        end
    end)
end

-- ---------- Password Screen ----------
local PasswordScreen = Instance.new("ScreenGui")
PasswordScreen.Name = "PasswordScreen"
PasswordScreen.ResetOnSpawn = false
PasswordScreen.Parent = game.CoreGui
PasswordScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local PasswordFrame = Instance.new("Frame", PasswordScreen)
PasswordFrame.Size = UDim2.new(0, isMobile and 350 or 300, 0, isMobile and 250 or 200)
PasswordFrame.Position = UDim2.new(0.5, isMobile and -175 or -150, 0.5, isMobile and -125 or -100)
PasswordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
PasswordFrame.BorderSizePixel = 0

local PasswordCorner = Instance.new("UICorner", PasswordFrame)
PasswordCorner.CornerRadius = UDim.new(0, 12)

local PasswordTitle = Instance.new("TextLabel", PasswordFrame)
PasswordTitle.Size = UDim2.new(1, 0, 0, isMobile and 50 or 40)
PasswordTitle.Position = UDim2.new(0, 0, 0, 10)
PasswordTitle.BackgroundTransparency = 1
PasswordTitle.Text = "Enter Password"
PasswordTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
PasswordTitle.Font = Enum.Font.GothamBold
PasswordTitle.TextSize = isMobile and 24 or 20

local PasswordInput = Instance.new("TextBox", PasswordFrame)
PasswordInput.Size = UDim2.new(0.8, 0, 0, isMobile and 50 or 40)
PasswordInput.Position = UDim2.new(0.1, 0, 0.3, 0)
PasswordInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PasswordInput.TextColor3 = Color3.fromRGB(240, 240, 240)
PasswordInput.Font = Enum.Font.Gotham
PasswordInput.TextSize = isMobile and 22 or 18
PasswordInput.PlaceholderText = "Password"
PasswordInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
PasswordInput.ClearTextOnFocus = false
PasswordInput.TextScaled = isMobile

local PasswordInputCorner = Instance.new("UICorner", PasswordInput)
PasswordInputCorner.CornerRadius = UDim.new(0, 8)

local SubmitButton = Instance.new("TextButton", PasswordFrame)
SubmitButton.Size = UDim2.new(0.6, 0, 0, isMobile and 50 or 40)
SubmitButton.Position = UDim2.new(0.2, 0, 0.6, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(70, 180, 130)
SubmitButton.TextColor3 = Color3.fromRGB(240, 240, 240)
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.TextSize = isMobile and 22 or 18
SubmitButton.Text = "Submit"
SubmitButton.TextScaled = isMobile

local SubmitCorner = Instance.new("UICorner", SubmitButton)
SubmitCorner.CornerRadius = UDim.new(0, 8)

local ErrorLabel = Instance.new("TextLabel", PasswordFrame)
ErrorLabel.Size = UDim2.new(0.8, 0, 0, isMobile and 30 or 20)
ErrorLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
ErrorLabel.BackgroundTransparency = 1
ErrorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
ErrorLabel.Font = Enum.Font.Gotham
ErrorLabel.TextSize = isMobile and 16 or 14
ErrorLabel.Text = ""
ErrorLabel.Visible = false
ErrorLabel.TextScaled = isMobile

SubmitButton.MouseButton1Click:Connect(function()
    if PasswordInput.Text == password then
        authenticated = true
        PasswordScreen.Enabled = false
        HubFrame.Visible = true
        Config.UIVisible = true
    else
        ErrorLabel.Text = "Incorrect password!"
        ErrorLabel.Visible = true
        task.wait(2)
        ErrorLabel.Visible = false
    end
end)

PasswordInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and PasswordInput.Text == password then
        authenticated = true
        PasswordScreen.Enabled = false
        HubFrame.Visible = true
        Config.UIVisible = true
    elseif enterPressed then
        ErrorLabel.Text = "Incorrect password!"
        ErrorLabel.Visible = true
        task.wait(2)
        ErrorLabel.Visible = false
    end
end)

-- ---------- GUI SETUP (Modern Tabbed UI) ----------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "hoodkiller_v125"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local HubFrame = Instance.new("Frame", ScreenGui)
HubFrame.Size = UDim2.new(0, isMobile and 400 or 520, 0, isMobile and 600 or 700)
HubFrame.Position = UDim2.new(0, 12, 0, 12)
HubFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
HubFrame.BorderSizePixel = 0
HubFrame.Active = true
HubFrame.Name = "HubFrame"
HubFrame.Visible = false

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 46)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(46, 46, 71))
}
gradient.Rotation = 90
gradient.Parent = HubFrame

local HubUICorner = Instance.new("UICorner", HubFrame)
HubUICorner.CornerRadius = UDim.new(0,12)

local TitleBar = Instance.new("Frame", HubFrame)
TitleBar.Size = UDim2.new(1,0,0,isMobile and 44 or 36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundTransparency = 1

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,-72,1,0)
TitleLabel.Position = UDim2.new(0,12,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "hoodkiller v1.25"
TitleLabel.TextColor3 = Color3.fromRGB(240,240,240)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = isMobile and 18 or 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.TextScaled = isMobile

local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.new(0, isMobile and 32 or 24, 0, isMobile and 32 or 24)
CloseButton.Position = UDim2.new(1, isMobile and -36 or -32, 0.5, isMobile and -16 or -12)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = isMobile and 18 or 14
CloseButton.ZIndex = 2
CloseButton.TextScaled = isMobile

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(1, 0)

CloseButton.MouseButton1Click:Connect(function()
    Config.UIVisible = false
    HubFrame.Visible = false
end)

local ResizeHandle = Instance.new("Frame", HubFrame)
ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Visible = not isMobile

local ResizeCorner = Instance.new("UICorner", ResizeHandle)
ResizeCorner.CornerRadius = UDim.new(0, 4)

local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, isMobile and 50 or 40, 0, isMobile and 50 or 40)
OpenButton.Position = UDim2.new(0, 12, 0, 80)
OpenButton.BackgroundColor3 = Color3.fromRGB(54, 179, 126)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "+"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = isMobile and 28 or 24
OpenButton.Visible = false
OpenButton.TextScaled = isMobile

local OpenCorner = Instance.new("UICorner", OpenButton)
OpenCorner.CornerRadius = UDim.new(1, 0)

OpenButton.MouseButton1Click:Connect(function()
    Config.UIVisible = true
    HubFrame.Visible = true
    OpenButton.Visible = false
end)

HubFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    OpenButton.Visible = not HubFrame.Visible
end)

-- Tab Buttons
local TabContainer = Instance.new("Frame", HubFrame)
TabContainer.Size = UDim2.new(1, -24, 0, isMobile and 40 or 30)
TabContainer.Position = UDim2.new(0, 12, 0, 40)
TabContainer.BackgroundTransparency = 1

local Tabs = {"Rapid", "Visuals", "Misc", "Whitelist"}
local TabButtons = {}

for i, tabName in ipairs(Tabs) do
    local tabButton = Instance.new("TextButton", TabContainer)
    tabButton.Size = UDim2.new(0.25, -4, 1, 0)
    tabButton.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = isMobile and 14 or 12
    tabButton.TextScaled = isMobile
    
    local tabCorner = Instance.new("UICorner", tabButton)
    tabCorner.CornerRadius = UDim.new(0, 6)
    
    tabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        updateTabDisplay()
    end)
    
    TabButtons[tabName] = tabButton
end

-- Content Frame
local Content = Instance.new("ScrollingFrame", HubFrame)
Content.Size = UDim2.new(1,-24,1,-90)
Content.Position = UDim2.new(0,12,0,80)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = isMobile and 12 or 6
Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.VerticalScrollBarInset = Enum.ScrollBarInset.Always
Content.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
Content.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Content.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
Content.ScrollBarImageTransparency = isMobile and 0.3 or 0.5

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.Padding = UDim.new(0, isMobile and 12 or 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)

-- Utility: CreateToggle
local function createToggle(name, layoutOrder, initial, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, isMobile and 50 or 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 0

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.45,0,1,0)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = isMobile and 18 or 14
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = isMobile

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.35,0,0.72,0)
    btn.Position = UDim2.new(0.5,0,0.14,0)
    btn.BackgroundColor3 = initial and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
    btn.BorderSizePixel = 0
    btn.Text = initial and "ON" or "OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = isMobile and 16 or 13
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.TextScaled = isMobile
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0,8)

    local keyBox = Instance.new("TextBox", container)
    keyBox.Size = UDim2.new(0.12,0,0.72,0)
    keyBox.Position = UDim2.new(0.86,0,0.14,0)
    keyBox.ClearTextOnFocus = false
    keyBox.Text = ""
    keyBox.PlaceholderText = ""
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = isMobile and 14 or 13
    keyBox.TextColor3 = Color3.fromRGB(20,20,20)
    keyBox.BackgroundColor3 = Color3.fromRGB(240,240,240)
    keyBox.BorderSizePixel = 0
    keyBox.TextScaled = isMobile
    local kbCorner = Instance.new("UICorner", keyBox)
    kbCorner.CornerRadius = UDim.new(0,6)

    keyBox.Focused:Connect(function() markTyping(true) end)
    keyBox.FocusLost:Connect(function()
        local txt = tostring(keyBox.Text or ""):gsub("%s+",""):upper()
        if txt == "" then
            Config.Keybinds[name] = nil
            keyBox.Text = ""
        else
            Config.Keybinds[name] = txt
            keyBox.Text = txt
        end
        markTyping(false)
    end)

    btn.MouseButton1Click:Connect(function()
        initial = not initial
        btn.BackgroundColor3 = initial and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
        btn.Text = initial and "ON" or "OFF"
        pcall(callback, initial)
    end)

    return container, btn, keyBox
end

-- Utility: CreateTextBox
local function createTextBox(labelText, layoutOrder, initialValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, isMobile and 50 or 38)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 0

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.55,0,1,0)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = isMobile and 18 or 13
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = isMobile

    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(0.35,0,0.7,0)
    box.Position = UDim2.new(0.63,0,0.15,0)
    box.Text = tostring(initialValue)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = isMobile and 16 or 13
    box.TextColor3 = Color3.fromRGB(20,20,20)
    box.BackgroundColor3 = Color3.fromRGB(240,240,240)
    box.TextScaled = isMobile
    local corner = Instance.new("UICorner", box)
    corner.CornerRadius = UDim.new(0,6)

    box.Focused:Connect(function() markTyping(true) end)
    box.FocusLost:Connect(function(enter)
        local v = tonumber(box.Text)
        if v then pcall(callback, v) else box.Text = tostring(initialValue) end
        markTyping(false)
    end)
    return container, box
end

-- Utility: Create Section Header
local function createSection(title, layoutOrder)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, isMobile and 40 or 30)
    section.BackgroundTransparency = 1
    section.Text = title
    section.TextColor3 = Color3.fromRGB(200, 200, 220)
    section.Font = Enum.Font.GothamBold
    section.TextSize = isMobile and 20 or 16
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.LayoutOrder = layoutOrder or 0
    section.TextScaled = isMobile
    return section
end

-- Create all UI elements but organize by tabs
local rapidElements = {}
local visualsElements = {}
local miscElements = {}
local whitelistElements = {}

-- Rapid Tab Elements
local y = 1
rapidElements[#rapidElements+1] = createSection("RAPID FIRES", y); y = y + 1

local rfContainer, rfBtn, rfKeyBox = createToggle("RapidFire", y, Config.RapidFire, function(v) Config.RapidFire = v end)
rapidElements[#rapidElements+1] = rfContainer; y = y + 1

local afContainer, afBtn, afKeyBox = createToggle("AutoFire", y, Config.AutoFire, function(v) Config.AutoFire = v end)
rapidElements[#rapidElements+1] = afContainer; y = y + 1

local skyContainer, skyBtn, skyKeyBox = createToggle("Shoot from Sky", y, Config.ShootFromSky, function(v) Config.ShootFromSky = v end)
rapidElements[#rapidElements+1] = skyContainer; y = y + 1

local spreadContainer, spreadBtn, spreadKeyBox = createToggle("Spread Rapid Fire", y, Config.SpreadRapidFire, function(v) Config.SpreadRapidFire = v end)
rapidElements[#rapidElements+1] = spreadContainer; y = y + 1

local frCont, frBox = createTextBox("FireRate", y, Config.FireRate, function(v) Config.FireRate = v end)
rapidElements[#rapidElements+1] = frCont; y = y + 1

local scCont, scBox = createTextBox("Spread Count", y, Config.SpreadCount, function(v) Config.SpreadCount = math.max(1, math.floor(v)) end)
rapidElements[#rapidElements+1] = scCont; y = y + 1

if isMobile then
    local mobileAFContainer, mobileAFBtn, mobileAFKeyBox = createToggle("Mobile AutoFire", y, Config.MobileAutoFire, function(v) Config.MobileAutoFire = v end)
    rapidElements[#rapidElements+1] = mobileAFContainer; y = y + 1
end

-- Visuals Tab Elements
y = 1
visualsElements[#visualsElements+1] = createSection("VISUALS", y); y = y + 1

local espContainer, espBtn, espKeyBox = createToggle("ESP", y, Config.ESP, function(v)
    if v then setESPEnabled(true) else setESPEnabled(false) end
end)
visualsElements[#visualsElements+1] = espContainer; y = y + 1

local wallhackContainer, wallhackBtn, wallhackKeyBox = createToggle("Wallhack", y, Config.Wallhack, function(v) 
    Config.Wallhack = v 
    setWallhackEnabled(v)
end)
visualsElements[#visualsElements+1] = wallhackContainer; y = y + 1

local silentAimContainer, silentAimBtn, silentAimKeyBox = createToggle("Silent Aim", y, Config.SilentAim, function(v) 
    Config.SilentAim = v 
    updateFOVCircle()
end)
visualsElements[#visualsElements+1] = silentAimContainer; y = y + 1

local fovContainer, fovBox = createTextBox("FOV Size", y, Config.FOV, function(v) 
    Config.FOV = math.max(1, v)
    updateFOVCircle()
end)
visualsElements[#visualsElements+1] = fovContainer; y = y + 1

local showFOVContainer, showFOVBtn, showFOVKeyBox = createToggle("Show FOV", y, Config.ShowFOV, function(v) 
    Config.ShowFOV = v 
    updateFOVCircle()
end)
visualsElements[#visualsElements+1] = showFOVContainer; y = y + 1

-- Misc Tab Elements
y = 1
miscElements[#miscElements+1] = createSection("MISC", y); y = y + 1

local flyContainer, flyBtn, flyKeyBox = createToggle("Fly", y, Config.FlyEnabled, function(v) Config.FlyEnabled = v; flyEnabledChanged(v) end)
miscElements[#miscElements+1] = flyContainer; y = y + 1

local fsCont, fsBox = createTextBox("Fly Speed", y, Config.FlySpeed, function(v) Config.FlySpeed = v end)
miscElements[#miscElements+1] = fsCont; y = y + 1

local camContainer, camBtn, camKeyBox = createToggle("Camlock", y, Config.CamlockEnabled, function(v)
    Config.CamlockEnabled = v
    if Config.CamlockEnabled then
        local function getClosestLookedAtPlayer()
            local closestPlayer, closestDistance = nil, math.huge
            local camPos = Camera.CFrame.Position
            local lookVec = Camera.CFrame.LookVector
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
                    local targetPos = plr.Character.HumanoidRootPart.Position
                    local toTarget = (targetPos - camPos)
                    local dist = toTarget.Magnitude
                    if dist > 0 then
                        local dir = toTarget.Unit
                        local dot = lookVec:Dot(dir)
                        local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                        if angle <= 18 and dist < closestDistance then
                            closestDistance = dist
                            closestPlayer = plr
                        end
                    end
                end
            end
            return closestPlayer
        end
        camlockTarget = getClosestLookedAtPlayer()
        if not camlockTarget then
            Config.CamlockEnabled = false
            camBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            camBtn.Text = "OFF"
        end
    else
        camlockTarget = nil
    end
end)
miscElements[#miscElements+1] = camContainer; y = y + 1

local csCont, csBox = createTextBox("Camlock Smoothness", y, Config.CamlockSmoothness, function(v) Config.CamlockSmoothness = math.clamp(v,0,1) end)
miscElements[#miscElements+1] = csCont; y = y + 1

local stompContainer, stompBtn, stompKeyBox = createToggle("Auto Stomp", y, Config.AutoStomp, function(v) Config.AutoStomp = v end)
miscElements[#miscElements+1] = stompContainer; y = y + 1

local srCont, srBox = createTextBox("Stomp Range", y, Config.StompRange, function(v) Config.StompRange = math.max(1, v) end)
miscElements[#miscElements+1] = srCont; y = y + 1

local wsCont, wsBox = createTextBox("Walk Speed", y, Config.WalkSpeed, function(v) 
    Config.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
miscElements[#miscElements+1] = wsCont; y = y + 1

local killAllContainer, killAllBtn, killAllKeyBox = createToggle("Kill All", y, Config.KillAll, function(v) 
    Config.KillAll = v 
end)
miscElements[#miscElements+1] = killAllContainer; y = y + 1

local aimbotContainer, aimbotBtn, aimbotKeyBox = createToggle("Aimbot", y, Config.Aimbot, function(v) 
    Config.Aimbot = v 
end)
miscElements[#miscElements+1] = aimbotContainer; y = y + 1

local noRecoilContainer, noRecoilBtn, noRecoilKeyBox = createToggle("No Recoil", y, Config.NoRecoil, function(v) 
    Config.NoRecoil = v 
end)
miscElements[#miscElements+1] = noRecoilContainer; y = y + 1

local infJumpContainer, infJumpBtn, infJumpKeyBox = createToggle("Infinite Jump", y, Config.InfiniteJump, function(v) 
    Config.InfiniteJump = v 
    setInfiniteJumpEnabled(v)
end)
miscElements[#miscElements+1] = infJumpContainer; y = y + 1

local speedHackContainer, speedHackBtn, speedHackKeyBox = createToggle("Speed Hack", y, Config.SpeedHack, function(v) 
    Config.SpeedHack = v 
    if v then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed * 1.5
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        end
    end
end)
miscElements[#miscElements+1] = speedHackContainer; y = y + 1

local noclipContainer, noclipBtn, noclipKeyBox = createToggle("Noclip", y, Config.Noclip, function(v) 
    Config.Noclip = v 
    setNoclipEnabled(v)
end)
miscElements[#miscElements+1] = noclipContainer; y = y + 1

local autoFarmContainer, autoFarmBtn, autoFarmKeyBox = createToggle("Auto Farm", y, Config.AutoFarm, function(v) 
    Config.AutoFarm = v 
end)
miscElements[#miscElements+1] = autoFarmContainer; y = y + 1

local antiAFKContainer, antiAFKBtn, antiAFKKeyBox = createToggle("Anti AFK", y, Config.AntiAFK, function(v) 
    Config.AntiAFK = v 
    setAntiAFKEnabled(v)
end)
miscElements[#miscElements+1] = antiAFKContainer; y = y + 1

-- Whitelist Tab Elements
y = 1
whitelistElements[#whitelistElements+1] = createSection("WHITELIST", y); y = y + 1

local whitelistContainer = Instance.new("Frame")
whitelistContainer.Size = UDim2.new(1, 0, 0, isMobile and 250 or 180)
whitelistContainer.BackgroundTransparency = 1
whitelistContainer.LayoutOrder = y
y = y + 1

local whitelistScroll = Instance.new("ScrollingFrame", whitelistContainer)
whitelistScroll.Size = UDim2.new(1, 0, 0, isMobile and 180 or 120)
whitelistScroll.Position = UDim2.new(0, 0, 0, 0)
whitelistScroll.BackgroundTransparency = 1
whitelistScroll.ScrollBarThickness = isMobile and 14 or 8
whitelistScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
whitelistScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
whitelistScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
whitelistScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
whitelistScroll.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
whitelistScroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
whitelistScroll.ScrollBarImageTransparency = isMobile and 0.2 or 0.5

local whitelistLayout = Instance.new("UIListLayout", whitelistScroll)
whitelistLayout.Padding = UDim.new(0, isMobile and 10 or 6)
whitelistLayout.SortOrder = Enum.SortOrder.LayoutOrder

whitelistLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    whitelistScroll.CanvasSize = UDim2.new(0, 0, 0, whitelistLayout.AbsoluteContentSize.Y + 15)
end)

local whitelistInputContainer = Instance.new("Frame", whitelistContainer)
whitelistInputContainer.Size = UDim2.new(1, 0, 0, isMobile and 60 or 40)
whitelistInputContainer.Position = UDim2.new(0, 0, 0, isMobile and 185 or 125)
whitelistInputContainer.BackgroundTransparency = 1

local whitelistInput = Instance.new("TextBox", whitelistInputContainer)
whitelistInput.Size = UDim2.new(0.7, 0, 1, 0)
whitelistInput.Position = UDim2.new(0, 0, 0, 0)
whitelistInput.PlaceholderText = "Enter player name"
whitelistInput.Text = ""
whitelistInput.Font = Enum.Font.Gotham
whitelistInput.TextSize = isMobile and 18 or 14
whitelistInput.TextColor3 = Color3.fromRGB(20,20,20)
whitelistInput.BackgroundColor3 = Color3.fromRGB(240,240,240)
whitelistInput.ClearTextOnFocus = false
whitelistInput.TextScaled = isMobile
local inputCorner = Instance.new("UICorner", whitelistInput)
inputCorner.CornerRadius = UDim.new(0,8)

local whitelistAddBtn = Instance.new("TextButton", whitelistInputContainer)
whitelistAddBtn.Size = UDim2.new(0.25, 0, 1, 0)
whitelistAddBtn.Position = UDim2.new(0.75, 0, 0, 0)
whitelistAddBtn.Text = "Add"
whitelistAddBtn.Font = Enum.Font.Gotham
whitelistAddBtn.TextSize = isMobile and 18 or 14
whitelistAddBtn.TextColor3 = Color3.fromRGB(240,240,240)
whitelistAddBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 219)
whitelistAddBtn.TextScaled = isMobile
local addBtnCorner = Instance.new("UICorner", whitelistAddBtn)
addBtnCorner.CornerRadius = UDim.new(0,8)

whitelistElements[#whitelistElements+1] = whitelistContainer

-- Function to update whitelist display
local function updateWhitelistDisplay()
    for _, child in ipairs(whitelistScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for playerName, _ in pairs(Config.Whitelist) do
        local playerFrame = Instance.new("Frame", whitelistScroll)
        playerFrame.Size = UDim2.new(1, 0, 0, isMobile and 45 or 35)
        playerFrame.BackgroundTransparency = 1
        
        local playerLabel = Instance.new("TextLabel", playerFrame)
        playerLabel.Size = UDim2.new(0.7, 0, 1, 0)
        playerLabel.Position = UDim2.new(0, 0, 0, 0)
        playerLabel.BackgroundTransparency = 1
        playerLabel.Text = playerName
        playerLabel.Font = Enum.Font.Gotham
        playerLabel.TextSize = isMobile and 18 or 14
        playerLabel.TextColor3 = Color3.fromRGB(230,230,230)
        playerLabel.TextXAlignment = Enum.TextXAlignment.Left
        playerLabel.TextScaled = isMobile
        
        local removeBtn = Instance.new("TextButton", playerFrame)
        removeBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
        removeBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
        removeBtn.Text = "Remove"
        removeBtn.Font = Enum.Font.Gotham
        removeBtn.TextSize = isMobile and 16 or 13
        removeBtn.TextColor3 = Color3.fromRGB(240,240,240)
        removeBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        removeBtn.TextScaled = isMobile
        local removeCorner = Instance.new("UICorner", removeBtn)
        removeCorner.CornerRadius = UDim.new(0,6)
        
        removeBtn.MouseButton1Click:Connect(function()
            Config.Whitelist[playerName] = nil
            updateWhitelistDisplay()
        end)
    end
end

-- Add player to whitelist
whitelistAddBtn.MouseButton1Click:Connect(function()
    local playerName = whitelistInput.Text
    if playerName ~= "" and not Config.Whitelist[playerName] then
        Config.Whitelist[playerName] = true
        whitelistInput.Text = ""
        updateWhitelistDisplay()
    end
end)

whitelistInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local playerName = whitelistInput.Text
        if playerName ~= "" and not Config.Whitelist[playerName] then
            Config.Whitelist[playerName] = true
            whitelistInput.Text = ""
            updateWhitelistDisplay()
        end
    end
end)

-- Initialize whitelist display
updateWhitelistDisplay()

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, isMobile and 40 or 30)
Footer.BackgroundTransparency = 1
Footer.Text = "Right Ctrl hides/shows UI. Keybinds active only when not typing."
Footer.TextColor3 = Color3.fromRGB(170,170,170)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = isMobile and 16 or 14
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.LayoutOrder = y
Footer.TextScaled = isMobile

-- Function to update tab display
function updateTabDisplay()
    -- Clear content
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("GuiObject") and child ~= UIListLayout then
            child.Parent = nil
        end
    end
    
    -- Update tab button colors
    for tabName, button in pairs(TabButtons) do
        if tabName == currentTab then
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 219)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Add elements for current tab
    local elements = {}
    if currentTab == "Rapid" then
        elements = rapidElements
    elseif currentTab == "Visuals" then
        elements = visualsElements
    elseif currentTab == "Misc" then
        elements = miscElements
    elseif currentTab == "Whitelist" then
        elements = whitelistElements
    end
    
    for _, element in ipairs(elements) do
        element.Parent = Content
    end
    
    -- Add footer to all tabs
    Footer.Parent = Content
end

-- Initialize tab display
updateTabDisplay()

-- ---------- Walk Speed Function ----------
local function updateWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateWalkSpeed()
end)

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    updateWalkSpeed()
end

-- ---------- Draggable logic ----------
local dragging, dragInput, dragStart, startPos, activeDragTarget = false, nil, nil, nil, nil
local resizing = false

local function startDrag(input, target)
    dragging = true
    dragInput = input
    dragStart = input.Position
    startPos = target.Position
    activeDragTarget = target
    
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
            activeDragTarget = nil
        end
    end)
end

local function updateDrag(input)
    if not dragging or not activeDragTarget then return end
    local delta = input.Position - dragStart
    activeDragTarget.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

local function startResize(input)
    resizing = true
    dragInput = input
    dragStart = input.Position
    startPos = HubFrame.Size
    
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            resizing = false
        end
    end)
end

local function updateResize(input)
    if not resizing then return end
    local delta = input.Position - dragStart
    local newWidth = math.max(300, startPos.X.Offset + delta.X)
    local newHeight = math.max(400, startPos.Y.Offset + delta.Y)
    HubFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input, HubFrame)
    end
end)

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startResize(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput then
        if dragging then
            updateDrag(input)
        elseif resizing then
            updateResize(input)
        end
    end
end)

-- Enhanced mobile drag
if isMobile then
    local function isOverGui(position)
        local guiObjects = ScreenGui:GetGuiObjectsAtPosition(position.X, position.Y)
        for _, obj in ipairs(guiObjects) do
            if obj:IsDescendantOf(HubFrame) or obj:IsDescendantOf(OpenButton) then
                return true
            end
        end
        return false
    end
    
    UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        if isOverGui(touch.Position) then
            startDrag(touch, HubFrame)
        end
    end)
    
    UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        updateDrag(touch)
    end)
    
    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        dragging = false
        activeDragTarget = nil
    end)
end

-- ---------- ESP Implementation ----------
local function gameHasTeams()
    local tcount = 0
    for _, _ in pairs(Teams:GetChildren()) do tcount = tcount + 1 end
    return tcount > 0
end
local useTeams = gameHasTeams()

local function getTeamColorForPlayer(plr)
    if useTeams and plr.Team and LocalPlayer.Team then
        if plr.Team == LocalPlayer.Team then
            return Color3.fromRGB(100,220,120)
        else
            return Color3.fromRGB(255,100,100)
        end
    else
        return Color3.fromRGB(255,100,100)
    end
end

local function createESPForCharacter(plr, char)
    if not char then return end
    local attach = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not attach then return end

    local existing = attach:FindFirstChild("hoodkiller_ESP")
    if existing and existing:IsA("BillboardGui") then
        local lbl = existing:FindFirstChild("NameLabel")
        if lbl then
            lbl.TextColor3 = getTeamColorForPlayer(plr)
            existing.Enabled = Config.ESP
        end
        return
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "hoodkiller_ESP"
    gui.Size = UDim2.new(0, 120, 0, 18)
    gui.StudsOffset = Vector3.new(0, 2.4, 0)
    gui.AlwaysOnTop = true
    gui.Enabled = Config.ESP
    gui.Parent = attach

    local label = Instance.new("TextLabel", gui)
    label.Name = "NameLabel"
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name
    label.TextColor3 = getTeamColorForPlayer(plr)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextScaled = false
    label.TextWrapped = false
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextStrokeTransparency = 0.6
end

local function setupESPForPlayer(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        createESPForCharacter(plr, char)
    end)
    
    if plr.Character then createESPForCharacter(plr, plr.Character) end
    
    if useTeams then
        plr:GetPropertyChangedSignal("Team"):Connect(function()
            if plr.Character then
                local attach = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
                if attach then
                    local gui = attach:FindFirstChild("hoodkiller_ESP")
                    if gui and gui:FindFirstChild("NameLabel") then
                        gui.NameLabel.TextColor3 = getTeamColorForPlayer(plr)
                    end
                end
            end
        end)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then setupESPForPlayer(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then setupESPForPlayer(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        local attach = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
        if attach then
            local gui = attach:FindFirstChild("hoodkiller_ESP")
            if gui then gui:Destroy() end
        end
    end
end)

local function removeAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local attach = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
            if attach then
                local gui = attach:FindFirstChild("hoodkiller_ESP")
                if gui then gui:Destroy() end
            end
        end
    end
end

function setESPEnabled(enabled)
    Config.ESP = enabled
    if enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then createESPForCharacter(plr, plr.Character) end
        end
    else
        removeAllESP()
    end
    espBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
    espBtn.Text = enabled and "ON" or "OFF"
end

if Config.ESP then setESPEnabled(true) else setESPEnabled(false) end

-- ---------- Fly Implementation ----------
local function startFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if velocity then velocity:Destroy() end
    if gyro then gyro:Destroy() end
    velocity = Instance.new("BodyVelocity", hrp)
    velocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    velocity.Velocity = Vector3.new(0,0,0)
    gyro = Instance.new("BodyGyro", hrp)
    gyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    gyro.P = 10000
    flying = true
end

local function stopFly()
    flying = false
    if velocity then pcall(function() velocity:Destroy() end) velocity = nil end
    if gyro then pcall(function() gyro:Destroy() end) gyro = nil end
end

function flyEnabledChanged(state)
    if state then startFly() else stopFly() end
end

if Config.FlyEnabled then
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 219); flyBtn.Text = "ON"; flyEnabledChanged(true)
else
    flyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70); flyBtn.Text = "OFF"
end

-- ---------- Tool detection ----------
local function getEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

-- ---------- Mouse detection ----------
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = false end
end)

-- ---------- Bullet effect ----------
local function createBulletEffect(startPos, endPos)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, (startPos - endPos).Magnitude)
    part.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 50, 50)
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 5
    pointLight.Range = 10
    pointLight.Color = Color3.fromRGB(255, 50, 50)
    pointLight.Parent = part
    
    game:GetService("TweenService"):Create(part, TweenInfo.new(0.3), {Transparency = 1}):Play()
    game:GetService("TweenService"):Create(pointLight, TweenInfo.new(0.3), {Brightness = 0}):Play()
    delay(0.5, function() part:Destroy() end)
end

-- ---------- Auto Stomp Function ----------
local function findNearbyBodies()
    local bodies = {}
    local character = LocalPlayer.Character
    if not character then return bodies end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return bodies end
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health <= 0 then
            local bodyHrp = obj:FindFirstChild("HumanoidRootPart")
            if bodyHrp and (bodyHrp.Position - hrp.Position).Magnitude <= Config.StompRange then
                table.insert(bodies, obj)
            end
        end
    end
    
    return bodies
end

local function performStomp()
    if not Config.AutoStomp then return end
    if tick() - lastStompTime < stompCooldown then return end
    
    local bodies = findNearbyBodies()
    if #bodies > 0 then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        lastStompTime = tick()
        
        delay(0.1, function()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end
end

-- ---------- FOV Circle ----------
local function updateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    if Config.ShowFOV and Config.SilentAim then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = true
        FOVCircle.Transparency = 1
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Radius = Config.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

-- ---------- Silent Aim Logic ----------
local function getClosestPlayerToMouse()
    if not Config.SilentAim then return nil end
    
    local closestPlayer, closestDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
            local targetPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            
            if onScreen then
                local screenPos = Vector2.new(targetPos.X, targetPos.Y)
                local distance = (mousePos - screenPos).Magnitude
                
                if distance <= Config.FOV and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = plr
                end
            end
        end
    end
    
    return closestPlayer
end

-- ---------- Check if player is whitelisted ----------
local function isWhitelisted(player)
    return Config.Whitelist[player.Name] or false
end

-- ---------- Get target players ----------
local function getTargetPlayers()
    if Config.KillAll then
        local targets = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not isWhitelisted(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, player)
            end
        end
        return targets
    else
        if Config.SilentAim then
            local target = getClosestPlayerToMouse()
            return target and {target} or {}
        else
            local closestPlayer, closestDistance = nil, math.huge
            local camPos = Camera.CFrame.Position
            local lookVec = Camera.CFrame.LookVector
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
                    local targetPos = plr.Character.HumanoidRootPart.Position
                    local toTarget = (targetPos - camPos)
                    local dist = toTarget.Magnitude
                    
                    if dist > 0 then
                        local dir = toTarget.Unit
                        local dot = lookVec:Dot(dir)
                        local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                        
                        if angle <= 18 and dist < closestDistance then
                            closestDistance = dist
                            closestPlayer = plr
                        end
                    end
                end
            end
            
            return closestPlayer and {closestPlayer} or {}
        end
    end
end

-- ---------- New Feature Implementations ----------

-- Wallhack implementation
function setWallhackEnabled(enabled)
    if enabled then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 0.5 and part.Name ~= "HumanoidRootPart" then
                wallhackParts[part] = part.Transparency
                part.Transparency = 0.8
            end
        end
    else
        for part, transparency in pairs(wallhackParts) do
            if part.Parent then
                part.Transparency = transparency
            end
        end
        wallhackParts = {}
    end
end

-- Anti AFK implementation
function setAntiAFKEnabled(enabled)
    if enabled then
        antiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
        end)
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end
end

-- Noclip implementation
function setNoclipEnabled(enabled)
    if enabled then
        if noclipLoop then noclipLoop:Disconnect() end
        
        noclipLoop = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipLoop then
            noclipLoop:Disconnect()
            noclipLoop = nil
        end
    end
end

-- Infinite Jump implementation
function setInfiniteJumpEnabled(enabled)
    if enabled then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end
end

-- Aimbot implementation
local function updateAimbot()
    if not Config.Aimbot then return end
    
    local closestPlayer, closestDistance = nil, math.huge
    local camPos = Camera.CFrame.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
            local targetPos = plr.Character.HumanoidRootPart.Position
            local distance = (targetPos - camPos).Magnitude
            
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = plr
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = closestPlayer.Character.HumanoidRootPart
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
    end
end

-- No Recoil implementation
local function applyNoRecoil()
    if not Config.NoRecoil then return end
    
    for _, script in ipairs(game:GetDescendants()) do
        if script:IsA("LocalScript") and script.Name:lower():find("recoil") then
            script:Destroy()
        end
    end
end

-- Auto Farm implementation
local function autoFarm()
    if not Config.AutoFarm then return end
    
    local closestPlayer, closestDistance = nil, math.huge
    local myPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
    if not myPosition then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
            local targetPos = plr.Character.HumanoidRootPart.Position
            local distance = (targetPos - myPosition).Magnitude
            
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = plr
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:MoveTo(closestPlayer.Character.HumanoidRootPart.Position)
        end
    end
end

-- ---------- Main Execution Loop ----------
RunService.PreRender:Connect(function()
    if not authenticated then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local tool = getEquippedTool()
    if tool then
        -- try to adjust upvalues for rapidfire
        if type(getconnections) == "function" and type(debug) == "table" and tool.Activated then
            local ok, connections = pcall(function() return getconnections(tool.Activated) end)
            if ok and typeof(connections) == "table" then
                for _, conn in ipairs(connections) do
                    local fn = conn.Function
                    if fn then
                        local success, info = pcall(function() return debug.getinfo(fn) end)
                        if success and info then
                            for i = 1, info.nups do
                                local ups_ok, upv = pcall(function() return debug.getupvalue(fn, i) end)
                                if ups_ok and type(upv) == "number" then
                                    if not OriginalValues[i] then OriginalValues[i] = upv end
                                    pcall(function() debug.setupvalue(fn, i, Config.RapidFire and Config.FireRate or OriginalValues[i]) end)
                                end
                            end
                        end
                    end
                end
            end
        end

        local ammo = tool:FindFirstChild("Ammo")
        if ammo and ammo:IsA("IntValue") then ammo.Value = 9999 end

        local shouldFire = Config.AutoFire and (mouseDown or (isMobile and Config.MobileAutoFire and touchDown))
        
        if shouldFire then
            local targetPlayers = getTargetPlayers()
            
            if #targetPlayers > 0 then
                for _, target in ipairs(targetPlayers) do
                    if target and target.Character and target.Character:FindFirstChild("Head") and not isWhitelisted(target) then
                        if Config.SpreadRapidFire then
                            for i = 1, Config.SpreadCount do
                                local spreadAngle = math.rad((i - 1) * (360 / Config.SpreadCount))
                                local spreadDir = Vector3.new(math.cos(spreadAngle), 0, math.sin(spreadAngle)) * 5
                                
                                if Config.ShootFromSky then
                                    local skyPosition = target.Character.Head.Position + Vector3.new(0, 100, 0) + spreadDir
                                    local args = {
                                        "ShootGun",
                                        tool.Handle,
                                        skyPosition,
                                        target.Character.Head.Position,
                                        target.Character.Head,
                                        Vector3.yAxis,
                                        tick()
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent"):FireServer(unpack(args))
                                    
                                    createBulletEffect(skyPosition, target.Character.Head.Position)
                                else
                                    local gunPosition = tool.Handle.Position
                                    local targetPos = target.Character.Head.Position + spreadDir
                                    
                                    for j = 1, 3 do
                                        local args = {
                                            "ShootGun",
                                            tool.Handle,
                                            gunPosition,
                                            targetPos,
                                            target.Character.Head,
                                            Vector3.yAxis,
                                            tick()
                                        }
                                        game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent"):FireServer(unpack(args))
                                        
                                        createBulletEffect(gunPosition, targetPos)
                                        
                                        task.wait(0.01)
                                    end
                                end
                            end
                        elseif Config.ShootFromSky then
                            local skyPosition = target.Character.Head.Position + Vector3.new(0, 100, 0)
                            local args = {
                                "ShootGun",
                                tool.Handle,
                                skyPosition,
                                target.Character.Head.Position,
                                target.Character.Head,
                                Vector3.yAxis,
                                tick()
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent"):FireServer(unpack(args))
                            
                            createBulletEffect(skyPosition, target.Character.Head.Position)
                        else
                            local args = {
                                "ShootGun",
                                tool.Handle,
                                tool.Handle.Position,
                                target.Character.Head.Position,
                                target.Character.Head,
                                Vector3.yAxis,
                                tick()
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent"):FireServer(unpack(args))
                            
                            createBulletEffect(tool.Handle.Position, target.Character.Head.Position)
                            
                            if Config.RapidFire then
                                for i = 1, 2 do
                                    task.wait(0.01)
                                    game:GetService("ReplicatedStorage"):WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent"):FireServer(unpack(args))
                                    createBulletEffect(tool.Handle.Position, target.Character.Head.Position)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if Config.AutoStomp then
        performStomp()
    end
end)

-- ---------- Fly movement update ----------
RunService.RenderStepped:Connect(function()
    if not authenticated then return end
    if not Config.FlyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not flying then startFly() end
    if not velocity or not gyro then return end

    local cf = Camera.CFrame
    local moveVec = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += cf.UpVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= cf.UpVector end

    if moveVec.Magnitude > 0 then
        velocity.Velocity = moveVec.Unit * (tonumber(Config.FlySpeed) or 18)
    else
        velocity.Velocity = Vector3.new(0,0,0)
    end
    gyro.CFrame = cf
end)

-- ---------- Feature updates ----------
RunService.RenderStepped:Connect(function()
    if not authenticated then return end
    
    -- New feature updates
    updateAimbot()
    applyNoRecoil()
    autoFarm()
    
    if Config.Noclip then
        setNoclipEnabled(true)
    else
        setNoclipEnabled(false)
    end
    
    if Config.InfiniteJump then
        setInfiniteJumpEnabled(true)
    else
        setInfiniteJumpEnabled(false)
    end
    
    -- Camlock logic
    if Config.CamlockEnabled and camlockTarget and camlockTarget.Character and camlockTarget.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(camlockTarget) then
        local hrp = camlockTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local camCFrame = Camera.CFrame
            local desiredLook = CFrame.new(camCFrame.Position, hrp.Position)
            Camera.CFrame = camCFrame:Lerp(desiredLook, tonumber(Config.CamlockSmoothness) or 0.92)
        end
    end
end)

-- click to set camlock target
UserInputService.InputBegan:Connect(function(input, gp)
    if not authenticated then return end
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local x,y = input.Position.X, input.Position.Y
        local unitRay = Camera:ScreenPointToRay(x,y)
        local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
        local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if part then
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") then
                local plr = Players:GetPlayerFromCharacter(model)
                if plr and plr ~= LocalPlayer and not isWhitelisted(plr) then
                    if Config.CamlockEnabled then camlockTarget = plr end
                end
            end
        end
    end
end)

-- ---------- Keybind handling ----------
local function normalizeKeyNameFromInput(input)
    if not input.KeyCode then return nil end
    return tostring(input.KeyCode.Name or ""):upper()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not authenticated then return end
    if gameProcessed then return end
    if isTyping then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local pressedName = normalizeKeyNameFromInput(input)
    if not pressedName or pressedName == "" then return end

    for featureName, bind in pairs(Config.Keybinds) do
        if bind and tostring(bind):upper() == pressedName then
            if featureName == "RapidFire" then
                Config.RapidFire = not Config.RapidFire
                rfBtn.BackgroundColor3 = Config.RapidFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                rfBtn.Text = Config.RapidFire and "ON" or "OFF"
            elseif featureName == "AutoFire" then
                Config.AutoFire = not Config.AutoFire
                afBtn.BackgroundColor3 = Config.AutoFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                afBtn.Text = Config.AutoFire and "ON" or "OFF"
            elseif featureName == "ESP" then
                setESPEnabled(not Config.ESP)
            elseif featureName == "Fly" then
                Config.FlyEnabled = not Config.FlyEnabled
                flyBtn.BackgroundColor3 = Config.FlyEnabled and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                flyBtn.Text = Config.FlyEnabled and "ON" or "OFF"
                flyEnabledChanged(Config.FlyEnabled)
            elseif featureName == "Camlock" then
                Config.CamlockEnabled = not Config.CamlockEnabled
                camBtn.BackgroundColor3 = Config.CamlockEnabled and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                camBtn.Text = Config.CamlockEnabled and "ON" or "OFF"
                if Config.CamlockEnabled then
                    local function getClosestLookedAtPlayer()
                        local closestPlayer, closestDistance = nil, math.huge
                        local camPos, lookVec = Camera.CFrame.Position, Camera.CFrame.LookVector
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not isWhitelisted(plr) then
                                local targetPos = plr.Character.HumanoidRootPart.Position
                                local toTarget = (targetPos - camPos)
                                local dist = toTarget.Magnitude
                                if dist > 0 then
                                    local dir = toTarget.Unit
                                    local dot = lookVec:Dot(dir)
                                    local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                                    if angle <= 18 and dist < closestDistance then
                                        closestDistance = dist
                                        closestPlayer = plr
                                    end
                                end
                            end
                        end
                        return closestPlayer
                    end
                    camlockTarget = getClosestLookedAtPlayer()
                    if not camlockTarget then
                        Config.CamlockEnabled = false
                        camBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                        camBtn.Text = "OFF"
                    end
                else
                    camlockTarget = nil
                end
            elseif featureName == "Shoot from Sky" then
                Config.ShootFromSky = not Config.ShootFromSky
                skyBtn.BackgroundColor3 = Config.ShootFromSky and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                skyBtn.Text = Config.ShootFromSky and "ON" or "OFF"
            elseif featureName == "Spread Rapid Fire" then
                Config.SpreadRapidFire = not Config.SpreadRapidFire
                spreadBtn.BackgroundColor3 = Config.SpreadRapidFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                spreadBtn.Text = Config.SpreadRapidFire and "ON" or "OFF"
            elseif featureName == "Auto Stomp" then
                Config.AutoStomp = not Config.AutoStomp
                stompBtn.BackgroundColor3 = Config.AutoStomp and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                stompBtn.Text = Config.AutoStomp and "ON" or "OFF"
            elseif featureName == "Mobile AutoFire" and isMobile then
                Config.MobileAutoFire = not Config.MobileAutoFire
                mobileAFBtn.BackgroundColor3 = Config.MobileAutoFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                mobileAFBtn.Text = Config.MobileAutoFire and "ON" or "OFF"
            elseif featureName == "Silent Aim" then
                Config.SilentAim = not Config.SilentAim
                silentAimBtn.BackgroundColor3 = Config.SilentAim and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                silentAimBtn.Text = Config.SilentAim and "ON" or "OFF"
                updateFOVCircle()
            elseif featureName == "Show FOV" then
                Config.ShowFOV = not Config.ShowFOV
                showFOVBtn.BackgroundColor3 = Config.ShowFOV and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                showFOVBtn.Text = Config.ShowFOV and "ON" or "OFF"
                updateFOVCircle()
            elseif featureName == "Kill All" then
                Config.KillAll = not Config.KillAll
                killAllBtn.BackgroundColor3 = Config.KillAll and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                killAllBtn.Text = Config.KillAll and "ON" or "OFF"
            elseif featureName == "Aimbot" then
                Config.Aimbot = not Config.Aimbot
                aimbotBtn.BackgroundColor3 = Config.Aimbot and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                aimbotBtn.Text = Config.Aimbot and "ON" or "OFF"
            elseif featureName == "No Recoil" then
                Config.NoRecoil = not Config.NoRecoil
                noRecoilBtn.BackgroundColor3 = Config.NoRecoil and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                noRecoilBtn.Text = Config.NoRecoil and "ON" or "OFF"
            elseif featureName == "Infinite Jump" then
                Config.InfiniteJump = not Config.InfiniteJump
                infJumpBtn.BackgroundColor3 = Config.InfiniteJump and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                infJumpBtn.Text = Config.InfiniteJump and "ON" or "OFF"
                setInfiniteJumpEnabled(Config.InfiniteJump)
            elseif featureName == "Speed Hack" then
                Config.SpeedHack = not Config.SpeedHack
                speedHackBtn.BackgroundColor3 = Config.SpeedHack and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                speedHackBtn.Text = Config.SpeedHack and "ON" or "OFF"
                if Config.SpeedHack then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed * 1.5
                    end
                else
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
                    end
                end
            elseif featureName == "Wallhack" then
                Config.Wallhack = not Config.Wallhack
                wallhackBtn.BackgroundColor3 = Config.Wallhack and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                wallhackBtn.Text = Config.Wallhack and "ON" or "OFF"
                setWallhackEnabled(Config.Wallhack)
            elseif featureName == "Noclip" then
                Config.Noclip = not Config.Noclip
                noclipBtn.BackgroundColor3 = Config.Noclip and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                noclipBtn.Text = Config.Noclip and "ON" or "OFF"
                setNoclipEnabled(Config.Noclip)
            elseif featureName == "Auto Farm" then
                Config.AutoFarm = not Config.AutoFarm
                autoFarmBtn.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                autoFarmBtn.Text = Config.AutoFarm and "ON" or "OFF"
            elseif featureName == "Anti AFK" then
                Config.AntiAFK = not Config.AntiAFK
                antiAFKBtn.BackgroundColor3 = Config.AntiAFK and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70)
                antiAFKBtn.Text = Config.AntiAFK and "ON" or "OFF"
                setAntiAFKEnabled(Config.AntiAFK)
            end
        end
    end
end)

-- Right Ctrl toggles UI
UserInputService.InputBegan:Connect(function(input, gp)
    if not authenticated then return end
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Config.UIVisible = not Config.UIVisible
        HubFrame.Visible = Config.UIVisible
        OpenButton.Visible = not Config.UIVisible
    end
end)

-- Make TextBoxes mark typing
local function markAllTextBoxes(container)
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("TextBox") then
            child.Focused:Connect(function() markTyping(true) end)
            child.FocusLost:Connect(function() markTyping(false) end)
        elseif child:IsA("GuiObject") then
            pcall(function() markAllTextBoxes(child) end)
        end
    end
end
markAllTextBoxes(ScreenGui)

-- ---------- Initialize UI state ----------
HubFrame.Visible = false
OpenButton.Visible = false

-- Initialize all toggle buttons
rfBtn.BackgroundColor3 = Config.RapidFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); rfBtn.Text = Config.RapidFire and "ON" or "OFF"
afBtn.BackgroundColor3 = Config.AutoFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); afBtn.Text = Config.AutoFire and "ON" or "OFF"
if isMobile then
    mobileAFBtn.BackgroundColor3 = Config.MobileAutoFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); mobileAFBtn.Text = Config.MobileAutoFire and "ON" or "OFF"
end
espBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); espBtn.Text = Config.ESP and "ON" or "OFF"
flyBtn.BackgroundColor3 = Config.FlyEnabled and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); flyBtn.Text = Config.FlyEnabled and "ON" or "OFF"
camBtn.BackgroundColor3 = Config.CamlockEnabled and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); camBtn.Text = Config.CamlockEnabled and "ON" or "OFF"
skyBtn.BackgroundColor3 = Config.ShootFromSky and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); skyBtn.Text = Config.ShootFromSky and "ON" or "OFF"
spreadBtn.BackgroundColor3 = Config.SpreadRapidFire and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); spreadBtn.Text = Config.SpreadRapidFire and "ON" or "OFF"
stompBtn.BackgroundColor3 = Config.AutoStomp and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); stompBtn.Text = Config.AutoStomp and "ON" or "OFF"
silentAimBtn.BackgroundColor3 = Config.SilentAim and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); silentAimBtn.Text = Config.SilentAim and "ON" or "OFF"
showFOVBtn.BackgroundColor3 = Config.ShowFOV and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); showFOVBtn.Text = Config.ShowFOV and "ON" or "OFF"
killAllBtn.BackgroundColor3 = Config.KillAll and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); killAllBtn.Text = Config.KillAll and "ON" or "OFF"
aimbotBtn.BackgroundColor3 = Config.Aimbot and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); aimbotBtn.Text = Config.Aimbot and "ON" or "OFF"
noRecoilBtn.BackgroundColor3 = Config.NoRecoil and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); noRecoilBtn.Text = Config.NoRecoil and "ON" or "OFF"
infJumpBtn.BackgroundColor3 = Config.InfiniteJump and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); infJumpBtn.Text = Config.InfiniteJump and "ON" or "OFF"
speedHackBtn.BackgroundColor3 = Config.SpeedHack and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); speedHackBtn.Text = Config.SpeedHack and "ON" or "OFF"
wallhackBtn.BackgroundColor3 = Config.Wallhack and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); wallhackBtn.Text = Config.Wallhack and "ON" or "OFF"
noclipBtn.BackgroundColor3 = Config.Noclip and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); noclipBtn.Text = Config.Noclip and "ON" or "OFF"
autoFarmBtn.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); autoFarmBtn.Text = Config.AutoFarm and "ON" or "OFF"
antiAFKBtn.BackgroundColor3 = Config.AntiAFK and Color3.fromRGB(0, 180, 219) or Color3.fromRGB(70,70,70); antiAFKBtn.Text = Config.AntiAFK and "ON" or "OFF"

-- Initialize FOV circle
updateFOVCircle()

print("hoodkiller v1.25 loaded. Enter password 33333 to access the GUI.")
