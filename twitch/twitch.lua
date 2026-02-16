
local https = require("SMODS.https")

local json = require("json")

if not Twitch then
    --@class
    Twitch = {}
    Twitch.token = "";
    Twitch.client_id = "tztqbknddp0rfm2wmfkjvckjc4in5j"
end



server_code = [[
local html = ...
local socket = require("socket")

local server = assert(socket.bind("127.0.0.1", 3000))
server:settimeout(60)

while true do
    local client = server:accept()
    if not client then break end

    client:settimeout(1)
    local request = client:receive()

    if not request then
        client:close()
    else

        -- STEP 1: User lands on /callback
        if request:match("GET /callback") then

            

            client:send(html)
            client:close()

        -- STEP 2: JS sends token to /token
        elseif request:match("GET /token") then

            local token = request:match("access_token=([^& ]+)")

            if token then
                love.thread.getChannel("twitch_auth"):push(token)
            end

            client:send("HTTP/1.1 200 OK\r\n\r\nOK")
            client:close()
            break
        else
            client:close()
        end
    end
end

server:close()
]]

local html = [[
HTTP/1.1 200 OK
Content-Type: text/html

<html>
<body>
<h2>Linking Twitch...</h2>
<script>
const hash = window.location.hash;
const params = new URLSearchParams(hash.substring(1));
const token = params.get("access_token");
if(token){
    fetch("http://localhost:3000/token?access_token=" + token);
    document.body.innerHTML = "<h2>Success! You can close this window.</h2>";
} else {
    document.body.innerHTML = "<h2>No token received.</h2>";
}
</script>
</body>
</html>
]]


function G.FUNCS.EngagementBaitLinkAccount(e)
    local REDIRECT_URI = "http://localhost:3000/callback"

    local auth_url =
        "https://id.twitch.tv/oauth2/authorize" ..
        "?response_type=token" ..
        "&client_id=" .. Twitch.client_id ..
        "&redirect_uri=" .. REDIRECT_URI ..
        "&scope=user:read:email"

    local server = love.thread.newThread(server_code)
    server:start(html)

    love.system.openURL(auth_url)

    local ch = love.thread.getChannel("twitch_auth")
    local timeout = 60
    local start = love.timer.getTime()

    while love.timer.getTime() - start < timeout do
        local token = ch:pop()
        if token then
            Twitch.token = token
            EngagementBait.mod.config.oauth = token
            EngagementBait.mod.config.linked = true
            EngagementBait.mod.config.username = Twitch.get_user_name_and_id()[1]
            EngagementBait.mod.config.id = Twitch.get_user_name_and_id()[2]
            -- NFS.write(EngagementBait.mod.path .. "/config.lua", STR_PACK(EngagementBait.mod.config))
            print("Twitch OAuth token received and saved.")
            print("Twitch linked successfully!")
            server:release()
            return true
        end
        love.timer.sleep(0.1)
    end

    print("Twitch linking timed out.")
    server:release()
    return false
end


Twitch.load = function ()
    if EngagementBait.mod.config.linked and EngagementBait.mod.config.oauth then
        Twitch.token = EngagementBait.mod.config.oauth
        print("Twitch token loaded from config.")
    else
        print("No Twitch token found in config.")
    end
end



Twitch.get_user_name_and_id = function ()

	local headers = {
    	["Client-ID"] = Twitch.client_id,
   		["Authorization"] = "Bearer " .. Twitch.token
	}
    local code, body = https.request(
        "https://api.twitch.tv/helix/users",
        {
            method = "GET",
            headers = headers
        }
    )

    if code ~= 200 then
        print("Failed to fetch Twitch user. Code:", code)
        return
    end
	

    local data = json.decode(body)

    if data and data.data and data.data[1] then
        local user = data.data[1]
        
        print("Twitch linked as:", user.display_name)
        return {user.display_name, user.id}
    else
        print("Failed to parse Twitch response.")
        return {"no one :c", nil}
    end
end

Twitch.get_viewer_count = function ()

    local headers = {
    	["Client-ID"] = Twitch.client_id,
   		["Authorization"] = "Bearer " .. Twitch.token
	}

    https.asyncRequest(
        "https://api.twitch.tv/helix/streams?user_id=" .. EngagementBait.mod.config.id,
        {
            method = "GET",
            headers = headers
        },
        Twitch.set_global_viewers
    )

end


Twitch.set_global_viewers = function (code, body, headers)
     if code ~= 200 then
        print("Failed to fetch Stream Info. Code:", code)
        return
    end


    local data = json.decode(body)

    if data and data.data and data.data[1] then
        local streams = data.data[1]

        Twitch.viewers = streams.viewer_count
    else
        print("Failed to parse Twitch response.")
        Twitch.viewers = 0
    end
end


Twitch.startTime = nil
Twitch.set_start_time = function ()
    
	local headers = {
    	["Client-ID"] = Twitch.client_id,
   		["Authorization"] = "Bearer " .. Twitch.token
	}
    local code, body = https.request(
        "https://api.twitch.tv/helix/streams?user_id=" .. EngagementBait.mod.config.id,
        {
            method = "GET",
            headers = headers
        }
    )

    if code ~= 200 then
        print("Failed to fetch Twitch user. Code:", code)
        return
    end
    local data = json.decode(body)

    if data and data.data and data.data[1] then
        local stream = data.data[1]
        
        print("Twitch stream started at:", stream.started_at)
        Twitch.startTime = stream.started_at
    else
        print("Failed to parse Twitch response.")
        Twitch.startTime = nil
    end
end

Twitch.get_follower_count = function ()
    return 0
end

Twitch.get_subscriber_count = function ()
    return 0
end

Twitch.get_gifter_count = function ()
    return 0
end

Twitch.get_stream_duration = function ()
	if Twitch.startTime == nil then
        Twitch.set_start_time()
        if Twitch.startTime == nil then return 0 end
    end

    local y, m, d, h, min, s = Twitch.startTime:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")

    local timeTable = {
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(h),
        min = tonumber(min),
        sec = tonumber(s)
    }

    local start_time = os.time(timeTable)
    return  os.difftime(os.time(os.date("!*t")), start_time) /60
    -- return 0
end

Twitch.start_poll = function (question, options, duration)
    return nil
end

Twitch.stop_and_get_poll_result = function (poll_id)
    return nil
end



