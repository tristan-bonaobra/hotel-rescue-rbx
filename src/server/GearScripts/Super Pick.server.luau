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
local handle = tool:WaitForChild("Handle")
local isActive

local function isPickable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	return part
		and part:IsA("BasePart")
		and BrickUtils.isBreakable(part)
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

local function pickInteract(part)
	if isPickable(part) then
		SoundUtils.playSound(handle, "Gear.PickBreak", false, Config.PICK_PITCH_SHIFT)

		if BrickUtils.isTiny(part) then
			destroyPart(part)
			SoundUtils.playSound(handle, "Gear.PickCrush", false, Config.PICK_PITCH_SHIFT)
		else
			breakPart(part)
		end

	elseif BrickUtils.isTempUnanchorable(part) then
		BrickUtils.breakJoints(part)
		BrickUtils.tempUnanchor(part)
		SoundUtils.playSound(handle, "Gear.PickBreak", false, Config.PICK_PITCH_SHIFT)

	else
		SoundUtils.playSound(handle, "Gear.PickMiss")
	end
end

local clientClicked = GearUtils.initClientClick(tool)

clientClicked:Connect(function(plr, clickCFrame, clickTarget)
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
		
		if withinReach then
			pickInteract(clickTarget)
		else
			SoundUtils.playSound(handle, "Gear.PickMiss")
		end

		task.wait(Config.PICK_COOLDOWN)

		isActive = false
	end
end)