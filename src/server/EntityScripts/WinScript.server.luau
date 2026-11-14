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

local function rewardAllPlayersForRescue(npc)
	local isUnconscious = npc:GetAttribute("IsUnconscious")
	local isPanicked = npc:GetAttribute("IsPanicked")

	local pointsRewarded

	if isUnconscious then
		pointsRewarded = Config.REWARD_UNCONSCIOUS
	else
		if isPanicked then
			pointsRewarded = Config.REWARD_PANICKED
		else
			pointsRewarded = Config.REWARD_CONSCIOUS
		end
	end

	for _, plr in Players:GetPlayers() do
		local leaderstats = plr:WaitForChild("leaderstats")
		local pointsObject = leaderstats:WaitForChild("Points")
		pointsObject.Value += pointsRewarded
	end
	local hint = Instance.new("Hint", workspace)
	hint.Text = "Survivor #"..npcsRescued.." was rescued for "..pointsRewarded.." point"..(((pointsRewarded > 1) and "s") or "").."!"
	game.Debris:AddItem(hint, 3)
	if isUnconscious then
		SoundUtils.playSound(globalSoundsBin, "Game.ShortSpringSound")
	else
		SoundUtils.playSound(globalSoundsBin, "Game.Money")
	end
end

local function clearDebris()
	local currentMap = workspace:FindFirstChild("CurrentMap")

	if not currentMap then
		return
	end

	local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = {currentMap}

    local zoneCFrame, zoneSize = winZone:GetBoundingBox()
    local hitDebris = workspace:GetPartBoundsInBox(zoneCFrame, zoneSize, overlapParams)
  
    for _, hit in hitDebris do
        hit:Destroy()
    end
end

------------------------------------------------------------------------------------------
-- ORCHESTRATION
------------------------------------------------------------------------------------------

clearDebris()

winPart.Touched:Connect(function(hit)
	local npc = hit.Parent
	local hum = npc:FindFirstChildOfClass("Humanoid")
	local isInNpcFolder = npc:IsDescendantOf(npcsBin)
	local isRescued = npc:GetAttribute("IsRescued")
	local isUnconscious = npc:GetAttribute("IsUnconscious")
	local isMounted = npc:GetAttribute("IsMounted")

	if hum and isInNpcFolder and (not isRescued) and (not isMounted) then
		npcsRescued += 1
		npc:SetAttribute("IsRescued", true)
		rewardAllPlayersForRescue(npc)
		
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