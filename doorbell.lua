local doorbell = {}

computer = require("computer")
music = require("music")

local tone1 = 440
local tone2 = 349
local delay = 1
local scout = "scout"
local eve = "EVE"
-- e3-2 g5-1 e5-1 f5-4 e3-2 g5-1 e5-1 f4-4

local scoutSounds = {{165, 0.5},  {784, 0.25}, {659, 0.25}, {698, 1}, {165, 0.5},  {784, 0.25}, {659, 0.25}, {349, 1}}
local eveSounds = 
{
    {music.notes["REST"], music.beats(1)},
    {music.notes["E4"], music.beats(1)}, {music.notes["D4"], music.beats(1)}, {music.notes["C4"], music.beats(0.5)}, {music.notes["G4"], music.beats(1)},
    {music.notes["E4"], music.beats(1.5)}, {music.notes["D4"], music.beats(1)}, {music.notes["C4"], music.beats(0.5)}, {music.notes["D4"], music.beats(4.5)}, {music.notes["REST"], music.beats(1)},
    {music.notes["G3"], music.beats(1)}, {music.notes["C4"], music.beats(1)}, {music.notes["B3"], music.beats(0.5)}, {music.notes["A3"], music.beats(4.5)},
    {music.notes["G3"], music.beats(4)}, {music.notes["B3"], music.beats(4)}, {music.notes["A3"], music.beats(1.5)}, {music.notes["REST"], music.beats(1)}
}

local robotSounds = {}
robotSounds[scout] = scoutSounds
robotSounds[eve] = eveSounds


function doorbell.ringHome()
    while true do
        computer.beep(tone1, delay)
        os.sleep(delay)
        computer.beep(tone2, delay)
        os.sleep(delay)
    end
end


--takes string as robot type
function doorbell.ring(type)
    local running = true
    if (robotSounds[type] == nil) then
        print("invalid robot type")
        running = false
    end

    while running do
        for k,v in pairs(robotSounds[type]) do
            if (v[1] == 0) then
                os.sleep(v[2])
            else
                computer.beep(v[1], v[2])
            end
        end
    end
end

function doorbell.lookup()
    for k,v in pairs(robotSounds) do
        print(k)
    end
end

return doorbell