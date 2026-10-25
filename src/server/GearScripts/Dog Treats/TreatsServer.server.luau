if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local summonsFolder = ServerStorage:WaitForChild("Summons")
local toolDebrisFolder = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local isActive
local dog

tool.Activated:Connect(function()
	if isActive then
		return
	end
	
	isActive = true
	
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	game.Debris:AddItem(anim, 1)
	
	SoundUtils.playSound(handle, "Gear.TreatsRustle")
	
	if dog then
		dog:Destroy()
		dog = nil
		SoundUtils.playSound(handle, "Gear.TreatsWhistle")
	else
		local char = tool.Parent
		dog = summonsFolder:WaitForChild("Dog"):Clone()
		dog.Torso.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		dog.Parent = toolDebrisFolder
		script.DogScript:Clone().Parent = dog	
		SoundUtils.playSound(dog:WaitForChild("Head"), "Entity.DogBark")
	end
	
	task.wait(Config.TREATS_COOLDOWN)
	isActive = false
end)