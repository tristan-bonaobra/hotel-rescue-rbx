if (not script.Parent:IsA("Model"))
	or (script.Parent:GetAttribute("IsTripped"))
then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local Config = require(ServerScriptService:WaitForChild("Config"))

local soundsLib = ServerStorage:WaitForChild("Sounds")
local npcSoundsLib = soundsLib:WaitForChild("Npc")

local char = script.Parent
local hum = char:FindFirstChildOfClass("Humanoid")
local torso = char:WaitForChild("Torso")
local torsoPos = torso.Position

local function playNpcSound(name)
	local sound = npcSoundsLib:WaitForChild(name):Clone()
	sound.Parent = torso
	sound:Play()
	Debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)
end

hum.PlatformStand = true

char:PivotTo(CFrame.new(torsoPos) * CFrame.Angles(math.rad(-90), 0 , 0))

playNpcSound("NpcSplat")

char:SetAttribute("IsTripped", true)

task.wait(Config.NPC_TRIP_DURATION)

hum.PlatformStand = false

playNpcSound("NpcTumble")

char:SetAttribute("IsTripped", false)

script:Destroy()