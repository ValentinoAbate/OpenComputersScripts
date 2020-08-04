vector3 = {}

-- Local functions

-- Returns a new vector3 with the input components and all member functions
local function create(x, y, z)
    local vec3 = { ["x"] = x, ["y"] = y, ["z"] = z }
    --[[
        vec3.__index = vec3
        -- Add another vector3 to this one (in place)
        function vec3:add(vec)
            self.x = self.x + vec.x
            self.y = self.y + vec.y
            self.z = self.z + vec.z     
        end
        -- Subtract another vector3 from this one (in place)
        function vec3:sub(vec)
            self.x = self.x - vec.x
            self.y = self.y - vec.y
            self.z = self.z - vec.z     
        end
        -- Scale this vector3 (in place)
        function vec3:scale(scalar)
            self.x = self.x * scalar
            self.y = self.y * scalar
            self.z = self.z * scalar    
        end
        -- Return true if this vector3 is equal to another, else false (all coords have the same value)
        function vec3:equals(vec)
            return (self.x == vec.x) and (self.y == vec.y) and (self.z == vec.z)
        end
        function vec3:__tostring()
            return "(x: " .. self.x .. ", y: " .. self.y .. ", z: " .. self.z .. ")" 
        end
    --]]
    return vec3
end

-- Returns a new vector3 that is the sum of the two inputs
local function add(vec1, vec2)
    return create(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)
end

-- Returns a new vector3 that is the difference of second input subtracted from the first
local function subtract(vec1, vec2)
    return create(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z)
end

-- Returns a new vector3 that is the input vector scaled by the input scalar (multiplies all components by the scalar)
local function scale(vec, scalar)
    return create(vec1.x * scalar, vec1.y * scalar, vec1.z * scalar)
end

-- Returns true if two vector3s are equal, else false (all coords have the same value)
local function equals(vec1, vec2)
    return (vec1.x == vec2.x) and (vec1.y == vec2.y) and (vec1.z == vec2.z)
end

-- EXPORTED FUNCTIONS

-- Local function references (see documentation where function is declared)
vector3.create = create
vector3.add = add
vector3.subtract = subtract
vector3.sub = subtract
vector3.scale = scale
vector3.equals = equals
-- Anonymous functions
-- A vec3 with 0 for x, y, and z
vector3.zero = function() return create(0, 0, 0) end
-- A vec3 with 1 for x, y, and z
vector3.one = function() return create(1, 1, 1) end

return vector3