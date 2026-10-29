------------------------------------------------------------------------------------------
-- DEPENDENCIES
------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SoundUtils = require(ServerScriptService.SoundUtils)
local Config = require(ServerScriptService:WaitForChild("Config"))

local npcsBin = workspace:WaitForChild("Npcs")
local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local boostedWalkSpeed = Config.DEFAULT_WALKSPEED + Config.FLAG_BOOST_AMOUNT

local ralliedHumanoidsDict = {}

------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------------------------------------

local function unionDict(a, b)
    local c = {}

    for i, v in a do c[i] = v end
    for i, v in b do c[i] = v end

    return c
end

local function unionLists(a, b)
    local c = {}
    
    table.move(a, 1, #a, 1, c)
    table.move(b, 1, #b, #c + 1, c)
    
    return c
end

------------------------------------------------------------------------------------------
-- GETTING HUMANOIDS
------------------------------------------------------------------------------------------

local function getHumAndRoot(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return hum, root
end

local function getPlayerHumanoidRootsDict()
    local humanoidRootsDict = {}
    
    for _, plr in Players:GetPlayers() do
        local char = plr.Character
        local hum, root = getHumAndRoot(char)

        if hum and root then
            humanoidRootsDict[hum] = root
        end
    end

    return humanoidRootsDict
end

local function getNpcHumanoidRootsDict()
    local humanoidRootsDict = {}
    
    for _, npc in npcsBin:GetChildren() do
        local hum, root = getHumAndRoot(npc)

        if hum and root then
            humanoidRootsDict[hum] = root
        end
    end

    return humanoidRootsDict
end

local function getHumanoidRootsDict()
    local playersDict = getPlayerHumanoidRootsDict()
    local npcsDict = getNpcHumanoidRootsDict()

    return unionDict(playersDict, npcsDict)
end

------------------------------------------------------------------------------------------
-- GETTING FLAGS
------------------------------------------------------------------------------------------

local function getFlagsInBin()
    local flags = {}

    for _, v in toolDebrisBin:GetChildren() do
        if v.Name == "RallyFlag" then
            table.insert(flags, v)
        end
    end

    return flags
end

local function getFlagsEquipped()
    local flagsList = {}

    for _, plr in Players:GetPlayers() do
        local char = plr.Character
        local tool = char and char:FindFirstChild("Rally Flag")
        local handle = tool and tool:FindFirstChild("Handle")

        if handle and (handle.Transparency == 0) then
            table.insert(flagsList, handle)
        end
    end

    return flagsList
end

local function getFlags()
    local binnedFlagsList = getFlagsInBin()
    local equippedFlagsList = getFlagsEquipped()
    return unionLists(binnedFlagsList, equippedFlagsList)
end

------------------------------------------------------------------------------------------
-- RALLYING
------------------------------------------------------------------------------------------

local function isNearFlag(root)
    local flagsList = getFlags()

    for _, flag in flagsList do
        local rootPos = root.Position
        local flagPos = flag.Position
        local mag = (rootPos - flagPos).Magnitude
        local flagRadius = Config.FLAG_EFFECT_DIAMETER / 2

        if mag <= flagRadius then
            return true
        end
    end

    return false
end

local function addHumanoidsToRally()
    local humanoidRootsDict = getHumanoidRootsDict()
    
    for hum, root in humanoidRootsDict do
        if (not hum:GetAttribute("IsUnconscious"))
            and (not hum:GetAttribute("IsRescued"))
            and (not ralliedHumanoidsDict[hum])
            and isNearFlag(root)
        then
            ralliedHumanoidsDict[hum] = {
                LastRallied = os.clock(),
                HumanoidRootPart = root
            }

            SoundUtils.playSound(root, "Gear.FlagBoost", false, Config.FLAG_BOOST_PITCH_SHIFT)
        end
    end
end

local function setHumanoidRallied(hum, isRallied)
    hum:SetAttribute("IsRallied", isRallied)
    hum.WalkSpeed = (isRallied and boostedWalkSpeed) or Config.DEFAULT_WALKSPEED
end

local function updateRalliedHumanoids()
    for hum, known in ralliedHumanoidsDict do

        local justUpdated = math.floor(known.LastRallied) == math.floor(os.clock())
        local inWorkspace = hum:IsDescendantOf(workspace)

        if inWorkspace and (justUpdated or isNearFlag(known.HumanoidRootPart)) then
            setHumanoidRallied(hum, true)
            ralliedHumanoidsDict[hum].LastRallied = os.clock()
        elseif os.clock() - known.LastRallied > Config.FLAG_BOOST_DURATION then
            setHumanoidRallied(hum, false)
            ralliedHumanoidsDict[hum] = nil
        end
    end
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

while task.wait(1/30) do
    addHumanoidsToRally()
    updateRalliedHumanoids()
end