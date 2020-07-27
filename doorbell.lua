local doorbell = {}

computer = require("computer")

local tone1 = 440
local tone2 = 349
local delay = 1
local scout = "scout"
-- e3-2 g5-1 e5-1 f5-4 e3-2 g5-1 e5-1 f4-4

local scoutSounds = {{165, 0.5},  {784, 0.25}, {659, 0.25}, {698, 1}, {165, 0.5},  {784, 0.25}, {659, 0.25}, {349, 1}}
local robotSounds = {}
robotSounds[scout] = scoutSounds


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
                computer.beep(v[1], v[2])
        end
        os.sleep(delay)
    end
end

function doorbell.lookup()
    for k,v in pairs(robotSounds) do
        print(k)
    end
end

return doorbell