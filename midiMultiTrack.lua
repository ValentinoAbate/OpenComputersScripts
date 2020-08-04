--TODO 
--add one tick to the last note each song
    --for some fuck ass reason the midi format cuts the final note short by a tick
--add suppport for tempo
--put each channel into its own song table
--create an actual music player application
    --make it so it can play multiple tracks at the same time across different computers or use coroutines

--LONG TERM
--add support for a single track playing more than one note at the same time
--this will require basically completely rewriting this so I don't wanna do it now


--HOW TO USE

--please use this website to convert a midi file to a text file:
--http://flashmusicgames.com/midi/mid2txt.php

--name the file "song.txt" and place it in the same directory as midi.lua
--run midi.lua
--type the name of the song as it should be stored when prompted

--CURRENT LIMITATIONS

--midi file must only contain one track
--track must only ever have one note playing at a given time
--(these limitations are planned on being removed in the future)

local serialization = require("serialization")
local music = require("music")
local midiFile = "song.txt"
local song = {}
local path = "/usr/lib/playlist/"

local file = io.open(midiFile)
local startTick = 0
local lastTick = 0
local currentNote = 0
local currentTrack = 0

function convertToMusic(note, length)
    beat = music.midiBeats(length)
    tone = music.midiNotes(note)

    record = {tone, beat}
    table.insert(song[currentTrack], record)
end

function rest(sTick, lTick)
    restLength = sTick - lTick

    convertToMusic(0, restLength)
end

function fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then
        io.close(f)
        return true
    else
        return false
    end
end

function main()

    local fileName = ""
    local newFileName = false
    repeat
        print("Enter song name: ")
        fileName = io.read()

        if (fileExists(fileName)) then
            print("that name already exists.")
        else
            newFileName = true
        end
    until newFileName

    repeat
        line = file:read("*line")
    
        if (line ~= nil) then
            if (string.find(line, "Meta")) and (string.find(line, "TrkName"))) then
                currentTrack = currentTrack + 1
            else
                if ((string.find(line, "On") ~= nil) or (string.find(line, "Off") ~= nil)) then
                    lineTable = {}
                    i = 1
            
                    --splits line by space
                    for token in string.gmatch(line, "[^%s]+") do
                        lineTable[i] = token
                        i = i + 1
                    end
            
                    if (string.find(lineTable[2], "On") ~= nil) then
                        currentNote = tonumber(string.sub(lineTable[4], 3, -1))
                        startTick = tonumber(lineTable[1])
                        
                        if (startTick ~= lastTick) then
                            --adds a rest the size of the difference between the two values
                            rest(startTick, lastTick)
                        end
                        
                    else
                        --off state
            
                        lastTick = tonumber(lineTable[1])
            
                        local tickLength = lastTick - startTick
            
                        convertToMusic(currentNote, tickLength)
                    end
                end
            end
        end
    
    
    until line == nil
    
    file = io.open(path .. fileName .. ".txt", "w")
    file:write(serialization.serialize(song))
    io.close(file)
    
    print("file converted")
end

main()