local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

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

local splat = script:WaitForChild("Splat"):Clone()
splat.Parent = torso
splat:Play()
game.Debris:AddItem(splat, splat.TimeLength + 2)

task.wait(Config.NPC_TRIP_DURATION)

hum.PlatformStand = false
char:SetAttribute("IsTripped", false)

local tumble = script:WaitForChild("Tumble"):Clone()
tumble.Parent = torso
tumble:Play()
game.Debris:AddItem(tumble, tumble.TimeLength + 2)

script:Destroy()