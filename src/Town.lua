-- Made by netpa with love. It was fun making this script. Also you are NOT allowed to completely copy and paste this code and claiming it as your own.
-- Thanks to legitimate0x1 for helping me out on this! This would be so bad if he wouldn't help. :skull:
-- If your executor has hookmetamethod, don't forget to execute an adonis bypass script.
-- Also I quit playing Roblox meaning I'm updating this without testing them on an actual exploit and the game itself. If there are issues I probably won't fix it since as I mentioned, I don't play Roblox and exploit on it anymore.

local StartTick = tick()

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local CloneReference = cloneref or function(Ins) return Ins end

local MarketplaceService = CloneReference(game:GetService("MarketplaceService"))
local ReplicatedStorage = CloneReference(game:GetService("ReplicatedStorage"))
local UserInputService = CloneReference(game:GetService("UserInputService"))
local TweenService = CloneReference(game:GetService("TweenService"))
local RunService = CloneReference(game:GetService("RunService"))
local Workspace = CloneReference(game:GetService("Workspace"))
local Lighting = CloneReference(game:GetService("Lighting"))
local Players = CloneReference(game:GetService("Players"))
local Stats = CloneReference(game:GetService("Stats"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RenderStepped = RunService.RenderStepped
local WaitForSomeone = RenderStepped.Wait
local Debug = function() print(debug.info(2, "l")) end
local Olds = { Ambient = Lighting.OutdoorAmbient }
local Jitter = false
local PlayerDrawings = {}
local Utility = {}
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

getgenv().Meonkify = {
	Combat = {
		Aimbot = {
			Enabled = false,
			Smoothness = 0,
			StickyAim = true,
			TargetPart = "Head",
			FOV = {
				Visible = true,
				Color = Color3.fromRGB(255, 255, 255),
				ChangeColor = false,
				ChangedColor = Color3.fromRGB(255, 54, 54),
			},
			Checks = {
				AliveCheck = false,
				VisibleCheck = false,
				ForceFieldCheck = false
			},
			Radius = 90,
			Targeted = nil,
			KeyPressed = false,
			Tween = nil
		},
		SilentAim = {
			Enabled = false,
			TargetPart = "Head",
			Radius = 90,
			FOV = {
				Visible = true,
				Color = Color3.fromRGB(255, 255, 255)
			},
			Checks = {
				AliveCheck = false,
				VisibleCheck = false,
				ForceFieldCheck = false
			},
		},
		AntiAim = {
			Enabled = false,
			Yaw = 0,
			YawJitter = 0,
			Pitch = 0,
			PitchJitter = 0,
			Offset = "World"
		},
		GunMods = {
			Enabled = false,
			Recoil = {
				Enabled = false,
				Value = 0
			},
			AimFOV = {
				Enabled = false,
				Value = 70
			},
			ReloadTime = {
				Enabled = false,
				Value = 0.0001
			},
			FireRate = {
				Enabled = false,
				Value = 0
			},
			AimTime = {
				Enabled = false,
				Value = 0
			},
			Mode = "require"       
		}
	},
	Visuals = {
		ESP = {
			Enabled = false,
			Box = false,
			BoxColor = Color3.fromRGB(255, 255, 255),
			HealthBar = false,
			HealthBarColor = Color3.fromRGB(0, 255, 0),
			Name = false,
			NameColor = Color3.fromRGB(255, 255, 255),
			NameMode = "Username",
			Tool = false,
			ToolColor = Color3.fromRGB(255, 255, 255),
			Distance =  false,
			DistanceColor = Color3.fromRGB(255, 255, 255),
			Font = "Plex",
			MaxDistance = 100000
		},
		ViewModel = {
			Enabled = false,
			XOffset = 0,
			YOffset = 0,
			ZOffset = 0
		},
		WeaponModel = {
			Enabled = false,
			Color = Color3.fromRGB(255, 255, 255),
			Material = "ForceField"
		}
	},
	World = {
		Enabled = false,
		Clock = false,
		ClockTime = 14,
		Ambient = false,
		AmbientColor = Color3.fromRGB(128, 128, 128),
		Brightness = false,
		BrightnessValue = 2
	},
	Misc = {
		PlayerUtilities = {
			Target = nil,
			LoopKill = false,
			LoopKillAll = false,
			LoopKillOthers = false
		},
		LocalPlayer = {
			FastHeal = false,
			AutoSelfRevive = false,
			AutoSelfReviveMode = 'RenderStepped'
		},
		HealAura = {
			Enabled = false,
			Range = 50,
			Mode = "Blacklist",
			PlayerList = {}
		},
		PenisGunTool = nil
	},
	Connections = {}
}
local Meonkify = getgenv().Meonkify
local CombatEnv = Meonkify.Combat
local AimbotEnv = CombatEnv.Aimbot
local SilentAimEnv = CombatEnv.SilentAim
local AntiAimEnv = CombatEnv.AntiAim
local GunModsEnv = CombatEnv.GunMods
local VisualsEnv = Meonkify.Visuals
local ESPEnv = VisualsEnv.ESP
local ViewModelEnv = VisualsEnv.ViewModel
local WeaponmodelEnv = VisualsEnv.WeaponModel
local WorldEnv = Meonkify.World
local MiscEnv = Meonkify.Misc
local PlayerUtilitiesEnv = MiscEnv.PlayerUtilities
local LocalPlayerEnv = MiscEnv.LocalPlayer
local HealAuraEnv = MiscEnv.HealAura
local Connections = Meonkify.Connections
local Options = getgenv().Options -- Studio testing too lazy to remove it :speaking_head:
local Toggles = getgenv().Toggles -- Studio testing too lazy to remove it :speaking_head:

AimbotEnv.FOVCircle = Drawing.new("Circle")
AimbotEnv.FOVCircle.Filled = false
AimbotEnv.FOVCircle.Thickness = 1

SilentAimEnv.FOVCircle = Drawing.new("Circle")
SilentAimEnv.FOVCircle.Filled = false
SilentAimEnv.FOVCircle.Thickness = 1

local AimbotRequiredDistance = AimbotEnv.Radius
local SilentAimRequiredDistance = SilentAimEnv.Radius

function EndAimbot() -- I couldn't find a better name for this lmao. KILL AIMBOT!!! 💀💀💀💀
	AimbotEnv.Targeted = nil
	if AimbotEnv.Tween ~= nil then
		AimbotEnv.Tween:Cancel()
	end
end

function AimbotGetClosestPlayer()  -- This is the most unoptimized GetClosestPlayer you will ever see.
	if AimbotEnv.StickyAim then
		if not AimbotEnv.Targeted then
			AimbotRequiredDistance = AimbotEnv.Radius
			for _, v in next, Players:GetPlayers() do
				local Character = v.Character
				local Downed = Character and Character:FindFirstChild("Downed")
				local TargetPart = Character and Character:FindFirstChild(AimbotEnv.TargetPart)
				local ForceField = Character and Character:FindFirstChildOfClass("ForceField")
				if v ~= LocalPlayer and Character and TargetPart ~= nil then
					if AimbotEnv.Checks.AliveCheck and Downed ~= nil then continue end
					if AimbotEnv.Checks.VisibleCheck then local VCR = Ray.new(Camera.CFrame.Position, (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position)); local IsObstructed = Workspace:FindPartOnRayWithIgnoreList(VCR, {LocalPlayer.Character, v.Character}); if IsObstructed then continue end end
					if AimbotEnv.Checks.ForceFieldCheck and ForceField ~= nil then continue end
					local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
					local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
					if Distance < AimbotRequiredDistance and OnScreen then
						AimbotRequiredDistance = Distance
						AimbotEnv.Targeted = v
					end
				end
			end
		end
	else
		AimbotRequiredDistance = AimbotEnv.Radius
		for _, v in next, Players:GetPlayers() do
			local Character = v.Character
			local Downed = Character and Character:FindFirstChild("Downed")
			local TargetPart = Character and Character:FindFirstChild(AimbotEnv.TargetPart)
			local ForceField = Character and Character:FindFirstChildOfClass("ForceField")
			if v ~= LocalPlayer and Character and TargetPart ~= nil then
				if AimbotEnv.Checks.AliveCheck and Downed ~= nil then continue end
				if AimbotEnv.Checks.VisibleCheck then local VCR = Ray.new(Camera.CFrame.Position, (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position)); local IsObstructed = Workspace:FindPartOnRayWithIgnoreList(VCR, {LocalPlayer.Character, v.Character}); if IsObstructed then continue end end
				if AimbotEnv.Checks.ForceFieldCheck and ForceField ~= nil then continue end
				local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
				local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
				if Distance < AimbotRequiredDistance and OnScreen then
					AimbotRequiredDistance = Distance
					AimbotEnv.Targeted = v
				end
			end
		end
	end
	if AimbotEnv.Targeted ~= nil then
		if (not Players:FindFirstChild(AimbotEnv.Targeted.Name) or (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Camera:WorldToViewportPoint(AimbotEnv.Targeted.Character[AimbotEnv.TargetPart].Position).X, Camera:WorldToViewportPoint(AimbotEnv.Targeted.Character[AimbotEnv.TargetPart].Position).Y)).Magnitude > AimbotEnv.Radius) then
			EndAimbot()
		elseif AimbotEnv.Checks.VisibleCheck then
			local VCR = Ray.new(Camera.CFrame.Position, (AimbotEnv.Targeted.Character.HumanoidRootPart.Position - Camera.CFrame.Position))
			local IsObstructed = Workspace:FindPartOnRayWithIgnoreList(VCR, {LocalPlayer.Character, AimbotEnv.Targeted.Character})
			if IsObstructed then EndAimbot() end
		end
	end
end

function SilentAimGetClosestPlayer()
	local Target = nil
	SilentAimRequiredDistance = SilentAimEnv.Radius
	for _, v in next, Players.GetPlayers(Players) do
		local Character = v.Character
		local Downed = Character and Character.FindFirstChild(Character, "Downed")
		local TargetPart = Character and Character.FindFirstChild(Character, SilentAimEnv.TargetPart)
		local ForceField = Character and Character.FindFirstChildOfClass(Character, "ForceField")
		if v ~= LocalPlayer and Character and TargetPart ~= nil then
			if SilentAimEnv.Checks.AliveCheck and Downed ~= nil then continue end
			if SilentAimEnv.Checks.VisibleCheck then local VCR = Ray.new(Camera.CFrame.Position, (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position)); local IsObstructed = Workspace.FindPartOnRayWithIgnoreList(Workspace, VCR, {LocalPlayer.Character, Character}); if IsObstructed then continue end end
			if SilentAimEnv.Checks.ForceFieldCheck and ForceField ~= nil then continue end
			local Vector, OnScreen = Camera.WorldToScreenPoint(Camera, TargetPart.Position)
			local Distance = (Vector2.new(UserInputService.GetMouseLocation(UserInputService).X, UserInputService.GetMouseLocation(UserInputService).Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
			if Distance < SilentAimRequiredDistance and OnScreen then
				SilentAimRequiredDistance = Distance
				Target = v
			end
		end
	end
	return Target
end

function GunMods(Weapon)
	local SettingsModule = Weapon and Weapon:FindFirstChild("Settings")
	local AttachmentsFolder = Weapon and Weapon:FindFirstChild("AttachmentFolder")
	if GunModsEnv.Mode == "require" and SettingsModule ~= nil then
		local Module = require(SettingsModule)
		if GunModsEnv.Recoil.Enabled then
			Module.GunRecoil = GunModsEnv.Recoil.Value
			Module.GunRecoilX = GunModsEnv.Recoil.Value
		end
		if GunModsEnv.AimFOV.Enabled then
			Module.AimFov = GunModsEnv.AimFOV.Value
		end
		if GunModsEnv.ReloadTime.Enabled then
			Module.ReloadSpeed = GunModsEnv.ReloadTime.Value
			Module.ReloadSpeed2 = GunModsEnv.ReloadTime.Value
		end
		if GunModsEnv.FireRate.Enabled then
			Module.waittime = GunModsEnv.FireRate.Value
		end
		if GunModsEnv.AimTime.Enabled then
			Module.AimSpeed = GunModsEnv.AimTime.Value
		end
	elseif GunModsEnv.Mode == "Attachments" and AttachmentsFolder ~= nil then
		for _, v in pairs(AttachmentsFolder:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("Stats") ~= nil then
				if GunModsEnv.Recoil.Enabled then
					if v.Stats:FindFirstChild("GunRecoil") ~= nil then v.Stats.GunRecoil:Remove() end
					if v.Stats:FindFirstChild("GunRecoilX") ~= nil then v.Stats.GunRecoilX:Remove() end
					local GunRecoilValue = Instance.new("NumberValue")
					local GunRecoilXValue = Instance.new("NumberValue")
					GunRecoilValue.Name = "GunRecoil"
					GunRecoilValue.Parent = v.Stats
					GunRecoilValue.Value = GunModsEnv.Recoil.Value
					GunRecoilXValue.Name = "GunRecoilX"
					GunRecoilXValue.Parent = v.Stats
					GunRecoilXValue.Value = GunModsEnv.Recoil.Value
				end
				if GunModsEnv.AimFOV.Enabled then
					if v.Stats:FindFirstChild("AimFov") ~= nil then v.Stats.AimFov:Remove() end
					local AimFOVValue = Instance.new("NumberValue")
					AimFOVValue.Parent = v.Stats
					AimFOVValue.Name = "AimFov"
					AimFOVValue.Value = GunModsEnv.AimFOV.Value
				end
				if GunModsEnv.ReloadTime.Enabled then
					if v.Stats:FindFirstChild("ReloadSpeed") ~= nil then v.Stats.ReloadSpeed:Remove() end
					if v.Stats:FindFirstChild("ReloadSpeed2") ~= nil then v.Stats.ReloadSpeed2:Remove() end
					local ReloadSpeedValue = Instance.new("NumberValue")
					local ReloadSpeed2Value = Instance.new("NumberValue")
					ReloadSpeedValue.Value = GunModsEnv.ReloadTime.Value
					ReloadSpeedValue.Parent = v.Stats
					ReloadSpeedValue.Name = "ReloadSpeed"
					ReloadSpeed2Value.Value = GunModsEnv.ReloadTime.Value
					ReloadSpeed2Value.Parent = v.Stats
					ReloadSpeed2Value.Name = "ReloadSpeed2"
				end
				if GunModsEnv.FireRate.Enabled then
					if v.Stats:FindFirstChild("waittime") ~= nil then v.Stats.waittime:Remove() end
					local waittimeValue = Instance.new("NumberValue")
					waittimeValue.Parent = v.Stats
					waittimeValue.Value = GunModsEnv.FireRate.Value
					waittimeValue.Name = "waittime"
				end
				if GunModsEnv.AimTime.Enabled then
					if v.Stats:FindFirstChild("AimSpeed") ~= nil then v.Stats.AimSpeed:Remove() end
					local AimSpeedValue = Instance.new("NumberValue")
					AimSpeedValue.Parent = v.Stats
					AimSpeedValue.Value = GunModsEnv.AimTime.Value
					AimSpeedValue.Name = "AimSpeed"
				end
			end
		end
	end
end

function Kill(PlayerName)
	if LocalPlayer.Character and Players:FindFirstChild(PlayerName) ~= nil then
		local Player = Players[PlayerName]
		local Character = Player.Character
		local ForceField = Character and Character:FindFirstChildOfClass("ForceField")
		local Head = Character and Character:FindFirstChild("Head")
		local AK47 = LocalPlayer.Character:FindFirstChild("AK-47")
		local FireRemote = AK47 and AK47:FindFirstChild("FireEvent")
		local Barrel = AK47 and AK47:FindFirstChild("BarrelHandle")
		local Flash = AK47 and AK47:FindFirstChild("Flash")
		local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")		
		if HumanoidRootPart ~= nil and AK47 ~= nil and Barrel ~= nil and Flash ~= nil and FireRemote ~= nil and Character and Head ~= nil and not ForceField then
			FireRemote:FireServer({{{Head, Head.Position, Vector3.new(), Head.Material, Barrel.Position, Flash}}}, false, nil, Vector3.new(), nil, 1, 0.096, 3)
		end
	end
end

function Bring(PlayerName, IsDowned)
	if LocalPlayer.Character and Players:FindFirstChild(PlayerName) ~= nil then
		local Player = Players[PlayerName]
		local Character = Player.Character
		local ForceField = Character and Character:FindFirstChildOfClass("ForceField")
		local Torso = Character and Character:FindFirstChild("Torso")
		local Desert = LocalPlayer.Character:FindFirstChild("Desert Eagle")
		local FireRemote = Desert and Desert:FindFirstChild("FireEvent")
		local InteractFunc = ReplicatedStorage:FindFirstChild("InteractFunction")
		local Barrel = Desert and Desert:FindFirstChild("BarrelHandle")
		local Flash = Desert and Desert:FindFirstChild("Flash")
		local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local HealthTool = LocalPlayer.Backpack:FindFirstChild("Medkit") or LocalPlayer.Backpack:FindFirstChild("Bandage")
		local OldPosition = HumanoidRootPart.CFrame		
		if HumanoidRootPart ~= nil and Desert ~= nil and Barrel ~= nil and Flash ~= nil and FireRemote ~= nil and InteractFunc ~= nil and Character and Torso ~= nil and not ForceField then
			if not Character:FindFirstChild("Downed") then
				FireRemote:FireServer({{{Torso, Torso.Position, Vector3.new(), Torso.Material, Barrel.Position, Flash}}}, false, nil, Vector3.new(), nil, 1, 0.4, 2.2)
			end			
			while task.wait(0.75) do
				if not Character:FindFirstChild("Downed") then
					FireRemote:FireServer({{{Torso, Torso.Position, Vector3.new(), Torso.Material, Barrel.Position, Flash}}}, false, nil, Vector3.new(), nil, 1, 0.4, 2.2)
				else
					break
				end
			end
			Desert.Parent = LocalPlayer.Backpack
			HumanoidRootPart.CFrame = Torso.CFrame
			task.wait()
			InteractFunc:InvokeServer(Character, "CanCollide", true, "carryPerson", Vector3.new())
			task.wait()
			HumanoidRootPart.CFrame = OldPosition
			task.wait()
			InteractFunc:InvokeServer(Character, "CanCollide", true, "carryPerson", Vector3.new())
			if not IsDowned and HealthTool ~= nil then
				HealthTool.Parent = LocalPlayer.Character
				for i = 1, 15 do
					HealthTool.ActionMain:FireServer("heal", Character)
				end
			end
		end
	end
end

function Down(PlayerName)
	if LocalPlayer.Character and Players:FindFirstChild(PlayerName) ~= nil then
		local Player = Players[PlayerName]
		local Character = Player.Character
		local ForceField = Character and Character:FindFirstChildOfClass("ForceField")
		local Torso = Character and Character:FindFirstChild("Torso")
		local Desert = LocalPlayer.Character:FindFirstChild("Desert Eagle")
		local FireRemote = Desert and Desert:FindFirstChild("FireEvent")
		local Barrel = Desert and Desert:FindFirstChild("BarrelHandle")
		local Flash = Desert and Desert:FindFirstChild("Flash")
		local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")		
		if HumanoidRootPart ~= nil and Desert ~= nil and Barrel ~= nil and Flash ~= nil and Character and Torso ~= nil and not ForceField then
			if not Character:FindFirstChild("Downed") then
				FireRemote:FireServer({{{Torso, Torso.Position, Vector3.new(), Torso.Material, Barrel.Position, Flash}}}, false, nil, Vector3.new(), nil, 1, 0.4, 2.2)
			end
			while task.wait(0.75) do
				if not Character:FindFirstChild("Downed") then
					FireRemote:FireServer({{{Torso, Torso.Position, Vector3.new(), Torso.Material, Barrel.Position, Flash}}}, false, nil, Vector3.new(), nil, 1, 0.4, 2.2)
				else
					break
				end
			end
		end
	end
end

function AntiAimDirection()
	local Direction = nil
	if LocalPlayer.Character and LocalPlayer.Character.FindFirstChild(LocalPlayer.Character, "HumanoidRootPart") ~= nil then
		local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
		local Offsets
		Jitter = not Jitter
		if AntiAimEnv.Offset == "World" then
			if Jitter then
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter)), math.sin(math.rad(AntiAimEnv.Pitch + AntiAimEnv.PitchJitter)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter)))
			else
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw)), math.sin(math.rad(AntiAimEnv.Pitch)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw)))
			end
		elseif AntiAimEnv.Offset == "Camera" then
			if Jitter then
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter) + math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)), math.sin(math.rad(AntiAimEnv.Pitch + AntiAimEnv.PitchJitter)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter) - Camera.CFrame.RightVector.X))
			else
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw) + math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)), math.sin(math.rad(AntiAimEnv.Pitch)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw) - Camera.CFrame.RightVector.X))
			end
		end
		local x, y, z = HumanoidRootPart.Position.X + Offsets.X, HumanoidRootPart.Position.Y + Offsets.Y, HumanoidRootPart.Position.Z + Offsets.Z
		Direction = CFrame.new(x, y, z)
	end
	return Direction
end

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
		Color = ESPEnv.BoxColor,
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
		drawing.Color = Color3.new(0, 0, 0)
		drawing.Thickness = 3
	end
	return drawing
end

function Utility.Add(Player)
	if not PlayerDrawings[Player] then
		PlayerDrawings[Player] = {
			-- Offscreen = Utility.New("Triangle", nil, "Offscreen"), Even though I included this, I didnt make it functional. Too lazy to work on all that math functions again.
			Name = Utility.New("Text", nil, "Name"),
			Tool = Utility.New("Text", nil, "Tool"),
			Distance = Utility.New("Text", nil, "Distance"),
			BoxOutline = Utility.New("Square", true, "BoxOutline"),
			Box = Utility.New("Square", nil, "Box"),
			HealthOutline = Utility.New("Line", true, "HealthOutline"),
			Health = Utility.New("Line", nil, "Health")
		}
	end
end

for _, Player in next, Players:GetPlayers() do	
	if Player ~= LocalPlayer then
		Utility.Add(Player)
	end
end

Connections.PlayerAdded = Players.PlayerAdded:Connect(Utility.Add)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
	if PlayerDrawings[Player] then
		for i,v in pairs(PlayerDrawings[Player]) do
			v:Remove()
		end

		PlayerDrawings[Player] = nil
	end
end)

Connections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
	if AimbotEnv.Enabled and AimbotEnv.FOV.Visible then
		AimbotEnv.FOVCircle.Visible = true
		AimbotEnv.FOVCircle.Color = AimbotEnv.FOV.Color
		AimbotEnv.FOVCircle.Radius = AimbotEnv.Radius
		AimbotEnv.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	else
		AimbotEnv.FOVCircle.Visible = false
	end
	if AimbotEnv.Enabled then
		if AimbotEnv.KeyPressed then
			AimbotGetClosestPlayer()
			if AimbotEnv.Targeted ~= nil then
				if AimbotEnv.Smoothness >= 0.03 then
					AimbotEnv.Tween = TweenService:Create(Camera, TweenInfo.new(AimbotEnv.Smoothness, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, AimbotEnv.Targeted.Character[AimbotEnv.TargetPart].Position)})
					AimbotEnv.Tween:Play()
				else
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, AimbotEnv.Targeted.Character[AimbotEnv.TargetPart].Position)
				end
				if AimbotEnv.FOV.ChangeColor then
					AimbotEnv.FOVCircle.Color = AimbotEnv.FOV.ChangedColor
				end
			end
		end
	end
	if WorldEnv.Enabled then
		if WorldEnv.Clock then
			Lighting.ClockTime = WorldEnv.ClockTime
		end
		if WorldEnv.Ambient then
			Lighting.OutdoorAmbient = WorldEnv.AmbientColor
		else
			Lighting.OutdoorAmbient = Olds.Ambient
		end
		if WorldEnv.Brightness then
			Lighting.Brightness = WorldEnv.BrightnessValue
		end
	else
		Lighting.OutdoorAmbient = Olds.Ambient
	end
	if ViewModelEnv.Enabled and LocalPlayer.Character then
		local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if Tool ~= nil and Tool:FindFirstChild("ViewModelOffset") ~= nil then
			Tool.ViewModelOffset.Value = Vector3.new(ViewModelEnv.XOffset, ViewModelEnv.YOffset, ViewModelEnv.ZOffset)
		end
	end
	if SilentAimEnv.Enabled and SilentAimEnv.FOV.Visible then
		SilentAimEnv.FOVCircle.Visible = true
		SilentAimEnv.FOVCircle.Color = SilentAimEnv.FOV.Color
		SilentAimEnv.FOVCircle.Radius = SilentAimEnv.Radius
		SilentAimEnv.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	else
		SilentAimEnv.FOVCircle.Visible = false
	end
	task.spawn(function()
		for _, Player in pairs(Players:GetPlayers()) do
			local PlayerDrawing = PlayerDrawings[Player]
			if not PlayerDrawing then continue end
			for _, Drawing in pairs(PlayerDrawing) do Drawing.Visible = false end
			local Character = Player.Character
			local RootPart, Humanoid = Character and Character:FindFirstChild("HumanoidRootPart"), Character and Character:FindFirstChildOfClass("Humanoid")
			local LocalCharacter = LocalPlayer.Character
			local LocalRootPart = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")
			if not Character or not RootPart or not Humanoid then continue end
			local DistanceFromCharacter
			if LocalCharacter and LocalRootPart ~= nil and RootPart ~= nil then
				DistanceFromCharacter = (LocalRootPart.CFrame.Position - RootPart.Position).Magnitude
			else
				DistanceFromCharacter = (Camera.CFrame.Position - RootPart.Position).Magnitude
			end
			if ESPEnv.MaxDistance < DistanceFromCharacter then continue end
			local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
			if OnScreen then
				local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
				local BoxSize = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
				local BoxPos = Vector2.new(math.floor(Pos.X - Size * 1.5 / 2), math.floor(Pos.Y - Size * 1.6 / 2))
				local Name = PlayerDrawing.Name
				local Distance = PlayerDrawing.Distance
				local Tool = PlayerDrawing.Tool
				local Box = PlayerDrawing.Box
				local BoxOutline = PlayerDrawing.BoxOutline
				local Health = PlayerDrawing.Health
				local HealthOutline = PlayerDrawing.HealthOutline
				local BottomOffset = BoxSize.Y + BoxPos.Y + 1
				if not ESPEnv.Enabled then continue end
				if ESPEnv.Box then
					Box.Size = BoxSize
					Box.Position = BoxPos
					Box.Visible = true
					Box.Color = ESPEnv.BoxColor
					Box.ZIndex = 1
					BoxOutline.Size = BoxSize
					BoxOutline.Position = BoxPos
					BoxOutline.Visible = true
					BoxOutline.ZIndex = 0
				end
				if ESPEnv.HealthBar then
					Health.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
					Health.To = Vector2.new(Health.From.X, Health.From.Y - (Humanoid.Health / Humanoid.MaxHealth) * BoxSize.Y)
					Health.Color = ESPEnv.HealthBarColor
					Health.Visible = true
					Health.ZIndex = 1
					HealthOutline.From = Vector2.new(Health.From.X, BoxPos.Y + BoxSize.Y + 1)
					HealthOutline.To = Vector2.new(Health.From.X, (Health.From.Y - 1 * BoxSize.Y) -1)
					HealthOutline.Visible = true
					HealthOutline.ZIndex = 0
				end
				if ESPEnv.Name then
					local PlayerName = ""
					if ESPEnv.NameMode == "Username" then
						PlayerName = Player.Name
					else
						PlayerName = Player.DisplayName
					end
					Name.Text = PlayerName
					Name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
					Name.Color = ESPEnv.NameColor
					Name.Font = Drawing.Fonts[ESPEnv.Font]
					Name.Visible = true
				end
				if ESPEnv.Tool then
					local EquippedTool = Player.Character:FindFirstChildOfClass("Tool")
					local Name = EquippedTool and EquippedTool.Name or "None"
					Tool.Text = Name
					Tool.Position = Vector2.new(BoxSize.X/2 + BoxPos.X, BottomOffset)
					Tool.Color = ESPEnv.ToolColor
					Tool.Font = Drawing.Fonts[ESPEnv.Font]
					Tool.Visible = true
					BottomOffset += 15
				end
				if ESPEnv.Distance then
					Distance.Text = math.floor(DistanceFromCharacter).."m"
					Distance.Position = Vector2.new(BoxSize.X/2 + BoxPos.X, BottomOffset)
					Distance.Color = ESPEnv.DistanceColor
					Distance.Font = Drawing.Fonts[ESPEnv.Font]
					Distance.Visible = true
					BottomOffset += 15
				end
			end
		end
	end)
	if WeaponmodelEnv.Enabled then
		local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if Tool ~= nil then
			for _, v in pairs(Tool:GetDescendants()) do
				if v:IsA("SurfaceAppearance") then
					v:Destroy()
				elseif v:IsA("MeshPart") and v.TextureID ~= "" then
					v.TextureID = ""
				end
				if v:IsA("BasePart") then
					v.Color = WeaponmodelEnv.Color
					v.Material = Enum.Material[WeaponmodelEnv.Material]
				end
			end
		end
	end
	if AntiAimEnv.Enabled and AntiAimEnv.Mode == "RenderStepped" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		local CameraRemote = ReplicatedStorage:FindFirstChild("CameraEvent")
		local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
		local Offsets
		Jitter = not Jitter
		if AntiAimEnv.Offset == "World" then
			if Jitter then
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter)), math.sin(math.rad(AntiAimEnv.Pitch + AntiAimEnv.PitchJitter)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter)))
			else
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw)), math.sin(math.rad(AntiAimEnv.Pitch)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw)))
			end
		elseif AntiAimEnv.Offset == "Camera" then
			if Jitter then
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter) + math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)), math.sin(math.rad(AntiAimEnv.Pitch + AntiAimEnv.PitchJitter)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw + AntiAimEnv.YawJitter) - Camera.CFrame.RightVector.X))
			else
				Offsets = Vector3.new(math.cos(math.rad(AntiAimEnv.Yaw) + math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)), math.sin(math.rad(AntiAimEnv.Pitch)) * 1.5, math.sin(math.rad(AntiAimEnv.Yaw) - Camera.CFrame.RightVector.X))
			end
		end
		local x, y, z = HumanoidRootPart.Position.X + Offsets.X, HumanoidRootPart.Position.Y + Offsets.Y, HumanoidRootPart.Position.Z + Offsets.Z
		if CameraRemote ~= nil then
			CameraRemote:FireServer(CFrame.new(x, y, z), 0, 0.01, true, CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
		end
	end
	if LocalPlayerEnv.FastHeal and LocalPlayer.Character then
		local HealthItem = LocalPlayer.Character:FindFirstChild("Medkit") or LocalPlayer.Character:FindFirstChild("Bandage")
		if HealthItem ~= nil then
			HealthItem.ActionMain:FireServer("heal", LocalPlayer.Character)
		end
	end
	if LocalPlayerEnv.AutoSelfRevive and LocalPlayerEnv.AutoSelfReviveMode == "RenderStepped" and LocalPlayer.Character then
		local Downed = LocalPlayer.Character:FindFirstChild("Downed")
		local HealthItem = LocalPlayer.Backpack:FindFirstChild("Defibrillator") or LocalPlayer.Backpack:FindFirstChild("Medkit") or LocalPlayer.Backpack:FindFirstChild("Bandage")
		if Downed ~= nil then
			HealthItem.Parent = LocalPlayer.Character
			HealthItem.ActionMain:FireServer("heal", LocalPlayer.Character)
			HealthItem.Parent = LocalPlayer.Backpack
		end
	end
	if HealAuraEnv.Enabled and LocalPlayer.Character then
		local HealthItem = LocalPlayer.Character:FindFirstChild("Medkit") or LocalPlayer.Character:FindFirstChild("Bandage")
		if HealthItem ~= nil then
			task.spawn(function()
				for _, v in pairs(Players:GetPlayers()) do
					if v ~= LocalPlayer then
						if (HealAuraEnv.Mode == "Blacklist" and HealAuraEnv.PlayerList[v.Name]) or (HealAuraEnv.Mode == "Whitelist" and not HealAuraEnv.PlayerList[v.Name]) then continue end
						local Character = v.Character
						local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
						local LocalRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if Character and RootPart ~= nil and LocalRootPart ~= nil then
							local DistanceFromCharacter = (LocalRootPart.CFrame.Position - RootPart.CFrame.Position).Magnitude
							if HealAuraEnv.Range < DistanceFromCharacter then continue end
						else
							continue
						end
						HealthItem.ActionMain:FireServer("heal", Character)
					end
				end
			end)
		end
	end
	FrameCounter += 1
	if (tick() - FrameTimer) >= 1 then
		FPS = FrameCounter
		FrameTimer = tick()
		FrameCounter = 0
	end
	Library:SetWatermark(string.format('Meonkify | %s FPS | %s ms | Place: %s', math.floor(FPS), math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue()), MarketplaceService:GetProductInfo(game.PlaceId).Name))
end)

Connections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
	if AimbotEnv.Enabled and ((Options.AimbotKeybind.Value == "MB1" and Input.UserInputType == Enum.UserInputType.MouseButton1) or (Options.AimbotKeybind.Value == "MB2" and Input.UserInputType == Enum.UserInputType.MouseButton2) or Input.KeyCode.Name == Options.AimbotKeybind.Value) then
		AimbotEnv.KeyPressed = true             
	end
end)

Connections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
	if AimbotEnv.Enabled and ((Options.AimbotKeybind.Value == "MB1" and Input.UserInputType == Enum.UserInputType.MouseButton1) or (Options.AimbotKeybind.Value == "MB2" and Input.UserInputType == Enum.UserInputType.MouseButton2) or Input.KeyCode.Name == Options.AimbotKeybind.Value) then
		AimbotEnv.KeyPressed = false
		EndAimbot()
	end
end)

if LocalPlayer.Character then
	if Connections.CharacterChildAddedConnection ~= nil then
		Connections.CharacterChildAddedConnection:Disconnect()
		Connections.CharacterChildAddedConnection = nil
	end	
	Connections.CharacterChildAddedConnection = LocalPlayer.Character.ChildAdded:Connect(function(Child)
		if LocalPlayerEnv.AutoSelfRevive and LocalPlayerEnv.AutoSelfReviveMode == "ChildAdded" and LocalPlayer:FindFirstChildOfClass("Backpack") ~= nil and Child.Name == "Downed" then
			local HealthItem = LocalPlayer.Backpack:FindFirstChild("Defibrillator") or LocalPlayer.Backpack:FindFirstChild("Medkit") or LocalPlayer.Backpack:FindFirstChild("Bandage")
			if HealthItem ~= nil then
				while WaitForSomeone(RenderStepped) do
					if LocalPlayerEnv.AutoSelfRevive and LocalPlayer.Character:FindFirstChild("Downed") ~= nil then
						HealthItem.Parent = LocalPlayer.Character
						HealthItem.ActionMain:FireServer("heal", LocalPlayer.Character)
					else
						break
					end
				end
			end
		end
		if GunModsEnv.Enabled and Child:IsA("Tool") then
			GunMods(Child)
		end
	end)
end

Connections.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
	if Connections.CharacterChildAddedConnection ~= nil then
		Connections.CharacterChildAddedConnection:Disconnect()
		Connections.CharacterChildAddedConnection = nil
	end	
	Connections.CharacterChildAddedConnection = LocalPlayer.Character.ChildAdded:Connect(function(Child)
		if LocalPlayerEnv.AutoSelfRevive and LocalPlayerEnv.AutoSelfReviveMode == "ChildAdded" and LocalPlayer:FindFirstChildOfClass("Backpack") ~= nil and Child.Name == "Downed" then
			local HealthItem = LocalPlayer.Backpack:FindFirstChild("Defibrillator") or LocalPlayer.Backpack:FindFirstChild("Medkit") or LocalPlayer.Backpack:FindFirstChild("Bandage")
			if HealthItem ~= nil then
				while WaitForSomeone(RenderStepped) do
					if LocalPlayerEnv.AutoSelfRevive and LocalPlayer.Character:FindFirstChild("Downed") ~= nil then
						HealthItem.Parent = LocalPlayer.Character
						HealthItem.ActionMain:FireServer("heal", LocalPlayer.Character)
					else
						break
					end
				end
			end
		end
		if GunModsEnv.Enabled and Child:IsA("Tool") then
			GunMods(Child)
		end
	end)
end)

function Meonkify:Exit()
	for _, con in next, Connections do
		con:Disconnect()
		con = nil
	end
	for _, player in pairs(Players:GetPlayers()) do
		if PlayerDrawings[player] then
			for _, Drawing in pairs(PlayerDrawings[player]) do
				Drawing:Remove()
			end
		end
	end
	Lighting.OutdoorAmbient = Olds.Ambient
	AimbotEnv.FOVCircle:Remove()
	SilentAimEnv.FOVCircle:Remove()
	Library:Unload()
	getgenv().Meonkify = nil
end

local Window = Library:CreateWindow({
	Title = 'Meonkify',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.175
})

local Tabs = {
	Combat = Window:AddTab('Combat'),
	Visuals = Window:AddTab('Visuals'),
	World = Window:AddTab('World'),
	Misc = Window:AddTab('Misc'),
	Settings = Window:AddTab('Settings')
}

local Groups = {
	Aimbot = Tabs.Combat:AddLeftGroupbox('Aimbot'),
	SilentAim = Tabs.Combat:AddRightGroupbox('Silent Aim'),
	AntiAim = Tabs.Combat:AddLeftGroupbox('Anti Aim'),
	GunMods = Tabs.Combat:AddRightGroupbox('Gun Mods'),

	ESP = Tabs.Visuals:AddLeftGroupbox('ESP'),
	Viewmodel = Tabs.Visuals:AddRightGroupbox('View Model'),
	Weaponmodel = Tabs.Visuals:AddRightGroupbox('Weapon Model'),

	LightingModifier = Tabs.World:AddLeftGroupbox('Lighting Modifier'),

	PlayerUtilities = Tabs.Misc:AddLeftGroupbox('Player Utilities'),
	PenisGun = Tabs.Misc:AddLeftGroupbox('Penis Gun'),
	LocalPlayer = Tabs.Misc:AddRightGroupbox('LocalPlayer'),
	HealAura = Tabs.Misc:AddRightGroupbox('Heal Aura'),

	Menu = Tabs.Settings:AddLeftGroupbox('Menu')
}

Groups.Aimbot:AddToggle('AimbotEnabled', { Text = 'Enabled', Default = AimbotEnv.Enabled, Tooltip = 'Enable/Disable aimbot', Callback = function(vl) AimbotEnv.Enabled = vl if not vl then EndAimbot() end end}):AddKeyPicker('AimbotKeybind', { Default = 'MB2', SyncToggleState = false, Mode = 'Hold', Text = nil, NoUI = true })
Groups.Aimbot:AddToggle('AimbotStickyAim', { Text = 'Sticky Aim', Default = AimbotEnv.StickyAim, Tooltip = 'Keep the target same until the target is out of\nFOV circle or the key is no longer being pressed', Callback = function(vl) AimbotEnv.StickyAim = vl end })
Groups.Aimbot:AddSlider('AimbotRadius', { Text = 'Aimbot Radius', Max = 1000, Min = 30, Default = AimbotEnv.Radius, Rounding = 0, Callback = function(vl) AimbotEnv.Radius = vl end })
Groups.Aimbot:AddSlider('AimbotSmoothness', { Text = 'Smoothness', Max = 1, Min = 0, Default = AimbotEnv.Smoothness, Rounding = 2, Callback = function(vl) AimbotEnv.Smoothness = vl end })
Groups.Aimbot:AddDropdown('AimbotTargetPart', { Values = { "Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Default = AimbotEnv.TargetPart, Multi = false, Text = 'Target Part', Tooltip = 'Changes the part of the aimbot to lock on', Callback = function(vl) AimbotEnv.TargetPart = vl end })
Groups.Aimbot:AddDivider()
Groups.Aimbot:AddLabel('FOV Circle')
Groups.Aimbot:AddToggle('AimbotFOVCircle', { Text = 'Visible', Default = AimbotEnv.FOV.Visible, Tooltip = 'Hide/Show the FOV circle', Callback = function(vl) AimbotEnv.FOV.Visible = vl end }):AddColorPicker('AimbotFOVCircleColor', { Default = AimbotEnv.FOV.Color, Title = 'FOV Circle Color', Transparency = nil, Callback = function(vl) AimbotEnv.FOV.Color = vl end })
Groups.Aimbot:AddToggle('AimbotFOVColorChange', { Text = 'Change color on locked', Default = AimbotEnv.FOV.ChangeColor, Tooltip = 'Changes the Field of View circle color when locked', Callback = function(vl) AimbotEnv.FOV.ChangeColor = vl end }):AddColorPicker('AimbotFOVLockedColor', { Default = AimbotEnv.FOV.ChangedColor, Title = 'FOV Locked Color', Transparency = nil, Callback = function(vl) AimbotEnv.FOV.ChangedColor = vl end })
Groups.Aimbot:AddDivider()
Groups.Aimbot:AddLabel('Checks')
Groups.Aimbot:AddToggle('AimbotAliveCheck', { Text = 'Alive Check', Default = AimbotEnv.Checks.AliveCheck, Tooltip = 'Checks if the player is alive or downed', Callback = function(vl) AimbotEnv.Checks.AliveCheck = vl end })
Groups.Aimbot:AddToggle('AimbotVisibleCheck', { Text = 'Visible Check', Default = AimbotEnv.Checks.VisibleCheck, Tooltip = 'Checks if the player is visible', Callback = function(vl) AimbotEnv.Checks.VisibleCheck = vl end })
Groups.Aimbot:AddToggle('AimbotForceFieldCheck', { Text = 'ForceField Check', Default = AimbotEnv.Checks.ForceFieldCheck, Tooltip = 'Checks if the player has ForceField', Callback = function(vl) AimbotEnv.Checks.ForceFieldCheck = vl end })

if hookmetamethod then
	Groups.SilentAim:AddToggle('SilentAimEnabled', { Text = 'Enabled', Default = SilentAimEnv.Enabled, Tooltip = 'Enable/Disable silent aim', Callback = function(vl) SilentAimEnv.Enabled = vl end })
	Groups.SilentAim:AddSlider('SilentAimRadius', { Text = 'Silent Aim Radius', Max = 1000, Min = 30, Default = SilentAimEnv.Radius, Rounding = 0, Callback = function(vl) SilentAimEnv.Radius = vl end })
	Groups.SilentAim:AddDropdown('SilentAimTargetPart', { Values = { "Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Default = SilentAimEnv.TargetPart, Multi = false, Text = 'TargetPart', Tooltip = 'Changes the part of the part the silent aim will hit', Callback = function(vl) SilentAimEnv.TargetPart = vl end })
	Groups.SilentAim:AddDivider()
	Groups.SilentAim:AddLabel('FOV Circle')
	Groups.SilentAim:AddToggle('SilentAimFOVCircle', { Text = 'Visible', Default = SilentAimEnv.FOV.Visible, Tooltip = 'Hide/Show the FOV circle', Callback = function(vl) SilentAimEnv.FOV.Visible = vl end }):AddColorPicker('SilentAimFOVCircleColor', { Default = SilentAimEnv.FOV.Color, Title = 'FOV Circle Color', Transparency = nil, Callback = function(vl) SilentAimEnv.FOV.Color = vl end })
	Groups.SilentAim:AddDivider()
	Groups.SilentAim:AddLabel('Checks')
	Groups.SilentAim:AddToggle('SilentAimAliveCheck', { Text = 'Alive Check', Default = SilentAimEnv.Checks.AliveCheck, Tooltip = 'Checks if the player is alive and not downed', Callback = function(vl) SilentAimEnv.Checks.AliveCheck = vl end })
	Groups.SilentAim:AddToggle('SilentAimVisibleCheck', { Text = 'Visible Check', Default = SilentAimEnv.Checks.VisibleCheck, Tooltip = 'Checks if the player is visible', Callback = function(vl) SilentAimEnv.Checks.VisibleCheck = vl end })
	Groups.SilentAim:AddToggle('SilentAimForceFieldCheck', { Text = 'ForceField Check', Default = SilentAimEnv.Checks.ForceFieldCheck, Tooltip = 'Checks if the player has ForceField', Callback = function(vl) SilentAimEnv.Checks.ForceFieldCheck = vl end })
else
	Groups.SilentAim:AddLabel('Your current executor does not support the function "hookmetamethod". Because of that, silent aim features are hidden.', true)
end

Groups.AntiAim:AddToggle('AntiAimEnabled', { Text = 'Enabled', Default = AntiAimEnv.Enabled, Tooltip = 'Enable/Disable anti aim', Callback = function(vl) AntiAimEnv.Enabled = vl end })
if hookmetamethod then
	Groups.AntiAim:AddDropdown('AntiAimMode', { Values = { "RenderStepped", "hookmetamethod" }, Default = AntiAimEnv.Mode, Multi = false, Text = 'Anti Aim Mode', Tooltip = 'Changes the mode of how the anti aim works', Callback = function(vl) AntiAimEnv.Mode = vl end })
else
	Groups.AntiAim:AddLabel('Your current executor does not support the function "hookmetamethod". Because of that, anti aim mode is set to RenderStepped.', true)
end
Groups.AntiAim:AddSlider('AntiAimYaw', { Text = 'Yaw', Max = 180, Min = -180, Default = AntiAimEnv.Yaw, Rounding = 0, Callback = function(vl) AntiAimEnv.Yaw = vl end })
Groups.AntiAim:AddSlider('AntiAimYawJitter', { Text = 'Yaw Jitter', Max = 180, Min = -180, Default = AntiAimEnv.YawJitter, Rounding = 0, Callback = function(vl) AntiAimEnv.YawJitter = vl end })
Groups.AntiAim:AddSlider('AntiAimPitch', { Text = 'Pitch', Max = 90, Min = -90, Default = AntiAimEnv.Pitch, Rounding = 0, Callback = function(vl) AntiAimEnv.Pitch = vl end })
Groups.AntiAim:AddSlider('AntiAimPitchJitter', { Text = 'Pitch Jitter', Max = 180, Min = -180, Default = AntiAimEnv.PitchJitter, Rounding = 0, Callback = function(vl) AntiAimEnv.PitchJitter = vl end })
Groups.AntiAim:AddDropdown('AntiAimYawOffsetMode', { Values = {'World', 'Camera'}, Default = AntiAimEnv.Offset, Multi = false, Text = 'Yaw Offset Mode', Tooltip = 'Changes the offset mode of the anti aim', Callback = function(vl) AntiAimEnv.Offset = vl end })

Groups.GunMods:AddToggle('GunModsEnabled', { Text = 'Enabled', Default = GunModsEnv.Enabled, Tooltip = 'Enable/Disable gun mods', Callback = function(vl) GunModsEnv.Enabled = vl end })
Groups.GunMods:AddDropdown('GunModsMode', { Values = { "require", "Attachments" }, Default = GunModsEnv.Mode, Multi = false, Text = 'Mode', Tooltip = 'Changes the mode of gun mods', Callback = function(vl) GunModsEnv.Mode = vl end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Recoil')
Groups.GunMods:AddToggle('GunModsRecoilEnabled', { Text = 'Enabled', Default = GunModsEnv.Recoil.Enabled, Tooltip = 'Changes the recoil of your weapon', Callback = function(vl) GunModsEnv.Recoil.Enabled = vl if GunModsEnv.Enabled and vl and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddSlider('GunModsRecoil', { Text = 'Value', Max = 10, Min = 0, Default = GunModsEnv.Recoil.Value, Rounding = 2, Callback = function(vl) GunModsEnv.Recoil.Value = vl if GunModsEnv.Enabled and GunModsEnv.Recoil.Enabled and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Aim Field Of View')
Groups.GunMods:AddToggle('GunModsAimFOVEnabled', { Text = 'Enabled', Default = GunModsEnv.AimFOV.Enabled, Tooltip = 'Changes the aim FOV when you aim in with your weapon', Callback = function(vl) GunModsEnv.AimFOV.Enabled = vl if GunModsEnv.Enabled and vl and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddSlider('GunModsAimFOV', { Text = 'Value', Max = 120, Min = 0, Default = GunModsEnv.AimFOV.Value, Rounding = 2, Callback = function(vl) GunModsEnv.AimFOV.Value = vl if GunModsEnv.Enabled and GunModsEnv.AimFOV.Enabled and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Reload Time')
Groups.GunMods:AddToggle('GunModsReloadTimeEnabled', { Text = 'Enabled', Default = GunModsEnv.ReloadTime.Enabled, Tooltip = 'Changes the reload time of your weapon', Callback = function(vl) GunModsEnv.ReloadTime.Enabled = vl if GunModsEnv.Enabled and vl and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddSlider('GunModsReloadTime', { Text = 'Value', Max = 10, Min = 0.0001, Default = GunModsEnv.ReloadTime.Value, Rounding = 4, Callback = function(vl) GunModsEnv.ReloadTime.Value = vl if GunModsEnv.Enabled and GunModsEnv.ReloadTime.Enabled and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Fire Rate')
Groups.GunMods:AddToggle('GunModsFireRateEnabled', { Text = 'Enabled', Default = GunModsEnv.FireRate.Enabled, Tooltip = 'Changes the fire rate of your weapon', Callback = function(vl) GunModsEnv.FireRate.Enabled = vl if GunModsEnv.Enabled and vl and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddSlider('GunModsFireRate', { Text = 'Value', Max = 10, Min = 0, Default = GunModsEnv.FireRate.Value, Rounding = 2, Callback = function(vl) GunModsEnv.FireRate.Value = vl if GunModsEnv.Enabled and GunModsEnv.FireRate.Enabled and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Aim Time')
Groups.GunMods:AddToggle('GunModsAimTimeEnabled', { Text = 'Enabled', Default = GunModsEnv.AimTime.Enabled, Tooltip = 'Changes the aim time of your weapon', Callback = function(vl) GunModsEnv.AimTime.Enabled = vl if GunModsEnv.Enabled and vl and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddSlider('GunModsAimTime', { Text = 'Value', Max = 10, Min = 0, Default = GunModsEnv.AimTime.Value, Rounding = 2, Callback = function(vl) GunModsEnv.AimTime.Value = vl if GunModsEnv.Enabled and GunModsEnv.AimTime.Enabled and LocalPlayer.Character then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if Tool ~= nil then GunMods(Tool) end end end })
Groups.GunMods:AddDivider()
Groups.GunMods:AddLabel('Install Kill')
Groups.GunMods:AddToggle('GunModsInstallKill', { Text = 'Enabled', Default = false, Tooltip = 'Installs your kills 🤖🤖 (Fatality.cb moment)', Callback = function(vl) if vl then Library:Notify("Installing your kills 🤖🤖 (this shit aint doing anything bru 💔💔)") end end })

Groups.ESP:AddToggle('ESPEnabled', { Text = 'Enabled', Default = ESPEnv.Enabled, Tooltip = 'Enable/Disable ESP', Callback = function(vl) ESPEnv.Enabled = vl end })
Groups.ESP:AddToggle('ESPBox', { Text = 'Box', Default = ESPEnv.Box, Tooltip = 'Draws boxes on players', Callback = function(vl) ESPEnv.Box = vl end }):AddColorPicker('ESPBoxColor', { Default = ESPEnv.BoxColor, Title = 'ESP Box Color', Transparency = nil, Callback = function(vl) ESPEnv.BoxColor = vl end })
Groups.ESP:AddToggle('ESPName', { Text = 'Name', Default = ESPEnv.Name, Tooltip = 'Draws names on players', Callback = function(vl) ESPEnv.Name = vl end }):AddColorPicker('ESPNameColor', { Default = ESPEnv.NameColor, Title = 'ESP Name Color', Transparency = nil, Callback = function(vl) ESPEnv.NameColor = vl end })
Groups.ESP:AddToggle('ESPHealthBar', { Text = 'Health Bar', Default = ESPEnv.HealthBar, Tooltip = 'Draws health bars on players', Callback = function(vl) ESPEnv.HealthBar = vl end }):AddColorPicker('ESPHealthBarColor', { Default = ESPEnv.HealthBarColor, Title = 'ESP Health Bar Color', Transparency = nil, Callback = function(vl) ESPEnv.HealthBarColor = vl end })
Groups.ESP:AddToggle('ESPTool', { Text = 'Tool', Default = ESPEnv.Tool, Tooltip = 'Draws the equipped tool on players', Callback = function(vl) ESPEnv.Tool = vl end }):AddColorPicker('ESPToolColor', { Default = ESPEnv.ToolColor, Title = 'ESP Tool Color', Transparency = nil, Callback = function(vl) ESPEnv.ToolColor = vl end })
Groups.ESP:AddToggle('ESPDistance', { Text = 'Distance', Default = ESPEnv.Distance, Tooltip = 'Draws the distance between your character and the player', Callback = function(vl) ESPEnv.Distance  = vl end }):AddColorPicker('ESPDistanceColor', { Default = ESPEnv.DistanceColor, Title = 'ESP Distance Color', Transparency = nil, Callback = function(vl) ESPEnv.DistanceColor = vl end })
Groups.ESP:AddDropdown('ESPNameMode', { Values = { "Username", "Display Name" }, Default = ESPEnv.NameMode, Multi = false, Text = 'Name Mode', Tooltip = 'Changes the name mode', Callback = function(vl) ESPEnv.NameMode = vl end })
Groups.ESP:AddDropdown('ESPFont', { Values = { "Plex", "Monospace", "System", "UI" }, Default = ESPEnv.Font, Multi = false, Text = 'Font', Tooltip = 'Changes the text font', Callback = function(vl) ESPEnv.Font = vl end })
Groups.ESP:AddSlider('ESPDistance', { Text = 'Max Distance', Max = 100000, Min = 0, Default = ESPEnv.MaxDistance, Rounding = 0, Callback = function(vl) ESPEnv.MaxDistance = vl end })

Groups.Viewmodel:AddToggle('ViewmodelEnabled', { Text = 'Enabled', Default = ViewModelEnv.Enabled, Tooltip = 'Enable/Disable viewmodel changer', Callback = function(vl) ViewModelEnv.Enabled = vl end })
Groups.Viewmodel:AddSlider('ViewmodelX', { Text = 'X Offset', Max = 10, Min = -10, Default = ViewModelEnv.XOffset, Rounding = 1, Callback = function(vl) ViewModelEnv.XOffset = vl end })
Groups.Viewmodel:AddSlider('ViewmodelY', { Text = 'Y Offset', Max = 10, Min = -10, Default = ViewModelEnv.YOffset, Rounding = 1, Callback = function(vl) ViewModelEnv.YOffset = vl end })
Groups.Viewmodel:AddSlider('ViewmodelX', { Text = 'Z Offset', Max = 10, Min = -10, Default = ViewModelEnv.ZOffset, Rounding = 1, Callback = function(vl) ViewModelEnv.ZOffset = vl end })

Groups.Weaponmodel:AddToggle('WeaponmodelEnabled', { Text = 'Enabled', Default = WeaponmodelEnv.Enabled, Tooltip = 'Changes your weapon model', Callback = function(vl) WeaponmodelEnv.Enabled = vl end }):AddColorPicker('WeaponmodelColor', { Default = WeaponmodelEnv.Color, Title = 'Weapon Color', Transparency = nil, Callback = function(vl) WeaponmodelEnv.Color = vl end })
Groups.Weaponmodel:AddDropdown('WeaponmodelMaterial', { Values = { "Asphalt", "Basalt", "Brick", "Cardboard", "Carpet", "CeramicTiles", "ClayRoofTiles", "Cobblestone", "Concrete", "CorrodedMetal", "CrackedLava", "DiamondPlate", "Fabric", "Foil", "ForceField", "Glacier", "Glass", "Granite", "Grass", "Ground", "Ice", "LeafyGrass", "Leather", "Limestone", "Marble", "Metal", "Mud", "Neon", "Pavement", "Pebble", "Plaster", "Plastic", "Rock", "RoofShingles", "Rubber", "Salt", "Sand", "Sandstone", "Slate", "SmoothPlastic", "Snow", "Wood", "WoodPlanks" }, Default = WeaponmodelEnv.Material, Multi = false, Text = 'Material', Tooltip = 'Sets the material of your weapon', Callback = function(vl) WeaponmodelEnv.Material = vl end })

Groups.LightingModifier:AddToggle('LightingModifierEnabled', { Text = 'Enabled', Default = WorldEnv.Enabled, Tooltip = 'Enable/Disable lighting modifier', Callback = function(vl) WorldEnv.Enabled = vl end })
Groups.LightingModifier:AddDivider()
Groups.LightingModifier:AddToggle('LightingModifierClock', { Text = 'Clock', Default = WorldEnv.Clock, Tooltip = 'Changes the clock time', Callback = function(vl) WorldEnv.Clock = vl end })
Groups.LightingModifier:AddSlider('LightingModifierClockTime', { Text = 'Clock Time', Max = 24, Min = 0, Default = WorldEnv.ClockTime, Rounding = 1, Callback = function(vl) WorldEnv.ClockTime = vl end })
Groups.LightingModifier:AddDivider()
Groups.LightingModifier:AddToggle('LightingModifierBrightness', { Text = 'Brightness', Default = WorldEnv.Brightness, Tooltip = 'Changes the brightness', Callback = function(vl) WorldEnv.Brightness = vl end })
Groups.LightingModifier:AddSlider('LightingModifierBrightnessValue', { Text = 'Brightness Value', Max = 10, Min = 0, Default = WorldEnv.BrightnessValue, Rounding = 1, Callback = function(vl) WorldEnv.BrightnessValue = vl end })
Groups.LightingModifier:AddDivider()
Groups.LightingModifier:AddToggle('LightingModifierAmbient', { Text = 'Ambient', Default = WorldEnv.Ambient, Tooltip = 'Changes the ambient color', Callback = function(vl) WorldEnv.Ambient = vl end }):AddColorPicker('LightingModifierAmbientColor', { Default = WorldEnv.AmbientColor, Title = 'Ambient Color', Transparency = nil, Callback = function(vl) WorldEnv.AmbientColor = vl end })

Groups.PlayerUtilities:AddDropdown('PlayerUtilitiesPlayer', { SpecialType = 'Player', Text = 'Target Player', Tooltip = 'Changes the target player', Callback = function(vl) PlayerUtilitiesEnv.Target = vl end })
Groups.PlayerUtilities:AddButton({ Text = 'Bring', Func = function() if PlayerUtilitiesEnv.Target ~= nil then Bring(PlayerUtilitiesEnv.Target, false) end end, Tooltip = 'Brings the targeted player to you\nEquip Desert Eagle for this to function', DoubleClick = false }):AddButton({ Text = 'Downed Bring', Func = function() if PlayerUtilitiesEnv.Target ~= nil then Bring(PlayerUtilitiesEnv.Target, true) end end, Tooltip = 'Brings the targeted player to you\nBut does not revive them\nEquip Desert Eagle for this to function', DoubleClick = false })
Groups.PlayerUtilities:AddButton({ Text = 'Kill', Func = function() if PlayerUtilitiesEnv.Target ~= nil then Kill(PlayerUtilitiesEnv.Target) end end, Tooltip = 'Kills the targeted player\nEquip AK-47 for this to function', DoubleClick = false })
Groups.PlayerUtilities:AddToggle('PlayerUtilitiesLoopKill', { Text = 'Loop Kill', Default = PlayerUtilitiesEnv.LoopKill, Tooltip = 'Kills the player in a loop\nEquip AK-47 for this to function', Callback = function(vl) PlayerUtilitiesEnv.LoopKill = vl if vl then task.spawn(function() while task.wait(0.5) do if PlayerUtilitiesEnv.LoopKill then Kill(PlayerUtilitiesEnv.Target) else break end end end) end end })
Groups.PlayerUtilities:AddButton({ Text = 'Down', Func = function() if PlayerUtilitiesEnv.Target ~= nil then Down(PlayerUtilitiesEnv.Target) end end, Tooltip = 'Downs the targeted player\nEquip Desert Eagle for this to function', DoubleClick = false })
Groups.PlayerUtilities:AddDivider()
Groups.PlayerUtilities:AddButton({ Text = 'Kill All', Func = function() for _, v in next, Players:GetPlayers() do Kill(v.Name) end end, Tooltip = 'Kills all players INCLUDING yourself\nEquip AK-47 for this to function', DoubleClick = false }):AddButton({ Text = 'Kill Others', Func = function() for _, v in next, Players:GetPlayers() do if v ~= LocalPlayer then Kill(v) end end end, Tooltip = 'Kills other players\nEquip AK-47 for this to function', Doubleclick = false })
Groups.PlayerUtilities:AddToggle('PlayerUtilitiesLoopKillAll', { Text = 'Loop Kill All', Default = PlayerUtilitiesEnv.LoopKillAll, Tooltip = 'Kills everyone INCLUDING you in a loop\nEquip AK-47 for this to function', Callback = function(vl) PlayerUtilitiesEnv.LoopKillAll = vl if vl then task.spawn(function() while task.wait(0.5) do if PlayerUtilitiesEnv.LoopKillAll then for _, v in next, Players:GetPlayers() do Kill(v.Name) end else break end end end) end end })
Groups.PlayerUtilities:AddToggle('PlayerUtilitiesLoopKillOthers', { Text = 'Loop Kill Others', Default = PlayerUtilitiesEnv.LoopKillOthers, Tooltip = 'Kills others in a loop\nEquip AK-47 for this to function', Callback = function(vl) PlayerUtilitiesEnv.LoopKillOthers = vl if vl then task.spawn(function() while task.wait(0.5) do if PlayerUtilitiesEnv.LoopKillOthers then for _, v in next, Players:GetPlayers() do if v ~= LocalPlayer then Kill(v.Name) end end else break end end end) end end })

Groups.LocalPlayer:AddToggle('LocalPlayerFastHeal', { Text = 'Fast Heal', Default = LocalPlayerEnv.FastHeal, Tooltip = 'Heals you when you hold a health tool (like medkit or bandages)', Callback = function(vl) LocalPlayerEnv.FastHeal = vl end })
Groups.LocalPlayer:AddToggle('LocalPlayerAutoSelfRevive', { Text = 'Auto Self Revive', Default = LocalPlayerEnv.AutoSelfRevive, Tooltip = 'Automatically revives you when you are down', Callback = function(vl) LocalPlayerEnv.AutoSelfRevive = vl end })
Groups.LocalPlayer:AddDropdown('LocalPlayerAutoSelfReviveMode', { Values = { 'RenderStepped', 'ChildAdded' }, Default = LocalPlayerEnv.AutoSelfReviveMode, Multi = false, Text = 'Auto Self Revive Mode', Tooltip = 'Changes the mode of auto self revive', Callback = function(vl) LocalPlayerEnv.AutoSelfReviveMode = vl end })

Groups.HealAura:AddToggle('HealAuraEnabled', { Text = 'Enabled', Default = HealAuraEnv.Enabled, Tooltip = 'Heals the player around you', Callback = function(vl) HealAuraEnv.Enabled = vl end })
Groups.HealAura:AddSlider('HealAuraRange', { Text = 'Range', Max = 50, Min = 0, Default = HealAuraEnv.Range, Rounding = 2, Callback = function(vl) HealAuraEnv.Range = vl end })
Groups.HealAura:AddDropdown('HealAuraMode', { Values = { 'Blacklist', 'Whitelist' }, Default = HealAuraEnv.Mode, Multi = false, Text = 'Method', Tooltip = 'Changes the mode of the getting players', Callback = function(vl) HealAuraEnv.Mode = vl end })
Groups.HealAura:AddDropdown('HealAuraPlayers', { SpecialType = 'Player', Text = 'Player List', Tooltip = 'Selects the player to heal or not', Multi = true, Callback = function(vl) HealAuraEnv.PlayerList = vl end })

Groups.PenisGun:AddToggle('PenisGun', { Text = 'Enabled', Default = false, Tooltip = "Makes the gun you're holding look like your penis", Callback = function(vl) if vl then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") MiscEnv.PenisGunTool = Tool Tool.Parent = Workspace end else if LocalPlayer.Character and MiscEnv.PenisGunTool ~= nil then MiscEnv.PenisGunTool.Parent = LocalPlayer.Character end end end })
Groups.PenisGun:AddLabel('It is NOT recommended to hold a weapon during this is enabled', true)

Groups.Menu:AddButton('Unload', function() Meonkify:Exit() end)
Groups.Menu:AddLabel('Menu Keybind'):AddKeyPicker('MK', { Default = 'Insert', NoUI = true, Text = 'Menu Keybind' })

Library.ToggleKeybind = Options.MK

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library) 
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MK', 'HealAuraPlayers', 'PlayerUtilitiesPlayer' })
ThemeManager:SetFolder('Meonkify/Themes')
SaveManager:SetFolder('Meonkify/Town')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

if hookmetamethod then
	local Old = nil; 
	Old = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
		local Args = {...}
		local Method = getnamecallmethod()
		if typeof(Self) == "Instance" and Self.ClassName == "RemoteEvent" and Method == "FireServer" and not checkcaller() then
			if Self.Name == "FireEvent" and SilentAimEnv.Enabled then
				local Target = SilentAimGetClosestPlayer()
				if Target ~= nil then
					Args[1][1][1][1] = Target.Character[SilentAimEnv.TargetPart]
					Args[1][1][1][2] = Target.Character[SilentAimEnv.TargetPart].Position
					Args[1][1][1][3] = Vector3.new()
					Args[1][1][1][4] = Target.Character[SilentAimEnv.TargetPart].Material
					Args[4] = Vector3.new()
				end
			end
			if Self.Name == "CameraEvent" and AntiAimEnv.Enabled and AntiAimEnv.Mode == "hookmetamethod" then
				local Offsets = AntiAimDirection()
				if Offsets ~= nil then
					Args[1] = Offsets
				end
			end
		end
		return Old(Self, table.unpack(Args))
	end))
end

Library:Notify("Script loaded in ".. tick() - StartTick)
