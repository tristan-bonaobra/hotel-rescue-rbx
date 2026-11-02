if not script.Parent:IsA("Model") then
    return
end

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local NpcUtils = require(ServerScriptService:WaitForChild("NpcUtils"))

local npcAssetsLib = ServerStorage:WaitForChild("NpcAssets")
local classicClothing = npcAssetsLib:WaitForChild("ClassicClothing")

local npc = script.Parent
local head = npc:WaitForChild("Head")
local newFace = NpcUtils.personalityFacesLib:WaitForChild("Clingy"):Clone()

npc:SetAttribute("IsClingy", true)
NpcUtils.replaceFace(npc, newFace)
NpcUtils.playUtterances(npc, "Clingy")

for _, v in npc:GetChildren() do
    if v:IsA("BasePart") then
        v.BrickColor = head.BrickColor
    end
end

classicClothing:WaitForChild("PyjamaShirt"):Clone().Parent = npc
classicClothing:WaitForChild("PyjamaPants"):Clone().Parent = npc