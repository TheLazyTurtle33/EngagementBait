SMODS.Joker = {
    key = "bitter",
    config = {
         extra = {
            chip = 1,
            bitts = 0,
     	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.chip,
            	card.ability.extra.bitts * card.ability.extra.chip,
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
                extra = { chips = card.ability.extra.bitts * card.ability.extra.chip } }
        end
    end,
    update = function (self, card, context)
        Twitch.Events.Bits.check_for_bits()
    end,

    

}