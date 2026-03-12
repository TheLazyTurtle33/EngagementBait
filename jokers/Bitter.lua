SMODS.Joker {
    key = "bitter",
    atlas = 'Joker', pos = { x = 0, y = 0 },
    config = {
         extra = {
            mult = 1,
            bits = 0,
     	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.mult,
            	card.ability.extra.bits * card.ability.extra.mult,
           }
        }
    end,
    rarity = 2,
    cost = 5,
    unlocked  = true,
    discovered  = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
        	return {
                extra = { mult = card.ability.extra.bits * card.ability.extra.mult } }
        end
    end,
    update = function (self, card, context)
        Twitch.Events.Bits.check_for_bits()
    end,
    set_badges = function(self, card, badges)
        if EngagementBait.mod.config.linked then
            badges[#badges+1] = create_badge("Linked", G.C.GREEN, G.C.BLACK, 1.2 )
        else
            badges[#badges+1] = create_badge("Not Linked", G.C.RED, G.C.BLACK, 1.2 )
        end
 	end,

    add_to_deck = function (self, card, deck)
        Twitch.Events.Bits.register_callback(card, self.bits_gained)
    end,
    remove_from_deck = function (self, card, deck)
        Twitch.Events.Bits.unregister_callback(card)
    end,
    load = function (self, card)
        Twitch.Events.Bits.register_callback(card, self.bits_gained)
    end,

    bits_gained = function (card, data)
        print("bits: " .. data.bits)
        data.bits_num = tonumber(data.bits)
        SMODS.scale_card(card, {
            ref_table = card.ability.extra,
            ref_value = "bits",
            scalar_table = data,
            scalar_value = "bits_num",
            scaling_message = {
                message = "+" .. data.bits,
                colour = G.C.PURPLE
            }
        })
    end,

}