Unloaded = false

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = {
	MinigameResult = ReplicatedStorage.Events.Loot.MinigameResult,
	LootObject = ReplicatedStorage.Events.Loot.LootObject,
	Buy = ReplicatedStorage.Events.Stations.Buy,
	Minigame = ReplicatedStorage.Events.Loot.Minigame,
	Swing = ReplicatedStorage.MeleeStorage.Events.Swing,
	MeleeHit = ReplicatedStorage.MeleeStorage.Events.Hit,
	GunHit = ReplicatedStorage.GunStorage.Events.Hit,
	DialogEvent = ReplicatedStorage.Events.Dialogue.Event,
	TransferCurrency = ReplicatedStorage.Events.Stash.TransferCurrency
}

local Camera = Workspace.CurrentCamera
local WorldToScreen = Camera.WorldToScreenPoint
local GetMouseLocation = UserInputService.GetMouseLocation

local enemyFolder = Workspace:WaitForChild("NPCs"):WaitForChild("Custom")

-- SAFE Mouse Position
local function safeGetMouseLocation()
	return GetMouseLocation(UserInputService)
end

-- SAFE World to Screen
local function safeWorldToScreenPoint(worldPos)
	local screenPos, onScreen = WorldToScreen(Camera, worldPos)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Closest Zombie
local function getClosestZombie()
	local mousePos = safeGetMouseLocation()
	local closestDist = math.huge
	local closestEnemy = nil

	for _, enemy in pairs(enemyFolder:GetChildren()) do
		local head = enemy:FindFirstChild("Head")
		local humanoid = enemy:FindFirstChild("Humanoid")

		if head and humanoid and humanoid.Health > 0 then
			local screenPos, onScreen = safeWorldToScreenPoint(head.Position)
			if onScreen then
				local dist = (mousePos - screenPos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestEnemy = head
				end
			end
		end
	end

	if closestEnemy then
		print("✅ Found closest enemy:", closestEnemy.Parent.Name)
	end

	return closestEnemy
end

-- HOOK
local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)

	if not Unloaded then
		if not checkcaller() then
			local Args = {...}
			local Method = getnamecallmethod()

			if Method == "FireServer" then
				if self.Name == "Shoot" then
					task.delay(0.1, function()
						Remotes.GunHit:FireServer(
							Aiming.CurrentTarget[Options.SilentAimParts.Value],
							Args[6]
						)
					end)
				end
			end
		end
	end

	return OldNamecall(self, ...)
end)
