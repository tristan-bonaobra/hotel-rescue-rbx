-------------------------------------------------------------------------------------------
-- DEPENDENCIES
-------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

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
        FasterEarthquake = false,
        IsPreprocessed = false,
        IsForWelding = false,
    },

    {
        MapObject = getMap("TheAmazeman's End of Roblox"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = DEFAULT_ROUND_TIME,
        FasterEarthquake = false,
        IsPreprocessed = false,
        IsForWelding = false,
    },

    {
        MapObject = getMap("IcyFresh's Underground Base"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = 7 * 60,
        FasterEarthquake = false,
        IsPreprocessed = true,
        IsForWelding = false,
    },

    {
        MapObject = getMap("Stickmasterluke's Prison Panic"),
        MusicObject = getMusic(DEFAULT_MUSIC),
        RoundTime = 7 * 60,
        FasterEarthquake = false,
        IsPreprocessed = false,
        IsForWelding = false,
    },

    {
        MapObject = getMap("Cindering's Robloxian High School"),
        MusicObject = getMusic("GroundworksComplex"),
        RoundTime = 10 * 60,
        FasterEarthquake = false,
        IsPreprocessed = false,
        IsForWelding = true,
    },]]

    {
        MapObject = getMap("1dev2's Town of Robloxia"),
        MusicObject = getMusic("GroundworksComplex"),
        RoundTime = 10 * 60,
        FasterEarthquake = true,
        IsPreprocessed = false,
        IsForWelding = true,

        Init = function(map)
            local filteredDescendantsModel = map:WaitForChild("NongameParts")
            local filteredDescendants = filteredDescendantsModel:GetDescendants()
            local baseExtensionModel = filteredDescendantsModel:WaitForChild("BaseExtension")

            for _, v in filteredDescendants do
                if v:IsA("BasePart") then
                    v:SetAttribute("PreventSpawning", true)

                    if v:IsDescendantOf(baseExtensionModel) then
                        BrickUtils.grantImmunity(v)
                    end
                end
            end
        end,
    },
}