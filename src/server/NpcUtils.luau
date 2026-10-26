-------------------------------------------------------------------------------------------
-- DEPENDENCIES
-------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService.BrickUtils)

local npcAssetsLib = ServerStorage:WaitForChild("NpcAssets")
local bodiesLib = npcAssetsLib:WaitForChild("Bodies")
local classicFacesLib = npcAssetsLib:WaitForChild("ClassicFaces")
local hatsLib = npcAssetsLib:WaitForChild("Hats")
local pantsColorsLib = npcAssetsLib:WaitForChild("PantsColors")
local shirtColorsLib = npcAssetsLib:WaitForChild("ShirtColors")
local skinColorsLib = npcAssetsLib:WaitForChild("SkinColors")
local rareSkinColorsLib = npcAssetsLib:WaitForChild("RareSkinColors")

-------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------------------

local function getRandomChild(instance)
	return instance:GetChildren()[math.random(#instance:GetChildren())]
end

-------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
-------------------------------------------------------------------------------------------

local function createNpc()
	local pantsColorCategory = getRandomChild(pantsColorsLib)
	local shirtColorCategory = getRandomChild(shirtColorsLib)
	local skinColorCategory = getRandomChild(skinColorsLib)
	local faceCategory = classicFacesLib:WaitForChild("Awake")
	
	local char = getRandomChild(bodiesLib):Clone()
	local face = getRandomChild(faceCategory):Clone()
	local hat = getRandomChild(hatsLib):Clone()
	local pantsColor = getRandomChild(pantsColorCategory).Color
	local shirtColor = getRandomChild(shirtColorCategory).Color
	local skinColor = getRandomChild(skinColorCategory).Color
	local rareSkinColor = getRandomChild(rareSkinColorsLib).Color
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

local function getSpaceAbovePartForNpc(part)
	local footPos = BrickUtils.getTopPosition(part)
	local boxSize = Vector3.new(2, 5, 1)
	local boxCFrame = CFrame.new(footPos) * CFrame.new(0, (boxSize.Y / 2) + 0.1, 0)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {part}

	local obstacles = workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)
	return #obstacles == 0, footPos
end

-------------------------------------------------------------------------------------------
-- RETURN MODULE
-------------------------------------------------------------------------------------------

return {
    createNpc = createNpc,
	getSpaceAbovePartForNpc = getSpaceAbovePartForNpc,
}