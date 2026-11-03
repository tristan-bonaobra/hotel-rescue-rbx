local ReplicatedStorage = game:GetService("ReplicatedStorage")

local globalSoundsBin = workspace:WaitForChild("GlobalSounds")

local music = globalSoundsBin:WaitForChild("Music")
local volumeRemote = ReplicatedStorage:WaitForChild("GetServerMusicVolume")

volumeRemote.OnServerInvoke = function(plr)
	return music.Volume
end