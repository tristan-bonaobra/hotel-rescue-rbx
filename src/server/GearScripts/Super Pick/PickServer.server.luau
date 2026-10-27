if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local playgroundBin = workspace:WaitForChild("Playground")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")
local isActive

local function isPickable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	return part
		and part:IsA("BasePart")
		and (
			(currentMap and part:IsDescendantOf(currentMap))
			or (playgroundBin and part:IsDescendantOf(playgroundBin))
		)
end

local function playAnim()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	game.Debris:AddItem(anim, 1)
end

local function destroyPart(part)
	BrickUtils.breakJoints(part)
	part.Anchored = false
	part.CanCollide = false
	part.Transparency = 0.5
	part.BrickColor = BrickColor.new("Brick yellow")
	part.Material = Enum.Material.Slate
	SoundUtils.playSound(handle, "Gear.PickCrush")
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
	SoundUtils.playSound(handle, "Gear.PickBreak")
	if BrickUtils.isTiny(part) then
		destroyPart(part)
	else
		breakPart(part)
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
		playAnim()
		
		local withinReach = (root.Position - clickCFrame.Position).Magnitude <= Config.PICK_DISTANCE
		if withinReach and isPickable(clickTarget) then
			pickInteract(clickTarget)
		else
			SoundUtils.playSound(handle, "Gear.PickMiss")
		end

		task.wait(Config.PICK_COOLDOWN)
		isActive = false
	end
end)