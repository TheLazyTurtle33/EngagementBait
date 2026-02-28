SMODS.Joker {
    key = "the_great_vote",
    atlas = 'Joker', pos = { x = 7, y = 0 },
    config = {
       extra = {
            text = "?????????",
            active = {},
            choices = { -- 5
                {text = "example", weight = 0, effect = {chips = 0, xchips = 0, mult = 0, xmult = 0, dollars = 0, sell_price_dif = 0, self_destruct = false, joker_copy = {}, extra_slots = {joker = 0, consumeable = 0, hand = 0}, hands_dif = 0, discgard_dif = 0, level_ups = 0, balance = false, staking = true}},
                {text = "Nothing...",       weight = 0.80, effect = {},                                                 staking = true  },
                {text = "Self Destruct",    weight = 0.01, effect = {self_destruct = true},                             staking = false },
                {text = "+100 Chips",       weight = 0.90, effect = {chips = 100},                                      staking = true  },
                {text = "X2 Chips",         weight = 0.50, effect = {xchips = 2},                                       staking = true  },
                {text = "+50 Mult",         weight = 0.85, effect = {mult = 50},                                        staking = true  },
                {text = "X2 mult",          weight = 0.50, effect = { xmult = 2},                                       staking = true  },
                {text = "X5 mult",          weight = 0.40, effect = {xmult = 5},                                        staking = true  },
                {text = "X0.75 mult",       weight = 0.40, effect = {xmult = 0.75},                                     staking = true  },
                {text = "-50 Chips",        weight = 0.40, effect = {chips = -50},                                      staking = true  },
                {text = "X0.5 Chips",       weight = 0.30, effect = {xchips = 0.5},                                     staking = true  },
                {text = "Looks Inside",        weight = 0.10, effect = {joker_copy = {"j_photograph","j_hanging_chad"}},   staking = false },
                {text = "Unesless",         weight = 0.20, effect = {joker_copy = {"j_chicot"}},                        staking = false },
                {text = "Hand size +1",     weight = 0.50, effect = {extra_slots = {hand = 1}},                         staking = true  },
                {text = "Hand size -1",     weight = 0.50, effect = {extra_slots = {hand = -1}},                        staking = true  },
                {text = "LEVEL UP!",        weight = 0.10, effect = {level_ups = 1},                                    staking = true  },
                {text = "LEVEL DOWN!",      weight = 0.08, effect = {level_ups = -1},                                   staking = true  },
                {text = "Yes but choice 1", weight = 0.02, effect = {xchips = 2},                                       staking = true  },
                {text = "Yes but choice 2", weight = 0.02, effect = {xmult = 2},                                        staking = true  },
                {text = "Yes but choice 3", weight = 0.02, effect = {xmult = 3},                                        staking = true  },
                {text = "Yes but choice 4", weight = 0.02, effect = {xmult = 4},                                        staking = true  },
                {text = "Yes but choice 5", weight = 0.02, effect = {xmult = 5},                                        staking = true  },
                {text = "Plasma",           weight = 0.20, effect = {balance = true},                                   staking = false },
                {text = "Again!",           weight = 0.03, effect = {repetition = 1},                                   staking = true },
                {text = "Negative",         weight = 0.10, effect = {extra_slots = {joker = 1}},                        staking = true },
                {text = "Positive",         weight = 0.10, effect = {extra_slots = {joker = -1}},                       staking = true },






            },
    	}
    },
    loc_vars = function (self, info_queue, card)
            local text = card.ability.extra.text
            local size = 0.9
            local font = G.LANG.font
            local max_text_width = 2 - 2*0.05 - 4*0.03*size - 2*0.03
            local calced_text_width = 0
            -- Math reproduced from DynaText:update_text
            for _, c in utf8.chars(text) do
                local tx = font.FONT:getWidth(c)*(0.33*size)*G.TILESCALE*font.FONTSCALE + 2.7*1*G.TILESCALE*font.FONTSCALE
                calced_text_width = calced_text_width + tx/(G.TILESIZE*G.TILESCALE)
            end
            local scale_fac = 1
        return {
           vars = {
        },
        main_end = {{n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR, r = 0.1, minw = 2, minh = 0.36, emboss = 0.05, padding = 0.03*size}, nodes={
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                  {n=G.UIT.O, config={object = DynaText({string = text or 'ERROR', colours = {G.C.BLACK},float = true, shadow = true, offset_y = -0.05, silent = true, spacing = 1*scale_fac, scale = 0.33*size*scale_fac, marquee = calced_text_width > max_text_width, maxw = max_text_width})}},
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                }}
              }}}
    }
    end,
    
    rarity = 4,
    cost = 20,
    unloxed = true,
    descover = false,
    blueprint_compat = false,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.setting_blind and not context.skip_blind then
            local choices = self.get_weighted_choices(card.ability.extra.choices, 5)
            local choice_formated = {}
            local ret = {}
            for i, choice in ipairs(choices) do
                table.insert(choice_formated, {title = choice.text})
            end
            Twitch.start_poll("The Great Vote", choice_formated, math.floor(EngagementBait.mod.config.poll_duration))
            ret.message = "Vote Started!"
            
            if card.ability.extra.active and card.ability.extra.active ~= {} then
                for i, effect in ipairs(card.ability.extra.active) do
                    if effect.hands_dif then
                        ease_hands_played(effect.hands_dif)
                    end
                    if effect.discgard_dif then
                        ease_discard(effect.discgard_dif)
                    end
                end
            end
            
            return ret

            


        end
        
        if context.blind_defeated then
            -- local eff = self.get_weighted_choices(card.ability.extra.choices, 1)[1]
            -- print(eff)
            -- self.poll_ended(card, {text = "Again!"})
            -- self.poll_ended(card, {text = "+100 Chips"})
        end
        
        
        local ret = {}
        for i, effect in ipairs(card.ability.extra.active) do
        -- effect = {chips = 0, xchips = 0, mult = 0, xmult = 0, dollars = 0, sell_price_dif = 0, self_destruct = false, joker_copy = nil, extra_slots = {joker = 0, consumeable = 0, hand = 0}, hands_dif = 0, discgard_dif = 0}
        
            if context.joker_main and card.ability.extra.active and card.ability.extra.active ~= {} then

                -- effect.repetition = nil
                ret = self.murge_returns(ret, effect)


                if effect.sell_price_dif then
                    card.sell_cost =  card.sell_cost + effect.sell_price_dif
                    card.sell_cost_label = tostring(card.sell_cost)
                end
            end


            if context.repetition and context.cardarea == G.play and effect.repetition then
                ret = self.murge_returns(ret, {
                    repetitions = effect.repetition
                })
            end


            if effect.joker_copy then
                for j, _ in ipairs(effect.joker_copy) do
                    if effect.joker_copy[j] == "j_photograph" then
                        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
                            local is_first_face = false
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i]:is_face() then
                                    is_first_face = context.scoring_hand[i] == context.other_card
                                    break
                                end
                            end
                            if is_first_face then
                                ret = self.murge_returns(ret, {
                                    xmult = 2
                                })
                            end
                        end
                    elseif effect.joker_copy[j] == "j_hanging_chad" then
                        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
                            ret = self.murge_returns(ret, {
                                repetitions = 2
                            })
                        end
                    elseif effect.joker_copy[j] == "j_chicot" then
                        if context.setting_blind and not context.blueprint and context.blind.boss then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            G.GAME.blind:disable()
                                            play_sound('timpani')
                                            delay(0.4)
                                            return true
                                        end
                                    }))
                                    SMODS.calculate_effect({ message = localize('ph_boss_disabled') }, card)
                                end
                            }))
                        end
                    end
                end
            end
            
        end
        return ret
    end,

    murge_returns = function (r1, r2)
        if r2.chips then
            if not r1.chips then
                r1.chips = r2.chips
            else
                r1.chips = r1.chips + r2.chips
            end
        end
        if r2.mult then
            if not r1.mult then
                r1.mult = r2.mult
            else
                r1.mult = r1.mult + r2.mult
            end
        end

        if r2.dollars then
            if not r1.dollars then
                r1.dollars = r2.dollars
            else
                r1.dollars = r1.dollars + r2.dollars
            end
        end

        if r2.level_ups then
            if not r1.level_up then
                r1.level_up = r2.level_ups
            else
                r1.level_up = r1.level_up + r2.level_ups
            end
        end

        if r2.xchips then
            if not r1.xchips then
                r1.xchips = r2.xchips
            else
                r1.xchips = r1.xchips * r2.xchips
            end
        end

        if r2.xmult then
            if not r1.xmult then
                r1.xmult = r2.xmult
            else
                r1.xmult = r1.xmult * r2.xmult
            end
        end

        if r2.repetitions then
            if not r1.repetitions then
                r1.repetitions = r2.repetitions
            else
                r1.repetitions = r1.repetitions + r2.repetitions
            end
        end

        if r2.balance ~= nil then
            r1.balance = r2.balance
        end


        return r1
    end,


    update = function (self, card, context)
        Twitch.get_poll_result()
    end,


    poll_ended = function(card, data)
        local name
        if data.title then
            name = data.title
        else
            name = data.text
        end
        for i, choice in ipairs(card.ability.extra.choices) do
            if choice.text == name then
                table.insert(card.ability.extra.active, choice.effect)
                if card.ability.extra.text == "?????????" then
                    card.ability.extra.text = choice.text
                else
                    card.ability.extra.text = card.ability.extra.text .. " & " .. choice.text
                end
                if not choice.staking then
                    table.remove(card.ability.extra.choices, i) -- so it cant be chosen again
                end
                attention_text({
                    text = choice.text,
                    scale = 0.5,
                    hold = 3,
                    fade = 3,
                    major = card,
                    colour = G.C.GREEN,
                })

                if choice.effect.extra_slots then
                    if choice.effect.extra_slots.hand then
                        G.hand:change_size(choice.effect.extra_slots.hand)
                    end
                    if choice.effect.extra_slots.joker then
                        G.jokers.config.card_limit = G.jokers.config.card_limit + choice.effect.extra_slots.joker
                    end
                    if choice.effect.extra_slots.consumeable then
                        G.consumeables.config.card_limit = G.consumeables.config.card_limit + choice.effect.extra_slots.consumeable
                    end
                end
                if choice.effect.self_destruct then
                G.E_MANAGER:add_event(Event({
                    delay = 1,
                    func = function()
                            attention_text({
                                    text = "Get Fucked",
                                    scale = 0.5,
                                    hold = 3,
                                    fade = 3,
                                    major = card,
                                    colour = G.C.RED,
                                })
                        G.E_MANAGER:add_event(Event({
                            delay = 2.5,
                            func = function()
                                    SMODS.destroy_cards(card, nil, nil, false)
                                return true
                            end
                        }))
                        return true
                    end
                }))
                end


                break
            end
        end
        
    end,

    add_to_deck = function (self, card, from_debuff)
        Twitch.register_poll_end_callback(card, self.poll_ended)
        -- self.poll_ended(card,{text = "Photo"})
        -- self.poll_ended(card,{text = "Chad"})
    end,

    remove_from_deck = function (self, card, from_debuff)
        Twitch.unregister_poll_end_callback()
        if card.ability.extra.active and card.ability.extra.active ~= {} then
            for i, effect in ipairs(card.ability.extra.active) do
                if effect.extra_slots then
                    if effect.extra_slots.hand then
                        G.hand:change_size(-effect.extra_slots.hand)
                    end
                    if effect.extra_slots.joker then
                        G.jokers.config.card_limit = G.jokers.config.card_limit + effect.extra_slots.joker
                    end
                    if effect.extra_slots.consumeable then
                        G.consumeables.config.card_limit = G.consumeables.config.card_limit + effect.extra_slots.consumeable
                    end
                end
            end
        end
    end,

    load = function (self, card)
        Twitch.register_poll_end_callback(card, self.poll_ended)
    end,

    -- Returns `count` weighted random unique choices from `choices`
    get_weighted_choices = function (choices, count)
        local results = {}
        local pool = {}

        -- Copy choices so we can remove selected ones (no duplicates)
        for i, choice in ipairs(choices) do
            pool[i] = choice
        end

        count = math.min(count or 0, #pool)

        for _ = 1, count do
            -- Calculate total weight
            local total_weight = 0
            for i, choice in ipairs(pool) do
                if choice.weight and choice.weight > 0 then
                    total_weight = total_weight + choice.weight
                else
                    table.remove(pool, i)
                end
            end

            -- If all weights are 0, just pick uniformly
            local selected_index

            if total_weight <= 0 then
                selected_index = pseudorandom("the_great_vote", 1, #pool)
            else
                local r = pseudorandom("the_great_vote", 0, total_weight)
                local cumulative = 0

                for i, choice in ipairs(pool) do
                    cumulative = cumulative + (choice.weight or 0)
                    if r <= cumulative then
                        selected_index = i
                        break
                    end
                end

                -- Fallback (in case of floating point edge cases)
                selected_index = selected_index or #pool
            end

            -- Add to results
            table.insert(results, pool[selected_index])

            -- Remove from pool (no replacement)
            table.remove(pool, selected_index)
        end

        return results
    end,



}