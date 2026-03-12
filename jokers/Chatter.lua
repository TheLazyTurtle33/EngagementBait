SMODS.Joker {
    key = "chatter",
    atlas = 'Joker', pos = { x = 1, y = 0 },
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
    cost = 6,
    unlocked  = true,
    discovered  = false,
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
        if EngagementBait.mod.config.linked then
            badges[#badges+1] = create_badge("Linked", G.C.GREEN, G.C.BLACK, 1.2 )
        else
            badges[#badges+1] = create_badge("Not Linked", G.C.RED, G.C.BLACK, 1.2 )
        end
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
        SMODS.scale_card(card, {
            ref_table = card.ability.extra,
            ref_value = "chatcount",
            scalar_table = { val = 1 },
            scalar_value = "val",
        })
    end


}