if not script.Parent:IsA("Humanoid") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ServerScriptService:WaitForChild("Config"))

local myHum = script.Parent
local myChar = myHum.Parent
local myHead = myChar:WaitForChild("Head")
local leaderHead
local leaderHum
local shortestDistance = math.huge

for _, player in ipairs(game.Players:GetPlayers()) do
	local character = player.Character
	if character then
		local playerHum = character:FindFirstChildOfClass("Humanoid")
		local playerHead = character:FindFirstChild("Head")
		if playerHum and playerHead then
			local distance = (playerHead.Position - myHead.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				leaderHead = playerHead
				leaderHum = playerHum
			end
		end
	end
end

leaderHum.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		task.wait(math.random(0, 5) * 0.1)
		myHum.Jump = true
	end
end)

myChar.AttributeChanged:Connect(function()
	if myChar:GetAttribute("IsRescued") or myChar:GetAttribute("IsUnconscious") then
		script:Destroy()
	end
end)

while task.wait(0.5) do
	if (leaderHead.Position - myHead.Position).Magnitude >= Config.NPC_FOLLOW_DISTANCE_THRESHOLD then
		local walkToCFrame = CFrame.new(leaderHead.Position, myHead.Position) * CFrame.new(0, 0, -Config.NPC_FOLLOW_DISTANCE_THRESHOLD)
		myHum:MoveTo(walkToCFrame.Position)
	end
end