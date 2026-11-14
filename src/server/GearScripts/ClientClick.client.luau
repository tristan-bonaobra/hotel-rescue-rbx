if not script.Parent:IsA("Tool") then
	return
end

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local tool = script.Parent
local remote = tool:WaitForChild("ClientClickRemote")

mouse.Button1Down:Connect(function()
	local clickCFrame = mouse.Hit
	local clickTarget = mouse.Target
	local clickSurface = mouse.TargetSurface
	
	remote:FireServer(clickCFrame, clickTarget, clickSurface)
end)