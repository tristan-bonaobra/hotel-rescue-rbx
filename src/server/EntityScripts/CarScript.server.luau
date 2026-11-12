if not script.Parent:IsA("Model") then
	return
end

--------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
--------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local NpcUtils = require(ServerScriptService.NpcUtils)
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

local function setupSeat(seat)
	seat.Disabled = true

	seat.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if (not hum)
			or seat.Occupant
			or seat:GetAttribute("NpcOccupant")
			or (hum.Health <= 0)
			or hum.Sit
		then
			return
		end

		local now = os.clock()
		local lastUnseated = hum:GetAttribute("LastUnseated") or 0
		local timeSinceUnseat = now - lastUnseated

		if timeSinceUnseat >= Config.CAR_SEAT_COOLDOWN then
			NpcUtils.seat(char, seat)
		end
	end)
end

local function setupSeats()
	for _, v in seatsModel:GetChildren() do
		if v:IsA("Seat") and (not v:IsA("VehicleSeat")) then
			setupSeat(v)
		end
	end
end

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

vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(updateSteering)

setupSeats()

updateSteering()