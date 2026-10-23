-- [[ Nhaz Auto Steal - Best Value & Focus ]]
-- Best Value | Fast Run & Return | Anti Guard/Trap | Lightweight

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local AntiTrap = true
local AntiGuard = true
local CurrentTarget = nil
local IsReturning = false

local function ParseValue(str)
    if not str then return 0 end
    local text = str:lower():gsub(",", ""):gsub("%s+", "")
    local num = tonumber(text:match("([%d%.]+)"))
    if not num then return 0 end
    if text:find("k") then return num * 1000
    elseif text:find("m") then return num * 1000000
    elseif text:find("b") then return num * 1000000000
    elseif text:find("t") then return num * 1000000000000
    elseif text:find("qa") then return num * 1000000000000000
    else return num end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Hub_Best"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleBtn.Text = "Nhaz"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 250)
Main.Position = UDim2.new(0.5, -140, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Nhaz Best Value"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 35)
AutoBtn.Position = UDim2.new(0, 10, 0, 45)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal Best: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 14
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 4)

local GuardBtn = Instance.new("TextButton", Main)
GuardBtn.Size = UDim2.new(0.45, 0, 0, 30)
GuardBtn.Position = UDim2.new(0.03, 0, 0, 90)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Anti Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 12
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", Main)
TrapBtn.Size = UDim2.new(0.45, 0, 0, 30)
TrapBtn.Position = UDim2.new(0.52, 0, 0, 90)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Anti Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 12
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 60)
Status.Position = UDim2.new(0, 10, 0, 130)
Status.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Status.Text = "Status: Ready\nTarget: None"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 4)

task.wait(0.1)
Main.Visible = true

-- ស្កេនរកពងដែលមានតម្លៃខ្ពស់ជាងគេ
local function GetBestEgg()
    local bestEgg = nil
    local highestValue = 0
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            local isBlacklisted = cleanName:lower():find("shop") or cleanName:lower():find("base") or cleanName:lower():find("firstarea") or cleanName:lower():find("holder")
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            
            if prompt and not isBlacklisted then
                local valueStr = "Unknown"
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then valueStr = lbl.Text end
                end
                
                local valueNum = ParseValue(valueStr)
                if valueNum > highestValue then
                    highestValue = valueNum
                    bestEgg = {Model = obj, Name = cleanName:gsub(" Egg", ""), Value = valueStr}
                end
            end
        end
    end
    return bestEgg
end

-- Toggle Buttons
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

AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoBtn.Text = AutoSteal and "Auto Steal Best: ON" or "Auto Steal Best: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if not AutoSteal then
        Status.Text = "Status: Stopped"
        local Char = LP.Character
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then 
            Hum.WalkSpeed = 16
            Hum:MoveTo(Char.HumanoidRootPart.Position) 
        end
    end
end)

-- Main Loop
task.spawn(function()
    while task.wait(0.2) do
        if AutoSteal then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                -- ប្រព័ន្ធ Anti Guard & Trap (ស្រាល)
                if AntiGuard or AntiTrap then
                    for _, m in ipairs(workspace:GetChildren()) do
                        if m:IsA("Model") then
                            local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if root then
                                local dist = (HRP.Position - root.Position).Magnitude
                                if AntiGuard and (m.Name:lower():find("guard") or m.Name:lower():find("police") or m.Name:lower():find("tiger")) and dist < 25 then
                                    Hum.Jump = true
                                elseif AntiTrap and (m.Name:lower():find("trap") or m.Name:lower():find("spike")) and dist < 15 then
                                    Hum.Jump = true
                                end
                            end
                        end
                    end
                end

                if not IsReturning then
                    -- រកពងថ្លៃជាងគេ
                    if not CurrentTarget or not CurrentTarget.Model.Parent then
                        CurrentTarget = GetBestEgg()
                    end

                    if CurrentTarget and CurrentTarget.Model.Parent then
                        local targetPos = CurrentTarget.Model.Position
                        local dist = (HRP.Position - targetPos).Magnitude
                        Status.Text = "Status: Running to Best\nTarget: "..CurrentTarget.Name.." ("..CurrentTarget.Value..")"
                        
                        if dist > 6 then
                            Hum.WalkSpeed = 150
                            Hum:MoveTo(targetPos)
                        else
                            Hum:MoveTo(HRP.Position) -- ឈប់
                            Status.Text = "Status: Stealing...\nTarget: "..CurrentTarget.Name
                            
                            for _, v in pairs(CurrentTarget.Model:GetDescendants()) do
                                if v:IsA("ProximityPrompt") then
                                    v.HoldDuration = 0
                                    v.MaxActivationDistance = 50
                                    pcall(function() fireproximityprompt(v) end)
                                end
                            end
                            
                            task.wait(0.5)
                            IsReturning = true -- ប្តូរទៅរត់ត្រឡប់មកវិញ
                            CurrentTarget = nil
                        end
                    else
                        Status.Text = "Status: No Eggs Found\nWaiting for spawn..."
                    end
                else
                    -- រត់ត្រឡប់មកវិញលឿន
                    Status.Text = "Status: Running Back to Base"
                    Hum.WalkSpeed = 150
                    
                    -- រត់ថយក្រោយ ៥០ ស្ទូឌ
                    local backPos = HRP.Position - (HRP.CFrame.LookVector * 50)
                    Hum:MoveTo(backPos)
                    
                    task.wait(1) -- រង់ចាំបន្តិច
                    IsReturning = false -- ចាប់ផ្តើមរកពងថ្មី
                end
            end
        else
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 then 
                Hum.WalkSpeed = 16 
            end
        end
    end
end)
