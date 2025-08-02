local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local Hitbox = {
    Enabled = false,
    TargetNPC = true,
    TargetPlayers = false,
    Size = 2,
    Targets = {
        "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"
    },
    CurrentTarget = "Head",
    OriginalSizes = {}
}

function Hitbox:UpdateHitbox(model)
    if not self.Enabled then return end

    print("UPDATNG HITBOX")
    local part = model:FindFirstChild(self.CurrentTarget)
    if part and part:IsA("BasePart") then
        if not self.OriginalSizes[part] then
            self.OriginalSizes[part] = part.Size
        end
        part.Size = Vector3.new(self.Size, self.Size, self.Size)
        part.Material = Enum.Material.Plastic
        part.Transparency = 0.5
        part.CanCollide = false
    end
end

function Hitbox:RestoreHitbox(model)
    local part = model:FindFirstChild(self.CurrentTarget)
    if part and self.OriginalSizes[part] then
        part.Size = self.OriginalSizes[part]
        self.OriginalSizes[part] = nil
        part.Transparency = 0
        part.CanCollide = true
    end
end

function Hitbox:RefreshAll()
    -- NPCs
    for _, npc in ipairs(CollectionService:GetTagged("NPC")) do
        if self.TargetNPC and IsValidNPC(npc) then
            self:UpdateHitbox(npc)
        else
            self:RestoreHitbox(npc)
        end
    end
    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if self.TargetPlayers then
                self:UpdateHitbox(player.Character)
            else
                self:RestoreHitbox(player.Character)
            end
        end
    end
end

function Hitbox:Enable()
    self.Enabled = true
    self:RefreshAll()
end

function Hitbox:Disable()
    self.Enabled = false
    self:RefreshAll()
end

-- Helper for NPC check
function IsValidNPC(model)
    return model:IsDescendantOf(workspace)
        and model:IsA("Model")
        and model:FindFirstChild("HumanoidRootPart")
        and CollectionService:HasTag(model, "ActiveCharacter")
        and not model:GetAttribute("ProtectFromPlayers")
end

-- Connections for runtime
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if Hitbox.TargetPlayers and Hitbox.Enabled then
            Hitbox:UpdateHitbox(character)
        end
    end)
end)

CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(npc)
    if Hitbox.TargetNPC and Hitbox.Enabled and IsValidNPC(npc) then
        Hitbox:UpdateHitbox(npc)
    end
end)

-- For initial load
Hitbox:RefreshAll()

return Hitbox
