Muscle = Class("Muscle")

function Muscle:init(a, b, c, angle, strength)
    self.a = a
    self.b = b
    self.c = c
    self.angle = angle
    self.strength = strength
    self.disabled = false
end

function Muscle:solve()
    if self.disabled then return end
    
    local vec1 = self.a.pos - self.b.pos
    local vec2 = self.c.pos - self.b.pos
    
    local angle = math.atan2(vec1 % vec2, vec1 * vec2) --"%" = cross product
    
    local diff = angle - self.angle
    
    if diff <= -math.pi then
        diff = diff + 2 * math.pi
    elseif diff >= math.pi then
        diff = diff - 2 * math.pi
    end
    
    if math.abs(diff) < 0.0001 then return end

    diff = (diff / physics.getDeltaTime()) * self.strength
    
    local imTotal = self.a.imass + self.b.imass + self.c.imass
    
    self.a.pos:rotateAround(self.b.pos, diff * self.a.imass / imTotal)
    self.c.pos:rotateAround(self.b.pos, -diff * self.c.imass / imTotal)
    self.b.pos:rotateAround(self.a.pos, diff * self.b.imass / imTotal)
    self.b.pos:rotateAround(self.c.pos, -diff * self.b.imass / imTotal)
end

function Muscle:negateAngle()
    self.angle = -self.angle
end

function Muscle:addToAngle(d)
    self.angle = self.angle + d
end

function Muscle:disable() self.disabled = true end
function Muscle:enable() self.disabled = false end
