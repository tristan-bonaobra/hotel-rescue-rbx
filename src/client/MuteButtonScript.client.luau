local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiUtils = require(ReplicatedStorage:WaitForChild("GuiUtils"))

local globalSoundsBin = workspace:WaitForChild("GlobalSounds")

local music = globalSoundsBin:WaitForChild("Music")
local mainGui = GuiUtils.getMainGui()
local button = mainGui:WaitForChild("MuteButton")
local volumeRemote = ReplicatedStorage:WaitForChild("GetServerMusicVolume")

local isMuted = false

local function getServerVolume()
	return volumeRemote:InvokeServer()
end

local function update()
	if isMuted then
		music.Volume = 0
		button.Text = "Unmute Music"
	else
		music.Volume = getServerVolume()
		button.Text = "Mute Music"
	end
end

update()

button.Activated:Connect(function()
	isMuted = not isMuted
	update()
end)