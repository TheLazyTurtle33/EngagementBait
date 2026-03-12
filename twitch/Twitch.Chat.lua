local https = require("SMODS.https")
local json = require("json")




if not Twitch.Chat then
Twitch.Chat = {

    
    Callbacks = {{ card = {}, callback = function(card, data) end }},
    time_of_last_chat = os.time(),
    Mode = {
        current = {},
        LastChecked = 0,
        CheckDelay = 5,
        CheckMode = function ()
            local now = os.time()
            if now - Twitch.Chat.Mode.LastChecked > Twitch.Chat.Mode.CheckDelay then
                Twitch.Chat.Mode.LastChecked = now
                Twitch.get(
                    "chat/settings?broadcaster_id=" .. EngagementBait.mod.config.id,
                    function (code, body, headers)
                        if code ~= 200 then
                            print("Failed to start poll. Code:", code)
                            print("Response body:", body)   
                            return
                        end
                        local data = json.decode(body).data
                        Twitch.Chat.Mode.current = data[1]
                    end
                )
            end
        end,
    },

    register_callback = function (card,callback)
        table.insert(Twitch.Chat.Callbacks, { card = card, callback = callback })
    end,

    unregister_callback = function (card)
        for i, cb in ipairs(Twitch.Chat.Callbacks) do
            if cb.card == card then
                table.remove(Twitch.Chat.Callbacks, i)
                break
            end
        end
    end,


    check_for_chats = function ()
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
    end,

    get_last_chat_time = function ()
        Twitch.Chat.check_for_chats()
        return Twitch.Chat.time_of_last_chat
    end,
}
end
Twitch.urldecode = function (s)
    s = string.gsub(s, '%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    -- Also replace '+' with ' ' for form-encoded data, if necessary
    s = string.gsub(s, '+', ' ')
    return s
end