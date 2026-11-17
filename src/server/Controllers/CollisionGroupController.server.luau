local Players = game:GetService("Players")

local npcsBin = workspace:WaitForChild("Npcs")

local function setModelCollisionGroup(model, groupName)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = groupName
		end
	end

	model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = groupName
		end
	end)
end

-----------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------

for _, player in Players:GetPlayers() do
	if player.Character then
		setModelCollisionGroup(player.Character)
	end

	player.CharacterAdded:Connect(function(char)
		setModelCollisionGroup(char, "Player")
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setModelCollisionGroup)
end)

-----------------------------------------------------------------------------------------
-- NPCS
-----------------------------------------------------------------------------------------

npcsBin.ChildAdded:Connect(function(npc)
	setModelCollisionGroup(npc, "Npcs")
end)