local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local HotelRescue = ServerScriptService:WaitForChild("HotelRescue")
local Config = require(HotelRescue.Config)
local Summons = ServerStorage:WaitForChild("Summons")
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
	
	handle.Rustle:Play()
	
	if dog then
		dog:Destroy()
		dog = nil
		handle.Whistle:Play()
	else
		local char = tool.Parent
		dog = Summons:WaitForChild("Dog"):Clone()
		dog.Torso.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		dog.Parent = toolDebrisFolder
		script.DogScript:Clone().Parent = dog	
		dog:WaitForChild("Head"):WaitForChild("Bark"):Play()
	end
	
	task.wait(Config.TREATS_COOLDOWN)
	isActive = false
end)