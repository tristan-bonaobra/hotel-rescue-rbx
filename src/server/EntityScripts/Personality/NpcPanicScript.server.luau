if not script.Parent:IsA("Model") then
    return
end

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local npc = script.Parent
local root = npc:WaitForChild("HumanoidRootPart")
local hum = npc:WaitForChild("Humanoid")

while RunService.Heartbeat:Wait() do
    if npc:GetAttribute("IsUnconscious") or npc:GetAttribute("IsRescued") then
        root.AssemblyAngularVelocity = Vector3.new()
        script:Destroy()
    elseif npc:GetAttribute("IsTripped") then
        continue
    elseif hum:GetState() == Enum.HumanoidStateType.Freefall then
        task.wait(0.5)
    else
        root.AssemblyAngularVelocity = Vector3.new(0, Config.NPC_PANIC_ANGULAR_VELOCITY, 0)
    end
end