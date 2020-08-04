path = require("pathing")
doorbell = require("doorbell")

function probe()
    local vertical = 20
    local horizontal = 8
    os.sleep(45)
    doorbell.start()

    path.pathAndReturn(path.forward(horizontal), path.down(vertical), path.up(vertical), path.turnLeft(), path.turnLeft(), path.forward(horizontal))

end