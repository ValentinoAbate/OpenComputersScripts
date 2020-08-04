local invSize = 0
while(true) do
    print("Enter Inventory Size (positive int):")
    invSize = io.read("*n")
    if(not (type(invSize) == "number")) then
        print("invalid input: inventory size must be a number")
        goto continue
    end
    if(invSize < 0) then
        print("invalid input: inventory size must be greater than 0")
        goto continue
    end
    break
    ::continue::
end
local table = {}
for i = 1, invSize, 1 do
    print("enter the name of the block in slot or end to end early: " .. i)
    if (i == 1) then
        io.read()
    end
    local block = io.read()
    if(block == "end") then
        break
    else
        table[i] = block
    end

end
print("Enter file name")
local fileName = io.read()
local file = io.open(fileName, "w")
file:write(serialization.serialize(table))
file:close()