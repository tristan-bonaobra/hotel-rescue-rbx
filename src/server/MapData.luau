-------------------------------------------------------------------------------------------
-- DEPENDENCIES
-------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local DEFAULT_ROUND_TIME = Config.DEFAULT_ROUND_TIME
local DEFAULT_MUSIC = Config.DEFAULT_MUSIC

local mapsLib = ServerStorage:WaitForChild("Maps")
local soundsLib = ServerStorage:WaitForChild("Sounds")
local musicLib = soundsLib:WaitForChild("Music")

-------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------------------

-- Check at this level whether all map references are valid.

local function getMap(name)
    return mapsLib:WaitForChild(name)
end

local function getMusic(name)
    return musicLib:WaitForChild(name)
end

-------------------------------------------------------------------------------------------
-- MAP DATA
-------------------------------------------------------------------------------------------

return {
    --[[{
        MapObject = getMap("Radioaktiivinen's Disaster Hotel"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = DEFAULT_ROUND_TIME,
        IsPreprocessed = false,
        IsForWelding = false,
    },

    {
        MapObject = getMap("TheAmazeman's End of Roblox"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = DEFAULT_ROUND_TIME,
        IsPreprocessed = false,
        IsForWelding = false,
    },

    {
        MapObject = getMap("IcyFresh's Underground Base"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = DEFAULT_ROUND_TIME,
        IsPreprocessed = true,
        IsForWelding = false,
    },

    {
        MapObject = getMap("Stickmasterluke's Prison Panic"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = DEFAULT_ROUND_TIME,
        IsPreprocessed = false,
        IsForWelding = false,
    },]]

    {
        MapObject = getMap("Cindering's Robloxian High School"),
        MusicObject = getMusic("GroundworksComplex"),
        RoundTime = 12 * 60,
        IsPreprocessed = false,
        IsForWelding = true,
    },
}