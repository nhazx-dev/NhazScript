-- [[ Nhaz Hub - Ultimate Edition ]]
-- Clean UI | Anti Trap/Guard | Run & Steal Back | Drop/Pickup | Real Values

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local IsSlowMode = false
local AntiTrap = true
local AntiGuard = true

local RunSpeedFast = 150
local RunSpeedSlow = 60
local DropTimer = 0

-- មុខងារបំប្លែងអក្សរទៅជាលេខ (សម្រាប់តម្រៀប)
local function ParseValue(str)
    if not str then return 0 end
    local text = str:lower():gsub("%s+", "")
    local num = tonumber(text:match("([%d%.]+)"))
    if not num then return 0 end
    if text:find("k") then return num * 1000
    elseif text:find("m") then return num * 1000000
    elseif text:find("b") then return num * 1000000000
    elseif text:find("t") then return num * 1000000000000
    elseif text:find("qa") then return num * 1000000000000000
    else return num end
end

-- UI Setup (តាមស្ទីលរូបទី១)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Hub"
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
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
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
Title.Text = "Nhaz Auto Steal"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ជួរទី១: Auto Steal និង Slow Mode
local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(0.45, 0, 0, 30)
AutoBtn.Position = UDim2.new(0.03, 0, 0, 45)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoBtn.Text = "Auto Steal: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 12
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 4)

local SlowModeBtn = Instance.new("TextButton", Main)
SlowModeBtn.Size = UDim2.new(0.45, 0, 0, 30)
SlowModeBtn.Position = UDim2.new(0.52, 0, 0, 45)
SlowModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 40)
SlowModeBtn.Text = "Slow Mode: OFF"
SlowModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SlowModeBtn.Font = Enum.Font.SourceSansBold
SlowModeBtn.TextSize = 12
Instance.new("UICorner", SlowModeBtn).CornerRadius = UDim.new(0, 4)

-- ជួរទី២: Anti Guard និង Anti Trap
local GuardBtn = Instance.new("TextButton", Main)
GuardBtn.Size = UDim2.new(0.3, 0, 0, 25)
GuardBtn.Position = UDim2.new(0.03, 0, 0, 80)
GuardBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
GuardBtn.Text = "Guard: ON"
GuardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GuardBtn.Font = Enum.Font.SourceSansBold
GuardBtn.TextSize = 11
Instance.new("UICorner", GuardBtn).CornerRadius = UDim.new(0, 4)

local TrapBtn = Instance.new("TextButton", Main)
TrapBtn.Size = UDim2.new(0.3, 0, 0, 25)
TrapBtn.Position = UDim2.new(0.35, 0, 0, 80)
TrapBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TrapBtn.Text = "Trap: ON"
TrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrapBtn.Font = Enum.Font.SourceSansBold
TrapBtn.TextSize = 11
Instance.new("UICorner", TrapBtn).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", Main)
RefreshBtn.Size = UDim2.new(0.3, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.67, 0, 0, 80)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 11
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

-- បញ្ជីពង
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -160)
Scroll.Position = UDim2.new(0, 10, 0, 115)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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

-- ស្កេនរកពងក្នុង Map (កាត់ Shop/Base ចោល)
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
            
            -- ឆែកថាតើមាន ProximityPrompt សម្រាប់ចុចលួចឬអត់
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            local isBlacklisted = cleanName:lower():find("shop") or cleanName:lower():find("base") or parentName:find("base") or parentName:find("plot") or cleanName:lower():find("firstarea")
            
            if prompt and not isBlacklisted and not seen[cleanName] then
                seen[cleanName] = true
                local valueStr = "Unknown"
                local valueNum = 0
                
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then valueStr = lbl.Text end
                end
                
                valueNum = ParseValue(valueStr)
                
                if valueNum > 0 then
                    table.insert(found, {Model = obj, Name = cleanName:gsub(" Egg", ""), ValueStr = valueStr, ValueNum = valueNum})
                end
            end
        end
    end
    table.sort(found, function(a, b) return a.ValueNum > b.ValueNum end)
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
        Btn.Size = UDim2.new(1, -5, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        local NameLbl = Instance.new("TextLabel", Btn)
        NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 10, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = data.Name
        NameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        NameLbl.Font = Enum.Font.SourceSansBold
        NameLbl.TextSize = 12
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local ValLbl = Instance.new("TextLabel", Btn)
        ValLbl.Size = UDim2.new(0.35, 0, 1, 0)
        ValLbl.Position = UDim2.new(0.65, 0, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = data.ValueStr
        ValLbl.TextColor3 = Color3.fromRGB(0, 255, 127)
        ValLbl.Font = Enum.Font.SourceSansBold
        ValLbl.TextSize = 12
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right

        Btn.MouseButton1Click:Connect(function()
            SelectedEggObj = data.Model
            AutoSteal = true
            AutoBtn.Text = "Auto Steal: ON"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            for _, c in pairs(Scroll:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #MapEggs * 40)
    Status.Text = "Status: Found "..#MapEggs.." eggs."
end

task.spawn(function() task.wait(1) UpdateUI() end)
RefreshBtn.MouseButton1Click:Connect(UpdateUI)

-- Toggle Buttons
SlowModeBtn.MouseButton1Click:Connect(function()
    IsSlowMode = not IsSlowMode
    SlowModeBtn.Text = "Slow Mode: "..(IsSlowMode and "ON" or "OFF")
    SlowModeBtn.BackgroundColor3 = IsSlowMode and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 40)
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
            Hum.WalkSpeed = 16
            Hum:MoveTo(Char.HumanoidRootPart.Position) 
        end
    end
end)

-- មុខងាររត់វាងជញ្ជាំង
local function RunToTarget(targetPos)
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end
    
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local success = pcall(function() path:ComputeAsync(HRP.Position, targetPos) end)
    
    if success and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not AutoSteal then break end
            Hum:MoveTo(waypoint.Position)
            if waypoint.Action == Enum.PathWaypointAction.Jump then Hum.Jump = true end
            task.wait(0.2)
        end
    else
        Hum:MoveTo(targetPos)
    end
end

-- Main Loop (Auto Steal, Anti Trap, Anti Guard, Drop/P _,ickup)
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character m
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                if not SelectedEggObj.Parent then
                    Status.Text = "Egg stolen! Finding new..."
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else AutoSteal = false end
                    task.wait(0.5)
                    continue
                end

                -- Anti Guard
                if AntiGuard then
                    for in ipairs(workspace:GetDescendants()) do
                        if m:IsA("Model") and (m.Name:lower():find("guard") or m.Name:lower():find("police") or m.Name:lower():find("tiger")) then
                            local root = m:FindFirstChild("HumanoidRootPart")
                            if root and (HRP.Position - root.Position).Magnitude < 25 then Hum.Jump = true end
                        end
                    end
                end
                
                -- Anti Trap
                if AntiTrap then
                    for _, t in ipairs(workspace:GetDescendants()) do
                        if t:IsA("Part") and (t.Name:lower():find("trap") or t.Name:lower():find("spike")) then
                            if (HRP.Position - t.Position).Magnitude < 15 then Hum.Jump = true end
                        end
                    end
                end

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    Status.Text = "Running to: "..SelectedEggObj.Name
                    Hum.WalkSpeed = IsSlowMode and RunSpeedSlow or RunSpeedFast
                    RunToTarget(targetPos)
                    
                    -- ទម្លាក់ និងរើសពងវិញរាល់ ៤ វិនាទី
                    DropTimer = DropTimer + 0.1
                    if DropTimer >= 4 then
                        DropTimer = 0
                        Status.Text = "Dropping & Equipping Egg..."
                        Hum:UnequipTools()
                        task.wait(0.1)
                        local Backpack = LP:FindFirstChild("Backpack")
                        if Backpack then
                            for _, tool in ipairs(Backpack:GetChildren()) do
                                if tool:IsA("Tool") then Hum:EquipTool(tool) break end
                            end
                        end
                    end
                else
                    Hum:MoveTo(HRP.Position) -- ឈប់រត់
                    Status.Text = "Stealing: "..SelectedEggObj.Name
                    
                    for _, v in pairs(SelectedEggObj:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                            v.MaxActivationDistance = 50
                            v.Enabled = true
                            pcall(function() fireproximityprompt(v) end)
                        end
                    end
                    
                    task.wait(0.5)
                    
                    -- រត់ត្រឡប់មកវិញ
                    Status.Text = "Running back..."
                    Hum.WalkSpeed = IsSlowMode and RunSpeedSlow or RunSpeedFast
                    local backPos = HRP.Position + (HRP.Position - targetPos).Unit * 50
                    Hum:MoveTo(backPos)
                    task.wait(0.5)
                    
                    -- រើសពងថ្មីបន្ត
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else SelectedEggObj = nil end
                end
            end
        else
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 then Hum.WalkSpeed = 16 end
        end
    end
end)
