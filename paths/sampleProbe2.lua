path = require("pathing")
doorbell = require("doorbell")

function probe()
    os.sleep(45)
    doorbell.start()

    path.pathAndReturn(path.setHoleAbortLevel("none"), path.forward(7), path.turnRight(), path.forward(20), path.setHoleAbortLevel("strict"), path.down(20))
    path.endPathing()

    doorbell.ring("fireflies")

end

probe()