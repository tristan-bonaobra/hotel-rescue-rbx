if not script.Parent:IsA("Tool") then
    return
end

------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
------------------------------------------------------------------------------------------

local THEME = BrickColor.new("Magenta")
local EXIT_FADE_TIME = 2

local Debris = game:GetService("Debris")
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

local function teleportEnterEffect(root)
    local part = Instance.new("Part")
    part.Name = "TeleportEffect"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new()
    part.Shape = "Ball"
    part.CFrame = root.CFrame
    part.Material = "SmoothPlastic"
    part.BrickColor = THEME
    part.Parent = toolDebrisBin

    task.spawn(function()
        local targetProperties = {Size = Vector3.new(15, 15, 15), Transparency = 1}
        BrickUtils.tween(part, targetProperties, 0.5, Enum.EasingStyle.Exponential).Completed:Wait()
        part:Destroy()
    end)

    SoundUtils.playSound(root, "Gear.TranslocatorEnter")
end

local function teleportExitEffect(char)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            local part = Instance.new("Part")
            part.Name = "TeleporterGhostPart"
            part.Size = v.Size
            part.CFrame = v.CFrame
            part.BrickColor = THEME
            part.Material = "SmoothPlastic"
            part.Anchored = true
            part.CanCollide = false

            local mesh = v:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh:Clone().Parent = part
            end

            part.Parent = toolDebrisBin

            if v.Name == "HumanoidRootPart" then
                SoundUtils.playSound(part, "Gear.TranslocatorExit")
            end

            Debris:AddItem(part, EXIT_FADE_TIME)

            BrickUtils.tween(part, {Transparency = 1}, EXIT_FADE_TIME)
        end
    end
end

local function teleport()
    if translocator then
        local char = getChar()
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if root then
            teleportExitEffect(char)
            root.CFrame = CFrame.new(translocator.Position) * CFrame.new(0, 2.5, 0)
            teleportEnterEffect(root)
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