local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local BrickUtils = require(ServerScriptService:WaitForChild("BrickUtils"))

local toolDebrisBin = workspace:WaitForChild("ToolDebris")

--------------------------------------------------------------------------------------------
-- BASIC FUNCTIONS
--------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------------------

local function getChar(tool)
    if tool.Parent:IsA("Model") then
        return tool.Parent
    elseif tool.Parent:IsA("Backpack") then
        local backpack = tool.Parent
        local plr = backpack.Parent
        return plr.Character
    end
    return
end
--------------------------------------------------------------------------------------------
-- BIG FUNCTIONS
--------------------------------------------------------------------------------------------

local function placeMode(tool)
	local handle = tool:WaitForChild("Handle")
	local placedListener = Instance.new("BindableEvent")
	local retrievedListener = Instance.new("BindableEvent")

	local isActive
	local prop
	local weld

	local function awaitUnweld()
		if (not weld) or (not weld.Part0) then
			return
		end

		task.spawn(function()
			weld.Part0.AncestryChanged:Wait()
			if prop then
				prop.CanCollide = true
			end
		end)
	end

	local function placeProp(tool)
		prop = handle:Clone()
		prop:SetAttribute("IsGearAttachable", true)

		BrickUtils.breakJoints(prop)
		BrickUtils.stabilize(prop)

		handle.Transparency = 1
		toolAnim(tool, "Slash")

		local raycastResult = BrickUtils.raycast(
			handle.Position,
			handle.Position + Vector3.new(0, -10, 0),
			Enum.RaycastFilterType.Exclude,
			{getChar(tool)}
		)

		if raycastResult then
			local base = raycastResult.Instance
			local rayHit = raycastResult.Position

			prop.CFrame = CFrame.new(rayHit) * CFrame.new(-prop.Size.X / 2, prop.Size.Y / 2, 0)
			prop.CanCollide = false

			weld = Instance.new("WeldConstraint")
			weld.Part0 = base
			weld.Part1 = prop
			weld.Parent = prop
			awaitUnweld()
		else
			prop.CanCollide = true
		end

		prop.Parent = toolDebrisBin
	end

	local function retrieveProp(prop)
		handle.Transparency = 0
		
		if prop:IsDescendantOf(workspace) then
			prop:Destroy()
		end

		prop = nil
		weld = nil
	end

	tool.Activated:Connect(function()
		isActive = not isActive
		if isActive then
			placeProp(tool)
			placedListener:Fire(prop, weld)
		else
			retrieveProp(prop)
			retrievedListener:Fire()
		end
	end)

	return placedListener.Event, retrievedListener.Event
end

return {
    toolAnim = toolAnim,
	getOwner = getOwner,
	placeMode = placeMode,
}