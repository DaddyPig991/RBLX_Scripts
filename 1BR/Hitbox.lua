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
  }
}

function Hitbox:UpdateHitbox(entity)
  print("UPDATING HITBOX")
end

local function IsValidNPC(model)
	return model:IsDescendantOf(workspace)
		and model:IsA("Model")
		and model:FindFirstChild("HumanoidRootPart")
		and CollectionService:HasTag(model, "ActiveCharacter")
		and not model:GetAttribute("ProtectFromPlayers")
end

local function AddNPC(npc)
	if IsValidNPC(npc) then
		Hitbox:UpdateHitbox(npc)
	end
end

Players.PlayerAdded:Connect(function(player)
	Hitbox:UpdateHitbox(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		Hitbox:UpdateHitbox(player)
	end
end

for _, npc in ipairs(CollectionService:GetTagged("NPC")) do
	AddNPC(npc)
end

CollectionService:GetInstanceAddedSignal("NPC"):Connect(AddNPC)

return Hitbox
