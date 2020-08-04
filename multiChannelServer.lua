--this needs to be rewritten to use the component.modem api, this isn't how event works apparently


local event = require("event")
local songs = require("songs")

function sendFile(songName)
    event.push("mc_song", songName)
end

function sendPlay()
    event.push("mc_play")
end

function waitForReply()
    local count = 0

    while count < 8 do
        event.pull("mc_ready")
        count = count + 1
    end

    if count >= 8 then
        return true
        count = 0
    end
end

function getInput()
    local run = true
    repeat
        print("Enter song name: ")

        local songName = io.read()
    
        if songs.songName ~= nil then
            print("playing " .. songName)
            return songName
            run == false
        else
            print("invalid song name. would you like a list of valid songs? y/n")
    
            local answer = io.read()
    
            if answer == "y" then
                songs.lookup()
            end
        end
    until run == false
end

function main()
    sendFile(getInput())

    if waitForRely() then
        sendPlay()
    end
end

main()