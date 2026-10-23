local Config = require(game:GetService("ServerScriptService").HotelRescue.Config)

local function tempUnanchor(part: Instance)
	if not part:IsA("BasePart") then
		return
	end
	part.Anchored = false
	part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.8, 0, 100, 100)
	task.spawn(function()
		repeat
			task.wait(2)
		until part:IsDescendantOf(workspace)
			and (not part:FindFirstChildOfClass("Attachment"))
			and (part.AssemblyLinearVelocity.Magnitude + part.AssemblyAngularVelocity.Magnitude) <= Config.DEBRIS_ANCHOR_THRESHOLD
		part.Anchored = true
		part.CustomPhysicalProperties = nil
		part.AssemblyLinearVelocity = Vector3.new()
		part.AssemblyAngularVelocity = Vector3.new()
	end)
end

local function breakJoints(part: Instance)
	for _, joint in part:GetJoints() do
		joint:Destroy()
	end
end

local function randTint(part)
	local h, s, v = part.Color:ToHSV()
	local a = 1000
	if math.random(2) == 1 then
		s += math.random(a * Config.DEBRIS_TINT) / a
		v += math.random(a * Config.DEBRIS_TINT) / a
	else
		s-= math.random(a * Config.DEBRIS_TINT) / a
		v -= math.random(a * Config.DEBRIS_TINT) / a
	end
	s = math.clamp(s, 0, 1)
	v = math.clamp(v, 0, 1)
	part.Color = Color3.fromHSV(h, s, v)
end

return {
	tempUnanchor = tempUnanchor,
	breakJoints = breakJoints,
	randTint = randTint
}