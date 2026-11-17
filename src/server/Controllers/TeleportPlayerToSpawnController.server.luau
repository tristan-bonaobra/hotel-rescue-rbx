local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))
local TeleUtils = require(ServerScriptService:WaitForChild("TeleUtils"))

local remote = ReplicatedStorage:WaitForChild("TeleportPlayerToSpawn")
local spawnFolder = workspace:WaitForChild("PlayerSpawn")
local spawnIsland = spawnFolder:WaitForChild("Island")
local grass = spawnIsland:WaitForChild("Grass")

remote.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	if not char then
		return
	end

	local targetCFrame = grass.CFrame * CFrame.new(0, 15, 0)
	local brickColor = Config.SPAWNTP_EFFECT_BRICK_COLOR

	TeleUtils.teleport(char, targetCFrame, brickColor)
end)