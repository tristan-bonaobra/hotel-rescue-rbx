-- Rename to MapUtils

local ServerStorage = game:GetService("ServerStorage")
local Maps = ServerStorage:WaitForChild("Maps")
local HotelRescue = script.Parent
local Config = require(HotelRescue:WaitForChild("Config"))
local NpcLoader = require(HotelRescue:WaitForChild("NpcLoader"))
local PartBreaker = require(script:WaitForChild("PartBreaker"))
local DebrisController = require(script:WaitForChild("DebrisController"))
local Npcs = workspace:WaitForChild("Npcs")

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

local function raycast(originPos, targetPos, filterInclude)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = filterInclude or {workspace}

	local rayDirection = targetPos - originPos
	local raycastResult = workspace:Raycast(originPos, rayDirection, rayParams)
	return raycastResult
end

-- Move this to BrickUtils
-- Switching to "is" instead of "verify" from here
local function isBuried(part)
	-- Acts strangely in rare cases where a block has tiny blocks attached perfectly on each side
	-- or is otherwise completely buried except for a tiny gap on one side.
	-- The point is to filter out the thousands of fill bricks in Underground Base.
	local size = part.Size / 2
	local targetCFrames = {
		part.CFrame * CFrame.new(size.X + 0.5, 0, 0),
		part.CFrame * CFrame.new(-size.X - 0.5, 0, 0),
		part.CFrame * CFrame.new(0, size.Y + 0.5, 0),
		part.CFrame * CFrame.new(0, -size.Y - 0.5, 0),
		part.CFrame * CFrame.new(0, 0, size.Z + 0.5),
		part.CFrame * CFrame.new(0, 0, -size.Z - 0.5),
	}
	for _, targetCFrame in targetCFrames do
		local targetPos = targetCFrame.Position
		local raycastResult = raycast(part.Position, targetPos)
		if not raycastResult then
			return false
		end
	end
	return true
end

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

local function crumbleMap(map)
	local sortedParts = getSortedParts(map)
	for _, v in pairs(sortedParts) do
		if (math.random(Config.CRUMBLE_DIE) == 1)
			and (not isBuried(v))
			and (not v:GetAttribute("PreventCrumbling"))
		then
			DebrisController.tempUnanchor(v)
			DebrisController.breakJoints(v)
			task.wait()
			v.CFrame *= CFrame.Angles(math.random(), math.random(), math.random())
		end
	end
end

local function breakMap(map)
	for _,v in pairs(map:GetDescendants()) do
		if v:IsA("Part") then
			local breakParams = {
				Threshold = Config.BREAK_THRESHOLD_MAP,
				IsRecursive = true,
				Unanchor = false,
				Tint = false
			}
			PartBreaker.breakPart(v, breakParams)
		end
	end
	map:MakeJoints()
end

local function spawnNpcsOnMap(map)
	if not map then return end
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
		local noObstacles, footPos = NpcLoader.getSpaceAbovePartForNpc(spawnPart)
		if noObstacles then
			local npc = NpcLoader.createNpc()
			npc:PivotTo(CFrame.new(footPos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, math.random(), 0))
			npc.Parent = Npcs
			spawnedNpcs += 1
		end
		iterations += 1
		if iterations % Config.NPC_SPAWN_CHECKS_PER_TICK == 0 then
			task.wait()
		end
	end
end

-- Move to BrickUtils...

local weldIndex = {}
local weldDuplicatesPrevented = 0

local function weldToAdjacent(part)
	weldIndex[part] = weldIndex[part] or {}
	
	local buff = Config.TOUCH_BUFFER_SIZE
	local paddedSize = part.Size + Vector3.new(buff, buff, buff)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = {part}
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude

	local touchingParts = workspace:GetPartBoundsInBox(part.CFrame, paddedSize, overlapParams)
	local nCreatedWelds = 0
	for _, touchingPart in pairs(touchingParts) do
		if (not weldIndex[touchingPart]) or (not weldIndex[touchingPart][part]) then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = part
			weld.Part1 = touchingPart
			weld.Parent = part
			
			nCreatedWelds += 1
			weldIndex[part][touchingPart] = true
		else
			weldDuplicatesPrevented += 1
		end
	end
	
	return nCreatedWelds
end

local function weldMap(map)
	weldIndex = {}
	local nCreatedWeldsTotal = 0
	for _, v in map:GetDescendants() do
		if v:IsA("BasePart") then
			local nCreatedWeldsSubtotal = weldToAdjacent(v)
			
			nCreatedWeldsTotal += nCreatedWeldsSubtotal
			if nCreatedWeldsTotal % Config.WELDS_PER_FRAME == 0 then
				task.wait()
			end
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

return {
	cleanMap = cleanMap,
	anchorMap = anchorMap,
	breakMap = breakMap,
	spawnNpcsOnMap = spawnNpcsOnMap,
	crumbleMap = crumbleMap,
	weldMap = weldMap,
	slowDestroy = slowDestroy
}