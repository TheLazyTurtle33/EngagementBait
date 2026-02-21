SMODS.Joker {
    key = "dead_chat",
    atlas = 'Joker', pos = { x = 2, y = 0 },
    config = {
       extra = {
            xmult_initial = 10,
            xmult_lose = 1,
            time_interval_s = 60,
       		xmult = 10,
            time_of_last_check = nil,
    	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.xmult_initial,
            	card.ability.extra.xmult_lose,
                card.ability.extra.time_interval_s,
            	card.ability.extra.xmult,
           }
        }
    end,
    rarity = 2,
    cost = 7,
    unloxed = true,
    descover = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
        	return {
                extra = { xmult = card.ability.extra.xmult } }
        end
    end,

    add_to_deck = function (self, card, deck)
        card.ability.extra.time_of_last_check = os.time()
        card.ability.extra.xmult = card.ability.extra.xmult_initial
    end,

    update = function (self, card, context)
        
        if not card.ability.extra.time_of_last_check then
            card.ability.extra.time_of_last_check = os.time()
        else
            local now = os.time()
            if (now - card.ability.extra.time_of_last_check) >= card.ability.extra.time_interval_s then
                card.ability.extra.time_of_last_check = now

                local last_chat_time = Twitch.Chat.get_last_chat_time()

                if last_chat_time and (now - last_chat_time) >= card.ability.extra.time_interval_s then
                    if card.ability.extra.xmult - card.ability.extra.xmult_lose <= 1 then
                        attention_text({
                            text = "Get some Chatters lmao",
                            scale = 0.5,
                            hold = 3,
                            fade = 3,
                            major = card,
                            colour = G.C.RED,
                        })
                        SMODS.destroy_cards(card, nil, nil, false)
                    else
                        card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_lose
                        attention_text({
                            text = "-x" .. card.ability.extra.xmult_lose,
                            scale = 0.75,
                            hold = 2,
                            fade = 1,
                            major = card,
                            colour = G.C.RED,
                        })
                    end
                end
            end
        end
    end,
}