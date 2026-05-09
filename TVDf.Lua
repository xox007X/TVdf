local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============ ตั้งค่า ============
local SCAN_RATE = 0.5
local AURA_RANGE = 100
local ATTACK_RATE = 0.1

-- ============ สถานะ ============
local totalCollected = 0
local killCount = 0
local autoCollect = true
local auraActive = true

-- ============ GUI หลัก ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local camera = workspace.CurrentCamera

-- ============ ฟังก์ชัน ลาก GUI ============
local function makeDraggable(frame, titleBar)
    local dragging, dragStartPos, frameStartPos
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = inp.Position
            frameStartPos = frame.Position
        end
    end)
    titleBar.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStartPos
            local nx = math.clamp(frameStartPos.X.Offset + d.X, 0, camera.ViewportSize.X - frame.AbsoluteSize.X)
            local ny = math.clamp(frameStartPos.Y.Offset + d.Y, 0, camera.ViewportSize.Y - frame.AbsoluteSize.Y)
            frame.Position = UDim2.new(0, nx, 0, ny)
        end
    end)
    titleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============ หน้าต่าง AutoCollect ============
local Frame1 = Instance.new("Frame")
Frame1.Size = UDim2.new(0, 210, 0, 128)
Frame1.Position = UDim2.new(0, 15, 0, 120)
Frame1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame1.BorderSizePixel = 0
Frame1.ClipsDescendants = true
Frame1.Parent = ScreenGui
Instance.new("UICorner", Frame1).CornerRadius = UDim.new(0, 8)

local TitleBar1 = Instance.new("Frame")
TitleBar1.Size = UDim2.new(1, 0, 0, 28)
TitleBar1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar1.BorderSizePixel = 0
TitleBar1.Parent = Frame1
Instance.new("UICorner", TitleBar1).CornerRadius = UDim.new(0, 8)

local TitleTxt1 = Instance.new("TextLabel")
TitleTxt1.Size = UDim2.new(1, -55, 1, 0)
TitleTxt1.Position = UDim2.new(0, 8, 0, 0)
TitleTxt1.BackgroundTransparency = 1
TitleTxt1.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleTxt1.Text = "💎 AutoCollect [ON]"
TitleTxt1.TextSize = 12
TitleTxt1.Font = Enum.Font.GothamBold
TitleTxt1.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt1.Parent = TitleBar1

local BtnMin1 = Instance.new("TextButton")
BtnMin1.Size = UDim2.new(0, 22, 0, 18)
BtnMin1.Position = UDim2.new(1, -47, 0.5, -9)
BtnMin1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnMin1.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMin1.Text = "—"
BtnMin1.TextSize = 11
BtnMin1.Font = Enum.Font.GothamBold
BtnMin1.BorderSizePixel = 0
BtnMin1.Parent = TitleBar1
Instance.new("UICorner", BtnMin1).CornerRadius = UDim.new(0, 4)

local BtnClose1 = Instance.new("TextButton")
BtnClose1.Size = UDim2.new(0, 22, 0, 18)
BtnClose1.Position = UDim2.new(1, -22, 0.5, -9)
BtnClose1.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnClose1.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnClose1.Text = "✕"
BtnClose1.TextSize = 11
BtnClose1.Font = Enum.Font.GothamBold
BtnClose1.BorderSizePixel = 0
BtnClose1.Parent = TitleBar1
Instance.new("UICorner", BtnClose1).CornerRadius = UDim.new(0, 4)

local Content1 = Instance.new("Frame")
Content1.Size = UDim2.new(1, 0, 0, 100)
Content1.Position = UDim2.new(0, 0, 0, 30)
Content1.BackgroundTransparency = 1
Content1.Parent = Frame1

local StatusLbl1 = Instance.new("TextLabel")
StatusLbl1.Size = UDim2.new(0.9, 0, 0, 18)
StatusLbl1.Position = UDim2.new(0.05, 0, 0, 5)
StatusLbl1.BackgroundTransparency = 1
StatusLbl1.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLbl1.Text = "สถานะ: กำลังทำงาน..."
StatusLbl1.TextSize = 11
StatusLbl1.Font = Enum.Font.Gotham
StatusLbl1.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl1.Parent = Content1

local CountLbl = Instance.new("TextLabel")
CountLbl.Size = UDim2.new(0.9, 0, 0, 18)
CountLbl.Position = UDim2.new(0.05, 0, 0, 26)
CountLbl.BackgroundTransparency = 1
CountLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
CountLbl.Text = "เก็บไปแล้ว: 0 ชิ้น"
CountLbl.TextSize = 11
CountLbl.Font = Enum.Font.Gotham
CountLbl.TextXAlignment = Enum.TextXAlignment.Left
CountLbl.Parent = Content1

local QueueLbl = Instance.new("TextLabel")
QueueLbl.Size = UDim2.new(0.9, 0, 0, 18)
QueueLbl.Position = UDim2.new(0.05, 0, 0, 47)
QueueLbl.BackgroundTransparency = 1
QueueLbl.TextColor3 = Color3.fromRGB(100, 220, 255)
QueueLbl.Text = "ของในแมพ: -"
QueueLbl.TextSize = 11
QueueLbl.Font = Enum.Font.Gotham
QueueLbl.TextXAlignment = Enum.TextXAlignment.Left
QueueLbl.Parent = Content1

makeDraggable(Frame1, TitleBar1)

local minimized1 = false
BtnMin1.MouseButton1Click:Connect(function()
    minimized1 = not minimized1
    if minimized1 then
        Frame1:TweenSize(UDim2.new(0, 210, 0, 28), "Out", "Quad", 0.2, true)
        BtnMin1.Text = "+"
    else
        Frame1:TweenSize(UDim2.new(0, 210, 0, 128), "Out", "Quad", 0.2, true)
        BtnMin1.Text = "—"
    end
end)
BtnClose1.MouseButton1Click:Connect(function()
    autoCollect = false
    Frame1:Destroy()
end)

-- ============ หน้าต่าง Aura Kill ============
local Frame2 = Instance.new("Frame")
Frame2.Size = UDim2.new(0, 200, 0, 133)
Frame2.Position = UDim2.new(0, 15, 0, 265)
Frame2.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame2.BorderSizePixel = 0
Frame2.ClipsDescendants = true
Frame2.Parent = ScreenGui
Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 8)

local TitleBar2 = Instance.new("Frame")
TitleBar2.Size = UDim2.new(1, 0, 0, 28)
TitleBar2.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
TitleBar2.BorderSizePixel = 0
TitleBar2.Parent = Frame2
Instance.new("UICorner", TitleBar2).CornerRadius = UDim.new(0, 8)

local TitleTxt2 = Instance.new("TextLabel")
TitleTxt2.Size = UDim2.new(1, -55, 1, 0)
TitleTxt2.Position = UDim2.new(0, 8, 0, 0)
TitleTxt2.BackgroundTransparency = 1
TitleTxt2.TextColor3 = Color3.fromRGB(255, 100, 100)
TitleTxt2.Text = "⚔️ Aura Kill [ON]"
TitleTxt2.TextSize = 12
TitleTxt2.Font = Enum.Font.GothamBold
TitleTxt2.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt2.Parent = TitleBar2

local BtnMin2 = Instance.new("TextButton")
BtnMin2.Size = UDim2.new(0, 22, 0, 18)
BtnMin2.Position = UDim2.new(1, -47, 0.5, -9)
BtnMin2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnMin2.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMin2.Text = "—"
BtnMin2.TextSize = 11
BtnMin2.Font = Enum.Font.GothamBold
BtnMin2.BorderSizePixel = 0
BtnMin2.Parent = TitleBar2
Instance.new("UICorner", BtnMin2).CornerRadius = UDim.new(0, 4)

local BtnClose2 = Instance.new("TextButton")
BtnClose2.Size = UDim2.new(0, 22, 0, 18)
BtnClose2.Position = UDim2.new(1, -22, 0.5, -9)
BtnClose2.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnClose2.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnClose2.Text = "✕"
BtnClose2.TextSize = 11
BtnClose2.Font = Enum.Font.GothamBold
BtnClose2.BorderSizePixel = 0
BtnClose2.Parent = TitleBar2
Instance.new("UICorner", BtnClose2).CornerRadius = UDim.new(0, 4)

local Content2 = Instance.new("Frame")
Content2.Size = UDim2.new(1, 0, 0, 105)
Content2.Position = UDim2.new(0, 0, 0, 30)
Content2.BackgroundTransparency = 1
Content2.Parent = Frame2

local StatusLbl2 = Instance.new("TextLabel")
StatusLbl2.Size = UDim2.new(0.9, 0, 0, 18)
StatusLbl2.Position = UDim2.new(0.05, 0, 0, 5)
StatusLbl2.BackgroundTransparency = 1
StatusLbl2.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLbl2.Text = "รอ AutoCollect... 5s"
StatusLbl2.TextSize = 11
StatusLbl2.Font = Enum.Font.Gotham
StatusLbl2.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl2.Parent = Content2

local EnemyLbl = Instance.new("TextLabel")
EnemyLbl.Size = UDim2.new(0.9, 0, 0, 18)
EnemyLbl.Position = UDim2.new(0.05, 0, 0, 26)
EnemyLbl.BackgroundTransparency = 1
EnemyLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
EnemyLbl.Text = "ศัตรูใกล้: -"
EnemyLbl.TextSize = 11
EnemyLbl.Font = Enum.Font.Gotham
EnemyLbl.TextXAlignment = Enum.TextXAlignment.Left
EnemyLbl.Parent = Content2

local KillLbl = Instance.new("TextLabel")
KillLbl.Size = UDim2.new(0.9, 0, 0, 18)
KillLbl.Position = UDim2.new(0.05, 0, 0, 47)
KillLbl.BackgroundTransparency = 1
KillLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
KillLbl.Text = "Kill: 0"
KillLbl.TextSize = 11
KillLbl.Font = Enum.Font.Gotham
KillLbl.TextXAlignment = Enum.TextXAlignment.Left
KillLbl.Parent = Content2

local RangeLbl = Instance.new("TextLabel")
RangeLbl.Size = UDim2.new(0.9, 0, 0, 18)
RangeLbl.Position = UDim2.new(0.05, 0, 0, 68)
RangeLbl.BackgroundTransparency = 1
RangeLbl.TextColor3 = Color3.fromRGB(100, 220, 255)
RangeLbl.Text = "Range: " .. AURA_RANGE .. " studs"
RangeLbl.TextSize = 11
RangeLbl.Font = Enum.Font.Gotham
RangeLbl.TextXAlignment = Enum.TextXAlignment.Left
RangeLbl.Parent = Content2

makeDraggable(Frame2, TitleBar2)

local minimized2 = false
BtnMin2.MouseButton1Click:Connect(function()
    minimized2 = not minimized2
    if minimized2 then
        Frame2:TweenSize(UDim2.new(0, 200, 0, 28), "Out", "Quad", 0.2, true)
        BtnMin2.Text = "+"
    else
        Frame2:TweenSize(UDim2.new(0, 200, 0, 133), "Out", "Quad", 0.2, true)
        BtnMin2.Text = "—"
    end
end)
BtnClose2.MouseButton1Click:Connect(function()
    auraActive = false
    Frame2:Destroy()
end)

-- ============ ฟังก์ชัน AutoCollect ============
local function getAllPrompts()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local isPlayerPart = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and part:IsDescendantOf(p.Character) then
                        isPlayerPart = true break
                    end
                end
                if not isPlayerPart then
                    table.insert(list, {prompt = obj, pos = part.Position})
                end
            end
        end
    end
    return list
end

local function collectOne(item)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(item.pos + Vector3.new(0, 2, 0))
    task.wait(0.2)
    pcall(function() fireproximityprompt(item.prompt) end)
    totalCollected = totalCollected + 1
    CountLbl.Text = "เก็บไปแล้ว: " .. totalCollected .. " ชิ้น"
    task.wait(0.15)
end

-- ============ ฟังก์ชัน Aura Kill ============
local function getEnemies()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return {} end
    local myPos = char.HumanoidRootPart.Position
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model = obj.Parent
            if not model or model == char then continue end
            local isPlayer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character == model then isPlayer = true break end
            end
            if isPlayer then continue end
            local root = model:FindFirstChild("HumanoidRootPart")
                      or model:FindFirstChild("Root")
            if not root then continue end
            local dist = (myPos - root.Position).Magnitude
            if dist <= AURA_RANGE then
                table.insert(list, {humanoid = obj, root = root, model = model, dist = dist})
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function attackEnemy(enemy)
    if not enemy.humanoid or enemy.humanoid.Health <= 0 then return end
    local char = LocalPlayer.Character
    if not char then return end
    char.HumanoidRootPart.CFrame = CFrame.new(enemy.root.Position + Vector3.new(0, 3, 0))
    task.wait(0.05)
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then StatusLbl2.Text = "⚠️ ไม่มี Tool!" return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(enemy.root.Position) end)
        end
    end
    for _, v in ipairs(enemy.model:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(function() fireclickdetector(v) end)
        end
    end
    pcall(function() tool:Activate() end)
    if enemy.humanoid.Health <= 0 then
        killCount = killCount + 1
        KillLbl.Text = "Kill: " .. killCount
    end
end

-- ============ เริ่มทำงานทันที ============
task.spawn(function()
    while autoCollect do
        local items = getAllPrompts()
        if #items == 0 then
            StatusLbl1.Text = "รอของ..."
            QueueLbl.Text = "ของในแมพ: ไม่มี"
            task.wait(SCAN_RATE)
        else
            QueueLbl.Text = "ของในแมพ: " .. #items .. " ชิ้น"
            for i, item in ipairs(items) do
                if not autoCollect then break end
                StatusLbl1.Text = "เก็บชิ้นที่ " .. i .. "/" .. #items
                collectOne(item)
            end
            StatusLbl1.Text = "รอของ..."
            QueueLbl.Text = "ของในแมพ: ไม่มี"
        end
    end
end)

task.spawn(function()
    -- รอ AutoCollect ทำงานก่อน 5 วินาที
    for i = 5, 1, -1 do
        StatusLbl2.Text = "รอ AutoCollect... " .. i .. "s"
        task.wait(1)
    end
    StatusLbl2.Text = "สถานะ: กำลังสแกน..."

    while auraActive do
        local enemies = getEnemies()
        if #enemies == 0 then
            StatusLbl2.Text = "รอศัตรู..."
            EnemyLbl.Text = "ศัตรูใกล้: ไม่มี"
            task.wait(0.3)
        else
            EnemyLbl.Text = "ศัตรูใกล้: " .. #enemies .. " ตัว"
            for _, enemy in ipairs(enemies) do
                if not auraActive then break end
                StatusLbl2.Text = "⚔️ " .. enemy.model.Name
                attackEnemy(enemy)
                task.wait(ATTACK_RATE)
            end
        end
    end
end)
