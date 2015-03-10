Game = Class("Game")

local world = World()
table.insert(world:getStaticPolygons(), StaticPolygon(Vector(200, 200), Vector(500, 200), Vector(500,300), Vector(200, 300)))

function Game:init(player1, player2)
    self.player1 = player1
    self.player2 = player2
    self.grabbed = {}
    self.pointmasses = {}
    for _, v in pairs(self.player1.pointmasses) do
        v:applyForce(Vector(100000, 0))
        table.insert(self.pointmasses, v)
    end
    for _, v in pairs(self.player2.pointmasses) do
        table.insert(self.pointmasses, v)
    end
end

function Game:update(dt)
    
    physics.update(dt, self.pointmasses, world)
        
    if love.mouse.isDown("l") then -- doesn't work in server
        for k, v in pairs(self.grabbed) do 
            k.pos = Vector(love.mouse.getX(), love.mouse.getY()) + v
        end
    else
        self.grabbed = {}
    end
end

function Game:sync(worldUpdate)
    
end

function Game:createWorldUpdate()
    
end
function Game:getWorld() return world end

function Game:mousepressed(x, y, button)
    for _, v in pairs(self.pointmasses) do
        local dx, dy = v.pos.x - x, v.pos.y - y
        
        if dx * dx + dy * dy < 150 then
            self.grabbed[v] = Vector(dx, dy)
        end
    end
end
