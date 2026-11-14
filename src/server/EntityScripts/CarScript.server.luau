if not script.Parent:IsA("Model") then
	return
end

--------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
--------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))

local npcsBin = workspace:WaitForChild("Npcs")
local effectsLib = ServerStorage:WaitForChild("Effects")

local car = script.Parent
local vehicleSeat = car:WaitForChild("VehicleSeat")
local body = car:WaitForChild("Body")
local linkButton = car:WaitForChild("LinkButton")
local callButton = car:WaitForChild("CallButton")
local tip = car:WaitForChild("Tip")

local lastSteerTime = os.time()
local linkEffectUpdatedNpcs = {}
local linkedNpcs = {}

--------------------------------------------------------------------------------------------
-- NEW OBJECTS
--------------------------------------------------------------------------------------------

local alignOrientationAttachment = Instance.new("Attachment")
alignOrientationAttachment.Name = "AlignOrientationAttachment"
alignOrientationAttachment.Parent = body

local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Name = "YAlignOrientation"
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.RigidityEnabled = true
alignOrientation.Attachment0 = alignOrientationAttachment
alignOrientation.PrimaryAxisOnly = true

local linkClicker = Instance.new("ClickDetector")
linkClicker.MaxActivationDistance = Config.DEFAULT_CLICK_DETECTOR_DISTANCE
linkClicker.Parent = linkButton

local callClicker = Instance.new("ClickDetector")
callClicker.MaxActivationDistance = Config.DEFAULT_CLICK_DETECTOR_DISTANCE
callClicker.Parent = callButton

local tipAttachment = Instance.new("Attachment")
tipAttachment.Name = "LinkAttachment"
tipAttachment.Parent = tip

--------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------------------

local function blinkButton(button)
	if not button:GetAttribute("OriginalBrickColor") then
		button:SetAttribute("OriginalBrickColor", button.BrickColor)
	end

	button.BrickColor = Config.CAR_BUTTON_COLOR

	task.spawn(function()
		task.wait(0.25)
		button.BrickColor = button:GetAttribute("OriginalBrickColor")
	end)
end

local function updateLinkEffects()
	for _, npc in linkEffectUpdatedNpcs do
		local root = npc:FindFirstChild("HumanoidRootPart")
		local linkAttachment = root and root:FindFirstChild("LinkAttachment")
		local linkBeam = root and root:FindFirstChild("LinkBeam")

		if not root then
			continue
		end

		if table.find(linkedNpcs, npc) then
			if not linkAttachment then
				linkAttachment = Instance.new("Attachment")
				linkAttachment.Name = "LinkAttachment"
				linkAttachment.Parent = root
			end
			
			if not linkBeam then
				linkBeam = effectsLib:WaitForChild("LinkBeam"):Clone()
				linkBeam.Parent = root
				linkBeam.Attachment0 = linkAttachment
				linkBeam.Attachment1 = tipAttachment
			end

		else
			if linkAttachment then
				linkAttachment:Destroy()
			end

			if linkBeam then
				linkBeam:Destroy()
			end
		end
	end

	linkEffectUpdatedNpcs = linkedNpcs
end

local function listenUnlink(npc)
	local childListener
	local attributeListener

	local function unlink()
		if npc:FindFirstChild("NpcFollowScript") or npc:GetAttribute("IsRescued") then
			local linkId = table.find(linkedNpcs, npc)

			if linkId then
				table.remove(linkedNpcs, linkId)
			end

			childListener:Disconnect()
			attributeListener:Disconnect()

			updateLinkEffects()
		end
	end

	childListener = npc.ChildAdded:Connect(unlink)
	attributeListener = npc.AttributeChanged:Connect(unlink)
end

--------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
--------------------------------------------------------------------------------------------

local function updateSteering()
	if vehicleSeat.Steer ~= 0 then
	alignOrientation.Enabled = false
	lastSteerTime = os.time()

	else
		local activationCheckTime = lastSteerTime

		task.delay(Config.CAR_STABILIZE_TIMER, function()
			if (vehicleSeat.Steer == 0)
			and (
				(lastSteerTime == activationCheckTime)
				or (not vehicleSeat.Occupant)
			) then
				local _, yRotation, _ = body.CFrame:ToOrientation()

				alignOrientation.CFrame = CFrame.Angles(0, yRotation, 0)
				alignOrientation.Enabled = true

				if not alignOrientation.Parent then
					alignOrientation.Parent = body
				end
			end
		end)
	end
end

local function linkNearbyNpcs()
	blinkButton(linkButton)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {npcsBin}

	local partsInRadius = workspace:GetPartBoundsInRadius(
		body.Position,
		Config.CAR_LINK_RADIUS,
		overlapParams
	)

	local nearbyNpcs = {}

	for _, part in partsInRadius do
		local npc = part.Parent
		local hum = npc:FindFirstChild("Humanoid")

		if hum and (not table.find(nearbyNpcs, npc)) then
			table.insert(nearbyNpcs, npc)
		end
	end

	for _, npc in nearbyNpcs do
		if table.find(linkedNpcs, npc) then
			table.remove(linkedNpcs, table.find(linkedNpcs, npc))
		else
			table.insert(linkedNpcs, npc)
		end
	end

	updateLinkEffects()
end

-- The math stuff is vibecoded
local function teleportLinkedNpcs()
	blinkButton(callButton)

	local count = #linkedNpcs
	local radius = Config.CAR_TELEPORT_RADIUS

	if count == 0 then
		return
	end

	for i, npc in ipairs(linkedNpcs) do
		local angle
		
		if count == 1 then
			angle = 0
		else
			local step = (math.pi * 2) / count
			local index = i - 1
			
			if index % 2 == 0 then
				angle = (index / 2) * step
			else
				angle = math.pi + math.floor(index / 2) * step
			end
		end

		local offsetX = math.cos(angle) * radius
		local offsetZ = math.sin(angle) * radius
		local targetCFrame = body.CFrame * CFrame.new(offsetX, 0, offsetZ)
		targetCFrame = CFrame.new(targetCFrame.Position) * body.CFrame.Rotation

		npc:PivotTo(targetCFrame)

		task.wait(0.1)
	end

	linkedNpcs = {}
	updateLinkEffects()
end

--------------------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------------------

vehicleSeat.MaxSpeed = Config.CAR_MAX_SPEED
vehicleSeat.TurnSpeed = Config.CAR_TURN_SPEED

linkClicker.MouseClick:Connect(linkNearbyNpcs)
callClicker.MouseClick:Connect(teleportLinkedNpcs)

vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(updateSteering)
updateSteering()