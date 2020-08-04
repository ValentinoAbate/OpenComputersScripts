local event = require("event")
local zune = require("zune")

local track = {}

--set this to the channel that this computer should play on
local CHANNEL = 1

function saveTrack(eventName, fullSong)
    return fullSong[CHANNEL]
end

function waitForFile()
    track = event.listen("mc_song", saveTrack())
end

function sendReady()
    if track ~= nil then
        event.push("mc_ready")
    else
        print("something went wrong")
    end
end

function playTrack(eventName)
    zune.play(track)
end

function waitForPlay()
    event.listen("mc_play", playTrack())
end

function main()
    waitForFile()
    sendReady()
    waitForPlay()
end

main()