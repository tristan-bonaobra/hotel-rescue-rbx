if not script.Parent:IsA("Tool") then
    return
end

--------------------------------------------------------------------------------------------
-- DEPENDENCIES & VARIABLES
--------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local beam = tool:WaitForChild("Beam")
local pointer = tool:WaitForChild("Pointer")

local isActive = false
local relativeCFrame = handle.CFrame:ToObjectSpace(pointer.CFrame)

--------------------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------------------

local function getPartsInBeam(currentMap)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {currentMap}
    overlapParams.FilterType = Enum.RaycastFilterType.Include

    local affectedParts = workspace:GetPartsInPart(beam, overlapParams)
    return affectedParts
end

local function freezePart(part)
    part.BrickColor = beam.BrickColor
    part.Material = beam.Material

	local breakParams = {
		Threshold = Config.BREAK_THRESHOLD_MANUAL,
		IsRecursive = true,
		Unanchor = false,
		Tint = true
	}

	BrickUtils.breakPart(part, breakParams)
end

local function repositionPointer()
    pointer.CFrame = handle.CFrame * relativeCFrame
end

--------------------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------------------

tool.Activated:Connect(function()
    if isActive then
        return
    end

    isActive = true

    beam.Transparency = 0.4
    pointer.Transparency = 1
    SoundUtils.playSound(handle, "Gear.IceMagic")
    
    local currentMap = workspace:WaitForChild("CurrentMap")
    if not currentMap then
        return
    end

    local partsAtStart
    local partsAtEnd
    local frozeOnePart = false

    partsAtStart = getPartsInBeam(currentMap)
    task.wait(Config.FREEZE_RAY_WINDUP)
    partsAtEnd = getPartsInBeam(currentMap)

    -- The affected part must take presumably the whole duration of the beam.
    for _, part in partsAtStart do
        local tookWholeBeam = table.find(partsAtEnd, part)
        local isBreakable = BrickUtils.isBreakable(part)

        if tookWholeBeam and isBreakable then
            freezePart(part)
            frozeOnePart = true
        end
    end

    beam.Transparency = 1
    pointer.Transparency = 0

    if frozeOnePart then
        SoundUtils.playSound(handle, "Gear.IceFreeze")
    end

    task.wait(Config.FREEZE_RAY_COOLDOWN)
    isActive = false
end)

RunService.Heartbeat:Connect(repositionPointer)