local https = require("SMODS.https")
local json = require("json")




if not Twitch.Chat then
    Twitch.Chat = {}
    Twitch.Chat.Callbacks = {{ card = {}, callback = function(card, data) end }}
    Twitch.Chat.time_of_last_chat = os.time()
    Twitch.Chat.Mode = {}
    Twitch.Chat.Mode.mode = {}
end

Twitch.Chat.register_callback = function (card,callback)
    table.insert(Twitch.Chat.Callbacks, { card = card, callback = callback })
end

Twitch.Chat.unregister_callback = function (card)
    for i, cb in ipairs(Twitch.Chat.Callbacks) do
        if cb.card == card then
            table.remove(Twitch.Chat.Callbacks, i)
            break
        end
    end
end


Twitch.Chat.check_for_chats = function ()

   local ch = love.thread.getChannel("twitch_chat")
   if ch:peek() then
        while ch:peek() do
            local data = ch:pop()
            data = {message = Twitch.urldecode(data.message), name = data.name}
            for _, callback in pairs(Twitch.Chat.Callbacks) do
                if callback.card and callback.callback then
                    callback.callback(callback.card, data)
                end
            end
            Twitch.Chat.time_of_last_chat = data.time
        end
   end
end

Twitch.Chat.get_last_chat_time = function ()
    Twitch.Chat.check_for_chats()
    return Twitch.Chat.time_of_last_chat
end



Twitch.Chat.Mode.LastChecked = 0
Twitch.Chat.Mode.CheckDelay = 5
Twitch.Chat.Mode.CheckMode = function ()
    local now = os.time()
    if now - Twitch.Chat.Mode.LastChecked > Twitch.Chat.Mode.CheckDelay then
        Twitch.Chat.Mode.LastChecked = now
        local headers = {
        	["Client-ID"] = Twitch.client_id,
    		["Authorization"] = "Bearer " .. Twitch.token,
            ["Content-Type"] = "application/json"
    	}
        -- body = [[{"broadcaster_id":"884480140","title":"Heads or Tails?","choices":[{"title":"Heads"},{"title":"Tails"}],"channel_points_voting_enabled":true,"channel_points_per_vote":100,"duration":1800}]]
        -- print("Body sent: "..body)

        https.asyncRequest(
            "https://api.twitch.tv/helix/chat/settings?broadcaster_id=" .. EngagementBait.mod.config.id,
            {
                method = "GET",
                headers = headers,
            },
            Twitch.Chat.Mode.SetModeGlobal
        )
    end
end

Twitch.Chat.Mode.SetModeGlobal = function (code, body, headers)
    if code ~= 200 then
        print("Failed to start poll. Code:", code)
        print("Response body:", body)   
        return
    end
    local data = json.decode(body).data
    Twitch.Chat.Mode.mode = data[1]
    -- print(data[1])

end


Twitch.Chat.CreateChatBoxUI = function ()
    
end


Twitch.urldecode = function (s)
    s = string.gsub(s, '%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    -- Also replace '+' with ' ' for form-encoded data, if necessary
    s = string.gsub(s, '+', ' ')
    return s
end