-- [[ Nhaz Auto Steal - Run Mode & Fixed Scanner ]]
-- Run on ground | Anti Trap/Guard | Real Values | Stop 3 Zones

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local StopZones = 3
local CurrentZones = 0
local RunSpeed = 80 -- ល្បឿនរត់ (មិនលឿនពេក មិនយឺតពេក)
local AntiTrap = true
local AntiGuard = true

-- មុខងារបំប្លែងអក្សរទៅជាលេខ
local function ParseValue(str)
    if not str then return 0 end
    local text = str:lower()
    local num = tonumber(text:match("([%d%.]+)"))
    if not num then return 0 end
    if text:find("k") then return num * 1000
    elseif text:find("m") then return num * 1000000
    elseif text:find("b") then return num * 1000000000
    elseif text:find("t") then return num * 1000000000000
    else return num end
end

-- ស្កេនរកពងទាំងអស់ក្នុង Map (កែឱ្យស្កេនពេញលេញ)
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            -- ការពារកុំឱ្យវាស្កេនយកពងក្នុង Base (ជាទូទៅមានឈ្មោះថា Base ឬមានពាក្យថា Player)
            local parentName = obj.Parent and obj.Parent.Name or ""
            if not parentName:lower():find("base") and not parentName:lower():find("spawn") and not seen[cleanName] then
                seen[cleanName] = true
                
                local valueStr = "Unknown"
                local valueNum = 0
                local eggType = "Common"
                
                if obj.Name:lower():find("divine") then eggType = "Divine"
                elseif obj.Name:lower():find("eternal") then eggType = "Eternal"
                elseif obj.Name:lower():find("legendary") then eggType = "Legendary"
                elseif obj.Name:lower():find("epic") then eggType = "Epic"
                elseif obj.Name:lower():find("rare") then eggType = "Rare"
                end
                
                -- អានតម្លៃពិតពី Billboard ឬ TextLabel
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("TextLabel") and (desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("T") or desc.Text:find("K")) then
                        valueStr = desc.Text
                        valueNum = ParseValue(valueStr)
                        break
                    end
                end
                
                table.insert(found, {Model = obj, Name = cleanName:gsub(" Egg", ""), ValueStr = valueStr, ValueNum = valueNum, Type = eggType})
            end
        end
    end
    table.sort(found, function(a, b) return a.ValueNum > b.ValueNum end)
    return found
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu"
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
Main.Size = UDim2.new(0, 320, 0, 450)
Main.Position = UDim2.new(0.5, -160, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 35)
AutoBtn.Position = UDim2.new(0, 10, 0, 10)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 14
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 6)

-- បន្ថែម Anti Trap & Guard
local GuardBtn = Instance.new("TextButton", Main)
GuardBtn.Size = UDim2.new(0.3, 0, 0, 25)
GuardBtn.Position = UDim2.new(0, 10, 0, 50)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 11
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", Main)
TrapBtn.Size = UDim2.new(0.3, 0, 0, 25)
TrapBtn.Position = UDim2.new(0.35, 0, 0, 50)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 11
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", Main)
RefreshBtn.Size = UDim2.new(0.3, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.7, 0, 0, 50)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 12
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -160)
Scroll.Position = UDim2.new(0, 10, 0, 85)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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

-- បង្កើត UI
local function UpdateUI()
    for _, c in pairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local MapEggs = ScanMapEggs()
    for _, data in ipairs(MapEggs) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, -10, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Btn.Text = "["..data.Type.."] "..data.Name.." ("..data.ValueStr..")"
        Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        Btn.MouseButton1Click:Connect(function()
            SelectedEggObj = data.Model
            AutoSteal = true
            AutoBtn.Text = "Auto Steal: ON"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            for _, c in pairs(Scroll:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #MapEggs * 40)
end

RefreshBtn.MouseButton1Click:Connect(UpdateUI)
UpdateUI()

-- Toggle Functions
AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoBtn.Text = AutoSteal and "Auto Steal: ON" or "Auto Steal: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if AutoSteal and not SelectedEggObj then
        local eggs = ScanMapEggs()
        if #eggs > 0 then SelectedEggObj = eggs[1].Model end
    end
    
    if not AutoSteal then
        Status.Text = "Status: Stopped"
        local Char = LP.Character
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then 
            Hum.WalkSpeed = 16 -- ត្រឡប់មកល្បឿនធម្មតាវិញ
            Hum:MoveTo(Char.HumanoidRootPart.Position) -- បញ្ឈប់ការរត់
        end
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

-- Main Loop (រត់លើដី + Anti Guard/Trap)
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                -- បើពងនោះបាត់ (ត្រូវគេលួចមុន) រកពងថ្មី
                if not SelectedEggObj.Parent then
                    Status.Text = "Egg gone! Finding new one..."
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then
                        SelectedEggObj = eggs[1].Model
                    else
                        SelectedEggObj = nil
                        AutoSteal = false
                        AutoBtn.Text = "Auto Steal: OFF"
                        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    end
                    task.wait(1)
                    continue
                end

                -- Anti Guard (បើមាន Guard មកជិត លោតគេច)
                if AntiGuard then
                    for _, m in ipairs(workspace:GetDescendants()) do
                        if m:IsA("Model") and (m.Name:lower():find("guard") or m.Name:lower():find("police") or m.Name:lower():find("tiger")) then
                            local root = m:FindFirstChild("HumanoidRootPart")
                            if root and (HRP.Position - root.Position).Magnitude < 25 then
                                Hum.Jump = true
                            end
                        end
                    end
                end
                
                -- Anti Trap (បើមាន Trap ជិត លោតគេច)
                if AntiTrap then
                    for _, t in ipairs(workspace:GetDescendants()) do
                        if t:IsA("Part") and (t.Name:lower():find("trap") or t.Name:lower():find("spike")) then
                            if (HRP.Position - t.Position).Magnitude < 15 then
                                Hum.Jump = true
                            end
                        end
                    end
                end

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                
                Status.Text = "Running to: "..SelectedEggObj.Name:gsub(" Egg", "")
                Hum.WalkSpeed = RunSpeed
                Hum:MoveTo(targetPos) 
                
                local dist = (HRP.Position - targetPos).Magnitude
                if dist < 6 then
                    -- ដល់ហើយ ឈប់រត់ ហើយលួច
                    Hum:MoveTo(HRP.Position) 
                    Status.Text = "Stealing: "..SelectedEggObj.Name:gsub(" Egg", "")
                    
                    for _, v in pairs(SelectedEggObj:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                            v.MaxActivationDistance = 50
                            v.Enabled = true
                            pcall(function() fireproximityprompt(v) end)
                        elseif v:IsA("ClickDetector") then
                            pcall(function() fireclickdetector(v) end)
                        end
                    end
                    
                    task.wait(1.5) -- រង់ចាំបន្តិច
                    CurrentZones = CurrentZones + 1
                    
                    -- បើលួចបាន ៣ ដង ឈប់ឈរ
                    if CurrentZones >= StopZones then
                        Status.Text = "Resting..."
                        Hum:MoveTo(HRP.Position) 
                        task.wait(2)
                        CurrentZones = 0
                        
                        -- រើសពងថ្មីដែលថ្លៃជាងគេ
                        local eggs = ScanMapEggs()
                        if #eggs > 0 then SelectedEggObj = eggs[1].Model end
                    end
                end
            end
        else
            -- បើបិទ Auto ធានាថាល្បឿនធម្មតា
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 then 
                Hum.WalkSpeed = 16 
            end
        end
    end
end)
