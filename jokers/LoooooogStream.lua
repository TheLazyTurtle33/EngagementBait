SMODS.Joker {
    key = "loooooog_stream",
    atlas = 'Joker', pos = { x = 4, y = 0 },
    config = {
       extra = {
       		chip = 1,
            time = 0,
    	}
    },
    loc_vars = function (self, info_queue, card)
        card.ability.extra.time = Twitch.get_stream_duration() or 0
        return {
           vars = {
            	card.ability.extra.chip,
            	card.ability.extra.time * card.ability.extra.chip,
           }
        }
    end,
    rarity = 1,
    cost = 5,
    unlocked  = true,
    discovered  = false,
    blueprint_compat = true,
    eternal_compat = true,

    calculate = function (self, card, context)
        if context.before then
        	card.ability.extra.time = Twitch.get_stream_duration() or 0
        end
        if context.joker_main then
        	return {
                extra = { chips = card.ability.extra.time * card.ability.extra.chip } }
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