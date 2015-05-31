Joint = Class("Joint")

function Joint:init(a, b, c, minAngle, maxAngle, stiff)
    self.a = a
    self.b = b
    self.c = c
    self.mina = minAngle
    self.maxa = maxAngle
    self.stiffness = stiff
end

function Joint:solve()
    local vec1 = self.a.pos - self.b.pos
    local vec2 = self.c.pos - self.b.pos
    
    local angle = math.atan2(vec1 % vec2, vec1 * vec2) --"%" = cross product
    
    if self.mina > self.maxa then
        if angle <= self.maxa or angle >= self.mina then return end
    else
        if angle <= self.maxa and angle >= self.mina then return end
    end
    
    local diff1 = angle - self.mina
    
    if diff1 <= -math.pi then
        diff1 = diff1 + 2 * math.pi
    elseif diff1 >= math.pi then
        diff1 = diff1 - 2 * math.pi
    end
    
    local diff2 = angle - self.maxa
        
    if diff2 <= -math.pi then
        diff2 = diff2 + 2 * math.pi
    elseif diff2 >= math.pi then
        diff2 = diff2 - 2 * math.pi
    end
    
    local diff = math.abs(diff1) < math.abs(diff2) and diff1 or diff2
    
    if math.abs(diff) < 0.0001 then return end

    diff = (diff /physics.getDeltaTime()) * self.stiffness
    
    local imTotal = self.a.imass + self.b.imass + self.c.imass
    
    self.a.pos:rotateAround(self.b.pos, diff * self.a.imass / imTotal)
    self.c.pos:rotateAround(self.b.pos, -diff * self.c.imass / imTotal)
    self.b.pos:rotateAround(self.a.pos, diff * self.b.imass / imTotal)
    self.b.pos:rotateAround(self.c.pos, -diff * self.b.imass / imTotal)
end

function Joint:negateAngle()
    local tmina = self.mina
    self.mina = -self.maxa
    self.maxa = -tmina
end

