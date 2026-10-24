if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local toolDebrisFolder = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")

local platformRadius = Config.PLATFORM_RADIUS
local platformDiameter = platformRadius * 2
local platform

local function playAnim()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	game.Debris:AddItem(anim, 1)
end

local function verifyPlatformAttachable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	local Playground = workspace:FindFirstChild("Playground")
	local teleporter = workspace:FindFirstChild("Teleporter")
	return part
		and part:IsA("BasePart")
		and (teleporter and (not part:IsDescendantOf(teleporter)))
		and (
			part.Anchored
			or (currentMap and part:IsDescendantOf(currentMap))
			or (Playground and part:IsDescendantOf(Playground))
			or (part:GetAttribute("IsGearAttachable"))
		)
end

toolRemote.OnServerEvent:Connect(function(plr, clickCFrame, clickTarget, clickSurface)
	if not tool:IsDescendantOf(plr.Character) then
		return
	end
	
	if platform then
		platform:Destroy()
		platform = nil
		handle.Transparency = 0
		handle:WaitForChild("ReturnSound"):Play()
		playAnim()
	else
		local clickPos = clickCFrame.Position
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local clickDistance = root and (root.Position - clickPos).Magnitude
		local withinReach = clickDistance and (clickDistance <= Config.PLATFORM_PLACEMENT_DISTANCE)
		
		if withinReach and verifyPlatformAttachable(clickTarget) then
			platform = Instance.new("Part")
			platform.Name = "WoodenPlatform"
			platform.Shape = Enum.PartType.Cylinder
			platform.BrickColor = BrickColor.new("CGA brown")
			platform.Material = Enum.Material.Wood
			platform.Size = Vector3.new(0.5, platformDiameter, platformDiameter)
			platform.CFrame = CFrame.new(clickPos) * CFrame.Angles(0, 0, math.rad(90))
			platform:SetAttribute("IsGearAttachable", true)
			platform.Parent = toolDebrisFolder
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = clickTarget
			weld.Part1 = platform
			weld.Parent = platform
			
			playAnim()
			handle:WaitForChild("PlaceSound"):Play()
			handle.Transparency = 1
		end
	end
end)