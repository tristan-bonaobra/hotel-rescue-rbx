-- Move this to BrickUtils...

-- Do direct math with math.ceil for xyz loops instead of blueprints...
-- (reason: garbage collection)

local Config = require(script.Parent.Parent.Config)
local DebrisController = require(script.Parent.DebrisController)

type BreakParams = {
	Threshold: number,
	IsRecursive: boolean,
	Unanchor: boolean,
	Tint: boolean
}

local function breakBlueprintAtDimension(blueprint, dimension, threshold)
	local newBlueprints = {}
	if (dimension == "X") and (blueprint.Size.X > threshold) then
		local new0 = {Size = nil, CFrame = nil}
		local new1 = {Size = nil, CFrame = nil}
		new0.Size = blueprint.Size / Vector3.new(2, 1, 1)
		new1.Size = blueprint.Size / Vector3.new(2, 1, 1)
		new0.CFrame = blueprint.CFrame * CFrame.new(-blueprint.Size.X / 4, 0, 0)
		new1.CFrame = blueprint.CFrame * CFrame.new(blueprint.Size.X / 4, 0, 0)
		table.insert(newBlueprints, new0)
		table.insert(newBlueprints, new1)
	elseif (dimension == "Y") and (blueprint.Size.Y > threshold) then
		local new0 = {Size = nil, CFrame = nil}
		local new1 = {Size = nil, CFrame = nil}
		new0.Size = blueprint.Size / Vector3.new(1, 2, 1)
		new1.Size = blueprint.Size / Vector3.new(1, 2, 1)
		new0.CFrame = blueprint.CFrame * CFrame.new(0, -blueprint.Size.Y / 4, 0)
		new1.CFrame = blueprint.CFrame * CFrame.new(0, blueprint.Size.Y / 4, 0)
		table.insert(newBlueprints, new0)
		table.insert(newBlueprints, new1)
	elseif (dimension == "Z") and (blueprint.Size.Z > threshold) then
		local new0 = {Size = nil, CFrame = nil}
		local new1 = {Size = nil, CFrame = nil}
		new0.Size = blueprint.Size / Vector3.new(1, 1, 2)
		new1.Size = blueprint.Size / Vector3.new(1, 1, 2)
		new0.CFrame = blueprint.CFrame * CFrame.new(0, 0, -blueprint.Size.Z / 4)
		new1.CFrame = blueprint.CFrame * CFrame.new(0, 0, blueprint.Size.Z / 4)
		table.insert(newBlueprints, new0)
		table.insert(newBlueprints, new1)
	end
	if #newBlueprints > 0 then
		return newBlueprints
	else
		return {blueprint}
	end
end

local function breakBlueprintsAtDimension(blueprints, dimension, threshold)
	local newBlueprints = {}
	for _, blueprint in blueprints do
		for _, newBlueprint in breakBlueprintAtDimension(blueprint, dimension, threshold) do
			table.insert(newBlueprints, newBlueprint)
		end
	end
	if #newBlueprints > 0 then
		return newBlueprints
	else
		return blueprints
	end
end

local function breakBlueprintsAtAllDimensions(blueprints, threshold)
	local newBlueprints = {}
	for _, blueprint in blueprints do
		local localBlueprints = breakBlueprintsAtDimension({blueprint}, "X", threshold)
		localBlueprints = breakBlueprintsAtDimension(localBlueprints, "Y", threshold)
		localBlueprints = breakBlueprintsAtDimension(localBlueprints, "Z", threshold)
		for _, localBlueprint in localBlueprints do
			table.insert(newBlueprints, localBlueprint)
		end
	end
	if #newBlueprints > 0 then
		return newBlueprints
	else
		return blueprints
	end
end

local function breakBlueprintsAtAllDimensionsRecursive(blueprints, threshold)
	local oldBlueprints = blueprints
	local newBlueprints = breakBlueprintsAtAllDimensions(oldBlueprints, threshold)
	while #newBlueprints > #oldBlueprints do
		oldBlueprints = newBlueprints
		newBlueprints = breakBlueprintsAtAllDimensions(oldBlueprints, threshold)
	end
	return newBlueprints
end

local fragmentYieldCounter = 0

local function breakPart(part, breakParams: BreakParams)
	local initialBlueprint = {Size = part.Size, CFrame = part.CFrame}
	local initialBlueprints = {initialBlueprint}
	local fragmentBlueprints = {}
	if breakParams.IsRecursive then
		fragmentBlueprints = breakBlueprintsAtAllDimensionsRecursive(initialBlueprints, breakParams.Threshold)
	else
		fragmentBlueprints = breakBlueprintsAtAllDimensions(initialBlueprints, breakParams.Threshold)
	end
	if #fragmentBlueprints == 1 then
		return
	end
	
	local newFragments = {}
	for _, blueprint in fragmentBlueprints do
		local newFragment = part:Clone()
		newFragment.Size = blueprint.Size
		newFragment.CFrame = blueprint.CFrame
		table.insert(newFragments, newFragment)
	end
	
	local oldParent = part.Parent
	for _, fragment in newFragments do
		fragment.Parent = oldParent
		if breakParams.Unanchor then
			DebrisController.tempUnanchor(fragment)
		end
		if breakParams.Tint then
			DebrisController.randTint(fragment)
		end
		DebrisController.breakJoints(fragment)
		fragmentYieldCounter += 1
		if fragmentYieldCounter % Config.FRAGMENTS_PER_TICK == 0 then
			task.wait()
		end
	end
	part:Destroy()
	return newFragments
end

return {
	breakPart = breakPart
}