local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))
local GearData = require(ServerScriptService:WaitForChild("GearData"))

local playerSpawnFolder = workspace:WaitForChild("PlayerSpawn")
local shopFolder = playerSpawnFolder:WaitForChild("Shop")
local giversFolder = shopFolder:WaitForChild("Givers")

local playerInventories = {}

---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------------------------------

local function getGearData(name)
	for _, data in GearData do
		if data.GearObject.Name == name then
			return data
		end
	end
	return
end

---------------------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
---------------------------------------------------------------------------------------------------

local function standardizeItems()
	for _, data in GearData do
		local item = data.GearObject
		if item:IsA("Tool") then
			item.CanBeDropped = false
			item.ToolTip = item.Name
		end
	end
end

local function loadGearScripts(gear)
	local gearScriptsMainFolder = ServerScriptService:WaitForChild("GearScripts")
	local gearScriptsSubFolder = gearScriptsMainFolder:FindFirstChild(gear.Name)
	if gearScriptsSubFolder then
		for _, v in gearScriptsSubFolder:GetChildren() do
			v:Clone().Parent = gear
		end
	end
end

local function initGiver(giverModel)
	local data = getGearData(giverModel.Name)
	local head = giverModel:FindFirstChild("Head")
	local decal = head and head:FindFirstChildOfClass("Decal")
	
	if (not data)
		or (not head)
		or (not decal)
	then
		return
	end

	local price = data.Price
	local gearObject = data.GearObject

	local originalBrickColor = head and head.BrickColor
	local isActive = false
	
	giverModel.Name = gearObject.Name.. " - "..price.." points"
	decal.ColorMapContent = Content.fromUri(gearObject.TextureId)
	
	head.Touched:Connect(function(hit)
		local char = hit.Parent
		local plr = Players:GetPlayerFromCharacter(char)
		local leaderstats = plr and plr:FindFirstChild("leaderstats")
		local backpack = plr and plr.Backpack

		local pointsObject = leaderstats and leaderstats:FindFirstChild("Points")
		local currentPoints = pointsObject and pointsObject.Value
		local canAffordItem = currentPoints and (currentPoints >= price)

		local hasItemInBackpack = backpack and backpack:FindFirstChild(gearObject.Name)
		local hasItemInChar = char:FindFirstChild(gearObject.Name)
		local hasItem = hasItemInBackpack or hasItemInChar
		
		if canAffordItem and (not isActive) and (not hasItem) then
			isActive = true
			head.BrickColor = BrickColor.new("Bright red")
			SoundUtils.playSound(head, "World.ShopBuy")
			pointsObject.Value -= price

			local newItem = gearObject:Clone()
			newItem.Parent = plr.Backpack
			loadGearScripts(newItem)
			
			if playerInventories[plr] then
				table.insert(playerInventories[plr], gearObject:Clone())
			end
			
			task.wait(1)
			isActive = false
			head.BrickColor = originalBrickColor
		end
	end)
end

local function grantPlayerItems(plr)
	for _, ownedItem in playerInventories[plr] do
		local clonedItem = ownedItem:Clone()
		clonedItem.Parent = plr.Backpack
		loadGearScripts(clonedItem)
	end
end

local function grantFreeItems(plr)
	for _, data in GearData do
		if data.Price == 0 then
			table.insert(playerInventories[plr], data.GearObject:Clone())
		end
	end
end

local function beginTrackingPlayer(plr)
	playerInventories[plr] = {}
	
	grantFreeItems(plr)
	grantPlayerItems(plr)

	plr.CharacterAdded:Connect(function()
		grantPlayerItems(plr)
	end)
end

---------------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------------

standardizeItems()

for _, giverModel in giversFolder:GetChildren() do
	initGiver(giverModel)
end

for _, plr in Players:GetPlayers() do
	beginTrackingPlayer(plr)
end

Players.PlayerAdded:Connect(beginTrackingPlayer)