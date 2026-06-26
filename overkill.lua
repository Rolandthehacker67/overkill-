--[[
Roblox Official Shooter Assist - V4 ULTRA EDITION
Put in: StarterPlayer > StarterPlayerScripts > LocalScript

IMPORTANT:
This is a clean Roblox Studio LocalScript for YOUR OWN shooter game.
It does not use executor APIs, getgenv, hookmetamethod, CoreGui, Drawing, readfile/writefile, etc.

It provides official/accessibility/debug systems:
- Aim assist / target assist for your own game
- Debug ESP for your own game
- Official weapon bridge via BindableEvent/BindableFunction
- Mobile-friendly controls
- Server-safe design: server must still validate ammo, cooldown, teams, LOS, damage, distance, etc.

Created PlayerGui bridge objects:
- BindableEvent: OfficialV4UltraFireRequested
- BindableFunction: OfficialV4UltraGetCorrectedAim

Style goal:
Inspired by old-school multi-column dark UI: top tabs, 3 columns, colored sections, neon glow, patterned background.
]]

---------------------------------------------------------------------
-- Services
---------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

while not Camera do
	task.wait()
	Camera = workspace.CurrentCamera
end

---------------------------------------------------------------------
-- Official weapon bridge
---------------------------------------------------------------------

local FireRequested = PlayerGui:FindFirstChild("OfficialV4UltraFireRequested")
if not FireRequested then
	FireRequested = Instance.new("BindableEvent")
	FireRequested.Name = "OfficialV4UltraFireRequested"
	FireRequested.Parent = PlayerGui
end

local CorrectedAim = PlayerGui:FindFirstChild("OfficialV4UltraGetCorrectedAim")
if not CorrectedAim then
	CorrectedAim = Instance.new("BindableFunction")
	CorrectedAim.Name = "OfficialV4UltraGetCorrectedAim"
	CorrectedAim.Parent = PlayerGui
end

---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------

local S = {
	-- UI
	MenuOpen = true,
	ActiveTab = "Aim",
	Accent = Color3.fromRGB(0, 170, 255),
	Accent2 = Color3.fromRGB(255, 170, 30),
	Accent3 = Color3.fromRGB(210, 45, 255),
	Background = Color3.fromRGB(18, 18, 22),
	Panel = Color3.fromRGB(28, 28, 34),
	Panel2 = Color3.fromRGB(36, 36, 44),
	Text = Color3.fromRGB(235, 235, 245),
	Muted = Color3.fromRGB(155, 160, 175),
	Glass = 0.08,
	DimTransparency = 0.38,
	Blur = true,
	BlurSize = 8,
	Pattern = true,
	AnimatedGradient = true,
	Particles = true,
	Animations = true,
	RainbowAccent = false,
	UIScaleMobile = true,
	ShowTopButton = true,
	ShowMiniStatus = true,
	ShowNotifications = true,
	OpenKey = Enum.KeyCode.RightShift,

	-- Permissions
	AdminOnly = false,
	AllowedUserIds = {},

	-- Target selection
	TargetPlayers = true,
	TargetNPCs = false,
	UseAimTargetTag = true,
	TeamCheck = true,
	AliveCheck = true,
	IgnoreSpawnProtection = true,
	SpawnProtectionAttribute = "SpawnProtected",
	AimPart = "Head",
	NPCFolders = {"NPCs", "Enemies", "Targets"},

	-- Aim core
	AimAssist = true,
	AutoAim = true,
	HoldToAim = false,
	AimInput = Enum.UserInputType.MouseButton2,
	StickyTarget = true,
	TargetLock = true,
	Prediction = true,
	VelocityPrediction = true,
	DynamicSmoothing = true,
	NearCenterBoost = true,
	Deadzone = true,
	AimRadius = 230,
	AimStrength = 0.28,
	MinAimStrength = 0.06,
	MaxAimStrength = 0.68,
	PredictionLead = 0.13,
	VerticalPrediction = 0.35,
	MaxDistance = 1500,
	MinConfidence = 0.40,
	DeadzoneRadius = 7,
	FOVPriority = 0.62,
	DistancePriority = 0.18,
	HealthPriority = 0.10,
	VisiblePriority = 0.18,
	StickyBonus = 0.22,
	PreferVisible = true,
	PreferLowHealth = false,
	PreferClosestCrosshair = true,
	PreferClosestDistance = true,

	-- Switching/walls
	LineOfSight = false,
	WallMemory = true,
	WallMemoryTime = 0.55,
	StickyTime = 1.35,
	SwitchCooldown = 0.22,
	SwitchAdvantage = 0.24,
	RequireLOSForAim = false,
	RequireLOSForFire = true,

	-- Official shooting bridge
	ShotCorrection = true,
	AutoFireRequest = false,
	FireRate = 9,
	FireConfidence = 0.72,
	OnlyFireWhenCentered = true,
	FireCenterRadius = 42,
	BurstMode = false,
	BurstShots = 3,
	BurstDelay = 0.065,
	Triggerbot = false,
	TriggerDelay = 0.045,
	ManualCorrectionOnly = false,

	-- ESP
	ESP = true,
	ESPPlayers = true,
	ESPNPCs = false,
	ESPNames = true,
	ESPDistance = true,
	ESPHealth = true,
	ESPTeam = true,
	ESPConfidence = true,
	ESPState = true,
	ESPHighlights = true,
	ESPBoxes = true,
	ESPSnaplines = true,
	ESPOffscreenArrows = true,
	ESPTargetMarker = true,
	ESPVisibleWallColors = true,
	ESPTeamColors = true,
	ESPMaxDistance = 2200,
	ESPTextSize = 13,
	ESPLineThickness = 2,
	ESPBoxThickness = 2,
	ESPUpdateRate = 1 / 30,
	ESPHealthBar = true,
	ESPNameBackground = true,
	ESPOnlyEnemies = true,

	-- Visuals
	ShowFOV = true,
	FOVRainbow = false,
	FOVFilled = true,
	FOVFillTransparency = 0.93,
	FOVThickness = 2,
	ShowCrosshair = true,
	CrosshairGap = 6,
	CrosshairLength = 9,
	CrosshairThickness = 2,
	CrosshairDot = true,
	ShowPredictionDot = true,
	ShowTargetDot = true,
	ShowAimLine = true,
	ShowLockRing = true,
	ReadyColor = Color3.fromRGB(45, 255, 170),
	WallColor = Color3.fromRGB(255, 210, 60),
	EnemyColor = Color3.fromRGB(65, 205, 255),
	TargetColor = Color3.fromRGB(255, 70, 220),

	-- Death zone / own-game arena helpers
	DeathZoneAssist = false,
	DeathZoneFolder = "DeathZones",
	DeathZoneWarning = true,
	DeathZoneESP = true,
	DeathZoneDistance = 80,
	DeathZoneColor = Color3.fromRGB(255, 70, 70),

	-- Debug
	DebugHUD = true,
	DebugPrintTarget = false,
	PrintFireRequests = false,
	ShowPerformance = true,
}

---------------------------------------------------------------------
-- Runtime state
---------------------------------------------------------------------

local State = {
	HoldingAim = false,
	Target = nil,
	TargetKind = nil,
	Part = nil,
	Character = nil,
	Humanoid = nil,
	AimPosition = nil,
	PredictedPosition = nil,
	Confidence = 0,
	LOS = false,
	Reason = "Starting",
	Distance = 0,
	ScreenDistance = math.huge,
	LastSeen = 0,
	LastLOS = 0,
	LastSwitch = 0,
	LastFire = 0,
	BurstLeft = 0,
	NextBurst = 0,
	Best = nil,
	FPS = 60,
	FrameCounter = 0,
	LastFPS = os.clock(),
	LastESPUpdate = 0,
	LastTrigger = 0,
}

local Connections = {}
local EspCache = {}
local NotificationIndex = 0

---------------------------------------------------------------------
-- Helper utilities
---------------------------------------------------------------------

local function clamp(x, a, b)
	return math.max(a, math.min(b, x))
end

local function now()
	return os.clock()
end

local function round(n, places)
	local m = 10 ^ (places or 0)
	return math.floor(n * m + 0.5) / m
end

local function addConnection(conn)
	table.insert(Connections, conn)
	return conn
end

local function isAllowed()
	if not S.AdminOnly then
		return true
	end
	for _, id in ipairs(S.AllowedUserIds) do
		if id == LocalPlayer.UserId then
			return true
		end
	end
	return false
end

local function tween(obj, info, props)
	if S.Animations then
		TweenService:Create(obj, info, props):Play()
	else
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
end

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function stroke(obj, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or S.Accent
	s.Transparency = transparency or 0.35
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

local function gradient(obj, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 0
	g.Parent = obj
	return g
end

local function clearGui(layer)
	for _, ch in ipairs(layer:GetChildren()) do
		if ch:IsA("GuiObject") then
			ch:Destroy()
		end
	end
end

local function colorForTeam(player)
	if player and player.TeamColor then
		return player.TeamColor.Color
	end
	return S.EnemyColor
end

local function currentAccent()
	if S.RainbowAccent or S.FOVRainbow then
		return Color3.fromHSV((tick() % 5) / 5, 1, 1)
	end
	return S.Accent
end

local function safeName(obj)
	return obj and obj.Name or "none"
end

---------------------------------------------------------------------
-- Permission gate
---------------------------------------------------------------------

if not isAllowed() then
	-- Console silent: blocked quietly when AdminOnly is enabled.
	return
end

---------------------------------------------------------------------
-- Target data
---------------------------------------------------------------------

local function isEnemyPlayer(player)
	if player == LocalPlayer then
		return false
	end
	if S.ESPOnlyEnemies or S.TeamCheck then
		if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
			return false
		end
	end
	return true
end

local function getAimPartFromCharacter(char)
	if not char then return nil end
	return char:FindFirstChild(S.AimPart)
		or char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char.PrimaryPart
		or char:FindFirstChildWhichIsA("BasePart")
end

local function isSpawnProtected(char)
	if not S.IgnoreSpawnProtection then
		return false
	end
	if not char then return false end
	local attr = char:GetAttribute(S.SpawnProtectionAttribute)
	if attr == true then
		return true
	end
	local ff = char:FindFirstChildOfClass("ForceField")
	return ff ~= nil
end

local function getPlayerTargetData(player)
	if not player or not player.Parent then
		return nil, "No player"
	end
	if not isEnemyPlayer(player) then
		return nil, "Friendly/self"
	end
	local char = player.Character
	if not char then
		return nil, "No character"
	end
	if isSpawnProtected(char) then
		return nil, "Spawn protected"
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if S.AliveCheck and (not hum or hum.Health <= 0) then
		return nil, "Dead"
	end
	local part = getAimPartFromCharacter(char)
	if not part or not part:IsA("BasePart") then
		return nil, "No aim part"
	end
	return {
		kind = "Player",
		object = player,
		player = player,
		character = char,
		humanoid = hum,
		part = part,
		name = player.Name,
	}, "OK"
end

local function getNPCTargetData(model)
	if not model or not model:IsA("Model") then
		return nil, "Bad NPC"
	end
	if isSpawnProtected(model) then
		return nil, "Spawn protected"
	end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if S.AliveCheck and hum and hum.Health <= 0 then
		return nil, "Dead"
	end
	local part = getAimPartFromCharacter(model)
	if not part or not part:IsA("BasePart") then
		return nil, "No aim part"
	end
	return {
		kind = "NPC",
		object = model,
		player = nil,
		character = model,
		humanoid = hum,
		part = part,
		name = model.Name,
	}, "OK"
end

local function getPartTargetData(part)
	if not part or not part:IsA("BasePart") then
		return nil, "Bad part"
	end
	return {
		kind = "Part",
		object = part,
		player = nil,
		character = part,
		humanoid = nil,
		part = part,
		name = part.Name,
	}, "OK"
end

local function collectTargets(includeForESP)
	local targets = {}

	if S.TargetPlayers or (includeForESP and S.ESPPlayers) then
		for _, p in ipairs(Players:GetPlayers()) do
			local d = getPlayerTargetData(p)
			if d then
				table.insert(targets, d)
			end
		end
	end

	if S.TargetNPCs or (includeForESP and S.ESPNPCs) then
		for _, folderName in ipairs(S.NPCFolders) do
			local folder = workspace:FindFirstChild(folderName)
			if folder then
				for _, model in ipairs(folder:GetChildren()) do
					local d = getNPCTargetData(model)
					if d then
						table.insert(targets, d)
					end
				end
			end
		end
	end

	if S.UseAimTargetTag then
		for _, obj in ipairs(CollectionService:GetTagged("AimTarget")) do
			if obj:IsA("Model") then
				local d = getNPCTargetData(obj)
				if d then table.insert(targets, d) end
			elseif obj:IsA("BasePart") then
				local d = getPartTargetData(obj)
				if d then table.insert(targets, d) end
			end
		end
	end

	return targets
end

---------------------------------------------------------------------
-- Aim math
---------------------------------------------------------------------

local function hasLineOfSight(part, character)
	if not Camera or not part then
		return false, nil
	end
	local origin = Camera.CFrame.Position
	local direction = part.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	local hit = workspace:Raycast(origin, direction, params)
	if not hit then
		return true, nil
	end
	if typeof(character) == "Instance" and hit.Instance:IsDescendantOf(character) then
		return true, hit.Instance
	end
	if hit.Instance == part then
		return true, hit.Instance
	end
	return false, hit.Instance
end

local function predictedPosition(part)
	if not S.Prediction then
		return part.Position
	end
	if not S.VelocityPrediction then
		return part.Position
	end
	local v = part.AssemblyLinearVelocity
	local adjusted = Vector3.new(v.X, v.Y * S.VerticalPrediction, v.Z)
	return part.Position + adjusted * S.PredictionLead
end

local function worldToScreen(worldPos)
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)
	local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
	local pos2 = Vector2.new(pos.X, pos.Y)
	local dist = (pos2 - center).Magnitude
	return pos, onScreen and pos.Z > 0, dist, center
end

local function candidateFromTarget(data, forESP)
	local aimPos = predictedPosition(data.part)
	local worldDist = (aimPos - Camera.CFrame.Position).Magnitude
	local maxDist = forESP and S.ESPMaxDistance or S.MaxDistance
	if worldDist > maxDist then
		return nil, "Too far"
	end

	local screen, onScreen, screenDist = worldToScreen(aimPos)
	if not forESP then
		if not onScreen then
			return nil, "Off screen"
		end
		if screenDist > S.AimRadius then
			return nil, "Outside FOV"
		end
	end

	local los = hasLineOfSight(data.part, data.character)
	if not forESP then
		if S.RequireLOSForAim and not los then
			return nil, "No LOS"
		end
		if S.LineOfSight and not los then
			local recentWallMemory = S.WallMemory and data.object == State.Target and (now() - State.LastLOS) <= S.WallMemoryTime
			if not recentWallMemory then
				return nil, "Wall blocked"
			end
		end
	end

	local radiusAlpha = 1 - clamp(screenDist / math.max(S.AimRadius, 1), 0, 1)
	local distanceAlpha = 1 - clamp(worldDist / math.max(S.MaxDistance, 1), 0, 1)
	local healthAlpha = 0
	if data.humanoid and data.humanoid.MaxHealth > 0 then
		healthAlpha = 1 - clamp(data.humanoid.Health / data.humanoid.MaxHealth, 0, 1)
	end

	local confidence = 0
	confidence += radiusAlpha * S.FOVPriority
	confidence += distanceAlpha * S.DistancePriority
	if S.PreferLowHealth then
		confidence += healthAlpha * S.HealthPriority
	end
	if S.PreferVisible then
		confidence += los and S.VisiblePriority or -0.12
	end
	if S.StickyTarget and data.object == State.Target then
		confidence += S.StickyBonus
	end
	confidence = clamp(confidence, 0, 1)

	local score = 0
	if S.PreferClosestCrosshair then
		score += screenDist
	end
	if S.PreferClosestDistance then
		score += worldDist * 0.028
	end
	if S.PreferLowHealth then
		score -= healthAlpha * 55
	end
	if S.PreferVisible and los then
		score -= 30
	end
	score -= confidence * 88
	if S.StickyTarget and data.object == State.Target then
		score *= 0.70
	end

	return {
		base = data,
		object = data.object,
		kind = data.kind,
		player = data.player,
		character = data.character,
		humanoid = data.humanoid,
		part = data.part,
		name = data.name,
		aimPos = aimPos,
		screen = screen,
		onScreen = onScreen,
		screenDistance = screenDist,
		distance = worldDist,
		los = los,
		confidence = confidence,
		score = score,
		healthAlpha = healthAlpha,
	}, "OK"
end

local function chooseBestTarget()
	if not S.AimAssist then
		State.Target = nil
		State.Best = nil
		State.Confidence = 0
		State.Reason = "Aim off"
		return nil
	end

	local t = now()
	local best = nil
	local bestReason = "Scanning"

	if S.StickyTarget and State.Target and (t - State.LastSeen) <= S.StickyTime then
		for _, data in ipairs(collectTargets(false)) do
			if data.object == State.Target then
				local candidate = candidateFromTarget(data, false)
				if candidate then
					best = candidate
					bestReason = "Sticky"
				end
				break
			end
		end
	end

	for _, data in ipairs(collectTargets(false)) do
		local candidate = candidateFromTarget(data, false)
		if candidate then
			if not best then
				best = candidate
				bestReason = "Best"
			else
				local canSwitch = (t - State.LastSwitch) >= S.SwitchCooldown
				local advantage = (best.score - candidate.score) / math.max(math.abs(best.score), 1)
				if candidate.object == State.Target then
					best = candidate
					bestReason = "Sticky"
				elseif canSwitch and candidate.score < best.score and advantage >= S.SwitchAdvantage then
					best = candidate
					bestReason = "Switched"
				end
			end
		end
	end

	if best then
		if State.Target ~= best.object then
			State.LastSwitch = t
			if S.DebugPrintTarget then
				-- Console silent by default. Enable your own print here if needed.
			end
		end
		State.Target = best.object
		State.TargetKind = best.kind
		State.Part = best.part
		State.Character = best.character
		State.Humanoid = best.humanoid
		State.AimPosition = best.aimPos
		State.PredictedPosition = best.aimPos
		State.Confidence = best.confidence
		State.LOS = best.los
		State.Distance = best.distance
		State.ScreenDistance = best.screenDistance
		State.LastSeen = t
		if best.los then
			State.LastLOS = t
		end
		State.Best = best
		State.Reason = bestReason .. " / " .. (best.los and "clear" or "wall")
		return best
	end

	State.Target = nil
	State.TargetKind = nil
	State.Part = nil
	State.Character = nil
	State.Humanoid = nil
	State.AimPosition = nil
	State.PredictedPosition = nil
	State.Confidence = 0
	State.LOS = false
	State.Distance = 0
	State.ScreenDistance = math.huge
	State.Best = nil
	State.Reason = "No valid target"
	return nil
end

---------------------------------------------------------------------
-- UI root
---------------------------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "OfficialV4UltraEdition"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999999
Gui.Enabled = true
Gui.Parent = PlayerGui

local Blur = Lighting:FindFirstChild("OfficialV4UltraBlur")
if not Blur then
	Blur = Instance.new("BlurEffect")
	Blur.Name = "OfficialV4UltraBlur"
	Blur.Parent = Lighting
end
Blur.Size = S.MenuOpen and S.BlurSize or 0

local Dim = Instance.new("Frame")
Dim.Name = "Dim"
Dim.Size = UDim2.fromScale(1, 1)
Dim.BackgroundColor3 = Color3.fromRGB(2, 4, 14)
Dim.BackgroundTransparency = S.DimTransparency
Dim.BorderSizePixel = 0
Dim.Visible = S.MenuOpen
Dim.Parent = Gui
local DimGradient = gradient(Dim, Color3.fromRGB(10, 40, 70), Color3.fromRGB(65, 20, 75), 25)

local PatternLayer = Instance.new("Frame")
PatternLayer.Name = "PatternLayer"
PatternLayer.Size = UDim2.fromScale(1, 1)
PatternLayer.BackgroundTransparency = 1
PatternLayer.Visible = S.MenuOpen
PatternLayer.Parent = Gui

for i = 1, 28 do
	local bubble = Instance.new("Frame")
	bubble.AnchorPoint = Vector2.new(0.5, 0.5)
	bubble.Position = UDim2.fromScale(math.random(), math.random())
	local size = math.random(22, 85)
	bubble.Size = UDim2.fromOffset(size, size)
	bubble.BackgroundColor3 = i % 3 == 0 and S.Accent2 or (i % 3 == 1 and S.Accent or S.Accent3)
	bubble.BackgroundTransparency = 0.86
	bubble.BorderSizePixel = 0
	bubble.Parent = PatternLayer
	corner(bubble, 999)
end

local ParticleLayer = Instance.new("Frame")
ParticleLayer.Name = "ParticleLayer"
ParticleLayer.Size = UDim2.fromScale(1, 1)
ParticleLayer.BackgroundTransparency = 1
ParticleLayer.Visible = S.MenuOpen and S.Particles
ParticleLayer.Parent = Gui

local Particles = {}
for i = 1, 48 do
	local p = Instance.new("Frame")
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Size = UDim2.fromOffset(math.random(2, 6), math.random(2, 6))
	p.Position = UDim2.fromScale(math.random(), 1 + math.random() * 0.2)
	p.BackgroundColor3 = i % 2 == 0 and S.Accent or S.Accent3
	p.BackgroundTransparency = math.random(35, 70) / 100
	p.BorderSizePixel = 0
	p.Parent = ParticleLayer
	corner(p, 999)
	Particles[p] = {
		speed = math.random(12, 42) / 10000,
		drift = math.random(-18, 18) / 100000,
	}
end

local TopButton = Instance.new("TextButton")
TopButton.Name = "TopButton"
TopButton.AnchorPoint = Vector2.new(1, 0)
TopButton.Position = UDim2.new(1, -16, 0, 16)
TopButton.Size = UDim2.fromOffset(150, 48)
TopButton.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
TopButton.BackgroundTransparency = 0.04
TopButton.BorderSizePixel = 0
TopButton.Font = Enum.Font.GothamBlack
TopButton.Text = S.MenuOpen and "✕ CLOSE" or "◆ V4 ULTRA"
TopButton.TextColor3 = Color3.new(1, 1, 1)
TopButton.TextSize = 15
TopButton.Visible = true
TopButton.ZIndex = 10000
TopButton.Parent = Gui
corner(TopButton, 10)
stroke(TopButton, S.Accent, 0.10, 2)

gradient(TopButton, Color3.fromRGB(30, 34, 46), Color3.fromRGB(12, 14, 20), -90)

local Root = Instance.new("Frame")
Root.Name = "Root"
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.Position = UDim2.fromScale(0.5, 0.5)
Root.Size = UDim2.fromOffset(1180, 640)
Root.BackgroundColor3 = S.Background
Root.BackgroundTransparency = S.Glass
Root.BorderSizePixel = 0
Root.Visible = S.MenuOpen
Root.Parent = Gui
corner(Root, 4)
stroke(Root, Color3.fromRGB(240, 240, 240), 0.05, 3)
local RootScale = Instance.new("UIScale")
RootScale.Parent = Root

local RootPattern = Instance.new("Frame")
RootPattern.Name = "RootPattern"
RootPattern.Size = UDim2.fromScale(1, 1)
RootPattern.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
RootPattern.BackgroundTransparency = 0.15
RootPattern.BorderSizePixel = 0
RootPattern.Parent = Root
corner(RootPattern, 4)
gradient(RootPattern, Color3.fromRGB(18, 22, 31), Color3.fromRGB(8, 10, 15), 0)

for i = 1, 34 do
	local c = Instance.new("Frame")
	c.AnchorPoint = Vector2.new(0.5, 0.5)
	c.Position = UDim2.fromScale(math.random(), math.random())
	local size = math.random(18, 80)
	c.Size = UDim2.fromOffset(size, size)
	c.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(70, 50, 18) or Color3.fromRGB(30, 35, 50)
	c.BackgroundTransparency = 0.78
	c.BorderSizePixel = 0
	c.Parent = RootPattern
	corner(c, 999)
end

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BackgroundTransparency = 0.03
Header.BorderSizePixel = 0
Header.Parent = Root
stroke(Header, Color3.fromRGB(0, 0, 0), 0.2, 1)
gradient(Header, Color3.fromRGB(35, 35, 38), Color3.fromRGB(14, 14, 18), -90)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(12, 2)
Title.Size = UDim2.new(1, -160, 0, 22)
Title.Font = Enum.Font.Code
Title.Text = "uwu-style official V4 Ultra"
Title.TextColor3 = Color3.fromRGB(225, 225, 235)
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local HeaderClose = Instance.new("TextButton")
HeaderClose.Name = "HeaderClose"
HeaderClose.AnchorPoint = Vector2.new(1, 0)
HeaderClose.Position = UDim2.new(1, -8, 0, 5)
HeaderClose.Size = UDim2.fromOffset(96, 24)
HeaderClose.BackgroundColor3 = Color3.fromRGB(58, 24, 32)
HeaderClose.BackgroundTransparency = 0.05
HeaderClose.BorderSizePixel = 0
HeaderClose.Font = Enum.Font.Code
HeaderClose.Text = "close"
HeaderClose.TextColor3 = Color3.fromRGB(255, 210, 220)
HeaderClose.TextSize = 15
HeaderClose.ZIndex = 50
HeaderClose.Parent = Header
corner(HeaderClose, 3)
stroke(HeaderClose, Color3.fromRGB(255, 80, 120), 0.25, 1)

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Position = UDim2.fromOffset(10, 25)
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Header

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(10, 66)
Content.Size = UDim2.new(1, -20, 1, -76)
Content.BackgroundTransparency = 1
Content.Parent = Root

local LeftColumn = Instance.new("ScrollingFrame")
local MidColumn = Instance.new("ScrollingFrame")
local RightColumn = Instance.new("ScrollingFrame")
local Columns = {LeftColumn, MidColumn, RightColumn}

for i, col in ipairs(Columns) do
	col.Name = "Column" .. i
	col.Position = UDim2.fromOffset((i - 1) * 386, 0)
	col.Size = UDim2.fromOffset(374, 564)
	col.BackgroundTransparency = 1
	col.BorderSizePixel = 0
	col.ScrollBarThickness = 3
	col.ScrollBarImageColor3 = i == 1 and S.Accent or (i == 2 and S.Accent2 or S.Accent3)
	col.CanvasSize = UDim2.fromOffset(0, 800)
	col.Parent = Content
end

local function updateScale()
	local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
	local scale = math.min(vp.X / 1280, vp.Y / 760)
	if S.UIScaleMobile then
		scale = clamp(scale, 0.50, 1)
	else
		scale = clamp(scale, 0.70, 1)
	end
	RootScale.Scale = scale
end

---------------------------------------------------------------------
-- UI widgets
---------------------------------------------------------------------

local UI = {}
UI.TabButtons = {}
UI.Elements = {}
UI.ColumnY = {0, 0, 0}

local function getColumn(index)
	return Columns[index]
end

local function resetColumns()
	for _, col in ipairs(Columns) do
		clearGui(col)
	end
	UI.ColumnY = {0, 0, 0}
end

local function section(columnIndex, title, accent)
	local col = getColumn(columnIndex)
	local y = UI.ColumnY[columnIndex]
	local sec = Instance.new("Frame")
	sec.Position = UDim2.fromOffset(0, y)
	sec.Size = UDim2.fromOffset(374, 40)
	sec.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	sec.BackgroundTransparency = 0.08
	sec.BorderSizePixel = 0
	sec.Parent = col
	corner(sec, 2)
	stroke(sec, accent, 0.25, 1)

	local line = Instance.new("Frame")
	line.Position = UDim2.fromOffset(0, 0)
	line.Size = UDim2.new(1, 0, 0, 3)
	line.BackgroundColor3 = accent
	line.BorderSizePixel = 0
	line.Parent = sec

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 8)
	label.Size = UDim2.new(1, -24, 0, 24)
	label.Font = Enum.Font.Code
	label.Text = "— " .. title
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sec

	UI.ColumnY[columnIndex] += 50
	return sec
end

local function widgetFrame(columnIndex, height)
	local col = getColumn(columnIndex)
	local y = UI.ColumnY[columnIndex]
	local f = Instance.new("Frame")
	f.Position = UDim2.fromOffset(0, y)
	f.Size = UDim2.fromOffset(374, height)
	f.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	f.BackgroundTransparency = 0.16
	f.BorderSizePixel = 0
	f.Parent = col
	corner(f, 2)
	stroke(f, Color3.fromRGB(70, 70, 80), 0.55, 1)
	UI.ColumnY[columnIndex] += height + 8
	return f
end

local function addToggle(columnIndex, text, key, tip)
	local f = widgetFrame(columnIndex, 30)
	local box = Instance.new("TextButton")
	box.Position = UDim2.fromOffset(10, 8)
	box.Size = UDim2.fromOffset(16, 16)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	box.BorderSizePixel = 0
	box.Text = ""
	box.Parent = f
	stroke(box, Color3.fromRGB(0,0,0), 0, 1)

	local fill = Instance.new("Frame")
	fill.Position = UDim2.fromOffset(3, 3)
	fill.Size = UDim2.fromOffset(10, 10)
	fill.BackgroundColor3 = currentAccent()
	fill.BorderSizePixel = 0
	fill.Visible = S[key] == true
	fill.Parent = box

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(34, 4)
	label.Size = UDim2.new(1, -44, 0, 22)
	label.Font = Enum.Font.Code
	label.Text = text
	label.TextColor3 = S[key] and Color3.fromRGB(230,230,240) or Color3.fromRGB(165,165,175)
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local function set(v)
		S[key] = v
		fill.Visible = v
		fill.BackgroundColor3 = currentAccent()
		label.TextColor3 = v and Color3.fromRGB(230,230,240) or Color3.fromRGB(165,165,175)
	end

	box.MouseButton1Click:Connect(function()
		set(not S[key])
	end)
	f.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			set(not S[key])
		end
	end)

	UI.Elements[key] = {Set = set, Type = "Toggle"}
	return f
end

local function addSlider(columnIndex, text, key, minVal, maxVal, decimals, suffix)
	local f = widgetFrame(columnIndex, 50)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(10, 3)
	label.Size = UDim2.new(1, -20, 0, 19)
	label.Font = Enum.Font.Code
	label.TextColor3 = Color3.fromRGB(220,220,230)
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local bar = Instance.new("Frame")
	bar.Position = UDim2.fromOffset(10, 27)
	bar.Size = UDim2.new(1, -20, 0, 16)
	bar.BackgroundColor3 = Color3.fromRGB(45, 45, 54)
	bar.BorderSizePixel = 0
	bar.Parent = f
	stroke(bar, Color3.fromRGB(0,0,0), 0.2, 1)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = currentAccent()
	fill.BorderSizePixel = 0
	fill.Parent = bar
	gradient(fill, Color3.fromRGB(80,80,85), currentAccent(), 0)

	local valueText = Instance.new("TextLabel")
	valueText.BackgroundTransparency = 1
	valueText.Size = UDim2.fromScale(1, 1)
	valueText.Font = Enum.Font.Code
	valueText.TextColor3 = Color3.fromRGB(235,235,240)
	valueText.TextSize = 14
	valueText.Parent = bar

	local dragging = false
	local function fmt(v)
		if decimals == 0 then
			return tostring(math.floor(v + 0.5))
		end
		return string.format("%." .. tostring(decimals) .. "f", v)
	end
	local function set(v)
		S[key] = clamp(v, minVal, maxVal)
		local a = (S[key] - minVal) / (maxVal - minVal)
		fill.Size = UDim2.fromScale(a, 1)
		label.Text = text .. ": " .. fmt(S[key]) .. (suffix or "")
		valueText.Text = fmt(S[key]) .. (suffix or "")
	end
	local function fromX(x)
		local a = clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
		local v = minVal + (maxVal - minVal) * a
		if decimals == 0 then v = math.floor(v + 0.5) end
		set(v)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	set(S[key])
	UI.Elements[key] = {Set = set, Type = "Slider"}
	return f
end

local function addDropdown(columnIndex, text, key, values)
	local f = widgetFrame(columnIndex, 38)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(10, 4)
	label.Size = UDim2.fromOffset(120, 28)
	label.Font = Enum.Font.Code
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220,220,230)
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local button = Instance.new("TextButton")
	button.Position = UDim2.new(1, -170, 0, 6)
	button.Size = UDim2.fromOffset(160, 26)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Code
	button.TextColor3 = Color3.fromRGB(240,240,245)
	button.TextSize = 14
	button.Parent = f
	stroke(button, Color3.fromRGB(0,0,0), 0.2, 1)

	local idx = 1
	for i, v in ipairs(values) do
		if v == S[key] then idx = i end
	end
	local function setIndex(i)
		idx = ((i - 1) % #values) + 1
		S[key] = values[idx]
		button.Text = values[idx] .. "  ▼"
	end
	button.MouseButton1Click:Connect(function()
		setIndex(idx + 1)
	end)
	setIndex(idx)
	return f
end

local function addInfo(columnIndex, text, height)
	local f = widgetFrame(columnIndex, height or 90)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(10, 8)
	label.Size = UDim2.new(1, -20, 1, -16)
	label.Font = Enum.Font.Code
	label.Text = text
	label.TextColor3 = Color3.fromRGB(195, 200, 215)
	label.TextSize = 14
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = f
	return f
end

local function rebuildTab()
	resetColumns()
	for name, btn in pairs(UI.TabButtons) do
		btn.TextColor3 = name == S.ActiveTab and currentAccent() or Color3.fromRGB(230,230,235)
	end

	if S.ActiveTab == "Aim" then
		section(1, "Main", S.Accent)
		addToggle(1, "Enabled", "AimAssist")
		addToggle(1, "Auto Aim", "AutoAim")
		addToggle(1, "Hold To Aim", "HoldToAim")
		addToggle(1, "Target Lock", "TargetLock")
		addDropdown(1, "Mode", "AimPart", {"Head", "HumanoidRootPart"})
		addSlider(1, "Smoothness", "AimStrength", 0.02, 0.9, 2)
		addSlider(1, "FOV Size", "AimRadius", 40, 520, 0)

		section(1, "Targeting", S.Accent)
		addToggle(1, "Team Check", "TeamCheck")
		addToggle(1, "Alive Check", "AliveCheck")
		addToggle(1, "Ignore Spawn Protection", "IgnoreSpawnProtection")
		addToggle(1, "Players", "TargetPlayers")
		addToggle(1, "NPCs", "TargetNPCs")
		addToggle(1, "AimTarget Tag", "UseAimTargetTag")
		addSlider(1, "Max Distance", "MaxDistance", 100, 3500, 0)

		section(2, "Prediction", S.Accent2)
		addToggle(2, "Prediction", "Prediction")
		addToggle(2, "Velocity Prediction", "VelocityPrediction")
		addSlider(2, "Prediction Lead", "PredictionLead", 0, 0.6, 2)
		addSlider(2, "Vertical Prediction", "VerticalPrediction", 0, 1.2, 2)
		addToggle(2, "Dynamic", "DynamicSmoothing")
		addToggle(2, "Near Center Boost", "NearCenterBoost")
		addSlider(2, "Min Strength", "MinAimStrength", 0.01, 0.5, 2)
		addSlider(2, "Max Strength", "MaxAimStrength", 0.05, 0.95, 2)

		section(2, "Sticky Aim", S.Accent2)
		addToggle(2, "Sticky Target", "StickyTarget")
		addSlider(2, "Sticky Time", "StickyTime", 0, 4, 2)
		addSlider(2, "Switch Cooldown", "SwitchCooldown", 0, 1.2, 2)
		addSlider(2, "Switch Advantage", "SwitchAdvantage", 0, 0.8, 2)

		section(3, "Walls", S.Accent3)
		addToggle(3, "Line Of Sight", "LineOfSight")
		addToggle(3, "Require LOS For Aim", "RequireLOSForAim")
		addToggle(3, "Wall Memory", "WallMemory")
		addSlider(3, "Wall Memory Time", "WallMemoryTime", 0, 2.5, 2)

		section(3, "Priority", S.Accent3)
		addToggle(3, "Prefer Visible", "PreferVisible")
		addToggle(3, "Prefer Low Health", "PreferLowHealth")
		addToggle(3, "Closest Crosshair", "PreferClosestCrosshair")
		addToggle(3, "Closest Distance", "PreferClosestDistance")
		addSlider(3, "FOV Priority", "FOVPriority", 0, 1.2, 2)
		addSlider(3, "Distance Priority", "DistancePriority", 0, 0.8, 2)
		addSlider(3, "Visible Priority", "VisiblePriority", 0, 0.8, 2)
		addSlider(3, "Min Confidence", "MinConfidence", 0.05, 0.95, 2)

	elseif S.ActiveTab == "Visuals" then
		section(1, "ESP Enemies", S.Accent)
		addToggle(1, "ESP Enabled", "ESP")
		addToggle(1, "ESP Players", "ESPPlayers")
		addToggle(1, "ESP NPCs", "ESPNPCs")
		addToggle(1, "Only Enemies", "ESPOnlyEnemies")
		addToggle(1, "Names", "ESPNames")
		addToggle(1, "Info", "ESPState")
		addToggle(1, "Distance", "ESPDistance")
		addToggle(1, "Health", "ESPHealth")
		addToggle(1, "Team", "ESPTeam")
		addToggle(1, "Confidence", "ESPConfidence")

		section(2, "ESP Draw", S.Accent2)
		addToggle(2, "Chams / Highlights", "ESPHighlights")
		addToggle(2, "2D Box", "ESPBoxes")
		addToggle(2, "Health Bar", "ESPHealthBar")
		addToggle(2, "Look Direction", "ShowAimLine")
		addToggle(2, "Snaplines", "ESPSnaplines")
		addToggle(2, "Offscreen Arrows", "ESPOffscreenArrows")
		addToggle(2, "Target Marker", "ESPTargetMarker")
		addToggle(2, "Visible / Wall Colors", "ESPVisibleWallColors")
		addToggle(2, "Team Colors", "ESPTeamColors")
		addToggle(2, "Name Background", "ESPNameBackground")

		section(3, "ESP Settings", S.Accent3)
		addSlider(3, "ESP Max Distance", "ESPMaxDistance", 100, 7000, 0)
		addSlider(3, "Text Size", "ESPTextSize", 9, 28, 0)
		addSlider(3, "Line Thickness", "ESPLineThickness", 1, 8, 0)
		addSlider(3, "Box Thickness", "ESPBoxThickness", 1, 8, 0)
		addSlider(3, "ESP Update Rate", "ESPUpdateRate", 0.01, 0.2, 2)

		section(3, "FOV / Crosshair", S.Accent3)
		addToggle(3, "Show FOV", "ShowFOV")
		addToggle(3, "FOV Rainbow", "FOVRainbow")
		addToggle(3, "FOV Filled", "FOVFilled")
		addSlider(3, "FOV Fill Trans", "FOVFillTransparency", 0.75, 1, 2)
		addSlider(3, "FOV Thickness", "FOVThickness", 1, 8, 0)
		addToggle(3, "Crosshair", "ShowCrosshair")
		addToggle(3, "Crosshair Dot", "CrosshairDot")
		addSlider(3, "Crosshair Gap", "CrosshairGap", 0, 30, 0)
		addSlider(3, "Crosshair Length", "CrosshairLength", 2, 35, 0)
		addSlider(3, "Crosshair Thick", "CrosshairThickness", 1, 8, 0)

	elseif S.ActiveTab == "Shooting" then
		section(1, "Weapon Bridge", S.Accent)
		addToggle(1, "Shot Correction", "ShotCorrection")
		addToggle(1, "Auto Fire Request", "AutoFireRequest")
		addToggle(1, "Manual Correction Only", "ManualCorrectionOnly")
		addToggle(1, "Require LOS For Fire", "RequireLOSForFire")
		addToggle(1, "Only Fire Centered", "OnlyFireWhenCentered")
		addSlider(1, "Fire Confidence", "FireConfidence", 0.1, 0.98, 2)
		addSlider(1, "Fire Rate", "FireRate", 1, 24, 0)
		addSlider(1, "Center Radius", "FireCenterRadius", 4, 150, 0)

		section(2, "Burst / Trigger", S.Accent2)
		addToggle(2, "Burst Mode", "BurstMode")
		addSlider(2, "Burst Shots", "BurstShots", 1, 10, 0)
		addSlider(2, "Burst Delay", "BurstDelay", 0.02, 0.35, 2)
		addToggle(2, "Trigger Assist", "Triggerbot")
		addSlider(2, "Trigger Delay", "TriggerDelay", 0.01, 0.25, 2)
		addInfo(2, "Auto Fire Request only fires a local BindableEvent. Connect it to your own weapon controller. Your server must validate ammo, cooldown, reload, team, LOS, distance and damage.", 120)

		section(3, "Integration", S.Accent3)
		addInfo(3, "BindableEvent:\nPlayerGui.OfficialV4UltraFireRequested\n\nBindableFunction:\nPlayerGui.OfficialV4UltraGetCorrectedAim\n\nUse these inside your own weapon scripts only.", 190)
		addToggle(3, "Print Fire Requests", "PrintFireRequests")

	elseif S.ActiveTab == "Death Zone" then
		section(1, "Death Zone", S.Accent)
		addToggle(1, "Death Zone Assist", "DeathZoneAssist")
		addToggle(1, "Warning", "DeathZoneWarning")
		addToggle(1, "Death Zone ESP", "DeathZoneESP")
		addSlider(1, "Warning Distance", "DeathZoneDistance", 10, 250, 0)
		addInfo(1, "Create workspace.DeathZones and put parts inside it. This tab can warn players in your own game when they are near danger zones.", 120)

		section(2, "Arena Debug", S.Accent2)
		addInfo(2, "This is not a cheat feature. It is a debug/accessibility helper for your own arena maps. You can rename the folder in code if your map uses another name.", 120)

		section(3, "Status", S.Accent3)
		addInfo(3, "Current folder: workspace." .. S.DeathZoneFolder .. "\nDistance: " .. tostring(S.DeathZoneDistance), 90)

	elseif S.ActiveTab == "Settings" then
		section(1, "Menu", S.Accent)
		addToggle(1, "Top Button", "ShowTopButton")
		addToggle(1, "Mini Status", "ShowMiniStatus")
		addToggle(1, "Notifications", "ShowNotifications")
		addToggle(1, "Blur", "Blur")
		addToggle(1, "Pattern", "Pattern")
		addToggle(1, "Particles", "Particles")
		addToggle(1, "Animated Gradient", "AnimatedGradient")
		addToggle(1, "Animations", "Animations")
		addToggle(1, "Rainbow Accent", "RainbowAccent")
		addSlider(1, "Glass", "Glass", 0, 0.5, 2)
		addSlider(1, "Dim", "DimTransparency", 0.1, 0.85, 2)
		addSlider(1, "Blur Size", "BlurSize", 0, 24, 0)

		section(2, "Mobile", S.Accent2)
		addToggle(2, "Mobile Scaling", "UIScaleMobile")
		addInfo(2, "Open/close button stays at top right. RightShift also toggles on PC. The whole UI scales down on phones/tablets.", 100)

		section(3, "Debug / Admin", S.Accent3)
		addToggle(3, "Admin Only", "AdminOnly")
		addToggle(3, "Debug HUD", "DebugHUD")
		addToggle(3, "Debug Print Target", "DebugPrintTarget")
		addToggle(3, "Show Performance", "ShowPerformance")
		addInfo(3, "For AdminOnly, add your UserIds in S.AllowedUserIds near the top of the script. This script is designed for your own Roblox Studio game.", 135)
	end

	for i, col in ipairs(Columns) do
		col.CanvasSize = UDim2.fromOffset(0, UI.ColumnY[i] + 20)
	end
end

local TabNames = {"Aim", "Visuals", "Shooting", "Death Zone", "Settings"}
local tabX = 0
for _, name in ipairs(TabNames) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.Position = UDim2.fromOffset(tabX, 0)
	btn.Size = UDim2.fromOffset(name == "Death Zone" and 125 or 92, 28)
	btn.Font = Enum.Font.Code
	btn.Text = name
	btn.TextColor3 = name == S.ActiveTab and S.Accent or Color3.fromRGB(230,230,235)
	btn.TextSize = 16
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = TabBar
	UI.TabButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		S.ActiveTab = name
		rebuildTab()
	end)
	tabX += btn.Size.X.Offset + 22
end

rebuildTab()

---------------------------------------------------------------------
-- HUD drawing layers
---------------------------------------------------------------------

local WorldLayer = Instance.new("Frame")
WorldLayer.Name = "WorldLayer"
WorldLayer.Size = UDim2.fromScale(1, 1)
WorldLayer.BackgroundTransparency = 1
WorldLayer.Parent = Gui

local ESPLayer = Instance.new("Frame")
ESPLayer.Name = "ESPLayer"
ESPLayer.Size = UDim2.fromScale(1, 1)
ESPLayer.BackgroundTransparency = 1
ESPLayer.Parent = Gui

local CrosshairLayer = Instance.new("Frame")
CrosshairLayer.Name = "CrosshairLayer"
CrosshairLayer.Size = UDim2.fromScale(1, 1)
CrosshairLayer.BackgroundTransparency = 1
CrosshairLayer.Parent = Gui

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(S.AimRadius * 2, S.AimRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = WorldLayer
corner(FOVCircle, 999)
local FOVStroke = stroke(FOVCircle, S.Accent, 0.08, S.FOVThickness)
local FOVFill = Instance.new("Frame")
FOVFill.Size = UDim2.fromScale(1, 1)
FOVFill.BackgroundColor3 = S.Accent
FOVFill.BackgroundTransparency = S.FOVFillTransparency
FOVFill.BorderSizePixel = 0
FOVFill.Parent = FOVCircle
corner(FOVFill, 999)

local MiniStatus = Instance.new("TextLabel")
MiniStatus.Name = "MiniStatus"
MiniStatus.AnchorPoint = Vector2.new(0.5, 0)
MiniStatus.Position = UDim2.fromScale(0.5, 0.065)
MiniStatus.Size = UDim2.fromOffset(520, 48)
MiniStatus.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
MiniStatus.BackgroundTransparency = 0.14
MiniStatus.BorderSizePixel = 0
MiniStatus.Font = Enum.Font.Code
MiniStatus.TextColor3 = Color3.fromRGB(230, 245, 255)
MiniStatus.TextSize = 14
MiniStatus.Text = "V4 Ultra starting..."
MiniStatus.Parent = Gui
corner(MiniStatus, 4)
stroke(MiniStatus, S.Accent, 0.3, 1)

local NotificationLayer = Instance.new("Frame")
NotificationLayer.Name = "NotificationLayer"
NotificationLayer.Size = UDim2.fromScale(1, 1)
NotificationLayer.BackgroundTransparency = 1
NotificationLayer.Parent = Gui

local function notify(text, duration)
	if not S.ShowNotifications then return end
	duration = duration or 2.2
	NotificationIndex += 1
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(1, 1)
	f.Position = UDim2.new(1, -16, 1, -16 - ((NotificationIndex - 1) % 4) * 74)
	f.Size = UDim2.fromOffset(0, 64)
	f.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	f.BackgroundTransparency = 0.04
	f.BorderSizePixel = 0
	f.Parent = NotificationLayer
	corner(f, 4)
	stroke(f, currentAccent(), 0.25, 1)

	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(10, 8)
	l.Size = UDim2.new(1, -20, 1, -16)
	l.Font = Enum.Font.Code
	l.Text = text
	l.TextColor3 = Color3.fromRGB(235,235,245)
	l.TextSize = 14
	l.TextWrapped = true
	l.TextTransparency = 1
	l.Parent = f

	tween(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(260, 64)})
	tween(l, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {TextTransparency = 0})
	task.delay(duration, function()
		if f.Parent then
			tween(f, TweenInfo.new(0.18), {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 64)})
			task.delay(0.2, function()
				if f.Parent then f:Destroy() end
			end)
		end
	end)
end

notify("V4 Ultra loaded. Only use inside your own Roblox game.", 3)

---------------------------------------------------------------------
-- UI open/close and input
---------------------------------------------------------------------

local function setMenu(open)
	S.MenuOpen = open
	Root.Visible = open
	Dim.Visible = open
	PatternLayer.Visible = open and S.Pattern
	ParticleLayer.Visible = open and S.Particles
	TopButton.Text = open and "✕ CLOSE" or "◆ V4 ULTRA"
	TopButton.Visible = true
	TopButton.ZIndex = 10000
	if S.Blur then
		tween(Blur, TweenInfo.new(0.16), {Size = open and S.BlurSize or 0})
	else
		Blur.Size = 0
	end
	if open then
		Root.Size = UDim2.fromOffset(1140, 610)
		tween(Root, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(1180, 640)})
	end
end

TopButton.MouseButton1Click:Connect(function()
	setMenu(not S.MenuOpen)
end)

HeaderClose.MouseButton1Click:Connect(function()
	setMenu(false)
end)

addConnection(UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == S.OpenKey then
		setMenu(not S.MenuOpen)
	end
	if input.UserInputType == S.AimInput then
		State.HoldingAim = true
	end
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == S.AimInput then
		State.HoldingAim = false
	end
end))

local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Root.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

---------------------------------------------------------------------
-- Drawing helpers
---------------------------------------------------------------------

local function drawLine(parent, fromPos, toPos, color, thickness)
	local diff = toPos - fromPos
	local length = diff.Magnitude
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromOffset((fromPos.X + toPos.X) / 2, (fromPos.Y + toPos.Y) / 2)
	f.Size = UDim2.fromOffset(length, thickness)
	f.Rotation = math.deg(math.atan2(diff.Y, diff.X))
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function drawCrosshair()
	clearGui(CrosshairLayer)
	if not S.ShowCrosshair then return end
	local vp = Camera.ViewportSize
	local cx, cy = vp.X / 2, vp.Y / 2
	local gap = S.CrosshairGap
	local len = S.CrosshairLength
	local thick = S.CrosshairThickness
	local col = Color3.fromRGB(255,255,255)
	drawLine(CrosshairLayer, Vector2.new(cx - gap - len, cy), Vector2.new(cx - gap, cy), col, thick)
	drawLine(CrosshairLayer, Vector2.new(cx + gap, cy), Vector2.new(cx + gap + len, cy), col, thick)
	drawLine(CrosshairLayer, Vector2.new(cx, cy - gap - len), Vector2.new(cx, cy - gap), col, thick)
	drawLine(CrosshairLayer, Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + len), col, thick)
	if S.CrosshairDot then
		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.fromOffset(cx, cy)
		dot.Size = UDim2.fromOffset(thick + 2, thick + 2)
		dot.BackgroundColor3 = col
		dot.BorderSizePixel = 0
		dot.Parent = CrosshairLayer
		corner(dot, 999)
	end
end

local function getESPColor(candidate)
	if not candidate then return S.EnemyColor end
	if S.ESPTeamColors and candidate.player then
		return colorForTeam(candidate.player)
	end
	if S.ESPVisibleWallColors then
		return candidate.los and S.ReadyColor or S.WallColor
	end
	return S.EnemyColor
end

local function cleanupEspCache()
	for obj, pack in pairs(EspCache) do
		if not obj.Parent then
			if pack.Highlight then pack.Highlight:Destroy() end
			if pack.Billboard then pack.Billboard:Destroy() end
			EspCache[obj] = nil
		end
	end
end

local function updateESP()
	if not S.ESP then
		clearGui(ESPLayer)
		for _, pack in pairs(EspCache) do
			if pack.Highlight then pack.Highlight:Destroy(); pack.Highlight = nil end
			if pack.Billboard then pack.Billboard:Destroy(); pack.Billboard = nil end
		end
		return
	end

	local t = now()
	if t - State.LastESPUpdate < S.ESPUpdateRate then
		return
	end
	State.LastESPUpdate = t

	clearGui(ESPLayer)
	cleanupEspCache()

	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)
	local bottom = Vector2.new(vp.X / 2, vp.Y - 10)

	for _, data in ipairs(collectTargets(true)) do
		local candidate = candidateFromTarget(data, true)
		if candidate then
			local color = getESPColor(candidate)
			local pack = EspCache[data.object] or {}
			EspCache[data.object] = pack

			if S.ESPHighlights then
				if not pack.Highlight or pack.Highlight.Parent ~= data.character then
					if pack.Highlight then pack.Highlight:Destroy() end
					pack.Highlight = Instance.new("Highlight")
					pack.Highlight.Name = "V4UltraHighlight"
					pack.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					pack.Highlight.FillTransparency = 0.78
					pack.Highlight.OutlineTransparency = 0
					pack.Highlight.Parent = data.character
				end
				pack.Highlight.FillColor = color
				pack.Highlight.OutlineColor = color
			elseif pack.Highlight then
				pack.Highlight:Destroy()
				pack.Highlight = nil
			end

			local showBillboard = S.ESPNames or S.ESPDistance or S.ESPHealth or S.ESPTeam or S.ESPConfidence or S.ESPState or (S.ESPTargetMarker and State.Target == data.object)
			if showBillboard then
				if not pack.Billboard or pack.Billboard.Parent ~= data.character then
					if pack.Billboard then pack.Billboard:Destroy() end
					pack.Billboard = Instance.new("BillboardGui")
					pack.Billboard.Name = "V4UltraBillboard"
					pack.Billboard.AlwaysOnTop = true
					pack.Billboard.Size = UDim2.fromOffset(210, 82)
					pack.Billboard.StudsOffset = Vector3.new(0, 3.4, 0)
					pack.Billboard.Adornee = data.part
					pack.Billboard.Parent = data.character

					pack.LabelBG = Instance.new("Frame")
					pack.LabelBG.AnchorPoint = Vector2.new(0.5, 0.5)
					pack.LabelBG.Position = UDim2.fromScale(0.5, 0.5)
					pack.LabelBG.Size = UDim2.fromScale(1, 1)
					pack.LabelBG.BackgroundColor3 = Color3.fromRGB(0,0,0)
					pack.LabelBG.BackgroundTransparency = 0.55
					pack.LabelBG.BorderSizePixel = 0
					pack.LabelBG.Parent = pack.Billboard
					corner(pack.LabelBG, 4)

					pack.Label = Instance.new("TextLabel")
					pack.Label.BackgroundTransparency = 1
					pack.Label.Size = UDim2.fromScale(1, 1)
					pack.Label.Font = Enum.Font.Code
					pack.Label.TextStrokeTransparency = 0.2
					pack.Label.Parent = pack.Billboard
				end

				local text = ""
				if S.ESPTargetMarker and State.Target == data.object then text ..= "◆ TARGET\n" end
				if S.ESPNames then text ..= data.name end
				if S.ESPDistance then text ..= " [" .. math.floor(candidate.distance) .. "m]" end
				if S.ESPHealth and data.humanoid then text ..= "\nHP " .. math.floor(data.humanoid.Health) .. "/" .. math.floor(data.humanoid.MaxHealth) end
				if S.ESPTeam and data.player and data.player.Team then text ..= "\n" .. data.player.Team.Name end
				if S.ESPConfidence then text ..= "  " .. math.floor(candidate.confidence * 100) .. "%" end
				if S.ESPState then text ..= candidate.los and "\nVISIBLE" or "\nWALL" end
				pack.Label.Text = text
				pack.Label.TextSize = S.ESPTextSize
				pack.Label.TextColor3 = color
				if pack.LabelBG then pack.LabelBG.Visible = S.ESPNameBackground end
			elseif pack.Billboard then
				pack.Billboard:Destroy()
				pack.Billboard = nil
			end

			local screen = candidate.screen
			local screen2 = Vector2.new(screen.X, screen.Y)
			if candidate.onScreen and screen.Z > 0 then
				if S.ESPSnaplines then
					drawLine(ESPLayer, bottom, screen2, color, S.ESPLineThickness)
				end
				if S.ESPBoxes then
					local boxH = clamp(19000 / math.max(candidate.distance, 30), 28, 185)
					local boxW = boxH * 0.55
					local box = Instance.new("Frame")
					box.AnchorPoint = Vector2.new(0.5, 0.5)
					box.Position = UDim2.fromOffset(screen.X, screen.Y)
					box.Size = UDim2.fromOffset(boxW, boxH)
					box.BackgroundTransparency = 1
					box.Parent = ESPLayer
					stroke(box, color, 0.04, S.ESPBoxThickness)

					if S.ESPHealthBar and data.humanoid then
						local hpAlpha = clamp(data.humanoid.Health / math.max(data.humanoid.MaxHealth, 1), 0, 1)
						local bg = Instance.new("Frame")
						bg.Position = UDim2.fromOffset(screen.X - boxW / 2 - 8, screen.Y - boxH / 2)
						bg.Size = UDim2.fromOffset(4, boxH)
						bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
						bg.BorderSizePixel = 0
						bg.Parent = ESPLayer
						local hp = Instance.new("Frame")
						hp.AnchorPoint = Vector2.new(0, 1)
						hp.Position = UDim2.new(0, 0, 1, 0)
						hp.Size = UDim2.new(1, 0, hpAlpha, 0)
						hp.BackgroundColor3 = Color3.fromRGB(60, 255, 110)
						hp.BorderSizePixel = 0
						hp.Parent = bg
					end
				end
			elseif S.ESPOffscreenArrows then
				local dir = (screen2 - center)
				if dir.Magnitude < 1 then dir = Vector2.new(0, -1) end
				dir = dir.Unit
				local edge = center + dir * (math.min(vp.X, vp.Y) * 0.42)
				local arrow = Instance.new("TextLabel")
				arrow.AnchorPoint = Vector2.new(0.5, 0.5)
				arrow.Position = UDim2.fromOffset(edge.X, edge.Y)
				arrow.Size = UDim2.fromOffset(34, 34)
				arrow.BackgroundTransparency = 1
				arrow.Font = Enum.Font.GothamBlack
				arrow.Text = "▲"
				arrow.TextSize = 26
				arrow.TextColor3 = color
				arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) + 90
				arrow.Parent = ESPLayer
			end
		end
	end
end

---------------------------------------------------------------------
-- Death zone helpers
---------------------------------------------------------------------

local function updateDeathZoneESP()
	if not S.DeathZoneAssist or not S.DeathZoneESP then return end
	local folder = workspace:FindFirstChild(S.DeathZoneFolder)
	if not folder then return end
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			local dist = (part.Position - root.Position).Magnitude
			if dist <= S.DeathZoneDistance * 2 then
				local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen and screen.Z > 0 then
					local label = Instance.new("TextLabel")
					label.AnchorPoint = Vector2.new(0.5, 0.5)
					label.Position = UDim2.fromOffset(screen.X, screen.Y)
					label.Size = UDim2.fromOffset(150, 28)
					label.BackgroundTransparency = 0.35
					label.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
					label.BorderSizePixel = 0
					label.Font = Enum.Font.Code
					label.Text = "DEATH ZONE " .. math.floor(dist) .. "m"
					label.TextSize = 13
					label.TextColor3 = S.DeathZoneColor
					label.Parent = ESPLayer
					corner(label, 4)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- Weapon bridge
---------------------------------------------------------------------

local function buildAimData(forFire)
	local best = State.Best
	if not best then return nil end
	if forFire then
		if S.FireConfidence and State.Confidence < S.FireConfidence then return nil end
		if S.RequireLOSForFire and not State.LOS then return nil end
		if S.OnlyFireWhenCentered and State.ScreenDistance > S.FireCenterRadius then return nil end
	end
	return {
		target = State.Target,
		targetKind = State.TargetKind,
		targetPart = State.Part,
		character = State.Character,
		humanoid = State.Humanoid,
		aimPosition = State.AimPosition,
		predictedPosition = State.PredictedPosition,
		confidence = State.Confidence,
		lineOfSight = State.LOS,
		distance = State.Distance,
		screenDistance = State.ScreenDistance,
		reason = State.Reason,
		time = now(),
	}
end

CorrectedAim.OnInvoke = function(defaultAimPosition)
	if not S.ShotCorrection then return nil end
	return buildAimData(false)
end

local function fireRequest()
	local data = buildAimData(true)
	if not data then return end
	FireRequested:Fire(data)
	if S.PrintFireRequests then
		-- Console silent by default. Enable your own print here if needed.
	end
end

---------------------------------------------------------------------
-- Main render loop
---------------------------------------------------------------------

RunService.RenderStepped:Connect(function(dt)
	State.FrameCounter += 1
	if now() - State.LastFPS >= 1 then
		State.FPS = State.FrameCounter
		State.FrameCounter = 0
		State.LastFPS = now()
	end

	if S.AnimatedGradient then
		DimGradient.Rotation = (DimGradient.Rotation + dt * 8) % 360
	end

	if ParticleLayer.Visible then
		for p, data in pairs(Particles) do
			local pos = p.Position
			local ny = pos.Y.Scale - data.speed * dt * 60
			local nx = pos.X.Scale + data.drift * dt * 60
			if ny < -0.08 then
				ny = 1.08
				nx = math.random()
			end
			p.Position = UDim2.fromScale(nx, ny)
		end
	end
end)

RunService:BindToRenderStep("OfficialV4UltraMain", Enum.RenderPriority.Camera.Value + 1, function()
	Camera = workspace.CurrentCamera
	if not Camera then return end
	updateScale()

	TopButton.Visible = true
	PatternLayer.Visible = S.MenuOpen and S.Pattern
	ParticleLayer.Visible = S.MenuOpen and S.Particles
	Dim.BackgroundTransparency = S.DimTransparency
	Root.BackgroundTransparency = S.Glass
	if not S.Blur then Blur.Size = 0 end

	local accent = currentAccent()
	local best = chooseBestTarget()

	FOVCircle.Visible = S.ShowFOV and S.AimAssist
	FOVCircle.Size = UDim2.fromOffset(S.AimRadius * 2, S.AimRadius * 2)
	FOVStroke.Color = best and (State.LOS and S.ReadyColor or S.WallColor) or accent
	FOVStroke.Thickness = S.FOVThickness
	FOVFill.Visible = S.FOVFilled
	FOVFill.BackgroundColor3 = accent
	FOVFill.BackgroundTransparency = S.FOVFillTransparency

	MiniStatus.Visible = S.ShowMiniStatus
	if S.ShowMiniStatus then
		local txt = "Target: " .. safeName(State.Target) .. " | " .. math.floor(State.Confidence * 100) .. "% | LOS: " .. tostring(State.LOS) .. " | " .. State.Reason
		if S.ShowPerformance then txt ..= " | FPS: " .. tostring(State.FPS) end
		MiniStatus.Text = txt
		MiniStatus.BackgroundColor3 = best and (State.LOS and Color3.fromRGB(4, 35, 28) or Color3.fromRGB(42, 32, 12)) or Color3.fromRGB(10, 12, 20)
	end

	drawCrosshair()

	local shouldAim = S.AimAssist and S.AutoAim and (not S.HoldToAim or State.HoldingAim)
	if shouldAim and best and State.AimPosition and State.Confidence >= S.MinConfidence then
		if (not S.Deadzone) or State.ScreenDistance > S.DeadzoneRadius then
			local strength = S.AimStrength
			if S.DynamicSmoothing then
				local centerAlpha = 1 - clamp(State.ScreenDistance / math.max(S.AimRadius, 1), 0, 1)
				strength = S.MinAimStrength + centerAlpha * (S.MaxAimStrength - S.MinAimStrength)
				if S.NearCenterBoost then strength += centerAlpha * 0.08 end
				strength = clamp(strength, 0.01, 0.95)
			end
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, State.AimPosition), strength)
		end
	end

	if S.AutoFireRequest and S.AimAssist and not S.ManualCorrectionOnly then
		local t = now()
		local interval = 1 / math.max(1, S.FireRate)
		if S.BurstMode then
			if State.BurstLeft > 0 and t >= State.NextBurst then
				State.BurstLeft -= 1
				State.NextBurst = t + S.BurstDelay
				fireRequest()
			elseif State.BurstLeft <= 0 and t - State.LastFire >= interval then
				State.LastFire = t
				State.BurstLeft = S.BurstShots
				State.NextBurst = t
			end
		else
			if t - State.LastFire >= interval then
				State.LastFire = t
				fireRequest()
			end
		end
	end

	if S.Triggerbot and best and State.ScreenDistance <= S.FireCenterRadius then
		local t = now()
		if t - State.LastTrigger >= S.TriggerDelay then
			State.LastTrigger = t
			fireRequest()
		end
	end

	updateESP()
	updateDeathZoneESP()
end)

setMenu(S.MenuOpen)

---------------------------------------------------------------------
-- Weapon integration examples
---------------------------------------------------------------------

--[[
Example weapon LocalScript usage:

local player = game.Players.LocalPlayer
local fireEvent = player.PlayerGui:WaitForChild("OfficialV4UltraFireRequested")
local correction = player.PlayerGui:WaitForChild("OfficialV4UltraGetCorrectedAim")

fireEvent.Event:Connect(function(data)
    -- Use your normal official shoot function.
    -- The server must validate ammo, reload, cooldown, team, LOS, distance, damage, weapon equipped.
    -- WeaponController:TryShoot(data.aimPosition)
end)

local function getFinalAim(defaultAimPosition)
    local data = correction:Invoke(defaultAimPosition)
    if data then
        return data.aimPosition
    end
    return defaultAimPosition
end

-- Manual shot example:
-- local aim = getFinalAim(mouse.Hit.Position)
-- WeaponController:TryShoot(aim)
]]
