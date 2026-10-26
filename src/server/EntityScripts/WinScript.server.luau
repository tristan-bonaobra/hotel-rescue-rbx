if not script.Parent:IsA("Model") then
	return
end

------------------------------------------------------------------------------------------
-- DEPENDENCIES
------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))

local globalSoundsBin = workspace:WaitForChild("GlobalSounds")
local npcsBin = workspace:WaitForChild("Npcs")

local winZone = script.Parent
local winPart = winZone:WaitForChild("WinPart")
local npcSpotsFolder = winZone:WaitForChild("NpcSpots")
local npcSpotsConscious = npcSpotsFolder:WaitForChild("Conscious"):GetChildren()
local npcSpotsUnconscious = npcSpotsFolder:WaitForChild("Unconscious"):GetChildren()

local npcsRescued = 0

------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------

local function chooseSpot(isUnconscious)
	local spot
	if isUnconscious then
		local spotId = math.random(#npcSpotsUnconscious)
		spot = npcSpotsUnconscious[spotId]
		table.remove(npcSpotsUnconscious, spotId) -- Regen later
	else
		local spotId = math.random(#npcSpotsConscious)
		spot = npcSpotsConscious[spotId]
		table.remove(npcSpotsConscious, spotId)
	end
	return spot
end

local function rewardAllPlayersForRescue(isUnconscious)
	local points = (isUnconscious and Config.REWARD_UNCONSCIOUS) or Config.REWARD_CONSCIOUS
	for _, plr in Players:GetPlayers() do
		local leaderstats = plr:WaitForChild("leaderstats")
		local pointsObject = leaderstats:WaitForChild("Points")
		pointsObject.Value += points
	end
	local hint = Instance.new("Hint", workspace)
	hint.Text = "Survivor #"..npcsRescued.." was rescued for "..points.." point"..(((points > 1) and "s") or "").."!"
	game.Debris:AddItem(hint, 3)
	if isUnconscious then
		SoundUtils.playSound(globalSoundsBin, "Game.ShortSpringSound")
	else
		SoundUtils.playSound(globalSoundsBin, "Game.Money")
	end
end

------------------------------------------------------------------------------------------
-- ORCHESTRATION
------------------------------------------------------------------------------------------

winPart.Touched:Connect(function(hit)
	local npc = hit.Parent
	local hum = npc:FindFirstChildOfClass("Humanoid")
	local isInNpcFolder = npc:IsDescendantOf(npcsBin)
	local isRescued = npc:GetAttribute("IsRescued")
	local isUnconscious = npc:GetAttribute("IsUnconscious")
	if hum and isInNpcFolder and (not isRescued) then
		npcsRescued += 1
		npc:SetAttribute("IsRescued", true)
		rewardAllPlayersForRescue(isUnconscious)
		
		local spot = chooseSpot(isUnconscious)
		if spot then
			NpcUtils.poseNpcAtSpot(npc, spot)
		else
			npc:Destroy()
		end
	end
end)

for _, spot in npcSpotsFolder:GetDescendants() do
	if spot:IsA("BasePart") then
		spot.Transparency = 1
	end
end