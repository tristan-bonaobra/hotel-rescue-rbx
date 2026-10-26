----------------------------------------------------------------------------------------------
-- DEBRIS FUNCTIONS
----------------------------------------------------------------------------------------------

local function tempUnanchor(part)
    return true
end

local function breakPart(part, breakParams)
    return true
end

----------------------------------------------------------------------------------------------
-- OTHER FUNCTIONS
----------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------
-- RETURN MODULE
----------------------------------------------------------------------------------------------

return {
    tempUnanchor = tempUnanchor,
    breakPart = breakPart,
    getTopPosition = getTopPosition,
}