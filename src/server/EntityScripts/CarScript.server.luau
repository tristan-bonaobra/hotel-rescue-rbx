if not script.Parent:IsA("Model") then
	return
end

--------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
--------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local SeatUtils = require(ServerScriptService:WaitForChild("SeatUtils"))
local Config = require(ServerScriptService:WaitForChild("Config"))

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

--------------------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------------------

for _, v in seatsModel:GetChildren() do
	if v:IsA("Seat") and (not v:IsA("VehicleSeat")) then
		SeatUtils.reprogramSeat(v)
	end
end

vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(updateSteering)
updateSteering()