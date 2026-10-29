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

local function tween(object, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or 1,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)

	local tween = game:GetService("TweenService"):Create(object, tweenInfo, properties)
	tween:Play()
	return tween
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
-- PART APPEARANCE
----------------------------------------------------------------------------------------------

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

local function removeFaceInstances(part)
	for _, v in pairs(part:GetChildren()) do
		if v:IsA("FaceInstance") then
			v:Destroy()
		end
	end
end

----------------------------------------------------------------------------------------------
-- PART BREAKING
----------------------------------------------------------------------------------------------

-- This section pre-debugs was vibe-coded based on what I wrote previously,
-- which was a really laggy and spaghetti blueprint approach with garbage
-- collection overload. All other code is mine unless stated otherwise.

local function isWedge(part: Instance): boolean
	return part:IsA("WedgePart")
	or (
		(part:IsA("Part")
		and (part.Shape == Enum.PartType.Wedge))
	)
end

local function passOnceBlock(sizes: {Vector3}, cframes: {CFrame}, threshold: number)
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

local function passOnceWedge(items: { {Size: Vector3, CFrame: CFrame, Type: string} }, threshold: number)
	local nextX = {}
	for _, item in ipairs(items) do
		local sz, cf, itemType = item.Size, item.CFrame, item.Type
		if sz.X > threshold then
			local halfX = sz.X / 2
			table.insert(nextX, { Size = Vector3.new(halfX, sz.Y, sz.Z), CFrame = cf * CFrame.new(-sz.X / 4, 0, 0), Type = itemType })
			table.insert(nextX, { Size = Vector3.new(halfX, sz.Y, sz.Z), CFrame = cf * CFrame.new(sz.X / 4, 0, 0), Type = itemType })
		else
			table.insert(nextX, item)
		end
	end

	local nextYZ = {}
	for _, item in ipairs(nextX) do
		local sz, cf, itemType = item.Size, item.CFrame, item.Type
		local splitY = sz.Y > threshold
		local splitZ = sz.Z > threshold

		if itemType == "Block" then
			local yOffsets = splitY and { -sz.Y / 4, sz.Y / 4 } or { 0 }
			local zOffsets = splitZ and { -sz.Z / 4, sz.Z / 4 } or { 0 }
			local newY = splitY and sz.Y / 2 or sz.Y
			local newZ = splitZ and sz.Z / 2 or sz.Z
			for _, oy in ipairs(yOffsets) do
				for _, oz in ipairs(zOffsets) do
					table.insert(nextYZ, {
						Size = Vector3.new(sz.X, newY, newZ),
						CFrame = cf * CFrame.new(0, oy, oz),
						Type = "Block",
					})
				end
			end
		elseif splitY or splitZ then
			local qSize = Vector3.new(sz.X, sz.Y / 2, sz.Z / 2)
			local qy, qz = sz.Y / 4, sz.Z / 4

			table.insert(nextYZ, { Size = qSize, CFrame = cf * CFrame.new(0, -qy, -qz), Type = "Wedge" })
			table.insert(nextYZ, { Size = qSize, CFrame = cf * CFrame.new(0, -qy, qz), Type = "Block" })
			table.insert(nextYZ, { Size = qSize, CFrame = cf * CFrame.new(0, qy, qz), Type = "Wedge" })
		else
			table.insert(nextYZ, item)
		end
	end

	return nextYZ
end

local function calculateSplit(part: BasePart, breakParams: BreakParams)
	local threshold = breakParams.Threshold
	local isWedgePart = isWedge(part)
	
	if not isWedgePart then
		local currentSizes = {part.Size}
		local currentCframes = {part.CFrame}
		
		currentSizes, currentCframes = passOnceBlock(currentSizes, currentCframes, threshold)
		if breakParams.IsRecursive then
			local prevCount = 0
			while #currentSizes > prevCount do
				prevCount = #currentSizes
				currentSizes, currentCframes = passOnceBlock(currentSizes, currentCframes, threshold)
			end
		end
		
		local results = {}
		for i = 1, #currentSizes do
			table.insert(results, { Size = currentSizes[i], CFrame = currentCframes[i], Type = "Block" })
		end
		return results
	else
		local items = { { Size = part.Size, CFrame = part.CFrame, Type = "Wedge" } }
		
		items = passOnceWedge(items, threshold)
		if breakParams.IsRecursive then
			local prevCount = 0
			while #items > prevCount do
				prevCount = #items
				items = passOnceWedge(items, threshold)
			end
		end
		
		return items
	end
end

local function spawnFragments(
	originalPart: BasePart,
	fragmentsData: { {Size: Vector3, CFrame: CFrame, Type: string} },
	breakParams: any
)
	if #fragmentsData <= 1 then
		return
	end
	
	local oldParent = originalPart.Parent
	local newFragments = {}
	
	for _, data in ipairs(fragmentsData) do
		local newFragment: BasePart
		local isWedgeOriginal = isWedge(originalPart)

		if data.Type == "Wedge" and not isWedgeOriginal then
			newFragment = Instance.new("WedgePart")
			newFragment.Material = originalPart.Material
			newFragment.Color = originalPart.Color
		elseif data.Type == "Block" and isWedgeOriginal then
			newFragment = Instance.new("Part")
			newFragment.Material = originalPart.Material
			newFragment.Color = originalPart.Color

			if newFragment:IsA("Part") then
				newFragment.Shape = Enum.PartType.Block
			end
		else
			newFragment = originalPart:Clone()
			removeFaceInstances(newFragment)
		end
		
		newFragment.Size = data.Size
		newFragment.CFrame = data.CFrame
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
	
	originalPart:Destroy()
	return newFragments
end

local function breakPart(part: BasePart, breakParams: BreakParams)
	if not part or (not part.Parent) then
		return
	end
	
	local fragmentsData = calculateSplit(part, breakParams)
	
	return spawnFragments(part, fragmentsData, breakParams)
end

----------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: BOOL STUFF
----------------------------------------------------------------------------------------------

local function isTempUnanchorable(part)
	local currentMap = getCurrentMap()
	local isPart = part and part:IsA("BasePart")
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

local function isBreakable(part)
	if not part:IsA("BasePart") then
		return
	end

	return (part:IsA("Part")
		and (
			(part.Shape == Enum.PartType.Block)
			or (part.Shape == Enum.PartType.Wedge)
		))
		or (part:IsA("WedgePart"))
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

local function stabilize(part)
	local attachment = Instance.new("Attachment")
    attachment.Parent = part

    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.Attachment0 = attachment
    alignOrientation.MaxTorque = math.huge
    alignOrientation.MaxAngularVelocity = 20
    alignOrientation.Responsiveness = 15
	alignOrientation.Parent = part
end

----------------------------------------------------------------------------------------------
-- RETURN MODULE
----------------------------------------------------------------------------------------------

return {
	-- Helper
	raycast = raycast,
	tween = tween,
	-- Debris
    tempUnanchor = tempUnanchor,
	breakJoints = breakJoints,
	weldToAdjacent = weldToAdjacent,
	-- Breaking
	breakPart = breakPart,
	-- Bool
	isTempUnanchorable = isTempUnanchorable,
	isGearAttachable = isGearAttachable,
	isBuried = isBuried,
	isTiny = isTiny,
	isBreakable = isBreakable,
	-- Other
    getTopPosition = getTopPosition,
	stabilize = stabilize,
}