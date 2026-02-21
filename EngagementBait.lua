
if not EngagementBait then
    ---@class EngagementBait
    EngagementBait = {}
end


EngagementBait.mod = SMODS.current_mod

SMODS.Atlas({
    key = "Joker",
    px = 71,
    py = 95,
    path = "jokers.png"
})

-- Load all joker files from the jokers folder
function EngagementBait.load_files(dir)
    local files = NFS.getDirectoryItems(SMODS.current_mod.path .. dir)
    for _, file in pairs(files) do
        if string.sub(file, string.len(file) - 3) == '.lua' then
            assert(SMODS.load_file(dir .. "/" .. file))()
        end
    end
end

EngagementBait.load_files("twitch")
EngagementBait.load_files("ui")
EngagementBait.load_files("jokers")


Twitch.load()
Twitch.startServer()
Twitch.set_start_time()
