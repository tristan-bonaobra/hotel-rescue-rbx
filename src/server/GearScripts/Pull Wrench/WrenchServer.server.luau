if not script.Parent:IsA("Tool") then
	return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))

local playgroundLib = workspace:WaitForChild("Playground")
local npcsLib = workspace:WaitForChild("Npcs")

local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")

local isActive
local rope, attachment0, attachment1
local attachedPart
local attConn

local function isPullable(part)
	local currentMap = workspace:FindFirstChild("CurrentMap")
	return part
		and part:IsA("BasePart")
		and (
			part.Anchored
			or (currentMap and part:IsDescendantOf(currentMap))
			or part:IsDescendantOf(playgroundLib)
			or part:IsDescendantOf(npcsLib)
			or part:GetAttribute("IsGearAttachable")
		)
end

local function unattachAndDeactivate()
	isActive = false

	game.Debris:AddItem(attachment0, 0)
	game.Debris:AddItem(attachment1, 0)
	game.Debris:AddItem(rope, 0)

	if BrickUtils.isTempUnanchorable(attachedPart) then -- Just in case
		BrickUtils.tempUnanchor(attachedPart)
	end

	attachedPart = nil

	if attConn then
		attConn:Disconnect()
	end

	GearUtils.playToolAnim(tool, "Slash")
end

local function reelPlayerAndPart(part, playerTargetPos)
	local char = tool.Parent
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	
	if (not root) then
		return
	end
	
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	
	local rootPos = root.Position
	
	if rootPos then
		local playerImpulseDirection = CFrame.new(rootPos, playerTargetPos).LookVector
		local playerImpulse = playerImpulseDirection * Config.ROPE_IMPULSE_PLAYER
		root.AssemblyLinearVelocity += playerImpulse -- ApplyImpulse does not work
	end
	
	local partImpulseDirection = CFrame.new(part.Position, rootPos).LookVector
	local partImpulse = partImpulseDirection * Config.ROPE_IMPULSE_PART
	part:ApplyImpulse(partImpulse) -- ApplyImpulse is mandatory so we dont make trampolines
end

toolRemote.OnServerEvent:Connect(function(plr, clickCFrame, clickTarget)
	if not tool:IsDescendantOf(plr.Character) then
		return
	end
	
	if isActive then
		local oldAttachedPart = attachedPart
		unattachAndDeactivate()
		task.wait()
		reelPlayerAndPart(oldAttachedPart, attachment1.WorldPosition)
	else
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local withinReach = (root.Position - clickCFrame.Position).Magnitude <= Config.ROPE_LENGTH
		
		if withinReach and isPullable(clickTarget) then
			GearUtils.playToolAnim(tool, "Slash")
			SoundUtils.playSound(tool:WaitForChild("Handle"), "Gear.WrenchBass")
			
			attachedPart = clickTarget
			attachment0 = Instance.new("Attachment")
			attachment1 = Instance.new("Attachment")
			
			local relativeCFrame = clickTarget.CFrame:ToObjectSpace(clickCFrame)
			attachment1.CFrame = relativeCFrame
			attachment1.Parent = attachedPart
			attachment0.Parent = root
			
			rope = Instance.new("SpringConstraint")
			rope.Visible = true
			rope.Thickness = 0.25
			rope.Radius = 0.1
			rope.Color = BrickColor.new("Dark orange")
			rope.MinLength = Config.ROPE_LENGTH / 2
			rope.MaxLength = Config.ROPE_LENGTH
			rope.Stiffness = Config.ROPE_STIFFNESS
			rope.Damping = Config.ROPE_DAMPING
			rope.Attachment0 = attachment0
			rope.Attachment1 = attachment1
			rope.Parent = root
			
			if isPullable(clickTarget) and BrickUtils.isTempUnanchorable(clickTarget) then
				attachedPart.Anchored = false
			end
			
			local npc
			local npcFolder = workspace:WaitForChild("Npcs")
			for _, v in npcFolder:GetChildren() do
				if attachedPart:IsDescendantOf(v) then
					npc = v
					break
				end
			end
			if npc and npc:FindFirstChildOfClass("Humanoid") then
				attConn = npc.AttributeChanged:Connect(function()
					if npc:GetAttribute("IsRescued") then
						unattachAndDeactivate()
					end
				end)
			end
			
			isActive = true
		end
	end
end)