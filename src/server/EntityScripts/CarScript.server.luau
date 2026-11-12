if not script.Parent:IsA("Model") then
	return
end

--------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
--------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local car = script.Parent
local seatsModel = car:WaitForChild("Seats")
local vehicleSeat = car:WaitForChild("VehicleSeat")
local body = car:WaitForChild("Body")

local lastSteerTime = os.time()

--------------------------------------------------------------------------------------------
-- NEW OBJECTS
--------------------------------------------------------------------------------------------

local attachment = Instance.new("Attachment")
attachment.Name = "AlignOrientationAttachment"
attachment.Parent = body

local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Name = "YAlignOrientation"
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.RigidityEnabled = true
alignOrientation.Attachment0 = attachment
alignOrientation.PrimaryAxisOnly = true

--------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------------------

local function arePartsTouching(part0, part1)
	for _, hit in part0:GetTouchingParts() do
		if hit == part1 then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------------------------------
-- FUNCTIONS
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

local function forceServerOwnership()
	for _, v in car:GetDescendants() do
		if v:IsA("BasePart") then
			v:SetNetworkOwner(nil)
		end
	end
end

--------------------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------------------

vehicleSeat.MaxSpeed = Config.CAR_MAX_SPEED
vehicleSeat.TurnSpeed = Config.CAR_TURN_SPEED
vehicleSeat.Torque = Config.CAR_TORQUE

forceServerOwnership()

vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	task.wait()
	forceServerOwnership()
end)

vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(updateSteering)
updateSteering()