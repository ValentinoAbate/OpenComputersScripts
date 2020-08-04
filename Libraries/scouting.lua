scouting = {}

local mapping = require("mapping")
local robot = require("robot")
local vec3 = require("vector3")
local serialization = require("serialization")
-- Scouting protocol names
local scoutingProtocolNone = "None"
local scoutingProtocolFull = "Full"
local scoutingProtocolPowerSaving = "PowerSave"
local scoutingProtocol = scoutingProtocolFull
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
        inventory = serialization.unserialize(invFile:read("*line"))
        invFile:close()
    end
end

local function setScoutingProtocol(protocolName)
    scoutingProtocol = protocolName
end

local function processData(position, blockType, compareFunction)
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

local function scout(posFn, dirFn, turnFn)
    local pos = posFn() 
    -- Where we are is considered air
    mapping.logData(pos, blockNameAir, blockTypeAir, nil)
    if scoutingProtocol == scoutingProtocolNone then
        return
    end
    -- Assume protocol is powersaving or full, scout forward, up, and down
    local blocked, blockType = robot.detect()
    processData(vec3.add(pos, dirFn()), blockType, robot.compare)
    blocked, blockType = robot.detectDown()
    processData(vec3.add(pos, vec3.down()), blockType, robot.compareDown)
    blocked, blockType = robot.detectUp()
    processData(vec3.add(pos, vec3.up()), blockType, robot.compareUp)
    -- Scout all the way around self
    if scoutingProtocol == scoutingProtocolFull then
        turnFn();
        for i = 1,3 do
            blocked, blockType = robot.detect()
            processData(vec3.add(pos, dirFn()), blockType, robot.compare)
            turnFn();
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