SMODS.Joker {
    key = "bitter",
    config = {
         extra = {
            mult = 1,
            bitts = 0,
     	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.mult,
            	card.ability.extra.bitts * card.ability.extra.mult,
           }
        }
    end,
    rarity = 2,
    cost = 5,
    unloxed = true,
    descover = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
        	return {
                extra = { mult = card.ability.extra.bitts * card.ability.extra.mult } }
        end
    end,
    update = function (self, card, context)
        Twitch.Events.Bits.check_for_bits()
    end,

    add_to_deck = function (self, card, deck)
        Twitch.Events.Bits.register_callback(card, self.bits)
    end,
    remove_from_deck = function (self, card, deck)
        Twitch.Events.Bits.unregister_callback(card)
    end,
    load = function (self, card)
        Twitch.Events.Bits.register_callback(card, self.bits)
    end,
    bits = function (card, data)
        print("bits: " .. data.bits)
        card.ability.extra.bitts = card.ability.extra.bitts + tonumber(data.bits)
        attention_text({
            text = "+" .. data.bits,
            scale = 0.75,
            hold = 1,
            fade = 1,
            major = card,
            colour = G.C.PURPLE,
        })
        card:juice_up(0.1, 0.2)
        play_sound('tarot2', 0.76, 0.6);
    end,

}