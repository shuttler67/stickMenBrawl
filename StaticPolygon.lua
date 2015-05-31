-- TEST 1: Vertex within circle
--
StaticPolygon = Class("StaticPolygon")

--insert Vectors please
function StaticPolygon:init(...)
    self.vertices = {...}
    
    -- normals clockwise
    self.normals = {}
    
    for i = 1, #self.vertices do
        
        local v1 = self.vertices[i]
        local v2 = self.vertices[i + 1 > #self.vertices and 1 or i + 1]

        self.normals[i] = Vector(v2.y - v1.y, v1.x - v2.x):normalise()
    end
    
    self.friction = 0.7
end

function StaticPolygon:setFriction(f)
    self.friction = f
end

function StaticPolygon:solve(pointmass_or_link)
    
    if tostring(pointmass_or_link) == "PointMass" then
        return self:solvePointMass(pointmass_or_link)
    elseif tostring(pointmass_or_link) == "Link" then
        return self:solveLink(pointmass_or_link)
    end
end


function StaticPolygon:solvePointMass(pointmass)
    
    local cRadiusSqr = pointmass.size * pointmass.size
    
    --
    -- check for collision
    --
    
    local penetration
    local faceNormal
    
    for i = 1, #self.vertices do
        
        local c = pointmass.pos - self.vertices[i]
        
        local distance = c * self.normals[i] - pointmass.size
        
        if distance > 0 then
            return
        end
        
        if not penetration or distance > penetration then --distance is negative therefore the bigger the distance the smaller the gap
            penetration = distance
            faceNormal = i
        end
    end
    
    if math.abs(penetration) < 0.001 then return end
    
    --Retrieve edge vertices
    local v1 = self.vertices[faceNormal]
    local v2 = self.vertices[faceNormal + 1 > #self.vertices and 1 or faceNormal + 1]
    
    --Find which Voronoi region of the edge the center of the circle lies within because:
    -- the circle could be intersecting a corner.
    
    local c1 = pointmass.pos - v1
    local c2 = pointmass.pos - v2
    local dot1 = c1 * (v2 - v1)
    local dot2 = c2 * (v1 - v2)
    
    --
    -- Resolve Collision
    --
    
    local normal
    
    -- Determine normal based on which voronoi region circle is in
    
    if dot1 <= 0 then -- region nearest v1
        if c1:LengthSqr() > cRadiusSqr then
            return
        end
        
        normal = c1:normalised()
        
    elseif dot2 <= 0 then -- region nearest v2
        if c2:LengthSqr() > cRadiusSqr then
            return
        end
        normal = c2:normalised()
        
    else -- region nearest face
        normal = self.normals[faceNormal]
    end
    
    -- Correct based on normal
    
    local correction = normal * -penetration
    
    pointmass.pos = pointmass.pos + correction
    
    pointmass:simulateFriction( self.friction, normal, penetration)
    --pointmass:applyForce(normal * -penetration * 800)
    
    return normal, penetration
end

local function lineCheck(q, s, p, r)
    local v = q - p
    local cr = r % s -- cross product
    
    local t = (v % r)/ cr
    local u = (v % s)/ cr
    
    if cr == 0 then
        return false
    else
        if t < 0 or t > 1 or u < 0 or u > 1 then
            return false
        end
    end
    return q + s * u
end

function StaticPolygon:solveLink(link)
    
    local returnValue
    
    local q = Vector(link.p1.pos)
    local s = link.p2.pos - q
    q = q - s * 0.02 --make it slightly longer so as to stop jittering
    s = s *1.04
    --local dist = 
    local linkNormal = s:normalised()

    linkNormal:set(-linkNormal.y, linkNormal.x)
    
    q = q + linkNormal * link:getSize()
    
    for j = 1, 2 do
        
        if j == 2 then
            q = q + (-2 * linkNormal * link:getSize())
        end
        
        local contacts = 0
        local bestProjection1 = -math.huge
        local bestVertex1
        local bestProjection2 = -math.huge
        local bestVertex2

        for i = 1, #self.vertices do
            
            local p = self.vertices[i]
            local r = self.vertices[i + 1 > #self.vertices and 1 or i + 1] - p

            local contact = lineCheck(q, s, p, r)
            if contact then
                contacts = contacts + 1
                
                local projection1 = linkNormal * (p - contact)
            
                if projection1 > bestProjection1 then
                    bestVertex1 = p
                    bestProjection1 = projection1
                end
                
                local projection2 = -projection1
            
                if projection2 > bestProjection2 then
                    bestVertex2 = p
                    bestProjection2 = projection2
                end
            end
        end
        
        if contacts == 2 then 
            
            local bestVertex = bestProjection1 < bestProjection2 and bestVertex1 or bestVertex2
            
            local qToBestVertex = bestVertex - q
            local ratio1 = (s - qToBestVertex) * s
            local ratio2 = qToBestVertex * s
            local t = ratio1 + ratio2
            
            ratio1 = ratio1 / t
            ratio2 = ratio2 / t
            
            local penetration = linkNormal * qToBestVertex
            if math.abs(penetration) < 0.001 or ratio1 + ratio2 > 1 then return end
            local d = (linkNormal * penetration)
            
            link.p1.pos = link.p1.pos + d * ratio1
            link.p2.pos = link.p2.pos + d * ratio2
            
            link.p1:simulateFriction( self.friction, linkNormal, penetration * ratio1)
            link.p2:simulateFriction( self.friction, linkNormal, penetration * ratio2)
                    
            --link.p1:applyForce(linkNormal * -penetration * 800 )
            --link.p2:applyForce(linkNormal * -penetration * 800 )
            
            return linkNormal, penetration
        end
    end
end
