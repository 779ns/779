--[[
    NEXUS v1.0 — Universal Edition
    Works in any Roblox game via executor (Delta, Arceus, Synapse, Codex)
]]--

-- ═══ SERVICES ═══
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Mouse = plr:GetMouse()

-- ═══ THEME ═══
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

-- ═══ STATE ═══
local state = {
	flyEnabled = false, flySpeed = 100,
	clickCooldown = 0.1, autoClick = false,
	killAura = false, auraRange = 20, auraCooldown = 0.15,
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

-- ═══ HELPERS ═══
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

local function protectGui(g)
	pcall(function()
		if gethui then
			g.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(g)
			g.Parent = game:GetService("CoreGui")
		else
			g.Parent = game:GetService("CoreGui")
		end
	end)
end

-- ═══ GUI ═══
pcall(function()
	local o1 = game:GetService("CoreGui"):FindFirstChild("NexusPanel")
	if o1 then o1:Destroy() end
	local o2 = plr.PlayerGui:FindFirstChild("NexusPanel")
	if o2 then o2:Destroy() end
end)

local gui = new("ScreenGui", {
	Name = "NexusPanel",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
protectGui(gui)

-- ═══ WINDOW ═══
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

-- Drag
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, input.Position, win.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
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

-- ═══ TABS ═══
local pages = {}
local tabs = {}

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
		Elasticity = 0.3,
	}, content)
	pages[id] = page
	return page
end

-- ═══ COMPONENTS ═══
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			upd(input.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			upd(input.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
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

-- ═══ COMBAT ═══
local p1 = makePage("Combat"); setCur(p1)

sectionTitle(p1, "FAST CLICK")
local autoClickTgl = toggle(p1, "Автоклик", false, function(v) state.autoClick = v end)
slider(p1, "Задержка клика", 0.01, 1.0, 0.1, "s", function(v) state.clickCooldown = v end)

sectionTitle(p1, "KILL AURA")
toggle(p1, "Включить Kill Aura", false, function(v) state.killAura = v end)
slider(p1, "Радиус", 5, 100, 20, "", function(v) state.auraRange = v end)
slider(p1, "Скорость удара", 0.05, 1.0, 0.15, "s", function(v) state.auraCooldown = v end)
p1.CanvasSize = UDim2.new(0, 0, 0, cursor[p1] + 20)

-- ═══ MOVEMENT ═══
local p2 = makePage("Movement"); setCur(p2)

sectionTitle(p2, "FLIGHT")
toggle(p2, "Полёт", false, function(v)
	state.flyEnabled = v
	if v then
		local c = plr.Character
		if c then setupFly(c) end
	else
		stopFly()
	end
end)
slider(p2, "Скорость полёта", 10, 500, 100, "", function(v) state.flySpeed = v end)

sectionTitle(p2, "NOCLIP")
toggle(p2, "Noclip (проход сквозь стены)", false, function(v) state.noclip = v end)
p2.CanvasSize = UDim2.new(0, 0, 0, cursor[p2] + 20)

-- ═══ ESP ═══
local p3 = makePage("ESP"); setCur(p3)

sectionTitle(p3, "GENERAL")
toggle(p3, "ESP включен", false, function(v) state.espEnabled = v end)
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

-- ═══ SETTINGS ═══
local p4 = makePage("Settings"); setCur(p4)

sectionTitle(p4, "INFO")
local infoFrame = new("Frame", {
	Size = UDim2.new(1, -24, 0, 170),
	Position = UDim2.new(0, 12, 0, getY(p4, 174) + 4),
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

-- ═══ TABS INIT ═══
makeTabButton("Combat",   "⚔  Combat",   10).MouseButton1Click:Connect(function() switchTab("Combat") end)
makeTabButton("Movement", "✈  Movement", 46).MouseButton1Click:Connect(function() switchTab("Movement") end)
makeTabButton("ESP",      "◉  ESP",      82).MouseButton1Click:Connect(function() switchTab("ESP") end)
makeTabButton("Settings", "⚙  Settings", 118).MouseButton1Click:Connect(function() switchTab("Settings") end)

switchTab("Combat")

-- ═══ FLY ═══
local flyBody, flyGyro, flyHRP

function setupFly(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end
	flyHRP = hrp
	if flyBody then flyBody:Destroy() end
	if flyGyro then flyGyro:Destroy() end
	flyBody = new("BodyGyro", { MaxTorque = Vector3.new(9e9,9e9,9e9), P = 1000, Parent = hrp })
	flyGyro = new("BodyVelocity", { MaxForce = Vector3.new(9e9,9e9,9e9), Velocity = Vector3.zero, Parent = hrp })
end

function stopFly()
	if flyBody then flyBody:Destroy(); flyBody = nil end
	if flyGyro then flyGyro:Destroy(); flyGyro = nil end
	flyHRP = nil
	state.flyEnabled = false
end

RunService.RenderStepped:Connect(function()
	if not state.flyEnabled or not flyHRP or not flyHRP.Parent then return end

	local camCF = cam.CFrame
	local dir = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

	if dir.Magnitude > 0 then
		dir = dir.Unit * state.flySpeed
	end

	flyGyro.Velocity = dir
	flyBody.CFrame = camCF
	flyHRP.Velocity = Vector3.zero
end)

-- ═══ AUTOCLICK ═══
local lastClick = 0
RunService.Heartbeat:Connect(function()
	if not state.autoClick then return end
	local now = tick()
	if now - lastClick < state.clickCooldown then return end
	lastClick = now

	local c = plr.Character
	if not c then return end
	local tool = c:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end)

-- ═══ KILL AURA ═══
local lastAura = 0
RunService.Heartbeat:Connect(function()
	if not state.killAura then return end
	local now = tick()
	if now - lastAura < state.auraCooldown then return end
	lastAura = now

	local c = plr.Character
	if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local tool = c:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= plr and other.Character then
			local oHrp = other.Character:FindFirstChild("HumanoidRootPart")
			local oHum = other.Character:FindFirstChildOfClass("Humanoid")
			if oHrp and oHum and oHum.Health > 0 then
				if (hrp.Position - oHrp.Position).Magnitude <= state.auraRange then
					pcall(function()
						local exp = Instance.new("Explosion")
						exp.BlastRadius = 0
						exp.BlastPressure = 0
						exp.Position = oHrp.Position
						exp.Parent = workspace
						Debris:AddItem(exp, 0.1)
					end)
				end
			end
		end
	end
end)

-- ═══ NOCLIP ═══
local noclipParts = {}
local noclipConns = {}

local function setupNoclipCache(char)
	for _, c in ipairs(noclipConns) do c:Disconnect() end
	table.clear(noclipConns)
	table.clear(noclipParts)

	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then noclipParts[#noclipParts + 1] = p end
	end

	local conn = char.DescendantAdded:Connect(function(p)
		if p:IsA("BasePart") and state.noclip then p.CanCollide = false end
	end)
	noclipConns[#noclipConns + 1] = conn
end

RunService.Stepped:Connect(function()
	if not state.noclip then return end
	for i = 1, #noclipParts do
		local p = noclipParts[i]
		if p.Parent and p.CanCollide then p.CanCollide = false end
	end
end)

local function onChar(char) setupNoclipCache(char) end
if plr.Character then onChar(plr.Character) end
plr.CharacterAdded:Connect(onChar)

-- ═══ ESP (Drawing API) ═══
local espData = {}
local espUpdateAccum = 0
local ESP_UPDATE_RATE = 0.05

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

local function mkDraw(cls, props)
	local d = Drawing.new(cls)
	for k, v in pairs(props) do d[k] = v end
	return d
end

local function createESP(p)
	if espData[p] or not hasDrawing then return end
	espData[p] = {
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
	local myTeam = plr.Team
	local camPos = cam.CFrame.Position
	local vpSize = cam.ViewportSize
	local vpCenterX = vpSize.X / 2
	local esp = state.esp

	for _, p in ipairs(Players:GetPlayers()) do
		if p == plr and not esp.showSelf then
			if espData[p] then hideAll(espData[p]) end
			continue
		end

		local d = espData[p]
		if not d then createESP(p); d = espData[p] end
		if not d then continue end

		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		local head = c and c:FindFirstChild("Head")
		local hum = c and c:FindFirstChildOfClass("Humanoid")

		if not (hrp and head and hum and hum.Health > 0) then
			hideAll(d); continue
		end
		if esp.showTeamCheck and myTeam and p.Team == myTeam then
			hideAll(d); continue
		end

		local hrpPos = hrp.Position
		local dx, dy, dz = camPos.X - hrpPos.X, camPos.Y - hrpPos.Y, camPos.Z - hrpPos.Z
		local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
		if dist > esp.maxDistance then hideAll(d); continue end

		local hPos, hOn = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
		local rPos, rOn = cam:WorldToViewportPoint(hrpPos)
		if not hOn and not rOn then hideAll(d); continue end

		local boxH = math.abs(hPos.Y - rPos.Y) * 1.6
		local boxW = boxH * 0.55
		local boxX = hPos.X - boxW * 0.5
		local boxY = hPos.Y - boxH * 0.5 + boxH * 0.1

		local alpha = 1
		if esp.fadeWithDistance then
			alpha = 1 - (dist / esp.maxDistance) * 0.7
			if alpha < 0.3 then alpha = 0.3 end
		end

		local boxCol = esp.boxColor
		if esp.teamColor and p.Team then boxCol = p.Team.TeamColor.Color end

		if esp.boxEnabled and esp.boxStyle == "Коробка" then
			d.box.Visible = true
			d.box.Size = Vector2.new(boxW, boxH)
			d.box.Position = Vector2.new(boxX, boxY)
			d.box.Color = boxCol
			d.box.Thickness = esp.boxThickness
			d.box.Transparency = alpha
			if esp.fillBox then
				d.boxFill.Visible = true
				d.boxFill.Size = Vector2.new(boxW, boxH)
				d.boxFill.Position = Vector2.new(boxX, boxY)
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

		if esp.boxEnabled and esp.boxStyle == "Уголки" then
			local cl = math.min(boxW, boxH) * 0.25
			local x1, y1, x2, y2 = boxX, boxY, boxX + boxW, boxY + boxH
			local L = d.corners
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
				l.Visible = true; l.Color = boxCol; l.Thickness = esp.boxThickness; l.Transparency = alpha
			end
			d.box.Visible = false
		elseif esp.boxStyle ~= "Уголки" then
			for i = 1, 8 do d.corners[i].Visible = false end
		end

		if esp.nameEnabled then
			d.name.Visible = true
			d.name.Text = p.Name
			d.name.Position = Vector2.new(boxX + boxW * 0.5, boxY - 18)
			d.name.Size = esp.textSize
			d.name.Color = esp.nameColor
			d.name.Transparency = alpha
		else d.name.Visible = false end

		if esp.distanceEnabled then
			d.distance.Visible = true
			d.distance.Text = "[" .. math.floor(dist) .. "]"
			d.distance.Position = Vector2.new(boxX + boxW * 0.5, boxY + boxH + 4)
			d.distance.Size = esp.textSize - 1
			d.distance.Color = esp.distanceColor
			d.distance.Transparency = alpha
		else d.distance.Visible = false end

		if esp.healthEnabled then
			local hp = hum.Health / hum.MaxHealth
			local bw, bh = 3, boxH
			local bx, by
			if esp.healthBarSide == "Слева" then bx, by = boxX - 8, boxY
			elseif esp.healthBarSide == "Справа" then bx, by = boxX + boxW + 5, boxY
			else bw, bh = boxW, 3; bx, by = boxX, boxY - 6 end

			d.healthBarBg.Visible = true
			d.healthBarBg.Size = Vector2.new(bw, bh)
			d.healthBarBg.Position = Vector2.new(bx, by)
			d.healthBarBg.Transparency = alpha * 0.5

			d.healthBar.Visible = true
			if esp.healthBarSide == "Под именем" then
				d.healthBar.Size = Vector2.new(bw * hp, bh)
				d.healthBar.Position = Vector2.new(bx, by)
			else
				d.healthBar.Size = Vector2.new(bw, bh * hp)
				d.healthBar.Position = Vector2.new(bx, by + bh * (1 - hp))
			end
			d.healthBar.Color = esp.healthColor
			d.healthBar.Transparency = alpha
		else
			d.healthBar.Visible = false
			d.healthBarBg.Visible = false
		end

		if esp.tracerEnabled then
			d.tracer.Visible = true
			if esp.tracerFromBottom then
				d.tracer.From = Vector2.new(vpCenterX, vpSize.Y)
			else
				d.tracer.From = Vector2.new(vpCenterX, 0)
			end
			d.tracer.To = Vector2.new(boxX + boxW * 0.5, boxY + boxH)
			d.tracer.Color = esp.tracerColor
			d.tracer.Transparency = alpha
		else d.tracer.Visible = false end

		if esp.headDotEnabled then
			d.headDot.Visible = true
			d.headDot.Position = Vector2.new(hPos.X, hPos.Y)
			d.headDot.Radius = 4
			d.headDot.Color = esp.headDotColor
			d.headDot.Transparency = alpha
		else d.headDot.Visible = false end
	end
end

Players.PlayerRemoving:Connect(cleanup)

RunService.Heartbeat:Connect(function(dt)
	if not state.espEnabled then return end
	espUpdateAccum = espUpdateAccum + dt
	if espUpdateAccum < ESP_UPDATE_RATE then return end
	espUpdateAccum = 0
	pcall(updateESP)
end)

-- ═══ STATS ═══
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
		pcall(function() ping = math.floor(pingStat:GetValue()) end)
		local pingIcon = ping <= 60 and "🟢" or (ping <= 150 and "🟡" or "🔴")
		headerStats.Text = string.format("%s %d ms  |  %d fps", pingIcon, ping, fps)

		local mem = math.floor(Stats:GetTotalMemoryUsageMb())
		memoryText.Text = "mem " .. mem .. " MB"
		memoryText.TextColor3 = mem <= 800 and T.green or (mem <= 1500 and T.yellow or T.red)
	end
end)

-- ═══ HOTKEYS ═══
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local k = input.KeyCode

	if k == Enum.KeyCode.F then
		state.flyEnabled = not state.flyEnabled
		if state.flyEnabled then
			local c = plr.Character
			if c then setupFly(c) end
		else
			stopFly()
		end
	elseif k == Enum.KeyCode.G then
		state.autoClick = not state.autoClick
		autoClickTgl.set(state.autoClick)
	elseif k == Enum.KeyCode.V then
		state.killAura = not state.killAura
	elseif k == Enum.KeyCode.N then
		state.noclip = not state.noclip
	elseif k == Enum.KeyCode.E then
		state.espEnabled = not state.espEnabled
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

-- ═══ CLOSE ═══
closeBtn.MouseButton1Click:Connect(function()
	tw(win, { Position = UDim2.new(0, 40, 0.5, 800) })
	task.wait(0.15)
	win.Visible = false
end)
closeBtn.MouseEnter:Connect(function() tw(closeBtn, { TextColor3 = T.red }) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, { TextColor3 = T.textDim }) end)

-- ═══ RESPAWN ═══
plr.CharacterAdded:Connect(function()
	state.flyEnabled = false
	stopFly()
end)

print("⚡ NEXUS v1.0 (Universal) загружен")