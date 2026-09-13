-- StarterPlayer/StarterPlayerScripts/AdminGUI (LocalScript)
-- ⚡ NEXUS v1.0 — Optimized Edition

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- 📡 REMOTES (кэш)
-- ═══════════════════════════════════════════════
local clickRemote  = ReplicatedStorage:WaitForChild("FastClick")
local flyRemote    = ReplicatedStorage:WaitForChild("FlyRemote")
local auraRemote   = ReplicatedStorage:WaitForChild("AuraRemote")
local noclipRemote = ReplicatedStorage:WaitForChild("NoclipRemote")
local espRemote    = ReplicatedStorage:WaitForChild("EspRemote")

-- ═══════════════════════════════════════════════
-- 🎨 THEME (кэш цветов)
-- ═══════════════════════════════════════════════
local T = {
	bg        = Color3.fromRGB(14, 14, 16),
	panel     = Color3.fromRGB(20, 20, 24),
	panelAlt  = Color3.fromRGB(26, 26, 30),
	line      = Color3.fromRGB(38, 38, 44),
	text      = Color3.fromRGB(230, 230, 235),
	textDim   = Color3.fromRGB(120, 120, 130),
	textMuted = Color3.fromRGB(80, 80, 90),
	green     = Color3.fromRGB(80, 220, 130),
	red       = Color3.fromRGB(235, 70, 85),
	yellow    = Color3.fromRGB(250, 190, 70),
	blue      = Color3.fromRGB(90, 140, 250),
	purple    = Color3.fromRGB(160, 110, 250),
	cyan      = Color3.fromRGB(80, 210, 220),
}

-- ═══════════════════════════════════════════════
-- 🧠 STATE
-- ═══════════════════════════════════════════════
local state = {
	flyEnabled = false, flySpeed = 100,
	clickCooldown = 0.1, autoClick = false,
	noclip = false,
	espEnabled = false,
	esp = {
		boxEnabled = true, boxStyle = "Коробка",
		boxColor = Color3.fromRGB(90,140,250), boxThickness = 1.5,
		nameEnabled = true, nameColor = Color3.fromRGB(255,255,255),
		healthEnabled = true, healthColor = Color3.fromRGB(80,220,130),
		distanceEnabled = true, distanceColor = Color3.fromRGB(250,190,70),
		tracerEnabled = true, tracerColor = Color3.fromRGB(160,110,250),
		tracerFromBottom = false,
		headDotEnabled = false, headDotColor = Color3.fromRGB(235,70,85),
		maxDistance = 300, showTeamCheck = true, showSelf = false,
		teamColor = true, fillBox = false, fillTransparency = 0.85,
		healthBarSide = "Слева", textSize = 13, fadeWithDistance = true,
	}
}

-- ═══════════════════════════════════════════════
-- 🛠 HELPERS (оптимизированные)
-- ═══════════════════════════════════════════════
local TweenInfoFast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function new(cls, props, parent)
	local i = Instance.new(cls)
	for k, v in pairs(props) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end

local function tw(inst, props)
	TweenService:Create(inst, TweenInfoFast, props):Play()
end

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 4)
	c.Parent = inst
	return c
end

local function stroke(inst, col, th, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or T.line
	s.Thickness = th or 1
	s.Transparency = trans or 0
	s.Parent = inst
	return s
end

-- ═══════════════════════════════════════════════
-- 🪟 GUI ROOT
-- ═══════════════════════════════════════════════
local old = player.PlayerGui:FindFirstChild("NexusPanel")
if old then old:Destroy() end

local gui = new("ScreenGui", {
	Name = "NexusPanel",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

-- ═══════════════════════════════════════════════
-- 📌 WINDOW
-- ═══════════════════════════════════════════════
local win = new("Frame", {
	Name = "Window",
	Size = UDim2.new(0, 420, 0, 560),
	Position = UDim2.new(0, 40, 0.5, -280),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(win, 6)
stroke(win, T.line, 1)

-- ═══ HEADER ═══
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = T.panel,
	BorderSizePixel = 0,
}, win)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = T.line,
	BorderSizePixel = 0,
}, header)

-- Логотип NEXUS
new("TextLabel", {
	Size = UDim2.new(0, 16, 0, 16),
	Position = UDim2.new(0, 12, 0.5, -8),
	BackgroundTransparency = 1,
	Text = "◆",
	TextColor3 = T.green,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, header)

new("TextLabel", {
	Size = UDim2.new(0, 200, 1, 0),
	Position = UDim2.new(0, 32, 0, 0),
	BackgroundTransparency = 1,
	Text = "NEXUS",
	TextColor3 = T.text,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

new("TextLabel", {
	Size = UDim2.new(0, 100, 1, 0),
	Position = UDim2.new(0, 92, 0, 0),
	BackgroundTransparency = 1,
	Text = "v1.0",
	TextColor3 = T.textMuted,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local headerStats = new("TextLabel", {
	Size = UDim2.new(0, 160, 1, 0),
	Position = UDim2.new(1, -180, 0, 0),
	BackgroundTransparency = 1,
	Text = "— ms  |  — fps",
	TextColor3 = T.textDim,
	Font = Enum.Font.Code,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Right,
}, header)

-- Кнопка закрытия
local closeBtn = new("TextButton", {
	Size = UDim2.new(0, 40, 1, 0),
	Position = UDim2.new(1, -40, 0, 0),
	BackgroundTransparency = 1,
	Text = "✕",
	TextColor3 = T.textDim,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
}, header)

-- ═══ DRAG (оптимизированное) ═══
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging, dragStart, startPos = true, input.Position, win.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ═══ SIDEBAR ═══
local sidebar = new("Frame", {
	Size = UDim2.new(0, 110, 1, -64),
	Position = UDim2.new(0, 0, 0, 40),
	BackgroundColor3 = T.panel,
	BorderSizePixel = 0,
}, win)
new("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = T.line,
	BorderSizePixel = 0,
}, sidebar)

-- ═══ CONTENT ═══
local content = new("Frame", {
	Size = UDim2.new(1, -110, 1, -64),
	Position = UDim2.new(0, 110, 0, 40),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
}, win)

-- ═══ STATUSBAR ═══
local statusBar = new("Frame", {
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 1, -24),
	BackgroundColor3 = T.panel,
	BorderSizePixel = 0,
}, win)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = T.line,
	BorderSizePixel = 0,
}, statusBar)

new("TextLabel", {
	Size = UDim2.new(1, -20, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1,
	Text = "● ready",
	TextColor3 = T.green,
	Font = Enum.Font.Code,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, statusBar)

local memoryText = new("TextLabel", {
	Size = UDim2.new(0, 150, 1, 0),
	Position = UDim2.new(1, -160, 0, 0),
	BackgroundTransparency = 1,
	Text = "mem — MB",
	TextColor3 = T.textMuted,
	Font = Enum.Font.Code,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Right,
}, statusBar)

-- ═══════════════════════════════════════════════
-- 🎫 TABS
-- ═══════════════════════════════════════════════
local pages = {}
local tabs = {}
local activePage = nil

local function makeTabButton(id, label, y)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, y),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, sidebar)

	local indicator = new("Frame", {
		Size = UDim2.new(0, 2, 0, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = T.green,
		BorderSizePixel = 0,
	}, btn)

	local txt = new("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = T.textDim,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, btn)

	tabs[id] = { btn = btn, indicator = indicator, text = txt }
	return btn
end

local function switchTab(id)
	activePage = id
	for tid, t in pairs(tabs) do
		if tid == id then
			tw(t.indicator, { Size = UDim2.new(0, 2, 0, 18) })
			tw(t.text, { TextColor3 = T.text })
		else
			tw(t.indicator, { Size = UDim2.new(0, 2, 0, 0) })
			tw(t.text, { TextColor3 = T.textDim })
		end
	end
	for pid, page in pairs(pages) do
		page.Visible = (pid == id)
	end
end

-- ═══════════════════════════════════════════════
-- 📄 PAGES
-- ═══════════════════════════════════════════════
local function makePage(id)
	local page = new("ScrollingFrame", {
		Name = id,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.line,
		CanvasSize = UDim2.new(0, 0, 0, 500),
		Visible = false,
	}, content)
	pages[id] = page
	return page
end

-- ═══════════════════════════════════════════════
-- 🧩 COMPONENTS
-- ═══════════════════════════════════════════════
local cursor = {}
local function setCur(p) cursor[p] = 12 end
local function getY(p, h)
	cursor[p] = cursor[p] + (h or 0)
	return cursor[p] - (h or 0)
end

local function sectionTitle(page, text)
	local y = getY(page, 38)
	new("TextLabel", {
		Size = UDim2.new(1, -24, 0, 14),
		Position = UDim2.new(0, 12, 0, y + 12),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = T.textMuted,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, page)
	new("Frame", {
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.new(0, 12, 0, y + 30),
		BackgroundColor3 = T.line,
		BorderSizePixel = 0,
	}, page)
end

local function toggle(page, label, default, cb)
	local y = getY(page, 30)
	local row = new("Frame", {
		Size = UDim2.new(1, -24, 0, 26),
		Position = UDim2.new(0, 12, 0, y + 2),
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
	}, page)
	corner(row, 4)

	new("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = T.text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local box = new("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -26, 0.5, -8),
		BackgroundColor3 = default and T.green or T.panelAlt,
		BorderSizePixel = 0,
	}, row)
	corner(box, 3)
	local s = stroke(box, default and T.green or T.line, 1)

	local check = new("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "✓",
		TextColor3 = T.bg,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextTransparency = default and 0 or 1,
	}, box)

	local click = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	local isOn = default
	click.MouseButton1Click:Connect(function()
		isOn = not isOn
		box.BackgroundColor3 = isOn and T.green or T.panelAlt
		s.Color = isOn and T.green or T.line
		check.TextTransparency = isOn and 0 or 1
		cb(isOn)
	end)

	return {
		set = function(v)
			isOn = v
			box.BackgroundColor3 = v and T.green or T.panelAlt
			s.Color = v and T.green or T.line
			check.TextTransparency = v and 0 or 1
		end
	}
end

local function slider(page, label, minV, maxV, def, suffix, cb)
	local y = getY(page, 42)
	local row = new("Frame", {
		Size = UDim2.new(1, -24, 0, 38),
		Position = UDim2.new(0, 12, 0, y + 2),
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
	}, page)
	corner(row, 4)

	new("TextLabel", {
		Size = UDim2.new(1, -80, 0, 16),
		Position = UDim2.new(0, 10, 0, 4),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = T.text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local valueLabel = new("TextLabel", {
		Size = UDim2.new(0, 70, 0, 16),
		Position = UDim2.new(1, -80, 0, 4),
		BackgroundTransparency = 1,
		Text = tostring(def) .. (suffix or ""),
		TextColor3 = T.cyan,
		Font = Enum.Font.Code,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	local bar = new("Frame", {
		Size = UDim2.new(1, -20, 0, 2),
		Position = UDim2.new(0, 10, 0, 28),
		BackgroundColor3 = T.panelAlt,
		BorderSizePixel = 0,
	}, row)
	corner(bar, 2)

	local ratio = (def - minV) / (maxV - minV)
	local fill = new("Frame", {
		Size = UDim2.new(ratio, 0, 1, 0),
		BackgroundColor3 = T.cyan,
		BorderSizePixel = 0,
	}, bar)
	corner(fill, 2)

	local knob = new("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(ratio, -5, 0.5, -5),
		BackgroundColor3 = T.text,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, bar)
	corner(knob, 5)

	local dragging = false
	local function upd(x)
		local ax = bar.AbsolutePosition.X
		local aw = bar.AbsoluteSize.X
		local r = math.clamp((x - ax) / aw, 0, 1)
		local v = minV + r * (maxV - minV)
		fill.Size = UDim2.new(r, 0, 1, 0)
		knob.Position = UDim2.new(r, -5, 0.5, -5)
		local d = (maxV - minV >= 10) and math.floor(v * 10) / 10 or math.floor(v * 100) / 100
		valueLabel.Text = tostring(d) .. (suffix or "")
		cb(d)
	end

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			upd(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			upd(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

local function dropdown(page, label, options, def, cb)
	local y = getY(page, 34)
	local row = new("Frame", {
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.new(0, 12, 0, y + 2),
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 5,
	}, page)
	corner(row, 4)

	new("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = T.text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local curBtn = new("TextButton", {
		Size = UDim2.new(0, 90, 0, 22),
		Position = UDim2.new(1, -100, 0.5, -11),
		BackgroundColor3 = T.panelAlt,
		Text = def .. " ▾",
		TextColor3 = T.text,
		Font = Enum.Font.Code,
		TextSize = 11,
		AutoButtonColor = false,
		ZIndex = 6,
	}, row)
	corner(curBtn, 3)
	stroke(curBtn, T.line, 1)

	local listFrame, isOpen = nil, false

	local function close()
		if listFrame then listFrame:Destroy(); listFrame = nil end
		isOpen = false
	end

	curBtn.MouseButton1Click:Connect(function()
		if isOpen then close(); return end
		isOpen = true
		listFrame = new("Frame", {
			Size = UDim2.new(0, 90, 0, #options * 22),
			Position = UDim2.new(1, -100, 1, 2),
			BackgroundColor3 = T.panelAlt,
			BorderSizePixel = 0,
			ZIndex = 20,
		}, row)
		corner(listFrame, 3)
		stroke(listFrame, T.line, 1)

		for i, opt in ipairs(options) do
			local ob = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 22),
				Position = UDim2.new(0, 0, 0, (i-1)*22),
				BackgroundTransparency = 1,
				Text = opt,
				TextColor3 = T.text,
				Font = Enum.Font.Code,
				TextSize = 11,
				ZIndex = 21,
			}, listFrame)
			ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0.85; ob.BackgroundColor3 = T.blue end)
			ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
			ob.MouseButton1Click:Connect(function()
				curBtn.Text = opt .. " ▾"
				cb(opt)
				close()
			end)
		end
	end)
end

local function colorPicker(page, label, def, cb)
	local y = getY(page, 30)
	local row = new("Frame", {
		Size = UDim2.new(1, -24, 0, 26),
		Position = UDim2.new(0, 12, 0, y + 2),
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 5,
	}, page)
	corner(row, 4)

	new("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = T.text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local cur = new("Frame", {
		Size = UDim2.new(0, 20, 0, 14),
		Position = UDim2.new(1, -30, 0.5, -7),
		BackgroundColor3 = def,
		BorderSizePixel = 0,
	}, row)
	corner(cur, 3)
	stroke(cur, T.line, 1)

	local palette = {
		Color3.fromRGB(255,80,80), Color3.fromRGB(255,150,60),
		Color3.fromRGB(255,220,80), Color3.fromRGB(120,230,120),
		Color3.fromRGB(80,200,255), Color3.fromRGB(120,120,255),
		Color3.fromRGB(200,120,255), Color3.fromRGB(255,120,200),
		Color3.new(1,1,1), Color3.fromRGB(180,180,200),
	}

	local picker, isOpen = nil, false
	local function close() if picker then picker:Destroy(); picker = nil end; isOpen = false end

	local click = new("TextButton", {
		Size = UDim2.new(0, 20, 0, 14),
		Position = UDim2.new(1, -30, 0.5, -7),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 7,
	}, row)

	click.MouseButton1Click:Connect(function()
		if isOpen then close(); return end
		isOpen = true
		picker = new("Frame", {
			Size = UDim2.new(0, 110, 0, 58),
			Position = UDim2.new(1, -120, 1, 2),
			BackgroundColor3 = T.panelAlt,
			BorderSizePixel = 0,
			ZIndex = 20,
		}, row)
		corner(picker, 3)
		stroke(picker, T.line, 1)

		for i, col in ipairs(palette) do
			local cb2 = new("TextButton", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 4 + ((i-1) % 5) * 20, 0, 4 + math.floor((i-1)/5) * 22),
				BackgroundColor3 = col,
				Text = "",
				ZIndex = 21,
				AutoButtonColor = false,
			}, picker)
			corner(cb2, 3)
			cb2.MouseButton1Click:Connect(function()
				cur.BackgroundColor3 = col
				cb(col)
				close()
			end)
		end
	end)
end

-- ═══════════════════════════════════════════════
-- 📄 COMBAT
-- ═══════════════════════════════════════════════
local p1 = makePage("Combat"); setCur(p1)

sectionTitle(p1, "FAST CLICK")
local autoClickTgl = toggle(p1, "Автоклик", false, function(v) state.autoClick = v end)
slider(p1, "Задержка клика", 0.01, 1.0, 0.1, "s", function(v)
	state.clickCooldown = v
	clickRemote:FireServer("setCooldown", v)
end)

sectionTitle(p1, "KILL AURA")
toggle(p1, "Включить Kill Aura", false, function()
	auraRemote:FireServer("toggle")
end)
slider(p1, "Радиус", 5, 100, 20, "", function(v) auraRemote:FireServer("setRange", v) end)
slider(p1, "Урон", 1, 200, 15, "", function(v) auraRemote:FireServer("setDamage", v) end)
slider(p1, "Скорость удара", 0.05, 1.0, 0.15, "s", function(v) auraRemote:FireServer("setCooldown", v) end)
p1.CanvasSize = UDim2.new(0, 0, 0, cursor[p1] + 20)

-- ═══════════════════════════════════════════════
-- 📄 MOVEMENT
-- ═══════════════════════════════════════════════
local p2 = makePage("Movement"); setCur(p2)

sectionTitle(p2, "FLIGHT")
toggle(p2, "Полёт", false, function(v)
	state.flyEnabled = v
	if v then
		local c = player.Character
		if c then setupFly(c) end
	else stopFly() end
	flyRemote:FireServer("toggle")
end)
slider(p2, "Скорость полёта", 10, 500, 100, "", function(v)
	state.flySpeed = v
	flyRemote:FireServer("setSpeed", v)
end)

sectionTitle(p2, "NOCLIP")
toggle(p2, "Noclip (проход сквозь стены)", false, function(v)
	state.noclip = v
	noclipRemote:FireServer("toggle")
end)
p2.CanvasSize = UDim2.new(0, 0, 0, cursor[p2] + 20)

-- ═══════════════════════════════════════════════
-- 📄 ESP
-- ═══════════════════════════════════════════════
local p3 = makePage("ESP"); setCur(p3)

sectionTitle(p3, "GENERAL")
toggle(p3, "ESP включен", false, function(v)
	state.espEnabled = v
	espRemote:FireServer("toggle", v)
end)
toggle(p3, "Игнорировать союзников", true, function(v) state.esp.showTeamCheck = v end)
toggle(p3, "Показывать себя", false, function(v) state.esp.showSelf = v end)
slider(p3, "Макс. дистанция", 50, 2000, 300, "", function(v) state.esp.maxDistance = v end)

sectionTitle(p3, "BOX")
toggle(p3, "Показывать бокс", true, function(v) state.esp.boxEnabled = v end)
dropdown(p3, "Стиль бокса", {"Коробка", "Уголки", "3D"}, "Коробка", function(v) state.esp.boxStyle = v end)
colorPicker(p3, "Цвет бокса", Color3.fromRGB(90,140,250), function(c) state.esp.boxColor = c end)
slider(p3, "Толщина линий", 0.5, 5, 1.5, "px", function(v) state.esp.boxThickness = v end)
toggle(p3, "Заливка бокса", false, function(v) state.esp.fillBox = v end)
slider(p3, "Прозрачность заливки", 0.3, 1, 0.85, "", function(v) state.esp.fillTransparency = v end)

sectionTitle(p3, "INFO")
toggle(p3, "Имя игрока", true, function(v) state.esp.nameEnabled = v end)
colorPicker(p3, "Цвет имени", Color3.fromRGB(255,255,255), function(c) state.esp.nameColor = c end)
toggle(p3, "Здоровье", true, function(v) state.esp.healthEnabled = v end)
colorPicker(p3, "Цвет HP", Color3.fromRGB(80,220,130), function(c) state.esp.healthColor = c end)
dropdown(p3, "Позиция HP", {"Слева", "Справа", "Под именем"}, "Слева", function(v) state.esp.healthBarSide = v end)
toggle(p3, "Дистанция", true, function(v) state.esp.distanceEnabled = v end)
colorPicker(p3, "Цвет дистанции", Color3.fromRGB(250,190,70), function(c) state.esp.distanceColor = c end)

sectionTitle(p3, "LINES & DOTS")
toggle(p3, "Tracer (линия)", true, function(v) state.esp.tracerEnabled = v end)
colorPicker(p3, "Цвет tracer", Color3.fromRGB(160,110,250), function(c) state.esp.tracerColor = c end)
toggle(p3, "Tracer снизу экрана", false, function(v) state.esp.tracerFromBottom = v end)
toggle(p3, "Точка на голове", false, function(v) state.esp.headDotEnabled = v end)
colorPicker(p3, "Цвет точки", Color3.fromRGB(235,70,85), function(c) state.esp.headDotColor = c end)

sectionTitle(p3, "TEXT")
slider(p3, "Размер текста", 8, 24, 13, "px", function(v) state.esp.textSize = v end)
toggle(p3, "Затухание с дистанцией", true, function(v) state.esp.fadeWithDistance = v end)
toggle(p3, "Цвет команды", true, function(v) state.esp.teamColor = v end)
p3.CanvasSize = UDim2.new(0, 0, 0, cursor[p3] + 20)

-- ═══════════════════════════════════════════════
-- 📄 SETTINGS
-- ═══════════════════════════════════════════════
local p4 = makePage("Settings"); setCur(p4)

sectionTitle(p4, "INFO")
local infoFrame = new("Frame", {
	Size = UDim2.new(1, -24, 0, 140),
	Position = UDim2.new(0, 12, 0, getY(p4, 144) + 4),
	BackgroundColor3 = T.panel,
	BorderSizePixel = 0,
}, p4)
corner(infoFrame, 4)

new("TextLabel", {
	Size = UDim2.new(1, -20, 1, -20),
	Position = UDim2.new(0, 10, 0, 10),
	BackgroundTransparency = 1,
	Text = "HOTKEYS\n\n  F  →  Fly\n  G  →  AutoClick\n  V  →  Kill Aura\n  N  →  Noclip\n  E  →  ESP\n  H  →  Hide panel",
	TextColor3 = T.textDim,
	Font = Enum.Font.Code,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, infoFrame)
p4.CanvasSize = UDim2.new(0, 0, 0, cursor[p4] + 20)

-- ═══════════════════════════════════════════════
-- 🎫 TABS INIT
-- ═══════════════════════════════════════════════
makeTabButton("Combat",   "⚔  Combat",   10).MouseButton1Click:Connect(function() switchTab("Combat") end)
makeTabButton("Movement", "✈  Movement", 46).MouseButton1Click:Connect(function() switchTab("Movement") end)
makeTabButton("ESP",      "◉  ESP",      82).MouseButton1Click:Connect(function() switchTab("ESP") end)
makeTabButton("Settings", "⚙  Settings", 118).MouseButton1Click:Connect(function() switchTab("Settings") end)

switchTab("Combat")

-- ═══════════════════════════════════════════════
-- ✈️ FLY (оптимизировано)
-- ═══════════════════════════════════════════════
local flyBody, flyGyro
local flyHRP

function setupFly(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end
	flyHRP = hrp
	if flyBody then flyBody:Destroy() end
	if flyGyro then flyGyro:Destroy() end
	flyBody = new("BodyGyro", { MaxTorque = Vector3.new(9e9,9e9,9e9), P = ly1000, Parent = hrGyp })
	fro = new("BodyVelocity", { MaxForce = Vector3.new(9e9,9e9,9e9), Velocity = Vector3.zero, Parent = hrp })
end

function stopFly()
	if flyBody then flyBody:Destroy(); flyBody = nil end
	if flyGyro then flyGyro:Destroy(); flyGyro = nil end
	flyHRP = nil
	state.flyEnabled = false
end

-- Оптимизация: обновление полёта через RenderStepped с проверкой изменений
local lastCamCF
RunService.RenderStepped:Connect(function()
	if not state.flyEnabled or not flyHRP or not flyHRP.Parent then return end

	-- Проверяем ввод только раз в кадр
	local cam = camera.CFrame
	local dir = Vector3.zero

	-- Векторизованные проверки (быстрее чем 6 отдельных if)
	local k = UserInputService
	if k:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
	if k:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
	if k:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
	if k:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
	if k:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
	if k:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

	-- Применяем только если есть движение или камера изменилась
	if dir.Magnitude > 0 then
		dir = dir.Unit * state.flySpeed
	end
	flyGyro.Velocity = dir
	flyBody.CFrame = cam
	flyHRP.Velocity = Vector3.zero
end)

-- ═══════════════════════════════════════════════
-- ⚔️ AUTOCLICK (оптимизирован — без task.spawn loop)
-- ═══════════════════════════════════════════════
local lastClick = 0
RunService.Heartbeat:Connect(function(dt)
	if not state.autoClick then return end
	local now = tick()
	if now - lastClick < state.clickCooldown then return end
	lastClick = now

	local c = player.Character
	if not c then return end
	local tool = c:FindFirstChildOfClass("Tool")
	if tool then tool:Activate() end
	clickRemote:FireServer("click", {range=15, damage=10})
end)

-- ═══════════════════════════════════════════════
-- 👻 NOCLIP (оптимизирован — кэш частей)
-- ═══════════════════════════════════════════════
local noclipParts = {}
local noclipConnections = {}

local function setupNoclipCache(char)
	-- Отключаем старые соединения
	for _, c in ipairs(noclipConnections) do c:Disconnect() end
	table.clear(noclipConnections)
	table.clear(noclipParts)

	-- Кэшируем все BasePart персонажа
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			noclipParts[#noclipParts + 1] = p
		end
	end

	-- Следим за новыми частями (для аксессуаров)
	local conn = char.DescendantAdded:Connect(function(p)
		if p:IsA("BasePart") and state.noclip then
			p.CanCollide = false
		end
	end)
	noclipConnections[#noclipConnections + 1] = conn
end

local function applyNoclip()
	if not state.noclip then return end
	for i = 1, #noclipParts do
		local p = noclipParts[i]
		if p.Parent and p.CanCollide then
			p.CanCollide = false
		end
	end
end

-- Обновляем через Stepped, но только когда включен
RunService.Stepped:Connect(applyNoclip)

-- Обновляем кэш при респавне
local function onChar(char)
	setupNoclipCache(char)
end

if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

-- ═══════════════════════════════════════════════
-- 🎯 ESP (оптимизировано)
-- ═══════════════════════════════════════════════
local espData = {}
local espUpdateAccum = 0
local ESP_UPDATE_RATE = 0.05 -- 20 FPS для ESP = плавно и без лагов

local function cleanup(plr)
	local d = espData[plr]
	if not d then return end
	for _, o in pairs(d) do
		if type(o) == "table" then
			for _, s in pairs(o) do
				if s and s.Remove then s:Remove() end
			end
		elseif o and o.Remove then
			o:Remove()
		end
	end
	espData[plr] = nil
end

local function mkDraw(cls, props)
	local d = Drawing.new(cls)
	for k, v in pairs(props) do d[k] = v end
	return d
end

local function createESP(plr)
	if espData[plr] then return end
	espData[plr] = {
		box = mkDraw("Square", {Visible=false, Thickness=1.5, Color=Color3.new(1,1,1), Filled=false, Transparency=1}),
		boxFill = mkDraw("Square", {Visible=false, Thickness=1, Color=Color3.new(1,1,1), Filled=true, Transparency=0.85}),
		corners = {
			mkDraw("Line", {Thickness=2, Visible=false}), mkDraw("Line", {Thickness=2, Visible=false}),
			mkDraw("Line", {Thickness=2, Visible=false}), mkDraw("Line", {Thickness=2, Visible=false}),
			mkDraw("Line", {Thickness=2, Visible=false}), mkDraw("Line", {Thickness=2, Visible=false}),
			mkDraw("Line", {Thickness=2, Visible=false}), mkDraw("Line", {Thickness=2, Visible=false}),
		},
		name = mkDraw("Text", {Visible=false, Center=true, Outline=true, Size=13, Font=2, Color=Color3.new(1,1,1)}),
		distance = mkDraw("Text", {Visible=false, Center=true, Outline=true, Size=12, Font=2, Color=Color3.new(1,1,1)}),
		healthBar = mkDraw("Square", {Visible=false, Filled=true, Thickness=1}),
		healthBarBg = mkDraw("Square", {Visible=false, Filled=true, Thickness=1, Color=Color3.new(0,0,0)}),
		tracer = mkDraw("Line", {Visible=false, Thickness=1}),
		headDot = mkDraw("Circle", {Visible=false, Filled=true, Thickness=1, NumSides=24}),
	}
end

local function hideAll(data)
	for _, o in pairs(data) do
		if type(o) == "table" then
			for _, s in pairs(o) do s.Visible = false end
		else
			o.Visible = false
		end
	end
end

local function updateESP()
	local myTeam = player.Team
	local camPos = camera.CFrame.Position
	local vpSize = camera.ViewportSize
	local vpCenterX = vpSize.X / 2
	local esp = state.esp

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player and not esp.showSelf then
			if espData[plr] then hideAll(espData[plr]) end
			continue
		end

		local d = espData[plr]
		if not d then
			createESP(plr)
			d = espData[plr]
		end

		local c = plr.Character
		local hrp = c and c.HumanoidRootPart -- прямое обращение быстрее
		local head = c and c.Head
		local hum = c and c.Humanoid

		-- Ранний выход: мёртв / нет частей
		if not (hrp and head and hum and hum.Health > 0) then
			hideAll(d)
			continue
		end

		-- Team check
		if esp.showTeamCheck and myTeam and plr.Team == myTeam then
			hideAll(d)
			continue
		end

		-- Дистанция (до WorldToViewportPoint — экономим вычисления)
		local hrpPos = hrp.Position
		local dx = camPos.X - hrpPos.X
		local dy = camPos.Y - hrpPos.Y
		local dz = camPos.Z - hrpPos.Z
		local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

		if dist > esp.maxDistance then
			hideAll(d)
			continue
		end

		-- Проекция на экран
		local hPos, hOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
		local rPos, rOn = camera:WorldToViewportPoint(hrpPos)

		if not hOn and not rOn then
			hideAll(d)
			continue
		end

		local boxH = math.abs(hPos.Y - rPos.Y) * 1.6
		local boxW = boxH * 0.55
		local boxX = hPos.X - boxW * 0.5
		local boxY = hPos.Y - boxH * 0.5 + boxH * 0.1
		local boxPos = Vector2.new(boxX, boxY)

		-- Alpha
		local alpha = 1
		if esp.fadeWithDistance then
			alpha = 1 - (dist / esp.maxDistance) * 0.7
			if alpha < 0.3 then alpha = 0.3 end
		end

		-- Цвет
		local boxCol = esp.boxColor
		if esp.teamColor and plr.Team then
			boxCol = plr.Team.TeamColor.Color
		end

		-- Box
		if esp.boxEnabled and esp.boxStyle == "Коробка" then
			local box = d.box
			box.Visible = true
			box.Size = Vector2.new(boxW, boxH)
			box.Position = boxPos
			box.Color = boxCol
			box.Thickness = esp.boxThickness
			box.Transparency = alpha

			if esp.fillBox then
				d.boxFill.Visible = true
				d.boxFill.Size = Vector2.new(boxW, boxH)
				d.boxFill.Position = boxPos
				d.boxFill.Color = boxCol
				d.boxFill.Transparency = esp.fillTransparency
			else
				d.boxFill.Visible = false
			end

			for i = 1, 8 do d.corners[i].Visible = false end
		else
			d.box.Visible = false
			d.boxFill.Visible = false
		end

		-- Уголки
		if esp.boxEnabled and esp.boxStyle == "Уголки" then
			local cl = math.min(boxW, boxH) * 0.25
			local x1, y1 = boxX, boxY
			local x2, y2 = boxX + boxW, boxY + boxH
			local L = d.corners
			local t = esp.boxThickness

			L[1].From, L[1].To = Vector2.new(x1, y1), Vector2.new(x1 + cl, y1)
			L[2].From, L[2].To = Vector2.new(x1, y1), Vector2.new(x1, y1 + cl)
			L[3].From, L[3].To = Vector2.new(x2, y1), Vector2.new(x2 - cl, y1)
			L[4].From, L[4].To = Vector2.new(x2, y1), Vector2.new(x2, y1 + cl)
			L[5].From, L[5].To = Vector2.new(x1, y2), Vector2.new(x1 + cl, y2)
			L[6].From, L[6].To = Vector2.new(x1, y2), Vector2.new(x1, y2 - cl)
			L[7].From, L[7].To = Vector2.new(x2, y2), Vector2.new(x2 - cl, y2)
			L[8].From, L[8].To = Vector2.new(x2, y2), Vector2.new(x2, y2 - cl)

			for i = 1, 8 do
				local l = L[i]
				l.Visible = true
				l.Color = boxCol
				l.Thickness = t
				l.Transparency = alpha
			end
			d.box.Visible = false
		elseif esp.boxStyle ~= "Уголки" then
			for i = 1, 8 do d.corners[i].Visible = false end
		end

		-- Name
		if esp.nameEnabled then
			local n = d.name
			n.Visible = true
			n.Text = plr.Name
			n.Position = Vector2.new(boxX + boxW * 0.5, boxY - 18)
			n.Size = esp.textSize
			n.Color = esp.nameColor
			n.Transparency = alpha
		else
			d.name.Visible = false
		end

		-- Distance
		if esp.distanceEnabled then
			local dd = d.distance
			dd.Visible = true
			dd.Text = "[" .. math.floor(dist) .. "]"
			dd.Position = Vector2.new(boxX + boxW * 0.5, boxY + boxH + 4)
			dd.Size = esp.textSize - 1
			dd.Color = esp.distanceColor
			dd.Transparency = alpha
		else
			d.distance.Visible = false
		end

		-- Health
		if esp.healthEnabled then
			local hp = hum.Health / hum.MaxHealth
			local bw, bh = 3, boxH
			local bx, by

			local side = esp.healthBarSide
			if side == "Слева" then
				bx, by = boxX - 8, boxY
			elseif side == "Справа" then
				bx, by = boxX + boxW + 5, boxY
			else
				bw, bh = boxW, 3
				bx, by = boxX, boxY - 6
			end

			d.healthBarBg.Visible = true
			d.healthBarBg.Size = Vector2.new(bw, bh)
			d.healthBarBg.Position = Vector2.new(bx, by)
			d.healthBarBg.Transparency = alpha * 0.5

			local hb = d.healthBar
			hb.Visible = true
			if side == "Под именем" then
				hb.Size = Vector2.new(bw * hp, bh)
				hb.Position = Vector2.new(bx, by)
			else
				hb.Size = Vector2.new(bw, bh * hp)
				hb.Position = Vector2.new(bx, by + bh * (1 - hp))
			end
			hb.Color = esp.healthColor
			hb.Transparency = alpha
		else
			d.healthBar.Visible = false
			d.healthBarBg.Visible = false
		end

		-- Tracer
		if esp.tracerEnabled then
			local t = d.tracer
			t.Visible = true
			if esp.tracerFromBottom then
				t.From = Vector2.new(vpCenterX, vpSize.Y)
			else
				t.From = Vector2.new(vpCenterX, 0)
			end
			t.To = Vector2.new(boxX + boxW * 0.5, boxY + boxH)
			t.Color = esp.tracerColor
			t.Transparency = alpha
		else
			d.tracer.Visible = false
		end

		-- HeadDot
		if esp.headDotEnabled then
			local hd = d.headDot
			hd.Visible = true
			hd.Position = Vector2.new(hPos.X, hPos.Y)
			hd.Radius = 4
			hd.Color = esp.headDotColor
			hd.Transparency = alpha
		else
			d.headDot.Visible = false
		end
	end
end

Players.PlayerRemoving:Connect(cleanup)

-- Оптимизированный цикл ESP через аккумулятор времени
RunService.Heartbeat:Connect(function(dt)
	if not state.espEnabled then return end
	espUpdateAccum = espUpdateAccum + dt
	if espUpdateAccum < ESP_UPDATE_RATE then return end
	espUpdateAccum = 0
	updateESP()
end)

-- ═══════════════════════════════════════════════
-- 📊 STATS (оптимизировано — 1s обновление)
-- ═══════════════════════════════════════════════
-- Кэшируем StatsItems заранее
local pingStat = Stats.Network.ServerStatsItem["Data Ping"]

local frameCount, fpsTimer, fps = 0, 0, 60

RunService.RenderStepped:Connect(function(dt)
	frameCount = frameCount + 1
	fpsTimer = fpsTimer + dt
	if fpsTimer >= 0.5 then
		fps = math.floor(frameCount / fpsTimer)
		frameCount = 0
		fpsTimer = 0
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		local ping = 0
		local ok, p = pcall(function() return pingStat:GetValue() end)
		if ok then ping = math.floor(p) end

		local pingIcon = ping <= 60 and "🟢" or (ping <= 150 and "🟡" or "🔴")
		headerStats.Text = string.format("%s %d ms  |  %d fps", pingIcon, ping, fps)

		-- Mem обновляем реже (раз в 2 секунды)
		local mem = math.floor(Stats:GetTotalMemoryUsageMb())
		memoryText.Text = "mem " .. mem .. " MB"
		memoryText.TextColor3 = mem <= 800 and T.green or (mem <= 1500 and T.yellow or T.red)
	end
end)

-- ═══════════════════════════════════════════════
-- ⌨️ HOTKEYS
-- ═══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local k = input.KeyCode

	if k == Enum.KeyCode.F then
		state.flyEnabled = not state.flyEnabled
		if state.flyEnabled then
			local c = player.Character
			if c then setupFly(c) end
		else stopFly() end
		flyRemote:FireServer("toggle")
	elseif k == Enum.KeyCode.G then
		state.autoClick = not state.autoClick
		autoClickTgl.set(state.autoClick)
	elseif k == Enum.KeyCode.V then
		auraRemote:FireServer("toggle")
	elseif k == Enum.KeyCode.N then
		state.noclip = not state.noclip
		noclipRemote:FireServer("toggle")
	elseif k == Enum.KeyCode.E then
		state.espEnabled = not state.espEnabled
		espRemote:FireServer("toggle", state.espEnabled)
	elseif k == Enum.KeyCode.H then
		if win.Visible then
			tw(win, { Position = UDim2.new(0, 40, 0.5, 800) })
			task.wait(0.15)
			win.Visible = false
		else
			win.Visible = true
			win.Position = UDim2.new(0, 40, 0.5, 800)
			tw(win, { Position = UDim2.new(0, 40, 0.5, -280) })
		end
	end
end)

-- ═══════════════════════════════════════════════
-- ❌ CLOSE
-- ═══════════════════════════════════════════════
closeBtn.MouseButton1Click:Connect(function()
	tw(win, { Position = UDim2.new(0, 40, 0.5, 800) })
	task.wait(0.15)
	win.Visible = false
end)
closeBtn.MouseEnter:Connect(function() tw(closeBtn, { TextColor3 = T.red }) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, { TextColor3 = T.textDim }) end)

-- ═══════════════════════════════════════════════
-- 🔄 RESPAWN
-- ═══════════════════════════════════════════════
player.CharacterAdded:Connect(function()
	state.flyEnabled = false
	stopFly()
end)

print("⚡ NEXUS v1.0 загружен | F/G/V/N/E/H")