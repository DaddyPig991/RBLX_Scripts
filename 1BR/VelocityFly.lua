local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local VelocityFly = {}

VelocityFly.LoopFunction = function()
    if VelocityFly.Enabled == true then
        local MovementInputDetected = false

        for _, KeyObject in pairs(UserInputService:GetKeysPressed()) do
            if KeyObject.KeyCode == Enum.KeyCode.W then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + (Camera.CFrame.LookVector.Unit * VelocityFly.Speed)
            end
            if KeyObject.KeyCode == Enum.KeyCode.D then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + (Camera.CFrame.LookVector:Cross(Vector3.new(0, 1, 0)).Unit * VelocityFly.Speed)
            end
            if KeyObject.KeyCode == Enum.KeyCode.A then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + (Camera.CFrame.LookVector:Cross(Vector3.new(0, -1, 0)).Unit * VelocityFly.Speed)
            end
            if KeyObject.KeyCode == Enum.KeyCode.S then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + ((Camera.CFrame.LookVector.Unit * - 1) * VelocityFly.Speed)
            end
            if KeyObject.KeyCode == Enum.KeyCode.E then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + (Camera.CFrame.UpVector.Unit * VelocityFly.Speed)
            end
            if KeyObject.KeyCode == Enum.KeyCode.Q then
                MovementInputDetected = true
                VelocityFly.TargetCFrame = VelocityFly.TargetCFrame + (Camera.CFrame.UpVector.Unit * -VelocityFly.Speed)
            end
        end

        if not MovementInputDetected then
            VelocityFly.TargetCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, (workspace.Gravity / 196.1999969482422), 0)
        end

        LocalPlayer.Character.HumanoidRootPart.Velocity = (VelocityFly.TargetCFrame.Position - LocalPlayer.Character.HumanoidRootPart.Position)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.p) * Camera.CFrame.Rotation
    end
end

VelocityFly.Speed = 1
VelocityFly.Enabled = false
VelocityFly.TargetCFrame = CFrame.new(0,0,0)
VelocityFly.HeartbeatConnection = nil

function VelocityFly:Toggle(State)
    self.Enabled = State
    if State == true then
        if VelocityFly.HeartbeatConnection and VelocityFly.HeartbeatConnection.Connected then
            VelocityFly.HeartbeatConnection:Disconnect()
            VelocityFly.HeartbeatConnection = nil
        end
        VelocityFly.HeartbeatConnection = RunService.Heartbeat:Connect(VelocityFly.LoopFunction)
        VelocityFly.TargetCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        if VelocityFly.HeartbeatConnection and VelocityFly.HeartbeatConnection.Connected then
            VelocityFly.HeartbeatConnection:Disconnect()
            VelocityFly.HeartbeatConnection = nil
        end
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

return VelocityFly
