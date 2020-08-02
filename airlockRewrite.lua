local dimensions = {}
local debug = require("component").debug
local computer = require("computer")
local sides = require("sides")
local redstone = require("component").redstone
local component = require("component")
local shell = require("shell")


--EDIT THESE VALUES

--set these values to the coordinate values of the airlock
--format: xyz of top left corner followed by xyz of bottom right, all values should be separated by one space
--example: x1 y1 z1 x2 y2 z2
dimensions.OVERWORLD = {["front"] = "7 73 499 9 71 499", ["back"] = "7 73 495 9 71 495"}
dimensions.NETHER = {["front"] = "", ["back"] = ""}
dimensions.END = {["front"] = "", ["back"] = ""}

--replace with operating dimension
airlock = dimensions.OVERWORLD

--set to the address of the energy cube
local proxy = component.proxy("")

--set these values to determine the power of operation
power = 10000

--set this to the sound that should play on door open/close
sound = "mekanism:etc.hydraulic"

--set this to the number of seconds to wait between operations
delay = 3

finishTime = 155


--MAIN

--cleanup
redstone.setOutput(sides.back, 1)
redstone.setOutput(sides.bottom, 0)
redstone.setOutput(sides.top, 0)
redstone.setOutput(sides.front, 0)
redstone.setOutput(sides.right, 0)
redstone.setOutput(sides.left, 0)

run = false

function closeBack()
    debug.runCommand("fill " .. airlock.back .. " bedrock")
end

function openBack()
    debug.runCommand("fill " .. airlock.back .. " air")
end

function closeFront()
    debug.runCommand("fill " .. airlock.front .. " bedrock")
end

function openFront()
    debug.runCommand("fill " .. airlock.front .. " air")
end

function delPower()
    local currentPower = proxy.getEnergyStored()
    local minPower = currentPower - power

    while (proxy.getEnergyStored() > minPower) do
        redstone.setOutput(sides.bottom, 1)
        redstone.setOutput(sides.back, 0)
    end

    redstone.setOutput(sides.bottom, 0)
    redstone.setOutput(sides.back, 1)
end

function savePower()
    redstone.setOutput(sides.back, 1)
    redstone.setOutput(sides.bottom, 0)
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

function progressBar()
    middleNum = (finishTime/2) - 4
    print("")
    io.write("|")

    for i = 1, middleNum do
        io.write(" ")
    end

    io.write("PROGRESS")

    for i = 1, middleNum do
        io.write(" ")
    end

    print("|")
    io.write(" ")
    for i = 1, finishTime do
        os.sleep(delay/finishTime)
        io.write("=")
    end
end


function main()
    debug.runCommand("playsound mekanism:etc.beep master @a ~ ~ ~ 1 1 1")

    if fileExists("lockState.txt") == false then
        file = io.open("lockState.txt", "w")
        file:write("insideClosed")
        io.close(file)
        closeFront()
        openBack()
    end

    local file = io.open("lockState.txt", "r")
    lockStateValue = file:read()
    io.close(file)

    if (lockStateValue == "insideClosed") then
        insideClosed = true
    elseif (lockStateValue == "insideOpen") then
        insideClosed = false
        io.close(file)
    else
        os.exit()
    end


    print("power stored: " .. proxy.getEnergyStored())

    if (proxy.getEnergyStored() < power) then
        print("power needed: " .. power)
        print("gaining power...")

        while (proxy.getEnergyStored() <= power) do
            os.sleep(3)
            print(proxy.getEnergyStored())
        end
    end
        
    if (proxy.getEnergyStored() >= power) then
        print("engaging airlock motors...")
        delPower()
        print("")
        print("power remaining: " .. proxy.getEnergyStored())
        print("")
        print("airlock motors engaged")
        run = true
    end

    if (run == true) then
        if (insideClosed) then
            debug.runCommand("playsound mekanism:etc.beep master @a ~ ~ ~ 1 1 1")
            print("")
            print("initiate airlock protocol?")
            wait_for_user = io.read()

            closeBack()
            debug.runCommand("playsound " .. sound .. " master @a ~ ~ ~ 1 1 1")
            os.sleep(delay)
            openFront()
            debug.runCommand("playsound " .. sound .. " master @a ~ ~ ~ 1 1 1")

            redstone.setOutput(sides.bottom, 0)
            redstone.setOutput(sides.back, 1)

            file =io.open("lockState.txt", "w")
            file:write("insideOpen")
            io.close(file)
            
            run = false
        else
            debug.runCommand("playsound mekanism:etc.beep master @a ~ ~ ~ 1 1 1")
            print("")
            print("initiate airlock protocol?")
            io.read()
            closeFront()
            debug.runCommand("playsound " .. sound .. " master @a ~ ~ ~ 1 1 1")
            os.sleep(delay)
            openBack()
            debug.runCommand("playsound " .. sound .. " master @a ~ ~ ~ 1 1 1")

            redstone.setOutput(sides.bottom, 0)
            redstone.setOutput(sides.back, 1)

            file =io.open("lockState.txt", "w")
            file:write("insideClosed")
            io.close(file)

            run = false
        end
    end

    progressBar()
    shell.execute("clear")
    debug.runCommand("playsound mekanism:etc.success master @a ~ ~ ~ 1 1 1")
    print("airlock protocol successful")

end

main()