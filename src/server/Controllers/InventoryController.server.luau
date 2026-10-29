local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local SoundUtils = require(ServerScriptService:WaitForChild("SoundUtils"))

local playerSpawnFolder = workspace:WaitForChild("PlayerSpawn")
local shopFolder = playerSpawnFolder:WaitForChild("Shop")
local giversFolder = shopFolder:WaitForChild("Givers")

local gearLib = ServerStorage:WaitForChild("Gear")

local playerInventories = {}

---------------------------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------------------------

local function standardizeItems()
	for _, item in gearLib:GetChildren() do
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
	local item = gearLib:FindFirstChild(giverModel.Name)
	local priceObject = item and item:FindFirstChild("Price")
	local price = priceObject and priceObject.Value
	local head = giverModel:FindFirstChild("Head")
	local decal = head and head:FindFirstChildOfClass("Decal")
	local originalBrickColor = head and head.BrickColor
	local isActive = false
	
	if (not item)
		or (not price)
		or (not head)
		or (not decal)
	then
		return
	end
	
	giverModel.Name = item.Name.. " - "..price.." points"
	decal.ColorMapContent = Content.fromUri(item.TextureId)
	
	head.Touched:Connect(function(hit)
		local char = hit.Parent
		local plr = Players:GetPlayerFromCharacter(char)
		local leaderstats = plr and plr:FindFirstChild("leaderstats")
		local pointsObject = leaderstats and leaderstats:FindFirstChild("Points")
		local currentPoints = pointsObject and pointsObject.Value
		local canAffordItem = currentPoints and (currentPoints >= price)
		local backpack = plr and plr.Backpack
		local hasItemInBackpack = backpack and backpack:FindFirstChild(item.Name)
		local hasItemInChar = char:FindFirstChild(item.Name)
		local hasItem = hasItemInBackpack or hasItemInChar
		
		if canAffordItem and (not isActive) and (not hasItem) then
			isActive = true
			head.BrickColor = BrickColor.new("Bright red")
			SoundUtils.playSound(head, "World.ShopBuy")
			pointsObject.Value -= price

			local newItem = item:Clone()
			newItem.Parent = plr.Backpack
			loadGearScripts(newItem)
			
			if playerInventories[plr] then
				table.insert(playerInventories[plr], item:Clone())
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

local function beginTrackingPlayer(plr)
	playerInventories[plr] = {}
	
	for _, item in gearLib:GetChildren() do
		local priceObject = item:FindFirstChild("Price")
		local price = priceObject and priceObject.Value
		local isFree = price == 0
		
		if isFree then
			table.insert(playerInventories[plr], item:Clone())
		end
	end
	
	grantPlayerItems(plr)

	local characterListener
	local leaverListener
	
	characterListener = plr.CharacterAdded:Connect(function()
		grantPlayerItems(plr)
	end)

	leaverListener = Players.PlayerRemoving:Connect(function(leaver)
		if leaver == plr then
			characterListener:Disconnect()
			leaverListener:Disconnect()
		end
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