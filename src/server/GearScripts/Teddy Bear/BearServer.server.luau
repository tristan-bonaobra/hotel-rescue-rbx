if not script.Parent:IsA("Tool") then
	return
end

local Chat = game:GetService("Chat")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local entityScriptsLib = ServerScriptService:WaitForChild("EntityScripts")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local isActive

local rescueSoundPaths = {
	"Gear.BearFollow1",
	"Gear.BearFollow2",
	"Gear.BearFollow3",
	"Gear.BearFollow4"
}

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
					entityScriptsLib:WaitForChild("NpcFollowScript"):Clone().Parent = hum
				end
			end
		end
	end
	
	local char = tool.Parent
	local head = char:FindFirstChild("Head")

	local chatMessage
	local soundPath
	
	if mode == "StartFollowing" then
		playAnim()
		soundPath = rescueSoundPaths[math.random(#rescueSoundPaths)]
		chatMessage = Config.BEAR_MESSAGE_FOLLOW
	elseif mode == "StopFollowing" then
		playAnim()
		soundPath = "Gear.BearStay"
		chatMessage = Config.BEAR_MESSAGE_STAY
	else
		tool.GripForward = Vector3.new(1,0,0)
		tool.GripPos = Vector3.new(.5,-1.5,-1.56)
		tool.GripRight = Vector3.new(0,-.707,-.707)
		tool.GripUp = Vector3.new(0,-.707,.707)
		soundPath = "Gear.BearSqueak"
	end

	SoundUtils.playSound(handle, soundPath)
	
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