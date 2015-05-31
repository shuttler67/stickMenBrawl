Player = Class("Player", Stickman)

local shouldermass =26
function Player:init(x, y)
    self.super:init(x, y)
    
    self.thighMuscleLeft = self.pelvis:becomeMuscle(self.shoulder, self.kneeLeft, math.pi * 0.7, 0)
    self.thighMuscleRight = self.pelvis:becomeMuscle(self.shoulder, self.kneeRight, -math.pi * 0.7, 0)
    
    self.legMuscleRight = self.kneeRight:becomeMuscle(self.pelvis, self.footRight, math.pi *0.7 , 0.8)
    self.legMuscleLeft = self.kneeLeft:becomeMuscle(self.pelvis, self.footLeft, math.pi *0.7, 0.8)
    
    --self.bicepsANDtricepsLeft = self.elbowLeft:becomeMuscle(self.shoulder, self.handLeft, -0.8, 0.7)
    --self.bicepsANDtricepsRight = self.elbowLeft:becomeMuscle(self.shoulder, self.handRight, -1, 0.7)
    
    --self.armMuscleLeft = self.shoulder:becomeMuscle(self.pelvis, self.elbowLeft, 0.3 ,0.7)
    --self.armMuscleRight = self.shoulder:becomeMuscle(self.pelvis, self.elbowRight, 1.3 ,0.7)
    
    self.balance = Gyroscope(0, self.pelvis, self.shoulder)
    self.footLeft:subscribeToCollisions(self.doFootFever, self)
    self.footRight:subscribeToCollisions(self.doFootFever, self)
    self.footmina = 3
    self.footmaxa = -3
    self.thigh = (math.pi * 1.4) / 60
    
    self.footLeft:addMuscles(self.thighMuscleLeft, self.legMuscleLeft)
    self.footRight:addMuscles(self.thighMuscleRight, self.legMuscleRight)
    
    self.canwalk = true
    self.facingLeft = true
end

function Player:update()
    
    if self.footRight:checkOnGround() or self.footLeft:checkOnGround() then self.canwalk = true end
    
    if self.footLeft.onGround or self.footRight.onGround then
        self.balance:doGyroScopicAction()
    end
    
    if love.keyboard.isDown("a") then
        if self.footLeft.onGround and self.footRight.onGround and self.canwalk then
            local f = self.footLeft.pos.x > self.footRight.pos.x and self.footLeft or self.footRight
            f.lastPos = f.lastPos + Vector(7,3)
            self.canwalk = false
        end
    elseif love.keyboard.isDown("d") then
        if self.footLeft.onGround and self.footRight.onGround and self.canwalk then
            local f = self.footLeft.pos.x < self.footRight.pos.x and self.footLeft or self.footRight
            f.lastPos = f.lastPos + Vector(-7,3)
            self.canwalk = false
        end
    end
    
    local anchor = self.footLeft.pos.x + (self.footRight.pos.x - self.footLeft.pos.x)/ 2
    if self.facingLeft and love.mouse.getX() > anchor then
        self:flip(anchor)
        self.facingLeft = false
    elseif not self.facingLeft and love.mouse.getX() < anchor then
        self:flip(anchor)
        self.facingLeft = true
    end
    
    self.footRight:decreaseFootFever()
    self.footLeft:decreaseFootFever()
end

function Player:doFootFever(f, normal, penetration)
    if normal.y > 0 then return end
    f:callFootFever()
    
    local b = f.links[1].p2
    local vec1 = f.pos - b.pos
    
    local angle = math.atan2(normal % vec1, normal * vec1) --"%" = cross product
    
    if self.footmina > self.footmaxa then
        if angle <= self.footmaxa or angle >= self.footmina then return end
    else
        if angle <= self.footmaxa and angle >= self.footmina then return end
    end
    
    local diff1 = angle - self.footmina
    
    if diff1 <= -math.pi then
        diff1 = diff1 + 2 * math.pi
    elseif diff1 >= math.pi then
        diff1 = diff1 - 2 * math.pi
    end
    
    local diff2 = angle - self.footmaxa
        
    if diff2 <= -math.pi then
        diff2 = diff2 + 2 * math.pi
    elseif diff2 >= math.pi then
        diff2 = diff2 - 2 * math.pi
    end
    
    local diff = math.abs(diff1) < math.abs(diff2) and diff1 or diff2

    diff = (diff /physics.getDeltaTime())

    --b.pos:rotateAround(f.pos, -diff* b.imass)-- * imB / imTotal)
end

function Player:flip(anchor)
    for _,v in pairs(self.bodyConstraints) do
        v:negateAngle()
    end
    self.thighMuscleLeft:negateAngle()
    self.thighMuscleRight:negateAngle()
    self.legMuscleLeft:negateAngle()
    self.legMuscleRight:negateAngle()
    
    --for _,v in pairs(self.pointmasses) do
    --    v.pos.x = v.pos.x - (v.pos.x - anchor)
    --    v.lastPos.x = v.lastPos.x - (v.lastPos.x - anchor)
    --end
end

