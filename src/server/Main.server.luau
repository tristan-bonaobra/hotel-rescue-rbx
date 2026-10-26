local ServerScriptService = game:GetService("ServerScriptService")

local GameMaster = require(ServerScriptService:WaitForChild("GameMaster"))

GameMaster.initLeaderstats()
GameMaster.gameLoop()