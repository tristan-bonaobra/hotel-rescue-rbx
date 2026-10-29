local function playToolAnim(tool, animName)
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = animName
	anim.Parent = tool
	
	game.Debris:AddItem(anim, 1)
end

return {
    playToolAnim = playToolAnim,
}