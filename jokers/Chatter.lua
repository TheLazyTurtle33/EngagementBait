SMODS.Joker {
    key = "chatter",
    config = {
       extra = {
       		chip = 1,
            chatcount = 0,
    	}
    },

    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.chip,
            	card.ability.extra.chatcount * card.ability.extra.chip,
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
                extra = { chips = card.ability.extra.chatcount * card.ability.extra.chip } }
        end
    end,

    update = function (self, card, context)
        Twitch.Chat.check_for_chats()
    end,
    set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("test", G.C.RED, G.C.BLACK, 1.2 )
 	end,

    add_to_deck = function (self, card, deck)
        	Twitch.Chat.register_callback(card, self.chat)
    end,

    remove_from_deck = function (self, card, deck)
        	Twitch.Chat.unregister_callback(card)
    end,
    load = function (self, card)
        print("load")
        Twitch.Chat.register_callback(card, self.chat)
    end,

    chat = function (card, data)
        card.ability.extra.chatcount = card.ability.extra.chatcount + 1
            attention_text({
                text = data.name .. ": " .. data.message,
                scale = 0.5,
                hold = 2.5,
                fade = 1.5,
                major = card,
                -- align = 'cm',
                offset = { x = 0, y = -1.5 },
            })
    end


}