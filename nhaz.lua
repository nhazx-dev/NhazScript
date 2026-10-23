-- [[ QX-CYBER-404 || Nhaz Auto Steal (V2) ]]
-- Delta Mobile | Map Filtering | UI Toggle | Loading Screen | Best Value

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

-- Configuration
local BestEgg = nil
local AutoSteal = false
local AntiGuard = true
local AntiTrap = true
local SpeedBoost = false
local BoostSpeedValue = 100
local TweenSpeedValue = 50
local StopEveryZones = 3
local ZoneCounter = 0

-- Egg Database (តម្លៃ និងរូបភាព អ្នកអាចកែតម្លៃលុយឬ ID រូបភាពនៅទីនេះបាន)
local EggDatabase = {
    -- Jungle
    ["Toucan Egg"] = {Zone = "Jungle", Value = "500K/s", Icon = "rbxassetid://7487019531"},
    ["Chimpanzee Egg"] = {Zone = "Jungle", Value = "1.2M/s", Icon = "rbxassetid://7487019531"},
    ["Crocodile Egg"] = {Zone = "Jungle", Value = "2.5M/s", Icon = "rbxassetid://7487019531"},
    ["Gorilla Egg"] = {Zone = "Jungle", Value = "4.8M/s", Icon = "rbxassetid://7487019531"},
    ["Orangutini Ananassini Egg"] = {Zone = "Jungle", Value = "8M/s", Icon = "rbxassetid://7487019531"},
    ["Spider Egg"] = {Zone = "Jungle", Value = "12M/s", Icon = "rbxassetid://7487019531"},
    ["Tiger Egg"] = {Zone = "Jungle", Value = "18M/s", Icon = "rbxassetid://7487019531"},
    ["King Snake Egg"] = {Zone = "Jungle", Value = "25M/s", Icon = "rbxassetid://7487019531"},
    -- Snow
    ["Penguin Egg"] = {Zone = "Snow", Value = "35M/s", Icon = "rbxassetid://7487019531"},
    ["Walrus Egg"] = {Zone = "Snow", Value = "50M/s", Icon = "rbxassetid://7487019531"},
    ["Polar Bear Egg"] = {Zone = "Snow", Value = "75M/s", Icon = "rbxassetid://7487019531"},
    ["Sabertooth Tiger Egg"] = {Zone = "Snow", Value = "100M/s", Icon = "rbxassetid://7487019531"},
    ["Mammoth Egg"] = {Zone = "Snow", Value = "150M/s", Icon = "rbxassetid://7487019531"},
    ["King Mammoth Egg"] = {Zone = "Snow", Value = "220M/s", Icon = "rbxassetid://7487019531"},
    ["Yeti Egg"] = {Zone = "Snow", Value = "300M/s", Icon = "rbxassetid://7487019531"},
    ["Ice Dragon Egg"] = {Zone = "Snow", Value = "450M/s", Icon = "rbxassetid://7487019531"},
    -- Volcano
    ["Lava Gecko Egg"] = {Zone = "Volcano", Value = "600M/s", Icon = "rbxassetid://7487019531"},
    ["Lava Frog Egg"] = {Zone = "Volcano", Value = "850M/s", Icon = "rbxassetid://7487019531"},
    ["Flaming Bull Egg"] = {Zone = "Volcano", Value = "1.2B/s", Icon = "rbxassetid://7487019531"},
    ["Lava Turtle Egg"] = {Zone = "Volcano", Value = "1.8B/s", Icon = "rbxassetid://7487019531"},
    ["Magma Golem Egg"] = {Zone = "Volcano", Value = "2.5B/s", Icon = "rbxassetid://7487019531"},
    ["Cerberus Egg"] = {Zone = "Volcano", Value = "3.5B/s", Icon = "rbxassetid://7487019531"},
    -- Abyss Ocean
    ["Frog Egg"] = {Zone = "Abyss Ocean", Value = "5B/s", Icon = "rbxassetid://7487019531"},
    ["Duckling Egg"] = {Zone = "Abyss Ocean", Value = "7B/s", Icon = "rbxassetid://7487019531"},
    ["Catfish Egg"] = {Zone = "Abyss Ocean", Value = "10B/s", Icon = "rbxassetid://7487019531"},
    ["Turtle Egg"] = {Zone = "Abyss Ocean", Value = "15B/s", Icon = "rbxassetid://7487019531"},
    ["Trulimero Trulicina Egg"] = {Zone = "Abyss Ocean", Value = "22B/s", Icon = "rbxassetid://7487019531"},
    ["Swan Egg"] = {Zone = "Abyss Ocean", Value = "30B/s", Icon = "rbxassetid://7487019531"},
    ["Axolotl Egg"] = {Zone = "Abyss Ocean", Value = "45B/s", Icon = "rbxassetid://7487019531"},
    ["Leviathan Egg"] = {Zone = "Abyss Ocean", Value = "70B/s", Icon = "rbxassetid://7487019531"},
    ["Moby Egg"] = {Zone = "Abyss Ocean", Value = "100B/s", Icon = "rbxassetid://7487019531"},
    -- Prehistoric
    ["Jerboa Egg"] = {Zone = "Prehistoric", Value = "150B/s", Icon = "rbxassetid://7487019531"},
    ["Fennec Egg"] = {Zone = "Prehistoric", Value = "220B/s", Icon = "rbxassetid://7487019531"},
    ["Camel Egg"] = {Zone = "Prehistoric", Value = "300B/s", Icon = "rbxassetid://7487019531"},
    ["Tob Tob Tob Egg"] = {Zone = "Prehistoric", Value = "400B/s", Icon = "rbxassetid://7487019531"},
    ["Snake Egg"] = {Zone = "Prehistoric", Value = "550B/s", Icon = "rbxassetid://7487019531"},
    ["Scorpion Egg"] = {Zone = "Prehistoric", Value = "750B/s", Icon = "rbxassetid://7487019531"},
    ["Sand Spider Egg"] = {Zone = "Prehistoric", Value = "1T/s", Icon = "rbxassetid://7487019531"},
    ["Royal Sphinx Egg"] = {Zone = "Prehistoric", Value = "1.5T/s", Icon = "rbxassetid://7487019531"},
    ["T-Rex Egg"] = {Zone = "Prehistoric", Value = "2T/s", Icon = "rbxassetid://7487019531"},
    -- Cosmic
    ["Cosmic Egg"] = {Zone = "Cosmic", Value = "5T/s", Icon = "rbxassetid://7487019531"},
    -- Cherry Blossom
    ["Cherry Blossom Egg"] = {Zone = "Cherry Blossom", Value = "10T/s", Icon = "rbxassetid://7487019531"},
    -- Titan Temple
    ["Titan Temple Egg"] = {Zone = "Titan Temple", Value = "25T/s", Icon = "rbxassetid://7487019531"},
    -- Enchanted Forest
    ["Starry Fox Egg"] = {Zone = "Enchanted Forest", Value = "50T/s", Icon = "rbxassetid://7487019531"},
    ["Celestial Sunlion Egg"] = {Zone = "Enchanted Forest", Value = "100T/s", Icon = "rbxassetid://7487019531"}
}

-- ១. ផ្ទាំង Loading ពេល Execute
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "Nhaz_Loading"
LoadGui.ResetOnSpawn = false
LoadGui.Parent = CoreGui

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(0, 250, 0, 80)
LoadFrame.Position = UDim2.new(0.5, -125, 0.5, -40)
LoadFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = LoadGui
Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 10)

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(1, 0, 0, 40)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Loading Nhaz Script... 0%"
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.Font = Enum.Font.SourceSansBold
LoadText.TextSize = 16
LoadText.Parent = LoadFrame

local LoadBarBg = Instance.new("Frame")
LoadBarBg.Size = UDim2.new(0.8, 0, 0, 10)
LoadBarBg.Position = UDim2.new(0.1, 0, 0.7, 0)
LoadBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
LoadBarBg.BorderSizePixel = 0
LoadBarBg.Parent = LoadFrame
Instance.new("UICorner", LoadBarBg).CornerRadius = UDim.new(0, 5)

local LoadBar = Instance.new("Frame")
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
LoadBar.BorderSizePixel = 0
LoadBar.Parent = LoadBarBg
Instance.new("UICorner", LoadBar).CornerRadius = UDim.new(0, 5)

local function UpdateLoad(percent)
    LoadText.Text = "Loading Nhaz Script... " .. percent .. "%"
    TweenService:Create(LoadBar, TweenInfo.new(0.2), {Size = UDim2.new(percent/100, 0, 1, 0)}):Play()
    task.wait(0.2)
end

UpdateLoad(20)

-- ២. ស្កេនរកពងដែលមានក្នុង Map តែម្តង
local function ScanAvailableEggs()
    local available = {}
    local workspaceEggs = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local cleanName = string.gsub(obj.Name, "%s+", ""):lower()
            table.insert(workspaceEggs, cleanName)
        end
    end

    for eggName, data in pairs(EggDatabase) do
        local cleanEggName = string.gsub(eggName, "%s+", ""):lower()
        for _, wEgg in ipairs(workspaceEggs) do
            if wEgg == cleanEggName or wEgg:find(cleanEggName) or cleanEggName:find(wEgg) then
                available[eggName] = data
                break
            end
        end
    end
    return available
end

local MapEggs = ScanAvailableEggs()
UpdateLoad(60)

-- ៣. បង្កើត UI សំខាន់
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu_Delta"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- ប៊ូតុងមូលតូច (Toggle Menu)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "⚙️"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 350)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- លាក់ទុកមុន លុះត្រាចុចប៊ូតុងមូល
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "Nhaz Auto Steal - QX-CYBER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Waiting for selection..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Size = UDim2.new(0, 180, 0, 35)
AutoStealBtn.Position = UDim2.new(0.5, -90, 0.15, 0)
AutoStealBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoStealBtn.Text = "Auto Steal: OFF"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
AutoStealBtn.Font = Enum.Font.SourceSansBold
AutoStealBtn.TextSize = 14
AutoStealBtn.Parent = MainFrame
Instance.new("UICorner", AutoStealBtn).CornerRadius = UDim.new(0, 5)

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

-- ៤. បញ្ជីពង (បង្ហាញតែពងដែលមានក្នុង Map និងមានរូប+តម្លៃ)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
ScrollFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame
Instance.new("UIListLayout").Parent = ScrollFrame

-- បង្ហាញពងដែលរកឃើញ
for eggName, data in pairs(MapEggs) do
    local eggBtn = Instance.new("TextButton")
    eggBtn.Size = UDim2.new(1, -5, 0, 40)
    eggBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    eggBtn.Text = ""
    eggBtn.Parent = ScrollFrame
    
    -- រូបសត្វ
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 5, 0, 5)
    icon.BackgroundTransparency = 1
    icon.Image = data.Icon
    icon.Parent = eggBtn
    
    -- តម្លៃ និងឈ្មោះ
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -45, 1, 0)
    info.Position = UDim2.new(0, 40, 0, 0)
    info.BackgroundTransparency = 1
    info.Text = data.Zone .. " | " .. eggName .. "\n" .. data.Value
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.Font = Enum.Font.SourceSansBold
    info.TextSize = 12
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = eggBtn
    
    eggBtn.MouseButton1Click:Connect(function()
        BestEgg = eggName
        StatusLabel.Text = "Target: " .. eggName .. " (" .. data.Value .. ")"
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end
        end
        eggBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    end)
end
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollFrame:GetChildren() * 45)
UpdateLoad(90)

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

local function TweenToEgg(eggName)
    local eggObj = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower() == eggName:lower() and (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            eggObj = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart") or obj
            break
        end
    end
    if not eggObj or not eggObj.Position then return false, nil end
    
    -- ហោះទាបល្មម (ខ្ពស់ជាង Hero បន្តិច +6)
    local targetPos = eggObj.Position + Vector3.new(0, 6, 0)
    local distance = (HRP.Position - targetPos).Magnitude
    local tweenTime = distance / (TweenSpeedValue * 10)
    
    local tween = TweenService:Create(HRP, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true, eggObj
end

local function StealEgg(eggObj)
    for _, v in pairs(eggObj:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
            fireproximityprompt(v)
            return true
        end
    end
    local clickEvent = game:GetService("ReplicatedStorage"):FindFirstChild("StealEgg")
    if clickEvent then 
        clickEvent:FireServer(eggObj) 
        return true
    end
    return false
end

UpdateLoad(100)

task.delay(1, function()
    LoadGui:Destroy()
    MainFrame.Visible = true -- បង្ហាញ Menu ស្វ័យប្រវត្តិពេល Load រួច
end)

-- Main Loop (Auto Steal)
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
            
            if AntiGuard then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj.Name:find("Guard") or obj.Name == "Tiger" or obj.Name == "Yeti") and obj:IsA("Model") then
                        local root = obj:FindFirstChild("HumanoidRootPart")
                        if root and (HRP.Position - root.Position).Magnitude < 35 then
                            HRP.CFrame = CFrame.new(0, 200, 0)
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end
end)
