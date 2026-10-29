if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")

local platformRadius = Config.PLATFORM_RADIUS
local platformDiameter = platformRadius * 2
local platform

toolRemote.OnServerEvent:Connect(function(plr, clickCFrame, clickTarget, clickSurface)
	if not tool:IsDescendantOf(plr.Character) then
		return
	end
	
	if platform then
		platform:Destroy()
		platform = nil
		handle.Transparency = 0
		SoundUtils.playSound(handle, "Gear.PlatformReturn")
		GearUtils.toolAnim(tool, "Slash")
	else
		local clickPos = clickCFrame.Position
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local clickDistance = root and (root.Position - clickPos).Magnitude
		local withinReach = clickDistance and (clickDistance <= Config.PLATFORM_PLACEMENT_DISTANCE)
		
		if withinReach and BrickUtils.isGearAttachable(clickTarget) then
			platform = Instance.new("Part")
			platform.Name = "WoodenPlatform"
			platform.Shape = Enum.PartType.Cylinder
			platform.BrickColor = BrickColor.new("CGA brown")
			platform.Material = Enum.Material.Wood
			platform.Size = Vector3.new(0.5, platformDiameter, platformDiameter)
			platform.CFrame = CFrame.new(clickPos) * CFrame.Angles(0, 0, math.rad(90))
			platform:SetAttribute("IsGearAttachable", true)
			platform.Parent = toolDebrisBin
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = clickTarget
			weld.Part1 = platform
			weld.Parent = platform
			
			GearUtils.toolAnim(tool, "Slash")
			SoundUtils.playSound(handle, "Gear.PlatformPlace")
			handle.Transparency = 1
		end
	end
end)