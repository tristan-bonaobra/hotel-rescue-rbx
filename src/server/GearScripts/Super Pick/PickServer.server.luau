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
		
		local anim = Instance.new("StringValue")
		anim.Name = "toolanim"
		anim.Value = "Slash"
		anim.Parent = tool
		game.Debris:AddItem(anim, 1)
		
		local withinReach = (root.Position - clickCFrame.Position).Magnitude <= Config.PICK_DISTANCE
		
		if withinReach and isPickable(clickTarget) then
			local breakParams = {
				Threshold = Config.BREAK_THRESHOLD_MANUAL,
				IsRecursive = false,
				Unanchor = true,
				Tint = true
			}
			BrickUtils.breakPart(clickTarget, breakParams)
			SoundUtils.playSound(handle, "Gear.PickBreak")
		else
			SoundUtils.playSound(handle, "Gear.PickMiss")
		end

		task.wait(Config.PICK_COOLDOWN)
		isActive = false
	end
end)