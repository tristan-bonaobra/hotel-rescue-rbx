local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("Config"))

local teleporterModel = workspace:WaitForChild("Teleporter")

local teleportPads = {
	teleporterModel:WaitForChild("SpawnSide"):WaitForChild("Head"),
	teleporterModel:WaitForChild("MapSide"):WaitForChild("Head")
}

for i, pad in teleportPads do
	pad.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if hum
			and (not char:GetAttribute("IsTeleporting"))
			and teleporterModel:GetAttribute("IsEnabled")
		then
			char:SetAttribute("IsTeleporting", true)
			
			local targetPad = teleportPads[3 - i]
			local targetCFrame = targetPad.CFrame * CFrame.new(0, 3, 0)
			char:PivotTo(targetCFrame)
			
			task.wait(Config.TELEPORT_COOLDOWN_PER_PLAYER)
			char:SetAttribute("IsTeleporting", false)
		end
	end)
end

local function updatePads()
	for _, pad in teleportPads do
		if teleporterModel:GetAttribute("IsEnabled") then
			pad.BrickColor = BrickColor.new("Plum")
            pad.Parent.Name = "Teleporter (Active)"
		else
			pad.BrickColor = BrickColor.new("Black")
            pad.Parent.Name = "Teleporter (Offline)"
		end
	end
end

teleporterModel.AttributeChanged:Connect(updatePads)
updatePads()