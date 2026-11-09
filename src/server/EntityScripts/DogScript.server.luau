if script.Parent.Name ~= "Dog" then
	return
end

local DEFAULT_NECK_POS = Vector3.new(0, 0.235, 0)
local DEFAULT_NECK_ROT = CFrame.Angles(math.rad(90), math.rad(180), 0)

local npcFolder = workspace:WaitForChild("Npcs")

local dog = script.Parent
local humanoid = dog:WaitForChild("Humanoid")
local torso = dog:WaitForChild("Torso")
local neckWeld = torso:WaitForChild("NeckWeld")

local myHead = dog:WaitForChild("Head")
local leaderHead
local shortestDistance = math.huge

for _, npc in npcFolder:GetChildren() do
	local npcHum = npc:FindFirstChildOfClass("Humanoid")
	local npcHead = npc:FindFirstChild("Head")
	local followScript = npc:FindFirstChild("NpcFollowScript")
	local isUnconscious = npc:GetAttribute("IsUnconscious")
	local isRescued = npc:GetAttribute("IsRescued")

	if npcHum and npcHead and (not followScript) and (not isUnconscious) and (not isRescued) then
		local distance = (npcHead.Position - myHead.Position).Magnitude
		if distance < shortestDistance then
			shortestDistance = distance
			leaderHead = npcHead
			leaderHum = npcHum
		end
	end
end

if not leaderHead then
	return
end

while task.wait(1 / 30) do
	local targetPos = leaderHead.Position

	humanoid:MoveTo(targetPos)
	humanoid.Jump = true

	local localTarget = torso.CFrame:PointToObjectSpace(targetPos)
	if (localTarget - DEFAULT_NECK_POS).Magnitude > 0.001 then
		local lookCFrame = CFrame.lookAt(DEFAULT_NECK_POS, localTarget)
		neckWeld.C0 = lookCFrame * DEFAULT_NECK_ROT
	end
end