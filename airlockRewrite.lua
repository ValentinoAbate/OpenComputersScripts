dimentions = {}



--EDIT THESE VALUES

--set these values to the coordinate values of the airlock
--format: xyz of top left corner followed by xyz of bottom right, all values should be separated by one space
--example: x1 y1 z1 x2 y2 z2
dimensions.OVERWORLD = {["front"] = "", ["back"] = ""}
dimensions.NETHER = {["front"] = "", ["back"] = ""}
dimensions.END = {["front"] = "", ["back"] = ""}

--replace with operating dimension
airlock = dimensions.OVERWORLD

--set to the address of the energy cube
local proxy = component.proxy("")

--set these values to determine the min and max power of operation
power = 10000
min_power = 1000


--MAIN
local debug = require("component").debug
local computer = require("computer")
local sides = require("sides")
local redstone = require("component").redstone
local component = require("component")


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
    redstone.setOutput(sides.bottom, 1)
    redstone.setOutput(sides.back, 0)
end

function savePower()
    redstone.setOutput(sides.back, 1)
    redstone.setOutput(sides.bottom, 0)
end


function main()

    file =io.open("lockState.txt", "w+")

    if (file:read() == "insideClosed") then
        insideClosed = true
        io.close(file)
    else if (file:read() == "insideOpen") then
        insideClosed = false
        io.close(file)
    else
        closeFront()
        openBack()
        insideClosed = true
        io.close(file)
    end


    print("power needed: " .. power)
    print("charging...")
    while (proxy.getEnergyStored() <= power) do
        os.sleep(3)
        print(proxy.getEnergyStored())
    end
        
    if (proxy.getEnergyStored() >= power) then
        delPower()
        print("dumping power...")
        run = true
    end

    while (run == true) do
        os.sleep(5)
        print(proxy.getEnergyStored())

        if ((run == true) and (proxy.getEnergyStored() <= min_power)) then
            if (insideClosed) then
                print("")
                print("initiate airlock protocol?")
                wait_for_user = io.read()
    
                closeBack()
                debug.runCommand("playsound entity.elder_guardian.ambient master @a ~ ~ ~ 1 1 1")
                os.sleep(5)
                openFront()
                debug.runCommand("playsound entity.elder_guardian.ambient master @a ~ ~ ~ 1 1 1")
    
                redstone.setOutput(sides.bottom, 0)
                redstone.setOutput(sides.back, 1)

                file =io.open("lockState.txt", "w+")
                file:write("insideOpen")
                io.close(file)
                
                run = false
            else
                print("")
                print("initiate airlock protocol?")
                io.read()
                closeFront()
                debug.runCommand("playsound entity.elder_guardian.ambient master @a ~ ~ ~ 1 1 1")
                os.sleep(5)
                openBack()
                debug.runCommand("playsound entity.elder_guardian.ambient master @a ~ ~ ~ 1 1 1")

                redstone.setOutput(sides.bottom, 0)
                redstone.setOutput(sides.back, 1)

                file =io.open("lockState.txt", "w+")
                file:write("insideOpen")
                io.close(file)

                run = false
            end
        end
    end
end

main()