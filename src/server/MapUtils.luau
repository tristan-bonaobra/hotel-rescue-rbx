-------------------------------------------------------------------------------------------
-- DEPENDENCIES
-------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))
local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local mapsLib = ServerStorage:WaitForChild("Maps")

local npcsBin = workspace:WaitForChild("Npcs")

-------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------------------

local function getSortedParts(map)
	local mapParts = {}
	for _, v in pairs(map:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(mapParts, v)
		end
	end
	table.sort(mapParts, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	return mapParts
end

local function cleanMap(map)
	for _, v in pairs(map:GetDescendants()) do
		for _, clean_object in Config.CLEAN_OBJECTS do
			if v:IsA(clean_object) then
				v:Destroy()
			end
		end
		
		if v:IsA("BasePart") and (not v.CanCollide) then
			v.CanCollide = true
		elseif v:IsA("Seat") or v:IsA("VehicleSeat") then
			v.Disabled = true
		elseif v:IsA("Humanoid") and v.Parent then
			v.Parent:Destroy()
		end
	end
end

local function anchorMap(map)
	for _,v in pairs(map:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Anchored = true
		end
	end
end

local function breakMap(map)
	for _, v in pairs(map:GetDescendants()) do
		if BrickUtils.isBreakable(v) then
			local breakParams = {
				Threshold = Config.BREAK_THRESHOLD_MAP,
				IsRecursive = true,
				Unanchor = false,
				Tint = false
			}
			BrickUtils.breakPart(v, breakParams)
		end
	end
	map:MakeJoints()
end

local function weldMap(map)
	local nCreatedWeldsTotal = 0
	for _, v in map:GetDescendants() do
		if v:IsA("BasePart") then
			local nCreatedWeldsSubtotal = BrickUtils.weldToAdjacent(v)
			
			nCreatedWeldsTotal += nCreatedWeldsSubtotal
			if nCreatedWeldsTotal % Config.WELDS_PER_FRAME == 0 then
				task.wait()
			end
		end
	end
end

local function getRandomMap()
	if #mapsLib:GetChildren() == 0 then
		mapsLib.ChildAdded:Wait()
	end
	
	local maps = mapsLib:GetChildren()
	return maps[math.random(#maps)]:Clone()
end

-------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
-------------------------------------------------------------------------------------------

local function loadMap()
	local currentMap = getRandomMap()
	currentMap.Name = "CurrentMap"
	
	task.wait(1)
	if not currentMap:GetAttribute("IsProcessed") then
		cleanMap(currentMap)
		anchorMap(currentMap)
		currentMap.Parent = workspace
		breakMap(currentMap)
		if currentMap:GetAttribute("ForWelding") then weldMap(currentMap) end
	else
		currentMap.Parent = workspace
	end

	return currentMap
end

local function crumbleMap(map)
	local sortedParts = getSortedParts(map)
	for _, v in pairs(sortedParts) do
		if (math.random(Config.CRUMBLE_DIE) == 1)
			and (not BrickUtils.isBuried(v))
			and (not v:GetAttribute("PreventCrumbling"))
		then
			BrickUtils.tempUnanchor(v)
			BrickUtils.breakJoints(v)
			task.wait()
			v.CFrame *= CFrame.Angles(math.random(), math.random(), math.random())
		end
	end
end

local function spawnNpcsOnMap(map)
	if not map then
        return
    end

	local validParts = {}
	for _, descendant in map:GetDescendants() do
		if descendant:IsA("BasePart") and (not descendant:GetAttribute("PreventSpawning")) then
			table.insert(validParts, descendant)
		end
	end

	if #validParts == 0 then
		return
	end

	local spawnedNpcs = 0
	local iterations = 0
	while spawnedNpcs < Config.NPC_COUNT do
		local spawnPart = validParts[math.random(#validParts)]
		local noObstacles, footPos = NpcUtils.getSpaceAbovePartForNpc(spawnPart)
		if noObstacles then
			local npc = NpcUtils.createNpc()
			npc:PivotTo(CFrame.new(footPos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, math.random(), 0))
			npc.Parent = npcsBin
			spawnedNpcs += 1
		end
		iterations += 1
		if iterations % Config.NPC_SPAWN_CHECKS_PER_TICK == 0 then
			task.wait()
		end
	end
end

local function slowDestroy(object)
	local deletions = 0
	for _, v in object:GetDescendants() do
		if v:IsDescendantOf(object) and v:IsA("BasePart") then
			v:Destroy()
			deletions += 1
			if deletions % Config.SD_DELETIONS_PER_FRAME == 0 then
				task.wait()
			end
		end
	end
	object:Destroy()
end

-------------------------------------------------------------------------------------------
-- RETURN MODULE
-------------------------------------------------------------------------------------------

return {
	loadMap = loadMap,
	weldMap = weldMap,
	crumbleMap = crumbleMap,
    spawnNpcsOnMap = spawnNpcsOnMap,
    slowDestroy = slowDestroy,
}