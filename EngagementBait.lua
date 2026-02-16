




-- local twitch = require "twitch"

-- -- Creates an "echo" command
-- local function echo(client, channel, username, ...)
--     local msg = ""
--     for _, value in ipairs({...}) do
--         msg = msg .. value .. " "
--     end

--     -- Sends the data received
--     client:send(channel, string.format("@%s %s", username, msg))
-- end

-- -- Connects to Twitch server
-- local client = twitch.connect("<USERNAME>", "<OAUTH_OKEN>")

-- -- Joins to our channel
-- client:join("<CHANNEL>")

-- -- Sends a message in our channel
-- client:send("Hello world!")

-- -- Adds a command
-- client:attach("echo", "<CHANNEL>", echo)

-- -- Closes the connection
-- client:close()

if not EngagementBait then
    ---@class EngagementBait
    EngagementBait = {}
end


EngagementBait.mod = SMODS.current_mod





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
