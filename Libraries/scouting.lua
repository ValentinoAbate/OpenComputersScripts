scouting = {}

local navigation = require("navigation")
local mapping = require("mapping")
local robot = require("robot")
-- Scouting protocol names
local scoutingProtocolNone = "None"
local scoutingProtocolFull = "Full"
local scoutingProtocolPowerSaving = "PowerSave"
local scoutingProtocol = scoutingProtocolNone
-- Block type names
local blockTypeAir = "air"
local blockTypeLiquid = "liquid"
local blockTypeSolid = "solid"
local blockTypePassable = "passable"
local blockTypeEntity = "entity"
-- Special Block names
local blockNameAir = "Air"
local inventoryPath = "inventory.txt"

local inventory = {}

local function loadInventory()
    local invFile = io.open(inventoryPath,"r")
    if not (invFile == nil) then
        inventory = ser.deserialize(invFile:read("*line"))
    end
    invFile:close()
end

local function setScoutingProtocol(protocolName)
    scoutingProtocol = protocolName
end

local function ProcessData(position, blockType, compareFunction)
    if blockType == blockTypeEntity then
        return
    elseif blockType == blockTypeAir then
        mapping.logData(position, blockNameAir, blockType, nil)
    elseif blockType == blockTypeSolid or blockType == blockTypePassable then
        local succeeded = false
        for k, v in pairs(inventory) do
            robot.select(k)
            if compareFunction() then
                succeeded = true
                mapping.logData(position, v, blockType, nil)
                break
            end
        end
        if not succeeded then
            mapping.logData(position, mapping.unknown, blockType, inventory)
        end
    elseif blockType == blockTypeLiquid then
        mapping.logData(position, mapping.unknown, blockType, nil)
    end
end

local function scout(position)
    if scoutingProtocol == scoutingProtocolNone then
        return
    end
    -- Assume protocol is powersaving or full, scout forward, up, and down
    local blocked, blockType = robot.detect()
    processData(position, blockType, robot.compare)
    blocked, blockType = robot.detectDown()
    processData(position, blockType, robot.compareDown)
    blocked, blockType = robot.detectUp()
    processData(position, blockType, robot.compareUp)
    -- Scout all the way around self
    if scoutingProtocol == scoutingProtocolFull then
        navigation.turnRight();
        for i = 1,3 do
            blocked, blockType = robot.detect()
            processData(position, blockType, robot.compare)
            navigation.turnRight();
        end
    end
end

scouting.loadInventory = loadInventory
scouting.setScoutingProtocol = setScoutingProtocol
scouting.scout = scout
scouting.scoutingProtocolNone = scoutingProtocolNone
scouting.scoutingProtocolFull = scoutingProtocolFull
scouting.scoutingProtocolPowerSaving = scoutingProtocolPowerSaving

return scouting