-- [[ Nhaz Hub - Ultimate Focus & Icon UI ]]
-- Strict Focus | Best Value First | Icons | Anti Guard/Trap | Fast Run

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local AntiTrap = true
local AntiGuard = true
local TargetEggName = nil
local TargetEggModel = nil

local RunSpeed = 200
local DefaultEggIcon = "rbxassetid://6928578862" -- រូបពងធម្មតា បើហ្គេមអត់មានរូប

local function ParseValue(str)
    if not str then return 0 end
    str = str:lower():gsub(",", ""):gsub("%s+", "")
    local num = tonumber(str:match("([%d%.]+)"))
    if not num then return 0 end
    if str:find("k") then return num * 1000
    elseif str:find("m") then return num * 1000000
    elseif str:find("b") then return num * 1000000000
    elseif str:find("t") then return num * 1000000000000
    elseif str:find("qa") then return num * 1000000000000000
    else return num end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Hub_Final"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

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

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Nhaz Focus Steal"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 30)
AutoBtn.Position = UDim2.new(0, 10, 0, 40)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 13
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 4)

local GuardBtn = Instance.new("TextButton", Main)
GuardBtn.Size = UDim2.new(0.3, 0, 0, 25)
GuardBtn.Position = UDim2.new(0.03, 0, 0, 75)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 11
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", Main)
TrapBtn.Size = UDim2.new(0.3, 0, 0, 25)
TrapBtn.Position = UDim2.new(0.35, 0, 0, 75)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 11
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", Main)
RefreshBtn.Size = UDim2.new(0.3, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.67, 0, 0, 75)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 11
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -150)
Scroll.Position = UDim2.new(0, 10, 0, 105)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 4)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 1, -25)
Status.BackgroundTransparency = 1
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

task.wait(0.1)
Main.Visible = true

-- មុខងារស្កេនរកពង
local function ScanMapEggs()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("egg") then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            local isBase = obj.Name:lower():find("firstarea") or obj.Name:lower():find("shop") or obj.Name:lower():find("holder") or (obj.Parent and obj.Parent.Name:lower():find("base"))
            
            if prompt and not isBase then
                local valueStr = "Unknown"
                local icon = DefaultEggIcon
                
                -- ស្កេនរកតម្លៃ និងរូបភាពពី Billboard
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then valueStr = lbl.Text end
                    
                    local img = bb:FindFirstChildWhichIsA("ImageLabel", true)
                    if img and img.Image ~= "" then icon = img.Image end
                end
                
                local valueNum = ParseValue(valueStr)
                if valueNum > 0 then
                    table.insert(found, {
                        Model = obj, 
                        Name = obj.Name:gsub(" Egg", ""), 
                        ValueStr = valueStr, 
                        ValueNum = valueNum,
                        Icon = icon
                    })
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.ValueNum > b.ValueNum end)
    return found
end

local function UpdateUI()
    for _, c in pairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    Status.Text = "Status: Scanning Map..."
    task.wait(0.1)
    
    local MapEggs = ScanMapEggs()
    
    for _, data in ipairs(MapEggs) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, -5, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        local Icon = Instance.new("ImageLabel", Btn)
        Icon.Size = UDim2.new(0, 30, 0, 30)
        Icon.Position = UDim2.new(0, 5, 0, 5)
        Icon.BackgroundTransparency = 1
        Icon.Image = data.Icon
        Icon.ScaleType = Enum.ScaleType.Fit

        local NameLbl = Instance.new("TextLabel", Btn)
        NameLbl.Size = UDim2.new(0.5, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 40, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = data.Name
        NameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        NameLbl.Font = Enum.Font.SourceSansBold
        NameLbl.TextSize = 12
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local ValLbl = Instance.new("TextLabel", Btn)
        ValLbl.Size = UDim2.new(0.35, 0, 1, 0)
        ValLbl.Position = UDim2.new(0.6, 0, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = data.ValueStr
        ValLbl.TextColor3 = Color3.fromRGB(0, 255, 127)
        ValLbl.Font = Enum.Font.SourceSansBold
        ValLbl.TextSize = 12
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right

        Btn.MouseButton1Click:Connect(function()
            TargetEggName = data.Name
            TargetEggModel = data.Model
            AutoSteal = true
            
            AutoBtn.Text = "Auto Steal: ON"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            Status.Text = "Status: Locked on "..data.Name
            
            for _, c in pairs(Scroll:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #MapEggs * 45)
    Status.Text = "Status: Found "..#MapEggs.." eggs."
end

task.spawn(function() task.wait(1) UpdateUI() end)
RefreshBtn.MouseButton1Click:Connect(UpdateUI)

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

AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoBtn.Text = AutoSteal and "Auto Steal: ON" or "Auto Steal: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if not AutoSteal then
        Status.Text = "Status: Stopped"
        TargetEggName = nil
        TargetEggModel = nil
        local Char = LP.Character
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then 
            Hum.WalkSpeed = 16
            Hum:MoveTo(Char.HumanoidRootPart.Position) 
        end
    end
end)

-- Main Loop (Focus & Fast Run)
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and TargetEggName then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                -- Anti Guard & Trap
                if AntiGuard or AntiTrap then
                    for _, m in ipairs(workspace:GetChildren()) do
                        if m:IsA("Model") then
                            local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if root then
                                local dist = (HRP.Position - root.Position).Magnitude
                                if AntiGuard and (m.Name:lower():find("guard") or m.Name:lower():find("police")) and dist < 25 then
                                    Hum.Jump = true
                                elseif AntiTrap and (m.Name:lower():find("trap") or m.Name:lower():find("spike")) and dist < 15 then
                                    Hum.Jump = true
                                end
                            end
                        end
                    end
                end

                -- បើពងបាត់ (ដោយសារតែអ្នកលួចវាបានហើយ)
                if not TargetEggModel or not TargetEggModel.Parent then
                    Status.Text = "Status: Stole "..TargetEggName.."! Waiting for respawn..."
                    Hum:MoveTo(HRP.Position) -- ឈប់រត់
                    
                    -- ព្យាយាមរកពងដែលមានឈ្មោះដូចគ្នាឡើងវិញ
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find(TargetEggName:lower()) then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                TargetEggModel = obj
                                break
                            end
                        end
                    end
                    task.wait(0.5)
                    continue
                end

                local targetPos = TargetEggModel.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    -- Focus ទៅតែពងនោះ
                    Status.Text = "Status: Running to "..TargetEggName
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(targetPos)
                    
                    -- បើជាប់ជញ្ជាំង លោត
                    if HRP.Velocity.Magnitude < 2 then Hum.Jump = true end
                else
                    -- ដល់ហើយ លួច
                    Hum:MoveTo(HRP.Position)
                    Status.Text = "Status: Stealing "..TargetEggName
                    
                    for _, v in pairs(TargetEggModel:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                            v.MaxActivationDistance = 50
                            pcall(function() fireproximityprompt(v) end)
                        end
                    end
                    
                    task.wait(0.5)
                    
                    -- រត់ថយក្រោយបន្តិច ដើម្បីកុំឱ្យជាប់គ្នា
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(HRP.Position + (HRP.Position - targetPos).Unit * 20)
                    task.wait(0.5)
                end
            end
        else
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 then Hum.WalkSpeed = 16 end
        end
    end
end)
