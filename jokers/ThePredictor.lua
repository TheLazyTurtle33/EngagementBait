SMODS.Joker {
    key = "the_predictor",
    -- atlas = 'Joker', pos = { x = 2, y = 0 },
    config = {
        extra = {
            xmult_gain = 0.25,
            xmult_lose = 0.25,
            xmult = 1.5
        }
    },
    loc_vars = function (self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult_gain,
                card.ability.extra.xmult_lose,
                card.ability.extra.xmult,
            }
        }
    end,
    rarity = 3,
    cost = 8,
    unlocked  = true,
    discovered  = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.setting_blind then
            Twitch.Events.Prediction.start_prediction("Odd or Even", {{ title = "Even" },{ title = "Odd"} }, math.floor(EngagementBait.mod.config.prediction_window))
        end
        if context.before and G.GAME.current_round.hands_left == 0 then
            Twitch.Events.Prediction.lock_prediction()
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult,
            }
        end
        if context.blind_defeated then
            local odd = G.GAME.chips % 2
            if Twitch.Events.Prediction.opts then
                if odd == 0 then
                    Twitch.Events.Prediction.resolve_prediction(Twitch.Events.Prediction.opts[1].id, card, self.up_values)
                else
                    Twitch.Events.Prediction.resolve_prediction(Twitch.Events.Prediction.opts[2].id, card, self.up_values)
                end
            end
        end
        if context.game_over then
            Twitch.Events.Prediction.cancele_prediction()
        end
    end,
    remove_from_deck = function (self, card, deck)
        Twitch.Events.Prediction.cancele_prediction()
    end,

    up_values = function (card, data)
        print(data)
        if not data then return end
        if data.outcomes[1].channel_points > data.outcomes[2].channel_points and data.winning_outcome_id == data.outcomes[1].id
            or data.outcomes[1].channel_points < data.outcomes[2].channel_points and data.winning_outcome_id == data.outcomes[2].id then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                scaling_message = {
                    message = "CORRECT!",
                    colour = G.C.GREEN
                }
            })
        else
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_lose",
                scaling_message = {
                    message = "WRONG!",
                    colour = G.C.RED
                },
                operation = '-'
            })
        end
        if card.ability.extra.xmult  < 1 then
            SMODS.destroy_cards(card, nil, nil, false)
        end
    end
}