SMODS.Joker {
    key = "the_predictor",
    -- atlas = 'Joker', pos = { x = 2, y = 0 },
    config = {
        extra = {
            xmult_lose = 0.25,
            xmult = 1.5
        }
    },
    loc_vars = function (self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult_initial,
                card.ability.extra.xmult_lose,
                card.ability.extra.time_interval_s,
                card.ability.extra.xmult,
            }
        }
    end,
    rarity = 2,
    cost = 8,
    unlocked  = true,
    discovered  = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult,
            }
        end
        if context.blind_defeated then
            
        end
    end
}