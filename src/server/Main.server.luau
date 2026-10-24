local ServerScriptService = game:GetService("ServerScriptService")

local GameMaster = ServerScriptService:WaitForChild("GameMaster")

GameMaster.initLeaderstats()
GameMaster.gameLoop()