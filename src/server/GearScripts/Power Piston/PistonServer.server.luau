if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local toolDebrisFolder = workspace:WaitForChild("ToolDebris")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")
local handle = tool:WaitForChild("Handle")

local isActive
local pistonModel

local function playAnim()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	game.Debris:AddItem(anim, 1)
end

toolRemote.OnServerEvent:Connect(function(plr, clickCFrame, clickTarget, clickSurface)
	if not tool:IsDescendantOf(plr.Character) then
		return
	end
	
	if isActive then
		isActive = false
		playAnim()
		SoundUtils.playSound(handle, "Gear.PistonUnsummon")
		pistonModel:Destroy()
		pistonModel = nil
		
	else
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local withinReach = root and (root.Position - clickCFrame.Position).Magnitude <= Config.PISTON_PLACEMENT_DISTANCE
		
		if withinReach and BrickUtils.isGearAttachable(clickTarget) then
			isActive = true
			
			playAnim()
			
			local hitPosition = clickCFrame.Position
			local localNormal = Vector3.fromNormalId(clickSurface)
			local hitNormal = clickTarget.CFrame:VectorToWorldSpace(localNormal)
			local surfaceCFrame = CFrame.lookAt(hitPosition, hitPosition + hitNormal) * CFrame.Angles(math.rad(-90), 0, 0)
			
			pistonModel = Instance.new("Model")
			pistonModel.Name = "Piston"
			pistonModel.Parent = toolDebrisFolder
			
			local base = Instance.new("Part")
			base.Name = "Base"
			base.Size = Vector3.new(3, 0.5, 3)
			base.BrickColor = BrickColor.new("Black")
			base.CFrame = surfaceCFrame * CFrame.new(0, base.Size.Y / 2, 0)
			base:SetAttribute("IsGearAttachable", true)
			base.Parent = pistonModel
			
			for _, v in script.BaseScripts:GetChildren() do
				v:Clone().Parent = base
			end
			
			local baseWeld = Instance.new("WeldConstraint")
			baseWeld.Name = "BaseWeld"
			baseWeld.Part0 = clickTarget
			baseWeld.Part1 = base
			baseWeld.Parent = base
			
			local face = Instance.new("Part")
			face.Name = "PistonFace"
			face.Size = Vector3.new(Config.PISTON_WIDTH, 0.5, Config.PISTON_WIDTH)
			face.BrickColor = BrickColor.new("Bright red")
			face.CFrame = base.CFrame * CFrame.new(0, (base.Size.Y / 4) + (face.Size.Y / 4), 0)
			face:SetAttribute("IsGearAttachable", true)
			face.Parent = pistonModel
			
			local attachment0 = Instance.new("Attachment")
			local attachment1 = Instance.new("Attachment")
			attachment0.Orientation = Vector3.new(0, 0, 90)
			attachment1.Orientation = Vector3.new(0, 0, 90)
			attachment0.Parent = base
			attachment1.Parent = face
			
			local collisionConstraint = Instance.new("NoCollisionConstraint")
			collisionConstraint.Part0 = base
			collisionConstraint.Part1 = face
			collisionConstraint.Parent = base
			
			local pConstraint = Instance.new("PrismaticConstraint")
			pConstraint.Attachment0 = attachment0
			pConstraint.Attachment1 = attachment1
			pConstraint.ActuatorType = Enum.ActuatorType.Servo
			pConstraint.Speed = Config.PISTON_SPEED
			pConstraint.ServoMaxForce = math.huge
			pConstraint.LinearResponsiveness = Config.PISTON_RESPONSIVENESS
			pConstraint.TargetPosition = Config.PISTON_HEIGHT
			pConstraint.Parent = base
			
			local spring = Instance.new("SpringConstraint")
			spring.Attachment0 = attachment0
			spring.Attachment1 = attachment1
			spring.Stiffness = 0
			spring.Damping = 0
			spring.Visible = true
			spring.Color = BrickColor.new("Medium stone grey")
			spring.Radius = base.Size.X / 2
			spring.Thickness *= 2
			spring.Coils = Config.PISTON_HEIGHT
			spring.Parent = base
			
			local smoke = Instance.new("Smoke")
			smoke.Size = 0.05
			smoke.Opacity = 0.5
			smoke.Enabled = false
			smoke.Parent = base
		end
	end
end)

while true do
	local face = pistonModel and pistonModel:FindFirstChild("PistonFace")
	if face then
		local boxSize = Vector3.new(face.Size.X, Config.PISTON_HITBOX_LENGTH, face.Size.Z)
		local boxCFrame = face.CFrame * CFrame.new(0, (boxSize.Y / 2) + (face.Size.Y / 2), 0)
		local partsInBox = workspace:GetPartBoundsInBox(boxCFrame, boxSize)
		
		for _, part in ipairs(partsInBox) do
			if BrickUtils.isTempUnanchorable(part) then
				BrickUtils.tempUnanchor(part)
			end
		end
	end
	task.wait(1)
end