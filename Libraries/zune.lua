--probably rewrite this
--zune should only be for library type functions
--the major zune functions like play and such can be on here
--client and host should maybe be their own actual files that are scripts that run

--zune should probably just be for the advanced play options that can handle shuffle and loop


local zune = {}
local computer = require("computer")

function zune.play(songTrack)
    for k,v in pairs(songTrack) do
        computer.beep(v[1],v[2])
    end
end




return zune