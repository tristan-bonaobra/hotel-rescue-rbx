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
local winPosesLib = npcAssetsLib:WaitForChild("WinPoses")

-------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS: SPAWNING
-------------------------------------------------------------------------------------------

local function getRandomChild(instance)
	return instance:GetChildren()[math.random(#instance:GetChildren())]
end

-------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: SPAWNING
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
	npcAssetsLib:WaitForChild("NpcAnimator"):Clone().Parent = char
	
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
-- HELPER FUNCTIONS: WINZONE
-------------------------------------------------------------------------------------------

local function anchorModel(model)
	for _, v in model:GetDescendants() do
		if v:IsA("BasePart") then
			v.Anchored = true
			v.CanCollide = true
			v.AssemblyLinearVelocity = Vector3.new()
			v.AssemblyAngularVelocity = Vector3.new()
		end
	end
end

local function breakNpcForPosing(npc)
	local hum = npc:FindFirstChildOfClass("Humanoid")
	hum.RequiresNeck = false
	
	local torso = npc:FindFirstChild("Torso")
	if (not torso) then
		return
	end
	
	anchorModel(npc)
	
	for _, descendant in ipairs(npc:GetDescendants()) do
		if (descendant:IsA("Motor6D") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint")) then
			if (descendant.Name ~= "RootJoint") and (descendant.Name ~= "Root") then
				local part0 = descendant.Part0
				local part1 = descendant.Part1
				local connectsToTorso = (part0 == torso) or (part1 == torso)
				local otherPart = ((part0 == torso) and part1) or part0
				local isAccessoryWeld = descendant.Parent and descendant.Parent:IsA("Accessory")
				
				if connectsToTorso and (not isAccessoryWeld) and otherPart then
					if (otherPart.Name == "Head") or string.find(otherPart.Name, "Arm") or string.find(otherPart.Name, "Leg") then
						descendant:Destroy()
					end
				end
			end
		end
	end
end

local function getWinPoseReferenceModel(spotName)
	if table.find({"Seat", "Stand", "Watch"}, spotName) then
		local referenceFolder = winPosesLib:FindFirstChild(spotName)
		local references = referenceFolder:GetChildren()
		return references[math.random(#references)]
	elseif spotName == "Hug" then
		return winPosesLib:WaitForChild("Hug")
	end
	return
end

local function getRelativeCFrames(refModel)
	local torsoCFrame = refModel:WaitForChild("Torso").CFrame
	return {
		["Head"] = torsoCFrame:ToObjectSpace(refModel:WaitForChild("Head").CFrame),
		["Left Arm"] = torsoCFrame:ToObjectSpace(refModel:WaitForChild("Left Arm").CFrame),
		["Right Arm"] = torsoCFrame:ToObjectSpace(refModel:WaitForChild("Right Arm").CFrame),
		["Left Leg"] = torsoCFrame:ToObjectSpace(refModel:WaitForChild("Left Leg").CFrame),
		["Right Leg"] = torsoCFrame:ToObjectSpace(refModel:WaitForChild("Right Leg").CFrame),
	}
end

local function mimicRefProps(npc, refModel)
	local refTool = refModel:FindFirstChildOfClass("Tool")
	local hum = npc:FindFirstChildOfClass("Humanoid")
	if refTool and hum then
		local newTool = refTool:Clone()
		local handle = newTool:FindFirstChild("Handle")
		if handle then
			handle.Anchored = false
			handle.CanCollide = true
			local npcRightHand = npc:FindFirstChild("Right Arm")
			local refRightHand = refModel:FindFirstChild("Right Arm")
			if npcRightHand and refRightHand then
				local refHandle = refTool:FindFirstChild("Handle")
				if refHandle then
					handle.CFrame = npcRightHand.CFrame * refRightHand.CFrame:ToObjectSpace(refHandle.CFrame)
				end
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = npcRightHand
				weld.Part1 = handle
				weld.Parent = handle
			end
		end
		newTool.Parent = npc
	end
end

local function refreshAccessories(npc)
	for _, v in npc:GetChildren() do
		if v:IsA("Accessory") then
			local handle = v:FindFirstChild("Handle")
			if handle then
				handle.Anchored = false
			end
			
			v.Parent = nil
			task.wait()
			v.Parent = npc
		end
	end
end

-------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS: WINZONE
-------------------------------------------------------------------------------------------

local function poseNpcAtSpot(npc, spot)
	local torso = npc:FindFirstChild("Torso")
	if (not torso) then
		return
	end
	
	breakNpcForPosing(npc)
	
	if spot.Name == "Bed" then
		npc:PivotTo(spot.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0))
	else
		local spotBottomCFrame = spot.CFrame * CFrame.new(0, -spot.Size.Y / 2, 0)
		if spot.Name == "Seat" then
			npc:PivotTo(spotBottomCFrame * CFrame.new(0, 1, 0.5))
		else
			npc:PivotTo(spotBottomCFrame * CFrame.new(0, 3, 0))
		end
			
		local refModel = getWinPoseReferenceModel(spot.Name)
		local relativeCFrames = getRelativeCFrames(refModel)
		for partName, relativeCFrame in pairs(relativeCFrames) do
			local part = npc:FindFirstChild(partName)
			if part then
				part.CFrame = torso.CFrame * relativeCFrame
			end
		end
		
		mimicRefProps(npc, refModel)
		refreshAccessories(npc)
	end
end

-------------------------------------------------------------------------------------------
-- RETURN MODULE
-------------------------------------------------------------------------------------------

return {
    createNpc = createNpc,
	getSpaceAbovePartForNpc = getSpaceAbovePartForNpc,
	poseNpcAtSpot = poseNpcAtSpot,
}