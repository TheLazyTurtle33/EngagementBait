SMODS.Joker {
    key = "the_secret",
    atlas = 'Joker', pos = { x = 5, y = 0 },
    config = {
       extra = {
            xmult_raw = 2,
            xmult_full = 50,
            xmult = 2,
            secret = "",
    	}
    },
    loc_vars = function (self, info_queue, card)
        return {
           vars = {
            	card.ability.extra.xmult_raw,
            	card.ability.extra.xmult_full,
                card.ability.extra.xmult,
                
           }
        }
    end,
    rarity = 2,
    cost = 6,
    unloxed = true,
    descover = false,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
        	return {
                extra = { xmult = card.ability.extra.xmult } }
        end
    end,

    update = function (self, card, context)
        Twitch.Chat.check_for_chats()
    end,
    set_badges = function(self, card, badges)
        if EngagementBait.mod.config.linked then
            badges[#badges+1] = create_badge("Linked", G.C.GREEN, G.C.BLACK, 1.2 )
        else
            badges[#badges+1] = create_badge("Not Linked", G.C.RED, G.C.BLACK, 1.2 )
        end
 	end,

    add_to_deck = function (self, card, deck)
        card.ability.extra.secret = self.RandomWord()
        Twitch.Chat.register_callback(card, self.chat)
    end,

    remove_from_deck = function (self, card, deck)
        Twitch.Chat.unregister_callback(card)
    end,
    load = function (self, card)
        Twitch.Chat.register_callback(card, self.chat)
    end,

    chat = function (card, data)
        local c = G.C.RED
        if data.message:lower():match("^%w+") == card.ability.extra.secret:lower() then
            card.ability.extra.xmult = card.ability.extra.xmult_full
            c = G.C.GREEN
            card:juice_up(0.1, 0.2)
        end
        attention_text({
            text = data.message:match("^%w+"),
            scale = 0.5,
            major = card,
            hold = 2.5,
            fade = 1.5,
            -- align = 'cm',
            offset = { x = 0, y = -1.5 },
            colour = c,
        })
    end,

    RandomWord = function ()
        local list = io.open(EngagementBait.mod.path .. "Words/" .. EngagementBait.mod.config.wordlist .. ".txt", "r"):read("*a")
        local words = {}
        for s in string.gmatch(list, "([^\r\n]+)") do
            table.insert(words, s)
        end
        local index = pseudorandom("the_secret",0,#words)
        print(words[index])
        return words[index]
    end

}
