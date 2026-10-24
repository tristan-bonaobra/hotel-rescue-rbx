local Chat = game:GetService("Chat")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = ServerScriptService:WaitForChild("Config")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local isActive
local rescueSounds = {}

for _, v in handle:GetChildren() do
	if v:IsA("Sound") and v.Name:find("rescue") then
		table.insert(rescueSounds, v)
	end
end

local function playAnim()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	game.Debris:AddItem(anim, 1)
end

tool.Activated:Connect(function()
	if isActive then
		return
	end
	
	isActive = true
	
	local Npcs = workspace:FindFirstChild("Npcs")
	local mode = "StopFollowing"

	if Npcs then
		local searchParams = OverlapParams.new()
		searchParams.FilterType = Enum.RaycastFilterType.Include
		searchParams.FilterDescendantsInstances = {Npcs}
		
		local affectedParts = workspace:GetPartBoundsInRadius(handle.Position, Config.BEAR_RADIUS, searchParams)
		local detectedHumanoids = {}
		local detectedOne = false
		
		for _, part in ipairs(affectedParts) do
			local hum = part.Parent:FindFirstChildOfClass("Humanoid")
			if hum and (not table.find(detectedHumanoids, hum)) then
				local existingFollowScript = hum:FindFirstChild("NpcFollowScript")
				if (mode ~= "StartFollowing") and (not existingFollowScript) then
					mode = "StartFollowing"
				end
				table.insert(detectedHumanoids, hum)
				detectedOne = true
			end
		end
		
		if (not detectedOne) then
			mode = nil
		else
			for _, hum in pairs(detectedHumanoids) do
				local existingFollowScript = hum:FindFirstChild("NpcFollowScript")
				if (mode == "StopFollowing") and existingFollowScript then
					existingFollowScript:Destroy()
				elseif (mode == "StartFollowing") and (not existingFollowScript) then
					script.NpcFollowScript:Clone().Parent = hum
				end
			end
		end
	end
	
	local char = tool.Parent
	local head = char:FindFirstChild("Head")
	local chatMessage
	
	if mode == "StartFollowing" then
		playAnim()
		rescueSounds[math.random(#rescueSounds)]:Play()
		chatMessage = Config.BEAR_MESSAGE_FOLLOW
	elseif mode == "StopFollowing" then
		playAnim()
		handle.ButtonWav:Play()
		chatMessage = Config.BEAR_MESSAGE_STAY
	else
		tool.GripForward = Vector3.new(1,0,0)
		tool.GripPos = Vector3.new(.5,-1.5,-1.56)
		tool.GripRight = Vector3.new(0,-.707,-.707)
		tool.GripUp = Vector3.new(0,-.707,.707)
		handle.Squeak:Play()
	end
	
	if head and chatMessage then
		Chat:Chat(head, chatMessage)
	end
	
	task.wait(Config.BEAR_COOLDOWN)
	
	tool.GripForward = Vector3.new(-1,0,0)
	tool.GripPos = Vector3.new(0,0,-.4)
	tool.GripRight = Vector3.new(0,1,0)
	tool.GripUp = Vector3.new(0,0,1)
	
	isActive = false
end)