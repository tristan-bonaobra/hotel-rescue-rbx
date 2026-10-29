if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local npcsBin = workspace:WaitForChild("Npcs")
local playgroundBin = workspace:WaitForChild("Playground")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local isActive

local function isBellable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	local npc
	
	if npcsBin and part:IsDescendantOf(npcsBin) then
		for _, v in npcsBin:GetChildren() do
			if part:IsDescendantOf(v) then
				npc = v
				break
			end
		end
	end
	
	return part
		and part:IsA("BasePart")
		and (
			(currentMap and part:IsDescendantOf(currentMap))
			or (npc and (not npc:GetAttribute("IsRescued")))
			or (playgroundBin and part:IsDescendantOf(playgroundBin))
		)
end

local function shockwaveFx()
	SoundUtils.playSound(handle, "Gear.BellBass")
	SoundUtils.playSound(handle, "Gear.BellQuake")
	
	local Effects = game.ServerStorage:FindFirstChild("Effects")

	if Effects then
		local shockwave = Effects:WaitForChild("BellShockwave"):Clone()
		shockwave.CFrame = CFrame.new(handle.Position)
		shockwave.Parent = workspace
		game.Debris:AddItem(shockwave, 0.5)
	end
end

local function shockwavePhysics()
	local affectedParts = workspace:GetPartBoundsInRadius(handle.Position, Config.BELL_RADIUS)
	local affectedRoots = {}

	for _, part in ipairs(affectedParts) do
		if isBellable(part) then
			if part.Anchored then
				BrickUtils.tempUnanchor(part)
			end

			if BrickUtils.isTiny(part) and (not part:IsDescendantOf(npcsBin)) then
				BrickUtils.breakJoints(part)
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
end

tool.Activated:Connect(function()
	if isActive then
		return
	end
	
	isActive = true
	playAnim()
	shockwaveFx()
	shockwavePhysics()
	task.wait(Config.BELL_COOLDOWN)
	isActive = false
end)