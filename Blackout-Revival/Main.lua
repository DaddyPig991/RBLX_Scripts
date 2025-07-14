Unloaded = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer

local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/DaddyPig991/RBLX_Scripts/refs/heads/main/Blackout-Revival/Aiming.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DaddyPig991/RBLX_Scripts/refs/heads/main/Blackout-Revival/ESP.lua"))()

Aiming.Enabled = false
Aiming.FOV = 180
Aiming.FOVColor = Color3.fromRGB(255, 255, 255)
Aiming.NPCs = true
Aiming.Players = false

local HitChance = 100

local Collection = {}
function Collect(Item : RBXScriptConnection | thread)
	table.insert(Collection, Item)
end

local FastCast = require(ReplicatedStorage.Mods.FastCast)

local Remotes = {
	GunHit = ReplicatedStorage.GunStorage.Events.Hit,
}

local Functions

local HookStorage = {}

local Limbs = {
	"Head",
	"Torso"
}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Options = Fluent.Options

-- Functions

local function Miss()
	return (math.random(0, 100) > HitChance)
end

local function GetClosest(Instances : {Model | BasePart}, Position : Vector3)
	local Closest = nil
	local ClosestDistance = math.huge

	for _, Object in ipairs(Instances) do
		local InstancePosition = Object:GetPivot().Position
		local Distance = (InstancePosition - Position).Magnitude
		if Distance < ClosestDistance then
			Closest = Object
			ClosestDistance = Distance
		end
	end

	return Closest, ClosestDistance
end

local function RestoreConnections(Event : RBXScriptSignal)
	pcall(function()
		for _, Connection in next, getconnections(Event) do
			Connection:Enable()
		end
	end)
end

local BlockedEvents = {}

-- Collections

Collect(ProximityPromptService.PromptButtonHoldBegan:Connect(function(ProximityPrompt : ProximityPrompt)
	if Options.ProxPrompt_Toggle.Value then
		fireproximityprompt(ProximityPrompt)
	end
end))

-- UI

local Window = Fluent:CreateWindow({
	Title = "Blackout: Revival",
	SubTitle = "by Aura hub",
	TabWidth = Aiming.FOV,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "menu" }),
	Aim = Window:AddTab({ Title = "Aim", Icon = "crosshair" }),
	ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

do
	
	local Misc_Section = Tabs.Main:AddSection("Misc")
	
	local Misc_PP_Toggle = Tabs.Main:AddToggle("ProxPrompt_Toggle", {Title = "Proximity Prompt Bypass", Default = false })
	
	local Section = Tabs.Aim:AddSection("Silent Aim")

	local Toggle = Tabs.Aim:AddToggle("SA_Toggle", {Title = "Enabled", Default = Aiming.Enabled })

	Toggle:OnChanged(function()
		Aiming.Enabled = Options.SA_Toggle.Value
	end)

	local Slider = Tabs.Aim:AddSlider("SA_FOV_Slider", {
		Title = "FOV",
		Description = "",
		Default = Aiming.FOV,
		Min = 1,
		Max = 1000,
		Rounding = 0,
		Callback = function(Value)
			Aiming.FOV = Value
		end
	})

	local Input = Tabs.Aim:AddInput("SA_FOV_Input", {
		Title = "FOV Input",
		Default = Aiming.FOV,
		Placeholder = "FOV Size",
		Numeric = true, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter
		Callback = function(Value)
			Slider:SetValue(Value)
		end
	})

	local FOV_Colorpicker = Tabs.Aim:AddColorpicker("SA_FOV_Color", {
		Title = "FOV Color",
		Default = Aiming.FOVColor
	})

	FOV_Colorpicker:OnChanged(function()
		Aiming.FOVColor = FOV_Colorpicker.Value
	end)

	local Dropdown = Tabs.Aim:AddDropdown("SA_TargetPart", {
		Title = "Target",
		Values = Limbs,
		Multi = false,
		Default = 1,
	})
end

do
	local MainSection = Tabs.ESP:AddSection("Main ESP")

	local EnabledToggle = MainSection:AddToggle("Enabled", {
		Title = "Enable ESP",
		Default = false
	})
	EnabledToggle:OnChanged(function()
		ESP.Settings.Enabled = EnabledToggle.Value
		if not ESP.Settings.Enabled then
			ESP:CleanupESP()
		else
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					ESP:CreateESP(player)
				end
			end
		end
	end)

	local TeamCheckToggle = MainSection:AddToggle("TeamCheck", {
		Title = "Team Check",
		Default = false
	})
	TeamCheckToggle:OnChanged(function()
		ESP.Settings.TeamCheck = TeamCheckToggle.Value
	end)

	local ShowTeamToggle = MainSection:AddToggle("ShowTeam", {
		Title = "Show Team",
		Default = false
	})
	ShowTeamToggle:OnChanged(function()
		ESP.Settings.ShowTeam = ShowTeamToggle.Value
	end)

	local BoxSection = Tabs.ESP:AddSection("Box ESP")

	local BoxESPToggle = BoxSection:AddToggle("BoxESP", {
		Title = "Box ESP",
		Default = false
	})
	BoxESPToggle:OnChanged(function()
		ESP.Settings.BoxESP = BoxESPToggle.Value
	end)

	local BoxStyleDropdown = BoxSection:AddDropdown("BoxStyle", {
		Title = "Box Style",
		Values = {"Corner", "Full", "ThreeD"},
		Default = "Corner"
	})
	BoxStyleDropdown:OnChanged(function(Value)
		ESP.Settings.BoxStyle = Value
	end)

	local ChamsSection = Tabs.ESP:AddSection("Chams")

	local ChamsToggle = ChamsSection:AddToggle("ChamsEnabled", {
		Title = "Enable Chams",
		Default = false
	})
	ChamsToggle:OnChanged(function()
		ESP.Settings.ChamsEnabled = ChamsToggle.Value
	end)

	local ChamsFillColor = ChamsSection:AddColorpicker("ChamsFillColor", {
		Title = "Fill Color",
		Description = "Color for visible parts",
		Default = ESP.Settings.ChamsFillColor
	})
	ChamsFillColor:OnChanged(function(Value)
		ESP.Settings.ChamsFillColor = Value
	end)

	local ChamsOccludedColor = ChamsSection:AddColorpicker("ChamsOccludedColor", {
		Title = "Occluded Color",
		Description = "Color for parts behind walls",
		Default = ESP.Settings.ChamsOccludedColor
	})
	ChamsOccludedColor:OnChanged(function(Value)
		ESP.Settings.ChamsOccludedColor = Value
	end)

	local ChamsOutlineColor = ChamsSection:AddColorpicker("ChamsOutlineColor", {
		Title = "Outline Color",
		Description = "Color for character outline",
		Default = ESP.Settings.ChamsOutlineColor
	})
	ChamsOutlineColor:OnChanged(function(Value)
		ESP.Settings.ChamsOutlineColor = Value
	end)

	local ChamsTransparency = ChamsSection:AddSlider("ChamsTransparency", {
		Title = "Fill Transparency",
		Description = "Transparency of the fill color",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Rounding = 2
	})
	ChamsTransparency:OnChanged(function(Value)
		ESP.Settings.ChamsTransparency = Value
	end)

	local ChamsOutlineTransparency = ChamsSection:AddSlider("ChamsOutlineTransparency", {
		Title = "Outline Transparency",
		Description = "Transparency of the outline",
		Default = 0,
		Min = 0,
		Max = 1,
		Rounding = 2
	})
	ChamsOutlineTransparency:OnChanged(function(Value)
		ESP.Settings.ChamsOutlineTransparency = Value
	end)

	local ChamsOutlineThickness = ChamsSection:AddSlider("ChamsOutlineThickness", {
		Title = "Outline Thickness",
		Description = "Thickness of the outline",
		Default = 0.1,
		Min = 0,
		Max = 1,
		Rounding = 2
	})
	ChamsOutlineThickness:OnChanged(function(Value)
		ESP.Settings.ChamsOutlineThickness = Value
	end)

	local HealthSection = Tabs.ESP:AddSection("Health ESP")

	local HealthESPToggle = HealthSection:AddToggle("HealthESP", {
		Title = "Health Bar",
		Default = false
	})
	HealthESPToggle:OnChanged(function()
		ESP.Settings.HealthESP = HealthESPToggle.Value
	end)

	local HealthStyleDropdown = HealthSection:AddDropdown("HealthStyle", {
		Title = "Health Style",
		Values = {"Bar", "Text", "Both"},
		Default = "Bar"
	})
	HealthStyleDropdown:OnChanged(function(Value)
		ESP.Settings.HealthStyle = Value
	end)
end

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("AuraHub")
SaveManager:SetFolder("AuraHub/blackout-revival")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()


local function Unload()
	Aiming.Unload()

	for _, Item in ipairs(Collection) do

		if typeof(Item) == 'RBXScriptConnection' then
			Item:Disconnect()
		end

		if type(Item) == 'thread' then
			coroutine.close(Item)
		end

	end

	for _, Event in next, BlockedEvents do
		RestoreConnections(Event)
	end

	for _, Limb in ipairs(Limbs) do
		LocalPlayer.Character:FindFirstChild(Limb).CanCollide = true
	end

	for _, Hook in next, HookStorage do
		hookfunction(Hook, Hook)
	end

	Unloaded = true
end

task.spawn(function()
	repeat task.wait() until Fluent.Unloaded
	pcall(Unload)
end)

-- Hooks

local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)

	if not Unloaded then
		if not checkcaller() then
			local Args = {...}
			local Method = getnamecallmethod()

			if Method == "FireServer" then
				if self.Name == "Shoot" then
					if Options.SA_Toggle.Value then
						if Aiming.CurrentTarget and typeof(Aiming.CurrentTarget) == "Instance" and Aiming.CurrentTarget:IsA("Model") then
							local limb = Aiming.CurrentTarget:FindFirstChild(Options.SA_TargetPart.Value)
							if limb and not shared.MissNextShot then			
								Remotes.GunHit:FireServer(
									limb,
									Args[6]
								)
							end
						end
					end	
				end
			end
		end
	end

	return OldNamecall(self, ...)
end)

local FireHook

local OldFire; OldFire = hookfunction(FastCast.Fire, function(...)
	return FireHook(...)
end)

FireHook = function(...)

	if not Unloaded then
		local Args = {...}
		local Caller = getcallingscript()

		if tostring(Caller) == "GunHandler" then

			shared.MissNextShot = Miss()

			if not shared.MissNextShot then
				if Options.SA_Toggle.Value then
					if Aiming.CurrentTarget then
						Args[3] = (Aiming.CurrentTarget[Options.SA_TargetPart.Value].Position - Args[2])
					end
				end
			end

			return OldFire(unpack(Args))
		end
	end

	return OldFire(...)
end

-- Loaded

Fluent:Notify({
	Title = "Aura Hub",
	Content = "The script has been loaded.",
	Duration = 5
})
