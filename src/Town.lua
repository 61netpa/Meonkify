local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({

	Title = 'Meonkify',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.175
})

Library:Notify('For best experience we recommend you to reset your character! (Optional)')

--// Storage

local X = {}
local Y = {}
local Z = {}
local VM = {}
local Material = Air
local MaterialColor = {}
local MM = {}
local LightingEnabled = {}
local CT = 24
local BrightnessValue = 2
local GS = false
local HF = {}
local FC = {}
local FCV = {}
local AmbientColor = {}
local Lighting = game:GetService("Lighting")
local WeaponMods = {
	Enabled = false
	R = {}
	AT = {}
	FR = {}
	RT = {}
	RE = {}
	AZM = {}
	ATE = {}
	FRE = {}
	RTE = {}
}
local WMR = {}
local WMAT = {}
local WMFR = {}
local WMRT = {}
local WMRE = {}
local WMAZM = {}
local WMATE = {}
local WMFRE = {}
local WMRTE = {}
local WMAZME = {}
local WhitelistedPlayers = {}
local Materials = {}
local AntiAim = {
	Enabled = false
	HH = {}
	PX = {}
	PY = {}
	PZ = {}
	RVX = {}
	RVY = {}
	RVZ = {}
	UVX = {}
	UVY = {}
	UVZ = {}
	LVX = {}
	LVY = {}
	LVZ = {}
}

--// Cache

local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// Preventing Multiple Processes

pcall(function()
	getgenv().TAimbot.Functions:Exit()
end)

--// Environment

getgenv().TAimbot = {}
local Environment = getgenv().TAimbot

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Variables

local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

--// Script Settings

Environment.Settings = {
	Enabled = false,
	TeamCheck = false,
	AliveCheck = false,
	WallCheck = false, -- Laggy
	WhitelistCheck = false,
	Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
	ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
	ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head" -- Body part to lock on
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = Color3.fromRGB(255, 255, 255),
	LockedColor = Color3.fromRGB(255, 70, 70),
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")

--// Functions

local function CancelLock()
	Environment.Locked = nil
	if Animation then Animation:Cancel() end
	Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

local function GetClosestPlayer()
	if not Environment.Locked then
		RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer then
				if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
					if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
					if Environment.Settings.AliveCheck and v.Character:FindFirstChild("Downed") then continue end
					if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end
					if Environment.Settings.WhitelistCheck then continue end

					local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
					local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

					if Distance < RequiredDistance and OnScreen then
						RequiredDistance = Distance
						Environment.Locked = v
					end
				end
			end
		end
	elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
		CancelLock()
	end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Main

local function Load()
	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
			Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
			Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
			Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
			Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
			Environment.FOVCircle.Color = Environment.FOVSettings.Color
			Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
			Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
			Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			Environment.FOVCircle.Visible = false
		end

		if Running and Environment.Settings.Enabled then
			GetClosestPlayer()

			if Environment.Locked then
				if Environment.Settings.ThirdPerson then
					Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

					local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
				else
					if Environment.Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
						Animation:Play()
					else
						Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
					end
				end

			Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor

			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not Environment.Settings.Toggle then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)

				pcall(function()
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

	getgenv().TAimbot.Functions = nil
	getgenv().TAimbot = nil
	
	Load = nil; GetClosestPlayer = nil; CancelLock = nil
end	

function Environment.Functions:Restart()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		Enabled = false,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
		ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head" -- Body part to lock on
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = Color3.fromRGB(255, 255, 255),
		LockedColor = Color3.fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
end

Load()

local PlayerDrawings = {}
local Utility = {}

local Workspace = game:GetService("Workspace")

getgenv().ESP = {
	Enabled = false,
	Box = false,
	Penis = false,
	Health = false,
	LookDir = false,
	Skeleton = false,
	Name = false,
	NameType = "Username",
	Indicators = {
		["Enabled"] = true,
		["Tools"] = false,
		["Distance"] = false
	},
	MaxDistance = 100000,
	OutOfFoV = {enemies = false, teammates = false, offset = 400, size = 15, settings = {Combo = {["outline"] = false, ["blinking"] = false}}},
	Enemies = true,
	Teammates = true,
	Font = "Flex",
	Surround = "none",
	BoxColor = Color3.fromRGB(255, 255, 255),
	HealthColor = Color3.new(0, 1, 0),
	NameColor = Color3.fromRGB(255, 255, 255),
	IndicatorsColor = Color3.fromRGB(255, 255, 255),
	EnemiesColor = Color3.fromRGB(255, 255, 255),
	TeammatesColor = Color3.fromRGB(255, 255, 255),
	PenisColor = Color3.fromRGB(255, 255, 255),
	LookDirColor = Color3.fromRGB(255, 255, 255),
	Connections = {},
	DestroyFunction = function()
		for A_1, A_2 in pairs(getgenv().ESP.Connections) do
			A_2:Disconnect()
			A_2 = nil
		end
		
		for A_1, A_2 in pairs(Players:GetPlayers()) do
			if PlayerDrawings[A_2] then
				for A_3, A_4 in pairs(PlayerDrawings[A_2]) do
					A_4:Remove()
				end
			end
		end
		
		getgenv().ESP = nil
	end
}
Utility.Settings = {
	Line = {
		Thickness = 1,
		Color = Color3.fromRGB(0, 255, 0)
	},
	Circle = {
		Radius = 15,
		Color = Color3.fromRGB(255, 255, 255),
		Filled = true,
		Thickness = 2
	},
	Text = {
		Size = 13,
		Center = true,
		Outline = true,
		Font = Drawing.Fonts.Plex,
		Color = Color3.fromRGB(255, 255, 255)
	},
	Square = {
		Thickness = 1,
		Color = ESP.BoxColor,
		Filled = false,
	},
	Triangle = {
		Color = Color3.fromRGB(255, 255, 255),
		Filled = true,
		Visible = false,
		Thickness = 1,
	}
}
function Utility.New(Type, Outline, Name)
	local drawing = Drawing.new(Type)
	for i, v in pairs(Utility.Settings[Type]) do
		drawing[i] = v
	end
	if Outline then
		drawing.Color = Color3.new(0,0,0)
		drawing.Thickness = 3
	end
	return drawing
end
function Utility.Add(Player)
	if not PlayerDrawings[Player] then
		PlayerDrawings[Player] = {
			Offscreen = Utility.New("Triangle", nil, "Offscreen"),
			Name = Utility.New("Text", nil, "Name"),
			Tool = Utility.New("Text", nil, "Tool"),
			Distance = Utility.New("Text", nil, "Distance"),
			BoxOutline = Utility.New("Square", true, "BoxOutline"),
			Box = Utility.New("Square", nil, "Box"),
			Ball1 = Utility.New("Circle", nil, "Ball1"),
			Ball2 = Utility.New("Circle", nil, "Ball2"),
			Stick = Utility.New("Line", nil, "Stick"),
			LookDir = Utility.New("Line", nil, "LookDir"),
			HealthOutline = Utility.New("Line", true, "HealthOutline"),
			Health = Utility.New("Line", nil, "Health")
		}
	end
end

for _, Player in pairs(Players:GetPlayers()) do	
	if Player ~= LocalPlayer then
		Utility.Add(Player)
	end
end
ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(Utility.Add)
ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
	if PlayerDrawings[Player] then
		for i,v in pairs(PlayerDrawings[Player]) do
			v:Remove()
		end

		PlayerDrawings[Player] = nil
	end
end)

local SurroundString = function(String, Add)
	local Left = ""
	local Right = ""
	
	if Add == "[]" then
		Left = "["
		Right = "]"
	elseif Add == "--" then
		Left = "-"
		Right = "-"
	elseif Add == "<>" then
		Left = "<"
		Right = ">"
	end

	return Left..String..Right
end

ESP.Connections.ESPLoop = RunService.RenderStepped:Connect(function()
	pcall(function()
	for _, Player in pairs(Players:GetPlayers()) do
		local PlayerDrawing = PlayerDrawings[Player]
		if not PlayerDrawing then continue end

		for _, Drawing in pairs(PlayerDrawing) do
			Drawing.Visible = false
		end

		local Character = Player.Character
		local RootPart, Humanoid = Character and Character:FindFirstChild("HumanoidRootPart"), Character and Character:FindFirstChildOfClass("Humanoid")
		if not Character or not RootPart or not Humanoid then continue end

		local DistanceFromCharacter = (Camera.CFrame.Position - RootPart.Position).Magnitude
		if ESP.MaxDistance < DistanceFromCharacter then continue end

		local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
		if not OnScreen then
			if Player.Team ~= LocalPlayer.Team and not ESP.OutOfFoV.enemies then continue end
			if Player.Team == LocalPlayer.Team and not ESP.OutOfFoV.teammates then continue end

			local RootPos = RootPart.Position
			local CameraVector = Camera.CFrame.Position
			local LookVector = Camera.CFrame.LookVector

			local Dot = LookVector:Dot(RootPart.Position - Camera.CFrame.Position)
			if Dot <= 0 then
				RootPos = (CameraVector + ((RootPos - CameraVector) - ((LookVector * Dot) * 1.01)))
			end

			local ScreenPos, OnScreen = Camera:WorldToScreenPoint(RootPos)
			if not OnScreen then
				local Drawing = PlayerDrawing.Offscreen
				local FOV     = 800 - ESP.OutOfFoV.offset -- Default: 400 --> 400
				local Size    = ESP.OutOfFoV.size -- Default: 15

				local Center = (Camera.ViewportSize / 2)
				local Direction = (Vector2(ScreenPos.X, ScreenPos.Y) - Center).Unit
				local Radian = math.atan2(Direction.X, Direction.Y)
				local Angle = (((math.pi * 2) / FOV) * Radian)
				local ClampedPosition = (Center + (Direction * math.min(math.abs(((Center.Y - FOV) / math.sin(Angle)) * FOV), math.abs((Center.X - FOV) / (math.cos(Angle)) / 2))))
				local Point = Vector2(math.floor(ClampedPosition.X - (Size / 2)), math.floor((ClampedPosition.Y - (Size / 2) - 15)))

				local function Rotate(point, center, angle)
					angle = math.rad(angle)
					local rotatedX = math.cos(angle) * (point.X - center.X) - math.sin(angle) * (point.Y - center.Y) + center.X
					local rotatedY = math.sin(angle) * (point.X - center.X) + math.cos(angle) * (point.Y - center.Y) + center.Y

					return Vector2(math.floor(rotatedX), math.floor(rotatedY))
				end

				local Rotation = math.floor(-math.deg(Radian)) - 47
				Drawing.PointA = Rotate(Point + Vector2(Size, Size), Point, Rotation)
				Drawing.PointB = Rotate(Point + Vector2(-Size, -Size), Point, Rotation)
				Drawing.PointC = Rotate(Point + Vector2(-Size, Size), Point, Rotation)
				Drawing.Color = Player.Team ~= LocalPlayer.Team and ESP.EnemiesColor or ESP.TeammatesColor

				Drawing.Filled = not ESP.OutOfFoV.settings.Combo.outline and true or false
				if ESP.OutOfFoV.settings.Combo.blinking then
					Drawing.Transparency = (math.sin(tick() * 5) + 1) / 2
				else
					Drawing.Transparency = 1
				end

				Drawing.Visible = true
			end
		else
			local VisualTable = Player.Team ~= LocalPlayer.Team and ESP.Enemies or ESP.Teammates

			local Size           = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
			local BoxSize        = Vector2(math.floor(Size * 1.5), math.floor(Size * 1.9))
			local BoxPos         = Vector2(math.floor(Pos.X - Size * 1.5 / 2), math.floor(Pos.Y - Size * 1.6 / 2))

			local Name           = PlayerDrawing.Name
			local Tool           = PlayerDrawing.Tool
			local Distance       = PlayerDrawing.Distance
			local Box            = PlayerDrawing.Box
			local Ball1			 = PlayerDrawing.Ball1
			local Ball2			 = PlayerDrawing.Ball2
			local Stick			 = PlayerDrawing.Stick
			local LookDir		 = PlayerDrawing.LookDir
			local BoxOutline     = PlayerDrawing.BoxOutline
			local Health         = PlayerDrawing.Health
			local HealthOutline  = PlayerDrawing.HealthOutline
			
			if not ESP.Enabled then continue end

			if ESP.Box then
				Box.Size = BoxSize
				Box.Position = BoxPos
				Box.Visible = true
				Box.Color = ESP.BoxColor
				Box.ZIndex = 1

				BoxOutline.Size = BoxSize
				BoxOutline.Position = BoxPos
				BoxOutline.Visible = true
				BoxOutline.ZIndex = 0
			end

			if ESP.Penis then
				local screenPos1 = Camera:WorldToViewportPoint(RootPart.Position + (RootPart.CFrame.RightVector * -0.2) + Vector3.new(0, -1, 0))
				local screenPos2 = Camera:WorldToViewportPoint(RootPart.Position + (RootPart.CFrame.RightVector * 0.2) + Vector3.new(0, -1, 0))
				local lineEndScreenPos = Camera:WorldToViewportPoint(RootPart.Position + (RootPart.CFrame.LookVector * 2.5) + Vector3.new(0, -1, 0))

				Ball1.Visible = true
				Ball1.Radius = 15
				Ball1.Thickness = 2
				Ball1.Filled = true

				Ball2.Visible = true
				Ball2.Radius = 15
				Ball2.Thickness = 2
				Ball2.Filled = true
				
				Stick.Visible = true
				Stick.Thickness = 5

				Ball1.Position = Vector2(screenPos1.X, screenPos1.Y)
				Ball2.Position = Vector2(screenPos2.X, screenPos2.Y)
				Stick.From = Vector2((screenPos1.X + screenPos2.X) / 2, (screenPos1.Y + screenPos2.Y) / 2)
				Stick.To = Vector2(lineEndScreenPos.X, lineEndScreenPos.Y)

				Ball1.Color = ESP.PenisColor
				Ball2.Color = ESP.PenisColor
				Stick.Color = ESP.PenisColor
			end

			if ESP.LookDir then
				if Character and Character:FindFirstChild("HumanoidRootPart") then
					local Head = Character:FindFirstChild("Head")

					if Head then
						local HeadPosition = Head.Position
						local HeadLookVector = Head.CFrame.LookVector

						local LineStartPos = Camera:WorldToViewportPoint(HeadPosition)
						local LineEndPos = Camera:WorldToScreenPoint(HeadPosition + (HeadLookVector * 5))

						LookDir.Visible = true
						LookDir.Thickness = 1
						LookDir.Color = ESP.LookDirColor

						LookDir.From = Vector2(LineStartPos.X, LineStartPos.Y)
						LookDir.To = Vector2(LineEndPos.X, LineEndPos.Y)
					end
				end
			end

			if ESP.Health then
				Health.From = Vector2((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
				Health.To = Vector2(Health.From.X, Health.From.Y - (Humanoid.Health / Humanoid.MaxHealth) * BoxSize.Y)
				Health.Color = ESP.HealthColor
				Health.Visible = true
				Health.ZIndex = 1

				HealthOutline.From = Vector2(Health.From.X, BoxPos.Y + BoxSize.Y + 1)
				HealthOutline.To = Vector2(Health.From.X, (Health.From.Y - 1 * BoxSize.Y) -1)
				HealthOutline.Visible = true
				HealthOutline.ZIndex = 0
			end

			if ESP.Name then
				local PlayerName = ""
				
				if ESP.NameType == "Username" then
					PlayerName = Player.Name
				else
					PlayerName = Player.DisplayName
				end
				
				Name.Text = SurroundString(PlayerName, ESP.Surround)
				Name.Position = Vector2(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
				Name.Color = ESP.NameColor
				Name.Font = Drawing.Fonts[ESP.Font]
				Name.Visible = true
			end

			if ESP.Indicators.Enabled then
				local BottomOffset = BoxSize.Y + BoxPos.Y + 1
				if ESP.Indicators.Tools then
					local EquippedTool = Player.Character:FindFirstChildOfClass("Tool")
					local Name = EquippedTool and EquippedTool.Name or "None"
					Name = SurroundString(Name, ESP.Surround)
					Tool.Text = Name
					Tool.Position = Vector2(BoxSize.X/2 + BoxPos.X, BottomOffset)
					Tool.Color = ESP.IndicatorsColor
					Tool.Font = Drawing.Fonts[ESP.Font]
					Tool.Visible = true
					BottomOffset = BottomOffset + 15
				end
				
				if ESP.Indicators.Distance then
					Distance.Text = SurroundString(math.floor(DistanceFromCharacter).."m", ESP.Surround)
					Distance.Position = Vector2(BoxSize.X/2 + BoxPos.X, BottomOffset)
					Distance.Color = ESP.IndicatorsColor
					Distance.Font = Drawing.Fonts[ESP.Font]
					Distance.Visible = true

					BottomOffset = BottomOffset + 15
				end
			end
		end
	end
	end)
end)

--Tabs
local Tabs = {
	Aimbot = Window:AddTab('Aimbot'),
	Visuals = Window:AddTab('Visuals'),
	Player = Window:AddTab('Player'),
	Misc = Window:AddTab('Misc'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

--Groups

local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox('Aimbot Settings')
local FOVGroup = Tabs.Aimbot:AddRightGroupbox('Fov Settings')
local ChecksGroup = Tabs.Aimbot:AddLeftGroupbox('Checks')

local PlayerESPGroup = Tabs.Visuals:AddLeftGroupbox('PlayerESP')
local OutOfFOVESPGroup = Tabs.Visuals:AddRightGroupbox('Out Of Fov')
local ViewModelGroup = Tabs.Visuals:AddRightGroupbox('ViewModel Changer')
local WeaponGroup = Tabs.Visuals:AddLeftGroupbox('Weapon Models')
local FOVChangerGroup = Tabs.Visuals:AddLeftGroupbox('FOV Changer')
local LightingGroup = Tabs.Visuals:AddRightGroupbox('Lighting Modifications')

local AntiAimGroup = Tabs.Player:AddRightGroupbox('Anti Aim')

local WeaponModsGroup = Tabs.Misc:AddLeftGroupbox('Weapon Mods')
local MiscGroup = Tabs.Misc:AddRightGroupbox('Misc')

AimbotGroup:AddToggle('AimbotEnableToggle', {
    Text = 'Enabled',
    Default = getgenv().TAimbot.Settings.Enabled,
    Tooltip = 'Enable/Disable Aimbot',

    Callback = function(Value)
        getgenv().TAimbot.Settings.Enabled = Value
    end
})

AimbotGroup:AddToggle('AimbotToggle', {
    Text = 'Toggle',
    Default = getgenv().TAimbot.Settings.Toggle,
    Tooltip = 'Toggles the aimbot instead of holding to use it',

    Callback = function(Value)
        getgenv().TAimbot.Settings.Toggle = Value
    end
})

AimbotGroup:AddDropdown('TargetPart', {
	Values = { 'Head', 'Torso', 'HumanoidRootPart', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg' },
	Default = getgenv().TAimbot.Settings.LockPart,
	Multi = false,

	Text = 'AimPart',
	Tooltip = 'AimPart of Aimbot',

	Callback = function(Value)
		getgenv().TAimbot.Settings.LockPart = Value
	end
})

AimbotGroup:AddSlider('Smoothness', {
    Text = 'Smoothness',
    Max = 1,
    Default = getgenv().TAimbot.Settings.Sensitivity,
    Min = 0,
    Rounding = 3,

    Callback = function(Value)
        getgenv().TAimbot.Settings.Sensitivity = Value
    end
})

ChecksGroup:AddToggle('WallCheck', {
	Text = 'Wall Check',
	Default = getgenv().TAimbot.Settings.WallCheck,
	Tooltip = 'Will not aim on people behind walls if enabled (laggy)',

	Callback = function(Value)
		getgenv().TAimbot.Settings.WallCheck = Value
	end
})

ChecksGroup:AddToggle('WallCheck', {
	Text = 'Alive Check',
	Default = getgenv().TAimbot.Settings.AliveCheck,
	Tooltip = 'Will not aim on people that are not alive',

	Callback = function(Value)
		getgenv().TAimbot.Settings.AliveCheck = Value
	end
})

FOVGroup:AddToggle('FOVToggle', {
    Text = 'Enabled',
    Default = getgenv().TAimbot.FOVSettings.Enabled,
    Tooltip = 'Enable/Disable FOV circle',

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Enabled = Value
    end
})

FOVGroup:AddToggle('FOVVisible', {
    Text = 'Visible',
    Default = getgenv().TAimbot.FOVSettings.Visible,
    Tooltip = 'Draws FoV',

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Visible = Value
    end
})

FOVGroup:AddToggle('FOVFilled', {
    Text = 'Filled',
    Default = getgenv().TAimbot.FOVSettings.Filled,
    Tooltip = 'Fills the FoV',

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Filled = Value
    end
})

FOVGroup:AddLabel('FOV Color'):AddColorPicker('FovColor', {
	Default = getgenv().TAimbot.FOVSettings.Color,
	Title = 'FOV Color',
	Transparency = nil,

	Callback = function(Value)
		getgenv().TAimbot.FOVSettings.Color = Value
	end
})

FOVGroup:AddLabel('FOV Locked Color'):AddColorPicker('FovLockedColor', {
	Default = getgenv().TAimbot.FOVSettings.LockedColor,
	Title = 'FOV Locked Color',
	Transparency = nil,

	Callback = function(Value)
		getgenv().TAimbot.FOVSettings.LockedColor = Value
	end
})

FOVGroup:AddSlider('FoV', {
    Text = 'FoV',
    Max = 1000,
    Default = getgenv().TAimbot.FOVSettings.Amount,
    Min = 0,
    Rounding = 0,

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Amount = Value
    end
})

FOVGroup:AddSlider('FoVSides', {
    Text = 'Sides',
    Max = 60,
    Default = getgenv().TAimbot.FOVSettings.Sides,
    Min = 0,
    Rounding = 0,

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Sides = Value
    end
})

FOVGroup:AddSlider('FoVVisibility', {
    Text = 'Visibility',
    Max = 1,
    Default = getgenv().TAimbot.FOVSettings.Transparency,
    Min = 0,
    Rounding = 3,

    Callback = function(Value)
        getgenv().TAimbot.FOVSettings.Transparency = Value
    end
})

PlayerESPGroup:AddToggle('ESPEnable', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable player ESP',

	Callback = function(Value)
		getgenv().ESP.Enabled = Value
	end
})

PlayerESPGroup:AddToggle('BoxESP', {
	Text = 'Box ESP',
	Default = false,
	Tooltip = 'Draws box around players',

	Callback = function(Value)
		getgenv().ESP.Box = Value
	end
}):AddColorPicker('BoxESPColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Box ESP color',
	Transparency = 0,

	Callback = function(Value)
		getgenv().ESP.BoxColor = Value
	end
})

PlayerESPGroup:AddToggle('NameESP', {
	Text = 'Name ESP',
	Default = false,
	Tooltip = 'Shows the username of the player',

	Callback = function(Value)
		getgenv().ESP.Name = Value
	end
}):AddColorPicker('NameESPColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Name ESP color',
	Transparency = 0,

	Callback = function(Value)
		getgenv().ESP.NameColor = Value
	end
})

PlayerESPGroup:AddToggle('Healthbar', {
	Text = 'HealthBar',
	Default = false,
	Tooltip = 'Shows the health of the player',

	Callback = function(Value)
		getgenv().ESP.Health = Value
	end
}):AddColorPicker('HealthbarColor', {
	Default = Color3.new(0, 1, 0),
	Title = 'HealthBar Color',
	Transparency = 0,

	Callback = function(Value)
		getgenv().ESP.HealthColor = Value
	end
})

PlayerESPGroup:AddToggle('ToolsESP', {
	Text = 'Tools',
	Default = false,
	Tooltip = 'Shows the tool of the player holding',

	Callback = function(Value)
		getgenv().ESP.Indicators["Tools"] = Value
	end
})

PlayerESPGroup:AddToggle('DistanceESP', {
	Text = 'Distance',
	Default = false,
	Tooltip = 'Shows the distance of the player',

	Callback = function(Value)
		getgenv().ESP.Indicators["Distance"] = Value
	end
})

PlayerESPGroup:AddLabel('Indicators color'):AddColorPicker('IndicatorsColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Indicators Color',
	Transparency = nil,

	Callback = function(Value)
		getgenv().ESP.IndicatorsColor = Value
	end
})

PlayerESPGroup:AddToggle('PenisESP', {
	Text = 'Penis',
	Default = false,
	Tooltip = 'Draw penis for everyone',

	Callback = function(Value)
		getgenv().ESP.Penis = Value
	end
}):AddColorPicker('PenisColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Penis Color',
	Transparency = nil,

	Callback = function(Value)
		getgenv().ESP.PenisColor = Value
	end
})

PlayerESPGroup:AddToggle('LookDirection', {
	Text = 'Look Direction',
	Default = false,
	Tooltip = 'Shows where every player is looking towards',

	Callback = function(Value)
		getgenv().ESP.LookDir = Value
	end
}):AddColorPicker('LookDirColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Look Direction Color',
	Transparency = nil,

	Callback = function(Value)
		getgenv().ESP.LookDirColor = Value
	end
})

PlayerESPGroup:AddSlider('MaxESPDistance', {
	Text = 'Max Distance',
	Min = 100,
	Default = 100000,
	Max = 200000,
	Rounding = 0,

	Callback = function(Value)
		getgenv().ESP.MaxDistance = Value
	end
})

PlayerESPGroup:AddDropdown('ESPUserType', {
	Values = { 'Username', 'DisplayName' },
	Default = 1,
	Multi = false,

	Text = 'Name ESP type',
	Tooltip = 'Change the name ESP type',

	Callback = function(Value)
		getgenv().ESP.NameType = Value
	end
})

PlayerESPGroup:AddDropdown('ESPTextSurround', {
	Values = { 'none', '[]', '--', '<>' },
	Default = 1,
	Multi = false,

	Text = 'Surround',
	Tooltip = 'surrounds the indicators with the icons',

	Callback = function(Value)
		getgenv().ESP.Surround = Value
	end
})

PlayerESPGroup:AddDropdown('ESPTextFont', {
	Values = { 'Flex', 'UI', 'System', 'Monospace' },
	Default = 1,
	Multi = false,

	Text = 'Text Font',
	Tooltip = 'Changes the font of the Texts on the ESP',

	Callback = function(Value)
		getgenv().ESP.Font = Value
	end
})

OutOfFOVESPGroup:AddToggle('OutOfFOVESPToggle', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Shows arrows to people outside of your screen',

	Callback = function(Value)
		getgenv().ESP.OutOfFoV.teammates = Value
		getgenv().ESP.OutOfFoV.enemies = Value
	end
})

OutOfFOVESPGroup:AddToggle('OFVOutline', {
	Text = 'Outline',
	Default = false,
	Tooltip = 'honestly idk',

	Callback = function(Value)
		getgenv().ESP.OutOfFoV.settings.Combo.outline = Value
	end
})

OutOfFOVESPGroup:AddToggle('OFVBlinking', {
	Text = 'Blinking',
	Default = true,
	Tooltip = 'honestly idk',

	Callback = function(Value)
		getgenv().ESP.OutOfFoV.settings.Combo.blinking = Value
	end
})

OutOfFOVESPGroup:AddSlider('OFVOffset', {
	Text = 'Offset',
	Max = 1000,
	Min = 10,
	Default = 400,
	Rounding = 0,

	Callback = function(Value)
		getgenv().ESP.OutOfFoV.offset = Value
	end
})

OutOfFOVESPGroup:AddSlider('OFVSize', {
	Text = 'Size',
	Max = 50,
	Min = 0,
	Default = 15,
	Rounding = 0,

	Callback = function(Value)
		getgenv().ESP.OutOfFoV.size = Value
	end
})

ViewModelGroup:AddToggle('VMToggle', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable ViewModel Changer',

	Callback = function(Value)
		VM = Value
	end
})

ViewModelGroup:AddSlider('VMX', {
	Text = 'Viewmodel offset X',
	Max = 10,
	Default = 1,
	Min = -10,
	Rounding = 3,

	Callback = function(Value)
		X = Value
	end
})

ViewModelGroup:AddSlider('VMY', {
	Text = 'Viewmodel offset Y',
	Max = 10,
	Default = 0,
	Min = -10,
	Rounding = 3,

	Callback = function(Value)
		Y = Value
	end
})

ViewModelGroup:AddSlider('VMZ', {
	Text = 'Viewmodel offset Z',
	Max = 10,
	Default = 0,
	Min = -10,
	Rounding = 3,

	Callback = function(Value)
		Z = Value
	end
})

LocalPlayer.CharacterAdded:Connect(function()
	if LocalPlayer.Character then
		LocalPlayer.Character.ChildAdded:Connect(function()
			if VM == true then
				for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
					if tool:IsA("Tool") and tool:FindFirstChild("ViewModelOffset") then
						wait(0.05)
						tool.ViewModelOffset.Value = Vector3.new(X, Y, Z)
						Options.VMX:OnChanged(function()
							tool.ViewModelOffset.Value = Vector3.new(X, Y, Z)
						end)
						Options.VMY:OnChanged(function()
							tool.ViewModelOffset.Value = Vector3.new(X, Y, Z)
						end)
						Options.VMZ:OnChanged(function()
							tool.ViewModelOffset.Value = Vector3.new(X, Y, Z)
						end)
					end
				end
			end
		end)
	end
end)

WeaponGroup:AddToggle('WeaponModelToggle', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable weapon model edit',

	Callback = function(Value)
		MM = Value
	end
})

for _, Materials in ipairs(Enum.Material:GetEnumItems()) do
    table.insert(Materials, material.Name)
end

WeaponGroup:AddDropdown('WeaponMaterial', {
	Values = Materials,
	Default = 1,
	Multi = false,

	Text = 'Material',
	Tooltip = 'The material of the weapon',

	Callback = function(Value)
		Material = Value
	end
})

WeaponGroup:AddLabel('MaterialColor'):AddColorPicker('WeaponMaterialColor', {
	Default = Color3.new(1, 1, 1),
	Title = 'Material Color',
	Transparency = 0,

	Callback = function(Value)
		MaterialColor = Value
	end
})

function WeaponModel(weapon)
	for _, descendant in ipairs(weapon:GetDescendants()) do
		if descendant:IsA("SurfaceAppearance") then
			descendant:Destroy()
		elseif descendant:IsA("MeshPart") and descendant.TextureID ~= "" then
			descendant.TextureID = ""
		end
		if descendant:IsA("MeshPart") or descendant:IsA("Part") then
			descendant.Material = Material
			descendant.Color = MaterialColor
		end
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if LocalPlayer.Character then
		LocalPlayer.Character.ChildAdded:Connect(function(tool)
			if MM == true then
				if tool:IsA("Tool") then
					WeaponModel(tool)
				end
			end
		end)
	end
end)

FOVChangerGroup:AddToggle('FOVChangerEnabled', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Changes the camera Field Of View',

	Callback = function(Value)
		FC = Value
	end
})

FOVChangerGroup:AddSlider('FOVCS', {
	Text = 'FOV Value',
	Max = 120,
	Min = 30,
	Default = 70,
	Rounding = 1,

	Callback = function(Value)
		FCV = Value
	end
})

RunService.RenderStepped:Connect(function()
	if FC == true then
		Camera.FieldOfView = FCV
	end
end)
LightingGroup:AddToggle('LightingToggle', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable lighting modifications',

	Callback = function(Value)
		LightingEnabled = Value
	end
})

LightingGroup:AddToggle('LShadowsToggle', {
	Text = 'Shadows',
	Default = false,
	Tooltip = 'Enable/Disable Shadows',

	Callback = function(Value)
		GS = Value
	end
})

LightingGroup:AddButton({
	Text = 'No fog',
	Func = function()
		Lighting.FogEnd = 100000
		for i,v in pairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end,
	Tooltip = 'Removes fog',
	DoubleClick = false
})

LightingGroup:AddSlider('LTime', {
	Text = 'Time',
	Max = 24,
	Default = 14,
	Min = 0,
	Rounding = 1,

	Callback = function(Value)
		CT = Value
	end
})

LightingGroup:AddSlider('LBrightness', {
	Text = 'Brightness',
	Max = 10,
	Default = 2,
	Min = 0,
	Rounding = 2,

	Callback = function(Value)
		BrightnessValue = Value
	end
})

LightingGroup:AddLabel('Ambient Color'):AddColorPicker('LAmbientColor', {
	Default = Color3.new(0.502, 0.502, 0.502),
	Title = 'Ambient Color',
	Transparency = nil,

	Callback = function(Value)
		AmbientColor = Value
	end
})

if LightingLoop then
	LightingLoop:Disconnect()
end
function ChangeLighting()
	if LightingEnabled == true then
		Lighting.Brightness = BrightnessValue
		Lighting.ClockTime = CT
		Lighting.GlobalShadows = Shadows
		Lighting.OutdoorAmbient = AmbientColor
	end
end

LightingLoop = RunService.RenderStepped:Connect(ChangeLighting)

AntiAimGroup:AddToggle('AntiAimToggle', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable anti aim',

	Callback = function(Value)
		AntiAim.Enabled = Value
	end
})

AntiAimGroup:AddSlider('AntiAimPositionX', {
	Text = 'CFrame Position X',
	Max = 50000,
	Default = 0,
	Min = -50000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.PX = Value
	end
})

AntiAimGroup:AddSlider('AntiAimPositionY', {
	Text = 'CFrame Position Y',
	Max = 50000,
	Default = 0,
	Min = -50000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.PY = Value
	end
})

AntiAimGroup:AddSlider('AntiAimPositionZ', {
	Text = 'CFrame Position Z',
	Max = 50000,
	Default = 0,
	Min = -50000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.PZ = Value
	end
})

AntiAimGroup:AddSlider('AntiAimRightVectorX', {
	Text = 'CFrame RightVector X',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.RVX = Value
	end
})

AntiAimGroup:AddSlider('AntiAimRightVectorY', {
	Text = 'CFrame RightVector Y',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.RVY = Value
	end
})

AntiAimGroup:AddSlider('AntiAimRightVectorZ', {
	Text = 'CFrame RightVector Z',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.RVZ = Value
	end
})

AntiAimGroup:AddSlider('AntiAimUpVectorX', {
	Text = 'CFrame UpVector X',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.UVX = Value
	end
})

AntiAimGroup:AddSlider('AntiAimUpVectorY', {
	Text = 'CFrame UpVector Y',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.UVY = Value
	end
})

AntiAimGroup:AddSlider('AntiAimUpVectorZ', {
	Text = 'CFrame UpVector Z',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.UVZ = Value
	end
})

AntiAimGroup:AddSlider('AntiAimLookVectorX', {
	Text = 'CFrame LookVector X',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.LVX = Value
	end
})

AntiAimGroup:AddSlider('AntiAimLookVectorY', {
	Text = 'CFrame LookVector Y',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,

	Callback = function(Value)
		AntiAim.LVY = Value
	end
})

AntiAimGroup:AddSlider('AntiAimLookVectorZ', {
	Text = 'CFrame LookVector Z',
	Max = 10000,
	Default = 0,
	Min = -10000,
	Rounding = 0,
	
	Callback = function(Value)
		AntiAim.LVZ = Value
	end
})

LocalPlayer.CharacterAdded:Connect(function()
	if LocalPlayer.Character then
		Toggles.AntiAimToggle:OnChanged(function()
			getgenv().AntiAim = RunService.RenderStepped:Connect(function()
				if AntiAim.Enabled == true then					
					game:GetService("ReplicatedStorage"):WaitForChild("CameraEvent"):FireServer({CFrame.new(AntiAim.PX, AntiAim.PY, AntiAim.PZ, AntiAim.RVX, AntiAim.RVY, AntiAim.RVZ, AntiAim.UVX, AntiAim.UVY, AntiAim.UVZ, AntiAim.LVX, AntiAim.LVY, AntiAim.LVZ), 0, 0.01, true, CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) })
				end
			end)
		end)
	end
end)

WeaponModsGroup:AddToggle('WeaponModsEnabled', {
	Text = 'Enabled',
	Default = false,
	Tooltip = 'Enable/Disable weapon mods',

	Callback = function(Value)
		WeaponMods.Enabled = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddToggle('WeaponModsRecoil', {
	Text = 'Recoil',
	Default = false,
	Tooltip = 'Change the recoil of the weapons',

	Callback = function(Value)
		WeaponMods.RE = Value
	end
})

WeaponModsGroup:AddSlider('WeaponModsRecoilValue', {
	Text = 'Recoil Value',
	Max = 3,
	Min = 0,
	Default = 0,
	Rounding = 2,

	Callback = function(Value)
		WeaponMods.R = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddToggle('WeaponModsAimTime', {
	Text = 'Aim Time',
	Default = false,
	Tooltip = 'Change the time of aiming in',

	Callback = function(Value)
		WeaponMods.ATE = Value
	end
})

WeaponModsGroup:AddSlider('WeaponModsAimTimeValue', {
	Text = 'Aim Time Value',
	Max = 1,
	Min = 0,
	Default = 0,
	Rounding = 2,

	Callback = function(Value)
		WeaponMods.AT = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddToggle('WeaponModsFireRate', {
	Text = 'Fire Rate',
	Default = false,
	Tooltip = 'Change the weapon firerate (lower = faster)',

	Callback = function(Value)
		WeaponMods.FRE = Value
	end
})

WeaponModsGroup:AddSlider('WeaponModsFireRateValue', {
	Text = 'Fire Rate Value',
	Max = 1,
	Min = 0,
	Default = 0,
	Rounding = 2,

	Callback = function(Value)
		WeaponMods.FR = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddToggle('WeaponModsReloadTimeRate', {
	Text = 'Reload Time',
	Default = false,
	Tooltip = 'Change the weapon reload time',

	Callback = function(Value)
		WeaponMods.RTE = Value
	end
})

WeaponModsGroup:AddSlider('WeaponModsReloadTimeValue', {
	Text = 'Reload Time Value',
	Max = 1,
	Min = 0.0001,
	Default = 0,
	Rounding = 4,

	Callback = function(Value)
		WeaponMods.RT = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddToggle('WeaponModsAimMulti', {
	Text = 'Aim Zoom Multiplier',
	Default = false,
	Tooltip = 'Change the weapon reload time',

	Callback = function(Value)
		WeaponMods.AZME = Value
	end
})

WeaponModsGroup:AddSlider('WeaponModsAimMultiValue', {
	Text = 'Aim Zoom Multiplier Value',
	Max = 1,
	Min = 0.0001,
	Default = 0,
	Rounding = 4,

	Callback = function(Value)
		WeaponMods.AZM = Value
	end
})

WeaponModsGroup:AddDivider()

WeaponModsGroup:AddLabel('Put just 1 attachment for')
WeaponModsGroup:AddLabel('it to work')

function WeaponMods(weapon)
	for _, children in ipairs(weapon.AttachmentFolder:GetChildren()) do
		if children:IsA("Tool") then
			local modfolder = children:FindFirstChild("Stats")

			if modfolder ~= nil then
				if WeaponMods.RE == true then
					if modfolder:FindFirstChild("GunRecoil") then
						modfolder:FindFirstChild("GunRecoil"):Destroy()
					end
					if modfolder:FindFirstChild("GunRecoilX") then
						modfolder:FindFirstChild("GunRecoilX"):Destroy()
					end	
					wait(0.01)
					local customrecoil = Instance.new("NumberValue", modfolder)
					customrecoil.Value = WeaponMods.R
					customrecoil.Name = "GunRecoil"
					local customrecoilX = Instance.new("NumberValue", modfolder)
					customrecoilX.Value = WeaponMods.R
					customrecoilX.Name = "GunRecoilX"
					Options.WeaponModsRecoilValue:OnChanged(function()
						customrecoil.Value = WeaponMods.R
						customrecoilX.Value = WeaponMods.R
					end)
				end
				if WeaponMods.ATE == true then
					if modfolder:FindFirstChild("AimTime") then
						modfolder:FindFirstChild("AimTime"):Destroy()
					end
					wait(0.01)
					local customaimtime = Instance.new("NumberValue", modfolder)
					customaimtime.Value = WeaponMods.AT
					customaimtime.Name = "AimTime"
					Options.WeaponModsAimTimeValue:OnChanged(function()
						customaimtime.Value = WeaponMods.AT
					end)
				end
				if WeaponMods.FRE == true then
					if modfolder:FindFirstChild("waittime") then
						modfolder:FindFirstChild("waittime"):Destroy()
					end
					wait(0.01)
					local customfirerate = Instance.new("NumberValue", modfolder)
					customfirerate.Value = WeaponMods.FR
					customfirerate.Name = "waittime"
					Options.WeaponModsFireRateValue:OnChanged(function()
						customfirerate.Value = WeaponMods.FR
					end)
				end
				if WeaponMods.RTE == true then
					if modfolder:FindFirstChild("ReloadSpeed") then
						modfolder:FindFirstChild("ReloadSpeed"):Destroy()
					end
					wait(0.01)
					local customreloadtime = Instance.new("NumberValue", modfolder)
					customreloadtime.Value = WeaponMods.RT
					customreloadtime.Name = "ReloadSpeed"
					Options.WeaponModsReloadTimeValue:OnChanged(function()
						customreloadtime.Value = WeaponMods.RT
					end)
				end
			end
		end
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if LocalPlayer.Character then
		LocalPlayer.Character.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") then
				if WeaponMods.Enabled == true then
					WeaponMods(tool)
				end				
			end
		end)
	end
end)

MiscGroup:AddToggle('NoAmbientNoise', {
	Text = 'No Ambient Noise',
	Default = false,
	Tooltip = 'Mutes/Unmutes the ambient noise',

	Callback = function(Value)
		if Value == true then
			
		end
	end
})

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Meonkify | %s fps | %s ms | Game: Town'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

--UI Settings not recommended to touch if you aint gonna destroy drawings with unload

Library:OnUnload(function()
	Library.Unloaded = true
    getgenv().TAimbot.Functions:Exit()
	WatermarkConnection:Disconnect()
	ESP.DestroyFunction()
	VM = false
	MM = false
	LightingLoop:Disconnect()
	AA = false
	WeaponMods = false
	FC = false
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
local Overlays = Tabs['UI Settings']:AddRightGroupbox('Overlays')

Overlays:AddToggle('KeybindsOverlay', {
	Text = 'Keybinds',
	Default = false,
	Tooltip = 'Shows a list with your keybinds',

	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end
})

Overlays:AddToggle('WatermarkOverlay', {
	Text = 'Watermark',
	Default = true,
	Tooltip = 'Enable/Disable watermark',

	Callback = function(Value)
		Library:SetWatermarkVisibility(Value)
	end
})

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library) 

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('Meonkify/Themes')
SaveManager:SetFolder('Meonkify/Town')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
