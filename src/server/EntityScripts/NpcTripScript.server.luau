local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local Config = require(ServerScriptService:WaitForChild("Config"))

local soundsLib = ServerStorage:WaitForChild("Sounds")
local npcSoundsLib = soundsLib:WaitForChild("Npc")

local char = script.Parent
local hum = char and char:FindFirstChildOfClass("Humanoid")

if (not hum) or char:GetAttribute("IsTripped") then
	return
end

hum.PlatformStand = true
char:SetAttribute("IsTripped", true)

local torso = char and char:WaitForChild("Torso")
local pos = torso.Position

char:PivotTo(CFrame.new(pos) * CFrame.Angles(math.rad(-90), 0 , 0))

local function playNpcSound(name)
	local sound = npcSoundsLib:WaitForChild(name):Clone()
	sound.Parent = torso
	sound:Play()
	Debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)
end

playNpcSound("NpcSplat")
task.wait(Config.NPC_TRIP_DURATION)
hum.PlatformStand = false
char:SetAttribute("IsTripped", false)
playNpcSound("NpcTumble")
script:Destroy()