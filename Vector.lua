--requires Class, MathHelper

Vector = Class("Vector")

function Vector:__tostring()
    return string.format("Vector: %d, %d", self.x, self.y)
end

function Vector:init(x, y)
    if Vector:made(x) then
        self.x = x.x
        self.y = x.y
    else
        self.x = x
        self.y = y
    end
end

function Vector:newNormal(phi)
    self.x = math.round(math.cos(phi))
    self.y = math.round(math.sin(phi))
    return self
end

function Vector:Length()
    return math.sqrt(self.x^2 + self.y^2)
end

function Vector:LengthSqr()
    return self.x^2 + self.y^2
end

function Vector:set(x, y)
    self.x = x
    self.y = y
    return self
end

function Vector:negate()
    self.x = -self.x
    self.y = -self.y
    return self
end

function Vector.__unm(vector)
    return Vector(-vector.x, -vector.y)
end

function Vector.__add(lhs, rhs)
        
    if Vector:made(lhs) and Vector:made(rhs) then
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y)
    elseif Vector:made(lhs) and type(rhs) == "number" then
        return Vector(lhs.x + rhs, lhs.y + rhs)
    elseif type(lhs) == "number" and Vector:made(rhs) then
        return Vector(lhs + rhs.x, lhs + rhs.y)
    end
end

function Vector.__sub(lhs, rhs)

    if Vector:made(lhs) and Vector:made(rhs) then
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y)
    elseif Vector:made(lhs) and type(rhs) == "number" then
        return Vector(lhs.x - rhs, lhs.y - rhs)
    elseif type(lhs) == "number" and Vector:made(rhs) then
        return Vector(lhs - rhs.x, lhs - rhs.y)
    end
end

function Vector.__mul(lhs, rhs)

    if Vector:made(lhs) and Vector:made(rhs) then
        return lhs.x * rhs.x + lhs.y * rhs.y --Dot Product
    elseif Vector:made(lhs) and type(rhs) == "number" then
        return Vector(lhs.x * rhs, lhs.y * rhs)
    elseif type(lhs) == "number" and Vector:made(rhs) then
        return Vector(lhs * rhs.x, lhs * rhs.y)
    end
end

function Vector.__div(lhs, rhs)

    if Vector:made(lhs) and Vector:made(rhs) then
        return Vector(lhs.x / rhs.x, lhs.y / rhs.y)
    elseif Vector:made(lhs) and type(rhs) == "number" then
        return Vector(lhs.x / rhs, lhs.y / rhs)
    elseif type(lhs) == "number" and Vector:made(rhs) then
        return Vector(lhs / rhs.x, lhs / rhs.y)
    end
end

function Vector.__eq(lhs, rhs)
    return lhs.x == rhs.x and lhs.y == rhs.y
end

function Vector:normalised( len )
    if not len then
        len = self:Length()
    end
    return Vector(self.x / len, self.y / len)
end

function Vector:normalise( len )
    if not len then
        len = self:Length()
    end
    
    self.x = self.x / len
    self.y = self.y / len
    
    return self
end

function Vector:rotateAround(center, phi)
    local x = self.x - center.x
    local y = self.y - center.y
    self.x, self.y = x*math.cos(phi) - y*math.sin(phi) + center.x, x*math.sin(phi) + y*math.cos(phi) + center.y
end

function Vector:rotate(phi)
    self.x, self.y = self.x * math.cos(phi) + self.y * math.sin(phi), self.x * -math.sin(phi) + self.y * math.cos(phi)
    return self
end

--component multiplication
function Vector:compMul(othervect)
    if not Vector:made(othervect) then return end
    
    return Vector(self.x * othervect.x , self.y * othervect.y)
end

--Cross Product
function Vector.__mod(lhs, rhs)

    if Vector:made(lhs) and Vector:made(rhs) then
        return lhs.x * rhs.y - lhs.y * rhs.x
    elseif Vector:made(lhs) and type(rhs) == "number" then
        return Vector(rhs * lhs.y, -rhs * lhs.x)
    elseif type(lhs) == "number" and Vector:made(rhs) then
        return Vector(-lhs * rhs.y, lhs * rhs.x)
    end
end

    