-- [[ Nhaz Auto Steal - Floating Circle UI ]]
-- Smooth Fly | Sort by Value | Anti Trap/Guard | 3 Zone Drop

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ការកំណត់
local AutoSteal = false
local SelectedEgg = nil
local StopZones = 3
local CurrentZones = 0
local SpeedPercentage = 100
local AntiGuard = true
local AntiTrap = true

-- ទិន្នន័យពង (តម្លៃពិត)
local EggData = {
    {Name="Celestial Sunlion Egg", Zone="Enchanted", Value="500T/s", Type="Divine", NumValue=500000000000000},
    {Name="Starry Fox Egg", Zone="Enchanted", Value="250T/s", Type="Eternal", NumValue=250000000000000},
    {Name="Titan Temple Egg", Zone="Titan", Value="100T/s", Type="Divine", NumValue=100000000000000},
    {Name="Cherry Blossom Egg", Zone="Cherry", Value="50T/s", Type="Eternal", NumValue=50000000000000},
    {Name="Cosmic Egg", Zone="Cosmic", Value="25T/s", Type="Divine", NumValue=25000000000000},
    {Name="T-Rex Egg", Zone="Prehistoric", Value="10T/s", Type="Eternal", NumValue=10000000000000},
    {Name="Royal Sphinx Egg", Zone="Prehistoric", Value="5T/s", Type="Divine", NumValue=5000000000000},
    {Name="Sand Spider Egg", Zone="Prehistoric", Value="2T/s", Type="Legendary", NumValue=2000000000000},
    {Name="Scorpion Egg", Zone="Prehistoric", Value="1T/s", Type="Legendary", NumValue=1000000000000},
    {Name="Snake Egg", Zone="Prehistoric", Value="500B/s", Type="Legendary", NumValue=500000000000},
    {Name="Tob Tob Tob Egg", Zone="Prehistoric", Value="250B/s", Type="Legendary", NumValue=250000000000},
    {Name="Camel Egg", Zone="Prehistoric", Value="100B/s", Type="Epic", NumValue=100000000000},
    {Name="Fennec Egg", Zone="Prehistoric", Value="50B/s", Type="Epic", NumValue=50000000000},
    {Name="Jerboa Egg", Zone="Prehistoric", Value="25B/s", Type="Epic", NumValue=25000000000},
    {Name="Moby Egg", Zone="Abyss", Value="10B/s", Type="Legendary", NumValue=10000000000},
    {Name="Leviathan Egg", Zone="Abyss", Value="5B/s", Type="Legendary", NumValue=5000000000},
    {Name="Axolotl Egg", Zone="Abyss", Value="2B/s", Type="Epic", NumValue=2000000000},
    {Name="Swan Egg", Zone="Abyss", Value="1B/s", Type="Epic", NumValue=1000000000},
    {Name="Trulimero Trulicina Egg", Zone="Abyss", Value="500M/s", Type="Epic", NumValue=500000000},
    {Name="Turtle Egg", Zone="Abyss", Value="250M/s", Type="Rare", NumValue=250000000},
    {Name="Catfish Egg", Zone="Abyss", Value="100M/s", Type="Rare", NumValue=100000000},
    {Name="Duckling Egg", Zone="Abyss", Value="50M/s", Type="Rare", NumValue=50000000},
    {Name="Frog Egg", Zone="Abyss", Value="25M/s", Type="Rare", NumValue=25000000},
    {Name="Cerberus Egg", Zone="Volcano", Value="10M/s", Type="Legendary", NumValue=10000000},
    {Name="Magma Golem Egg", Zone="Volcano", Value="5M/s", Type="Epic", NumValue=5000000},
    {Name="Lava Turtle Egg", Zone="Volcano", Value="2M/s", Type="Epic", NumValue=2000000},
    {Name="Flaming Bull Egg", Zone="Volcano", Value="1M/s", Type="Epic", NumValue=1000000},
    {Name="Lava Frog Egg", Zone="Volcano", Value="500K/s", Type="Rare", NumValue=500000},
    {Name="Lava Gecko Egg", Zone="Volcano", Value="250K/s", Type="Rare", NumValue=250000},
    {Name="Ice Dragon Egg", Zone="Snow", Value="100K/s", Type="Legendary", NumValue=100000},
    {Name="Yeti Egg", Zone="Snow", Value="50K/s", Type="Epic", NumValue=50000},
    {Name="King Mammoth Egg", Zone="Snow", Value="25K/s", Type="Epic", NumValue=25000},
    {Name="Mammoth Egg", Zone="Snow", Value="10K/s", Type="Rare", NumValue=10000},
    {Name="Sabertooth Tiger Egg", Zone="Snow", Value="5K/s", Type="Rare", NumValue=5000},
    {Name="Polar Bear Egg", Zone="Snow", Value="2K/s", Type="Rare", NumValue=2000},
    {Name="Walrus Egg", Zone="Snow", Value="1K/s", Type="Common", NumValue=1000},
    {Name="Penguin Egg", Zone="Snow", Value="500/s", Type="Common", NumValue=500},
    {Name="King Snake Egg", Zone="Jungle", Value="250/s", Type="Rare", NumValue=250},
    {Name="Tiger Egg", Zone="Jungle", Value="100/s", Type="Rare", NumValue=100},
    {Name="Spider Egg", Zone="Jungle", Value="50/s", Type="Common", NumValue=50},
    {Name="Orangutini Egg", Zone="Jungle", Value="25/s", Type="Common", NumValue=25},
    {Name="Gorilla Egg", Zone="Jungle", Value="10/s", Type="Common", NumValue=10},
    {Name="Crocodile Egg", Zone="Jungle", Value="5/s", Type="Common", NumValue=5},
    {Name="Chimpanzee Egg", Zone="Jungle", Value="2/s", Type="Common", NumValue=2},
    {Name="Toucan Egg", Zone="Jungle", Value="1/s", Type="Common", NumValue=1}
}

-- តម្រៀបពងតាមតម្លៃខ្ពស់ជាងគេ
table.sort(EggData, function(a, b) return a.NumValue > b.NumValue end)

-- ស្កេនរកពងក្នុង Map
local AvailableEggs = {}
for _, data in ipairs(EggData) do
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find(data.Name:gsub(" Egg", ""):lower()) then
            table.insert(AvailableEggs, data)
            break
        end
    end
end

-- បង្កើត UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_UI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- ប៊ូតុងមូល (Nhaz Logo)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ToggleBtn.Text = "Nhaz"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Draggable = true -- អូសបានស្រួល
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Color = Color3.fromRGB(0, 255, 127)
stroke.Thickness = 2

-- ផ្ទាំង Menu ធំ (លាក់ទុកមុន)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- ចុចប៊ូតុងមូល ដើម្បីបើក/បិទ Menu
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Auto Steal Button (នៅលើគេ)
local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 35)
AutoBtn.Position = UDim2.new(0, 10, 0, 10)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF (Highest Value)"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 14
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 6)

-- Toggles (Anti Guard, Anti Trap, Speed)
local TogglesFrame = Instance.new("Frame", Main)
TogglesFrame.Size = UDim2.new(1, -20, 0, 70)
TogglesFrame.Position = UDim2.new(0, 10, 0, 50)
TogglesFrame.BackgroundTransparency = 1

local GuardBtn = Instance.new("TextButton", TogglesFrame)
GuardBtn.Size = UDim2.new(0.3, 0, 0, 30)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Anti Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 11
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", TogglesFrame)
TrapBtn.Size = UDim2.new(0.3, 0, 0, 30)
TrapBtn.Position = UDim2.new(0.35, 0, 0, 0)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Anti Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 11
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local SpeedBox = Instance.new("TextBox", TogglesFrame)
SpeedBox.Size = UDim2.new(0.3, 0, 0, 30)
SpeedBox.Position = UDim2.new(0.7, 0, 0, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBox.Text = "100%"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 12
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 4)

-- List of Eggs
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -140)
Scroll.Position = UDim2.new(0, 10, 0, 130)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, #AvailableEggs * 40)
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

for _, data in ipairs(AvailableEggs) do
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.Text = "["..data.Type.."] "..data.Name.." ("..data.Value..")"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        SelectedEgg = data.Name:gsub(" Egg", "")
        AutoSteal = true
        AutoBtn.Text = "Auto Steal: ON (Target: "..SelectedEgg..")"
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
        if not SelectedEgg and #AvailableEggs > 0 then
            SelectedEgg = AvailableEggs[1].Name:gsub(" Egg", "") -- យកពងថ្លៃជាងគេបំផុត
        end
        AutoBtn.Text = "Auto Steal: ON (Target: "..(SelectedEgg or "None")..")"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AutoBtn.Text = "Auto Steal: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

GuardBtn.MouseButton1Click:Connect(function()
    AntiGuard = not AntiGuard
    GuardBtn.Text = "Anti Guard: "..(AntiGuard and "ON" or "OFF")
    GuardBtn.BackgroundColor3 = AntiGuard and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

TrapBtn.MouseButton1Click:Connect(function()
    AntiTrap = not AntiTrap
    TrapBtn.Text = "Anti Trap: "..(AntiTrap and "ON" or "OFF")
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
            return obj:FindFirstChildWhichIsA("BasePart") or obj
        end
    end
    return nil
end

-- Auto Steal Loop
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEgg then
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

            local eggPart = GetEggPart()
            if eggPart then
                local targetPos = eggPart.Position + Vector3.new(0, 3, 0)
                local distance = (HRP.Position - targetPos).Magnitude

                if distance > 5 then
                    local lerpAlpha = 0.3 * (SpeedPercentage / 100)
                    HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(targetPos), lerpAlpha)
                    Status.Text = "Flying to: "..SelectedEgg.." ("..SpeedPercentage.."%)"
                else
                    Status.Text = "Stealing: "..SelectedEgg
                    local prompt = eggPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                    
                    task.wait(0.5)
                    CurrentZones = CurrentZones + 1
                    
                    -- ទម្លាក់ខ្លួនចុះដីរាល់ពេលលួចបាន ៣ ដង
                    if CurrentZones >= StopZones then
                        Status.Text = "Resting (Dropped to ground)..."
                        HRP.CFrame = CFrame.new(HRP.Position.X, 5, HRP.Position.Z)
                        task.wait(2)
                        CurrentZones = 0
                    end
                end
            else
                Status.Text = "Waiting for egg to spawn..."
            end
        end
    end
end)
