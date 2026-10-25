local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local soundsLib = ServerStorage:WaitForChild("Sounds")

local function playSound(instance, pathString, isLooped)
    local path = pathString:split(".")
    local subLibName = path[1]
    local soundName = path[2]

    local subLib = soundsLib:FindFirstChild(subLibName)
    local asset = subLib and subLib:FindFirstChild(soundName)

    if asset then
        local sound = asset:Clone()
        sound.Parent = instance
        sound.Looped = isLooped
        sound:Play()

        if not isLooped then
            Debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)
        end

        return sound
    end
    return
end

return {
    playSound = playSound
}