Gyroscope = Class("Gyroscope")

function Gyroscope:init(angle, a, b)
    self.a = a
    self.b = b
    self.angle = angle
end

function Gyroscope:doGyroScopicAction()
    local vec1 = self.a.pos - self.b.pos
    
    local angle = math.atan2(Vector(0,1) % vec1, Vector(0,1) * vec1) --"%" = cross product
    
    local diff = self.angle - angle
    
    if diff <= -math.pi then
        diff = diff + 2 * math.pi
    elseif diff >= math.pi then
        diff = diff - 2 * math.pi
    end
    
    if math.abs(diff) < 0.0001 then return end

    diff = (diff /physics.getDeltaTime()) * 0.8
    
    local imTotal = self.a.imass + self.b.imass
    
    self.b.pos:rotateAround(self.a.pos, diff * self.b.imass / imTotal)
    self.a.pos:rotateAround(self.b.pos, diff * self.a.imass / imTotal)
end
