local socket = require "socket"
physics = require "physics"
require "Class"
require "Vector"
require "Link"
require "PointMass"
require "StaticPolygon"
require "World"
require "Game"
require "Player"

isClient = false

local clientList = {}
local clientBuffer = {}

local lastTime = os.clock()
local time = 0
local timeUntilLoop = 0

local function getIP()
    local s = socket.udp()
    s:setpeername( "74.125.115.104", 80 )
    local ip, sock = s:getsockname()
    print( "myIP:", ip, sock )
    return ip
end

local tcp = socket.bind(getIP(), 43765)
tcp:settimeout(0)

local running = true
while running do
    repeat
        local client = tcp:accept()  --allow a new client to connect
        if client then
            print( "found client", client:getpeername() )
            client:settimeout( 0 )  --just check the socket and keep going
            --TO DO: implement a way to check to see if the client has connected previously
            --consider assigning the client a session ID and use it on reconnect.
            clientList[#clientList+1] = client
            clientBuffer[client] = { "hello_client\n" }  --just including something to send below
        end
    until #clientList == 2

    for _,client in pairs(clientList) do
        client:settimeout(30)
        local data, err = client:send("found another player\n")
        client:settimeout( 0 )
    end

    local game = Game(Player(100, 100), Player(300, 100))

    local gameRunning = true
    while gameRunning do
        time = os.clock()
        local dt = time - lastTime
        lastTime = time

        timeUntilLoop = timeUntilLoop + dt
        
        if timeUntilLoop >= 0.1 then
            timeUntilLoop = 0

            local ready, writeReady, err = socket.select( clientList, clientList, 0 )
            if err == nil then
                for i = 1, #ready do  --list of clients who are available
                    local client = ready[i]
                    local allData = {}  --this holds all lines from a given client

                    repeat
                        local data, err = client:receive()  --get a line of data from the client, if any
                        if data then
                            allData[#allData+1] = data
                        end
                        if err == "closed" then
                            gameRunning = false
                            for k, c in pairs(clientList) do
                                if client == c then
                                    table.remove(clientList, k)
                                end
                            end
                        end
                    until not data

                    if ( #allData > 0 ) then  --figure out what the client said to the server
                        for i, thisData in ipairs( allData ) do
                            print( "thisData: ", thisData )
                            if thisData == "please quit" and client:getpeername() == getIP() then
                                running = false
                                gameRunning = false
                            end
                        end
                    end
                end

                for client, buffer in pairs( clientBuffer ) do
                    for _, msg in pairs( buffer ) do  --might be empty
                        local data, err = client:send( msg )  --send the message to the client
                        if err == "closed" then
                            gameRunning = false
                            for k, c in pairs(clientList) do
                                if client == c then
                                    table.remove(clientList, k)
                                end
                            end
                        end
                    end
                    clientBuffer[client] = nil
                end
            end
        end
        
        game:update(dt)
        
    end
    game = nil
end

tcp:close()
for i, v in pairs( clientList ) do
    v:close()
end