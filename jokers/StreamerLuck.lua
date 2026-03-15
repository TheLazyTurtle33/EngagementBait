SMODS.Joker {
    key = "streamer_luck",
    atlas = 'Joker', pos = { x = 0, y = 0 },
    config = {
       extra = {
       		common_mod = 0.5,
            uncommon_mod = 0.75,
            rare_mod = 1.25,
    	}
    },
    rarity = 2,
    cost = 6,
    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint then
            return {
                numerator = context.denominator
            }
        end
    end,

    add_to_deck = function (self, card, deck)
        G.GAME.common_mod = G.GAME.common_mod * card.ability.extra.common_mod
        G.GAME.uncommon_mod = G.GAME.uncommon_mod * card.ability.extra.uncommon_mod
        G.GAME.rare_mod = G.GAME.rare_mod * card.ability.extra.rare_mod
    end,

    remove_from_deck = function (self, card, deck)
        G.GAME.common_mod = G.GAME.common_mod / card.ability.extra.common_mod
        G.GAME.uncommon_mod = G.GAME.uncommon_mod / card.ability.extra.uncommon_mod
        G.GAME.rare_mod = G.GAME.rare_mod / card.ability.extra.rare_mod
    end
}