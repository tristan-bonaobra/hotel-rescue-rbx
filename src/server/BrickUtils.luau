-- you finna see a lotta code moved here

local function tempUnanchor(part)
    return true
end

local function breakPart(part, breakParams)
    return true
end

return {
    tempUnanchor = tempUnanchor,
    breakPart = breakPart
}