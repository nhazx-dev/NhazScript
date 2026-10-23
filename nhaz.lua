-- [[ Nhaz Auto Steal - Billboard Scanner & Fix ]]
-- Scans real map eggs | Run & Steal | Drop/Pickup | Reset Speed

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local RunSpeed = 150
local DropTimer = 0

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

-- ស្កេនរកពងពិតៗក្នុង Map (កាត់ពងក្នុង Base ចោល)
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
            
            -- ឆែកមើលថាតើវាមាន ProximityPrompt (សម្រាប់ចុចលួច) ឬអត់
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            
            if prompt then
                local cleanName = obj.Name
                local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
                
                -- កាត់ពងដែលនៅក្នុង Base ឬ Spawn ចោល
                if not parentName:find("base") and not parentName:find("plot") and not cleanName:lower():find("base") and not seen[cleanName] then
                    
                    local valueStr = "Unknown"
                    local displayName = cleanName:gsub(" Egg", ""):gsub("_", " ")
                    
                    -- អានតម្លៃពិតពី BillboardGui
                    local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                    if bb then
                        local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                        if lbl and lbl.Text ~= "" then 
                            valueStr = lbl.Text 
                        end
                    end
                    
                    -- បើឈ្មោះអត់ស្អាត (ដូចជា FirstAreaEgg...) ឱ្យវាយកឈ្មោះពី Billboard វិញ
                    if displayName:find("FirstAreaEgg") then
                        if bb and bb:FindFirstChildWhichIsA("TextLabel") then
                            displayName = bb.TextLabel.Text:gsub("/s", ""):gsub("%d", ""):gsub("M", ""):gsub("B", ""):gsub("T", "")
                        end
                    end
                    
                    seen[cleanName] = true
                    table.insert(found, {
                        Model = obj, 
                        Name = displayName, 
                        ValueStr = valueStr, 
                        ValueNum = ParseValue(valueStr)
                    })
                end
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

local function UpdateUI()
    for _, c in pairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
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
        if #eggs > 0 then SelectedEggObj = eggs[1].Model end
    end
    
    -- កែបញ្ហាដើរយឺតពេលបិទ Auto
    if not AutoSteal then
        Status.Text = "Status: Stopped"
        local Char = LP.Character
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then 
            Hum.WalkSpeed = 16 -- ត្រឡប់មកល្បឿនធម្មតា
            Hum:MoveTo(Char.HumanoidRootPart.Position) 
        end
    end
end)

-- Main Loop
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                -- បើពងនោះបាត់ (ប្រែក្លាយជាសត្វ) រកពងថ្មី
                if not SelectedEggObj.Parent then
                    Status.Text = "Egg stolen! Finding new one..."
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then 
                        SelectedEggObj = eggs[1].Model 
                    else 
                        SelectedEggObj = nil 
                        AutoSteal = false 
                        AutoBtn.Text = "Auto Steal: OFF"
                        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                        Hum.WalkSpeed = 16
                    end
                    task.wait(0.5)
                    continue
                end

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    -- រត់ទៅរកពង
                    Status.Text = "Running to: "..SelectedEggObj.Name
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(targetPos) 
                    
                    -- រាល់ពេលរត់បាន ៤ វិនាទី ទម្លាក់ និងរើសពងវិញ
                    DropTimer = DropTimer + 0.1
                    if DropTimer >= 4 then
                        DropTimer = 0
                        Status.Text = "Dropping & Picking up..."
                        Hum:UnequipTools()
                        task.wait(0.1)
                        local Backpack = LP:FindFirstChild("Backpack")
                        if Backpack then
                            for _, tool in ipairs(Backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    Hum:EquipTool(tool)
                                    break
                                end
                            end
                        end
                    end
                else
                    -- ដល់ហើយ ចាប់ផ្តើមលួច
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
                    
                    task.wait(0.5) -- ចាំបន្តិចឱ្យហ្គេមដំណើរការ
                    
                    -- រត់ថយក្រោយវិញ
                    Status.Text = "Running back..."
                    Hum.WalkSpeed = RunSpeed
                    local backPos = HRP.Position + (HRP.Position - targetPos).Unit * 50
                    Hum:MoveTo(backPos)
                    task.wait(0.5)
                    
                    -- រើសពងថ្មីបន្ត
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else SelectedEggObj = nil end
                end
            end
        else
            -- ធានាថាល្បឿនត្រឡប់មកធម្មតាពេលបិទ
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 and not AutoSteal then 
                Hum.WalkSpeed = 16 
            end
        end
    end
end)
