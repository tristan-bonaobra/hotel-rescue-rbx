if not script.Parent:IsA("Model") then
	return
end

local SMOOTH_FACTOR = 15
local TARGET_THRESHOLD = 0.25
local STRAIN_THRESHOLD = 0.75
local STRAIN_PLAYBACK_SPEED = 0.9
local DEFAULT_PLAYBACK_SPEED = 0.7
local SOUND_RAMP = 1.5

local ServerScriptService = game:GetService("ServerScriptService")

local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local pistonModel = script.Parent
local base = pistonModel:WaitForChild("Base")
local smoke = base:WaitForChild("Smoke")
local constraint = base:WaitForChild("PrismaticConstraint")

local lastPosition = constraint.CurrentPosition
local smoothedVelocity = 0

local sound = SoundUtils.copySound("Gear.PistonHydraulic")
sound.Parent = base
sound.PlaybackSpeed = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	local currentPosition = constraint.CurrentPosition
	local rawVelocity = (currentPosition - lastPosition) / math.max(dt, 0.001)
	smoothedVelocity = smoothedVelocity + (rawVelocity - smoothedVelocity) * math.min(dt * SMOOTH_FACTOR, 1)

	local realSpeed = math.abs(smoothedVelocity)
	local expectedSpeed = math.max(math.abs(constraint.Speed), 0.001)
	local speedRatio = math.clamp(realSpeed / expectedSpeed, 0, 1)
	local strain = 1 - speedRatio
	
	local targetPlaybackSpeed
	if math.abs(currentPosition - constraint.TargetPosition) <= TARGET_THRESHOLD then
		targetPlaybackSpeed = 0
		smoke.Enabled = false
	elseif strain >= STRAIN_THRESHOLD then
		targetPlaybackSpeed = STRAIN_PLAYBACK_SPEED
		smoke.Enabled = true
	else
		targetPlaybackSpeed = DEFAULT_PLAYBACK_SPEED
		smoke.Enabled = false
	end
	local alpha = math.min(dt * SOUND_RAMP, 1)
	sound.PlaybackSpeed = sound.PlaybackSpeed + (targetPlaybackSpeed - sound.PlaybackSpeed) * alpha

	lastPosition = currentPosition
end)

sound:Play()