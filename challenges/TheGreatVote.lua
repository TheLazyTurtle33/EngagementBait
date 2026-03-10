SMODS.Challenge({
    key = "the_great_vote",
    rules = {
        custom = {
            { id = "the_great_vote" },
        },
    },
    jokers = {
        { id = 'j_eb_the_great_vote', eternal = true },
    },
    deck = {
        type = 'Challenge Deck'
    },
    unlocked = function()
        return true
    end

})