local https = require("SMODS.https")
local json = require("json")


Twitch = {
    token = "", -- privete token of user
    client_id = "tztqbknddp0rfm2wmfkjvckjc4in5j", -- public client id
    channel = nil, -- channel name of user
    user_id = -1, -- channel if of user
    server = nil,
    startTime = nil,
    Events = {},

    --- posts datas to an endpoint.
    --- @param endpoint string The endpoint to request.
    --- @param data string The json formated body.
    --- @param callback function The callback function to call when the request is completed.
    post = function (endpoint, data, callback)
        local headers = {
        	["Client-ID"] = Twitch.client_id,
    		["Authorization"] = "Bearer " .. Twitch.token,
            ["Content-Type"] = "application/json"
    	}
        https.asyncRequest(
            "https://api.twitch.tv/helix/" .. endpoint,
            {
                method = "POST",
                headers = headers,
                data = data
            },
            callback
        )
    end,

    
    --- posts datas to an endpoint.
    --- @param endpoint string The endpoint to request.
    --- @param callback function The callback function to call when the request is completed.
    request = function (endpoint, callback)
        local headers = {
        	["Client-ID"] = Twitch.client_id,
    		["Authorization"] = "Bearer " .. Twitch.token,
    	}
        https.asyncRequest(
            "https://api.twitch.tv/helix/" .. endpoint,
            {
                method = "GET",
                headers = headers,
            },
            callback
        )
    end,


    -- starts the server
    startServer = function ()
        if Twitch.get_server() then
            print("Twitch server already running.")
            return
        end
        print("Starting Twitch server...")
        local server_code = io.open(EngagementBait.mod.path .. "server/server.lua", "r"):read("*a")
        Twitch.server = love.thread.newThread("TwitchServer", server_code)
        Twitch.server:start(EngagementBait.mod.path)
        Twitch.sendData()
    end,

    --- tries to return the server and find it if its not correctly loaded
    ---@diagnostic disable-next-line: undefined-doc-name
    --- @return Thread | nil
    get_server = function ()
        if not Twitch.server then
            Twitch.server = love.thread.getThread("TwitchServer")
        end
        return Twitch.server
    end,

    sendData = function ()
        if not Twitch.get_server() then
            print("Twitch server not found.")
            return
        end
        local data = {notLinked = true}
        if EngagementBait.mod.config.linked then
            data = {
                channel = Twitch.channel,
                user_id = Twitch.user_id,
                access_token = Twitch.token,
                notReady = false,
            }
        end
        love.thread.getChannel("twitch_data"):push(json.encode(data))
    end,




    load = function ()
        if EngagementBait.mod.config.linked and EngagementBait.mod.config.oauth and EngagementBait.mod.config.username and EngagementBait.mod.config.id then
            Twitch.token = EngagementBait.mod.config.oauth
            Twitch.channel = EngagementBait.mod.config.username
            Twitch.user_id = EngagementBait.mod.config.id
            print("Twitch token loaded from config.")
        else
            print("No Twitch token found in config.")
        end
    end,

    get_user_name_and_id = function ()
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
            return {"no one :c", -1}
        end
        
        local data = json.decode(body)

        if data and data.data and data.data[1] then
            local user = data.data[1]
            print("Twitch linked as:", user.display_name)
            return {user.display_name, user.id}
        else
            print("Failed to parse Twitch response.")
            return {"no one :c", -1}
        end
    end,

    set_start_time = function ()
        if EngagementBait.mod.config and EngagementBait.mod.config.id then
        Twitch.request("streams?user_id=" .. EngagementBait.mod.config.id, 
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to fetch Stream Info. Code:", code)
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
        )
        end
    end,

    --- gets the duration of the stream
    --- @return number - duration in seconds
    get_stream_duration = function ()
        if not Twitch.startTime then
            Twitch.set_start_time()
            if not Twitch.startTime then return 0 end
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
        return  os.difftime(os.time(os.date("!*t")), start_time)
        -- return 0
    end,

    --- sets the viewer count 
    set_viewer_count = function ()
        Twitch.request("streams?user_id=" .. EngagementBait.mod.config.id,
            function (code, body, headers)
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
        )
    end,

    --- Checks if a name is a bot
    --- @param name string
    --- @return boolean
    is_bot = function (name)
        local bots = {
            "moobot",
            "sery_bot",
            "streamelements",
            "nightbot",
            "fossabot",
            "streamlabs",
            "wizebot",
            "kofistreambot",
            "tangiabot",
            "own3d",
            "creatisbot",
            "botrixoficial",
            "frostytoolsdotcom",
            "kalyue",
            "djsoupandsalad",
            "thelazybot33",
        }
        
        for _, bot in ipairs(bots) do
            if name == bot then
                return true
            end
        end
        return false
    end

}




function G.FUNCS.EngagementBaitTwitchRestartServer ()
    if Twitch.get_server() then
        print("Killing Twitch server...")
        Twitch.server:release()
    end
    Twitch.startServer()
end

function G.FUNCS.EngagementBaitLinkOpenDashboard ()
    if not Twitch.get_server() then
        Twitch.startServer()
    end
    Twitch.sendData()
    love.system.openURL("http://localhost:3000/dashboard")
end

function G.FUNCS.EngagementBaitLinkAccount(e)
    local REDIRECT_URI = "http://localhost:3000/callback"

    local auth_url =
        "https://id.twitch.tv/oauth2/authorize" ..
        "?response_type=token" ..
        "&client_id=" .. Twitch.client_id ..
        "&redirect_uri=" .. REDIRECT_URI ..
        "&scope=chat:read+chat:edit+moderator:read:followers+channel:read:subscriptions+bits:read+channel:manage:polls"

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
            local user_info = Twitch.get_user_name_and_id()
            EngagementBait.mod.config.username = user_info[1]
            EngagementBait.mod.config.id = user_info[2]
            Twitch.channel = user_info[1]
            Twitch.user_id = user_info[2]
            Twitch.sendData()
            print("Twitch OAuth token received and saved.")
            print("Twitch linked successfully!")
            return true
        end
        love.timer.sleep(0.1)
    end

    print("Twitch linking timed out.")
    return false
end


