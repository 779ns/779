--[[
    NEXUS — Blox Fruits Edition
    Uses in-game remotes (Combat, Abilities, etc.)
    Works ONLY in Blox Fruits
]]--

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Tw = game:GetService("TweenService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Mouse = plr:GetMouse()

-- ═══ STATE ═══
local S = {
    autoClick = false, clickCD = 0.1,
    killAura = false, auraRange = 25, auraCD = 0.15,
    fly = false, flySpeed = 100,
    noclip = false,
    hitboxExpand = false, hitboxSize = 2,
    espOn = false,
    espBoxCol = Color3.fromRGB(90,140,250),
    espNameCol = Color3.fromRGB(255,255,255),
    espHpCol = Color3.fromRGB(80,220,130),
    espDistCol = Color3.fromRGB(250,190,70),
    espMaxD = 500, espName = true, espHp = true, espDist = true, espBox = true,
    espTracer = false, espTrcCol = Color3.fromRGB(160,110,250),
    espTxt = 13, espFill = false, espFillT = 0.85,
}

-- ═══ HELPERS ═══
local function new(cls, props, parent)
    local i = Instance.new(cls)
    for k, v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = i
    return c
end

local function stroke(i, c, t, a)
    local s = Instance.new("UIStroke")
    s.Color = c or Color3.fromRGB(38,38,44)
    s.Thickness = t or 1
    s.Transparency = a or 0
    s.Parent = i
    return s
end

local function protectGui(g)
    pcall(function()
        if gethui then g.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
        else g.Parent = game:GetService("CoreGui") end
    end)
end

-- ═══ FIND BLOX FRUITS REMOTES ═══
-- Ищем типичные ремоуты Blox Fruits
local function findRemote(name)
    local candidates = {
        RS:FindFirstChild(name),
        RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(name),
        RS:FindFirstChild("RemoteEvents") and RS.RemoteEvents:FindFirstChild(name),
        RS:FindFirstChild("CommF") and RS.CommF:FindFirstChild(name),
        RS:FindFirstChild("CommE") and RS.CommE:FindFirstChild(name),
        RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF") and RS.Remotes.CommF:FindFirstChild(name),
    }
    for _, r in ipairs(candidates) do
        if r then return r end
    end
    return nil
end

-- Кэшируем известные ремоуты Blox Fruits (могут обновляться)
local Remotes = {
    CommF = RS:FindFirstChild("CommF") or RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF"),
    CommE = RS:FindFirstChild("CommE") or RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommE"),
    Comm = RS:FindFirstChild("Comm") or RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Comm"),
    Combat = findRemote("Combat"),
    Attack = findRemote("Attack"),
    SendData = findRemote("SendData"),
}

-- Функция отправки в CommF (главный ремоут Blox Fruits)
local function fireCommF(...)
    if Remotes.CommF and Remotes.CommF:IsA("RemoteFunction") then
        pcall(function() Remotes.CommF:InvokeServer(...) end)
    elseif Remotes.CommF and Remotes.CommF:IsA("RemoteEvent") then
        pcall(function() Remotes.CommF:FireServer(...) end)
    end
end

local function fireCommE(...)
    if Remotes.CommE and Remotes.CommE:IsA("RemoteEvent") then
        pcall(function() Remotes.CommE:FireServer(...) end)
    end
end

local function fireCombat(...)
    if Remotes.Combat and Remotes.Combat:IsA("RemoteEvent") then
        pcall(function() Remotes.Combat:FireServer(...) end)
    end
end

-- ═══ BLOX FRUITS: ATTACK ═══
-- Настоящая атака через tool + ремоуты игры
local function bfAttack(target)
    local char = plr.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
        -- Многие Blox Fruits инструменты используют ремоут "Attack"
        if Remotes.Attack then
            pcall(function()
                Remotes.Attack:FireServer(target)
            end)
        end
    end
end

-- ═══ GUI ROOT ═══
pcall(function()
    local o = game:GetService("CoreGui"):FindFirstChild("NexusBF")
    if o then o:Destroy() end
    local o2 = plr.PlayerGui:FindFirstChild("NexusBF")
    if o2 then o2:Destroy() end
end)

local gui = new("ScreenGui", {
    Name = "NexusBF",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
protectGui(gui)

-- ═══ WINDOW ═══
local win = new("Frame", {
    Size = UDim2.new(0, 420, 0, 540),
    Position = UDim2.new(0, 40, 0.5, -270),
    BackgroundColor3 = Color3.fromRGB(14,14,16),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(win, 6)
stroke(win, Color3.fromRGB(38,38,44), 1)

-- Header
local hdr = new("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, win)
new("Frame", {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), BackgroundColor3 = Color3.fromRGB(38,38,44), BorderSizePixel = 0}, hdr)

new("TextLabel", {Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,12,0.5,-10), BackgroundTransparency = 1, Text = "◆", TextColor3 = Color3.fromRGB(80,220,130), Font = Enum.Font.GothamBold, TextSize = 15}, hdr)
new("TextLabel", {Size = UDim2.new(0,200,1,0), Position = UDim2.new(0,36,0,0), BackgroundTransparency = 1, Text = "NEXUS • Blox Fruits", TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, hdr)

local hStat = new("TextLabel", {Size = UDim2.new(0,120,1,0), Position = UDim2.new(1,-160,0,0), BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(120,120,130), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right}, hdr)
local closeBtn = new("TextButton", {Size = UDim2.new(0,40,1,0), Position = UDim2.new(1,-40,0,0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Color3.fromRGB(235,70,85), Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false}, hdr)

-- Drag
local dragging, dStart, wStart
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dStart = i.Position; wStart = win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        win.Position = UDim2.new(wStart.X.Scale, wStart.X.Offset+d.X, wStart.Y.Scale, wStart.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Sidebar
local sbar = new("Frame", {Size = UDim2.new(0,110,1,-64), Position = UDim2.new(0,0,0,40), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, win)
new("Frame", {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0), BackgroundColor3 = Color3.fromRGB(38,38,44), BorderSizePixel = 0}, sbar)
local cont = new("Frame", {Size = UDim2.new(1,-110,1,-64), Position = UDim2.new(0,110,0,40), BackgroundColor3 = Color3.fromRGB(14,14,16), BorderSizePixel = 0}, win)

-- Status
local stbar = new("Frame", {Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, win)
new("Frame", {Size = UDim2.new(1,0,0,1), BackgroundColor3 = Color3.fromRGB(38,38,44), BorderSizePixel = 0}, stbar)
new("TextLabel", {Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = "● ready", TextColor3 = Color3.fromRGB(80,220,130), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, stbar)
local memLbl = new("TextLabel", {Size = UDim2.new(0,140,1,0), Position = UDim2.new(1,-150,0,0), BackgroundTransparency = 1, Text = "mem —", TextColor3 = Color3.fromRGB(80,80,90), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right}, stbar)

-- ═══ UI COMPONENTS ═══
local pages, tabs = {}, {}
local cursor = {}
local function setCur(p) cursor[p] = 12 end
local function getY(p, h)
    cursor[p] = cursor[p] + (h or 0)
    return cursor[p] - (h or 0)
end

local function mkTab(id, label, y)
    local b = new("TextButton", {Size = UDim2.new(1,0,0,34), Position = UDim2.new(0,0,0,y), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, sbar)
    local ind = new("Frame", {Size = UDim2.new(0,2,0,0), Position = UDim2.new(0,0,0.5,0), AnchorPoint = Vector2.new(0,0.5), BackgroundColor3 = Color3.fromRGB(80,220,130), BorderSizePixel = 0}, b)
    local t = new("TextLabel", {Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,14,0,0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(120,120,130), Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, b)
    tabs[id] = {ind = ind, t = t}
    return b
end

local function switchTab(id)
    for tid, t in pairs(tabs) do
        if tid == id then
            Tw:Create(t.ind, TweenInfo.new(0.12), {Size = UDim2.new(0,2,0,18)}):Play()
            Tw:Create(t.t, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(230,230,235)}):Play()
        else
            Tw:Create(t.ind, TweenInfo.new(0.12), {Size = UDim2.new(0,2,0,0)}):Play()
            Tw:Create(t.t, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(120,120,130)}):Play()
        end
    end
    for pid, p in pairs(pages) do p.Visible = (pid == id) end
end

local function mkPage(id)
    local p = new("ScrollingFrame", {Name = id, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(38,38,44), CanvasSize = UDim2.new(0,0,0,600), Visible = false, Elasticity = 0.3}, cont)
    pages[id] = p
    return p
end

local function section(p, txt)
    local y = getY(p, 38)
    new("TextLabel", {Size = UDim2.new(1,-24,0,14), Position = UDim2.new(0,12,0,y+12), BackgroundTransparency = 1, Text = txt, TextColor3 = Color3.fromRGB(80,80,90), Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}, p)
    new("Frame", {Size = UDim2.new(1,-24,0,1), Position = UDim2.new(0,12,0,y+30), BackgroundColor3 = Color3.fromRGB(38,38,44), BorderSizePixel = 0}, p)
end

local function toggle(p, label, def, cb)
    local y = getY(p, 30)
    local row = new("Frame", {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,y+2), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, p)
    corner(row, 4)
    new("TextLabel", {Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local box = new("Frame", {Size = UDim2.new(0,16,0,16), Position = UDim2.new(1,-26,0.5,-8), BackgroundColor3 = def and Color3.fromRGB(80,220,130) or Color3.fromRGB(26,26,30), BorderSizePixel = 0}, row)
    corner(box, 3)
    local s = stroke(box, def and Color3.fromRGB(80,220,130) or Color3.fromRGB(38,38,44), 1)
    local chk = new("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "✓", TextColor3 = Color3.fromRGB(14,14,16), Font = Enum.Font.GothamBold, TextSize = 11, TextTransparency = def and 0 or 1}, box)
    local isOn = def
    new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, row).MouseButton1Click:Connect(function()
        isOn = not isOn
        box.BackgroundColor3 = isOn and Color3.fromRGB(80,220,130) or Color3.fromRGB(26,26,30)
        s.Color = isOn and Color3.fromRGB(80,220,130) or Color3.fromRGB(38,38,44)
        chk.TextTransparency = isOn and 0 or 1
        cb(isOn)
    end)
    return {set = function(v)
        isOn = v
        box.BackgroundColor3 = v and Color3.fromRGB(80,220,130) or Color3.fromRGB(26,26,30)
        s.Color = v and Color3.fromRGB(80,220,130) or Color3.fromRGB(38,38,44)
        chk.TextTransparency = v and 0 or 1
    end}
end

local function slider(p, label, mn, mx, def, suf, cb)
    local y = getY(p, 42)
    local row = new("Frame", {Size = UDim2.new(1,-24,0,38), Position = UDim2.new(0,12,0,y+2), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, p)
    corner(row, 4)
    new("TextLabel", {Size = UDim2.new(1,-80,0,16), Position = UDim2.new(0,10,0,4), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local vLbl = new("TextLabel", {Size = UDim2.new(0,70,0,16), Position = UDim2.new(1,-80,0,4), BackgroundTransparency = 1, Text = tostring(def)..(suf or ""), TextColor3 = Color3.fromRGB(80,210,220), Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right}, row)
    local bar = new("Frame", {Size = UDim2.new(1,-20,0,2), Position = UDim2.new(0,10,0,28), BackgroundColor3 = Color3.fromRGB(26,26,30), BorderSizePixel = 0}, row)
    corner(bar, 2)
    local r = (def-mn)/(mx-mn)
    local fill = new("Frame", {Size = UDim2.new(r,0,1,0), BackgroundColor3 = Color3.fromRGB(80,210,220), BorderSizePixel = 0}, bar)
    corner(fill, 2)
    local knob = new("Frame", {Size = UDim2.new(0,10,0,10), Position = UDim2.new(r,-5,0.5,-5), BackgroundColor3 = Color3.fromRGB(230,230,235), BorderSizePixel = 0, ZIndex = 2}, bar)
    corner(knob, 5)
    local drag = false
    local function upd(x)
        local ax = bar.AbsolutePosition.X
        local aw = bar.AbsoluteSize.X
        local rr = math.clamp((x-ax)/aw, 0, 1)
        local v = mn + rr*(mx-mn)
        fill.Size = UDim2.new(rr,0,1,0)
        knob.Position = UDim2.new(rr,-5,0.5,-5)
        local d = (mx-mn >= 10) and math.floor(v*10)/10 or math.floor(v*100)/100
        vLbl.Text = tostring(d)..(suf or "")
        cb(d)
    end
    local hit = new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, row)
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function colorPick(p, label, def, cb)
    local y = getY(p, 30)
    local row = new("Frame", {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,y+2), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0, ClipsDescendants = false, ZIndex = 5}, p)
    corner(row, 4)
    new("TextLabel", {Size = UDim2.new(1,-110,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local cur = new("Frame", {Size = UDim2.new(0,20,0,14), Position = UDim2.new(1,-30,0.5,-7), BackgroundColor3 = def, BorderSizePixel = 0}, row)
    corner(cur, 3)
    stroke(cur, Color3.fromRGB(38,38,44), 1)
    local palette = {
        Color3.fromRGB(255,80,80), Color3.fromRGB(255,150,60),
        Color3.fromRGB(255,220,80), Color3.fromRGB(120,230,120),
        Color3.fromRGB(80,200,255), Color3.fromRGB(120,120,255),
        Color3.fromRGB(200,120,255), Color3.fromRGB(255,120,200),
        Color3.new(1,1,1), Color3.fromRGB(180,180,200),
    }
    local picker, open = nil, false
    local function close() if picker then picker:Destroy(); picker = nil end; open = false end
    local click = new("TextButton", {Size = UDim2.new(0,20,0,14), Position = UDim2.new(1,-30,0.5,-7), BackgroundTransparency = 1, Text = "", ZIndex = 7}, row)
    click.MouseButton1Click:Connect(function()
        if open then close(); return end
        open = true
        picker = new("Frame", {Size = UDim2.new(0,110,0,58), Position = UDim2.new(1,-120,1,2), BackgroundColor3 = Color3.fromRGB(26,26,30), BorderSizePixel = 0, ZIndex = 20}, row)
        corner(picker, 3)
        stroke(picker, Color3.fromRGB(38,38,44), 1)
        for i, col in ipairs(palette) do
            local cb2 = new("TextButton", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0, 4+((i-1)%5)*20, 0, 4+math.floor((i-1)/5)*22), BackgroundColor3 = col, Text = "", ZIndex = 21, AutoButtonColor = false}, picker)
            corner(cb2, 3)
            cb2.MouseButton1Click:Connect(function()
                cur.BackgroundColor3 = col
                cb(col)
                close()
            end)
        end
    end)
end

-- ═══ PAGES ═══
local p1 = mkPage("Combat"); setCur(p1)
section(p1, "AUTO ATTACK (реальный)")
toggle(p1, "Автоклик", false, function(v) S.autoClick = v end)
slider(p1, "Задержка", 0.05, 1.0, 0.15, "s", function(v) S.clickCD = v end)

section(p1, "KILL AURA (реальная)")
toggle(p1, "Kill Aura", false, function(v) S.killAura = v end)
slider(p1, "Радиус", 5, 100, 25, "", function(v) S.auraRange = v end)
slider(p1, "Скорость", 0.05, 1.0, 0.15, "s", function(v) S.auraCD = v end)

section(p1, "HITBOX EXPANDER")
toggle(p1, "Увеличить хитбоксы врагов", false, function(v)
    S.hitboxExpand = v
    if not v then
        -- Вернуть всем исходный размер
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local orig = part:GetAttribute("NexusOrigSize")
                        if orig then part.Size = orig end
                    end
                end
            end
        end
    end
end)
slider(p1, "Множитель", 1.5, 5, 2, "x", function(v) S.hitboxSize = v end)
p1.CanvasSize = UDim2.new(0,0,0,cursor[p1]+20)

local p2 = mkPage("Movement"); setCur(p2)
section(p2, "FLIGHT")
toggle(p2, "Полёт", false, function(v)
    S.fly = v
    if v then
        local c = plr.Character
        if c then setupFly(c) end
    else stopFly() end
end)
slider(p2, "Скорость", 10, 500, 100, "", function(v) S.flySpeed = v end)

section(p2, "NOCLIP")
toggle(p2, "Noclip", false, function(v) S.noclip = v end)
p2.CanvasSize = UDim2.new(0,0,0,cursor[p2]+20)

local p3 = mkPage("ESP"); setCur(p3)
section(p3, "GENERAL")
toggle(p3, "ESP включен", false, function(v) S.espOn = v end)
toggle(p3, "Показывать бокс", true, function(v) S.espBox = v end)
toggle(p3, "Имя", true, function(v) S.espName = v end)
toggle(p3, "Здоровье", true, function(v) S.espHp = v end)
toggle(p3, "Дистанция", true, function(v) S.espDist = v end)
toggle(p3, "Tracer", false, function(v) S.espTracer = v end)
slider(p3, "Макс. дистанция", 50, 2000, 500, "", function(v) S.espMaxD = v end)
slider(p3, "Размер текста", 8, 24, 13, "px", function(v) S.espTxt = v end)
colorPick(p3, "Цвет бокса", Color3.fromRGB(90,140,250), function(c) S.espBoxCol = c end)
colorPick(p3, "Цвет tracer", Color3.fromRGB(160,110,250), function(c) S.espTrcCol = c end)
p3.CanvasSize = UDim2.new(0,0,0,cursor[p3]+20)

local p4 = mkPage("Info"); setCur(p4)
section(p4, "BLOX FRUITS INFO")
local info = new("Frame", {Size = UDim2.new(1,-24,0,150), Position = UDim2.new(0,12,0,getY(p4,154)+4), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, p4)
corner(info, 4)
new("TextLabel", {Size = UDim2.new(1,-20,1,-20), Position = UDim2.new(0,10,0,10), BackgroundTransparency = 1,
    Text = "Этот скрипт работает ТОЛЬКО в Blox Fruits!\n\nAutoClick/KillAura идут через\nремоуты игры — урон реальный.\n\nHitbox Expander увеличивает\nхитбоксы врагов (легче попасть).\n\nHotkeys: F G V N E H",
    TextColor3 = Color3.fromRGB(120,120,130), Font = Enum.Font.Code, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, info)
p4.CanvasSize = UDim2.new(0,0,0,cursor[p4]+20)

mkTab("Combat", "⚔ Combat", 10).MouseButton1Click:Connect(function() switchTab("Combat") end)
mkTab("Movement", "✈ Move", 46).MouseButton1Click:Connect(function() switchTab("Movement") end)
mkTab("ESP", "◉ ESP", 82).MouseButton1Click:Connect(function() switchTab("ESP") end)
mkTab("Info", "ℹ Info", 118).MouseButton1Click:Connect(function() switchTab("Info") end)

switchTab("Combat")

-- ═══ FLY ═══
local flyBody, flyGyro, flyHRP

function setupFly(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    flyHRP = hrp
    if flyBody then flyBody:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyBody = new("BodyGyro", {MaxTorque = Vector3.new(9e9,9e9,9e9), P = 1000, Parent = hrp})
    flyGyro = new("BodyVelocity", {MaxForce = Vector3.new(9e9,9e9,9e9), Velocity = Vector3.zero, Parent = hrp})
end

function stopFly()
    if flyBody then flyBody:Destroy(); flyBody = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
    flyHRP = nil
    S.fly = false
end

RunService.RenderStepped:Connect(function()
    if not S.fly or not flyHRP or not flyHRP.Parent then return end
    local camCF = cam.CFrame
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
    if dir.Magnitude > 0 then dir = dir.Unit * S.flySpeed end
    flyGyro.Velocity = dir
    flyBody.CFrame = camCF
    flyHRP.Velocity = Vector3.zero
end)

-- ═══ REAL AUTO ATTACK ═══
-- Использует tool:Activate() + ремоуты игры → настоящая атака
local lastClick = 0
RunService.Heartbeat:Connect(function()
    if not S.autoClick then return end
    local now = tick()
    if now - lastClick < S.clickCD then return end
    lastClick = now

    local c = plr.Character
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    -- Дополнительно шлём в CommF (для фруктов)
    fireCommF("Attack")
end)

-- ═══ REAL KILL AURA ═══
local lastAura = 0
RunService.Heartbeat:Connect(function()
    if not S.killAura then return end
    local now = tick()
    if now - lastAura < S.auraCD then return end
    lastAura = now

    local c = plr.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tool = c:FindFirstChildOfClass("Tool")

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= plr and other.Character then
            local oHrp = other.Character:FindFirstChild("HumanoidRootPart")
            local oHum = other.Character:FindFirstChildOfClass("Humanoid")
            if oHrp and oHum and oHum.Health > 0 then
                if (hrp.Position - oHrp.Position).Magnitude <= S.auraRange then
                    -- Активируем tool — это шлёт атаку на сервер
                    if tool then pcall(function() tool:Activate() end) end
                    -- Комбо-ремоуты Blox Fruits
                    fireCombat(other.Character)
                    fireCommF("Attack", other.Character)

                    -- Визуал
                    pcall(function()
                        local exp = Instance.new("Explosion")
                        exp.BlastRadius = 0
                        exp.BlastPressure = 0
                        exp.Position = oHrp.Position
                        exp.Parent = workspace
                        game:GetService("Debris"):AddItem(exp, 0.15)
                    end)
                end
            end
        end
    end
end)

-- ═══ HITBOX EXPANDER ═══
-- Увеличивает хитбоксы ВРАГОВ локально (легче попасть)
local hitboxConns = {}

local function expandHitbox(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not part:GetAttribute("NexusOrigSize") then
                part:SetAttribute("NexusOrigSize", part.Size)
            end
        end
    end
end

local function applyHitbox()
    if not S.hitboxExpand then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local orig = part:GetAttribute("NexusOrigSize") or part.Size
                    if not part:GetAttribute("NexusOrigSize") then
                        part:SetAttribute("NexusOrigSize", orig)
                    end
                    local s = S.hitboxSize
                    part.Size = Vector3.new(orig.X * s, orig.Y * s, orig.Z * s)
                    part.CanCollide = false
                    part.Transparency = 0.7
                    part.Material = Enum.Material.ForceField
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not S.hitboxExpand then return end
    -- Обновляем не каждый кадр — раз в 0.3 сек
    if tick() - (S._lastHb or 0) < 0.3 then return end
    S._lastHb = tick()
    applyHitbox()
end)

-- Возврат хитбоксов при выключении
local oldHitboxState = false
RunService.Heartbeat:Connect(function()
    if oldHitboxState and not S.hitboxExpand then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local orig = part:GetAttribute("NexusOrigSize")
                        if orig then
                            part.Size = orig
                            part.Transparency = 0
                            part.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
        end
    end
    oldHitboxState = S.hitboxExpand
end)

-- ═══ NOCLIP ═══
local nParts, nConns = {}, {}
local function cacheNoclip(c)
    for _, x in ipairs(nConns) do x:Disconnect() end
    table.clear(nConns); table.clear(nParts)
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then nParts[#nParts+1] = p end
    end
    nConns[#nConns+1] = c.DescendantAdded:Connect(function(p)
        if p:IsA("BasePart") and S.noclip then p.CanCollide = false end
    end)
end
RunService.Stepped:Connect(function()
    if not S.noclip then return end
    for i = 1, #nParts do
        local p = nParts[i]
        if p.Parent and p.CanCollide then p.CanCollide = false end
    end
end)
if plr.Character then cacheNoclip(plr.Character) end
plr.CharacterAdded:Connect(cacheNoclip)

-- ═══ ESP ═══
local espData = {}
local accum = 0
local RATE = 0.05
local hasDrawing = pcall(function() local _ = Drawing.new("Square") end)

local function cleanup(p)
    local d = espData[p]
    if not d then return end
    for _, o in pairs(d) do
        if type(o) == "table" then
            for _, s in pairs(o) do if s and s.Remove then pcall(function() s:Remove() end) end end
        elseif o and o.Remove then pcall(function() o:Remove() end) end
    end
    espData[p] = nil
end

local function mkD(cls, props)
    local d = Drawing.new(cls)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function createESP(p)
    if espData[p] or not hasDrawing then return end
    espData[p] = {
        box = mkD("Square", {Visible=false, Thickness=1.5, Color=Color3.new(1,1,1), Filled=false, Transparency=1}),
        boxFill = mkD("Square", {Visible=false, Thickness=1, Color=Color3.new(1,1,1), Filled=true, Transparency=0.85}),
        name = mkD("Text", {Visible=false, Center=true, Outline=true, Size=13, Font=2, Color=Color3.new(1,1,1)}),
        dist = mkD("Text", {Visible=false, Center=true, Outline=true, Size=12, Font=2, Color=Color3.new(1,1,1)}),
        hp = mkD("Square", {Visible=false, Filled=true, Thickness=1}),
        hpBg = mkD("Square", {Visible=false, Filled=true, Thickness=1, Color=Color3.new(0,0,0)}),
        tracer = mkD("Line", {Visible=false, Thickness=1}),
    }
end

local function hide(d)
    for _, o in pairs(d) do
        if type(o) == "table" then
            for _, s in pairs(o) do s.Visible = false end
        else o.Visible = false end
    end
end

local function updateESP()
    local myTeam = plr.Team
    local camPos = cam.CFrame.Position
    local vp = cam.ViewportSize
    local vcx = vp.X / 2

    for _, p in ipairs(Players:GetPlayers()) do
        if p == plr then
            if espData[p] then hide(espData[p]) end
            continue
        end
        local d = espData[p]
        if not d then createESP(p); d = espData[p] end
        if not d then continue end

        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local head = c and c:FindFirstChild("Head")
        local hum = c and c:FindFirstChildOfClass("Humanoid")

        if not (hrp and head and hum and hum.Health > 0) then hide(d); continue end

        local hp = hrp.Position
        local dx, dy, dz = camPos.X-hp.X, camPos.Y-hp.Y, camPos.Z-hp.Z
        local dist = math.sqrt(dx*dx+dy*dy+dz*dz)
        if dist > S.espMaxD then hide(d); continue end

        local hP, hOn = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rP, rOn = cam:WorldToViewportPoint(hp)
        if not hOn and not rOn then hide(d); continue end

        local bh = math.abs(hP.Y - rP.Y) * 1.6
        local bw = bh * 0.55
        local bx, by = hP.X - bw*0.5, hP.Y - bh*0.5 + bh*0.1

        local col = S.espBoxCol
        if p.Team then col = p.Team.TeamColor.Color end

        if S.espBox then
            d.box.Visible = true
            d.box.Size = Vector2.new(bw, bh)
            d.box.Position = Vector2.new(bx, by)
            d.box.Color = col
            d.box.Thickness = 1.5
        else d.box.Visible = false end

        if S.espName then
            d.name.Visible = true
            d.name.Text = p.Name
            d.name.Position = Vector2.new(bx + bw*0.5, by - 18)
            d.name.Size = S.espTxt
            d.name.Color = S.espNameCol
        else d.name.Visible = false end

        if S.espDist then
            d.dist.Visible = true
            d.dist.Text = "[" .. math.floor(dist) .. "]"
            d.dist.Position = Vector2.new(bx + bw*0.5, by + bh + 4)
            d.dist.Size = S.espTxt - 1
            d.dist.Color = S.espDistCol
        else d.dist.Visible = false end

        if S.espHp then
            local hpr = hum.Health / hum.MaxHealth
            d.hpBg.Visible = true
            d.hpBg.Size = Vector2.new(3, bh)
            d.hpBg.Position = Vector2.new(bx - 8, by)
            d.hp.Visible = true
            d.hp.Size = Vector2.new(3, bh * hpr)
            d.hp.Position = Vector2.new(bx - 8, by + bh * (1 - hpr))
            d.hp.Color = S.espHpCol
        else d.hp.Visible = false; d.hpBg.Visible = false end

        if S.espTracer then
            d.tracer.Visible = true
            d.tracer.From = Vector2.new(vcx, 0)
            d.tracer.To = Vector2.new(bx + bw*0.5, by + bh)
            d.tracer.Color = S.espTrcCol
        else d.tracer.Visible = false end
    end
end

Players.PlayerRemoving:Connect(cleanup)
RunService.Heartbeat:Connect(function(dt)
    if not S.espOn then return end
    accum = accum + dt
    if accum < RATE then return end
    accum = 0
    pcall(updateESP)
end)

-- ═══ STATS ═══
local Stats = game:GetService("Stats")
local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
local fc, ft, fps = 0, 0, 60
RunService.RenderStepped:Connect(function(dt)
    fc = fc + 1; ft = ft + dt
    if ft >= 0.5 then fps = math.floor(fc / ft); fc = 0; ft = 0 end
end)
task.spawn(function()
    while gui.Parent do
        task.wait(1)
        local ping = 0
        pcall(function() ping = math.floor(pingStat:GetValue()) end)
        hStat.Text = string.format("%dms | %dfps", ping, fps)
        local mem = math.floor(Stats:GetTotalMemoryUsageMb())
        memLbl.Text = "mem " .. mem .. " MB"
    end
end)

-- ═══ HOTKEYS ═══
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    local k = i.KeyCode
    if k == Enum.KeyCode.F then
        S.fly = not S.fly
        if S.fly then local c = plr.Character; if c then setupFly(c) end else stopFly() end
    elseif k == Enum.KeyCode.G then
        S.autoClick = not S.autoClick
    elseif k == Enum.KeyCode.V then
        S.killAura = not S.killAura
    elseif k == Enum.KeyCode.N then
        S.noclip = not S.noclip
    elseif k == Enum.KeyCode.E then
        S.espOn = not S.espOn
    elseif k == Enum.KeyCode.H then
        win.Visible = not win.Visible
    end
end)

-- ═══ CLOSE ═══
closeBtn.MouseButton1Click:Connect(function()
    Tw:Create(win, TweenInfo.new(0.15), {Position = UDim2.new(0, 40, 0.5, 800)}):Play()
    task.wait(0.15)
    win.Visible = false
end)

-- ═══ RESPAWN ═══
plr.CharacterAdded:Connect(function()
    S.fly = false
    stopFly()
end)

print("⚡ NEXUS Blox Fruits загружен | F/G/V/N/E/H")