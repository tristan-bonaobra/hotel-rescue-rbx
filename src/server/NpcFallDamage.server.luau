----------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
----------------------------------------------------------------------------------------------

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local entityScriptsLib = ServerScriptService:WaitForChild("EntityScripts")

local npcsBin = workspace:WaitForChild("Npcs")

local torsoHistories = {}

----------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------

local function trackTorso(torso)
	torsoHistories[torso] = {}
end

local function untrackTorso(torso)
	torsoHistories[torso] = nil
end

local function registerNpc(npc)
	local torso = npc:WaitForChild("Torso", 5)
	if torso then
		trackTorso(torso)
	end
end

----------------------------------------------------------------------------------------------
-- HEARTBEAT AND EVENTS
----------------------------------------------------------------------------------------------

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
				entityScriptsLib:WaitForChild("RagdollScript"):Clone().Parent = npc
				untrackTorso(torso)
			elseif (velocityChange >= Config.NPC_IMPACT_THRESHOLD * Config.NPC_TRIP_IMPACT_PCT) and (not isTripped) then
				entityScriptsLib:WaitForChild("TripScript"):Clone().Parent = npc
			end
		end
	end
end)

for _, npc in pairs(npcsBin:GetChildren()) do
	registerNpc(npc)
end

npcsBin.ChildAdded:Connect(registerNpc)