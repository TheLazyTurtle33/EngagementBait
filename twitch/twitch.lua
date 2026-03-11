local https = require("SMODS.https")

local json = require("json")

if not Twitch then
    --@class
    Twitch = {}
    Twitch.token = "";
    Twitch.client_id = "tztqbknddp0rfm2wmfkjvckjc4in5j"
    Twitch.channel = nil
    Twitch.user_id = -1
end



Twitch.check_for_data_request = function ()
    local ch = love.thread.getChannel("twitch_data_request")
    if ch:peek() == "request" then
        ch:clear()
        local data = {notLinked = true}
        if EngagementBait.mod.config.linked then
            data = {
                channel = EngagementBait.mod.config.username,
                user_id = EngagementBait.mod.config.id,
                access_token = Twitch.token,
                notReady = false,
            }
        end
        love.thread.getChannel("twitch_data"):push(json.encode(data))
    end
end


Twitch.startServer = function ()
    print("Starting Twitch server...")
    local server_code = io.open(EngagementBait.mod.path .. "server/server.lua", "r"):read("*a")
    Twitch.server = love.thread.newThread(server_code)
    Twitch.server:start(EngagementBait.mod.path)
    local data = {notLinked = true}
    if EngagementBait.mod.config.linked then
        data = {
            channel = EngagementBait.mod.config.username,
            user_id = EngagementBait.mod.config.id,
            access_token = Twitch.token,
            notReady = false,
        }
    end
    love.thread.getChannel("twitch_data"):push(json.encode(data))
end

function G.FUNCS.EngagementBaitTwitchRestartServer ()
    if Twitch.server then
        print("Killing Twitch server...")
        Twitch.server:release()
    end
    Twitch.startServer()
end

function G.FUNCS.EngagementBaitLinkOpenDashboard ()
    local data = {notLinked = true}
    if EngagementBait.mod.config.linked then
        data = {
            channel = EngagementBait.mod.config.username,
            user_id = EngagementBait.mod.config.id,
            access_token = Twitch.token,
            notReady = false,
        }
    end
    love.thread.getChannel("twitch_data"):push(json.encode(data))
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
            local data = {
                channel = EngagementBait.mod.config.username,
                user_id = EngagementBait.mod.config.id,
                access_token = Twitch.token,
                notReady = false,
            }
            love.thread.getChannel("twitch_data"):clear()
            love.thread.getChannel("twitch_data"):push(json.encode(data))
            print("Twitch OAuth token received and saved.")
            print("Twitch linked successfully!")
            return true
        end
        love.timer.sleep(0.1)
    end

    print("Twitch linking timed out.")
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
    if EngagementBait.mod.config and EngagementBait.mod.config.id then
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
            Twitch.set_start_time_global
        )
    end
end

Twitch.set_start_time_global = function (code, body, headers)
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
        local headers = {
        	["Client-ID"] = Twitch.client_id,
    		["Authorization"] = "Bearer " .. Twitch.token,
            ["Content-Type"] = "application/json"
    	}
        local body = json.encode({
            broadcaster_id = EngagementBait.mod.config.id,
            title = question,
            choices = options,
            duration = duration
        })

        https.asyncRequest(
            "https://api.twitch.tv/helix/polls",
            {
                method = "POST",
                headers = headers,
                data = body
            },
            Twitch.CheckSucsess
        )


        -- headers = {
        -- 	["Client-ID"] = "3697aa4dd04f7212a28052cc7a98c2",
    	-- 	["Authorization"] = "Bearer " .. "a92ea0ab9c9a903",
        --     ["Content-Type"] = "application/json"
    	-- }
        -- body = json.encode({
        --     duration = duration,
        --     choices = options,
        --     title = question,
        --     broadcaster_id = "15510855",
        -- })


        -- https.asyncRequest(
        --     "http://127.0.0.1:8080/mock/polls",
        --     {
        --         method = "POST",
        --         headers = headers,
        --         data = body
        --     },
        --     Twitch.CheckSucsess
        -- )
end

Twitch.CheckSucsess = function (code, body, headers)
    if code ~= 200 then
        print("Failed to start poll. Code:", code)
        print("Response body:", body)   
        return
    end
end
Twitch.poll_ids = {}
Twitch.get_poll_result = function ()
    local ch = love.thread.getChannel("twitch_poll")
    if ch:peek() then
        local data_raw = ch:pop()
        -- print("raw data: ".. data_raw)
        local data = json.decode(data_raw)
        if data then
            print("Poll has ended. Processing results...")
            local winning = { text = "No votes", votes = 0, tie = {} }
            for _, choice in ipairs(data) do
                if table.contains(Twitch.poll_ids, choice.id) then
                    return
                end
                table.insert(Twitch.poll_ids, choice.id)
                if choice.votes > winning.votes then
                    winning = choice
                    winning.tie = {}
                elseif choice.votes == winning.votes then
                    table.insert(winning.tie, choice)
                end
            end
            if #winning.tie > 0 then
                local ran = math.random(1, #winning.tie)
                winning = winning.tie[ran]  
            end
            print("Winning choice:", winning.title, "with", winning.votes, "votes")
            for i, callback in ipairs(Twitch.poll_end_callback) do
                if callback.card and callback.callback then
                    callback.callback(callback.card, winning)
                end
            end
        end
    end

end
Twitch.poll_end_callback = {{
    card = nil,
    callback = function (card, data) end
}}

Twitch.register_poll_end_callback = function (card, callback)
    table.insert(Twitch.poll_end_callback, { card = card, callback = callback })
end

Twitch.unregister_poll_end_callback = function (card)
        for i, cb in ipairs(Twitch.poll_end_callback) do
        if cb.card == card then
            table.remove(Twitch.poll_end_callback)
            break
        end
    end
end


if not Twitch.Events then
    --@classes
Twitch.Events = {}
Twitch.Events.Subscribe = {}
Twitch.Events.Subscribe.Callbacks = {{ card = {}, callback = function(card, data) end }}
Twitch.Events.Follow = {}
Twitch.Events.Follow.Callbacks = {{ card = {}, callback = function(card, data) end }}
Twitch.Events.Bits = {}
Twitch.Events.Bits.Callbacks = {{ card = {}, callback = function(card, data) end }}

end

Twitch.Events.Follow.register_callback = function (card, callback)
    table.insert(Twitch.Events.Follow.Callbacks, { card = card, callback = callback })
end

Twitch.Events.Follow.unregister_callback = function (card)
    for i, cb in ipairs(Twitch.Events.Follow.Callbacks) do
        if cb.card == card then
            table.remove(Twitch.Events.Follow.Callbacks, i)
            break
        end
    end
end


Twitch.Events.Follow.check_for_follows = function ()
    local ch = love.thread.getChannel("twitch_follows")
    if ch:peek() then
        while ch:peek() do
            local data = ch:pop()
            for _, callback in pairs(Twitch.Events.Follow.Callbacks) do
                if callback.card and callback.callback then
                    callback.callback(callback.card, data)
                end
            end
        end
    end
end

Twitch.Events.Subscribe.register_callback = function (card, callback)
    table.insert(Twitch.Events.Subscribe.Callbacks, { card = card, callback = callback })
end

Twitch.Events.Subscribe.unregister_callback = function (card)
    for i, cb in ipairs(Twitch.Events.Subscribe.Callbacks) do
        if cb.card == card then
            table.remove(Twitch.Events.Subscribe.Callbacks, i)
            break
        end
    end
end


Twitch.Events.Subscribe.check_for_subscribes = function ()
    local ch = love.thread.getChannel("twitch_subscribes")
    if ch:peek() then
        while ch:peek() do
            local data = ch:pop()
            for _, callback in pairs(Twitch.Events.Subscribe.Callbacks) do
                if callback.card and callback.callback then
                    callback.callback(callback.card, data)
                end
            end
        end
    end
end




Twitch.Events.Bits.register_callback = function (card, callback)
    table.insert(Twitch.Events.Bits.Callbacks, { card = card, callback = callback })
end

Twitch.Events.Bits.unregister_callback = function (card)
    for i, cb in ipairs(Twitch.Events.Bits.Callbacks) do
        if cb.card == card then
            table.remove(Twitch.Events.Bits.Callbacks, i)
            break
        end
    end
end

Twitch.Events.Bits.check_for_bits = function ()
    local ch = love.thread.getChannel("twitch_cheer")
    if ch:peek() then
        while ch:peek() do
            print("Checking for bits...")
            local data = ch:pop()
            for _, callback in pairs(Twitch.Events.Bits.Callbacks) do
                if callback.card and callback.callback then
                    callback.callback(callback.card, data)
                end
            end
        end
    end
end



Twitch.is_bot = function (name)
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

