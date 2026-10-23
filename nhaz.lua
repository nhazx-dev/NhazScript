-- [[ QX-CYBER-404 || Nhaz Auto Steal ]]
-- Steal An Egg | Tween Speed | Anti Guard | Anti Trap | Best Value
-- Discord: QX-CYBER

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local Zone_Eggs = {}
local BestEgg = nil
local AutoSteal = false
local AntiGuard = true
local AntiTrap = true
local SpeedBoost = false
local BoostSpeedValue = 100
local TweenSpeedValue = 50
local StopEveryZones = 3
local ZoneCounter = 0

-- GUI Creation (Nhaz Menu)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "Nhaz Auto Steal - QX-CYBER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Auto Steal Toggle (in red circle area as requested)
local AutoStealFrame = Instance.new("Frame")
AutoStealFrame.Size = UDim2.new(0, 120, 0, 40)
AutoStealFrame.Position = UDim2.new(0.5, -60, 0.15, 0)
AutoStealFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoStealFrame.Parent = MainFrame

local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Size = UDim2.new(1, 0, 1, 0)
AutoStealBtn.BackgroundTransparency = 1
AutoStealBtn.Text = "Auto Steal: OFF"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
AutoStealBtn.Font = Enum.Font.SourceSansBold
AutoStealBtn.TextSize = 16
AutoStealBtn.Parent = AutoStealFrame

-- Egg Selection List (Best Value)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.45, 0, 0.6, 0)
ScrollFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.45, 0, 0.6, 0)
SettingsFrame.Position = UDim2.new(0.52, 0, 0.25, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SettingsFrame.Parent = MainFrame

-- Anti Guard Toggle
local AntiGuardBtn = Instance.new("TextButton")
AntiGuardBtn.Size = UDim2.new(1, 0, 0, 30)
AntiGuardBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
AntiGuardBtn.Text = "Anti Guard: ON"
AntiGuardBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
AntiGuardBtn.Font = Enum.Font.SourceSansBold
AntiGuardBtn.Parent = SettingsFrame

-- Anti Trap Toggle
local AntiTrapBtn = Instance.new("TextButton")
AntiTrapBtn.Size = UDim2.new(1, 0, 0, 30)
AntiTrapBtn.Position = UDim2.new(0, 0, 0, 35)
AntiTrapBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
AntiTrapBtn.Text = "Anti Trap: ON"
AntiTrapBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
AntiTrapBtn.Font = Enum.Font.SourceSansBold
AntiTrapBtn.Parent = SettingsFrame

-- Speed Boost Toggle
local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(1, 0, 0, 30)
SpeedToggleBtn.Position = UDim2.new(0, 0, 0, 70)
SpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SpeedToggleBtn.Text = "Speed Boost: OFF"
SpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
SpeedToggleBtn.Font = Enum.Font.SourceSansBold
SpeedToggleBtn.Parent = SettingsFrame

-- Speed Value Slider (1-1000)
local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Size = UDim2.new(1, 0, 0, 25)
SpeedSlider.Position = UDim2.new(0, 0, 0, 105)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedSlider.Text = "100"
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.PlaceholderText = "Speed (1-1000)"
SpeedSlider.Parent = SettingsFrame

-- Tween Speed Slider (10-200)
local TweenSlider = Instance.new("TextBox")
TweenSlider.Size = UDim2.new(1, 0, 0, 25)
TweenSlider.Position = UDim2.new(0, 0, 0, 135)
TweenSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TweenSlider.Text = "50"
TweenSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
TweenSlider.PlaceholderText = "Tween Speed (10-200)"
TweenSlider.Parent = SettingsFrame

-- Stop Every Zones Slider
local StopSlider = Instance.new("TextBox")
StopSlider.Size = UDim2.new(1, 0, 0, 25)
StopSlider.Position = UDim2.new(0, 0, 0, 165)
StopSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StopSlider.Text = "3"
StopSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
StopSlider.PlaceholderText = "Stop every X zones"
StopSlider.Parent = SettingsFrame

-- Logic

-- Zone Eggs Data (Jungle to Enchanted Forest)
local EggZones = {
    {Name = "Jungle", Eggs = {"TouChcan Egg", "impanzee Egg", "Crocodile Egg", "Gorilla Egg", "Orangutini Ananassini Egg", "Spider Egg", "Tiger Egg", "King Snake Egg"}},
    {Name = "Snow", Eggs = {"Penguin Egg", "Walrus Egg", "Polar Bear Egg", "Sabertooth Tiger Egg", "Mammoth Egg", "King Mammoth Egg", "Yeti Egg", "Ice Dragon Egg"}},
    {Name = "Volcano", Eggs = {"Lava Gecko Egg", "Lava Frog Egg", "Flaming Bull Egg", "Lava Turtle Egg", "Magma Golem Egg", "Cerberus Egg"}},
    {Name = "Abyss Ocean", Eggs = {"Frog Egg", "Duckling Egg", "Catfish Egg", "Turtle Egg", "Trulimero Trulicina Egg", "Swan Egg", "Axolotl Egg", "Leviathan Egg", "Moby Egg"}},
    {Name = "Prehistoric", Eggs = {"Jerboa Egg", "Fennec Egg", "Camel Egg", "Tob Tob Tob Egg", "Snake Egg", "Scorpion Egg", "Sand Spider Egg", "Royal Sphinx Egg", "T-Rex Egg"}},
    {Name = "Cosmic", Eggs = {"Cosmic Egg"}},
    {Name = "Cherry Blossom", Eggs = {"Cherry Blossom Egg"}},
    {Name = "Titan Temple", Eggs = {"Titan Temple Egg"}},
    {Name = "Enchanted Forest", Eggs = {"Starry Fox Egg", "Celestial Sunlion Egg"}}
}

-- Populate Egg List (Best Value Priority)
local function PopulateEggs()
    for _, zone in ipairs(EggZones) do
        for _, eggName in ipairs(zone.Eggs) do
            local eggBtn = Instance.new("TextButton")
            eggBtn.Size = UDim2.new(1, 0, 0, 30)
            eggBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            eggBtn.Text = zone.Name .. " - " .. eggName
            eggBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            eggBtn.Font = Enum.Font.SourceSans
            eggBtn.TextSize = 14
            eggBtn.Parent = ScrollFrame
            eggBtn.MouseButton1Click:Connect(function()
                BestEgg = {Zone = zone.Name, Egg = eggName}
                for _, child in ipairs(ScrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                    end
                end
                eggBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            end)
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollFrame:GetChildren() * 30)
end

PopulateEggs()

-- Toggle Functions
AutoStealBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoStealBtn.Text = "Auto Steal: " .. (AutoSteal and "ON" or "OFF")
    AutoStealBtn.TextColor3 = AutoSteal and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

AntiGuardBtn.MouseButton1Click:Connect(function()
    AntiGuard = not AntiGuard
    AntiGuardBtn.Text = "Anti Guard: " .. (AntiGuard and "ON" or "OFF")
    AntiGuardBtn.TextColor3 = AntiGuard and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

AntiTrapBtn.MouseButton1Click:Connect(function()
    AntiTrap = not AntiTrap
    AntiTrapBtn.Text = "Anti Trap: " .. (AntiTrap and "ON" or "OFF")
    AntiTrapBtn.TextColor3 = AntiTrap and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

SpeedToggleBtn.MouseButton1Click:Connect(function()
    SpeedBoost = not SpeedBoost
    SpeedToggleBtn.Text = "Speed Boost: " .. (SpeedBoost and "ON" or "OFF")
    SpeedToggleBtn.TextColor3 = SpeedBoost and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    if SpeedBoost then
        Hum.WalkSpeed = BoostSpeedValue
    else
        Hum.WalkSpeed = 16
    end
end)

SpeedSlider.FocusLost:Connect(function()
    local val = tonumber(SpeedSlider.Text)
    if val then
        BoostSpeedValue = math.clamp(val, 1, 1000)
        SpeedSlider.Text = tostring(BoostSpeedValue)
        if SpeedBoost then Hum.WalkSpeed = BoostSpeedValue end
    end
end)

TweenSlider.FocusLost:Connect(function()
    local val = tonumber(TweenSlider.Text)
    if val then
        TweenSpeedValue = math.clamp(val, 10, 200)
        TweenSlider.Text = tostring(TweenSpeedValue)
    end
end)

StopSlider.FocusLost:Connect(function()
    local val = tonumber(StopSlider.Text)
    if val then
        StopEveryZones = math.clamp(val, 1, 10)
        StopSlider.Text = tostring(StopEveryZones)
    end
end)

-- Tween to Egg
local function TweenToEgg(eggName)
    local eggObj = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == eggName and obj:IsA("Part") then
            eggObj = obj
            break
        end
    end
    if not eggObj then return false end
    
    local targetPos = eggObj.Position + Vector3.new(0, 5, 0) -- fly low
    local distance = (HRP.Position - targetPos).Magnitude
    local tweenTime = distance / (TweenSpeedValue * 10) -- adjust speed
    
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Anti Guard Logic
local function CheckGuards()
    if not AntiGuard then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Guard" or obj.Name == "Tiger" or obj.Name == "Yeti" then
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (HRP.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < 30 then
                    -- Reset/escape logic
                    HRP.CFrame = CFrame.new(0, 100, 0) -- fly up
                    wait(1)
                end
            end
        end
    end
end

-- Anti Trap Logic
local function CheckTraps()
    if not AntiTrap then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Trap" and obj:IsA("Part") then
            local dist = (HRP.Position - obj.Position).Magnitude
            if dist < 10 then
                -- Avoid trap by moving away
                HRP.CFrame = HRP.CFrame + Vector3.new(0, 20, 0)
                wait(0.5)
            end
        end
    end
end

-- Auto Steal Loop:
local function AutoStealLoop()
    while AutoSteal do
        if not BestEgg then
            wait(1)
            continue
        endFire
        
        -- Stop every X zones
        if ZoneCounter >= StopEveryZones then
            wait(2) -- pause
            ZoneServerCounter = 0
        end
        
        local success = TweenToEgg(BestEgg.Egg)
        if success then
           ( -- Steal action (click or interact)
            local eggPart = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == BestEgg.Egg and obj:IsA("Part") then
                    eggPart = obj
                    break
                end
            end
            if eggPart then
                -- Simulate steal (click)
                local clickEvent = game:GetService("ReplicatedStorage"):FindFirstChild("StealEgg")
                if clickEvent then
                    clickEventeggPart)
                end
            end
            ZoneCounter = ZoneCounter + 1
        end
        
        -- Anti checks
        CheckGuards()
        CheckTraps()
        
        wait(1)
    end
end

-- Start Loop
spawn(function()
    while true do
        if AutoSteal then
            AutoStealLoop()
        end
        wait(1)
    end
end)

-- Quick Bar UI (matching image)
local QuickBar = Instance.new("Frame")
QuickBar.Name = "QuickBar"
QuickBar.Size = UDim2.new(0, 200, 0, 80)
QuickBar.Position = UDim2.new(1, -220, 0.5, -40)
QuickBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
QuickBar.Parent = ScreenGui

local QuickBarTitle = Instance.new("TextLabel")
QuickBarTitle.Size = UDim2.new(1, 0, 0, 20)
QuickBarTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
QuickBarTitle.Text = "Quick Bar 1"
QuickBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickBarTitle.Parent = QuickBar

local EggIcon = Instance.new("TextButton")
EggIcon.Size = UDim2.new(0, 60, 0, 60)
EggIcon.Position = UDim2.new(0.5, -30, 0.5, -20)
EggIcon.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
EggIcon.Text = "🥚"
EggIcon.Font = Enum.Font.SourceSansBold
EggIcon.TextSize = 30
EggIcon.Parent = QuickBar
EggIcon.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoStealBtn.Text = "Auto Steal: " .. (AutoSteal and "ON" or "OFF")
    AutoStealBtn.TextColor3 = AutoSteal and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
