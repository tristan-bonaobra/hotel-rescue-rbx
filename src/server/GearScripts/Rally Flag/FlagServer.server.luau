if not script.Parent:IsA("Tool") then
	return
end

------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")

local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local sparkles = handle:WaitForChild("Sparkles")
local light = handle:WaitForChild("PointLight")

local flag
local isActive

------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------

local function getChar()
    if tool.Parent:IsA("Model") then
        return tool.Parent
    elseif tool.Parent:IsA("Backpack") then
        local backpack = tool.Parent
        local plr = backpack.Parent
        return plr.Character
    end
    return
end

local function setHandleVisible(isVisible)
    handle.Transparency = (isVisible and 0) or 1
    sparkles.Enabled = isVisible
    light.Enabled = isVisible
end

local function awaitUnweld(weld)
    if not weld.Part0 then
        return
    end

    task.spawn(function()
        weld.Part0.AncestryChanged:Wait()
        if flag then
            flag.CanCollide = true
        end
    end)
end

local function placeFlag()
    flag = handle:Clone()
    flag.Name = "RallyFlag"

    BrickUtils.breakJoints(flag)
    BrickUtils.stabilize(flag)

    setHandleVisible(false)
    GearUtils.toolAnim(tool, "Slash")

    local raycastResult = BrickUtils.raycast(
        handle.Position,
        handle.Position + Vector3.new(0, -10, 0),
        Enum.RaycastFilterType.Exclude,
        {getChar()}
    )

    if raycastResult then
        local base = raycastResult.Instance
        local rayHit = raycastResult.Position

        flag.CFrame = CFrame.new(rayHit) * CFrame.new(-flag.Size.X / 2, flag.Size.Y / 2, 0)
        flag.CanCollide = false

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = base
        weld.Part1 = flag
        weld.Parent = flag
        awaitUnweld(weld)

        SoundUtils.playSound(handle, "Gear.FlagPlace")
    else
        flag.CanCollide = true
        SoundUtils.playSound(handle, "Gear.FlagDrop")
    end

    flag.Parent = toolDebrisBin
end

local function retrieveFlag()
    setHandleVisible(true)
    SoundUtils.playSound(handle, "Gear.FlagPlace").PlaybackSpeed = 0.85
    
    if flag:IsDescendantOf(workspace) then
        flag:Destroy()
    end
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

tool.Activated:Connect(function()
    isActive = not isActive
    if isActive then
        placeFlag()
    else
        retrieveFlag()
    end
end)

tool.Equipped:Connect(function()
    if not isActive then
        SoundUtils.playSound(handle, "Gear.FlagWhistle")
    end
end)