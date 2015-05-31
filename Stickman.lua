Stickman = Class("Stickman")

function Stickman:init( x, y )
    local headLength = 30
    
    self.head = PointMass(x, y)
    self.head.size = headLength / 2
    self.head:setMass(4)
    
    self.shoulder = PointMass(x, y + headLength/1.9)
    self.shoulder:setMass(26)
    self.head:attachTo(self.shoulder, headLength/1.9, 1, nil, false)
    
    self.elbowLeft = PointMass(x + 4/5 * headLength, y + 0.88 * headLength)
    self.elbowRight = PointMass(x - 4/5 * headLength, y + 0.88 * headLength)
    self.elbowLeft:setMass(2)
    self.elbowRight:setMass(2)
    self.elbowLeft:attachTo(self.shoulder, headLength*1.1, 1, nil, true)
    self.elbowRight:attachTo(self.shoulder, headLength*1.1, 1, nil, true)
    
    self.handLeft = PointMass(x + 1.5 * headLength, y + 1.6 * headLength)
    self.handRight = PointMass(x - 1.5 * headLength, y + 1.6 * headLength)
    self.handLeft:setMass(2)
    self.handRight:setMass(2)
    self.handLeft:attachTo(self.elbowLeft, headLength*1.0, 1, nil, true)
    self.handRight:attachTo(self.elbowRight, headLength*1.0, 1, nil, true)
    
    self.pelvis = PointMass(x, y + 2 * headLength)
    self.pelvis:setMass(15)
    self.pelvis:attachTo(self.shoulder, 1.5 * headLength, 1, nil, true)
    self.pelvis:attachTo(self.head, headLength/1.9 + 1.5 * headLength, 0.05, nil, false)
    
    self.kneeLeft = PointMass(x + 3/5 * headLength, y + 3.57 * headLength)
    self.kneeRight = PointMass(x - 3/5 * headLength, y + 3.57 * headLength)
    self.kneeLeft:setMass(10)
    self.kneeRight:setMass(10)
    self.kneeLeft:attachTo(self.pelvis, 1.5 * headLength, 1, nil, true)
    self.kneeRight:attachTo(self.pelvis, 1.5 * headLength, 1, nil, true)
    
    self.footLeft = Foot(x + 3/5 * headLength, y + 4.88 * headLength)
    self.footRight = Foot(x - 3/5 * headLength, y + 4.88 * headLength)
    self.footLeft:setMass(5)
    self.footRight:setMass(5)
    self.footLeft:attachTo(self.kneeLeft, 1.5 * headLength, 1, nil, true)
    self.footRight:attachTo(self.kneeRight, 1.5 * headLength, 1, nil, true)
    
    self.pointmasses = {self.head, self.shoulder, self.elbowLeft, self.elbowRight, self.handLeft, self.handRight, self.pelvis, self.kneeLeft, self.kneeRight, self.footLeft, self.footRight}
    
    self.bodyConstraints = {
        self.kneeRight:becomeJoint(self.pelvis, self.footRight, 0.3, math.pi, 1),
        self.kneeLeft:becomeJoint(self.pelvis, self.footLeft, 0.3, math.pi, 1),
    
        self.pelvis:becomeJoint(self.shoulder, self.kneeLeft, math.pi * 0.8, -0.3, 1),
        self.pelvis:becomeJoint(self.shoulder, self.kneeRight, math.pi * 0.8, -0.3, 1),
        self.pelvis:becomeJoint(self.shoulder, self.footLeft, 1, -1, 1),
        self.pelvis:becomeJoint(self.shoulder, self.footRight, 1, -1, 1),
   
        self.shoulder:becomeJoint(self.pelvis, self.elbowLeft, -math.pi*0.4, math.pi, 1),
        self.shoulder:becomeJoint(self.pelvis, self.elbowRight, -math.pi*0.4, math.pi, 1),
    
        self.elbowLeft:becomeJoint(self.shoulder, self.handLeft, -math.pi, -0.1,1),
        self.elbowRight:becomeJoint(self.shoulder, self.handRight, -math.pi, -0.1,1),
    }
end
