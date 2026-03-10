SMODS.Enhancement {
    key = "emote",
    atlas = 'Enhancement', pos = { x = 0, y = 0 },
    config = {
        extra = {
            xmult = 2,
            xmult_neg = 0.9
        }
    },
    loc_vars = function (self, info_queue, card)
        Twitch.Chat.Mode.CheckMode()
        local x_mult_curent
        if Twitch.Chat.Mode.mode.emote_mode then
            x_mult_curent = card.ability.extra.xmult
        else
            x_mult_curent = card.ability.extra.xmult_neg
        end
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.xmult_neg,
                x_mult_curent
            }
        }
    end,
    badge_colour = G.C.PURPLE,
    calculate = function (self, card, context)
        if context.before then
            Twitch.Chat.Mode.CheckMode()
        end
        if context.main_scoring and context.cardarea == G.play then
            if Twitch.Chat.Mode.mode.emote_mode then
                return {
                    x_mult = card.ability.extra.x_mult
                }
            else
                return {
                    x_mult = card.ability.extra.xmult_neg
                }
            end
        end
    end
}