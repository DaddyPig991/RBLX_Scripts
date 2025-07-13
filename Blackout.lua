Unloaded = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local Ragdoll = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("Ragdoll")
local DebrisFolder = workspace:WaitForChild("Debris")
local HitChance = 100

local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/DaddyPig991/RBLX_Scripts/refs/heads/main/Aiming.lua"))()

Aiming.Enabled = true
Aiming.FOV = 180
Aiming.FOVColor = Color3.fromRGB(255, 255, 255)
Aiming.NPCs = true
Aiming.Players = false

local Collection = {}
function Collect(Item : RBXScriptConnection | thread)
	table.insert(Collection, Item)
end

local FastCast = require(ReplicatedStorage.Mods.FastCast)

local Remotes = {
	GunShoot = ReplicatedStorage.GunStorage.Events.Shoot,
	GunHit = ReplicatedStorage.GunStorage.Events.Hit,
}

local Limbs = {
	"Head",
	"Torso"
}

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

Collect(ProximityPromptService.PromptButtonHoldBegan:Connect(function(ProximityPrompt : ProximityPrompt)
	fireproximityprompt(ProximityPrompt)
end))

local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)

	if not Unloaded then
		if not checkcaller() then
			local Args = {...}
			local Method = getnamecallmethod()

			if Method == "FireServer" then
				if self.Name == "Shoot" then
					if Aiming.CurrentTarget and typeof(Aiming.CurrentTarget) == "Instance" and Aiming.CurrentTarget:IsA("Model") then
						local head = Aiming.CurrentTarget:FindFirstChild("Head")
						if head and not shared.MissNextShot then			
							Remotes.GunHit:FireServer(
								head,
								Args[6]
							)
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
				if Aiming.CurrentTarget then
					Args[3] = (Aiming.CurrentTarget["Head"].Position - Args[2])
				end
			end

			return OldFire(unpack(Args))
		end
	end

	return OldFire(...)
end
