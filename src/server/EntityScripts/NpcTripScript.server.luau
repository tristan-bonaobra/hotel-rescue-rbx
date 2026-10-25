if (not script.Parent:IsA("Model"))
	or (script.Parent:GetAttribute("IsTripped"))
then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local char = script.Parent
local hum = char:FindFirstChildOfClass("Humanoid")
local torso = char:WaitForChild("Torso")
local torsoPos = torso.Position

hum.PlatformStand = true

char:PivotTo(CFrame.new(torsoPos) * CFrame.Angles(math.rad(-90), 0 , 0))

SoundUtils.playSound(torso, "Npc.NpcSplat")

char:SetAttribute("IsTripped", true)

task.wait(Config.NPC_TRIP_DURATION)

hum.PlatformStand = false

SoundUtils.playSound(torso, "Npc.NpcTumble")

char:SetAttribute("IsTripped", false)

script:Destroy()