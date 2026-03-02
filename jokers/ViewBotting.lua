SMODS.Joker {
    key = "view_botting",
    atlas = 'Joker', pos = { x = 3, y = 0 },
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
    unlocked  = true,
    discovered  = false,
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
    end,
    set_badges = function(self, card, badges)
        if EngagementBait.mod.config.linked then
            badges[#badges+1] = create_badge("Linked", G.C.GREEN, G.C.BLACK, 1.2 )
        else
            badges[#badges+1] = create_badge("Not Linked", G.C.RED, G.C.BLACK, 1.2 )
        end
 	end,


}