local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local Stats        = game:GetService("Stats")
local TeleportSvc  = game:GetService("TeleportService")
local HttpService  = game:GetService("HttpService")
local VirtualUser  = game:GetService("VirtualUser")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse  = LP:GetMouse()

local T = {
	Bg = Color3.fromRGB(11,11,16), Bg2 = Color3.fromRGB(18,18,26),
	Panel = Color3.fromRGB(23,23,33), Hover = Color3.fromRGB(32,32,46),
	Stroke = Color3.fromRGB(44,44,62), Text = Color3.fromRGB(238,238,248),
	Sub = Color3.fromRGB(132,132,160), Accent = Color3.fromRGB(155,112,255),
	Accent2 = Color3.fromRGB(90,200,255), Good = Color3.fromRGB(92,222,152),
	Bad = Color3.fromRGB(255,92,112),
}

local function new(c, p, parent)
	local i = Instance.new(c)
	for k, v in pairs(p or {}) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end
local function corner(i, r) new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, i) end

if game:GetService("CoreGui"):FindFirstChild("AetherUI") then
	game:GetService("CoreGui").AetherUI:Destroy()
end

local gui = new("ScreenGui", {
	Name = "AetherUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local okP = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not okP or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- WINDOW
local main = new("Frame", {
	Size = UDim2.fromOffset(548, 372), Position = UDim2.new(0.5,0,0.5,0),
	AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = T.Bg,
	BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
corner(main, 14)
new("UIStroke", {Color = T.Stroke, Thickness = 1}, main)
new("UIGradient", {Color = ColorSequence.new(T.Bg2, T.Bg), Rotation = 90}, main)

local glow = new("Frame", {Size = UDim2.new(1,0,0,2), BackgroundColor3 = T.Accent, BorderSizePixel = 0}, main)
new("UIGradient", {Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, T.Accent),
	ColorSequenceKeypoint.new(0.5, T.Accent2),
	ColorSequenceKeypoint.new(1, T.Accent),
})}, glow)

local header = new("Frame", {Size = UDim2.new(1,0,0,52), BackgroundTransparency = 1}, main)

new("TextLabel", {
	Size = UDim2.new(0,200,0,20), Position = UDim2.new(0,18,0,12),
	BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = "AETHER",
	TextSize = 20, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
new("TextLabel", {
	Size = UDim2.new(0,240,0,14), Position = UDim2.new(0,18,0,32),
	BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
	Text = "v1.0  ·  by TRJacob", TextSize = 11, TextColor3 = T.Sub,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local function headerBtn(px, glyph, col, click)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(24,24), Position = UDim2.new(1,px,0,14),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0, Font = Enum.Font.GothamBold,
		Text = glyph, TextSize = 13, TextColor3 = col, AutoButtonColor = false,
	}, header)
	corner(b, 7)
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel}):Play() end)
	b.MouseButton1Click:Connect(click)
end
headerBtn(-38, "—", T.Sub, function() main.Visible = false end)
headerBtn(-70, "✕", T.Bad, function() gui:Destroy() end)

-- DRAG
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, i.Position, main.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- RAIL / CONTENT
local rail = new("Frame", {
	Size = UDim2.new(0,130,1,-66), Position = UDim2.new(0,10,0,56),
	BackgroundColor3 = T.Bg2, BorderSizePixel = 0,
}, main)
corner(rail, 10)
new("UIListLayout", {Padding = UDim.new(0,3), SortOrder = Enum.SortOrder.LayoutOrder}, rail)
new("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,7), PaddingRight = UDim.new(0,7)}, rail)

local content = new("Frame", {
	Size = UDim2.new(1,-152,1,-66), Position = UDim2.new(0,148,0,56),
	BackgroundTransparency = 1,
}, main)

local pages, tabButtons, activePage = {}, {}, nil

local function addTab(name, glyph)
	local btn = new("TextButton", {
		Size = UDim2.new(1,0,0,30), BackgroundColor3 = T.Panel, BackgroundTransparency = 1,
		BorderSizePixel = 0, Font = Enum.Font.GothamMedium, Text = "  "..glyph.."   "..name,
		TextSize = 12, TextColor3 = T.Sub, TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
	}, rail)
	corner(btn, 8)

	local page = new("ScrollingFrame", {
		Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, ScrollBarImageColor3 = T.Stroke,
		CanvasSize = UDim2.new(0,0,0,0), Visible = false,
	}, content)
	local lay = new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	new("UIPadding", {PaddingRight = UDim.new(0,6), PaddingBottom = UDim.new(0,12)}, page)
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 20)
	end)

	pages[name] = page
	table.insert(tabButtons, btn)

	btn.MouseEnter:Connect(function()
		if activePage ~= page then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, TextColor3 = T.Text}):Play() end
	end)
	btn.MouseLeave:Connect(function()
		if activePage ~= page then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextColor3 = T.Sub}):Play() end
	end)
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		for _, b in pairs(tabButtons) do
			TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextColor3 = T.Sub}):Play()
		end
		page.Visible = true
		activePage = page
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0, TextColor3 = T.Accent}):Play()
	end)
	return page
end

local function section(page, text)
	new("TextLabel", {
		Size = UDim2.new(1,-4,0,22), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
		Text = string.upper(text), TextSize = 10, TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, page)
end

local function addLabel(page, text, col, h)
	local l = new("TextLabel", {
		Size = UDim2.new(1,-4,0,h or 30), BackgroundTransparency = 1,
		Font = Enum.Font.Gotham, Text = text, TextSize = 11, TextColor3 = col or T.Sub,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}, page)
	return l
end

local function addToggle(page, text, default, callback)
	local on = default or false
	local row = new("TextButton", {
		Size = UDim2.new(1,-4,0,36), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		AutoButtonColor = false, Text = "",
	}, page)
	corner(row, 8)
	new("UIStroke", {Color = T.Stroke, Thickness = 1}, row)
	new("TextLabel", {
		Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, Text = text, TextSize = 12, TextColor3 = T.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local pill = new("Frame", {
		Size = UDim2.fromOffset(34,18), Position = UDim2.new(1,-46,0.5,-9),
		BackgroundColor3 = T.Bg2, BorderSizePixel = 0,
	}, row)
	corner(pill, 9)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(12,12), Position = UDim2.new(0,3,0.5,-6),
		BackgroundColor3 = T.Sub, BorderSizePixel = 0,
	}, pill)
	corner(knob, 6)

	local function set(v)
		on = v
		TweenService:Create(knob, TweenInfo.new(0.16), {
			Position = on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
			BackgroundColor3 = on and T.Accent or T.Sub,
		}):Play()
		TweenService:Create(pill, TweenInfo.new(0.16), {BackgroundColor3 = on and T.Accent:Darker(0.55) or T.Bg2}):Play()
		if callback then pcall(callback, on) end
	end

	row.MouseButton1Click:Connect(function() set(not on) end)
	row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play() end)
	row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel}):Play() end)
	if on then set(true) end
	return set
end

local function addSlider(page, text, min, max, default, callback)
	local row = new("Frame", {
		Size = UDim2.new(1,-4,0,46), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	}, page)
	corner(row, 8)
	new("UIStroke", {Color = T.Stroke, Thickness = 1}, row)
	new("TextLabel", {
		Size = UDim2.new(1,-90,0,18), Position = UDim2.new(0,12,0,6), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, Text = text, TextSize = 12, TextColor3 = T.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local val = new("TextLabel", {
		Size = UDim2.new(0,62,0,18), Position = UDim2.new(1,-74,0,6), BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold, Text = tostring(default), TextSize = 12,
		TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right,
	}, row)
	local track = new("Frame", {
		Size = UDim2.new(1,-24,0,4), Position = UDim2.new(0,12,0,32),
		BackgroundColor3 = T.Bg, BorderSizePixel = 0,
	}, row)
	corner(track, 2)
	local fill = new("Frame", {
		Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 2)

	local function set(v)
		v = math.clamp(v, min, max)
		fill.Size = UDim2.new((v-min)/(max-min),0,1,0)
		val.Text = tostring(math.floor(v*10+0.5)/10)
		if callback then pcall(callback, v) end
	end

	local held = false
	local function upd(x)
		local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
		set(min + rel*(max-min))
	end
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			held = true; upd(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if held and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			upd(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then held = false end
	end)
	if callback then pcall(callback, default) end
	return set
end

local function addButton(page, text, col, callback)
	local b = new("TextButton", {
		Size = UDim2.new(1,-4,0,32), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = text,
		TextSize = 11, TextColor3 = col or T.Text,
	}, page)
	corner(b, 8)
	new("UIStroke", {Color = T.Stroke, Thickness = 1}, b)
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel}):Play() end)
	b.MouseButton1Click:Connect(function() pcall(callback) end)
	return b
end

-- NOTIFICATIONS
local nHolder = new("Frame", {
	Size = UDim2.new(0,240,0,300), Position = UDim2.new(1,-18,0,18),
	AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1,
}, gui)
new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, nHolder)

local function notify(title, body)
	local card = new("Frame", {
		Size = UDim2.new(1,0,0,46), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, nHolder)
	corner(card, 8)
	new("UIStroke", {Color = T.Accent, Thickness = 1, Transparency = 0.5}, card)
	new("Frame", {Size = UDim2.new(0,3,1,-16), Position = UDim2.new(0,8,0,8), BackgroundColor3 = T.Accent, BorderSizePixel = 0}, card)
	new("TextLabel", {
		Size = UDim2.new(1,-28,0,16), Position = UDim2.new(0,18,0,7), BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold, Text = title, TextSize = 11, TextColor3 = T.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	new("TextLabel", {
		Size = UDim2.new(1,-28,0,14), Position = UDim2.new(0,18,0,23), BackgroundTransparency = 1,
		Font = Enum.Font.Gotham, Text = body, TextSize = 10, TextColor3 = T.Sub,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	task.delay(3, function()
		if card.Parent then
			TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
			task.wait(0.28); card:Destroy()
		end
	end)
end

-- WATERMARK
local wm = new("Frame", {
	Size = UDim2.fromOffset(178,26), Position = UDim2.new(0,16,0,16),
	BackgroundColor3 = T.Bg2, BorderSizePixel = 0,
}, gui)
corner(wm, 7)
new("UIStroke", {Color = T.Stroke, Thickness = 1}, wm)
local wmText = new("TextLabel", {
	Size = UDim2.new(1,-14,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold, Text = "AETHER  ·  0 FPS  ·  0ms", TextSize = 10,
	TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Left,
}, wm)

-- STATE
local State = {
	Speed = 16, Jump = 50, God = false, ESP = false, Names = false,
	ClickTP = false, FlingTouch = false, Fullbright = false,
}

local function getChar() return LP.Character end
local function getHRP()
	local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function reapply()
	local h = getHum()
	if h then
		h.WalkSpeed = State.Speed
		h.UseJumpPower = true
		h.JumpPower = State.Jump
		if State.God then h.MaxHealth = math.huge; h.Health = math.huge end
	end
end

local refreshEsp
LP.CharacterAdded:Connect(function()
	task.wait(0.7); reapply()
	if State.ESP and refreshEsp then refreshEsp() end
	if State.FlingTouch and getHRP() then
		getHRP().Touched:Connect(function() end)
	end
end)

-- MOVEMENT MODULES
local flyBV, flyConn, FlySpeed = nil, nil, 60

local function setFly(on)
	if not on then
		if flyConn then flyConn:Disconnect(); flyConn = nil end
		if flyBV then flyBV:Destroy(); flyBV = nil end
		local h = getHum(); if h then h.PlatformStand = false end
		return
	end
	local hrp, h = getHRP(), getHum()
	if not hrp or not h then return end
	h.PlatformStand = true
	flyBV = new("BodyVelocity", {MaxForce = Vector3.new(1e5,1e5,1e5), Velocity = Vector3.zero, P = 2500, Parent = hrp})
	flyConn = RunService.RenderStepped:Connect(function()
		if not hrp.Parent or not flyBV.Parent then return end
		local d = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then d += Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then d -= Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then d -= Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then d += Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
		flyBV.Velocity = d.Magnitude > 0 and d.Unit * FlySpeed or Vector3.zero
	end)
end

local fBP, fBV, fConn, fAnchor = nil, nil, nil, nil
local function setFloat(on)
	if not on then
		if fConn then fConn:Disconnect(); fConn = nil end
		if fBP then fBP:Destroy(); fBP = nil end
		if fBV then fBV:Destroy(); fBV = nil end
		local h = getHum(); if h then h.PlatformStand = false end
		return
	end
	local hrp, h = getHRP(), getHum()
	if not hrp or not h then return end
	h.PlatformStand = true
	fAnchor = hrp.Position
	fBP = new("BodyPosition", {MaxForce = Vector3.new(1e5,1e5,1e5), P = 8000, D = 900, Position = fAnchor, Parent = hrp})
	fBV = new("BodyVelocity", {MaxForce = Vector3.new(1e5,1e5,1e5), Velocity = Vector3.zero, P = 2500, Parent = hrp})
	fConn = RunService.RenderStepped:Connect(function()
		if not hrp.Parent then return end
		local d = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then d += Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then d -= Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then d -= Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then d += Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then fAnchor += Vector3.new(0,0.5,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then fAnchor -= Vector3.new(0,0.5,0) end
		fAnchor += d * 0.6
		fBP.Position = fAnchor
		fBV.Velocity = d.Magnitude > 0 and d.Unit * 22 or Vector3.zero
	end)
end

local noclipConn
local function setNoclip(on)
	if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
	if not on then
		local c = getChar()
		if c then
			for _, p in pairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = true end
			end
		end
		return
	end
	noclipConn = RunService.Stepped:Connect(function()
		local c = getChar(); if not c then return end
		for _, p in pairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
		end
	end)
end

local infJumpConn
local function setInfJump(on)
	if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
	if not on then return end
	infJumpConn = UIS.JumpRequest:Connect(function()
		local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end

local function flingTarget(hrp)
	if not hrp then return end
	hrp.AssemblyAngularVelocity = Vector3.new(math.random(-70000,70000), math.random(-70000,70000), math.random(-70000,70000))
	hrp.AssemblyLinearVelocity = Vector3.zero
end

local function flingAll()
	local n = 0
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP then
			local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then flingTarget(hrp); n += 1 end
		end
	end
	notify("Fling All", n.." player(s) flung")
end

local flingConn
local function setFlingTouch(on)
	if flingConn then flingConn:Disconnect(); flingConn = nil end
	if not on then return end
	local hrp = getHRP(); if not hrp then return end
	flingConn = hrp.Touched:Connect(function(hit)
		local other = hit.Parent and hit.Parent:FindFirstChild("HumanoidRootPart")
		if other and other ~= hrp then flingTarget(other) end
	end)
end

local freezeConn
local function setFreezeAll(on)
	if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
	if not on then
		for _, p in pairs(Players:GetPlayers()) do
			local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then pcall(function() hrp.Anchored = false end) end
		end
		return
	end
	freezeConn = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LP then
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then pcall(function() hrp.Anchored = true end) end
			end
		end
	end)
end

-- KILL AURA
local auraConn
local function setAura(on)
	if auraConn then auraConn:Disconnect(); auraConn = nil end
	if not on then return end
	auraConn = RunService.Heartbeat:Connect(function()
		if not firetouchinterest then return end
		local hrp = getHRP(); if not hrp then return end
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LP then
				local thrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if thrp and (thrp.Position - hrp.Position).Magnitude < 10 then
					for _, part in pairs(thrp.Parent:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function()
								firetouchinterest(hrp, part, 0)
								firetouchinterest(hrp, part, 1)
							end)
						end
					end
				end
			end
		end
	end)
end

-- ESP
local espFolder = new("Folder", {Name = "AetherESP"}, gui)
local espData = {}

refreshEsp = function()
	for _, d in pairs(espData) do
		if d.hl then d.hl:Destroy() end
		if d.bb then d.bb:Destroy() end
	end
	espData = {}
	if not State.ESP then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP then
			local char = p.Character
			local head = char and char:FindFirstChild("Head")
			if char and head then
				local hl = new("Highlight", {
					FillColor = T.Accent, FillTransparency = 0.7, OutlineColor = T.Accent2,
					Adornee = char, Parent = espFolder,
				})
				local bb
				if State.Names then
					bb = new("BillboardGui", {
						Size = UDim2.fromOffset(120,16), StudsOffset = Vector3.new(0,2.6,0),
						AlwaysOnTop = true, Adornee = head, Parent = espFolder,
					})
					new("TextLabel", {
						Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold, Text = p.Name, TextSize = 11,
						TextColor3 = T.Accent2, TextStrokeTransparency = 0.4,
					}, bb)
				end
				espData[p] = {hl = hl, bb = bb}
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(p)
	local d = espData[p]
	if d then
		if d.hl then d.hl:Destroy() end
		if d.bb then d.bb:Destroy() end
		espData[p] = nil
	end
end)
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.9)
		if State.ESP then refreshEsp() end
	end)
end)

local fbStore = {}
local function setFullbright(on)
	if on then
		fbStore = {Lighting.Brightness, Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogEnd}
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(180,180,180)
		Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
		Lighting.FogEnd = 100000
	else
		if fbStore[1] then
			Lighting.Brightness = fbStore[1]
			Lighting.ClockTime = fbStore[2]
			Lighting.Ambient = fbStore[3]
			Lighting.OutdoorAmbient = fbStore[4]
			Lighting.FogEnd = fbStore[5]
		end
	end
end

-- MISC MODULES
local antiAfk = false
LP.Idled:Connect(function()
	if antiAfk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

local function teleportTo(plr)
	local hrp = getHRP()
	local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if hrp and t then hrp.CFrame = t.CFrame * CFrame.new(0,3,0) end
end

UIS.InputBegan:Connect(function(i, gp)
	if State.ClickTP and not gp and i.UserInputType == Enum.UserInputType.MouseButton1 then
		local hrp = getHRP()
		if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end
	end
end)

--=====================================================================
-- PAGES
--=====================================================================
local home = addTab("Home", "◈")
local move = addTab("Movement", "✦")
local combat = addTab("Combat", "✧")
local tp = addTab("Teleport", "➤")
local vis = addTab("Visuals", "◉")
local misc = addTab("Misc", "⚙")

-- HOME
section(home, "Welcome")
addLabel(home, "Aether v1.0 by TRJacob\nModern all-in-one utility menu. RightShift hides the window.", T.Sub, 34)
section(home, "Quick Access")
addToggle(home, "Fly", false, setFly)
addToggle(home, "Noclip", false, setNoclip)
addSlider(home, "Walk Speed", 8, 250, 16, function(v)
	State.Speed = v
	local h = getHum(); if h then h.WalkSpeed = v end
end)
section(home, "Session")
addButton(home, "Reset Character", T.Text, function()
	local h = getHum(); if h then h.Health = 0 end
end)
addButton(home, "Rejoin Server", T.Text, function()
	TeleportSvc:Teleport(game.PlaceId, LP)
end)
addButton(home, "Unload Aether", T.Bad, function()
	gui:Destroy()
end)

-- MOVEMENT
section(move, "Flight")
addToggle(move, "Fly", false, setFly)
addSlider(move, "Fly Speed", 10, 300, 60, function(v) FlySpeed = v end)
addToggle(move, "Float / Hover", false, setFloat)
section(move, "Ground")
addSlider(move, "Walk Speed", 8, 250, 16, function(v)
	State.Speed = v
	local h = getHum(); if h then h.WalkSpeed = v end
end)
addSlider(move, "Jump Power", 30, 300, 50, function(v)
	State.Jump = v
	local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = v end
end)
addToggle(move, "Infinite Jump", false, setInfJump)
addToggle(move, "Noclip", false, setNoclip)
section(move, "Physics")
addSlider(move, "Gravity", 0, 300, workspace.Gravity, function(v) workspace.Gravity = v end)
addButton(move, "Reset Gravity", T.Text, function() workspace.Gravity = 196.2 end)

-- COMBAT
section(combat, "Fling")
addToggle(combat, "Fling on Touch", false, setFlingTouch)
addButton(combat, "Fling All Players", T.Accent2, flingAll)
section(combat, "Control")
addToggle(combat, "Freeze All Players", false, setFreezeAll)
addToggle(combat, "Kill Aura (Touch)", false, setAura)
addToggle(combat, "Godmode", false, function(on)
	State.God = on
	local h = getHum()
	if h then
		if on then h.MaxHealth = math.huge; h.Health = math.huge
		else h.MaxHealth = 100; h.Health = 100 end
	end
end)

-- TELEPORT
section(tp, "Cursor")
addToggle(tp, "Click Teleport", false, function(on) State.ClickTP = on end)
addButton(tp, "Teleport To Mouse", T.Text, function()
	local hrp = getHRP()
	if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end
end)
addButton(tp, "Teleport To Spawn", T.Text, function()
	local hrp = getHRP()
	if hrp then hrp.CFrame = CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0,4,0)) end
end)
section(tp, "Players")

local listHolder = new("ScrollingFrame", {
	Size = UDim2.new(1,-4,0,150), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,0),
}, tp)
corner(listHolder, 8)
new("UIListLayout", {Padding = UDim.new(0,3), SortOrder = Enum.SortOrder.LayoutOrder}, listHolder)
new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}, listHolder)

local function rebuildList()
	for _, c in pairs(listHolder:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP then
			local b = new("TextButton", {
				Size = UDim2.new(1,0,0,26), BackgroundColor3 = T.Bg2, BorderSizePixel = 0,
				AutoButtonColor = false, Font = Enum.Font.GothamMedium, Text = p.Name,
				TextSize = 11, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
			}, listHolder)
			corner(b, 6)
			new("UIPadding", {PaddingLeft = UDim.new(0,8)}, b)
			b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.Hover}):Play() end)
			b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.Bg2}):Play() end)
			b.MouseButton1Click:Connect(function() teleportTo(p) end)
		end
	end
	listHolder.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 29 + 12)
end
rebuildList()
Players.PlayerAdded:Connect(function() task.wait(0.5); rebuildList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); rebuildList() end)

-- VISUALS
section(vis, "Players")
addToggle(vis, "Player ESP", false, function(on) State.ESP = on; refreshEsp() end)
addToggle(vis, "Player Names", false, function(on) State.Names = on; refreshEsp() end)
section(vis, "World")
addToggle(vis, "Fullbright", false, setFullbright)
addSlider(vis, "Time of Day", 0, 24, 14, function(v) Lighting.ClockTime = v end)
addSlider(vis, "Field of View", 40, 120, 70, function(v) Camera.FieldOfView = v end)

-- MISC
section(misc, "Utility")
addToggle(misc, "Anti AFK", false, function(on) antiAfk = on end)
addButton(misc, "Rejoin Server", T.Text, function()
	TeleportSvc:Teleport(game.PlaceId, LP)
end)
addButton(misc, "Server Hop", T.Text, function()
	local ok, res = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(
			("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)))
	end)
	if ok and res and res.data and #res.data > 0 then
		local pick = res.data[math.random(1,#res.data)]
		if pick and pick.id then TeleportSvc:TeleportToPlaceInstance(game.PlaceId, pick.id, LP) end
	else
		notify("Server Hop", "No servers found")
	end
end)
addButton(misc, "Copy Job ID", T.Text, function()
	if setclipboard then setclipboard(game.JobId); notify("Copied", "Job ID copied") end
end)
section(misc, "Interface")
addButton(misc, "Hide Window (RightShift)", T.Text, function() main.Visible = false end)
addButton(misc, "Unload Aether", T.Bad, function() gui:Destroy() end)

--=====================================================================
-- BOOT
--=====================================================================
pages["Home"].Visible = true
activePage = pages["Home"]
TweenService:Create(tabButtons[1], TweenInfo.new(0.15), {BackgroundTransparency = 0, TextColor3 = T.Accent}):Play()

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

-- watermark updater
local frames = 0
task.spawn(function()
	while gui.Parent do
		frames = 0
		task.wait(1)
		local ping = "0"
		pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():gsub(" ms", "") end)
		wmText.Text = ("AETHER  ·  %d FPS  ·  %sms"):format(frames, ping)
	end
end)
RunService.RenderStepped:Connect(function()
	if gui.Parent then frames += 1 end
end)

reapply()
notify("Aether", "Loaded — press RightShift to hide")
