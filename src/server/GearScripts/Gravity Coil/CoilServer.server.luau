if not script.Parent:IsA("Tool") then
    return
end

local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))
local GearUtils = require(ServerScriptService:WaitForChild("GearUtils"))
local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local function setJumpPower(jumpPower)
    local plr = GearUtils.getOwner(tool)
    local char = plr and plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.JumpPower = jumpPower
    end
end

tool.Equipped:Connect(function()
    setJumpPower(Config.COIL_JUMP_POWER)
    SoundUtils.playSound(handle, "Gear.CoilEquip")
end)

tool.Unequipped:Connect(function()
    setJumpPower(Config.DEFAULT_JUMP_POWER)
end)