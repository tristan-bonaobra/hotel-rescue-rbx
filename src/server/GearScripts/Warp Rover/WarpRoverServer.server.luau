if not script.Parent:IsA("Tool") then
	return
end

-------------------------------------------------------------------------------------------
-- DEPENDENCIES AND VARIABLES
-------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local summonsLib = ServerStorage:WaitForChild("Summons")
local entityScriptsLib = ServerScriptService:WaitForChild("EntityScripts")

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local isActive
local car

-------------------------------------------------------------------------------------------
-- SCRIPT
-------------------------------------------------------------------------------------------

local function slowDestroy(instance)
	for _, v in pairs(instance:GetChildren()) do
		if v:IsA("BasePart") then
			v:Destroy()
		end
	end

	task.wait(0.1)

	if instance:IsDescendantOf(workspace) then
		instance:Destroy()
	end
end

tool.Activated:Connect(function()
	if isActive then
		return
	end
	
	isActive = true
	
	GearUtils.toolAnim(tool, "Slash")
	
	if car and car.Parent then
		slowDestroy(car)
		car = nil
	else
		local char = tool.Parent
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

		car = summonsLib:WaitForChild("Car"):Clone()
		car:PivotTo(root.CFrame * CFrame.new(0, 1, 0))
		car.Parent = toolDebrisBin

		entityScriptsLib:WaitForChild("CarScript"):Clone().Parent = car

		task.wait(0.1)

		car:WaitForChild("VehicleSeat"):Sit(hum)
	end
	
	task.wait(Config.CAR_SUMMON_COOLDOWN)
	isActive = false
end)