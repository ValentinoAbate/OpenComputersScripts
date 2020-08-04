navigation = {}
local robot = require("robot")
local serialization = require("serialization")
local vec3 = require("vector3")
local origin = vec3.zero()
local pos = vec3.clone(origin)
local directions = vec3.directions()
local facingInd = 1
local facing = vec3.north()
local pathInd = 1
local path = { vec3.clone(origin) }
local logFile = io.open("logFile.txt", "w")
local newLine = "\n";
local holeError = "Hole Safety Protocol Violation"
-- Hole abort level codes
local holeAbortNone = 0
local holeAbortStrict = 1
local holeAbortLoose = 2
local holeAbortLevel = holeAbortStrict

local function log(message)
    logFile:write(message .. newLine)
end

local function directionBetween(from, to)
    return vec3.subtract(to, from)
end

local function logCurrentPositionInPath()
    pathInd = pathInd + 1
    path[pathInd] = vec3.clone(pos)
    log((pathInd - 1) .. " moves away from home.")
end

local function turnRight()
    robot.turnRight()
    facingInd = facingInd + 1
    if facingInd == 5 then facingInd = 1 end
    facing = directions[facingInd]()
end

local function turnLeft()
    robot.turnLeft()
    facingInd = facingInd - 1
    if facingInd <= 0 then facingInd = 4 end
    facing = directions[facingInd]()
end

local function checkForSolids(exceptDirection)
    if(not (vec3.equals(vec3.down(), exceptDirection))) then
        blocked, blockType = robot.detectDown()
        if(blocked and (blockType == "solid")) then
            return true
        end
    end
    if(not (vec3.equals(vec3.up(), exceptDirection))) then
        blocked, blockType = robot.detectUp()
        if(blocked and (blockType == "solid")) then
            return true
        end
    end
    local ret = false
    for i = 1,4 do
        if(not (vec3.equals(facing, exceptDirection))) then
            blocked, blockType = robot.detect()
            if(blocked and (blockType == "solid")) then
                ret = true
            end
        end
        turnRight();
    end
    return ret
end

local function moveGeneric(moveFunction, direction, logPath)
    log("Attempting move in " .. serialization.serialize(direction) .. " direction...")
    local success, error = moveFunction()
    if(success == nil) then return false, error end
    pos = vec3.add(pos, direction)
    log("Move success! Position is now " .. serialization.serialize(pos) .. ".")
    if(logPath) then
        logCurrentPositionInPath()
    end
    return true
end

local function holeAbort(execptDirection)
    if (holeAbortLevel == holeAbortNone) then
        return true
    elseif (holeAbortLevel == holeAbortStrict) then
         return checkForSolids(execptDirection)
    elseif (holeAbortLevel == holeAbortLoose) then
        local passedCheck = checkForSolids(execptDirection)

        if (passedCheck == false) then
            local safe = false
            repeat
                moveGeneric(robot.down, vec3.down(), true)
                if (checkForSolids(vec3.up())) then
                    safe = true
                end
            until safe
        end

        return true
    end
end

-- Resets the path data. Only call this function if you are at the origin
local function resetPathData()
    path = {origin}
    pathInd = 1
end

-- EXPORTED LIBRARY FUNCTIONS

function navigation.log(message)
    log(message)
end

function navigation.endLog(message)
    logFile:close()
end

function navigation.move(logPath)
    if logPath and (not holeAbort(facing)) then
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.forward, facing, logPath)
end

function navigation.moveUp(logPath)
    if logPath and (not holeAbort(vec3.up())) then
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.up, vec3.up(), logPath)
end

function navigation.moveDown(logPath)
    if logPath and (not holeAbort(vec3.down())) then
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.down, vec3.down(), logPath)
end

function navigation.turnRight()
    turnRight()
end

function navigation.turnLeft()
    turnLeft()
end

function navigation.faceDirection(dir)
    while not vec3.equals(facing, dir) do
        turnRight()
    end
end

function navigation.moveAndClear(moveFunction, attackFunction, returning)
    local moved = false
    local error = nil
    local counter = 0

    while moved == false do
        moved, error = moveFunction(not returning)

        if moved == false then
            log("Movement Failure: " .. error .. ".")
            if (error == holeError) and (not returning) then
                return false
            end
            log("Attempting swing...")
            local swingSuccess, message = attackFunction()
            if swingSuccess then
                log("Swing success. Hit on: " .. message)
            else
                log("Swing failure.")
            end
            counter = counter + 1
        end
        if (not returning) and (counter >= 10) then
            return false
        end
    end
    return true
end

function navigation.returnHome()
    log("Returning Home.")
    pathInd = pathInd - 1
    while pathInd > 0 do
        local goal = path[pathInd]
        if vec3.equals(pos, goal) then
            return
        end
        local direction = directionBetween(pos, goal)
        if vec3.equals(direction, vec3.up()) then
            navigation.moveAndClear(navigation.moveUp, robot.swingUp, true)
        elseif vec3.equals(direction, vec3.down()) then
            navigation.moveAndClear(navigation.moveDown, robot.swingDown, true)
        else
            navigation.faceDirection(direction)
            navigation.moveAndClear(navigation.move, robot.swing, true)
        end
        pathInd = pathInd - 1
    end
    resetPathData()
end

function navigation.setHoleAbortLevel(level)
    local numLevel = 1

    if (level == "none") then
        numLevel = holeAbortNone
    elseif (level == "strict") then
        numLevel = holeAbortStrict
    elseif (level == "loose") then
        numLevel = holeAbortLoose
    end

    holeAbortLevel = numLevel
    log("hole abort level set to " .. level)
end

return navigation
