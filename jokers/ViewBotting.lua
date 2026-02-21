SMODS.Joker {
    key = "view_botting",
    config = {
       extra = {
       		mult = 1,
            viewers = 0,
    	}
    },
    loc_vars = function (self, info_queue, card)
        Twitch.get_viewer_count()
        card.ability.extra.viewers = Twitch.viewers or 0
        return {
           vars = {
            	card.ability.extra.mult,
            	card.ability.extra.viewers * card.ability.extra.mult,
           }
        }
    end,
    rarity = 1,
    cost = 6,
    unloxed = true,
    descover = false,
    blueprint_compat = true,
    eternal_compat = true,

    calculate = function (self, card, context)
        if context.before then
            Twitch.get_viewer_count()
            card.ability.extra.viewers = Twitch.viewers or 0
        end
        if context.joker_main then
        	return {
                message = "lmao",
                extra = { mult = card.ability.extra.viewers } }
        end
    end


}