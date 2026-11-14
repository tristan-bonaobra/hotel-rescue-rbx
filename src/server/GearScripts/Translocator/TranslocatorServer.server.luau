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

local translocatorPlaced, translocatorRetrieved = GearUtils.placeMode(tool)
local translocator
local isActive

------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------

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
        local char = GearUtils.getChar(tool)
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if root then
            teleportExitEffect(char)
            root.CFrame = CFrame.new(translocator.Position) * CFrame.new(0, 2.5, 0)
            teleportEnterEffect(root)
        end
    end
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

translocatorPlaced:Connect(function(placedHandle)
    translocator = placedHandle
    SoundUtils.playSound(translocator, "Gear.TranslocatorEngage")
end)

translocatorRetrieved:Connect(teleport)