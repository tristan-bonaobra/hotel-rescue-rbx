------------------------------------------------------------------------------
-- DEPENDENCIES
------------------------------------------------------------------------------

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local MapUtils = require(ServerScriptService:WaitForChild("MapUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local soundsLib = ServerStorage:WaitForChild("Sounds")
local musicLib = soundsLib:WaitForChild("Music")
local entityScriptsLib = ServerScriptService:WaitForChild("EntityScripts")

local globalSoundsBin = workspace:WaitForChild("GlobalSounds")
local npcsBin = workspace:WaitForChild("Npcs")
local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local teleporter = workspace:WaitForChild("Teleporter")

------------------------------------------------------------------------------
-- NEW OBJECTS
------------------------------------------------------------------------------

local music = musicLib:WaitForChild("UrbanDescent"):Clone()
music.Parent = globalSoundsBin

local message = Instance.new("Message")
local hint = Instance.new("Hint")
message.Parent = workspace
hint.Parent = workspace

------------------------------------------------------------------------------
-- STATE VARIABLES
------------------------------------------------------------------------------

local currentMap
local winZone
local npcsAtStart

------------------------------------------------------------------------------
-- MISC FUNCTIONS
------------------------------------------------------------------------------

local function formatTime(totalSeconds)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60
	return string.format("%02d:%02d", minutes, seconds)
end

------------------------------------------------------------------------------
-- GAME FUNCTIONS
------------------------------------------------------------------------------

local function initLeaderstats()
	local function initPlayer(player)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local points = Instance.new("IntValue")
		points.Name = "Points" 
		points.Value = Config.STARTER_POINTS
		points.Parent = leaderstats
	end
	
	for _, player in pairs(Players:GetPlayers()) do
		initPlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		initPlayer(player)
	end)
end

local function enableTeleporter()
	teleporter:SetAttribute("IsEnabled", true)
end

local function disableTeleporter()
	teleporter:SetAttribute("IsEnabled", false)
end

local function killAllPlayers()
	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if hum then
			hum.Health = 0
		end
	end
end

------------------------------------------------------------------------------
-- GAME LOOP
------------------------------------------------------------------------------

local function intermission()
	hint.Text = "Intermission"
	task.wait(Config.INTERMISSION_TIME)
	hint.Text = ""
end

local function loadMap()
	message.Text = "Loading"
	local map = MapUtils.loadMap()
	message.Text = ""
	task.wait(5)
	return map
end

local function storyIntro()
	hint.Text = "Noob: It's a beautiful day in Robloxia... ^_^"
	task.wait(5)
	hint.Text = "Noob: I sure hope nothing bad happens! XD"
	task.wait(5)
	hint.Text = "Noob: Let's see what's on the news... o_O"
	task.wait(5)
	hint.Text = "Noob: *turns on TV* :3"
	task.wait(2)
	hint.Text = "News: Emergency report!"
	SoundUtils.playSound(globalSoundsBin, "Game.EmergencyReport")
	task.wait(5)
	hint.Text = "News: A 1337 magnitude earthquake is coming to Robloxia!"
	task.wait(5)
	hint.Text = "Noob: O_O whaa.....??? >_>"
	task.wait(5)
	hint.Text = ""
end

local function earthquake()
	local newSound = SoundUtils.playSound(globalSoundsBin, "Game.EarthquakeLoop", true)
	hint.Text = "The earth is shaking... >_>"
	MapUtils.spawnNpcsOnMap(currentMap)
	MapUtils.crumbleMap(currentMap)
	newSound:Stop()
	task.wait(5)
	hint.Text = ""
end

local function storyGameBegin()
	hint.Text = "Noob: Is it over? T_T"
	task.wait(5)
	hint.Text = "Survivor 1: WAHHHH!!!!! ;-;"
	task.wait(5)
	hint.Text = "Survivor 2: I want my teddy bear... :(("
	SoundUtils.playSound(globalSoundsBin, "Game.Ping")
	task.wait(5)
	hint.Text = "President: Players, I have a new mission for you! >:|"
	task.wait(5)
	hint.Text = "President: You must evacuate the survivors of the earthquake!"
	task.wait(5)
	hint.Text = "Players: SIR YES SIR!"
	task.wait(5)
	hint.Text = "Captain: Don't forget to return to spawn to buy items, rookie!"
	SoundUtils.playSound(globalSoundsBin, "Game.Ping")
	task.wait(5)
	hint.Text = ""
end

local function gameBegin()
	winZone = ServerStorage:WaitForChild("WinZone"):Clone()
	entityScriptsLib:WaitForChild("WinScript"):Clone().Parent = winZone
	winZone.Parent = workspace
	enableTeleporter()
	npcsAtStart = #npcsBin:GetChildren()
	SoundUtils.playSound(globalSoundsBin, "Game.GameBegin")
end

local function gameCountdown()
	for timeRemaining = Config.GAME_TIME, 0, -1 do
		hint.Text = "Time left: " .. formatTime(timeRemaining)
		task.wait(1)
	end
end

local function destroyWinPart()
	local winPart = winZone:FindFirstChild("WinPart")
	if winPart then
		winPart:Destroy()
	end
end

local function recap()
	local totalRescued = 0
	for _, npc in npcsBin:GetChildren() do
		if npc:GetAttribute("IsRescued") then
			totalRescued += 1
		end
	end
	
	hint.Text = "Times up!"
	SoundUtils.playSound(globalSoundsBin, "Game.Victory")
	task.wait(5)
	hint.Text = "You evacuated "..totalRescued.." out of "..npcsAtStart.." survivors!"
	SoundUtils.playSound(globalSoundsBin, "Game.Applause")
	task.wait(5)
	hint.Text = "Thanks for playing!"
	task.wait(5)
	hint.Text = ""
end

local function resetGame()
	message.Text = "Resetting game"
	MapUtils.slowDestroy(currentMap)
	winZone:Destroy()
	disableTeleporter()
	killAllPlayers()
	task.wait(2)
	npcsBin:ClearAllChildren()
	toolDebrisBin:ClearAllChildren()
	message.Text = ""
end

local function gameLoop()
	while true do
		intermission()
		currentMap = loadMap()
		storyIntro()
		earthquake()
		storyGameBegin()
		gameBegin()
		music:Play()
		gameCountdown()
		music:Stop()
		destroyWinPart()
		recap()
		resetGame()
	end
end

------------------------------------------------------------------------------
-- ORCHESTRATE
------------------------------------------------------------------------------

initLeaderstats()
gameLoop()