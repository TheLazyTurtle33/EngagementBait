local path = ...
local oath_html = io.open(path .. "server/oauth_index.html", "r"):read("*a")
local dashboard_html = io.open(path .. "server/index.html", "r"):read("*a")
local js = io.open(path .. "server/main.js", "r"):read("*a")


local socket = require("socket")

local server = assert(socket.bind("127.0.0.1", 3000))
server:settimeout(60)

while true do
    local client = server:accept()
    if not client then goto continue end

    client:settimeout(1)
    local request = client:receive()

    if not request then
        client:close()
    else

        if request:match("GET /callback") then
            client:send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" .. oath_html)
            client:close()
        elseif request:match("GET /dashboard") then
            client:send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" .. dashboard_html)
            client:close()
        elseif request:match("GET /token") then
            local token = request:match("access_token=([^& ]+)")
            if token then
                love.thread.getChannel("twitch_auth"):push(token)
            end
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
        elseif request:match("GET /chat") then
            local name = request:match("username=([^& ]+)")
            local message = request:match("message=([^& ]+)")
            if name and message then
                love.thread.getChannel("twitch_chat"):push({name = name, message = message})
            end
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            
            client:close()
        elseif request:match("GET /follow") then
            local name = request:match("username=([^& ]+)")
            if name then
                love.thread.getChannel("twitch_follow"):push(name)
            end
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
        elseif request:match("GET /subscribe") then
            local name = request:match("username=([^& ]+)")
            local tier = request:match("tier=([^& ]+)")
            if name and tier then
                love.thread.getChannel("twitch_subscribe"):push({name = name, tier = tier})
            end
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
        elseif request:match("GET /cheer") then
            local name = request:match("username=([^& ]+)")
            local bits = request:match("bits=([^& ]+)")
            if name and bits then
                love.thread.getChannel("twitch_cheer"):push({name = name, bits = bits})
            end
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
        elseif request:match("GET /main.js") then
            client:send("HTTP/1.1 200 OK\r\nContent-Type: application/javascript\r\n\r\n" .. js)
            client:close()
        elseif request:match("GET /ping") then
            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
        elseif request:match("GET /data") then
            
            local ch = love.thread.getChannel("twitch_data")
            -- ch:push("request")
            -- os.sleep(0.1)
            local data = ch:pop() or [[{ "notReady": true }]]
            if data == "request" then
                data = [[{ "notReady": true }]]
            end
            client:send("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n" .. data)
            client:close()
        else
            client:close()
        end
    end
    ::continue::
end

