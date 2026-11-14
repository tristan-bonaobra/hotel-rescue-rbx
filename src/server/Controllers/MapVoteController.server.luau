------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local MapData = require(ServerScriptService:WaitForChild("MapData"))

local voteArea = workspace:WaitForChild("MapVoteArea")

local mapIds = {}
local voteData = {}

local booths = {
    voteArea:WaitForChild("Booth1"),
    voteArea:WaitForChild("Booth2"),
    voteArea:WaitForChild("Booth3")
}

------------------------------------------------------------------------------------------
-- NEW OBJECTS
------------------------------------------------------------------------------------------

local trigger = Instance.new("BindableEvent")
trigger.Name = "BeginVoteTrigger"
trigger.Parent = voteArea

------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------------------------------------

local function getVotes(mapId)
    local votes = 0
    for _, votedMapId in voteData do
        if votedMapId == mapId then
            votes += 1
        end
    end
    return votes
end

------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
------------------------------------------------------------------------------------------

local function reshuffleMapIds()
    mapIds = {}
    repeat
        local id = math.random(#MapData)
        if table.find(mapIds, id) then
            task.wait()
        else
            table.insert(mapIds, id)
        end
    until #mapIds == 3
end

local function updateBooths()
    for i, booth in booths do
        local mapId = mapIds[i]
        local map = MapData[mapId]

        local screen = booth:WaitForChild("Screen")
        local votePad = booth:WaitForChild("VotePad")
        local surfaceGui = screen:WaitForChild("SurfaceGui")

        local titleLabel = surfaceGui:WaitForChild("Title")
        local thumbnailLabel = surfaceGui:WaitForChild("Thumbnail")
        local hum = votePad:WaitForChild("Humanoid")

        titleLabel.Text = map.MapObject.Name
        thumbnailLabel.Image = map.ThumbnailId or ""
        hum.DisplayName = "Votes: "..getVotes(mapId)
    end
end

local function updateWinner()
    local sortedMapIds = table.clone(mapIds)
    table.sort(sortedMapIds, function(a, b)
        return getVotes(a) > getVotes(b)
    end)
    
    local winningMapId = sortedMapIds[1]
    voteArea:SetAttribute("WinningMapId", winningMapId)
end

local function updateVoteArea()
    updateBooths()
    updateWinner()
end

local function beginVote()
    voteData = {}
    reshuffleMapIds()
    updateVoteArea()
end

local function programVotePads()
    for i, booth in booths do
        local votePad = booth:WaitForChild("VotePad")
        local head = votePad:WaitForChild("Head")

        head.Touched:Connect(function(hit)
            local char = hit.Parent
            local plr = Players:GetPlayerFromCharacter(char)

            if plr then
                local mapId = mapIds[i]
                voteData[plr] = mapId
                updateVoteArea()
            end
        end)
    end
end

------------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------------

beginVote()
programVotePads()

trigger.Event:Connect(beginVote)