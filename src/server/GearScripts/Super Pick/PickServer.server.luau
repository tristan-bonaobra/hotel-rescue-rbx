if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local playgroundBin = workspace:WaitForChild("Playground")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")
local isActive

local function isPickable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	return part
		and part:IsA("BasePart")
		and (part.Shape == Enum.PartType.Block) or (part.Shape == Enum.PartType.Wedge)
		and (
			(currentMap and part:IsDescendantOf(currentMap))
			or (playgroundBin and part:IsDescendantOf(playgroundBin))
		)
end

local function destroyPart(part)
	BrickUtils.breakJoints(part)
	part.Anchored = false
	part.CanCollide = false
	part.Transparency = 0.5
	part.BrickColor = BrickColor.new("Brick yellow")
	part.Material = Enum.Material.Slate
	SoundUtils.playSound(handle, "Gear.PickCrush", false, Config.PICK_PITCH_SHIFT)
end

local function breakPart(part)
	local breakParams = {
		Threshold = Config.BREAK_THRESHOLD_MANUAL,
		IsRecursive = false,
		Unanchor = true,
		Tint = true
	}
	BrickUtils.breakPart(part, breakParams)
end

local function pickInteractWithDynamicCooldown(part)
	SoundUtils.playSound(handle, "Gear.PickBreak", false, Config.PICK_PITCH_SHIFT)
	if BrickUtils.isTiny(part) then
		destroyPart(part)
		task.wait(Config.PICK_COOLDOWN / 2)
	else
		breakPart(part)
		task.wait(Config.PICK_COOLDOWN)
	end
end

toolRemote.OnServerEvent:Connect(function(plr, clickCFrame, clickTarget)
	local char = plr.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	
	if isActive
		or (not root)
		or (not tool:IsDescendantOf(plr.Character))
	then
		return
	else
		isActive = true

		GearUtils.toolAnim(tool, "Slash")
		
		local withinReach = (root.Position - clickCFrame.Position).Magnitude <= Config.PICK_DISTANCE
		
		if withinReach and isPickable(clickTarget) then
			pickInteractWithDynamicCooldown(clickTarget)
		else
			SoundUtils.playSound(handle, "Gear.PickMiss")
			task.wait(Config.PICK_COOLDOWN)
		end

		isActive = false
	end
end)