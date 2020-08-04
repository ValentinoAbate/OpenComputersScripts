local path = require("pathing")
local genpath = require("genericPaths")
local doorbell = require("doorbell")

function probe()
    os.sleep(45)
    doorbell.start()

    path.pathAndReturn
    (
        path.setHoleAbortLevel("none"),
        path.forward(7),
        path.turnRight(),
        path.forward(8),
        path.setHoleAbortLevel("strict"),
        path.down(60),
        path.turnRight(),
        path.turnRight(),
        genpath.clawForward(6, 4, 2)
    )
    path.endPathing()

    doorbell.ring("fireflies")

end

probe()