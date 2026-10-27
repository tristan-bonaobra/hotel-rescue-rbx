----------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
----------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local playgroundBin = workspace:WaitForChild("Playground")

local teleporter = workspace:WaitForChild("Teleporter")

type BreakParams = {
	Threshold: number,
	IsRecursive: boolean,
	Unanchor: boolean,
	Tint: boolean
}

local fragmentYieldCounter = 0
local weldIndex = {}

----------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------

local function raycast(originPos, targetPos, filterType, filterObjects)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = filterType or Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = filterObjects or {workspace}

	local rayDirection = targetPos - originPos
	local raycastResult = workspace:Raycast(originPos, rayDirection, rayParams)
	return raycastResult
end

local function getCurrentMap()
	return workspace:FindFirstChild("CurrentMap")
end

----------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: DEBRIS
----------------------------------------------------------------------------------------------

local function tempUnanchor(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Anchored = false

	task.spawn(function()
		repeat
			task.wait(2)

			local mag1 = part.AssemblyLinearVelocity.Magnitude
			local mag2 = part.AssemblyAngularVelocity.Magnitude
			local magSum = mag1 + mag2

			local isMoving = magSum > Config.DEBRIS_ANCHOR_THRESHOLD
			local isAttached = part:FindFirstChildOfClass("Attachment")
			local notMovingNorAttached = (not isMoving) and (not isAttached)
			local noLongerExists = not part:IsDescendantOf(workspace)

		until notMovingNorAttached or noLongerExists

		part.Anchored = true
		part.CustomPhysicalProperties = nil
		part.AssemblyLinearVelocity = Vector3.new()
		part.AssemblyAngularVelocity = Vector3.new()
	end)
end

local function breakJoints(part)
	for _, joint in part:GetJoints() do
		joint:Destroy()
	end
end

local function randTint(part)
	local h, s, v = part.Color:ToHSV()
	local a = 1000
	if math.random(2) == 1 then
		s += math.random(a * Config.DEBRIS_TINT) / a
		v += math.random(a * Config.DEBRIS_TINT) / a
	else
		s-= math.random(a * Config.DEBRIS_TINT) / a
		v -= math.random(a * Config.DEBRIS_TINT) / a
	end
	s = math.clamp(s, 0, 1)
	v = math.clamp(v, 0, 1)
	part.Color = Color3.fromHSV(h, s, v)
end

-- This function was vibe-coded based on what I wrote previously, which
-- was a really laggy and spaghetti blueprint approach with garbage
-- collection overload. All other functions are mine unless stated other
-- wise.
local function breakPart(part, breakParams: BreakParams)
	local threshold = breakParams.Threshold
	local currentSizes = {part.Size}
	local currentCframes = {part.CFrame}
	
	local function passOnce(sizes, cframes)
		local nextSizesX, nextCframesX = {}, {}
		for i = 1, #sizes do
			local sz, cf = sizes[i], cframes[i]
			if sz.X > threshold then
				local halfX = sz.X / 2
				table.insert(nextSizesX, Vector3.new(halfX, sz.Y, sz.Z))
				table.insert(nextCframesX, cf * CFrame.new(-sz.X / 4, 0, 0))
				table.insert(nextSizesX, Vector3.new(halfX, sz.Y, sz.Z))
				table.insert(nextCframesX, cf * CFrame.new(sz.X / 4, 0, 0))
			else
				table.insert(nextSizesX, sz)
				table.insert(nextCframesX, cf)
			end
		end
		
		local nextSizesY, nextCframesY = {}, {}
		for i = 1, #nextSizesX do
			local sz, cf = nextSizesX[i], nextCframesX[i]
			if sz.Y > threshold then
				local halfY = sz.Y / 2
				table.insert(nextSizesY, Vector3.new(sz.X, halfY, sz.Z))
				table.insert(nextCframesY, cf * CFrame.new(0, -sz.Y / 4, 0))
				table.insert(nextSizesY, Vector3.new(sz.X, halfY, sz.Z))
				table.insert(nextCframesY, cf * CFrame.new(0, sz.Y / 4, 0))
			else
				table.insert(nextSizesY, sz)
				table.insert(nextCframesY, cf)
			end
		end
		
		local nextSizesZ, nextCframesZ = {}, {}
		for i = 1, #nextSizesY do
			local sz, cf = nextSizesY[i], nextCframesY[i]
			if sz.Z > threshold then
				local halfZ = sz.Z / 2
				table.insert(nextSizesZ, Vector3.new(sz.X, sz.Y, halfZ))
				table.insert(nextCframesZ, cf * CFrame.new(0, 0, -sz.Z / 4))
				table.insert(nextSizesZ, Vector3.new(sz.X, sz.Y, halfZ))
				table.insert(nextCframesZ, cf * CFrame.new(0, 0, sz.Z / 4))
			else
				table.insert(nextSizesZ, sz)
				table.insert(nextCframesZ, cf)
			end
		end
		
		return nextSizesZ, nextCframesZ
	end
	
	currentSizes, currentCframes = passOnce(currentSizes, currentCframes)
	
	if breakParams.IsRecursive then
		local prevCount = 0
		while #currentSizes > prevCount do
			prevCount = #currentSizes
			currentSizes, currentCframes = passOnce(currentSizes, currentCframes)
		end
	end
	
	if #currentSizes == 1 then
		return
	end
	
	local oldParent = part.Parent
	local newFragments = {}
	for i = 1, #currentSizes do
		local newFragment = part:Clone()
		newFragment.Size = currentSizes[i]
		newFragment.CFrame = currentCframes[i]
		newFragment.Parent = oldParent
		
		if breakParams.Unanchor then
			tempUnanchor(newFragment)
		end
		if breakParams.Tint then
			randTint(newFragment)
		end
		breakJoints(newFragment)
		
		fragmentYieldCounter += 1
		if fragmentYieldCounter % Config.FRAGMENTS_PER_TICK == 0 then
			task.wait()
		end
		
		table.insert(newFragments, newFragment)
	end
	
	part:Destroy()
	return newFragments
end

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
		end
	end
	
	return nCreatedWelds
end

----------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: BOOL STUFF
----------------------------------------------------------------------------------------------

local function isTempUnanchorable(part)
	local currentMap = getCurrentMap()
	local isPart = part and part:IsA("Part")
	local isMap = (currentMap and part:IsDescendantOf(currentMap))
	local isPlayground = (playgroundBin and part:IsDescendantOf(playgroundBin))

	return part and isPart and (isMap or isPlayground)
end

local function isGearAttachable(part)
	local currentMap = getCurrentMap()
	return part
		and part:IsA("BasePart")
		and (teleporter and (not part:IsDescendantOf(teleporter)))
		and (
			part.Anchored
			or (currentMap and part:IsDescendantOf(currentMap))
			or part:IsDescendantOf(playgroundBin)
			or (part:GetAttribute("IsGearAttachable"))
		)
end

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

local function isTiny(part)
	local t = Config.BREAK_THRESHOLD_MANUAL
	local size = part.Size
	return (size.X <= t)
		and (size.Y <= t)
		and (size.Z <= t)
end

----------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: OTHER
----------------------------------------------------------------------------------------------

local function getTopPosition(part)
	local cf = part.CFrame
	local size = part.Size
	local faces = {
		{normal = cf.UpVector, offset = Vector3.new(0, size.Y / 2, 0)},
		{normal = -cf.UpVector, offset = Vector3.new(0, -size.Y / 2, 0)},
		{normal = cf.RightVector, offset = Vector3.new(size.X / 2, 0, 0)},
		{normal = -cf.RightVector, offset = Vector3.new(-size.X / 2, 0, 0)},
		{normal = cf.LookVector, offset = Vector3.new(0, 0, -size.Z / 2)},
		{normal = -cf.LookVector, offset = Vector3.new(0, 0, size.Z / 2)},
	}

	local bestFace = faces[1]
	local maxUpDot = bestFace.normal.Y
	for i = 2, #faces do
		local upDot = faces[i].normal.Y
		if upDot > maxUpDot then
			maxUpDot = upDot
			bestFace = faces[i]
		end
	end

	return cf:PointToWorldSpace(bestFace.offset)
end

----------------------------------------------------------------------------------------------
-- RETURN MODULE
----------------------------------------------------------------------------------------------

return {
	-- Helper
	raycast = raycast,
	-- Debris
    tempUnanchor = tempUnanchor,
    breakPart = breakPart,
	breakJoints = breakJoints,
	weldToAdjacent = weldToAdjacent,
	-- Bool
	isTempUnanchorable = isTempUnanchorable,
	isGearAttachable = isGearAttachable,
	isBuried = isBuried,
	isTiny = isTiny,
	-- Other
    getTopPosition = getTopPosition,
}