
local physics = {}

local fixedDeltaTime = 16
local fixedDeltaTimeSeconds = fixedDeltaTime / 1000

local leftOverDeltaTime = 0

local constraintAccuracy = 10

physics.gravity = 2000
physics.damping = 0.99

function physics.update( dt, pointmasses, world )

    local timeStepAmt = (dt*1000 + leftOverDeltaTime) / fixedDeltaTime

    timeStepAmt = math.min(timeStepAmt, 5)

    leftOverDeltaTime = dt*1000 - (timeStepAmt * fixedDeltaTime)
    
    for iteration = 1, math.floor(timeStepAmt) do
        for i = 1, constraintAccuracy do
            for _, pointmass in pairs(pointmasses) do
                pointmass:solveConstraints(world)
            end
        end

        for _, pointmass in pairs(pointmasses) do
            pointmass:updatePhysics(fixedDeltaTimeSeconds, physics.gravity, physics.damping)
        end
    end
end

function physics.simulateFriction(pointmass, friction, normal, penetration)

    local pV = pointmass.pos - pointmass.lastPos
    local t = Vector(normal.y, -normal.x)

    local jt = -(t * pV)
    
    local tangentImpulse
    if math.abs(jt) < -penetration * friction then
        tangentImpulse = t * jt
    else
        tangentImpulse = t * (penetration * (jt > 0 and -1 or 1) * friction)
    end
    
    pointmass.lastPos = pointmass.lastPos - tangentImpulse
end

function physics.getDeltaTime() return fixedDeltaTime end

return physics