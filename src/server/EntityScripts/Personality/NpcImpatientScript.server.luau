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
    if followScriptA then
        task.wait(Config.NPC_IMPATIENT_RUSH_TIMER)
        local followScriptB = getFollowScript()
        if followScriptB then
            if followScriptB == followScriptA then
                followScriptB:Destroy()
                SoundUtils.playSound(head, "Entity.NpcAngry")
            else
                -- Refresh rush timer
                continue
            end
        end
    end

    if npc:GetAttribute("IsUnconscious") or npc:GetAttribute("IsRescued") then
        break
    end

    hum:MoveTo(getWinPos())
    hum.Jump = true
end