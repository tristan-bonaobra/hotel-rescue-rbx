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

local translocator
local isActive

------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------------------------------------

-- Move to GearUtils...
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

------------------------------------------------------------------------------------------
-- GEAR FUNCTIONS
------------------------------------------------------------------------------------------

local function placeTranslocator()
    translocator = handle:Clone()
    translocator.Name = "Translocator"
    translocator.CanCollide = true
    BrickUtils.breakJoints(translocator)
    translocator.Parent = toolDebrisBin
    SoundUtils.playSound(translocator, "Gear.TranslocatorEngage")
    BrickUtils.stabilize(translocator)

    GearUtils.toolAnim(tool, "Slash")
    handle.Transparency = 1
end

local function retrieveTranslocator()
    if translocator:IsDescendantOf(workspace) then
        translocator:Destroy()
    end

    handle.Transparency = 0
end

local function teleportEffect(root)
    local part = Instance.new("Part")
    part.Name = "TeleportEffect"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new()
    part.Shape = "Ball"
    part.CFrame = root.CFrame
    part.Material = "SmoothPlastic"
    part.BrickColor = BrickColor.new("Magenta")
    part.Parent = toolDebrisBin

    task.spawn(function()
        local targetProperties = {Size = Vector3.new(15, 15, 15), Transparency = 1}
        BrickUtils.tween(part, targetProperties, 0.5, Enum.EasingStyle.Exponential).Completed:Wait()
        part:Destroy()
    end)

    SoundUtils.playSound(root, "Gear.TranslocatorTeleport")
end

local function teleport()
    if translocator then
        local char = getChar()
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = CFrame.new(translocator.Position) * CFrame.new(0, 2.5, 0)
            teleportEffect(root)
        end

        retrieveTranslocator()
    end
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

tool.Activated:Connect(function()
    isActive = not isActive

    if isActive then
        placeTranslocator()
    else
        teleport()
    end
end)