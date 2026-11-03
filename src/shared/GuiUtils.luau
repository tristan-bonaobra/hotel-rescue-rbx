local Players = game:GetService("Players")

local function getPlayerGuiFolder()
    local plr = Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")
    return playerGui
end

local function getMainGui()
    local playerGuiFolder = getPlayerGuiFolder()
    local mainGui = playerGuiFolder:WaitForChild("MainGui")
    return mainGui
end

return {
    getPlayerGuiFolder = getPlayerGuiFolder,
    getMainGui = getMainGui,
}