--------------------------------------------------------------------------------------------
-- GLOBAL DEPENDENCIES AND VARIABLES
--------------------------------------------------------------------------------------------

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")
local npcsBin = workspace:WaitForChild("Npcs")

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

local function setNpcCollisionGroup(npc, groupName)
    for _, v in npc:GetDescendants() do
        if v:IsA("BasePart") then
            v.CollisionGroup = groupName
        end
    end
end

local function setNpcSit(npc, value)
    local hum = npc:FindFirstChild("Humanoid")

    if hum then
        hum.Sit = value
    end
end

local function setNpcRootAnchored(npc, value)
    local root = npc:FindFirstChild("HumanoidRootPart")

    if root then
        root.Anchored = value
    end
end

local function stopNpcFollowing(npc)
    local npcFollowScript = npc:FindFirstChild("NpcFollowScript")

    if npcFollowScript then
        npcFollowScript:Destroy()
    end
end

local function pushNpcAwayFromPosition(npc, position)
    local root = npc:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local direction = (root.Position - position).Unit
    local impulseVector = direction * Config.CAR_EJECT_POWER * root.AssemblyMass

    root:ApplyImpulse(impulseVector)
end

local function setLightsBrickColor(car, brickColor)
    local lightsModel = car:WaitForChild("Lights")

    for _, light in lightsModel:GetChildren() do
        if not light:GetAttribute("OriginalBrickColor") then
            light:SetAttribute("OriginalBrickColor", light.BrickColor)
        end

        light.BrickColor = brickColor or light:GetAttribute("OriginalBrickColor")
    end
end

--------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
--------------------------------------------------------------------------------------------

local function programCarDriving(car)
    local vehicleSeat = car:WaitForChild("VehicleSeat")
    local body = car:WaitForChild("Body")
    local alignOrientationAttachment = Instance.new("Attachment")
    local alignOrientation = Instance.new("AlignOrientation")
    local lastSteerTime = os.clock()

    alignOrientationAttachment.Name = "AlignOrientationAttachment"
    alignOrientationAttachment.Parent = body

    alignOrientation.Name = "YAlignOrientation"
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.RigidityEnabled = true
    alignOrientation.Attachment0 = alignOrientationAttachment
    alignOrientation.PrimaryAxisOnly = true

    vehicleSeat.MaxSpeed = Config.CAR_MAX_SPEED
    vehicleSeat.TurnSpeed = Config.CAR_TURN_SPEED

    vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function()
        if vehicleSeat.Steer ~= 0 then
            -- Do not snap while the player is steering
            alignOrientation.Enabled = false
            lastSteerTime = os.clock()
            setLightsBrickColor(car, nil)

        else
            -- Snap after a delay
            local activationCheckTime = lastSteerTime
            
            task.wait(Config.CAR_STABILIZE_TIMER)

            local notSteering = vehicleSeat.Steer == 0
            local didNotSteerSince = lastSteerTime == activationCheckTime
            local noOccupant = not vehicleSeat.Occupant

            if notSteering and (didNotSteerSince or noOccupant) then
                local _, yRotation, _ = body.CFrame:ToOrientation()

                alignOrientation.CFrame = CFrame.Angles(0, yRotation, 0)
                alignOrientation.Enabled = true
                setLightsBrickColor(car, BrickColor.new("Bright red"))

                -- Prevent the car snapping forwards on spawn
                if not alignOrientation.Parent then
                    alignOrientation.Parent = body
                end
            end
        end
    end)

    vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
        local hum = vehicleSeat.Occupant
        local char = hum and hum.Parent
        local plr = char and Players:GetPlayerFromCharacter(char)

        if hum and (not plr) then
            task.wait()

            hum.Sit = false

            local seatWeld = vehicleSeat:FindFirstChild("SeatWeld")
            if seatWeld then
                seatWeld:Destroy()
            end
        end
    end)
end

local function programCarSeating(car)
    local npcSeatsModel = car:WaitForChild("NpcSeats")
    local dismountButton = car:WaitForChild("DismountButton")
    local carBody = car:WaitForChild("Body")
    local passengerIndex = {}

    local dismountClicker = Instance.new("ClickDetector")
    dismountClicker.MaxActivationDistance = Config.DEFAULT_CLICK_DETECTOR_DISTANCE
    dismountClicker.Parent = dismountButton

    dismountClicker.MouseClick:Connect(function()
        blinkButton(dismountButton)
    end)

    -- Dismounting system
    local function listenForDismount(npc)
        local childListener
        local clickListener
        local ancestryListener
        
        local function dismountNpc(npc)
            passengerIndex[npc] = nil
            setNpcCollisionGroup(npc, "Default")
            setNpcSit(npc, false)
            setNpcRootAnchored(npc, false)
            npc:SetAttribute("LastDismounted", os.clock())
            pushNpcAwayFromPosition(npc, carBody.Position)

            childListener:Disconnect()
            clickListener:Disconnect()
            ancestryListener:Disconnect()
        end

        childListener = npc.ChildAdded:Connect(function(v)
            if v.Name == "NpcFollowScript" then
                dismountNpc(npc)
            end
        end)

        clickListener = dismountClicker.MouseClick:Connect(function()
            dismountNpc(npc)
        end)

        ancestryListener = car.AncestryChanged:Connect(function()
            if not car:IsDescendantOf(workspace) then
                dismountNpc(npc)
            end
        end)
    end

    -- Mounting system
    local function mountNpc(npc, seat)
        passengerIndex[npc] = seat
        setNpcCollisionGroup(npc, "GhostedNpcs")
        setNpcSit(npc, true)
        setNpcRootAnchored(npc, true)
        listenForDismount(npc)
        stopNpcFollowing(npc)
    end

    -- Add new passengers
    for _, seat in npcSeatsModel:GetChildren() do
        seat.Touched:Connect(function(hit)
            local npc = hit.Parent
            local hum = npc:FindFirstChild("Humanoid")
            local lastDismounted = npc:GetAttribute("LastDismounted") or 0

            local inNpcsBin = hit:IsDescendantOf(npcsBin)
            local isOccupied = seat:GetAttribute("IsOccupied")
            local isIndexed = passengerIndex[npc] ~= nil
            local isClingy = npc:GetAttribute("IsClingy")
            local isPastCooldown = os.clock() - lastDismounted >= Config.CAR_SEAT_COOLDOWN
            local isUnconscious = npc:GetAttribute("IsUnconscious")

            if (not isOccupied)
                and inNpcsBin
                and hum
                and (not isIndexed)
                and (not isClingy)
                and isPastCooldown
                and (not isUnconscious)
            then
                mountNpc(npc, seat)
            end
        end)
    end

    -- Riding physics
    RunService.Heartbeat:Connect(function()
        for npc, seat in passengerIndex do
            local root = npc:FindFirstChild("HumanoidRootPart")

            if not root then
                return
            end

            local rootHeight = root.Size.Y
            local seatHeight = seat.Size.Y
            local seatBuffer = 0.5
            local seatOffset = (rootHeight / 2) + (seatHeight / 2) + seatBuffer

            root.CFrame = seat.CFrame * CFrame.new(0, seatOffset, 0)
        end
    end)
end

local function programCarUnanchoring(car)
    for _, v in car:GetChildren() do
        if v.Name ~= "Wheel" then
            continue
        end

        v.Touched:Connect(function(hit)
            if BrickUtils.isTempUnanchorable(hit) then
                BrickUtils.tempUnanchor(hit)
            end
        end)
    end
end

local function makeCarGearAttachable(car)
    for _, v in car:GetDescendants() do
        if v:IsA("BasePart") then
            v:SetAttribute("IsGearAttachable", true)
        end
    end
end

--------------------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------------------

toolDebrisBin.ChildAdded:Connect(function(v)
    if v.Name == "Car" then
        makeCarGearAttachable(v)
        programCarDriving(v)
        programCarSeating(v)
        programCarUnanchoring(v)
    end
end)