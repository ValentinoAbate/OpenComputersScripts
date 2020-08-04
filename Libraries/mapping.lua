mapping = {}

local vec3 = require("vector3")
local ser = require("serialization")
local mapFileName = ("mapData.txt")
local mapData = {}
local unknown = "Unknown"

local function loadMapData()
    -- Read existing mapData if it exists
    local mapFile = io.open(mapFileName,"r")
    if not (mapFile == nil) then
        mapData = ser.deserialize(mapFile:read("*line"))
    end
    mapFile:close()
end

local function saveMapData()
    -- Write current mapData to the file
    local mapFile = io.open(mapFileName,"w")
    file:write(ser.serialize(mapData))
    file:close()
end

local function setData(posVec3, blockData)
    if mapData[posVec3.x] == nil then
        mapData[posVec3.x] = {}
        mapData[posVec3.x][posVec3.y] = {}
        mapData[posVec3.x][posVec3.y][posVec3.z] = blockData
    elseif mapData[posVec3.x][posVec3.y] then
        mapData[posVec3.x][posVec3.y] = {}
        mapData[posVec3.x][posVec3.y][posVec3.z] = blockData
    else
        mapData[posVec3.x][posVec3.y][posVec3.z] = blockData
    end
end

local function getData(posVec3, blockData)
    if (mapData[posVec3.x] == nil) or (mapData[posVec3.x][posVec3.y] == nil) then
        return nil
    end
    return mapData[posVec3.x][posVec3.y][posVec3.z]
end

local function logData(posVec3, blockName, blockType, cantBe)
    local data = {}
    data.blockName = blockName
    data.blockType = blockType
    if blockName == unknown then
        data.cantBe = cantBe
    else
        data.cantBe = {}
    end
    data.timestamp = {os.day(), os.time()}
    setData(posVec3, data)
end

mapping.loadMapData = loadMapData
mapping.saveMapData = saveMapData
mapping.setData = setData
mapping.getData = getData
mapping.logData = logData
mapping.unknown = unknown

return mapping