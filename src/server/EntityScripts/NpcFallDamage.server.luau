local RunService = game:GetService("RunService")
local NpcLoader = require(script.Parent)
local HotelRescue = script.Parent.Parent
local Config = require(HotelRescue:WaitForChild("Config"))

local torsoHistories = {}

local function trackTorso(torso)
	torsoHistories[torso] = {}
end

local function untrackTorso(torso)
	torsoHistories[torso] = nil
end

RunService.Heartbeat:Connect(function()
	for torso, history in pairs(torsoHistories) do
		if (not torso) or (not torso:IsDescendantOf(workspace)) then
			torsoHistories[torso] = nil
			continue
		end

		local currentVelocity = torso.AssemblyLinearVelocity

		table.insert(history, currentVelocity)

		if #history > Config.NPC_IMPACT_FRAMES then
			table.remove(history, 1)
		end

		local oldestVelocity = history[1]
		local velocityChange = (currentVelocity - oldestVelocity).Magnitude
		
		local npc = torso.Parent
		local isUnconscious = npc and npc:GetAttribute("IsUnconscious")
		local isTripped = npc and npc:GetAttribute("IsTripped")
		
		if npc then
			if (velocityChange >= Config.NPC_IMPACT_THRESHOLD) and (not isUnconscious) then
				script:WaitForChild("RagdollScript"):Clone().Parent = npc
				untrackTorso(torso)
			elseif (velocityChange >= Config.NPC_IMPACT_THRESHOLD * Config.NPC_TRIP_IMPACT_PCT) and (not isTripped) then
				script:WaitForChild("TripScript"):Clone().Parent = npc
			end
		end
	end
end)

local Npcs = workspace:WaitForChild("Npcs")

local function registerNpc(npc)
	local torso = npc:WaitForChild("Torso", 5)
	if torso then
		trackTorso(torso)
	end
end

for _, npc in pairs(Npcs:GetChildren()) do
	registerNpc(npc)
end

Npcs.ChildAdded:Connect(registerNpc)