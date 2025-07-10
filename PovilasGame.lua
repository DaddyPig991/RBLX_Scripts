local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("POVILIUKO GAYMAS")

local serv = win:Server("POVILIUKAS", "")

local afChannel = serv:Channel("Autofarm")
local bgChannel = serv:Channel("Building")
local hdChannel = serv:Channel("Player")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local SensorPart = workspace:FindFirstChild("SensorPart")

local TURNEDON = false

-- AutoFarm
afChannel:Label("This will rape the game...")

afChannel:Toggle("Auto-Farm", false, function(bool)
	character = player.Character or player.CharacterAdded:Wait()
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	TURNEDON = bool
end)

afChannel:Label("Try this if something ain't work")

afChannel:Button("RESTART", function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	DiscordLib:Notification("Notification", "Restarted!", "FUCK YOU MONKEY!")
end)

-- Building
local BuildEvent = game:GetService("ReplicatedStorage"):WaitForChild("BuildEvent")

local function buildPart(partType, offset, rotationMatrix, hrp)
	local cf = hrp.CFrame * CFrame.new(offset) * rotationMatrix
	BuildEvent:FireServer("Build", partType, cf)
end

bgChannel:Label("Fun building stuff!")

bgChannel:Label("Full Box On Everyone!")

bgChannel:Button("Ful Box Everyone", function()
	for _, otherPlayerE in game.Players:GetPlayers() do
		local otherPlayerEChar = otherPlayerE.Character or otherPlayerE.CharacterAdded:Wait()
		local otherPlayerEHRP = otherPlayerEChar:WaitForChild("HumanoidRootPart")

		-- WALLS
		buildPart("Wall", Vector3.new(4, 0.13, -0.1), CFrame.Angles(0, math.rad(90), 0), otherPlayerEHRP)
		buildPart("Wall", Vector3.new(0, 0.13, -4.1), CFrame.Angles(0, math.rad(180), 0), otherPlayerEHRP)
		buildPart("Wall", Vector3.new(-4, 0.13, 0), CFrame.Angles(0, math.rad(270), 0), otherPlayerEHRP)
		buildPart("Wall", Vector3.new(0, 0.13, 4), CFrame.Angles(0, 0, 0), otherPlayerEHRP)

		-- FLOOR
		buildPart("Floor", Vector3.new(0, 3.125, 0), CFrame.new(), otherPlayerEHRP)
		buildPart("Floor", Vector3.new(0, -3, 0), CFrame.new(), otherPlayerEHRP)
	end
end)

bgChannel:Label("Full Box On One Chosen One!")

local chosenPlayer = ""

bgChannel:Label("!!!MAKE SURE TO PRESS ENTER AFTER WRITING THE NAME!!!")

bgChannel:Textbox("Choose Player", "Player name", false, function(t)
	chosenPlayer = t
end)

bgChannel:Button("Ful Box Player", function()
	local otherPlayer = game.Players:FindFirstChild(chosenPlayer)

	if otherPlayer then
		local otherPlayerChar = otherPlayer.Character or otherPlayer.CharacterAdded:Wait()
		local otherPlayerHRP = otherPlayerChar:WaitForChild("HumanoidRootPart")
		-- WALLS
		buildPart("Wall", Vector3.new(4, 0.13, -0.1), CFrame.Angles(0, math.rad(90), 0), otherPlayerHRP)
		buildPart("Wall", Vector3.new(0, 0.13, -4.1), CFrame.Angles(0, math.rad(180), 0), otherPlayerHRP)
		buildPart("Wall", Vector3.new(-4, 0.13, 0), CFrame.Angles(0, math.rad(270), 0), otherPlayerHRP)
		buildPart("Wall", Vector3.new(0, 0.13, 4), CFrame.Angles(0, 0, 0), otherPlayerHRP)

		-- FLOOR
		buildPart("Floor", Vector3.new(0, 3.125, 0), CFrame.new(), otherPlayerHRP)
		buildPart("Floor", Vector3.new(0, -3, 0), CFrame.new(), otherPlayerHRP)
	else
		DiscordLib:Notification("Notification", "PLAYER "..chosenPlayer.."NO EXIST!", "DAYUM!")
	end
end)

bgChannel:Label("Full Box On Yourself!")

bgChannel:Button("Ful Box You", function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- WALLS
	buildPart("Wall", Vector3.new(4, 0.13, -0.1), CFrame.Angles(0, math.rad(90), 0), humanoidRootPart)
	buildPart("Wall", Vector3.new(0, 0.13, -4.1), CFrame.Angles(0, math.rad(180), 0), humanoidRootPart)
	buildPart("Wall", Vector3.new(-4, 0.13, 0), CFrame.Angles(0, math.rad(270), 0), humanoidRootPart)
	buildPart("Wall", Vector3.new(0, 0.13, 4), CFrame.Angles(0, 0, 0), humanoidRootPart)

	-- FLOOR
	buildPart("Floor", Vector3.new(0, 3.125, 0), CFrame.new(), humanoidRootPart)
	buildPart("Floor", Vector3.new(0, -3, 0), CFrame.new(), humanoidRootPart)
end)

bgChannel:Label("Full Box On Spawn!")

bgChannel:Button("Ful Box Spawn", function()
	local spawnLocation = workspace:FindFirstChild("SpawnLocation")
	if not spawnLocation then DiscordLib:Notification("Notification", "SPAWN NO EXIST!", "DAYUM!") end

	local hrp = spawnLocation

	-- WALLS
	buildPart("Wall", Vector3.new(4, 2.63, 7.85), CFrame.new(), hrp) -- front-right
	buildPart("Wall", Vector3.new(-4, 2.63, 7.85), CFrame.new(), hrp) -- front-left

	buildPart("Wall", Vector3.new(-8, 2.63, 3.85), CFrame.Angles(0, math.rad(90), 0), hrp) -- left-front
	buildPart("Wall", Vector3.new(-8, 2.63, -4.15), CFrame.Angles(0, math.rad(90), 0), hrp) -- left-back

	buildPart("Wall", Vector3.new(4, 2.63, -8.15), CFrame.Angles(0, math.rad(180), 0), hrp) -- back-right
	buildPart("Wall", Vector3.new(-4, 2.63, -8.15), CFrame.Angles(0, math.rad(180), 0), hrp) -- back-right

	buildPart("Wall", Vector3.new(8, 2.63, -4.15), CFrame.Angles(0, math.rad(-90), 0), hrp) -- right-back
	buildPart("Wall", Vector3.new(8, 2.63, 3.85), CFrame.Angles(0, math.rad(-90), 0), hrp) -- right-front

	-- FLOORS (ceiling)
	buildPart("Floor", Vector3.new(4, 5.755, -4.15), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(4, 5.755, 3.85), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(-4, 5.755, -4.15), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(-4, 5.755, 3.85), CFrame.new(), hrp)
end)

bgChannel:Label("Full Box On ATM!")

bgChannel:Button("Ful Box ATM", function()
	local atm = workspace:FindFirstChild("ATM"):FindFirstChild("ATM")
	if not atm then DiscordLib:Notification("Notification", "ATM NO EXIST!", "DAYUM!") end

	local hrp = atm

	-- WALLS
	buildPart("Wall", Vector3.new(-3, 0.3, 0.15), CFrame.Angles(0, math.rad(90), 0), hrp) -- left
	buildPart("Wall", Vector3.new(1, 0.3, 4.15), CFrame.Angles(0, 0, 0), hrp) -- front
	buildPart("Wall", Vector3.new(1, 0.3, -3.85), CFrame.Angles(0, 0, 0), hrp) -- back
	buildPart("Wall", Vector3.new(5, 0.3, 0.15), CFrame.Angles(0, math.rad(-90), 0), hrp) -- right

	-- CEILING
	buildPart("Floor", Vector3.new(1, 3.425, 0.15), CFrame.new(), hrp)
end)

bgChannel:Label("Full Box On Money!")

bgChannel:Button("Ful Box Money", function()
	local sensor = workspace:FindFirstChild("SensorPart")
	if not sensor then DiscordLib:Notification("Notification", "SENSOR NO EXIST!", "DAYUM!") end

	local hrp = sensor

	-- Lower layer walls (y = -5.37 from top)
	buildPart("Wall", Vector3.new(-4.0687, -5.37, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(3.9313, -5.37, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(7.9313, -5.37, -3.3833), CFrame.Angles(0, math.rad(90), 0), hrp)
	buildPart("Wall", Vector3.new(7.9313, -5.37, 4.6167), CFrame.Angles(0, math.rad(90), 0), hrp)
	buildPart("Wall", Vector3.new(3.9313, -5.37, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(-4.0687, -5.37, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(-8.0687, -5.37, 4.6167), CFrame.Angles(0, math.rad(-90), 0), hrp)
	buildPart("Wall", Vector3.new(-8.0687, -5.37, -3.3833), CFrame.Angles(0, math.rad(-90), 0), hrp)

	-- Mid layer walls (y = 0.88 from center)
	buildPart("Wall", Vector3.new(3.9313, 0.88, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(-4.0687, 0.88, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(-8.0687, 0.88, -3.3833), CFrame.Angles(0, math.rad(-90), 0), hrp)
	buildPart("Wall", Vector3.new(-8.0687, 0.88, 4.6167), CFrame.Angles(0, math.rad(-90), 0), hrp)
	buildPart("Wall", Vector3.new(-4.0687, 0.88, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(3.9313, 0.88, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(7.9313, 0.88, 4.6167), CFrame.Angles(0, math.rad(90), 0), hrp)
	buildPart("Wall", Vector3.new(7.9313, 0.88, -3.3833), CFrame.Angles(0, math.rad(90), 0), hrp)

	-- Top layer walls (y = 7.13 from center)
	buildPart("Wall", Vector3.new(7.9313, 7.13, -3.3833), CFrame.Angles(0, math.rad(90), 0), hrp)
	buildPart("Wall", Vector3.new(3.9313, 7.13, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(-4.0687, 7.13, -7.3833), CFrame.new(), hrp)
	buildPart("Wall", Vector3.new(-8.0687, 7.13, -3.3833), CFrame.Angles(0, math.rad(-90), 0), hrp)
	buildPart("Wall", Vector3.new(-8.0687, 7.13, 4.6167), CFrame.Angles(0, math.rad(-90), 0), hrp)
	buildPart("Wall", Vector3.new(-4.0687, 7.13, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(3.9313, 7.13, 8.6167), CFrame.Angles(0, math.rad(180), 0), hrp)
	buildPart("Wall", Vector3.new(7.9313, 7.13, 4.6167), CFrame.Angles(0, math.rad(90), 0), hrp)

	-- Ceiling (y = 10.255 from center)
	buildPart("Floor", Vector3.new(3.9313, 10.255, -3.3833), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(3.9313, 10.255, 4.6167), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(-4.0687, 10.255, -3.3833), CFrame.new(), hrp)
	buildPart("Floor", Vector3.new(-4.0687, 10.255, 4.6167), CFrame.new(), hrp)
end)

-- Player
hdChannel:Label("This will make you fast! (or slow idk)")

local speedsldr = hdChannel:Slider("WalkSpeed", 0, 1000, 16, function(t)
	character.Humanoid.WalkSpeed = t
end)

hdChannel:Button("Default", function()
	speedsldr:Change(16)
	DiscordLib:Notification("Notification", "Set to Default Value!", "FUCK YOU NIGGER!")
end)

hdChannel:Label("This will make you jump high! (or slow idk)")

local jumpsldr = hdChannel:Slider("JumpHeight", 0, 1000, 7.2, function(t)
	character.Humanoid.JumpHeight = t
end)

hdChannel:Button("Default", function()
	jumpsldr:Change(7.2)
	DiscordLib:Notification("Notification", "Set to Default Value!", "FUCK YOU NIGGER!")
end)

hdChannel:Label("Try this if something ain't work")

hdChannel:Button("RESTART", function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	DiscordLib:Notification("Notification", "Restarted!", "FUCK YOU MONKEY!")
end)

task.spawn(function()
	while true do
		if TURNEDON then
			local part = workspace:FindFirstChild("GoldenPart")
			if part then
				humanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 1, 0)
				task.wait(1)
			else
				humanoidRootPart.CFrame = SensorPart.CFrame + Vector3.new(0, 0.5, 0)
				task.wait(0.5)
				humanoidRootPart.CFrame = SensorPart.CFrame + Vector3.new(10, 0, 0)
			end
		end
		task.wait(0.2)
	end
end)
