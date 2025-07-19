Unloaded = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/DaddyPig991/RBLX_Scripts/refs/heads/main/1BR/Aiming.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DaddyPig991/RBLX_Scripts/refs/heads/main/1BR/ESP.lua"))()

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
	LootObject = ReplicatedStorage.Events.Loot.LootObject,
	GunHit = ReplicatedStorage.GunStorage.Events.Hit,
	Swing = ReplicatedStorage.MeleeStorage.Events.Swing,
	MeleeHit = ReplicatedStorage.MeleeStorage.Events.Hit,
}

local Functions

local HookStorage = {}
local AttributeSpoof = {}

local BlockedEvents = {}

local Limbs = {
	"Head",
	"Torso"
}

local Characters = workspace:WaitForChild("Chars")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Options = Fluent.Options

local FakeMouse = Drawing.new("Circle")
FakeMouse.Radius = 3
FakeMouse.Filled = true
FakeMouse.Color = Color3.fromRGB(255, 255, 255)
FakeMouse.Transparency = 1
FakeMouse.ZIndex = 999999
FakeMouse.Visible = true

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

local function LockState(Key : string, Value : any)
	AttributeSpoof[LocalPlayer.PlayerGui] = {Key = Key, Value = Value}
end

local function FreeState(Key : string)
	AttributeSpoof[LocalPlayer.PlayerGui] = nil
end

Functions = {}

Functions.GuiHooks = function()
	local Gui = LocalPlayer:WaitForChild("PlayerGui")
	local MainGui = Gui:WaitForChild("MainGui")
	local Minimap = MainGui:WaitForChild("Minimap")

	do
		local NoSignal = Minimap:WaitForChild("NoSignal")
		local MapFrame = Minimap:WaitForChild("TabsFrame")

		Collect(NoSignal:GetPropertyChangedSignal("Visible"):Connect(function()
			if NoSignal.Visible and Options.AlwaysMap.Value then
				NoSignal.Visible = false
			end
		end))

		Collect(MapFrame:GetPropertyChangedSignal("Visible"):Connect(function()
			if (not MapFrame.Visible) and Options.AlwaysMap.Value then
				MapFrame.Visible = true
			end
		end))
	end
end

Functions.CharacterAdded = function(Character)
	Functions.GuiHooks()
end

-- Collections

Collect(Remotes.LootObject.OnClientEvent:Connect(function(LootTable : Folder)
	if Options.AutoLootValuables_Toggle.Value then
		Remotes.LootObject:FireServer(LootTable, "Valuables")
	end

	if Options.AutoLootCash_Toggle.Value then
		Remotes.LootObject:FireServer(LootTable, "Cash")
	end
end))

Collect(ProximityPromptService.PromptButtonHoldBegan:Connect(function(ProximityPrompt : ProximityPrompt)
	if Options.ProxPrompt_Toggle.Value then
		fireproximityprompt(ProximityPrompt)
	end
end))

local KillAuraCoroutine = coroutine.create(function()
	while task.wait(.5) do
		if Options.Aura_Toggle.Value and LocalPlayer.Character then
			if not (LocalPlayer.Character:FindFirstChild("ServerMeleeModel")) then
				continue
			end

			local Range = Options.Aura_Range_Slider.Value
			local TargetPart = Options.Aura_TargetPart.Value

			local TargetNPCs = Options.Aura_NPCs_Toggle.Value
			local TargetPlayers = Options.Aura_Players_Toggle.Value

			if TargetPlayers then

				local FilteredPlayers = {}

				for _, Player in ipairs(Characters:GetChildren()) do
					if not Player:GetAttribute("Downed") then
						table.insert(FilteredPlayers, Player)
					end
				end

				local Closest, ClosestRange = GetClosest(FilteredPlayers, LocalPlayer.Character:GetPivot().Position)
				if Closest and ClosestRange <= Range then

					local Limb = Closest:FindFirstChild(TargetPart)
					if Limb then
						local Result = Remotes.Swing:InvokeServer()

						if Result then
							task.wait(Result.Delay or 0.25)
							Remotes.MeleeHit:FireServer(Limb, Limb.Position)
						end
					end

					continue

				end
			end

			if TargetNPCs then

				local FilteredNPCs = {}

				-- for _, NPC in ipairs(NPCs.Hostile:GetChildren()) do
				--     if not NPC:GetAttribute("Downed") then
				--         table.insert(FilteredNPCs, NPC)
				--     end
				-- end

				for _, NPC in next, CollectionService:GetTagged("NPC") do
					if NPC:IsDescendantOf(workspace) and NPC:IsA("Model") and NPC:FindFirstChild("HumanoidRootPart") and CollectionService:HasTag(NPC, "ActiveCharacter") and not NPC:GetAttribute("ProtectFromPlayers") then
						table.insert(FilteredNPCs, NPC)
					end
				end

				local Closest, ClosestRange = GetClosest(FilteredNPCs, LocalPlayer.Character:GetPivot().Position)
				if Closest and ClosestRange <= Range then

					local Limb = Closest:FindFirstChild(TargetPart)
					if Limb then
						local Result = Remotes.Swing:InvokeServer()

						if Result then
							task.wait(Result.Delay or 0.25)
							Remotes.MeleeHit:FireServer(Limb, Limb.Position)
						end
					end
				end
			end
		end
	end
end)

Collect(KillAuraCoroutine)

Collect(LocalPlayer.CharacterAdded:Connect(Functions.CharacterAdded))

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
	Aim = Window:AddTab({ Title = "Aim", Icon = "crosshair" }),
	ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
	Main = Window:AddTab({ Title = "Misc", Icon = "menu" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

do
	
	local Misc_Section = Tabs.Main:AddSection("Misc")
	
	local Misc_Stamina_Toggle = Tabs.Main:AddToggle("Stamina_Toggle", {
		Title = "Infinite Stamina",
		Default = false,
		Callback = function(state)
			if state then
				LockState("Stamina", 100)
			else
				FreeState("Stamina")
			end
		end 
	})
	
	local Misc_PP_Toggle = Tabs.Main:AddToggle("ProxPrompt_Toggle", {
		Title = "Instant Interact",
		Description = "Instantly Bypass All Prompts",
		Default = false,
	})
	
	local Misc_Map_Toggle = Tabs.Main:AddToggle("AlwaysMap_Toggle", {
		Title = "Always Map",
		Description = "Always Show Map Even When There Is No Signal",
		Default = false 
	})
	
	local Misc_AutoLootCash_Toggle = Tabs.Main:AddToggle("AutoLootCash_Toggle", {
		Title = "Auto Loot Cash",
		Description = "Automatically Loot Cash when possible",
		Default = false 
	})
	
	local Misc_AutoLootValuables_Toggle = Tabs.Main:AddToggle("AutoLootValuables_Toggle", {
		Title = "Auto Loot Valuables",
		Description = "Automatically Loot Valuables when possible",
		Default = false 
	})
end

do
	local Section = Tabs.Aim:AddSection("Silent Aim")

	local Toggle = Tabs.Aim:AddToggle("SA_Toggle", {Title = "Enabled", Default = Aiming.Enabled })

	Toggle:OnChanged(function()
		Aiming.Enabled = Options.SA_Toggle.Value
	end)

	local Slider = Tabs.Aim:AddSlider("SA_FOV_Slider", {
		Title = "FOV",
		Description = "Default (180) probably will work the best",
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
	
	local SA_NPCs_Toggle = Tabs.Aim:AddToggle("SA_NPCs_Toggle", {
		Title = "NPCs",
		Description = "Silent Aim NPCs",
		Default = Aiming.NPCs,
		Callback = function(Value)
			Aiming.NPCs = Value
		end
	})

	local SA_Players_Toggle = Tabs.Aim:AddToggle("SA_Players_Toggle", {
		Title = "Players",
		Description = "Silent Aim Players",
		Default = Aiming.Players,
		Callback = function(Value)
			Aiming.Players = Value
		end
	})
	
	local Aura_Section = Tabs.Aim:AddSection("Aura Kill")
	
	local Aura_Toggle = Tabs.Aim:AddToggle("Aura_Toggle", {
		Title = "Enabled",
		Description = "Tries to Kill Zombies with Meele automatically",
		Default = false,
	})
	
	local Aura_Slider = Tabs.Aim:AddSlider("Aura_Range_Slider", {
		Title = "Range",
		Description = "Range from which Aura Kill will try to kill Zombies",
		Default = 10,
		Min = 1,
		Max = 100,
		Rounding = 0,
	})

	local Aura_Input = Tabs.Aim:AddInput("Aura_Range_Input", {
		Title = "Range Input",
		Default = 10,
		Placeholder = "Aura Range",
		Numeric = true, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter
		Callback = function(Value)
			Aura_Slider:SetValue(Value)
		end
	})
	
	local Aura_Dropdown = Tabs.Aim:AddDropdown("Aura_TargetPart", {
		Title = "Target",
		Values = Limbs,
		Multi = false,
		Default = 1,
	})
	
	local Aura_NPCs_Toggle = Tabs.Aim:AddToggle("Aura_NPCs_Toggle", {
		Title = "NPCs",
		Description = "Aura Kill NPCs",
		Default = true,
	})
	
	local Aura_Players_Toggle = Tabs.Aim:AddToggle("Aura_Players_Toggle", {
		Title = "Players",
		Description = "Aura Kill Players",
		Default = false,
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
	
	local SkeletonSection = Tabs.ESP:AddSection("Skeleton ESP")

	local SkeletonESPToggle = SkeletonSection:AddToggle("SkeletonESP", {
		Title = "Skeleton ESP",
		Default = false
	})
	SkeletonESPToggle:OnChanged(function()
		ESP.Settings.SkeletonESP = SkeletonESPToggle.Value
	end)

	local SkeletonColor = SkeletonSection:AddColorpicker("SkeletonColor", {
		Title = "Skeleton Color",
		Default = ESP.Settings.SkeletonColor
	})
	SkeletonColor:OnChanged(function(Value)
		ESP.Settings.SkeletonColor = Value
		for _, player in ipairs(Players:GetPlayers()) do
			local skeleton = ESP.Drawings.Skeleton[player]
			if skeleton then
				for _, line in pairs(skeleton) do
					line.Color = Value
				end
			end
		end
	end)

	local SkeletonThickness = SkeletonSection:AddSlider("SkeletonThickness", {
		Title = "Line Thickness",
		Default = 1,
		Min = 1,
		Max = 3,
		Rounding = 1
	})
	SkeletonThickness:OnChanged(function(Value)
		ESP.Settings.SkeletonThickness = Value
		for _, player in ipairs(Players:GetPlayers()) do
			local skeleton = ESP.Drawings.Skeleton[player]
			if skeleton then
				for _, line in pairs(skeleton) do
					line.Thickness = Value
				end
			end
		end
	end)

	local SkeletonTransparency = SkeletonSection:AddSlider("SkeletonTransparency", {
		Title = "Transparency",
		Default = 1,
		Min = 0,
		Max = 1,
		Rounding = 2
	})
	SkeletonTransparency:OnChanged(function(Value)
		ESP.Settings.SkeletonTransparency = Value
		for _, player in ipairs(Players:GetPlayers()) do
			local skeleton = ESP.Drawings.Skeleton[player]
			if skeleton then
				for _, line in pairs(skeleton) do
					line.Transparency = Value
				end
			end
		end
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
	ESP.Unload()

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

if LocalPlayer.Character then
	Functions.CharacterAdded(LocalPlayer.Character)
end

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
			elseif Method == "GetAttribute" then
				if AttributeSpoof[self] and AttributeSpoof[self].Key == Args[1] then
					return AttributeSpoof[self].Value
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

coroutine.resume(KillAuraCoroutine)

RunService.RenderStepped:Connect(function()
	local pos = UserInputService:GetMouseLocation()
	FakeMouse.Position = Vector2.new(pos.X, pos.Y)
end)

-- Loaded

Fluent:Notify({
	Title = "Aura Hub",
	Content = "The script has been loaded.",
	Duration = 5
})
