SMODS.Joker {
    key = "Chatter",
    config = {
       extra = {
       		chip = 1,
            chatcount = 1,
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
        if context.before then
        	card.ability.extra.chatcount = card.ability.extra.chatcount + 1
        end
        if context.joker_main then
        	return {
                extra = { chips = card.ability.extra.chatcount * card.ability.extra.chip } }
        end
    end
}