-- [[ Nhaz Auto Steal - Ultra Fast Fly ]]
-- Features: Fast Speed, Map Filter, Values, Loading Screen

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- កំណត់ល្បឿន (០.៨៥ គឺលឿនខ្លាំងតែរលូន)
local FlySpeed = 0.85 
local FlyHeight = 4 
local MaxZones = 3
local Active = false
local TargetEggName = ""
local ZoneCounter = 0

-- ទិន្នន័យពង
local EggDB = {
    ["Toucan Egg"] = {Zone="Jungle", Value="500K/s"}, ["Chimpanzee Egg"] = {Zone="Jungle", Value="1.2M/s"},
    ["Crocodile Egg"] = {Zone="Jungle", Value="2.5M/s"}, ["Gorilla Egg"] = {Zone="Jungle", Value="4.8M/s"},
    ["Orangutini Egg"] = {Zone="Jungle", Value="8M/s"}, ["Spider Egg"] = {Zone="Jungle", Value="12M/s"},
    ["Tiger Egg"] = {Zone="Jungle", Value="18M/s"}, ["King Snake Egg"] = {Zone="Jungle", Value="25M/s"},
    ["Penguin Egg"] = {Zone="Snow", Value="35M/s"}, ["Walrus Egg"] = {Zone="Snow", Value="50M/s"},
    ["Polar Bear Egg"] = {Zone="Snow", Value="75M/s"}, ["Sabertooth Egg"] = {Zone="Snow", Value="100M/s"},
    ["Mammoth Egg"] = {Zone="Snow", Value="150M/s"}, ["Yeti Egg"] = {Zone="Snow", Value="300M/s"},
    ["Ice Dragon Egg"] = {Zone="Snow", Value="450M/s"}, ["Lava Gecko Egg"] = {Zone="Volcano", Value="600M/s"},
    ["Lava Frog Egg"] = {Zone="Volcano", Value="850M/s"}, ["Flaming Bull Egg"] = {Zone="Volcano", Value="1.2B/s"},
    ["Lava Turtle Egg"] = {Zone="Volcano", Value="1.8B/s"}, ["Magma Golem Egg"] = {Zone="Volcano", Value="2.5B/s"},
    ["Cerberus Egg"] = {Zone="Volcano", Value="3.5B/s"}, ["Frog Egg"] = {Zone="Abyss", Value="5B/s"},
    ["Duckling Egg"] = {Zone="Abyss", Value="7B/s"}, ["Catfish Egg"] = {Zone="Abyss", Value="10B/s"},
    ["Turtle Egg"] = {Zone="Abyss", Value="15B/s"}, ["Axolotl Egg"] = {Zone="Abyss", Value="45B/s"},
    ["Leviathan Egg"] = {Zone="Abyss", Value="70B/s"}, ["Moby Egg"] = {Zone="Abyss", Value="100B/s"},
    ["T-Rex Egg"] = {Zone="Prehistoric", Value="2T/s"}, ["Cosmic Egg"] = {Zone="Cosmic", Value="5T/s"},
    ["Cherry Blossom Egg"] = {Zone="Cherry", Value="10T/s"}, ["Titan Temple Egg"] = {Zone="Titan", Value="25T/s"},
    ["Starry Fox Egg"] = {Zone="Enchanted", Value="50T/s"}, ["Sunlion Egg"] = {Zone="Enchanted", Value="100T/s"}
}

-- ១. Loading Screen
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "Nhaz_Load"
LoadGui.ResetOnSpawn = false
pcall(function() LoadGui.Parent = CoreGui end)
if not LoadGui.Parent then LoadGui.Parent = LP:WaitForChild("PlayerGui") end

local LoadFrame = Instance.new("Frame", LoadGui)
LoadFrame.Size = UDim2.new(0, 250, 0, 80)
LoadFrame.Position = UDim2.new(0.5, -125, 0.5, -40)
LoadFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
LoadFrame.BorderSizePixel = 0
Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 10)

local LoadText = Instance.new("TextLabel", LoadFrame)
LoadText.Size = UDim2.new(1, 0, 0, 40)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Loading Script... 0%"
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.Font = Enum.Font.SourceSansBold
LoadText.TextSize = 16

local BarBg = Instance.new("Frame", LoadFrame)
BarBg.Size = UDim2.new(0.8, 0, 0, 10)
BarBg.Position = UDim2.new(0.1, 0, 0.7, 0)
BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 5)

local Bar = Instance.new("Frame", BarBg)
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
Bar.BorderSizePixel = 0
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 5)

local function UpdateLoad(pct)
    LoadText.Text = "Loading Script... " .. pct .. "%"
    TweenService:Create(Bar, TweenInfo.new(0.2), {Size = UDim2.new(pct/100, 0, 1, 0)}):Play()
    task.wait(0.2)
end

UpdateLoad(30)

-- ២. ស្កេនរកពងក្នុង Map
local MapEggs = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
        for name, data in pairs(EggDB) do
            if obj.Name:lower():find(name:gsub(" Egg", ""):lower()) then
                MapEggs[name] = data
            end
        end
    end
end

UpdateLoad(60)

-- ៣. បង្កើត UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "⚙️"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.5, -190)
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
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "Nhaz Auto Steal ("..#MapEggs..")"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -10, 0, 20)
Status.Position = UDim2.new(0, 5, 1, -25)
Status.BackgroundTransparency = 1
Status.Text = "Status: Select an Egg"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -65)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, #MapEggs * 40)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 4)

for name, data in pairs(MapEggs) do
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, -5, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Btn.Text = "["..data.Zone.."] "..name.." | "..data.Value
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        TargetEggName = name:gsub(" Egg", "")
        Status.Text = "Stealing: "..TargetEggName
        Active = true 
        
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end
        end
        Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    end)
end

UpdateLoad(100)

task.delay(1, function()
    if LoadGui then LoadGui:Destroy() end
    Main.Visible = true
end)

-- ៤. មុខងារហោះ និង លួច (លឿនបំផុត)
local function GetEggPart()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find(TargetEggName:lower()) then
            return obj:FindFirstChildWhichIsA("BasePart") or obj
        end
    end
    return nil
end

-- ប្រើ RunService ដើម្បីឱ្យល្បឿនហោះលឿនដល់កម្រិត Frame
RunService.Heartbeat:Connect(function()
    if Active and TargetEggName ~= "" then
        if ZoneCounter >= MaxZones then
            Status.Text = "Resting (3 Zones)..."
            task.wait(2.5)
            ZoneCounter = 0
        end

        local eggPart = GetEggPart()
        if eggPart then
            local targetPos = eggPart.Position + Vector3.new(0, FlyHeight, 0)
            local distance = (HRP.Position - targetPos).Magnitude
            
            if distance > 4 then
                -- ល្បឿន Lerp ខ្ពស់ ០.៨៥ ធ្វើឱ្យវាលឿនស្ទើរតែ Teleport តែមិនត្រូវ Kick
                HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(targetPos), FlySpeed)
            else
                Status.Text = "Stealing: "..TargetEggName
                for _, v in pairs(eggPart.Parent:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        v.HoldDuration = 0
                        pcall(function() fireproximityprompt(v) end)
                    elseif v:IsA("ClickDetector") then
                        pcall(function() fireclickdetector(v) end)
                    end
                end
                task.wait(0.2) -- ចុចលួចរួច រង់ចាំបន្តិចទៅពងបន្ទាប់
                ZoneCounter = ZoneCounter + 1
            end
        else
            Status.Text = "Waiting for egg..."
        end
    end
end)
