if not script.Parent:IsA("Tool") then
	return
end

------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")

local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local flagPlaced, flagRetrieved = GearUtils.placeMode(tool)
local isActive

local function setEffectsEnabled(isEnabled)
    local sparkles = handle:WaitForChild("Sparkles")
    local light = handle:WaitForChild("PointLight")

    sparkles.Enabled = isEnabled
    light.Enabled = isEnabled
end

flagPlaced:Connect(function(placedHandle, weld)
    placedHandle.Name = "RallyFlag"
    isActive = true
    setEffectsEnabled(false)

    if weld then
        SoundUtils.playSound(handle, "Gear.FlagPlace")
    else
        SoundUtils.playSound(handle, "Gear.FlagDrop")
    end
        
end)

flagRetrieved:Connect(function()
    SoundUtils.playSound(handle, "Gear.FlagPlace").PlaybackSpeed = 0.85
    isActive = false
    setEffectsEnabled(true)
end)

tool.Equipped:Connect(function()
    if (not isActive) then
        SoundUtils.playSound(handle, "Gear.FlagWhistle")
    end
end)