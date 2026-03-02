SMODS.Joker {
    key = "anty_clanker_measures",
    atlas = 'Joker', pos = { x = 6, y = 0 },
    config = {
        extra = {
            mult = 0,
            mult_gain = 1,
            mult_lose_x = 0.5,
        }
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.mult_gain,
            	card.ability.extra.mult_lose_x,
            	card.ability.extra.mult,
                
           }
        }
    end,

    rarity = 3,
    cost = 9,
    unlocked  = true,
    discovered  = false,
    blueprint_compat = true,
    eternal_compat = true,


    calculate = function (self, card, context)
        if context.joker_main then
        	return {
                extra = { mult = card.ability.extra.mult } }
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
        local c = G.C.GREEN
        if Twitch.is_bot(data.name) then
            c = G.C.RED
            card.ability.extra.mult = card.ability.extra.mult * card.ability.extra.mult_lose_x
        else
            c = G.C.GREEN
            card.ability.extra.mult = card.ability.extra.mult + 1
        end
        attention_text({
            text = data.message,
            scale = 0.5,
            hold = 1.5,
            fade = 1.5,
            major = card,
            -- align = 'cm',
            offset = { x = 0, y = -1.5 },
            colour = c,
        })
    end,




}
