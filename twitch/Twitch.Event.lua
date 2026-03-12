local json = require("json")

Twitch.Events.Subscribe = {
    Callbacks = {{ card = {}, callback = function(card, data) end }},
    register_callback = function (card, callback)
        table.insert(Twitch.Events.Subscribe.Callbacks, { card = card, callback = callback })
    end,
    unregister_callback = function (card)
        for i, cb in ipairs(Twitch.Events.Subscribe.Callbacks) do
            if cb.card == card then
                table.remove(Twitch.Events.Subscribe.Callbacks, i)
                break
            end
        end
    end,

    check_for_subscribes = function ()
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
    end,
}

Twitch.Events.Bits = {
    Callbacks = {{ card = {}, callback = function(card, data) end }},
    register_callback = function (card, callback)
        table.insert(Twitch.Events.Bits.Callbacks, { card = card, callback = callback })
    end,
    unregister_callback = function (card)
        for i, cb in ipairs(Twitch.Events.Bits.Callbacks) do
            if cb.card == card then
                table.remove(Twitch.Events.Bits.Callbacks, i)
                break
            end
        end
    end,

    check_for_bits = function ()
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
    end,
}


Twitch.Events.Follow = {
    Callbacks = {{ card = {}, callback = function(card, data) end }},
    register_callback = function (card, callback)
        table.insert(Twitch.Events.Follow.Callbacks, { card = card, callback = callback })
    end,
    unregister_callback = function (card)
        for i, cb in ipairs(Twitch.Events.Follow.Callbacks) do
            if cb.card == card then
                table.remove(Twitch.Events.Follow.Callbacks, i)
                break
            end
        end
    end,

    check_for_follows = function ()
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
    end,
}


Twitch.Events.Poll = {
    Callbacks = {{ card = {}, callback = function(card, data) end }},
    poll_ids = {},

    start_poll = function (question, options, duration)
        local body = json.encode({
            broadcaster_id = Twitch.user_id,
            title = question,
            choices = options,
            duration = duration
        })

        Twitch.post("polls",body,
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to start poll. Code:", code)
                    print("Response body:", body)   
                    return
                end
            end
        )
    end,

    check_for_end = function ()
        local ch = love.thread.getChannel("twitch_poll")
        if ch:peek() then
            local data_raw = ch:pop()
            -- print("raw data: ".. data_raw)
            local data = json.decode(data_raw)
            if data then
                print("Poll has ended. Processing results...")
                local winning = { text = "No votes", votes = 0, tie = {} }
                for _, choice in ipairs(data) do
                    if table.contains(Twitch.Events.Poll.poll_ids, choice.id) then
                        return
                    end
                    table.insert(Twitch.Events.Poll.poll_ids, choice.id)
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
                for i, callback in ipairs(Twitch.Events.Poll.Callbacks) do
                    if callback.card and callback.callback then
                        callback.callback(callback.card, winning)
                    end
                end
            end
        end

    end,

    register_callback = function (card, callback)
        table.insert(Twitch.Events.Poll.Callbacks, { card = card, callback = callback })
    end,

    unregister_callback = function (card)
        for i, cb in ipairs(Twitch.Events.Poll.Callbacks) do
            if cb.card == card then
                table.remove(Twitch.Events.Poll.Callbacks)
                break
            end
        end
    end,
}


local json = require("json")


Twitch.Events.Prediction = {
    active_poll_id = nil,

    start_prediction = function (title, outcomes, prediction_window)
        local body = json.encode({
            broadcaster_id = Twitch.user_id,
            title = title,
            outcomes = outcomes,
            prediction_window = prediction_window
        })
        Twitch.post("predictions",body,
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to start prediction. Code:", code)
                    print("Response body:", body)   
                    return
                end
                local data = json.decode(body)
                if data and data.data and data.data[1] then
                    local prediction = data.data[1]
                    print("Prediction started with ID:", prediction.id)
                    Twitch.Events.Prediction.active_poll_id = prediction.id
                else
                    print("Failed to parse Twitch response.")
                end
            end
        )
    end,

    resolve_prediction = function (winning_outcome_id)
        if not Twitch.Events.Prediction.active_poll_id then
            print("No active prediction to resolve.")
            return
        end
        local body = json.encode({
            broadcaster_id = Twitch.user_id,
            status = "RESOLVED",
            winning_outcome_id = winning_outcome_id
        })
        Twitch.post("predictions",body,
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to start prediction. Code:", code)
                    print("Response body:", body)   
                    return
                end
            end
        )
        Twitch.Events.Prediction.active_poll_id = nil
    end,

    cancele_prediction = function ()
        if not Twitch.Events.Prediction.active_poll_id then
            print("No active prediction to cancel.")
            return
        end
        local body = json.encode({
            broadcaster_id = Twitch.user_id,
            status = "CANCELED"
        })
        Twitch.post("predictions",body,
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to start prediction. Code:", code)
                    print("Response body:", body)   
                    return
                end
            end
        )
        Twitch.Events.Prediction.active_poll_id = nil
    end,

    lock_prediction = function ()
        if not Twitch.Events.Prediction.active_poll_id then
            print("No active prediction to lock.")
            return
        end
        local body = json.encode({
            broadcaster_id = Twitch.user_id,
            status = "LOCKED"
        })
        Twitch.post("predictions",body,
            function (code, body, headers)
                if code ~= 200 then
                    print("Failed to start prediction. Code:", code)
                    print("Response body:", body)
                    return
                end
            end
        )
    end,




}


