local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local soundsLib = ServerStorage:WaitForChild("Sounds")

local function copySound(pathString)
    local path = pathString:split(".")
    local subLibName = path[1]
    local soundName = path[2]

    local subLib = soundsLib:FindFirstChild(subLibName)
    local asset = subLib and subLib:FindFirstChild(soundName)

    if asset then
        local sound = asset:Clone()
        return sound
    end
    return
end

local function stopSounds(instance, soundName)
    for _, v in pairs(instance:GetChildren()) do
        if (v:IsA("Sound")) and (v.Name == soundName) then
            v:Stop()
        end
    end
end

local function playSound(instance, pathString, isLooped, pitchShift)
    local sound = copySound(pathString)
    if sound then
        stopSounds(instance, sound.Name)
        
        sound.Parent = instance
        sound.Looped = isLooped

        if pitchShift then
            local a = 1000
            local s = pitchShift * a
            sound.PlaybackSpeed += math.random(-s, s) / a
        end

        sound:Play()

        if not isLooped then
            Debris:AddItem(sound, (sound.TimeLength / sound.PlaybackSpeed) + 2)
        end

        return sound
    end
    return
end

return {
    playSound = playSound,
    copySound = copySound
}