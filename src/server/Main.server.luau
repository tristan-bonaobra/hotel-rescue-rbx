local Init = require(script:WaitForChild("Init"))
local ServerStorage = game:GetService("ServerStorage")

Init.extractGamePackage("ServerStorage", ServerStorage)
Init.extractGamePackage("Workspace", workspace)

local HotelRescue = script.Parent
local MapManipulation = Init.importSubpackage("MapManipulation")
local GameMaster = Init.importSubpackage("GameMaster")
local NpcLoader = Init.importSubpackage("NpcLoader")

GameMaster.initLeaderstats()
task.spawn(GameMaster.gameLoop)