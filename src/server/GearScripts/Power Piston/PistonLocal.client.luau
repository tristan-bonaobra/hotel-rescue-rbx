local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local tool = script.Parent
local toolRemote = tool:WaitForChild("ToolRemote")

mouse.Button1Down:Connect(function()
	local clickCFrame = mouse.Hit
	local clickTarget = mouse.Target
	local clickSurface = mouse.TargetSurface
	toolRemote:FireServer(clickCFrame, clickTarget, clickSurface)
end)