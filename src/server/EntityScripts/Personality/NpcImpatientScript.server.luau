if not script.Parent:IsA("Model") then
    return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local npc = script.Parent
local newFace = NpcUtils.personalityFacesLib:WaitForChild("Impatient"):Clone()
local head = npc:WaitForChild("Head")
local hum = npc:WaitForChild("Humanoid")

npc:SetAttribute("IsImpatient", true)
NpcUtils.replaceFace(npc, newFace)

local function getFollowScript()
    return npc:FindFirstChild("NpcFollowScript")
end

local function getWinPos()
    local winZone = workspace:WaitForChild("WinZone", 60 * 5)
    local winPart = winZone:WaitForChild("WinPart")
    return winPart.Position
end

while task.wait(0.5) do
    local followScriptA = getFollowScript()
    local isMounted = npc:GetAttribute("IsMounted")
    local lastDismounted = npc:GetAttribute("LastDismounted")

    if followScriptA or isMounted then
        npc:SetAttribute("IsRushing", false)
        task.wait(Config.NPC_IMPATIENT_RUSH_TIMER)
    end

    if followScriptA then
        -- The reason for stopping rush was a follow command
        local followScriptB = getFollowScript()
        if followScriptB and (followScriptB == followScriptA) then
            -- The NPC is still following and it's by the same command
            followScriptB:Destroy()
        else
            -- A new command was given
            continue
        end
    end

    if isMounted and (npc:GetAttribute("LastDismounted") ~= lastDismounted) then
        -- The reason for stopping rush was a mount
        -- The NPC has dismounted and/or remounted since
        continue
    else
        -- The NPC has NOT dismounted since
    end

    if npc:GetAttribute("IsUnconscious") or npc:GetAttribute("IsRescued") then
        break
    end

    if not npc:GetAttribute("IsRushing") then
        SoundUtils.playSound(head, "Entity.NpcAngry")
    end

    npc:SetAttribute("IsRushing", true)
    hum:MoveTo(getWinPos())
    hum.Jump = true
end