local nav = require("navigation")
local robot = require("robot")
local pathing = {}

-- Local functions (mostly wrappers of the navigation library)

local function endLog()
    nav.endLog()
end

local function log(message)
    nav.log(message)
end

local function move()
    return nav.moveAndClear(nav.move, robot.swing, false)
end

local function moveUp()
    return nav.moveAndClear(nav.moveUp, robot.swingUp, false)
end

local function moveDown()
    return nav.moveAndClear(nav.moveDown, robot.swingDown, false)
end

local function turnRight()
    nav.turnRight()
end

local function turnLeft()
    nav.turnLeft()
end

local function turnAround()
    nav.turnLeft()
    nav.turnLeft()
end

local function setHoleAbortLevel(level)
    nav.setHoleAbortLevel(level)
end

local function trimPath()
    nav.trimPath()
end

-- INTERNAL PATH FUNCTIONS

-- Walk a random path of length (int) steps. 
-- returns false if path abort triggered, else true
local function randomPath(length)
    log("Starting random path of length " .. length)
    for i = 1, length do
        local r = math.random(100)
        local r2 = math.random(100)
        if r <= 25 then
            if (not moveUp()) then 
                return false
            end
        elseif r <= 35 then
            if (not moveDown()) then 
                return false
            end
        else
            if (not move()) then 
                return false
            end
        end
        -- Turn right or left hald the time
        if r2 <= 25 then
            turnRight()
        elseif r2 <= 50 then
            turnLeft()
        end
    end
    return true
end

-- Move forward length (int) steps. 
-- returns false if path abort triggered, else true
local function forwardPath(length)
    log("Moving " .. length .. " blocks forward.")
    for i = 1, length do
        if (not move()) then 
            return false
        end
    end
    return true
end

-- Move up length (int) steps. 
-- returns false if path abort triggered, else true
local function upPath(length)
    log("Moving " .. length .. " blocks up.")
    for i = 1, length do
        if (not moveUp()) then 
            return false
        end
    end
    return true
end

-- Move up length (int) steps. 
-- returns false if path abort triggered, else true
local function downPath(length)
    log("Moving " .. length .. " blocks down.")
    for i = 1, length do
        if (not moveDown()) then 
            return false
        end
    end
    return true
end


-- EXPORTED PATH FUNCTIONS

-- PATHS:
-- All PATH functions should return a function that does a path and returns true if the path should continue to the next step, or false of the path should abort


-- Move along a random path
function pathing.random(length)
    return function()
        return randomPath(length)
    end
end

-- Move an explicit number of spaces forward
function pathing.forward(length)
    return function()
        return forwardPath(length)
    end
end

-- Move an explicit number of spaces up
function pathing.up(length)
    return function()
        return upPath(length)
    end
end

-- Move and explicit number of spaces down
function pathing.down(length)
    return function()
        return downPath(length)
    end
end

-- Turn right (cannot abort)
function pathing.turnRight()
    return function()
        turnRight()
        return true
    end
end

-- Turn left (cannot abort)
function pathing.turnLeft()
    return function()
        turnLeft()
        return true
    end
end

function pathing.turnAround()
    return function()
        turnAround()
        return true
    end
end

-- Set level of hole about to be using
-- Can be "strict" for full hole about coverage or "none" for none
function pathing.setHoleAbortLevel(level)
    return function()
        setHoleAbortLevel(level)
        return true
    end
end

function pathing.trimPath()
    return function()
        trimPath()
        return true
    end
end 

-- PATH EXECUTION

function pathing.path(...)
    for i,v in ipairs({...}) do
        if not v() then 
            log("Aborting path.")
            return false 
        end
    end
    log("Path complete.")
    return true
end

function pathing.pathAndReturn(...)
    log("Starting path.")
    local failure = false
    for i,v in ipairs({...}) do
        if not v() then 
            failure = true
            log("Aborting path.")
            break;
        end
    end
    if not failure then log("Path complete.") end
    nav.returnHome()
end

function pathing.endPathing()
    log("Log end. Closed by Pathing.")
    endLog()
end

pathing.log = log

-- Return library

return pathing