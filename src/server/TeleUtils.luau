local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local function enterEffect(char, brickColor)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local part = Instance.new("Part")
    part.Name = "TeleportEffect"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new()
    part.Shape = "Ball"
    part.CFrame = root.CFrame
    part.Material = "SmoothPlastic"
    part.BrickColor = brickColor
    part.Parent = toolDebrisBin

    task.spawn(function()
        local targetProperties = {Size = Vector3.new(15, 15, 15), Transparency = 1}
        BrickUtils.tween(part, targetProperties, 0.5, Enum.EasingStyle.Exponential).Completed:Wait()
        part:Destroy()
    end)

    SoundUtils.playSound(root, "Gear.TranslocatorEnter")
end

local function exitEffect(char, brickColor)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            local part = Instance.new("Part")
            part.Name = "TeleporterGhostPart"
            part.Size = v.Size
            part.CFrame = v.CFrame
            part.BrickColor = brickColor
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

            BrickUtils.tween(part, {Transparency = 1}, Config.TELEPORT_EXIT_FADE_TIME)
            Debris:AddItem(part, Config.TELEPORT_EXIT_FADE_TIME)
        end
    end
end

local function teleport(char, targetCFrame, brickColor)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    exitEffect(char, brickColor)
    root.CFrame = targetCFrame
    enterEffect(char, brickColor)
end

return {
    teleport = teleport,
}