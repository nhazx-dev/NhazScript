-- [[ Nhaz Auto Steal - Pathfinding & Slow Mode ]]
-- Pathfinding Run | No Drop Spam | Slow Mode | Real Values

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local IsSlowMode = false
local RunSpeedFast = 150
local RunSpeedSlow = 50

-- មុខងារបំប្លែងអក្សរទៅជាលេខ
local function ParseValue(str)
    if not str then return 0 end
    local text = str:lower():gsub("%s+", "")
    local num = tonumber(text:match("([%d%.]+)"))
    if not num then return 0 end
    if text:find("k") then return num * 1000
    elseif text:find("m") then return num * 1000000
    elseif text:find("b") then return num * 1000000000
    elseif text:find("t") then return num * 1000000000000
    else return num end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Menu_Final"
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

local SlowModeBtn = Instance.new("TextButton", Main)
SlowModeBtn.Size = UDim2.new(0.4, 0, 0, 25)
SlowModeBtn.Position = UDim2.new(0.05, 0, 0, 50)
SlowModeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
SlowModeBtn.Text = "Slow Mode: OFF"
SlowModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SlowModeBtn.Font = Enum.Font.SourceSansBold
SlowModeBtn.TextSize = 11
Instance.new("UICorner", SlowModeBtn).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", Main)
RefreshBtn.Size = UDim2.new(0.4, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.55, 0, 0, 50)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RefreshBtn.Text = "Refresh Eggs"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 11
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
Status.Text = "Status: UI Loaded."
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.SourceSansBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

task.wait(0.1)
Main.Visible = true

-- មុខងារស្កេនរកពង
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
            
            -- កាត់ពងក្នុង Base ចោល
            local isBaseEgg = cleanName:lower():find("firstarea") or cleanName:lower():find("slot") or cleanName:lower():find("holder") or parentName:find("base") or parentName:find("plot")
            
            if not isBaseEgg and not seen[cleanName] then
                seen[cleanName] = true
                local valueStr = "Unknown"
                local valueNum = 0
                local displayName = cleanName:gsub(" Egg", ""):gsub("_", " ")
                
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then valueStr = lbl.Text end
                end
                
                if valueStr == "Unknown" then
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("TextLabel") and (desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("K") or desc.Text:find("T")) then
                            valueStr = desc.Text
                            break
                        end
                    end
                end
                
                valueNum = ParseValue(valueStr)
                
                if valueNum > 0 or valueStr ~= "Unknown" then
                    table.insert(found, {Model = obj, Name = displayName, ValueStr = valueStr, ValueNum = valueNum})
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
        Btn.Size = UDim2.new(1, -10, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Btn.Text = data.Name.." ("..data.ValueStr..")"
        Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 12
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        Btn.MouseButton1Click:Connect(function()
            SelectedEggObj = data.Model
            AutoSteal = true
            AutoBtn.Text = "Auto Steal: ON (Selected)"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            for _, c in pairs(Scroll:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #MapEggs * 40)
    Status.Text = "Status: Found "..#MapEggs.." eggs."
end

task.spawn(function()
    task.wait(1)
    UpdateUI()
end)

RefreshBtn.MouseButton1Click:Connect(UpdateUI)

SlowModeBtn.MouseButton1Click:Connect(function()
    IsSlowMode = not IsSlowMode
    SlowModeBtn.Text = "Slow Mode: "..(IsSlowMode and "ON" or "OFF")
    SlowModeBtn.BackgroundColor3 = IsSlowMode and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 150, 50)
end)

AutoBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoBtn.Text = AutoSteal and "Auto Steal: ON (Auto Best)" or "Auto Steal: OFF"
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

-- មុខងាររត់ដោយប្រើ Pathfinding (វាងជញ្ជាំង)
local function RunToTarget(targetPos)
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(HRP.Position, targetPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not AutoSteal then break end
            Hum:MoveTo(waypoint.Position)
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                Hum.Jump = true
            end
            Hum.MoveToFinished:Wait(0.5)
        end
    else
        -- បើ Path មិនដើរ ប្រើ MoveTo ធម្មតា
        Hum:MoveTo(targetPos)
    end
end

-- Main Loop
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
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

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    Status.Text = "Running to: "..SelectedEggObj.Name
                    Hum.WalkSpeed = IsSlowMode and RunSpeedSlow or RunSpeedFast
                    RunToTarget(targetPos)
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
                    
                    -- រត់ត្រឡប់មកវិញឬរកពងថ្មី
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else SelectedEggObj = nil end
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
