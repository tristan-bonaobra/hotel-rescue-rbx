local ServerStorage = game:GetService("ServerStorage")

local gearLib = ServerStorage:WaitForChild("Gear")

-- Validate at this level
local function getGear(name)
    return gearLib:WaitForChild(name)
end

return {
    {
        GearObject = getGear("Super Pick"),
        Price = 0,
    },
    {
        GearObject = getGear("Pull Wrench"),
        Price = 0,
    },
    {
        GearObject = getGear("Teddy Bear"),
        Price = 0,
    },
    {
        GearObject = getGear("Dog Treats"),
        Price = 10,
    },
    {
        GearObject = getGear("Power Bell"),
        Price = 30,
    },
    {
        GearObject = getGear("Power Piston"),
        Price = 30,
    },
    {
        GearObject = getGear("Wooden Platform"),
        Price = 30,
    },
    {
        GearObject = getGear("Rally Flag"),
        Price = 30,
    },
    {
        GearObject = getGear("Translocator"),
        Price = 30,
    },
    {
        GearObject = getGear("Gravity Coil"),
        Price = 90,
    },
}