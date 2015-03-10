local socket = require "socket"
physics = require "physics"

local tcp
isClient = true
local serverport, serveraddress = 43765, "10.20.1.224" --"192.168.1.63"

local gamestate = "start"
local timeUntilNextConnection = 0
local game

function love.load()

    require "Class"
    require "Vector"
    require "Link"
    require "Joint"
    require "PointMass"
    require "StaticPolygon"
    require "World"
    require "Game"
    require "Player"

    love.graphics.setBackgroundColor(255, 255, 255)
    love.window.setMode(640, 480)
end

function love.update(dt)
    local allData = {}
    local data, err

    if gamestate == "start" then
        if love.mouse.isDown("l") then
            tcp = socket.connect(serveraddress, serverport)
            if tcp then
                gamestate = "waitingForAnotherPlayer"
                tcp:settimeout(0)
                tcp:send( "we are connected\n" )
                love.graphics.setBackgroundColor(200, 255, 200)
            end
        end
        if love.mouse.isDown("r") then
            gamestate = "offlinegame"
            love.graphics.setBackgroundColor(0, 0, 0)
            game = Game(Player(100, 100), Player(300, 100))
        end
    elseif gamestate == "offlinegame" then
        game:update(dt)
    elseif gamestate == "game" then

        timeUntilNextConnection = timeUntilNextConnection + dt
        if timeUntilNextConnection > 1 then
            repeat
                data, err = tcp:receive()
                if data then
                    table.insert(allData, data)
                end
                if err == "closed" then
                    gamestate = "start"
                    love.graphics.setBackgroundColor(255, 255, 255)
                end
            until not data
            game:update(dt)
        end
 
    elseif gamestate == "waitingForAnotherPlayer" then

        timeUntilNextConnection = timeUntilNextConnection + dt
        if timeUntilNextConnection > 0.1 then
            repeat
                data, err = tcp:receive()
                if data then
                    table.insert(allData, data)
                end
                if err == "closed" then
                    gamestate = "start"
                    love.graphics.setBackgroundColor(255, 255, 255)
                end
            until not data
        end
        for _, thisData in ipairs(allData) do
            if thisData == "found another player" then
                gamestate = "game"
                game = Game(Player(100, 100), Player(300, 100))
                love.graphics.setBackgroundColor(0, 0, 0)
            end
            print("thisData: " .. thisData)
        end
        return
    end
end

function love.draw()
    if gamestate == "game" or gamestate == "offlinegame" then
        for _, p in pairs(game.player1.pointmasses) do
            p:draw()
        end
        for _, p in pairs(game.player2.pointmasses) do
            p:draw()
        end
        for _, p in pairs(game:getWorld():getStaticPolygons()) do
            local coords = {}
            for _,v in pairs(p.vertices) do
                table.insert(coords, v.x)
                table.insert(coords, v.y)
            end
            love.graphics.setColor(240,240,240)
            love.graphics.polygon("fill",coords)
        end

    elseif gamestate == "waitingForAnotherPlayer" then
        love.graphics.print("Waiting For Another Player", 200, 200, 0, 7)
    end
end

function love.keypressed(key)
    if key == "q" and gamestate ~= "start" then
        tcp:send("please quit\n")
    end
end

function love.mousepressed(x, y, button)
    if game then
        game:mousepressed(x, y, button)
    end
end

