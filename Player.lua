Player = Class("Player", Stickman)

local shouldermass =26
function Player:init(x, y)
    self.super:init(x, y)
    
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
    
    self.footLeft:addMuscles( self.legMuscleLeft)
    self.footRight:addMuscles(self.legMuscleRight)
    
    self.canwalk = true
    self.facingLeft = true
end

function Player:update()
    
    if self.footRight:checkOnGround() or self.footLeft:checkOnGround() then self.canwalk = true end
    
    if self.footLeft.onGround or self.footRight.onGround then
        self.balance:doGyroScopicAction()

    end
    
    if self.footLeft.onGround and self.footRight.onGround and self.canwalk then
        if love.keyboard.isDown("a") then
            
            local f1, f2 = self.footLeft, self.footRight
            if self.footLeft:getX() < self.footRight:getX() then 
                f1, f2 = f2, f1
            end
            f1.lastPos = f1.lastPos + Vector(5 + math.abs(f2:getX() - f1:getX()) / 10,1)
            self.canwalk = false
        elseif love.keyboard.isDown("d") then
            
            local f1, f2 = self.footLeft, self.footRight
            if self.footLeft:getX() > self.footRight:getX() then 
                f1, f2 = f2, f1
            end
            f1.lastPos = f1.lastPos + Vector(-5 - math.abs(f2:getX() - f1:getX()) / 10,1)
            self.canwalk = false
        end
    end
    
    local anchor = self.footLeft:getX() + (self.footRight:getX() - self.footLeft:getX())/ 2
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

    --b.pos:rotateAround(f.pos, -diff* b.imass)-- * imB / imTotal)
end

function Player:flip(anchor)
    for _,v in pairs(self.bodyConstraints) do
        v:negateAngle()
    end
    self.legMuscleLeft:negateAngle()
    self.legMuscleRight:negateAngle()
    
    --for _,v in pairs(self.pointmasses) do
    --    v:getX() = v:getX() - (v:getX() - anchor)
    --    v.lastPos.x = v.lastPos.x - (v.lastPos.x - anchor)
    --end
end

