local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")
local isActive

local function verifyPickable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	local Playground = workspace:FindFirstChild("Playground")
	return part
		and part:IsA("BasePart")
		and (
			(currentMap and part:IsDescendantOf(currentMap))
			or (Playground and part:IsDescendantOf(Playground))
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
		
		if withinReach and verifyPickable(clickTarget) then
			local breakParams = {
				Threshold = Config.BREAK_THRESHOLD_MANUAL,
				IsRecursive = false,
				Unanchor = true,
				Tint = true
			}
			BrickUtils.breakPart(clickTarget, breakParams)
			handle.Break:Play()
		else
			handle.Miss:Play()
		end

		task.wait(Config.PICK_COOLDOWN)
		isActive = false
	end
end)