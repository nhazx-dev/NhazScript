-- [[ Nhaz Auto Steal - Real Map Eggs & Select ]]
-- True Values | Select Egg | Run & Steal | Drop/Pickup 4s | Reset Speed

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

-- ស្កេនរកពងក្នុង Map (កាត់ Base និង FirstAreaEgg ចោល)
local function ScanMapEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name:lower():find("egg") then
            local cleanName = obj.Name
            local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
            
            -- កាត់ឈ្មោះពងក្នុង Base ចោលដាច់ខាត
            local isBaseEgg = cleanName:lower():find("firstarea") or cleanName:lower():find("slot") or cleanName:lower():find("holder") or parentName:find("base") or parentName:find("plot")
            
            if not isBaseEgg and not seen[cleanName] then
                seen[cleanName] = true
                local valueStr = "Unknown"
                local valueNum = 0
                local displayName = cleanName:gsub(" Egg", ""):gsub("_", " ")
                
                -- អានតម្លៃពិតពី Billboard
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then 
                        valueStr = lbl.Text 
                    end
                end
                
                -- ស្កេនរកតម្លៃក្នុង TextLabel ផ្សេងទៀតបើមិនឃើញក្នុង Billboard
                if valueStr == "Unknown" then
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("TextLabel") and (desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("K") or desc.Text:find("T")) then
                            valueStr = desc.Text
                            break
                        end
                    end
                end
                
                valueNum = ParseValue(valueStr)
                
                -- បើមានតម្លៃលុយ ឬជាពងពិត ទើបយក
                if valueNum > 0 or valueStr ~= "Unknown" then
                    table.insert(found, {
                        Model = obj, 
                        Name = displayName, 
                        ValueStr = valueStr, 
                        ValueNum = valueNum
                    })
                end
            end
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
            AutoBtn.Text = "Auto Steal: ON (Selected)"
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
    AutoBtn.Text = AutoSteal and "Auto Steal: ON (Auto Best)" or "Auto Steal: OFF"
    AutoBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if AutoSteal and not SelectedEggObj then
        local eggs = ScanMapEggs()
        if #eggs > 0 then SelectedEggObj = eggs[1].Model end
    end
    
    -- បិទ Auto ត្រូវដើរធម្មតាវិញ
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
    while task.wait(0.1) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                if not SelectedEggObj.Parent then
                    Status.Text = "Egg stolen!្ជ Finding new..."
                    local eggs = ScanMapEggs()
                    if #eggs > 0 then SelectedEggObj = eggs[1].Model else AutoSteីal = false end
                    task.wait(0.5)
                    continue
                end

                local eggPart = SelectedEggObj: ដFindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    Status.Text = "Running to: "..SelectedEggObj.Name
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(targetPos) 
                    
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
                    Hum:MoveTo(HRP.Position)
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
                    
                    Status.Text = "Running back..."
                    Hum.WalkSpeed = RunSpeed
                    local backPos = HRP.Position + (HRP.Position - targetPos).Unit * 50
                    Hum:MoveTo(backPos)
                    task.wait(0.5)
                    
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
