local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Hitbox = {
	  Enabled = false,
	  TargetNPC = true,
	  TargetPlayers = false,
	  Size = 1,
	  Targets = {
	    "Head",
	    "Torso",
	    "Right Arm",
	    "Left Arm",
	    "Right Leg",
	    "Left Leg",
	  },
	CurrentTarget = "Head"
}

function Hitbox:UpdateHitbox(entity)
	local targetPart = entity:FindFirstChild(Hitbox.CurrentTarget)

	if targetPart then
		targetPart.Size = Vector3.new(Hitbox.Size, Hitbox.Size, Hitbox.Size)

		targetPart.Material = "Plastic"

		targetPart.Transparency = 0.5

		targetPart.CanCollide = false
	end
end

local function IsValidNPC(model)
	return model:IsDescendantOf(workspace)
		and model:IsA("Model")
		and model:FindFirstChild("HumanoidRootPart")
		and CollectionService:HasTag(model, "ActiveCharacter")
		and not model:GetAttribute("ProtectFromPlayers")
end

local function AddNPC(npc)
	if IsValidNPC(npc) and Hitbox.TargetNPC then
		Hitbox:UpdateHitbox(npc)
	end
end

Players.PlayerAdded:Connect(function(player)
	if Hitbox.TargetPlayers then
		Hitbox:UpdateHitbox(player)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		if Hitbox.TargetPlayers then
			Hitbox:UpdateHitbox(player)
		end
	end
end

for _, npc in ipairs(CollectionService:GetTagged("NPC")) do
	AddNPC(npc)
end

CollectionService:GetInstanceAddedSignal("NPC"):Connect(AddNPC)

return Hitbox
