-- [[ QX-CYBER-404 || Nhaz Auto Steal (Delta Mobile Fix) ]]
-- Steal An Egg | Tween Speed | Anti Guard | Anti Trap | Best Value

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local BestEgg = nil
local AutoSteal = false
local AntiGuard = true
local AntiTrap = true
local SpeedBoost = false
local BoostSpeedValue = 100
local TweenSpeedValue = 50
local StopEveryZones = 3
local ZoneCounter = 0

-- កែសម្រួល UI ឱ្យដាក់ក្នុង PlayerGui ដើម្បីឱ្យ Delta ស្គាល់
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu_Delta"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LP:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- មុខងារអូស UI សម្រាប់ទូរស័ព្ទ
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "Nhaz Auto Steal - QX-CYBER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Debug Status (សម្រាប់មើលថាតើវាដើរដល់ណា)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Waiting for egg selection..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Auto Steal Toggle
local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Size = UDim2.new(0, 150, 0, 35)
AutoStealBtn.Position = UDim2.new(0.5, -75, 0.15, 0)
AutoStealBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoStealBtn.Text = "Auto Steal: OFF"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
AutoStealBtn.Font = Enum.Font.SourceSansBold
AutoStealBtn.TextSize = 14
AutoStealBtn.Parent = MainFrame

-- Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
SettingsFrame.Position = UDim2.new(0.52, 0, 0.25, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SettingsFrame.Parent = MainFrame

local AntiGuardBtn = Instance.new("TextButton")
AntiGuardBtn.Size = UDim2.new(1, -10, 0, 30)
AntiGuardBtn.Position = UDim2.new(0, 5, 0, 5)
AntiGuardBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
AntiGuardBtn.Text = "Anti Guard: ON"
AntiGuardBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
AntiGuardBtn.Font = Enum.Font.SourceSansBold
AntiGuardBtn.Parent = SettingsFrame

local AntiTrapBtn = Instance.new("TextButton")
AntiTrapBtn.Size = UDim2.new(1, -10, 0, 30)
AntiTrapBtn.Position = UDim2.new(0, 5, 0, 40)
AntiTrapBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
AntiTrapBtn.Text = "Anti Trap: ON"
AntiTrapBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
AntiTrapBtn.Font = Enum.Font.SourceSansBold
AntiTrapBtn.Parent = SettingsFrame

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Size = UDim2.new(1, -10, 0, 30)
SpeedToggleBtn.Position = UDim2.new(0, 5, 0, 75)
SpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SpeedToggleBtn.Text = "Speed Boost: OFF"
SpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
SpeedToggleBtn.Font = Enum.Font.SourceSansBold
SpeedToggleBtn.Parent = SettingsFrame

local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Size = UDim2.new(1, -10, 0, 25)
SpeedSlider.Position = UDim2.new(0, 5, 0, 110)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedSlider.Text = "100"
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.PlaceholderText = "Speed (1-1000)"
SpeedSlider.Parent = SettingsFrame

local TweenSlider = Instance.new("TextBox")
TweenSlider.Size = UDim2.new(1, -10, 0, 25)
TweenSlider.Position = UDim2.new(0, 5, 0, 140)
TweenSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TweenSlider.Text = "50"
TweenSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
TweenSlider.PlaceholderText = "Tween Speed (10-200)"
TweenSlider.Parent = SettingsFrame

local StopSlider = Instance.new("TextBox")
StopSlider.Size = UDim2.new(1, -10, 0, 25)
StopSlider.Position = UDim2.new(0, 5, 0, 170)
StopSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StopSlider.Text = "3"
StopSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
StopSlider.PlaceholderText = "Stop every X zones"
StopSlider.Parent = SettingsFrame

-- Scroll Frame (Egg List)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
ScrollFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame
Instance.new("UIListLayout").Parent = ScrollFrame

-- Egg Data
local EggZones = {
    {Name = "Jungle", Eggs = {"Toucan Egg", "Chimpanzee Egg", "Crocodile Egg", "Gorilla Egg", "Orangutini Ananassini Egg", "Spider Egg", "Tiger Egg", "King Snake Egg"}},
    {Name = "Snow", Eggs = {"Penguin Egg", "Walrus Egg", "Polar Bear Egg", "Sabertooth Tiger Egg", "Mammoth Egg", "King Mammoth Egg", "Yeti Egg", "Ice Dragon Egg"}},
    {Name = "Volcano", Eggs = {"Lava Gecko Egg", "Lava Frog Egg", "Flaming Bull Egg", "Lava Turtle Egg", "Magma Golem Egg", "Cerberus Egg"}},
    {Name = "Abyss Ocean", Eggs = {"Frog Egg", "Duckling Egg", "Catfish Egg", "Turtle Egg", "Trulimero Trulicina Egg", "Swan Egg", "Axolotl Egg", "Leviathan Egg", "Moby Egg"}},
    {Name = "Prehistoric", Eggs = {"Jerboa Egg", "Fennec Egg", "Camel Egg", "Tob Tob Tob Egg", "Snake Egg", "Scorpion Egg", "Sand Spider Egg", "Royal Sphinx Egg", "T-Rex Egg"}},
    {Name = "Cosmic", Eggs = {"Cosmic Egg"}},
    {Name = "Cherry Blossom", Eggs = {"Cherry Blossom Egg"}},
    {Name = "Titan Temple", Eggs = {"Titan Temple Egg"}},
    {Name = "Enchanted Forest", Eggs = {"Starry Fox Egg", "Celestial Sunlion Egg"}}
}

for _, zone in ipairs(EggZones) do
    for _, eggName in ipairs(zone.Eggs) do
        local eggBtn = Instance.new("TextButton")
        eggBtn.Size = UDim2.new(1, -5, 0, 28)
        eggBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        eggBtn.Text = zone.Name .. " - " .. eggName
        eggBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        eggBtn.Font = Enum.Font.SourceSans
        eggBtn.TextSize = 12
        eggBtn.Parent = ScrollFrame
        eggBtn.MouseButton1Click:Connect(function()
            BestEgg = eggName
            StatusLabel.Text = "Target: " .. eggName
            for _, child in ipairs(ScrollFrame:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end
            end
            eggBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end)
    end
end
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollFrame:GetChildren() * 28)

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
    Hum.WalkSpeed = SpeedBoost and BoostSpeedValue or 16
end)

SpeedSlider.FocusLost:Connect(function()
    local val = tonumber(SpeedSlider.Text)
    if val then
        BoostSpeedValue = math.clamp(val, 1, 1000)
        if SpeedBoost then Hum.WalkSpeed = BoostSpeedValue end
    end
end)

TweenSlider.FocusLost:Connect(function()
    local val = tonumber(TweenSlider.Text)
    if val then TweenSpeedValue = math.clamp(val, 10, 200) end
end)

StopSlider.FocusLost:Connect(function()
    local val = tonumber(StopSlider.Text)
    if val then StopEveryZones = math.clamp(val, 1, 10) end
end)

-- Tween to Egg
local function TweenToEgg(eggName)
    local eggObj = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == eggName and (obj:IsA("Part") or obj:IsA("MeshPart")) then
            eggObj = obj
            break
        end
    end
    if not eggObj then return false end
    
    local targetPos = eggObj.Position + Vector3.new(0, 6, 0)
    local distance = (HRP.Position - targetPos).Magnitude
    local tweenTime = distance / (TweenSpeedValue * 10)
    
    local tween = TweenService:Create(HRP, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true, eggObj
end

-- Auto Steal Logic (កែឱ្យដើរជាមួយ ProximityPrompt)
local function StealEgg(eggObj)
    -- ព្យាយាមរក ProximityPrompt ក្នុងពង
    for _, v in pairs(eggObj:GetChildren()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
            fireproximityprompt(v)
            return true
        end
    end
    -- បើគ្មាន ProximityPrompt ព្យាយាមរក RemoteEvent ធម្មតា
    local clickEvent = game:GetService("ReplicatedStorage"):FindFirstChild("StealEgg")
    if clickEvent then 
        clickEvent:FireServer(eggObj) 
        return true
    end
    return false
end

-- Main Loop
task.spawn(function()
    while task.wait(0.5) do
        if AutoSteal and BestEgg then
            if ZoneCounter >= StopEveryZones then
                StatusLabel.Text = "Resting to avoid anti-cheat..."
                task.wait(2)
                ZoneCounter = 0
            end
            
            StatusLabel.Text = "Flying to: " .. BestEgg
            local success, eggPart = TweenToEgg(BestEgg)
            
            if success and eggPart then
                StatusLabel.Text = "Stealing: " .. BestEgg
                StealEgg(eggPart)
                ZoneCounter += 1
            else
                StatusLabel.Text = "Error: Egg not found in map!"
            end
            
            -- Anti Guards
            if AntiGuard then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj.Name:find("Guard") or obj.Name == "Tiger" or obj.Name == "Yeti") and obj:IsA("Model") then
                        local root = obj:FindFirstChild("HumanoidRootPart")
                        if root and (HRP.Position - root.Position).Magnitude < 35 then
                            HRP.CFrame = CFrame.new(0, 200, 0) -- ហោះឡើងលើឱ្យឆ្ងាយ
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end
end)
