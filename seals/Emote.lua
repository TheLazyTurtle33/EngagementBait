SMODS.Seal {
    key = "Emote",
    config = {
        extra = {
            xmult = 1,
            xmult_neg = 0.5
        }
    },
    loc_vars = function (self, info_queue, card)
        local x_mult
        if Twitch.Chat.InEmoteOnly then
                x_mult = self.config.extra.x_mult
            else
                x_mult = self.config.extra.x_mult_neg
            end
        return {
            vars = {
                self.config.extra.xmult,
                self.config.extra.xmult_neg,
                x_mult
            }
        }
    end,
    badge_colour = G.C.PURPLE,
    calculate = function (self, card, context)
        if context.before then
            Twitch.Chat.CheckChatMode()
        end
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            if Twitch.Chat.InEmoteOnly then
                return {
                    x_mult = self.config.extra.x_mult
                }
            else
                return {
                    x_mult = self.config.extra.xmult_neg
                }
            end
        end
    end
}