local robot = require("robot")
local serialization = require("serialization")
local origin = {0,0,0}
local pos = {0,0,0}
local north = {0,0,-1}
local east = {1,0,0}
local south = {0,0,1}
local west = {-1,0,0}
local up = {0,1,0}
local down = {0,-1,0}
local directions = {north, east, south, west, up, down}
local facingInd = 1
local facing = north
local pathInd = 1
local path = {origin}
local logFile = io.open("logFile.txt", "w")
local newLine = "\n";
local holeError = "Hole Safety Protocol Violation"

function log(message)
    logFile:write(message .. newLine)
end

function comparePositions(pos1, pos2)
    return pos1[1] == pos2[1] and pos1[2] == pos2[2] and pos1[3] == pos2[3]
end

function addPositions(pos1, pos2)
    return {pos1[1] + pos2[1], pos1[2] + pos2[2], pos1[3] + pos2[3]}
end

function compareDirection(dir1, dir2)
    return dir1[1] == dir2[1] and dir1[2] == dir2[2] and dir1[3] == dir2[3] 
end

function logCurrentPositionInPath()
    pathInd = pathInd + 1
    path[pathInd] = {pos[1], pos[2], pos[3]}
    log((pathInd - 1) .. " moves away from home.")
end

function checkForSolids(exceptDirection)
    if(not (down == exceptDirection)) then
        blocked, blockType = robot.detectDown()
        if(blocked and (blockType == "solid")) then
            return true
        end
    end
    if(not (up == exceptDirection)) then
        blocked, blockType = robot.detectUp()
        if(blocked and (blockType == "solid")) then
            return true
        end
    end
    local ret = false
    for 1,4 do
        if(not (facing == exceptDirection)) then
            blocked, blockType = robot.detect()
            if(blocked and (blockType == "solid")) then
                ret = true
            end
        end
    end
    return ret
end

function moveGeneric(moveFunction, direction, logPath)
    log("Attempting move in " .. serialization.serialize(direction) .. " direction...")
    local success = moveFunction()
    if(success == nil) then return false end
    pos = addPositions(pos, direction)
    log("Move success! Position is now " .. serialization.serialize(pos) .. ".")
    if(logPath) then
        logCurrentPositionInPath()
    end
    return true
end

function move(logPath)
    if not checkForSolids(facing) then 
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.forward, facing, logPath)
end

function moveUp(logPath)
    if not checkForSolids(up) then 
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.up, up, logPath)
end

function moveDown(logPath)
    if not checkForSolids(down) then 
        log(holeError)
        return false, holeError
    end
    return moveGeneric(robot.down, down, logPath)
end

function turnRight()
    robot.turnRight()
    facingInd = facingInd + 1
    if facingInd == 5 then facingInd = 1 end
    facing = directions[facingInd]
end

function turnLeft()
    robot.turnLeft()
    facingInd = facingInd - 1
    if facingInd <= 0 then facingInd = 4 end
    facing = directions[facingInd]
end

function directionBetween(from, to)
    return {to[1] - from[1], to[2] - from[2], to[3] - from[3]}
end

function faceDirection(dir)
    while not compareDirection(facing, dir) do
        turnRight()
    end
end

function moveAndClear(moveFunction, attackFunction, returning)
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

function returnHome()
    log("Returning Home.")
    pathInd = pathInd - 1
    while pathInd > 0 do
        local goal = path[pathInd]
        if comparePositions(pos, goal) then
            return
        end
        local direction = directionBetween(pos, goal)
        if compareDirection(direction, up) then 
            moveAndClear(moveUp, robot.swingUp, true)
        elseif compareDirection(direction, down) then
            moveAndClear(moveDown, robot.swingDown, true)
        else
            faceDirection(direction)
            moveAndClear(move, robot.swing, true)
        end
        pathInd = pathInd - 1
    end
    resetPathData()
end

-- Resets the path data. Only call this function if you are at the origin
function resetPathData()
    path = {origin}
    pathInd = 1
end