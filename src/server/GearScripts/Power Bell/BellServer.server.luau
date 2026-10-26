if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local isActive

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

	SoundUtils.playSound(handle, "Gear.BellBass")
	SoundUtils.playSound(handle, "Gear.BellQuake")
	
	local Effects = game.ServerStorage:FindFirstChild("Effects")
	if Effects then
		local shockwave = Effects:WaitForChild("BellShockwave"):Clone()
		shockwave.CFrame = CFrame.new(handle.Position)
		shockwave.Parent = workspace
		game.Debris:AddItem(shockwave, 0.5)
	end
	
	local affectedParts = workspace:GetPartBoundsInRadius(handle.Position, Config.BELL_RADIUS)
	local affectedRoots = {}
	for _, part in ipairs(affectedParts) do
		if BrickUtils.isBellable(part) then
			if part.Anchored then
				BrickUtils.tempUnanchor(part)
			end
			
			local assemblyRoot = part.AssemblyRootPart or part
			if (not table.find(affectedRoots, assemblyRoot)) then
				table.insert(affectedRoots, assemblyRoot)
				local direction = CFrame.new(handle.Position, assemblyRoot.Position).LookVector
				local velocity = (direction * Config.BELL_FORCE) + Vector3.new(0, Config.BELL_JUMP, 0)
				assemblyRoot:ApplyImpulse(velocity * assemblyRoot:GetMass())
				
				part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.8, 0, 0, 0)
				task.spawn(function()
					task.wait(0.1)
					part.CustomPhysicalProperties = nil
				end)
			end
		end
	end
	
	task.wait(Config.BELL_COOLDOWN)
	isActive = false
end)