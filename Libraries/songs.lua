--iterate thru song files with filesystem
--make each song a table by unserializing it and naming the table the name of the file minus the ".txt"
--add said tables to songs

local songs = {}
local path = "/usr/lib/playlist/"

music = require("music")
filesystem = require("filesystem")
serialization = require("serialization")

for fileName in filesystem.list(path) do
    local file = io.open(path .. fileName)
    fileContents = file:read("*all")
    io.close(file)
    songName = string.sub(fileName, 1, -5)
    songs[songName] = serialization.unserialize(fileContents)
end

function songs.lookup()
    for k, v in pairs(songs) do
        print(k)
    end
end

return songs