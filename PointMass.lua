PointMass = Class("PointMass")

function PointMass:init(xPos, yPos)
    self.links = {}
    self.joints = {}

    self.pos = Vector(xPos, yPos)
    
    self.imass = 1
    self.size = 5

    self.lastPos = Vector(xPos, yPos)

    self.acc = Vector(0,0)
    
    self.collisionSubcriptions = {}
end

function PointMass:setMass(m) 
    if m ~= 0 then
        self.imass = 1/m
    else
        self.imass = 0
    end
end

function PointMass:updatePhysics(timeStep, gravity, damping)

    
    self.acc = self.acc + Vector(0, gravity)
    
    local vel = self.pos - self.lastPos

    vel = vel * damping

    local timeStepSq = timeStep * timeStep

    local nextPos = self.pos + vel + 0.5 * self.acc * timeStepSq

    self.lastPos = self.pos

    self.pos = nextPos

    self.acc:set(0,0)
end

function PointMass:draw()
    love.graphics.setColor(love.math.random(0,255), love.math.random(0,255), love.math.random(0,255))
    for _,l in pairs(self.links) do
        l:draw()
    end

    love.graphics.setLineWidth(7)
    love.graphics.circle("line", self.pos.x, self.pos.y, self.size - 3.5, 100)
end

function PointMass:solveConstraints( world )

    local collided = false
    
    for _,p in pairs(world:getStaticPolygons()) do
        for _,l in pairs(self.links) do
            p:solve(l)
        end
        local normal, penetration = p:solve(self)
        if normal then
            for k, v in pairs(self.collisionSubcriptions) do
                if type(k) == "number" then
                    v(self, normal, penetration)
                else
                    v(k, self, normal, penetration)
                end
            end
        end
    end
    if self.pos.y < self.size then
        local prevY = self.pos.y
        self.pos.y = self.size
        self:edgeCollide(0.9, Vector( 0, 1), prevY - self.pos.y)

    elseif self.pos.y > world:getHeight()-self.size then
        local prevY = self.pos.y
        self.pos.y = (world:getHeight() - self.size)
        self:edgeCollide(0.9, Vector( 0,-1), self.pos.y - prevY)
    end
    
    if self.pos.x > world:getWidth()-self.size then
        local prevX = self.pos.x
        self.pos.x = (world:getWidth() - self.size)
        self:edgeCollide(0.9, Vector(-1, 0), self.pos.x - prevX)

    elseif self.pos.x < self.size then
        local prevX = self.pos.x
        self.pos.x = self.size
        self:edgeCollide(0.9, Vector( 1, 0), prevX - self.pos.x)        
    end
    for _,l in pairs(self.links) do
        l:solve()
    end
    
    for _,j in pairs(self.joints) do
        j:solve()
    end
end

function PointMass:attachTo(pointmass, restingDist, stiff, tearSensitivity, drawLink)
    table.insert(self.links, Link(self, pointmass, restingDist, stiff, tearSensitivity , drawLink ~= false))
end

function PointMass:becomeJoint(p1, p2, minAngle, maxAngle, stiffness)
    local j = Joint(p1, self, p2, minAngle, maxAngle, stiffness)
    table.insert(self.joints, j)
    return j
end

function PointMass:becomeMuscle(p1, p2, angle, stiffness)
    local m = Muscle(p1, self, p2, angle, stiffness)
    table.insert(self.joints, m)
    return m
end

function PointMass:removeLink(link)
    for i = 1, #self.links do
        if self.links[i] == link then
            table.remove(self.links, i)
        end
    end
end

function PointMass:applyForce(force)
    self.acc = self.acc + force * self.imass
end

function PointMass:subscribeToCollisions(func, instance)
    if instance then
        self.collisionSubcriptions[instance] = func
    else
        table.insert(self.collisionSubcriptions, func)
    end
end

function PointMass:simulateFriction(friction, normal, penetration)
    local pV = self.pos - self.lastPos
    local t = Vector(normal.y, -normal.x)

    local jt = -(t * pV)
    
    local tangentImpulse
    if math.abs(jt) < -penetration * friction then
        tangentImpulse = t * jt
    else
        tangentImpulse = t * (penetration * (jt > 0 and -1 or 1) * friction)
    end
    
    self.lastPos = self.lastPos - tangentImpulse
end

function PointMass:edgeCollide(friction, normal, penetration)
    self:simulateFriction(friction, normal, penetration)        
    --self:applyForce(normal * -penetration * 800)
    for k, v in pairs(self.collisionSubcriptions) do
        if type(k) == "number" then
            v(self,normal, penetration)
        else
            v(k, self, normal, penetration)
        end
    end
end

function PointMass:getX()
    return self.pos.x
end

function PointMass:getY()
    return self.pos.y
end
