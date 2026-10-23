local ServerStorage = game:GetService("ServerStorage")
local NpcAssets = ServerStorage:WaitForChild("NpcAssets")
local Bodies = NpcAssets:WaitForChild("Bodies")
local ClassicFaces = NpcAssets:WaitForChild("ClassicFaces")
local Hats = NpcAssets:WaitForChild("Hats")
local PantsColors = NpcAssets:WaitForChild("PantsColors")
local ShirtColors = NpcAssets:WaitForChild("ShirtColors")
local SkinColors = NpcAssets:WaitForChild("SkinColors")
local RareSkinColors = NpcAssets:WaitForChild("RareSkinColors")
local HotelRescue = script.Parent
local Config = require(HotelRescue:WaitForChild("Config"))

local function getRandomChild(instance)
	return instance:GetChildren()[math.random(#instance:GetChildren())]
end

local function createNpc()
	local pantsColorCategory = getRandomChild(PantsColors)
	local shirtColorCategory = getRandomChild(ShirtColors)
	local skinColorCategory = getRandomChild(SkinColors)
	local faceCategory = ClassicFaces:WaitForChild("Awake")
	
	local char = getRandomChild(Bodies):Clone()
	local face = getRandomChild(faceCategory):Clone()
	local hat = getRandomChild(Hats):Clone()
	local pantsColor = getRandomChild(pantsColorCategory).Color
	local shirtColor = getRandomChild(shirtColorCategory).Color
	local skinColor = getRandomChild(skinColorCategory).Color
	local rareSkinColor = getRandomChild(RareSkinColors).Color
	local dressType = math.random(4)
	
	local head = char:WaitForChild("Head")
	local torso = char:WaitForChild("Torso")
	local leftArm = char:WaitForChild("Left Arm")
	local rightArm = char:WaitForChild("Right Arm")
	local leftLeg = char:WaitForChild("Left Leg")
	local rightLeg = char:WaitForChild("Right Leg")
	local hum = char:WaitForChild("Humanoid")
	
	face.Parent = head
	hat.Parent = char
	hum.JumpPower = Config.NPC_JUMP_POWER
	char.PrimaryPart = torso
	
	if math.random(Config.NPC_RARE_SKIN_DIE) == 1 then
		skinColor = rareSkinColor
	end
	
	if dressType == 1 then
		-- Short sleeve with pants
		head.Color = skinColor
		torso.Color = shirtColor
		leftArm.Color = skinColor
		rightArm.Color = skinColor
		leftLeg.Color = pantsColor
		rightLeg.Color = pantsColor
	elseif dressType == 2 then
		-- Long sleeves with pants
		head.Color = skinColor
		torso.Color = shirtColor
		leftArm.Color = shirtColor
		rightArm.Color = shirtColor
		leftLeg.Color = pantsColor
		rightLeg.Color = pantsColor
	elseif dressType == 3 then
		-- Short sleeve with shorts
		head.Color = skinColor
		torso.Color = shirtColor
		leftArm.Color = skinColor
		rightArm.Color = skinColor
		leftLeg.Color = skinColor
		rightLeg.Color = skinColor
	elseif dressType == 4 then
		-- Long sleeve with shorts
		head.Color = skinColor
		torso.Color = shirtColor
		leftArm.Color = shirtColor
		rightArm.Color = shirtColor
		leftLeg.Color = skinColor
		rightLeg.Color = skinColor
	end
	
	return char
end

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

-- Move this to BrickUtils
local function getSpaceAbovePartForNpc(part)
	local footPos = getTopPosition(part)
	local boxSize = Vector3.new(2, 5, 1)
	local boxCFrame = CFrame.new(footPos) * CFrame.new(0, (boxSize.Y / 2) + 0.1, 0)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {part}

	local obstacles = workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)
	return #obstacles == 0, footPos
end

return {
	createNpc = createNpc,
	getSpaceAbovePartForNpc = getSpaceAbovePartForNpc,
}