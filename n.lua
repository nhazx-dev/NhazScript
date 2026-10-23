-- [[ NHAZ HUB - Fully Functional UI ]]
-- Close Button | Steal/Stop Buttons | Egg List | Auto Run

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local AutoSteal = false
local SelectedEggObj = nil
local RunSpeed = 150

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

-- ១. បង្កើត UI មូលដ្ឋាន
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nhaz_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 480)
Main.Position = UDim2.new(0.5, -160, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- ចំណងជើង និង ប៊ូតុងបិទ (X)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NHAZ HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- ពេលចុច X ឱ្យបិទផ្ទាំងទាំងមូល
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ២. បញ្ជីពង
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -150)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)

-- ៣. ប៊ូតុងខាងក្រោម (STEAL / STOP)
local BottomFrame = Instance.new("Frame")
BottomFrame.Size = UDim2.new(1, -10, 0, 50)
BottomFrame.Position = UDim2.new(0, 5, 1, -95)
BottomFrame.BackgroundTransparency = 1
BottomFrame.Parent = Main

local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
StealBtn.Position = UDim2.new(0, 0, 0, 5)
StealBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StealBtn.Text = "STEAL"
StealBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 16
StealBtn.Parent = BottomFrame
Instance.new("UICorner", StealBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
StopBtn.Position = UDim2.new(0.52, 0, 0, 5)
StopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 16
StopBtn.Parent = BottomFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- ៤. មុខងារស្កេនពង (កែឱ្យរឹងមាំ)
local function ScanEggs()
    local found = {}
    local seen = {}
    
    -- ស្កេនទូទាំង Workspace ដើម្បីកុំឱ្យខកខាន
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("egg") then
            local name = obj.Name
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            local isBase = name:lower():find("shop") or name:lower():find("base") or name:lower():find("firstarea")
            
            if prompt and not isBase and not seen[name] then
                seen[name] = true
                
                local valueStr = "0/s"
                local multStr = "1.0x"
                local iconId = "rbxassetid://7487019531"
                
                local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    for _, desc in ipairs(bb:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                            if desc.Text:find("/s") or desc.Text:find("M") or desc.Text:find("B") or desc.Text:find("K") then
                                valueStr = desc.Text
                            elseif desc.Text:find("x") then
                                multStr = desc.Text
                            end
                        elseif desc:IsA("ImageLabel") and desc.Image ~= "" then
                            iconId = desc.Image
                        end
                    end
                end
                
                local valNum = ParseValue(valueStr)
                if valNum > 0 then
                    table.insert(found, {Model = obj, Name = name:gsub(" Egg", ""), Value = valueStr, Num = valNum, Mult = multStr, Icon = iconId})
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
    
    for _, data in ipairs(Eggs) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -5, 0, 50)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 40, 0, 40)
        Icon.Position = UDim2.new(0, 5, 0.5, -20)
        Icon.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Icon.Image = data.Icon
        Icon.Parent = Btn
        Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 4)

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
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

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
    task.wait(1)
    UpdateUI()
end)

-- ៥. ប៊ូតុង STEAL និង STOP
StealBtn.MouseButton1Click:Connect(function()
    if not SelectedEggObj then
        local Eggs = ScanEggs()
        if #Eggs > 0 then SelectedEggObj = Eggs[1].Model end
    end
    AutoSteal = true
    StealBtn.Text = "STEALING..."
end)

StopBtn.MouseButton1Click:Connect(function()
    AutoSteal = false
    StealBtn.Text = "STEAL"
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    if Hum then 
        Hum.WalkSpeed = 16
        Hum:MoveTo(Char.HumanoidRootPart.Position) 
    end
end)

-- ៦. Auto Steal Loop
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
                local dist = (HRP.Position - eggPart.Position).Magnitude
                
                if dist > 6 then
                    Hum.WalkSpeed = RunSpeed
                    Hum:MoveTo(eggPart.Position) 
                else
                    Hum:MoveTo(HRP.Position) -- ឈប់រត់
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
