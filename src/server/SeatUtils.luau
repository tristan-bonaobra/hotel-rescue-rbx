-------------------------------------------------------------------------------------------
-- DEPENDENCIES
-------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

-------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------------------

local function weldParts(part0, part1)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0

	return weld
end

local function destroyFollowScript(npc)
	local followScript = npc:FindFirstChild("NpcFollowScript")

	if followScript then
		followScript:Destroy()
	end
end

-------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
-------------------------------------------------------------------------------------------

local function seatCharacter(npc, seatPart)
    local root = npc:WaitForChild("HumanoidRootPart")
    local hum = npc:WaitForChild("Humanoid")
	local wasSeatEnabled = not seatPart.Disabled

    local rootSize = root.Size
    local seatSize = seatPart.Size
    local seatOffset = 0.5
    local seatHeight = (rootSize.Y / 2) + (seatSize.Y / 2) + seatOffset

    root.CFrame = seatPart.CFrame * CFrame.new(0, seatHeight, 0)
    local weld = weldParts(seatPart, root)

    hum.Sit = true
    npc:SetAttribute("IsSeated", true)
    destroyFollowScript(npc)

    seatPart:SetAttribute("NpcOccupant", hum)

	if wasSeatEnabled then
   		seatPart.Disabled = true
	end

	local stateListener
	local ancestryListener
	local childListener
	local attributeListener

    local function unsit()
		local falseAlarm = (
			(not hum.Jump)
			and (hum:GetState() ~= Enum.HumanoidStateType.Jumping)
			and (hum:GetState() ~= Enum.HumanoidStateType.Freefall)
			and (hum.Health > 0)
			and (hum.Sit)
			and (weld:IsDescendantOf(workspace))
			and (not npc:FindFirstChild("NpcFollowScript"))
			and (not npc:GetAttribute("IsUnconscious"))
			and (not npc:GetAttribute("IsTripped"))
			and (not npc:GetAttribute("IsRescued"))
		)
		
		if falseAlarm then
			return
		end

        seatPart:SetAttribute("NpcOccupant", nil)

		if wasSeatEnabled then
       		 seatPart.Disabled = false
		end
        
        if weld:IsDescendantOf(workspace) then
            weld:Destroy()
        end

        npc:SetAttribute("IsSeated", false)
        hum:SetAttribute("LastUnseated", os.clock())
		hum.Sit = false

		stateListener:Disconnect()
		ancestryListener:Disconnect()
		childListener:Disconnect()
		attributeListener:Disconnect()
    end

	stateListener = hum.StateChanged:Connect(unsit)
	ancestryListener = weld.AncestryChanged:Connect(unsit)
	childListener = npc.ChildAdded:Connect(unsit)
	attributeListener = npc.AttributeChanged:Connect(unsit)
end

local function reprogramSeat(seat)
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
			seatCharacter(char, seat)
		end
	end)
end

-------------------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------------------

return {
    reprogramSeat = reprogramSeat,
    seatCharacter = seatCharacter,
}