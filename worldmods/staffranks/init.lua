local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

dofile(modpath .. "/api.lua")
dofile(modpath .. "/ranks.lua")

-- =========================
-- Privilege
-- =========================
core.register_privilege("ranks_gestion", {
    description = S("This privilege allows you to manage ranks"),
    give_to_singleplayer = true
})

-- =========================
-- Defaults
-- =========================
local DEFAULT_RANK  = "Player"
local DEFAULT_COLOR = "#ADFF2F"

-- =========================
-- Player check
-- =========================
local function check_if_player(player_name, sender)
    local player = core.get_player_by_name(player_name)
    if player then
        return true, player
    elseif not core.player_exists(player_name) then
        core.chat_send_player(sender,
            core.colorize("#FF0F0F", "[Error] ") ..
            core.colorize("#FF4040", S("The player @1 doesn't exist.", player_name)))
    else
        core.chat_send_player(sender,
            core.colorize("#FF0F0F", "[Error] ") ..
            core.colorize("#FF4040", S("The player @1 is not connected.", player_name)))
    end
    return false
end

-- =========================
-- Rank commands
-- =========================
local function clear_rank_cmd(sender, player_name)
    local ok, player = check_if_player(player_name, sender)
    if not ok then return end

    local meta = player:get_meta()
    meta:set_string("staffranks:rank", "None")
    meta:set_string("staffranks:rank_prefix", DEFAULT_RANK)
    meta:set_string("staffranks:rank_color", DEFAULT_COLOR)

    staffranks.init_nametag(player)

    core.chat_send_player(sender,
        core.colorize("#8dff23", "[StaffRanks] ") ..
        core.colorize("#b7ff74", S("@1's rank has been reset to Player.", player_name)))
    core.chat_send_player(player_name,
        core.colorize("#8dff23", "[StaffRanks] ") ..
        core.colorize("#b7ff74", S("Your rank has been reset to Player by @1.", sender)))
end

local function add_rank_cmd(sender, player_name, rankname)
    local ok, player = check_if_player(player_name, sender)
    if not ok then return end

    if staffranks.rank_exist(rankname) then
        staffranks.add_rank(player_name, rankname)
        staffranks.init_nametag(player)

        core.chat_send_player(sender,
            core.colorize("#8dff23", "[StaffRanks] ") ..
            core.colorize("#b7ff74", S("@1's rank has been set to @2.", player_name, rankname)))
        core.chat_send_player(player_name,
            core.colorize("#8dff23", "[StaffRanks] ") ..
            core.colorize("#b7ff74", S("Your rank has been set to @1 by @2.", rankname, sender)))
    else
        core.chat_send_player(sender,
            core.colorize("#FF0F0F", "[Error] ") ..
            core.colorize("#FF4040", S("The @1 rank does not exist.", rankname)))
    end
end

local function view_rank_cmd(sender, player_name)
    local ok, player = check_if_player(player_name, sender)
    if not ok then return end

    local meta = player:get_meta()
    local rank = meta:get_string("staffranks:rank_prefix")
    if rank == "" or rank == "None" then
        rank = DEFAULT_RANK
    end

    core.chat_send_player(sender,
        core.colorize("#8dff23", "[StaffRanks] ") ..
        core.colorize("#b7ff74", S("The player @1 has the rank @2.", player_name, rank)))
end

-- =========================
-- Chat commands
-- =========================
if core.get_modpath("lib_chatcmdbuilder") then
    local cmd = chatcmdbuilder.register("ranks", {
        description = S("Add, clear, view or list all ranks of players."),
        params = "<add | clear | view | list> [<player>]",
        privs = { ranks_gestion = true },
    })

    cmd:sub("add :name:text :rank:text", function(sender, player_name, rankname)
        add_rank_cmd(sender, player_name, rankname)
    end)

    cmd:sub("clear :name:text", function(sender, player_name)
        clear_rank_cmd(sender, player_name)
    end)

    cmd:sub("view :name:text", function(sender, player_name)
        view_rank_cmd(sender, player_name)
    end)

    cmd:sub("list", function(sender)
        core.chat_send_player(sender, S("List of all ranks: @1", staffranks.rankslist()))
    end)
else
    core.register_chatcommand("add_rank", {
        params = "<name> <rank>",
        privs = { ranks_gestion = true },
        func = function(sender, param)
            local p, r = param:match("^(%S+)%s+(%S+)$")
            if not p or not r then return false end
            if r == "clear" then
                clear_rank_cmd(sender, p)
            else
                add_rank_cmd(sender, p, r)
            end
        end
    })

    core.register_chatcommand("ranks_list", {
        func = function(sender)
            core.chat_send_player(sender, S("List of all ranks: @1", staffranks.rankslist()))
        end
    })

    core.register_chatcommand("view_rank", {
        params = "<name>",
        func = function(sender, param)
            view_rank_cmd(sender, param)
        end
    })
end

-- =========================
-- Join / upgrade players
-- =========================
core.register_on_newplayer(function(player)
    local meta = player:get_meta()
    meta:set_string("staffranks:rank", "None")
    meta:set_string("staffranks:rank_prefix", DEFAULT_RANK)
    meta:set_string("staffranks:rank_color", DEFAULT_COLOR)
end)

core.register_on_joinplayer(function(player)
    local meta = player:get_meta()

    -- restore rank if logged out while AFK
    local r = meta:get_string("staffranks:afk_original_rank")
    local c = meta:get_string("staffranks:afk_original_color")
    if r ~= "" then
        meta:set_string("staffranks:rank_prefix", r)
        meta:set_string("staffranks:rank_color", c)
        meta:set_string("staffranks:afk_original_rank", "")
        meta:set_string("staffranks:afk_original_color", "")
    end

    if meta:get_string("staffranks:rank_prefix") == "" then
        meta:set_string("staffranks:rank_prefix", DEFAULT_RANK)
        meta:set_string("staffranks:rank_color", DEFAULT_COLOR)
    end

    staffranks.init_nametag(player)
end)

for _, player in ipairs(core.get_connected_players()) do
    staffranks.init_nametag(player)
end

-- =========================
-- AFK SYSTEM (FIXED)
-- =========================
local AFK_TIME  = 6 * 60
local afk_rank  = "Idle"
local afk_color = "#b8860b"

local activity = {}

core.register_globalstep(function()
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        local meta = player:get_meta()
        local now  = os.time()
        local pos  = player:get_pos()

        activity[name] = activity[name] or {
            last_action = now,
            last_pos = pos,
            afk = false
        }

        if pos and (not activity[name].last_pos or
           vector.distance(pos, activity[name].last_pos) > 0.01) then

            activity[name].last_action = now
            activity[name].last_pos = pos

            if activity[name].afk then
                local r = meta:get_string("staffranks:afk_original_rank")
                local c = meta:get_string("staffranks:afk_original_color")
                if r ~= "" then
                    meta:set_string("staffranks:rank_prefix", r)
                    meta:set_string("staffranks:rank_color", c)
                end
                meta:set_string("staffranks:afk_original_rank", "")
                meta:set_string("staffranks:afk_original_color", "")
                staffranks.init_nametag(player)
                activity[name].afk = false
            end
        end

        if not activity[name].afk and now - activity[name].last_action >= AFK_TIME then
            meta:set_string("staffranks:afk_original_rank",
                meta:get_string("staffranks:rank_prefix"))
            meta:set_string("staffranks:afk_original_color",
                meta:get_string("staffranks:rank_color"))

            meta:set_string("staffranks:rank_prefix", afk_rank)
            meta:set_string("staffranks:rank_color", afk_color)
            staffranks.init_nametag(player)
            activity[name].afk = true
        end
    end
end)

core.register_on_leaveplayer(function(player)
    activity[player:get_player_name()] = nil
end)

-- =========================
-- Chat handler (Discord ready)
-- =========================
core.register_on_chat_message(function(name, message)
    local player = core.get_player_by_name(name)
    if not player then return false end

    local meta = player:get_meta()
    local rank = meta:get_string("staffranks:rank_prefix")
    local col  = meta:get_string("staffranks:rank_color")

    if rank == "" then
        rank = DEFAULT_RANK
        col  = DEFAULT_COLOR
    end

    local display_name = core.colorize(col, "["..rank.."] "..name)

    if dcwebhook and dcwebhook.send_webhook then
        dcwebhook.send_webhook({ content = "["..rank.."] "..message })
    end

    return false, display_name, message
end)
