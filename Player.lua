Player = Class("Player", Stickman)

local shouldermass =26
function Player:init(x, y)
    self.super:init(x, y)
    
    self.thighMuscleLeft = self.pelvis:becomeMuscle(self.shoulder, self.kneeLeft, math.pi , 0.3)
    self.thighMuscleRight = self.pelvis:becomeMuscle(self.shoulder, self.kneeRight, -math.pi , 0.3)
    
    self.legMuscleRight = self.kneeRight:becomeMuscle(self.pelvis, self.footRight, math.pi *0.9 , 0.6)
    self.legMuscleLeft = self.kneeLeft:becomeMuscle(self.pelvis, self.footLeft, math.pi *0.9, 0.6)
    
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
    
    self.disabled = 0
end

function Player:update()
    
    if self.footRight:checkOnGround() or self.footLeft:checkOnGround() then self.canwalk = true end
    self:walk()
    if self.footLeft.onGround or self.footRight.onGround then
        self.balance:doGyroScopicAction()

    end

    --local anchor = self.footLeft:getX() + (self.footRight:getX() - self.footLeft:getX())/ 2
    --if self.facingLeft and love.mouse.getX() > anchor then
    --    self:flip(anchor)
    --    self.facingLeft = false
    --elseif not self.facingLeft and love.mouse.getX() < anchor then
    --    self:flip(anchor)
    --    self.facingLeft = true
    --end
    
    self.footRight:decreaseFootFever()
    self.footLeft:decreaseFootFever()
end

function Player:walk()
    
    local f, condition
    if love.keyboard.isDown("a") then
        condition = self.footLeft:getX() > self.footRight:getX()
        if not self.facingLeft then
            self:flip()
            self.facingLeft = true
        end
    elseif love.keyboard.isDown("d") then
        condition = self.footLeft:getX() < self.footRight:getX()
        if self.facingLeft then
            self:flip()
            self.facingLeft = false
        end
    else 
        return
    end

    if self.footLeft.onGround and self.footRight.onGround and self.canwalk then
            
        f = condition and self.footLeft or self.footRight
        local kick = math.abs(self.footRight:getX() - self.footLeft:getX())/10 +5
        if love.keyboard.isDown("d") then
            kick = -kick
        end
        
        f.lastPos = f.lastPos + Vector(kick,3)
        self.canwalk = false
    end
end

function Player:doFootFever(f, normal, penetration)
    --if normal.y > 0 then return end
    f:callFootFever()

    --b.pos:rotateAround(f.pos, -diff* b.imass)-- * imB / imTotal)
end

function Player:flip()
    for _,v in pairs(self.bodyConstraints) do
        v:negateAngle()
    end
    --self.thighMuscleLeft:negateAngle()
    --self.thighMuscleRight:negateAngle()
    self.legMuscleLeft:negateAngle()
    self.legMuscleRight:negateAngle()
    
    --for _,v in pairs(self.pointmasses) do
    --    v:getX() = v:getX() - (v:getX() - anchor)
    --    v.lastPos.x = v.lastPos.x - (v.lastPos.x - anchor)
    --end
end

