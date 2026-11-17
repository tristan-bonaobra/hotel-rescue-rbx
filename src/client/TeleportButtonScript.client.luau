local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiUtils = require(ReplicatedStorage:WaitForChild("GuiUtils"))

local mainGui = GuiUtils.getMainGui()
local button = mainGui:WaitForChild("TeleportButton")
local remote = ReplicatedStorage:WaitForChild("TeleportPlayerToSpawn")

button.Activated:Connect(function()
    remote:FireServer()
end)