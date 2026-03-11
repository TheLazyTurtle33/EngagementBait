local path = ...
local oath_html = io.open(path .. "server/oauth_index.html", "r"):read("*a")
local dashboard_html = io.open(path .. "server/index.html", "r"):read("*a")
local js = io.open(path .. "server/main.js", "r"):read("*a")


local socket = require("socket")

local server = assert(socket.bind("127.0.0.1", 3000))
server:settimeout(60)

while true do
    local alive_request = love.thread.getChannel("alive"):peek()
    if alive_request == "ping" then
        love.thread.getChannel("alive"):clear()
        love.thread.getChannel("alive"):push("alive")
    end
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
            local time = os.time()
            if name and message then
                love.thread.getChannel("twitch_chat"):push({name = name, message = message, time = time})
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
        elseif request:match("PUT /poll_end") then
            -- read headers until blank line, logging them
            local headers = {}
            while true do
                local line = client:receive()
                if not line or line == "" then break end
                table.insert(headers, line)
            end
            if #headers > 0 then
                print("[server] /poll_end headers:")
                for _, h in ipairs(headers) do print("[server]  ", h) end
            end

            -- detect transfer encoding
            local isChunked = false
            for _, h in ipairs(headers) do
                if h:lower():match("transfer%-encoding:%s*chunked") then
                    isChunked = true
                    break
                end
            end

            local content = ""
            if isChunked then
                -- parse chunked body
                while true do
                    local lenLine = client:receive("*l")
                    if not lenLine then break end
                    local len = tonumber(lenLine, 16)
                    if not len or len == 0 then
                        -- consume trailing CRLF if present
                        client:receive(2)
                        break
                    end
                    -- accumulate chunk, retry if partial
                    while #content < len do
                        local part = client:receive(len - #content)
                        if not part then
                            socket.sleep(0.01)
                        else
                            content = content .. part
                        end
                    end
                    -- skip CRLF after chunk
                    client:receive(2)
                end
            else
                -- try content-length first
                local length = 0
                for _, h in ipairs(headers) do
                    local k,v = h:match("([^:]+):%s*(.*)")
                    if k and k:lower() == "content-length" then
                        length = tonumber(v) or 0
                        break
                    end
                end
                if length > 0 then
                    -- loop until full content received
                    while #content < length do
                        local part = client:receive(length - #content)
                        if not part then
                            socket.sleep(0.01)
                        else
                            content = content .. part
                        end
                    end
                else
                    -- read until timeout by grabbing chunks
                    while true do
                        local chunk = client:receive(1024)
                        if not chunk then break end
                        content = content .. chunk
                    end
                end
            end

            if content == "" then
                print("[server] /poll_end received empty body")
            else
                print("[server] /poll_end body:", content)
                love.thread.getChannel("twitch_poll"):push(content)
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

