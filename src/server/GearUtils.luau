local Players = game:GetService("Players")

local function toolAnim(tool, animName)
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = animName
	anim.Parent = tool
	
	game.Debris:AddItem(anim, 1)
end

local function getOwner(tool)
	local parent = tool.Parent

    if not parent then 
        return nil
    elseif parent:IsA("Backpack") then
        return parent.Parent
	elseif parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
        return Players:GetPlayerFromCharacter(parent)
	else
		return nil
    end
end

return {
    toolAnim = toolAnim,
	getOwner = getOwner,
}