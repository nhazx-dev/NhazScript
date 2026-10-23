-- [[ Nhaz Auto Steal - Perfected Edition ]]
-- Smooth Fly | No Yielding Lag | Exact Map Eggs

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- ការកំណត់
local AutoSteal = false
local SelectedEgg = nil
local StopZones = 3
local CurrentZones = 0
local SpeedPercentage = 100
local AntiGuard = true
local AntiTrap = true

-- ទិន្នន័យពងពេញលេញ (ចាប់ពី Jungle ដល់ Enchanted Forest)
local EggData = {
    -- Enchanted Forest
    {Name="Celestial Sunlion Egg", Zone="Enchanted", Value="100B/s", Type="Divine", NumValue=100000000000},
    {Name="Starry Fox Egg", Zone="Enchanted", Value="50B/s", Type="Eternal", NumValue=50000000000},
    -- Titan Temple
    {Name="Titan Temple Egg", Zone="Titan", Value="25B/s", Type="Divine", NumValue=25000000000},
    -- Cherry Blossom
    {Name="Cherry Blossom Egg", Zone="Cherry", Value="10B/s", Type="Eternal", NumValue=10000000000},
    -- Cosmic
    {Name="Cosmic Egg", Zone="Cosmic", Value="5B/s", Type="Divine", NumValue=5000000000},
    -- Prehistoric
    {Name="T-Rex Egg", Zone="Prehistoric", Value="2B/s", Type="Eternal", NumValue=2000000000},
    {Name="Royal Sphinx Egg", Zone="Prehistoric", Value="1.5B/s", Type="Divine", NumValue=1500000000},
    {Name="Sand Spider Egg", Zone="Prehistoric", Value="1B/s", Type="Legendary", NumValue=1000000000},
    {Name="Scorpion Egg", Zone="Prehistoric", Value="750M/s", Type="Legendary", NumValue=750000000},
    {Name="Snake Egg", Zone="Prehistoric", Value="550M/s", Type="Legendary", NumValue=550000000},
    {Name="Tob Tob Tob Egg", Zone="Prehistoric", Value="400M/s", Type="Legendary", NumValue=400000000},
    {Name="Camel Egg", Zone="Prehistoric", Value="300M/s", Type="Epic", NumValue=300000000},
    {Name="Fennec Egg", Zone="Prehistoric", Value="220M/s", Type="Epic", NumValue=220000000},
    {Name="Jerboa Egg", Zone="Prehistoric", Value="150M/s", Type="Epic", NumValue=150000000},
    -- Abyss Ocean
    {Name="Moby Egg", Zone="Abyss", Value="100M/s", Type="Legendary", NumValue=100000000},
    {Name="Leviathan Egg", Zone="Abyss", Value="70M/s", Type="Legendary", NumValue=70000000},
    {Name="Axolotl Egg", Zone="Abyss", Value="45M/s", Type="Epic", NumValue=45000000},
    {Name="Swan Egg", Zone="Abyss", Value="30M/s", Type="Epic", NumValue=30000000},
    {Name="Trulimero Egg", Zone="Abyss", Value="22M/s", Type="Epic", NumValue=22000000},
    {Name="Turtle Egg", Zone="Abyss", Value="15M/s", Type="Rare", NumValue=15000000},
    {Name="Catfish Egg", Zone="Abyss", Value="10M/s", Type="Rare", NumValue=10000000},
    {Name="Duckling Egg", Zone="Abyss", Value="7M/s", Type="Rare", NumValue=7000000},
    {Name="Frog Egg", Zone="Abyss", Value="5M/s", Type="Rare", NumValue=5000000},
    -- Volcano
    {Name="Cerberus Egg", Zone="Volcano", Value="3.5M/s", Type="Legendary", NumValue=3500000},
    {Name="Magma Golem Egg", Zone="Volcano", Value="2.5M/s", Type="Epic", NumValue=2500000},
    {Name="Lava Turtle Egg", Zone="Volcano", Value="1.8M/s", Type="Epic", NumValue=1800000},
    {Name="Flaming Bull Egg", Zone="Volcano", Value="1.2M/s", Type="Epic", NumValue=1200000},
    {Name="Lava Frog Egg", Zone="Volcano", Value="850K/s", Type="Rare", NumValue=850000},
    {Name="Lava Gecko Egg", Zone="Volcano", Value="600K/s", Type="Rare", NumValue=600000},
    -- Snow
    {Name="Ice Dragon Egg", Zone="Snow", Value="450K/s", Type="Legendary", NumValue=450000},
    {Name="Yeti Egg", Zone="Snow", Value="300K/s", Type="Epic", NumValue=300000},
    {Name="King Mammoth Egg", Zone="Snow", Value="220K/s", Type="Epic", NumValue=220000},
    {Name="Mammoth Egg", Zone="Snow", Value="150K/s", Type="Rare", NumValue=150000},
    {Name="Sabertooth Egg", Zone="Snow", Value="100K/s", Type="Rare", NumValue=100000},
    {Name="Polar Bear Egg", Zone="Snow", Value="75K/s", Type="Rare", NumValue=75000},
    {Name="Walrus Egg", Zone="Snow", Value="50K/s", Type="Common", NumValue=50000},
    {Name="Penguin Egg", Zone="Snow", Value="35K/s", Type="Common", NumValue=35000},
    -- Jungle
    {Name="King Snake Egg", Zone="Jungle", Value="25K/s", Type="Rare", NumValue=25000},
    {Name="Tiger Egg", Zone="Jungle", Value="18K/s", Type="Rare", NumValue=18000},
    {Name="Spider Egg", Zone="Jungle", Value="12K/s", Type="Common", NumValue=12000},
    {Name="Orangutini Egg", Zone="Jungle", Value="8K/s", Type="Common", NumValue=8000},
    {Name="Gorilla Egg", Zone="Jungle", Value="4.8K/s", Type="Common", NumValue=4800},
    {Name="Crocodile Egg", Zone="Jungle", Value="2.5K/s", Type="Common", NumValue=2500},
    {Name="Chimpanzee Egg", Zone="Jungle", Value="1.2K/s", Type="Common", NumValue=1200},
    {Name="Toucan Egg", Zone="Jungle", Value="500/s", Type="Common", NumValue=500}
}

-- បង្កើត UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- ប៊ូតុងមូល (Nhaz)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Text = "Nhaz"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Color = Color3.fromRGB(0, 255, 127)
stroke.Thickness = 2

-- ផ្ទាំង Menu
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "Nhaz Auto Steal"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 35)
AutoBtn.Position = UDim2.new(0, 10, 0, 40)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 14
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 6)

local TogglesFrame = Instance.new("Frame", Main)
TogglesFrame.Size = UDim2.new(1, -20, 0, 35)
TogglesFrame.Position = UDim2.new(0, 10, 0, 80)
TogglesFrame.BackgroundTransparency = 1

local GuardBtn = Instance.new("TextButton", TogglesFrame)
GuardBtn.Size = UDim2.new(0.3, 0, 1, 0)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 11
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", TogglesFrame)
TrapBtn.Size = UDim2.new(0.3, 0, 1, 0)
TrapBtn.Position = UDim2.new(0.35, 0, 0, 0)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 11
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local SpeedBox = Instance.new("TextBox", TogglesFrame)
SpeedBox.Size = UDim2.new(0.3, 0, 1, 0)
SpeedBox.Position = UDim2.new(0.7, 0, 0, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBox.Text = "100%"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 12
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 4)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -135)
Scroll.Position = UDim2.new(0, 10, 0, 125)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, #EggData * 40)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 1, -25)
Status.BackgroundTransparency = 1
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

-- បង្កើតបញ្ជីពង
for _, data in ipairs(EggData) do
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.Text = "["..data.Type.."] "..data.Name.." ("..data.Value..")"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        SelectedEgg = data.Name:gsub(" Egg", "")
        AutoSteal = true
        AutoBtn.Text = "Auto Steal: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        for _, c in pairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
        end
        Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    end)
end

-- មុខងារ Toggle
AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    if AutoSteal then
        if not SelectedEgg then SelectedEgg = EggData[1].Name:gsub(" Egg", "") end
        AutoBtn.Text = "Auto Steal: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AutoBtn.Text = "Auto Steal: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Status.Text = "Stopped."
    end
end)

GuardBtn.MouseButton1Click:Connect(function()
    AntiGuard = not AntiGuard
    GuardBtn.Text = "Guard: "..(AntiGuard and "ON" or "OFF")
    GuardBtn.BackgroundColor3 = AntiGuard and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

TrapBtn.MouseButton1Click:Connect(function()
    AntiTrap = not AntiTrap
    TrapBtn.Text = "Trap: "..(AntiTrap and "ON" or "OFF")
    TrapBtn.BackgroundColor3 = AntiTrap and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text:gsub("%D", ""))
    if val then
        SpeedPercentage = math.clamp(val, 10, 200)
        SpeedBox.Text = tostring(SpeedPercentage).."%"
    else
        SpeedBox.Text = "100%"
        SpeedPercentage = 100
    end
end)

-- មុខងារស្វែងរកពង
local function GetEggPart()
    if not SelectedEgg then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find(SelectedEgg:lower()) then
            local part = obj:FindFirstChildWhichIsA("BasePart") or obj
            if part and part.Position then return part end
        end
    end
    return nil
end

-- ៤. Auto Steal Loop (ប្រើ Heartbeat ដើម្បីកុំឱ្យគាំង)
local targetPart = nil
local isResting = false
local restEndTime = 0

RunService.Heartbeat:Connect(function(dt)
    if not AutoSteal then return end
    local HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not HRP or not SelectedEgg then return end

    -- ប្រព័ន្ធឈប់សម្រាក (Resting)
    if isResting then
        if tick() >= restEndTime then
            isResting = false
            CurrentZones = 0
            Status.Text = "Resuming..."
        else
            return
        end
    end

    -- Anti Guard & Trap
    if AntiGuard then
        for _, m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and (m.Name:lower():find("guard") or m.Name:lower():find("tiger")) then
                local root = m:FindFirstChild("HumanoidRootPart")
                if root and (HRP.Position - root.Position).Magnitude < 30 then
                    HRP.CFrame = HRP.CFrame + Vector3.new(0, 50, 0)
                end
            end
        end
    end

    if not targetPart or not targetPart.Parent then
        targetPart = GetEggPart()
    end

    if targetPart then
        local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
        local distance = (HRP.Position - targetPos).Magnitude

        if distance > 5 then
            Status.Text = "Flying to: "..SelectedEgg
            -- គណនាល្បឿនហោះរលូន (មិនឱ្យលឿនដូច Teleport)
            local speed = SpeedPercentage * 0.4
            local alpha = math.clamp((speed * dt) / distance, 0, 1)
            HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(targetPos), alpha)
        else
            Status.Text = "Stealing: "..SelectedEgg
            local prompt = targetPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) or targetPart:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
            
            targetPart = nil
            CurrentZones = CurrentZones + 1
            
            -- លួចបាន ៣ ដង ទម្លាក់ខ្លួនចុះដី
            if CurrentZones >= StopZones then
                Status.Text = "Resting (Dropped to ground)..."
                HRP.CFrame = CFrame.new(HRP.Position.X, 5, HRP.Position.Z)
                isResting = true
                restEndTime = tick() + 2
            else
                isResting = true
                restEndTime = tick() + 0.5
            end
        end
    else
        Status.Text = "Waiting for egg to spawn..."
    end
end)
