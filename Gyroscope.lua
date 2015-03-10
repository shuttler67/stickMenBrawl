Gyroscope = Class("Gyroscope")

function Gyroscope:init(angle, a, b)
    self.a = a
    self.b = b
    self.angle = angle
end

function Gyroscope:solve()
    local vec1 = self.a.pos - self.b.pos
    
    local angle = math.atan2(Vector(0,1) % vec1, Vector(0,1) * vec1) --"%" = cross product
    
    local diff = self.angle - angle
    
    if diff <= -math.pi then
        diff = diff + 2 * math.pi
    elseif diff >= math.pi then
        diff = diff - 2 * math.pi
    end
    
    if math.abs(diff) < 0.0001 then return end

    diff = (diff) /physics.getDeltaTime()
    
    local imA = 1/self.a.mass
    local imB = 1/self.b.mass
    local imTotal = imA + imB
    
    
    self.b.pos:rotateAround(self.a.pos, diff * imB / imTotal)
    self.a.pos:rotateAround(self.b.pos, diff * imA / imTotal)
end
