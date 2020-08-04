path = require("pathing")
doorbell = require("doorbell")

function probe()
    os.sleep(5)
    doorbell.start()

    path.pathAndReturn(path.setHoleAbortLevel("loose"), path.forward(7), path.down(1))
    path.endPathing()

    doorbell.ring("fireflies")

end

probe()