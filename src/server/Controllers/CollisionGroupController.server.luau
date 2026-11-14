local Players = game:GetService("Players")

local function setupCharacter(character)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Players"
		end
	end

	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Players"
		end
	end)
end

for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		setupCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupCharacter)
end)