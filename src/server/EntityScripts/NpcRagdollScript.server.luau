local char = script.Parent
local hum = char and char:FindFirstChildOfClass("Humanoid")

if not hum then
	return
end

char:SetAttribute("IsUnconscious", true)

local head = char and char:WaitForChild("Head")
local torso = char and char:WaitForChild("Torso")

local ServerStorage = game:GetService("ServerStorage")
local npcAssetsFolder = ServerStorage:WaitForChild("NpcAssets")
local classicFacesFolder = npcAssetsFolder:WaitForChild("ClassicFaces")
local sleepingFaces = classicFacesFolder:WaitForChild("Asleep"):GetChildren()
local newFace = sleepingFaces[math.random(#sleepingFaces)]:Clone()
local oldFace = head:FindFirstChildOfClass("Decal")

if oldFace then
	oldFace.Name = "OriginalFace"
	oldFace.Transparency = 1
end

newFace.Parent = head

local deathSound = script.BlocklandDeath:Clone()
deathSound.Parent = head
deathSound:Play()

do
	local pos = torso.Position
	char:PivotTo(CFrame.new(pos) * CFrame.Angles(math.rad(90), 0 , 0))
end

hum.RequiresNeck = false
hum.AutoRotate = false
hum:ChangeState(Enum.HumanoidStateType.Physics)

for _, motor in ipairs(char:GetDescendants()) do
	if motor:IsA("Motor6D") then
		local part0 = motor.Part0
		local part1 = motor.Part1

		if part0 and part1 then
			if motor.Name == "RootJoint" then
				motor.Enabled = false
				continue
			end

			local att0 = Instance.new("Attachment")
			att0.Name = "RagdollAttachment0"
			att0.CFrame = motor.C0
			att0.Parent = part0

			local att1 = Instance.new("Attachment")
			att1.Name = "RagdollAttachment1"
			att1.CFrame = motor.C1
			att1.Parent = part1

			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "RagdollSocket"
			socket.Attachment0 = att0
			socket.Attachment1 = att1
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			socket.UpperAngle = 60
			socket.TwistLowerAngle = -45
			socket.TwistUpperAngle = 45
			socket.Parent = part0

			local noCollision = Instance.new("NoCollisionConstraint")
			noCollision.Name = "RagdollNoCollision"
			noCollision.Part0 = part0
			noCollision.Part1 = part1
			noCollision.Parent = part0

			motor.Enabled = false
		end
	end
end

game:GetService("RunService").Heartbeat:Connect(function()
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
end)