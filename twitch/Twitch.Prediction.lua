local https = require("SMODS.https")
local json = require("json")


if not Twitch.Prediction then
    Twitch.Prediction = {}
    Twitch.Prediction.Callbacks = {{ card = {}, callback = function(card, data) end }}
end


local p = Twitch.Prediction

p.register_callback = function (card,callback)
    table.insert(p.Callbacks, { card = card, callback = callback })
end

p.unregister_callback = function (card)
    for i, cb in ipairs(p.Callbacks) do
        if cb.card == card then
            table.remove(p.Callbacks, i)
            break
        end
    end
end


p.StartPrediction = function (question, outcomes, prediction_window)
            local headers = {
        	["Client-ID"] = Twitch.client_id,
    		["Authorization"] = "Bearer " .. Twitch.token,
            ["Content-Type"] = "application/json"
    	}
        local body = json.encode({
            broadcaster_id = EngagementBait.mod.config.id,
            title = question,
            outcomes = outcomes,
            prediction_window = prediction_window
        })

        https.asyncRequest(
            "https://api.twitch.tv/helix/predictions",
            {
                method = "POST",
                headers = headers,
                data = body
            },
            p.CheckSucsess
        )

end

p.CheckSucsess = function (code, body)
    if code ~= 200 then
        print("Failed to start poll. Code:", code)
        print("Response body:", body)
    end
end