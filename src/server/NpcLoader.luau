

-- Move this to BrickUtils
local function getSpaceAbovePartForNpc(part)
	local footPos = getTopPosition(part)
	local boxSize = Vector3.new(2, 5, 1)
	local boxCFrame = CFrame.new(footPos) * CFrame.new(0, (boxSize.Y / 2) + 0.1, 0)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {part}

	local obstacles = workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)
	return #obstacles == 0, footPos
end

return {
	getSpaceAbovePartForNpc = getSpaceAbovePartForNpc
}