local function getTopPosition(part)
	local cf = part.CFrame
	local size = part.Size
	local faces = {
		{normal = cf.UpVector, offset = Vector3.new(0, size.Y / 2, 0)},
		{normal = -cf.UpVector, offset = Vector3.new(0, -size.Y / 2, 0)},
		{normal = cf.RightVector, offset = Vector3.new(size.X / 2, 0, 0)},
		{normal = -cf.RightVector, offset = Vector3.new(-size.X / 2, 0, 0)},
		{normal = cf.LookVector, offset = Vector3.new(0, 0, -size.Z / 2)},
		{normal = -cf.LookVector, offset = Vector3.new(0, 0, size.Z / 2)},
	}

	local bestFace = faces[1]
	local maxUpDot = bestFace.normal.Y
	for i = 2, #faces do
		local upDot = faces[i].normal.Y
		if upDot > maxUpDot then
			maxUpDot = upDot
			bestFace = faces[i]
		end
	end

	return cf:PointToWorldSpace(bestFace.offset)
end

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