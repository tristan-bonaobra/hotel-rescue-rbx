if not script.Parent:IsA("Tool") then
    return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))
local TeleUtils = require(ServerScriptService:WaitForChild("TeleUtils"))

local tool = script.Parent
local translocator

local function teleport()
    if translocator then
        local char = GearUtils.getChar(tool)
        local targetCFrame = CFrame.new(translocator.Position) * CFrame.new(0, 2.5, 0)

        TeleUtils.teleport(char, targetCFrame, Config.TRANSLOCATOR_EFFECT_BRICK_COLOR)
    end
end

local translocatorPlaced, translocatorRetrieved = GearUtils.placeMode(tool)

translocatorPlaced:Connect(function(placedHandle)
    translocator = placedHandle
    SoundUtils.playSound(translocator, "Gear.TranslocatorEngage")
end)

translocatorRetrieved:Connect(teleport)