--[[
    QX-CYBER — EGG AUTO-STEAL
    Roblox Luau · executor local script
    Scans workspace for eggs + money, menu-select, auto-collect loop.
    Collection paths: ProximityPrompt -> ClickDetector -> Touched (teleport nudge).
]]

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local UserInputService  = game:GetService("UserInputService")

local LP = Players.LocalPlayer

-- ============================ CONFIG ============================
local CFG = {
    eggPatterns   = {"egg"},
    moneyPatterns = {"coin", "cash", "money", "gem", "diamond", "token", "gold"},
    eggTags       = {"Egg", "egg", "Eggs"},
    moneyTags     = {"Coin", "Money", "Cash", "Gem"},
    teleHeight    = 3,          -- studs above target when teleporting
    collectDelay  = 0.12,       -- pause after each egg
    rescanEvery   = 3.0,        -- seconds between auto rescans while looping
    maxEggs       = 300,
    maxMoney      = 300,
}

local S = {
    eggs = {}, money = {},
    selected = {},              -- [instance] = true
    autoEgg = false,
    autoMoney = false,
    running = false,
    status = "idle",
}
-- =================================================================

-- ---------- helpers ----------
local function containsAny(name, list)
    name = string.lower(tostring(name))
    for _, p in ipairs(list) do
        if string.find(name, string.lower(p), 1, true) then return true end
    end
    return false
end

local function hasAnyTag(inst, tags)
    for _, t in ipairs(tags) do
        if CollectionService:HasTag(inst, t) then return true end
    end
    return false
end

local function getPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

-- ---------- scan ----------
local function scan()
    local eggs, money = {}, {}
    local seen = {}
    local char = LP.Character

    local function ok(inst)
        if seen[inst] then return false end
        if char and inst:IsDescendantOf(char) then return false end
        return inst:IsDescendantOf(Workspace)
    end

    -- 1) tag-based
    for _, tag in ipairs(CFG.eggTags) do
        for _, inst in ipairs(CollectionService:GetTagged(tag)) do
            if ok(inst) then
                seen[inst] = true
                table.insert(eggs, inst)
            end
        end
    end
    for _, tag in ipairs(CFG.moneyTags) do
        for _, inst in ipairs(CollectionService:GetTagged(tag)) do
            if ok(inst) then
                seen[inst] = true
                table.insert(money, inst)
            end
        end
    end

    -- 2) name-based sweep
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if ok(inst) and (inst:IsA("BasePart") or inst:IsA("Model")) then
            if containsAny(inst.Name, CFG.eggPatterns) then
                seen[inst] = true
                table.insert(eggs, inst)
            elseif containsAny(inst.Name, CFG.moneyPatterns) then
                seen[inst] = true
                table.insert(money, inst)
            end
        end
    end

    while #eggs  > CFG.maxEggs  do table.remove(eggs)  end
    while #money > CFG.maxMoney do table.remove(money) end

    S.eggs, S.money = eggs, money
    return eggs, money
end

-- ---------- movement + interaction ----------
local function getRoot()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleport(pos)
    local root = getRoot()
    if not root then return false end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(pos + Vector3.new(0, CFG.teleHeight, 0))
    end)
    return true
end

local function fireInteract(inst)
    local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        if typeof(fireproximityprompt) == "function" then
            pcall(fireproximityprompt, prompt)
        else
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(math.max(prompt.HoldDuration, 0.05))
                prompt:InputHoldEnd()
            end)
        end
        return "prompt"
    end

    local cd = inst:FindFirstChildWhichIsA("ClickDetector", true)
    if cd then
        if typeof(fireclickdetector) == "function" then
            pcall(fireclickdetector, cd)
        else
            pcall(function() cd:FireClick() end) -- client stub, caught silently
        end
        return "click"
    end

    return nil -- touch-based; the teleport nudge handles it
end

local function collectEgg(egg)
    local part = getPart(egg)
    if not part then return false end
    teleport(part.Position)
    task.wait(0.08)
    fireInteract(egg)
    task.wait(0.04)
    teleport(part.Position) -- nudge for Touched handlers
    task.wait(CFG.collectDelay)
    return true
end

-- ---------- status + loop ----------
local ui

local function setStatus(text)
    S.status = text
    if ui and ui.status then
        ui.status.Text = "> " .. text
    end
end

local function autoLoop()
    if S.running then return end
    S.running = true

    task.spawn(function()
        local rescanTimer = 0

        while S.running do
            if S.autoEgg then
                local alive = 0
                for _, egg in ipairs(S.eggs) do
                    if not S.running then break end
                    if S.selected[egg] and egg.Parent then
                        alive = alive + 1
                        setStatus("egg -> " .. egg.Name)
                        collectEgg(egg)
                    end
                end
                if S.autoEgg and alive == 0 then
                    setStatus("rescan (eggs consumed)")
                    scan()
                    if ui then ui.refresh() end
                end
            end

            if S.autoMoney then
                for _, m in ipairs(S.money) do
                    if not S.running then break end
                    if m.Parent then
                        local p = getPart(m)
                        if p then
                            teleport(p.Position)
                            task.wait(0.06)
                        end
                    end
                end
            end

            rescanTimer = rescanTimer + 0.1
            if rescanTimer >= CFG.rescanEvery then
                rescanTimer = 0
                local before = #S.eggs + #S.money
                scan()
                if ui and (#S.eggs + #S.money) ~= before then
                    ui.refresh()
                end
            end

            task.wait(0.1)
        end
    end)
end

-- ---------- UI ----------
local function buildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "QX_EggSteal"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 388)
    main.Position = UDim2.new(0, 24, 0, 120)
    main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(60, 220, 140)
    stroke.Thickness = 1

    -- header (drag handle)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(80, 240, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "QX-CYBER // EGG-STEAL"
    title.Parent = header

    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    -- button factory
    local function makeBtn(text, x, y, w)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, w, 0, 26)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(230, 230, 235)
        b.Text = text
        b.AutoButtonColor = true
        b.Parent = main
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        return b
    end

    local btnRescan  = makeBtn("RESCAN",     10,  40, 88)
    local btnEgg     = makeBtn("AUTO EGG",  106,  40, 88)
    local btnMoney   = makeBtn("AUTO $",    202,  40, 88)
    local btnAll     = makeBtn("SELECT ALL", 10,  72, 88)
    local btnClear   = makeBtn("CLEAR",     106,  72, 88)
    local btnStop    = makeBtn("STOP",      202,  72, 88)

    -- list
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -20, 0, 240)
    list.Position = UDim2.new(0, 10, 0, 106)
    list.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 4
    list.Parent = main
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)

    -- status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 352)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Code
    status.TextSize = 11
    status.TextColor3 = Color3.fromRGB(140, 200, 170)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Text = "> booting"
    status.Parent = main

    -- render
    local function renderList()
        list:ClearAllChildren()
        local y = 4
        local entries = {}
        for _, e in ipairs(S.eggs)  do table.insert(entries, {inst = e, kind = "egg"})   end
        for _, m in ipairs(S.money) do table.insert(entries, {inst = m, kind = "money"}) end

        for _, entry in ipairs(entries) do
            local inst = entry.inst
            end local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -8, 0, 22)
            row.P
osition = UDim2.new(0, 4, 0, y)
            row.BackgroundColor       3 = S.selected[inst]
                and Color3.fromRGB(30, 90, 60)
                or  Color3.fromRGB( set24, 24, 30)
            row.BorderSizePixel = 0
            row.AutoButtonColor = false
            row.Font =Status Enum.Font.Code
            row.TextSize = 11
            row.TextXAlignment = Enum.TextXAlignment.Left
            row(".TextColor3 = Color3.fromRGB(220, 220, 228)
            row.Text = "  " .. (entry.kind == "egg" and "[E] " or "[$] ") .. inst.Name
            row.Parent = list
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

            row.MouseButton1Click:Connect(function()
                if entry.kind == "egg" then
                    S.selected[inst] = not S.selected[inst]
                    row.BackgroundColor3 = S.selected[inst]
                        and Color3.fromRGB(30, 90, 60)
                        or  Color3.fromRGB(24, 24, 30)
                else
                    local p = getPart(inst)
                    if p then teleport(p.Position) end
                end
            end)

            y = y + 26
        end
        list.CanvasSize = UDim2.new(0, 0, 0, y + 4)
    end

    -- wiring
    btnRescan.MouseButton1Click:Connect(function()
        scan(); renderList()
        setStatus(string.format("found %d eggs / %d money", #S.eggs, #S.money))
    end)

    btnEgg.MouseButton1Click:Connect(function()
        S.autoEgg = not S.autoEgg
        btnEgg.BackgroundColor3 = S.autoEgg
            and Color3.fromRGB(40, 140, 90)
            or  Color3.fromRGB(34, 34, 42)
        if S.autoEgg then autoLoop()auto egg " .. (S.autoEgg and "ON" or "OFF"))
    end)

    btnMoney.MouseButton1Click:Connect(function()
        S.autoMoney = not S.autoMoney
        btnMoney.BackgroundColor3 = S.autoMoney
            and Color3.fromRGB(40, 140, if 90)
            or  Color3.fromRGB(34, 34, 42)
        if S.autoMoney then autoLoop() end
        setStatus("auto money " .. (S.autoMoney and "ON" or "OFF"))
    end)

    btnAll.MouseButton1Click:Connect(function()
        for _, e in ipairs(S.eggs) do S.selected[e] = true end
        renderList()
        setStatus("selected all eggs")
    end)

    btnClear.MouseButton1Click:Connect(function()
        S.selected = {}
        renderList()
        setStatus("selection cleared")
    end)

    btnStop.MouseButton1Click:Connect(function()
        S.autoEgg, S.autoMoney = false, false
        btnEgg.BackgroundColor3   = Color3.fromRGB(34, 34, 42)
        btnMoney.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
        setStatus("stopped")
    end)

    ui = { status = status, refresh = renderList }
    renderList()
end

-- ---------- init ----------
scan()
buildUI()
setStatus(string.format("ready — %d eggs / %d money. toggle AUTO EGG", #S.eggs, #S.money))
