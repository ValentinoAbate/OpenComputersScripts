path = require("pathing")
doorbell = require("doorbell")

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
        path.down(56),
        path.turnRight(),
        path.forward(20),
        path.turnLeft(),
        path.forward(1),
        path.turnLeft(),
        path.forward(20),
        path.turnRight(),
        path.forward(1),
        path.turnRight(),
        path.forward(20),
        path.turnRight(),
        path.turnRight(),
        path.up(1),
        path.forward(20),
        path.turnLeft(),
        path.forward(1),
        path.turnLeft(),
        path.forward(20),
        path.turnRight(),
        path.forward(1),
        path.turnRight(),
        path.forward(20)
    )
    path.endPathing()

    doorbell.ring("fireflies")

end

probe()