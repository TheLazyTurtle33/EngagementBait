SMODS.Joker {
    key = "the_great_vote",
    config = {
       extra = {
            text = "?????",
            active = {},
            choices = { -- 5
                {text = "example", weight = 0, effect = {chips = 0, xchips = 0, mult = 0, xmult = 0, dollars = 0, sell_price_dif = 0, self_destruct = false, joker_copy = nil, extra_slots = {joker = 0, consumeable = 0, hand = 0}, hands_dif = 0, discgard_dif = 0, level_ups = 0, balance = false, staking = true}},
                {text = "Nothing...", weight = 0.8, effect = {}, staking = true},
                {text = "Self Destruct", weight = 0.01, effect = {self_destruct = true}, staking = false},
                {text = "+100 Chips", weight = 0.9, effect = {chips = 100}, staking = true},
                {text = "X2 Chips", weight = 0.5, effect = {xchips = 2}, staking = true},
                {text = "+50 Mult", weight = 0.85, effect = {mult = 50}, staking = true},
                {text = "X2 mult", weight = 0.5, effect={ xmult = 2}, staking = true},
                {text = "X5 mult", weight = 0.4, effect = {xmult = 5}, staking = true},
                {text = "X0.75 mult", weight = 0.4, effect = {xmult = 0.75}, staking = true},
                {text = "-50 Chips", weight = 0.4, effect = {chips = -50}, staking = true},
                {text = "X0.5 Chips", weight = 0.3, effect = {xchips = 0.5}, staking = true},
                -- {text = "Photo", weight = 0.1, effect = {joker_copy = "j_photograph"}, staking = false},
                -- {text = "Chad", weight = 0.1, effect = {joker_copy = "j_hanging_chad"}, staking = false},
                -- {text = "Chicot", weight = 0.2, effect = {joker_copy = "j_chicot"}, staking = false},
                -- {text = "Hand size +1", weight = 0.5, effect = {extra_slots = {hand = 1}}, staking = true},
                -- {text = "Hand size -1", weight = 0.5, effect = {extra_slots = {hand = -1}}, staking = true},
                {text = "LEVEL UP!", weight = 0.1, effect = {level_ups = 1}, staking = true},
                {text = "LEVEL DOWN!", weight = 0.08, effect = {level_ups = -1}, staking = true},
                {text = "Yes but choice 1", weight = 0.02, effect = {xchips = 2}, staking = true},
                {text = "Yes but choice 2", weight = 0.02, effect = {xmult = 2}, staking = true},
                {text = "Yes but choice 3", weight = 0.02, effect = {xmult = 3}, staking = true},
                {text = "Yes but choice 4", weight = 0.02, effect = {xmult = 4}, staking = true},
                {text = "Yes but choice 5", weight = 0.02, effect = {xmult = 5}, staking = true},
                {text = "Plasma", weight = 0.2, effect = {balance = true}, staking = false},





            },
    	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
           }
        } 
    end,
    rarity = 4,
    cost = 20,
    unloxed = true,
    descover = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.before then
            if not card.ability.extra.active then
                return {
                    message = "NOT READYT"
                }
            end
        end
        
        if context.setting_blind and not context.skip_blind then
            local choices = self.get_weighted_choices(card.ability.extra.choices, 5)
            local choice_formated = {}
            for i, choice in ipairs(choices) do
                table.insert(choice_formated, {title = choice.text})
            end
            Twitch.start_poll("The Great Vote", choice_formated, EngagementBait.mod.config.poll_duration)
            return { message = "Vote Started!" }
        end
        
        if context.blind_defeated then
            local eff = self.get_weighted_choices(card.ability.extra.choices, 1)[1]
            print(eff)
            self.poll_ended(card, eff)            
        end
        
        if context.joker_main then
            if not card.ability.extra.active or card.ability.extra.active == {} then
                return {
                    message = "NOT READYT"
                }
            end

            local r = {}

            for i, effect in ipairs(card.ability.extra.active) do
                -- effect = {chips = 0, xchips = 0, mult = 0, xmult = 0, dollars = 0, sell_price_dif = 0, self_destruct = false, joker_copy = nil, extra_slots = {joker = 0, consumeable = 0, hand = 0}, hands_dif = 0, discgard_dif = 0}
                if effect.self_destruct then
                    attention_text({
                            text = "Get Fucked",
                            scale = 0.5,
                            hold = 3,
                            fade = 3,
                            major = card,
                            colour = G.C.RED,
                        })
                    SMODS.destroy_cards(card, nil, nil, false)
                    return
                end

                if effect.chips then
                    if not r.chips then
                        r.chips = effect.chips
                    else
                        r.chips = r.chips + effect.chips
                    end
                end

                if effect.mult then
                    if not r.mult then
                        r.mult = effect.mult
                    else
                        r.mult = r.mult + effect.mult
                    end
                end

                if effect.xchips then
                    if not r.xchips then
                        r.xchips = effect.xchips
                    else
                        r.xchips = r.xchips * effect.xchips
                    end
                end

                if effect.xmult then
                    if not r.xmult then
                        r.xmult = effect.xmult
                    else
                        r.xmult = r.xmult * effect.xmult
                    end
                end

                if effect.dollars then
                    if not r.dollars then
                        r.dollars = effect.dollars
                    else
                        r.dollars = r.dollars + effect.dollars
                    end
                end

                if effect.level_ups then
                    if not r.level_up then
                        r.level_up = effect.level_ups
                    else
                        r.level_up = r.level_up + effect.level_ups
                    end
                end
                
                if effect.balance then
                    r.balance = effect.balance
                end

                if effect.sell_price_dif then
                    card.sell_cost =  card.sell_cost + effect.sell_price_dif
                    card.sell_cost_label = tostring(card.sell_cost)
                end


            end
            print(r)
            return r
        end
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
                card.ability.extra.text = card.ability.extra.text .. " & " .. choice.text
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
                break
            end
        end
        
    end,

    add_to_deck = function (self, card, from_debuff)
        Twitch.register_poll_end_callback(card, self.poll_ended)
    end,

    remove_from_deck = function (self, card, from_debuff)
        Twitch.unregister_poll_end_callback()
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