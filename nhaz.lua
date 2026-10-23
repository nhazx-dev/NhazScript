-- [[ Nhaz Auto Steal - Final Run Drop & Pickup ]]
-- Run Continuous | Drop & Pickup Every 4s | Real Values | Zone Filter

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local AutoSteal = false
local SelectedEggObj = nil
local RunSpeed = 180 -- ល្បឿនរត់លឿន (មិនដល់ Teleport)
local DropTimer = 0

-- តំបន់ដែលអនុញ្ញាត (Jungle ដល់ Enchanted Forest)
local AllowedZones = {
    "jungle", "snow", "volcano", "abyss", "prehistoric", "cosmic", "cherry", "titan", "enchanted"
}

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

-- ស្កេនរកពង និងអានតម្លៃពិត
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
            
            -- កាត់ពងដែលនៅក្នុង Base ឬ Spawn ចោល
            if not parentName:find("base") and not parentName:find("spawn") and not seen[cleanName] then
                seen[cleanName] = true
                
                local valueStr = "Unknown"
                local valueNum = 0
                local eggType = "Common"
                local validZone = false
                
                -- ឆែកមើល Zone
                for _, z in ipairs(AllowedZones) do
                    if cleanName:lower():find(z) then validZone = true break end
                end

                if cleanName:lower():find("divine") then eggType = "Divine"
                elseif cleanName:lower():find("eternal") then eggType = "Eternal"
                elseif cleanName:lower():find("legendary") then eggType = "Legendary"
                elseif cleanName:lower():find("epic") then eggType = "Epic"
                elseif cleanName:lower():find("rare") then eggType = "Rare"
                end
                
                -- អានតម្លៃពិតពី BillboardGui ឬ TextLabel
                local billboard = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if billboard then
                    local lbl = billboard:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then valueStr = lbl.Text end
                else
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("TextLabel") and (desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("K") or desc.Text:find("T")) then
                            valueStr = desc.Text
                            break
                        end
                    end
                end
                
                valueNum = ParseValue(valueStr)
                
                if validZone or valueNum > 0 then
                    table.insert(found, {
                        Model = obj, 
                        Name = cleanName:gsub(" Egg", ""), 
                        ValueStr = valueStr, 
                        ValueNum = valueNum, 
                        Type = eggType
                    })
                end
            end
        end
    end
    table.sort(found, function(a, b) return a.ValueNum > b.ValueNum end)
    return found
end

-- មុខងារទម្លាក់ និងរើសពងឡើងវិញ
local function DropAndPickup()
    local Char = LP.Character
    if not Char then return end
    local Hum = Char:FindFirstChild("Humanoid")
    if not Hum then return end
    
    -- ទម្លាក់ពង (ដកចេញពីដៃ)
    Hum:UnequipTools()
    task.wait(0.1)
    
    -- រើសពងឡើងវិញពីកាបូប
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

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -120)
Scroll.Position = UDim2.new(0, 10, 0, 55)
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

UpdateUI()

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

-- Main Loop (រត់ជាប់ជានិច្ច គ្មានឈប់)
task.spawn(function()
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                -- បើពងនោះបាត់ រកពងថ្មី
                if not SelectedEggObj.Parent then
                    Status.Text = "Egg gone! Finding new one..."
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else AutoSteal = false end
                    task.wait(1)
                    continue
                end

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                
                -- ១. រត់ទៅរកពង
                Status.Text = "Running to: "..SelectedEggObj.Name:gsub(" Egg", "")
                Hum.WalkSpeed = RunSpeed
                Hum:MoveTo(targetPos) 
                
                local dist = (HRP.Position - targetPos).Magnitude
                if dist < 6 then
                    -- ២. ពេលដល់ លួច (ឈប់រត់តែមួយភ្លែត)
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
                    
                    task.wait(0.5) -- ចាំបន្តិចឱ្យវាចូលកាបូប
                    
                    -- ៣. រត់ត្រឡប់មកវិញ
                    local backPos = HRP.Position + (HRP.Position - targetPos).Unit * 100 -- រត់ថយក្រោយ ១០០ ស្ទូឌ
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(backPos)
                    
                    -- ៤. រាល់ពេលរត់បាន ៤ វិនាទី (៤ Zone) ទម្លាក់ និងរើសពងវិញ
                    DropTimer = 0
                    while (HRP.Position - backPos).Magnitude > 10 and AutoSteal do
                        DropTimer = DropTimer + 0.1
                        if DropTimer >= 4 then
                            DropTimer = 0
                            Status.Text = "Dropping & Picking up Egg..."
                            DropAndPickup()
                        end
                        task.wait(0.1)
                    end
                    
                    -- ៥. បន្ទាប់ពីរត់ថយក្រោយរួច រើសពងថ្មីបន្ត
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model end
                end
            end
        else
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 then Hum.WalkSpeed = 16 end
        end
    end
end)
