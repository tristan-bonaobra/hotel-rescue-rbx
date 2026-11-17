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

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local isActive
local car

-------------------------------------------------------------------------------------------
-- SCRIPT
-------------------------------------------------------------------------------------------

tool.Activated:Connect(function()
	if isActive then
		return
	end
	
	isActive = true
	
	GearUtils.toolAnim(tool, "Slash")
	
	if car and car.Parent then
		car:Destroy()
		car = nil
		SoundUtils.playSound(handle, "Gear.CarBeep")
		
	else
		local char = tool.Parent
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

		car = summonsLib:WaitForChild("Car"):Clone()
		car:PivotTo(root.CFrame * CFrame.new(0, 1, 0))
		car.Parent = toolDebrisBin

		local body = car:FindFirstChild("Body")
		local vehicleSeat = car:FindFirstChild("VehicleSeat")

		if body then
			SoundUtils.playSound(body, "Gear.FlagDrop")
			SoundUtils.playSound(body, "Gear.CarEngine")
		end

		task.wait(0.1)

		if vehicleSeat then
			vehicleSeat:Sit(hum)
		end
	end
	
	task.wait(Config.CAR_SUMMON_COOLDOWN)
	isActive = false
end)