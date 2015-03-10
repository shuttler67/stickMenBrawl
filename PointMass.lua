PointMass = Class("PointMass")

function PointMass:init(xPos, yPos)
    self.links = {}
    self.joints = {}

    self.pos = Vector(xPos, yPos)
    
    self.mass = 1
    self.size = 5

    self.lastPos = Vector(xPos, yPos)

    self.acc = Vector(0,0)
    
    self.collisionSubcriptions = {}
end

function PointMass:updatePhysics(timeStep, gravity, damping)

    self:applyForce(Vector(0, self.mass * gravity))

    local vel = self.pos - self.lastPos

    vel = vel * damping

    local timeStepSq = timeStep * timeStep

    local nextPos = self.pos + vel + 0.5 * self.acc * timeStepSq

    self.lastPos = self.pos

    self.pos = nextPos

    self.acc:set(0,0)
end

function PointMass:draw()
    love.graphics.setColor(255, 255, 255)
    for _,l in pairs(self.links) do
        l:draw()
    end

    love.graphics.setLineWidth(7)
    love.graphics.circle("line", self.pos.x, self.pos.y, self.size - 3.5, 100)
end

function PointMass:solveConstraints( world )

    local collided = false

    for _,p in pairs(world:getStaticPolygons()) do
        local normal, penetration = p:solve(self)
        if normal then
            for k, v in pairs(self.collisionSubcriptions) do
                if type(k) == "number" then
                    v(normal, penetration)
                else
                    v(k, normal, penetration)
                end
            end
        end

        for _,l in pairs(self.links) do
            p:solve(l)
        end
    end

    for _,l in pairs(self.links) do
        l:solve()
    end
    
    for _,j in pairs(self.joints) do
        j:solve()
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
end

function PointMass:attachTo(pointmass, restingDist, stiff, tearSensitivity, drawLink)
    table.insert(self.links, Link(self, pointmass, restingDist, stiff, tearSensitivity , drawLink ~= false))
end

function PointMass:becomeJoint(p1, p2, minAngle, maxAngle, stiffness)
    table.insert(self.joints, Joint(p1, self, p2, minAngle, maxAngle, stiffness))
end

function PointMass:removeLink(link)
    for i = 1, #self.links do
        if self.links[i] == link then
            table.remove(self.links, i)
        end
    end
end

function PointMass:applyForce(force)
    self.acc = self.acc + force/self.mass
end

function PointMass:subscribeToCollisions(func, instance)
    if instance then
        self.collisionSubcriptions[instance] = func
    else
        table.insert(self.collisionSubcriptions, func)
    end
end

function PointMass:edgeCollide(friction, normal, penetration)
    physics.simulateFriction(self, friction, normal, penetration)        
        
    for k, v in pairs(self.collisionSubcriptions) do
        if type(k) == "number" then
            v(normal, penetration)
        else
            v(k, normal, penetration)
        end
    end
end
