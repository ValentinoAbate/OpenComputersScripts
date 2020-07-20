robot = require("robot")
serialization = require("serialization")
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
    logFile:write("Position is now " .. serialization.serialize(pos) .. ". " .. (pathInd - 1) .. " moves away from home.\n")
end

function moveGeneric(moveFunction, direction, logPath)
    logFile:write("Attempting move in " .. serialization.serialize(direction) .. " direction...\n")
    local success = moveFunction()
    if(success == nil) then return false end
    pos = addPositions(pos, direction)
    logFile:write("Move success!\n")
    if(logPath) then
        logCurrentPositionInPath()
    end
    return true
end

function move(logPath)
    return moveGeneric(robot.forward, facing, logPath)
end

function moveUp(logPath)
    return moveGeneric(robot.up, up, logPath)
end

function moveDown(logPath)
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
    local counter = 0

    while moved == false do
        moved = moveFunction(not returning)

        if moved == false then
            logFile:write("Movement Failure. Attempting swing...\n")
            local swingSuccess, message = attackFunction()
            if swingSuccess then
                logFile:write("Swing success. Hit on: " .. message .. "\n")
            else
                logFile:write("Swing failure.\n")
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
    logFile:write("Returning Home.\n")
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
end

function main()
    logFile:write("Starting routine.\n")
    for i = 1, 12 do
        if (not moveAndClear(moveUp, robot.swingUp, false)) then 
            break
        end
    end
    returnHome()
    faceDirection(north)
    logFile:close()
end

main()