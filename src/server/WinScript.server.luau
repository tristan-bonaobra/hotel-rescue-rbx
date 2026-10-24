local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ServerScriptService:WaitForChild("Config"))

local npcAssetsFolder = ServerStorage:WaitForChild("NpcAssets")
local npcWinPosesFolder = npcAssetsFolder:WaitForChild("WinPoses")
local npcFolder = workspace:WaitForChild("Npcs")

local winZone = script.Parent
local winPart = winZone:WaitForChild("WinPart")
local npcSpotsFolder = winZone:WaitForChild("NpcSpots")
local npcSpotsConscious = npcSpotsFolder:WaitForChild("Conscious"):GetChildren()
local npcSpotsUnconscious = npcSpotsFolder:WaitForChild("Unconscious"):GetChildren()

local globalSoundsFolder = workspace:WaitForChild("GlobalSounds")
local soundEffectsFolder = globalSoundsFolder:WaitForChild("Effects")

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
		local referenceFolder = npcWinPosesFolder:FindFirstChild(spotName)
		local references = referenceFolder:GetChildren()
		return references[math.random(#references)]
	elseif spotName == "Hug" then
		return npcWinPosesFolder:WaitForChild("Hug")
	end
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

local npcsRescued = 0

local function rewardAllPlayersForRescue(isUnconscious)
	local points = (isUnconscious and Config.REWARD_UNCONSCIOUS) or Config.REWARD_CONSCIOUS
	for _, plr in Players:GetPlayers() do
		local leaderstats = plr:WaitForChild("leaderstats")
		local pointsObject = leaderstats:WaitForChild("Points")
		pointsObject.Value += points
	end
	local sound
	local hint = Instance.new("Hint", workspace)
	hint.Text = "Survivor #"..npcsRescued.." was rescued for "..points.." point"..(((points > 1) and "s") or "").."!"
	game.Debris:AddItem(hint, 3)
	if isUnconscious then
		sound = soundEffectsFolder:FindFirstChild("ShortSpringSound")
	else
		sound = soundEffectsFolder:FindFirstChild("Money")
	end
	if sound then
		sound:Play()
	end
end

winPart.Touched:Connect(function(hit)
	local npc = hit.Parent
	local hum = npc:FindFirstChildOfClass("Humanoid")
	local isInNpcFolder = npc:IsDescendantOf(npcFolder)
	local isRescued = npc:GetAttribute("IsRescued")
	local isUnconscious = npc:GetAttribute("IsUnconscious")
	if hum and isInNpcFolder and (not isRescued) then
		npcsRescued += 1
		npc:SetAttribute("IsRescued", true)
		rewardAllPlayersForRescue(isUnconscious)
		
		local spot = chooseSpot(isUnconscious)
		if spot then
			poseNpcAtSpot(npc, spot)
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