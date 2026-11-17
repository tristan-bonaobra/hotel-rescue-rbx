if not script.Parent:IsA("Model") then
    return
end

------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
------------------------------------------------------------------------------------------

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))
local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local entityScriptsLib = ServerScriptService:WaitForChild("EntityScripts")
local effectsLib = ServerStorage:WaitForChild("Effects")
local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local npc = script.Parent
local root = npc:WaitForChild("HumanoidRootPart")
local head = npc:WaitForChild("Head")

local dizzyFace = NpcUtils.personalityFacesLib:WaitForChild("Dizzy"):Clone()
local vomitFace = NpcUtils.personalityFacesLib:WaitForChild("Vomit"):Clone()
local pukeEffect = effectsLib:WaitForChild("Puke"):Clone()

local isDoomed

------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------

local function getNearbyVehicleSeat()
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = {toolDebrisBin}

    local parts = workspace:GetPartBoundsInRadius(root.Position, 10, overlapParams)
    for _, part in parts do
        if part:IsA("VehicleSeat") then
            return part
        end
    end

    return nil
end

local function rideSpeedCheck()
    if isDoomed or (not npc:GetAttribute("IsMounted")) then
        return false
    end

    local seat = getNearbyVehicleSeat()
    if not seat then
        return false
    else
        local linearVelocity = seat.AssemblyLinearVelocity.Magnitude
        local angularVelocity = seat.AssemblyAngularVelocity.Magnitude
        local totalVelocity = linearVelocity + angularVelocity
        local maxSpeed = seat.MaxSpeed
        local isTooFast = math.round(totalVelocity) >= math.round(maxSpeed) * Config.NPC_TRIP_IMPACT_PCT

        return isTooFast
    end
end

local function puke()
    pukeEffect.Parent = head
    NpcUtils.replaceFace(npc, vomitFace)
    SoundUtils.playSound(head, "Entity.NpcVomit1")
    SoundUtils.playSound(head, "Entity.NpcVomit2")
    task.wait(Config.NPC_PUKE_DURATION)
    pukeEffect:Destroy()
end

local function knockout()
    isDoomed = true
    puke()

    local ragdollScript = entityScriptsLib:WaitForChild("NpcRagdollScript"):Clone()
    ragdollScript.Parent = npc
    script:Destroy()
end

local function trip()
    if npc:FindFirstChild("NpcTripScript")
        or npc:GetAttribute("IsUnconscious")
        or npc:GetAttribute("IsMounted")
        or isDoomed
    then
        return
    end

    local tripScript = entityScriptsLib:WaitForChild("NpcTripScript"):Clone()
    tripScript.Parent = npc
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

npc:SetAttribute("IsDizzy", true)
NpcUtils.replaceFace(npc, dizzyFace)

RunService.Heartbeat:Connect(function()
    if rideSpeedCheck() then
        knockout()
    end
end)

local min = Config.NPC_UTTERANCE_INTERVAL_MIN
local max = Config.NPC_UTTERANCE_INTERVAL_MAX
while task.wait(math.random(min, max)) do
    trip()
end