Foot = Class("Foot",PointMass)

function Foot:init(x, y)
    self.super:init(x, y)
    self.onGround = false
    self.calledFootFever = 2
    self.muscles = {}
end

function Foot:addMuscles(...)
    for _,v in pairs({...}) do
        table.insert(self.muscles, v)
    end
end

function Foot:callFootFever()
    self.calledFootFever = 2
    if not self.onGround then
        self.onGround = true
        self:setMass(0)
        for _,m in pairs(self.muscles) do
            m:enable()
        end
    end
end

function Foot:decreaseFootFever()
    self.calledFootFever = self.calledFootFever -1
end

function Foot:checkOnGround()
    if (self.calledFootFever <= 0) and self.onGround then
        self.onGround = false
        self:setMass(5)
        for _,m in pairs(self.muscles) do
            m:disable()
        end
        return true
    end
    return false
end
