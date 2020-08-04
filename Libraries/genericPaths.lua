genericPaths = {}

path = require("pathing")

function clawForward(length, width, height)
    return function()
        for i = 1, height do
            path.log("Moving .. " length .. " claws forward of " .. width .. " width")
            for i = 1, length do
                local pass = path.path
                (
                    path.forward(1),
                    path.turnRight(),
                    path.forward(width),
                    path.turnRight(),
                    path.turnRight(),
                    path.forward(width),
                    path.forward(width),
                    path.turnRight(),
                    path.turnRight(),
                    path.forward(width),
                    path.turnLeft(),
                    path.forward(2)

                )
                if pass == false then
                    return pass
                end
            end
            local pass = path.path
            (
                path.turnRight(),
                path.turnRight(),
                path.up(3),
                path.forward(1)
            )
            if pass == false then
                return pass
            end
        end
        return true
    end
end

--EXPORTED FUNCTIONS

genericPaths.clawForward = clawForward

genericPaths.clawForwardOne = function(length, width) return clawForward(length, width, 1) end

return genericPaths