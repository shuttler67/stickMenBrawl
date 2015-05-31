Link = Class("Link")

function Link:init(pm1, pm2, restingDistance, stiff, tearSensitivity, drawMe)

    self.p1 = pm1
    self.p2 = pm2

    self.restingDistance = restingDistance
    self.stiffness = stiff
    self.drawThis = drawMe
    self.tearSensitivity = tearSensitivity
end

function Link:solve()
    local diff = self.p1.pos - self.p2.pos
    local d = diff:Length()

    local difference = (self.restingDistance - d) / d

    if math.abs(difference) < 0.0001 then return end
    
    if self.tearSensitivity and d > self.tearSensitivity then
        print (self.tearSensitivity)
        self.p1:removeLink(self)
--        if self.drawThis then
--            local newp1 = PointMass(self.p2.x + diffX/2, self.p2.y + diffY/2)
--            local newp2 = PointMass(self.p2.x + diffX/2, self.p2.y + diffY/2)
--
--            self.p1.attachTo(newp2, self.restingDistance, self.stiffness, self.tearSensitivity, true)
--            self.p2.attachTo(newp1, self.restingDistance, self.stiffness, self.tearSensitivity, true)
            
--            physics.addPointMass(newp1)
--            physics.addPointMass(newp2)
--        end
end

    local scalarP1 = (self.p1.imass / (self.p1.imass + self.p2.imass)) * self.stiffness
    local scalarP2 = self.stiffness - scalarP1

    self.p1.pos = self.p1.pos + diff * scalarP1 * difference
    self.p2.pos = self.p2.pos - diff * scalarP2 * difference
end

function Link:draw()
    if self.drawThis then
        love.graphics.setLineWidth(self:getSize() * 2)
        love.graphics.setLineStyle( "smooth")
        love.graphics.line(self.p1.pos.x, self.p1.pos.y, self.p2.pos.x, self.p2.pos.y)
    end
end

function Link:getSize()
    return math.min(self.p1.size, self.p2.size)
end
