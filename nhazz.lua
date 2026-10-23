-- [[ NHAZ HUB - Final Stable Version ]]
print("Nhaz Hub: Loading...")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local AutoSteal = false
local SelectedEggObj = nil
local RunSpeed = 150
local DropTimer = 0

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 450)
Main.Position = UDim2.new(0.5, -160, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 10)
UICorner1.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Text = "NHAZ HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Main

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = Title

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -105)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Scroll

local BottomFrame = Instance.new("Frame")
BottomFrame.Size = UDim2.new(1, -10, 0, 40)
BottomFrame.Position = UDim2.new(0, 5, 1, -45)
BottomFrame.BackgroundTransparency = 1
BottomFrame.Parent = Main

local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.48, 0, 1, 0)
StealBtn.Position = UDim2.new(0, 0, 0, 0)
StealBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
StealBtn.Text = "STEAL"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 15
StealBtn.Parent = BottomFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = StealBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.48, 0, 1, 0)
StopBtn.Position = UDim2.new(0.52, 0, 0, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 15
StopBtn.Parent = BottomFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 6)
UICorner4.Parent = StopBtn

print("Nhaz Hub: UI Loaded Successfully!")

local function ScanEggs()
    local found = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            for _, child in ipairs(obj:GetDescendants()) do
                if (child:IsA("Model") or child:IsA("Part")) and child.Name:lower():find("egg") then
                    local name = child.Name
                    local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local isBase = name:lower():find("shop") or name:lower():find("base") or name:lower():find("firstarea")
                    
                    if prompt and not isBase and not seen[name] then
                        seen[name] = true
                        
                        local valueStr = "Unknown"
                        local multStr = "1.0x"
                        local iconId = "rbxassetid://7487019531"
                        
                        local bb = child:FindFirstChildWhichIsA("BillboardGui", true)
                        if bb then
                            local texts = {}
                            for _, desc in ipairs(bb:GetDescendants()) do
                                if desc:IsA("TextLabel") and desc.Text ~= "" then
                                    table.insert(texts, desc.Text)
                                elseif desc:IsA("ImageLabel") and desc.Image ~= "" then
                                    iconId = desc.Image
                                end
                            end
                            for _, t in ipairs(texts) do
                                if t:find("/s") or t:find("M") or t:find("B") or t:find("K") then
                                    valueStr = t
                                elseif t:find("x") then
                                    multStr = t
                                end
                            end
                        end
                        
                        local valNum = ParseValue(valueStr)
                        if valNum > 0 then
                            table.insert(found, {Model = child, Name = name:gsub(" Egg", ""), Value = valueStr, Num = valNum, Mult = multStr, Icon = iconId})
                        end
                    end
                end
            end
        end
    end
    
    table.sort(found, function(a, b) return a.Num > b.Num end)
    return found
end

local function UpdateUI()
    for _, c in pairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    local Eggs = ScanEggs()
    print("Nhaz Hub: Found " .. #Eggs .. " eggs.")
    
    for _, data in ipairs(Eggs) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -5, 0, 50)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.Parent = Scroll

        local UC = Instance.new("UICorner")
        UC.CornerRadius = UDim.new(0, 6)
        UC.Parent = Btn

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 40, 0, 40)
        Icon.Position = UDim2.new(0, 5, 0.5, -20)
        Icon.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Icon.Image = data.Icon
        Icon.Parent = Btn

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0.4, 0, 0, 20)
        NameLbl.Position = UDim2.new(0.16, 0, 0.1, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = data.Name
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.Font = Enum.Font.SourceSansBold
        NameLbl.TextSize = 14
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = Btn

        local MultLbl = Instance.new("TextLabel")
        MultLbl.Size = UDim2.new(0.2, 0, 0, 20)
        MultLbl.Position = UDim2.new(0.6, 0, 0.1, 0)
        MultLbl.BackgroundTransparency = 1
        MultLbl.Text = data.Mult
        MultLbl.TextColor3 = Color3.fromRGB(100, 150, 255)
        MultLbl.Font = Enum.Font.SourceSansBold
        MultLbl.TextSize = 14
        MultLbl.TextXAlignment = Enum.TextXAlignment.Right
        MultLbl.Parent = Btn

        local ValLbl = Instance.new("TextLabel")
        ValLbl.Size = UDim2.new(0.2, 0, 0, 20)
        ValLbl.Position = UDim2.new(0.8, 0, 0.1, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = data.Value
        ValLbl.TextColor3 = Color3.fromRGB(0, 255, 127)
        ValLbl.Font = Enum.Font.SourceSansBold
        ValLbl.TextSize = 14
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0.35, 0, 0, 4)
        Bar.Position = UDim2.new(0.16, 0, 0.75, 0)
        Bar.BackgroundColor3 = Color3.fromRGB(80, 50, 150)
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn

        local UCB = Instance.new("UICorner")
        UCB.CornerRadius = UDim.new(1, 0)
        UCB.Parent = Bar

        Btn.MouseButton1Click:Connect(function()
            SelectedEggObj = data.Model
            for _, c in pairs(Scroll:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(25, 25, 30) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Eggs * 55)
end

task.spawn(function()
    task.wait(2) 
    UpdateUI()
end)

StealBtn.MouseButton1Click:Connect(function()
    if not SelectedEggObj then
        local Eggs = ScanEggs()
        if #Eggs > 0 then SelectedEggObj = Eggs[1].Model end
    end
    AutoSteal = true
    StealBtn.Text = "STEALING..."
    StealBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
end)

StopBtn.MouseButton1Click:Connect(function()
    AutoSteal = false
    StealBtn.Text = "STEAL"
    StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    if Hum then 
        Hum.WalkSpeed = 16
        Hum:MoveTo(Char.HumanoidRootPart.Position) 
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if AutoSteal and SelectedEggObj then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum then
                if not SelectedEggObj.Parent then
                    local Eggs = ScanEggs()
                    if #Eggs > 0 then SelectedEggObj = Eggs[1].Model else AutoSteal = false end
                    task.wait(0.5)
                    continue
                end

                local eggPart = SelectedEggObj:FindFirstChildWhichIsA("BasePart") or SelectedEggObj
                local targetPos = eggPart.Position
                local dist = (HRP.Position - targetPos).Magnitude
                
                if dist > 6 then
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(targetPos) 
                    
                    DropTimer = DropTimer + 0.2
                    if DropTimer >= 4 then
                        DropTimer = 0
                        pcall(function() Hum:UnequipTools() end)
                        task.wait(0.1)
                        local Backpack = LP:FindFirstChild("Backpack")
                        if Backpack then
                            for _, tool in ipairs(Backpack:GetChildren()) do
                                if tool:IsA("Tool") then pcall(function() Hum:EquipTool(tool) end) break end
                            end
                        end
                    end
                else
                    Hum:MoveTo(HRP.Position)
                    
                    for _, v in pairs(SelectedEggObj:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                            v.MaxActivationDistance = 50
                            pcall(function() fireproximityprompt(v) end)
                        end
                    end
                    
                    task.wait(0.5)
                    local Eggs = ScanEggs()
                    if #Eggs > 0 then SelectedEggObj = Eggs[1].Model else SelectedEggObj = nil end
                end
            end
        else
            local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if Hum and Hum.WalkSpeed ~= 16 and not AutoSteal then Hum.WalkSpeed = 16 end
        end
    end
end)
