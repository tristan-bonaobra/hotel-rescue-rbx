local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local mapFolder = ServerStorage:WaitForChild("Maps")
local globalSoundsBin = workspace:WaitForChild("GlobalSounds")
local npcFolder = workspace:WaitForChild("Npcs")
local toolDebrisFolder = workspace:WaitForChild("ToolDebris")

local soundsLib = ServerStorage:WaitForChild("Sounds")
local gameSoundsLib = soundsLib:WaitForChild("Game")
local musicLib = soundsLib:WaitForChild("Music")

local Config = require(ServerScriptService:WaitForChild("Config"))
local MapManipulation = require(ServerScriptService:WaitForChild("MapManipulation"))

local teleporter = workspace:WaitForChild("Teleporter")
local message = Instance.new("Message")
local hint = Instance.new("Hint")
local currentMap
local winZone
local npcsAtStart

local music = musicLib:WaitForChild("UrbanDescent"):Clone()
music.Parent = globalSoundsBin

message.Parent = workspace
hint.Parent = workspace

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

local function autoDestroySound(sound)
	task.spawn(function()
		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		local trueLength = sound.TimeLength / sound.PlaybackSpeed
		Debris:AddItem(sound, trueLength)
	end)
end

local function playGameSound(name, isLooped)
	local originalSound = gameSoundsLib:FindFirstChild(name)
	if originalSound then
		local newSound = originalSound:Clone()
		newSound.Parent = globalSoundsBin
		newSound.Looped = isLooped
		newSound:Play()

		if not isLooped then
			autoDestroySound(newSound)
		end

		return newSound
	end
	return
end

------------------------------------------------------------------------------
-- GAME LOOP
------------------------------------------------------------------------------

local function intermission()
	hint.Text = "Intermission"
	task.wait(Config.INTERMISSION_TIME)
	hint.Text = ""
end

local function getRandomMap()
	if #mapFolder:GetChildren() == 0 then
		mapFolder.ChildAdded:Wait()
	end
	
	local maps = mapFolder:GetChildren()
	return maps[math.random(#maps)]:Clone()
end

-- Move to MapUtils
local function loadMap()
	currentMap = getRandomMap()
	currentMap.Name = "CurrentMap"
	message.Text = "Loading"
	task.wait(1)
	if not currentMap:GetAttribute("IsProcessed") then
		MapManipulation.cleanMap(currentMap)
		MapManipulation.anchorMap(currentMap)
		currentMap.Parent = workspace
		MapManipulation.breakMap(currentMap)
		if currentMap:GetAttribute("ForWelding") then MapManipulation.weldMap(currentMap) end
	else
		currentMap.Parent = workspace
	end
	message.Text = ""
	task.wait(5)
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
	playGameSound("EmergencyReport")
	task.wait(5)
	hint.Text = "News: A 1337 magnitude earthquake is coming to Robloxia!"
	task.wait(5)
	hint.Text = "Noob: O_O whaa.....??? >_>"
	task.wait(5)
	hint.Text = ""
end

local function earthquake()
	local newSound = playGameSound("EarthquakeLoop", true)
	hint.Text = "The earth is shaking... >_>"
	MapManipulation.spawnNpcsOnMap(currentMap)
	MapManipulation.crumbleMap(currentMap)
	newSound:Stop()
	task.wait(5)
	hint.Text = ""
end

local function storyGameBegin()
	hint.Text = "Noob: Is it over? T_T"
	task.wait(5)
	hint.Text = "Survivor 1: WAHHHH!!!!! ;-;"
	task.wait(5)
	hint.Text = "Survivor 2: I want my teddy bear... :(( ??"
	playGameSound("Ping")
	task.wait(5)
	hint.Text = "President: Players, I have a new mission for you! >:|"
	task.wait(5)
	hint.Text = "President: You must evacuate the survivors of the earthquake!"
	task.wait(5)
	hint.Text = "Players: SIR YES SIR!"
	task.wait(5)
	hint.Text = "Captain: Don't forget to return to spawn to buy items, rookie!"
	playGameSound("Ping")
	task.wait(5)
	hint.Text = ""
end

local function gameBegin()
	winZone = ServerStorage:WaitForChild("WinZone"):Clone()
	winZone.Parent = workspace
	enableTeleporter()
	npcsAtStart = #npcFolder:GetChildren()
	playGameSound("GameBegin")
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
	for _, npc in npcFolder:GetChildren() do
		if npc:GetAttribute("IsRescued") then
			totalRescued += 1
		end
	end
	
	hint.Text = "Times up!"
	playGameSound("Victory")
	task.wait(5)
	hint.Text = "You evacuated "..totalRescued.." out of "..npcsAtStart.." survivors!"
	playGameSound("Applause")
	task.wait(5)
	hint.Text = "Thanks for playing!"
	task.wait(5)
	hint.Text = ""
end

local function resetGame()
	message.Text = "Resetting game"
	MapManipulation.slowDestroy(currentMap)
	winZone:Destroy()
	disableTeleporter()
	killAllPlayers()
	task.wait(2)
	npcFolder:ClearAllChildren()
	toolDebrisFolder:ClearAllChildren()
	message.Text = ""
end

local function gameLoop()
	while true do
		intermission()
		loadMap()
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
-- END
------------------------------------------------------------------------------

return {
	initLeaderstats = initLeaderstats,
	gameLoop = gameLoop,
	loadMap = loadMap,
}