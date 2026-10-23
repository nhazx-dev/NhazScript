-- [[ Nhaz Auto Steal - True Value & Smooth Fly ]]
-- Moderate Speed | 3 Zone Drop | Real Billboard Values

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local StopZones = 3
local CurrentZones = 0
local FlySpeed = 35 -- ល្បឿនមធ្យម (មិនលឿនពេក មិនយឺតពេក)

-- មុខងារបំប្លែងអក្សរទៅជាលេខ (ដើម្បីតម្រៀប)
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

-- ស្កេនរកពង និងអានតម្លៃពិតពី BillboardGui
local function ScanMapEggs()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local valueStr = "Unknown"
            local valueNum = 0
            local eggType = "Common"
            
            if obj.Name:lower():find("divine") then eggType = "Divine"
            elseif obj.Name:lower():find("eternal") then eggType = "Eternal"
            elseif obj.Name:lower():find("legendary") then eggType = "Legendary"
            elseif obj.Name:lower():find("epic") then eggType = "Epic"
            elseif obj.Name:lower():find("rare") then eggType = "Rare"
            end
            
            -- អានតម្លៃពី TextLabel ឬ BillboardGui លើពង
            for _, desc in ipairs(obj:GetDescendants()) do
                if desc:IsA("TextLabel") and (desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("T") or desc.Text:find("K")) then
                    valueStr = desc.Text
                    valueNum = ParseValue(valueStr)
                    break
                end
            end
            
            table.insert(found, {
                Model = obj, 
                Name = obj.Name:gsub(" Egg", ""), 
                ValueStr = valueStr, 
                ValueNum = valueNum, 
                Type = eggType
            })
            break -- យកតែ ១ ក្នុងមួយ Model
        end
    end
    
    -- តម្រៀបពីថ្លៃទៅថោក
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
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
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

local RefreshBtn = Instance.new("TextButton", Main)
RefreshBtn.Size = UDim2.new(0.4, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.55, 0, 0, 50)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RefreshBtn.Text = "Refresh Eggs"
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

-- បង្កើត UI បញ្ជីពង
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

AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoBtn.Text = AutoSteal and "Auto Steal: ON" or "Auto Steal: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if AutoSteal and not SelectedEggObj then
        local eggs = ScanMapEggs()
        if #eggs > 0 then
            SelectedEggObj = eggs[1].Model -- យកពងថ្លៃជាងគេ
        end
    end
    
    if not AutoSteal then
        Status.Text = "Status: Stopped"
        local HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if HRP then HRP.Velocity = Vector3.new(0,0,0) end
        if Hum then Hum.PlatformStand = false end
    end
end)

-- Main Loop (Fly & Steal)
task.spawn(function()
    local bv = nil
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

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                
                -- ១. ចាប់ផ្តើមហោះ
                Status.Text = "Flying to: "..SelectedEggObj.Name:gsub(" Egg", "")
                Hum.PlatformStand = true -- ការពារការធ្លាក់
                
                if not bv or not bv.Parent then
                    bv = Instance.new("BodyVelocity", HRP)
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0,0,0)
                end

                local targetPos = eggPart.Position + Vector3.new(0, 2, 0)
                
                while AutoSteal and SelectedEggObj.Parent do
                    local dist = (HRP.Position - targetPos).Magnitude
                    if dist < 5 then break end
                    
                    -- ល្បឿនមធ្យម (មិន Teleport)
                    local dir = (targetPos - HRP.Position).Unit
                    bv.Velocity = dir * FlySpeed
                    task.wait()
                end
                
                bv.Velocity = Vector3.new(0,0,0)
                
                if AutoSteal then
                    -- ២. ពេលដល់ ចាប់ផ្តើមលួច
                    Hum.PlatformStand = false -- ឱ្យជើងជាប់ដី ដើម្បីឱ្យ Server ចាប់រាន់
                    task.wait(0.3)
                    
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
                    
                    task.wait(1.5) -- រង់ចាំបន្តិចកុំឱ្យហ្គេមចាប់បាន
                    CurrentZones = CurrentZones + 1
                    
                    -- ៣. បើបាន ៣ ដង ទម្លាក់ខ្លួន
                    if CurrentZones >= StopZones then
                        Status.Text = "Resting (Dropped to ground)..."
                        Hum.PlatformStand = false
                        HRP.Velocity = Vector3.new(0,0,0)
                        HRP.CFrame = CFrame.new(HRP.Position.X, 5, HRP.Position.Z) -- ទម្លាក់ចុះកម្ពស់ 5
                        task.wait(2)
                        CurrentZones = 0
                        -- បន្ទាប់ពីឈប់ វានឹងរើសពងថ្មីដែលមានក្នុង Map ដោយស្វ័យប្រវត្តិ
                        local eggs = ScanMapEggs()
                        if #eggs > 0 then
                            SelectedEggObj = eggs[1].Model
                        end
                    end
                end
            end
        else
            if bv then bv.Velocity = Vector3.new(0,0,0) end
        end
    end
end)
