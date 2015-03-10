Player = Class("Player")

function Player:init( x, y )
    local headLength = 40
    
    self.head = PointMass(x, y)
    self.head.size = headLength / 2
    self.head.mass = 4
    
    self.shoulder = PointMass(x, y + headLength/1.9)
    self.shoulder.mass = 26
    self.head:attachTo(self.shoulder, headLength/1.9, 1, nil, false)
    
    self.elbowLeft = PointMass(x + 4/5 * headLength, y + 0.88 * headLength)
    self.elbowRight = PointMass(x - 4/5 * headLength, y + 0.88 * headLength)
    self.elbowLeft.mass = 2
    self.elbowRight.mass = 2
    self.elbowLeft:attachTo(self.shoulder, headLength*1.1, 1, nil, true)
    self.elbowRight:attachTo(self.shoulder, headLength*1.1, 1, nil, true)
    
    self.handLeft = PointMass(x + 1.5 * headLength, y + 1.6 * headLength)
    self.handRight = PointMass(x - 1.5 * headLength, y + 1.6 * headLength)
    self.handLeft.mass = 2
    self.handRight.mass = 2
    self.handLeft:attachTo(self.elbowLeft, headLength*1.0, 1, nil, true)
    self.handRight:attachTo(self.elbowRight, headLength*1.0, 1, nil, true)
    
    self.pelvis = PointMass(x, y + 2 * headLength)
    self.pelvis.mass = 15
    self.pelvis:attachTo(self.shoulder, 1.5 * headLength, 1, nil, true)
    self.pelvis:attachTo(self.head, headLength/1.9 + 1.5 * headLength, 0.05, nil, false)
    
    self.kneeLeft = PointMass(x + 3/5 * headLength, y + 3.57 * headLength)
    self.kneeRight = PointMass(x - 3/5 * headLength, y + 3.57 * headLength)
    self.kneeLeft.mass = 10
    self.kneeRight.mass = 10
    self.kneeLeft:attachTo(self.pelvis, 1.5 * headLength, 1, nil, true)
    self.kneeRight:attachTo(self.pelvis, 1.5 * headLength, 1, nil, true)
    
    self.footLeft = PointMass(x + 3/5 * headLength, y + 4.88 * headLength)
    self.footRight = PointMass(x - 3/5 * headLength, y + 4.88 * headLength)
    self.footLeft.mass = 5
    self.footRight.mass = 5
    self.footLeft:attachTo(self.kneeLeft, 1.5 * headLength, 1, nil, true)
    self.footRight:attachTo(self.kneeRight, 1.5 * headLength, 1, nil, true)
    
    self.kneeRight:becomeJoint(self.pelvis, self.footRight, 0.3, math.pi, 1)
    self.kneeLeft:becomeJoint(self.pelvis, self.footLeft, 0.3, math.pi, 1)
    
    self.pelvis:becomeJoint(self.shoulder, self.kneeLeft, math.pi * 0.8, -0.3, 1)
    self.pelvis:becomeJoint(self.shoulder, self.kneeRight, math.pi * 0.8, -0.3, 1)
    self.pelvis:becomeJoint(self.shoulder, self.footLeft, 1, -1, 1)
    self.pelvis:becomeJoint(self.shoulder, self.footRight, 1, -1, 1)
    
    self.shoulder:becomeJoint(self.pelvis, self.elbowLeft, -math.pi*0.4, math.pi, 1)
    self.shoulder:becomeJoint(self.pelvis, self.elbowRight, -math.pi*0.4, math.pi, 1)
    
    self.elbowLeft:becomeJoint(self.shoulder, self.handLeft, -math.pi, -0.1,1)
    self.elbowRight:becomeJoint(self.shoulder, self.handRight, -math.pi, -0.1,1)
    
    self.pelvis:becomeJoint(self.shoulder, self.kneeLeft, math.pi * 0.8, math.pi * 0.8, 0.4)
    self.pelvis:becomeJoint(self.shoulder, self.kneeRight, -math.pi * 0.8, -math.pi * 0.8, 0.4)
    
    self.pointmasses = {}
    
    self.pointmasses[1] = self.head
    self.pointmasses[2] = self.shoulder
    self.pointmasses[3] = self.elbowLeft
    self.pointmasses[4] = self.elbowRight
    self.pointmasses[5] = self.handLeft
    self.pointmasses[6] = self.handRight
    self.pointmasses[7] = self.pelvis
    self.pointmasses[8] = self.kneeLeft
    self.pointmasses[9] = self.kneeRight
    self.pointmasses[10] = self.footLeft
    self.pointmasses[11] = self.footRight
end
