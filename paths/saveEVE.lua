--[[
    os.sleep(40)
    move forward 8
    move down 10
    move up 5
    turn around
    move forward 28




    testpath

    os.sleep(5)
    move forward 8
    move down 5
    move up 2
    turn around
    move forward 10
--]]
path = require("pathing")
doorbell = require("doorbell")
computer = require("computer")


function pathEVE()
    os.sleep(45)
    computer.beep(600, 4)
    path.pathAndReturn(path.forward(8), path.down(10), path.up(5), path.turnLeft(), path.turnLeft(), path.forward(28))
    doorbell.ring("scout")
end

function pathTest()
    os.sleep(5)
    path.pathAndReturn(path.forward(8), path.down(5), path.turnLeft(), path.turnLeft(), path.forward(10))
    doorbell.ring("scout")
end

pathEVE()
path.endPathing()