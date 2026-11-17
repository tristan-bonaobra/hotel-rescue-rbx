if not script.Parent:IsA("Model") then
    return
end

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))
local Config = require(ServerScriptService:WaitForChild("Config"))

local npc = script.Parent
local root = npc:WaitForChild("HumanoidRootPart")
local hum = npc:WaitForChild("Humanoid")

local newFace = NpcUtils.personalityFacesLib:WaitForChild("Panicked"):Clone()
local shake = Config.NPC_PANIC_CAR_SHAKE

npc:SetAttribute("IsPanicked", true)
NpcUtils.replaceFace(npc, newFace)
NpcUtils.playUtterances(npc, "Panicked")

local function forceSpin()
    root.AssemblyAngularVelocity = Vector3.new(0, Config.NPC_PANIC_ANGULAR_VELOCITY, 0)
end

local function shakeCar()
    local vehicleSeat = NpcUtils.getNearbyVehicleSeat(npc)
    if not vehicleSeat then
        return
    end

    local function r()
        return math.random(-shake, shake)
    end

    local car = vehicleSeat.Parent
    local body = car:WaitForChild("Body")
    body.AssemblyAngularVelocity += Vector3.new(r(), r(), r())
end

while RunService.Heartbeat:Wait() do
    if npc:GetAttribute("IsUnconscious") or npc:GetAttribute("IsRescued") then
        root.AssemblyAngularVelocity = Vector3.new()
        script:Destroy()
    elseif npc:GetAttribute("IsTripped") then
        continue
    elseif hum:GetState() == Enum.HumanoidStateType.Freefall then
        task.wait(0.5)
    else
        forceSpin()
        shakeCar()
    end
end