SMODS.Joker {
    key = "the_secret",
    config = {
       extra = {
            xmult_raw = 2,
            xmult_full = 50,
            xmult = 2,
            secret = "",
    	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.xmult_raw,
            	card.ability.extra.xmult_full,
                card.ability.extra.xmult,
                
           }
        }
    end,
    rarity = 1,
    cost = 5,
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

    update = function (self, card, context)
        Twitch.Chat.check_for_chats()
    end,

    add_to_deck = function (self, card, deck)
        card.ability.extra.secret = "temp"
        Twitch.Chat.register_callback(card, self.chat)
    end,

    remove_from_deck = function (self, card, deck)
        Twitch.Chat.unregister_callback(card)
    end,
    load = function (self, card)
        Twitch.Chat.register_callback(card, self.chat)
    end,

    chat = function (card, data)
        local c = G.C.RED
        if data.message:lower() == card.ability.extra.secret:lower() then
            card.ability.extra.xmult = card.ability.extra.xmult_full
            c = G.C.GREEN
            card:juice_up(0.1, 0.2)
        end
        attention_text({
            text = data.message,
            scale = 0.5,
            major = card,
            hold = 2.5,
            fade = 1.5,
            -- align = 'cm',
            offset = { x = 0, y = -1.5 },
            colour = c,
        })
    end


}