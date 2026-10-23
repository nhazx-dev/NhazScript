-- [[ Nhaz Hub - Auto Best Value Scanner ]]
-- 100% Map Scanner | Auto Select Best | Fast Run | Anti Guard/Trap

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
ScreenGui.Name = "Nhaz_Hub_Scanner"
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
Title.Text = "Nhaz Auto Scanner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(1, -20, 0, 35)
AutoBtn.Position = UDim2.new(0, 10, 0, 45)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF"
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
Status.Size = UDim2.new(1, -20, 0, 70)
Status.Position = UDim2.new(0, 10, 0, 130)
Status.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Status.Text = "Status: Ready\nTarget: None\nValue: None"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 4)

task.wait(0.1)
Main.Visible = true

-- មុខងារស្កេនរកពងពិតៗក្នុង Map
local function ScanMapEggs()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("egg") then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            local isBase = obj.Name:lower():find("firstarea") or obj.Name:lower():find("shop") or obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))
            
            if prompt and not isBase then
                local valueStr = "0/s"
                -- ស្កេនរកតម្លៃលុយពី Billboard ឬ TextLabel
                for _, v in ipairs(obj:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        local text = v.Text
                        if text:match("%d") and (text:find("/s") or text:find("M") or text:find("B") or text:find("T") or text:find("K") or text:find("Qa")) then
                            valueStr = text
                            break
                        end
                    end
                end
                
                local valueNum = ParseValue(valueStr)
                if valueNum > 0 then
                    table.insert(found, {Model = obj, Name = obj.Name:gsub(" Egg", ""), Value = valueStr, Num = valueNum})
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.Num > b.Num end)
    return found
end

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
    AutoBtn.Text = AutoSteal and "Auto Steal: ON" or "Auto Steal: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if not AutoSteal then
        Status.Text = "Status: Stopped\nTarget: None\nValue: None"
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
                -- Anti Guard & Trap
                if AntiGuard or AntiTrap then
                    for _, m in ipairs(workspace:GetChildren()) do
                        if m:IsA("Model") then
                            local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if root then
                                local dist = (HRP.Position - root.Position).Magnitude
                                if AntiGuard and (m.Name:lower():find("guard") or m.Name:lower():find("police") or m.Name:lower():find("tiger")) and dist < 30 then
                                    Hum.Jump = true
                                elseif AntiTrap and (m.Name:lower():find("trap") or m.Name:lower():find("spike")) and dist < 20 then
                                    Hum.Jump = true
                                end
                            end
                        end
                    end
                end

                -- ប្រព័ន្ធស្វែងរក និងលួច
                if not CurrentTarget or not CurrentTarget.Model.Parent then
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then
                        CurrentTarget = eggs[1] -- យកពងថ្លៃជាងគេបំផុត
                    else
                        CurrentTarget = nil
                    end
                end

                if CurrentTarget and CurrentTarget.Model.Parent then
                    local targetPos = CurrentTarget.Model.Position
                    local dist = (HRP.Position - targetPos).Magnitude
                    
                    Status.Text = "Status: Target Found!\nTarget: "..CurrentTarget.Name.."\nValue: "..CurrentTarget.Value
                    Hum.WalkSpeed = 150
                    Hum:MoveTo(targetPos)
                    
                    if dist < 6 then
                        Hum:MoveTo(HRP.Position)
                        Status.Text = "Status: Stealing...\nTarget: "..CurrentTarget.Name.."\nValue: "..CurrentTarget.Value
                        
                        for _, v in pairs(CurrentTarget.Model:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                v.HoldDuration = 0
                                v.MaxActivationDistance = 50
                                pcall(function() fireproximityprompt(v) end)
                            end
                        end
                        
                        task.wait(0.5)
                        CurrentTarget = nil -- លុបគោលដៅចោល ដើម្បីរកពងថ្មី
                    end
                else
                    -- បើអត់ឃើញពង ឱ្យវារត់ចេញទៅមុខដើម្បីស្កេនរក
                    Status.Text = "Status: No Eggs Found\nScanning Map..."
                    Hum.WalkSpeed = 100
                    Hum:MoveTo(HRP.Position + HRP.CFrame.LookVector * 50)
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
