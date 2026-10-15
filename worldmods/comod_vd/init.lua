local modname = core.get_current_modname()
local S = core.get_translator(modname)

-- =========================
-- Settings
-- =========================

local VOTE_DURATION = 3 * 60
local DAY_TIME = 6000
local DIAMOND_COST = 3

local VOTE_START_HOUR = 19
local VOTE_END_HOUR = 6

local HUD_ID = modname .. ":vote_hud"

local vote = nil


-- =========================
-- Time helpers
-- =========================

local function get_game_hour()
    local timeofday = core.get_timeofday()
    return timeofday * 24
end


local function is_vote_time()
    local hour = get_game_hour()

    return hour >= VOTE_START_HOUR or hour < VOTE_END_HOUR
end


local function get_time_string()
    local hour = get_game_hour()

    local h = math.floor(hour)
    local minutes = math.floor((hour - h) * 60)

    return string.format("%02d:%02d", h, minutes)
end


-- =========================
-- Inventory helpers
-- =========================

local function count_diamonds(player)
    local inv = player:get_inventory()

    if not inv then
        return 0
    end

    local count = 0
    local size = inv:get_size("main")

    for i = 1, size do
        local stack = inv:get_stack("main", i)

        if stack and stack:get_name() == "default:diamond" then
            count = count + stack:get_count()
        end
    end

    return count
end


local function remove_diamonds(player, amount)
    local inv = player:get_inventory()

    if not inv then
        return false
    end

    local stack = ItemStack("default:diamond " .. amount)
    local removed = inv:remove_item("main", stack)

    return removed:get_count() == amount
end


-- =========================
-- Player helpers
-- =========================

local function is_idle(player)
    if not player then
        return false
    end

    local meta = player:get_meta()

    local rank_prefix = meta:get_string("staffranks:rank_prefix")
    local rank = meta:get_string("staffranks:rank")
    local rank_name = meta:get_string("staffranks:rank_name")

    rank_prefix = rank_prefix:lower()
    rank = rank:lower()
    rank_name = rank_name:lower()

    if rank_prefix:find("idle", 1, true) then
        return true
    end

    if rank:find("idle", 1, true) then
        return true
    end

    if rank_name:find("idle", 1, true) then
        return true
    end

    return false
end


local function get_connected_names()
    local names = {}

    for _, player in ipairs(core.get_connected_players()) do
        names[player:get_player_name()] = true
    end

    return names
end


local function total_eligible()
    if not vote then
        return 0
    end

    local count = 0

    for name in pairs(vote.eligible) do
        if core.get_player_by_name(name) then
            count = count + 1
        end
    end

    return count
end


-- =========================
-- Vote announcements
-- =========================

local function announce_vote(name, yes)
    local vote_text

    if yes then
        vote_text = core.colorize("#FFFF00", "YES")
    else
        vote_text = core.colorize("#FFFF00", "NO")
    end

    core.chat_send_all(
        core.colorize("#FFD700", "[Vote Day] ") ..
        core.colorize("#55FF55", name) ..
        core.colorize("#FFFF00", " voted ") ..
        vote_text ..
        core.colorize("#FFFF00", " for the day.")
    )
end


local function announce_idle_vote(name)
    core.chat_send_all(
        core.colorize("#FFD700", "[Vote Day] ") ..
        core.colorize("#55FF55", name) ..
        core.colorize(
            "#FFFF00",
            " is Idle, automatically voted YES for the day."
        )
    )
end


-- =========================
-- HUD
-- =========================

local function update_hud(player)
    if not vote then
        local hud_id = player:get_meta():get_int(HUD_ID)

        if hud_id >= 0 then
            player:hud_remove(hud_id)
            player:get_meta():set_int(HUD_ID, -1)
        end

        return
    end

    local name = player:get_player_name()

    if vote.eligible[name]
        and vote.votes[name] == nil
        and not is_idle(player)
    then
        local old_hud_id = player:get_meta():get_int(HUD_ID)

        if old_hud_id >= 0 then
            player:hud_remove(old_hud_id)
        end

        local hud_id = player:hud_add({
            hud_elem_type = "text",

            position = {
                x = 0,
                y = 0.42
            },

            offset = {
                x = 20,
                y = 0
            },

            text =
                "Started day time voting.\n" ..
                "/yes to vote YES, /no to vote NO",

            alignment = {
                x = -1,
                y = 0
            },

            scale = {
                x = 100,
                y = 100
            },

            number = 0xFFFFFF,
        })

        player:get_meta():set_int(HUD_ID, hud_id)

    else
        local hud_id = player:get_meta():get_int(HUD_ID)

        if hud_id >= 0 then
            player:hud_remove(hud_id)
            player:get_meta():set_int(HUD_ID, -1)
        end
    end
end


local function remove_all_huds()
    for _, player in ipairs(core.get_connected_players()) do
        local meta = player:get_meta()

        local hud_id = meta:get_int(HUD_ID)

        if hud_id >= 0 then
            player:hud_remove(hud_id)
        end

        meta:set_int(HUD_ID, -1)
    end
end


-- =========================
-- Messages
-- =========================

local function broadcast(msg)
    core.chat_send_all(
        core.colorize("#FFD700", "[Vote Day] ") ..
        msg
    )
end


-- =========================
-- Finish vote
-- =========================

local function finish_vote(success, reason)
    if not vote then
        return
    end

    remove_all_huds()

    if success then
        core.set_timeofday(DAY_TIME / 24000)

        broadcast(
            "Vote passed! Day time has been set."
        )
    else
        broadcast(
            reason or "Vote failed."
        )
    end

    vote = nil
end


-- =========================
-- Vote evaluation
-- =========================

local function evaluate_vote()
    if not vote then
        return
    end

    local eligible = total_eligible()

    if eligible <= 0 then
        finish_vote(
            false,
            "Vote failed. There are no eligible players."
        )

        return
    end

    local yes = 0
    local no = 0

    for name in pairs(vote.eligible) do
        local v = vote.votes[name]

        local player = core.get_player_by_name(name)

        -- Idle players automatically vote YES.
        if player and is_idle(player) then
            if v ~= true then
                vote.votes[name] = true

                if not vote.idle_announced[name] then
                    vote.idle_announced[name] = true
                    announce_idle_vote(name)
                end
            end

            v = true
        end

        if v == true then
            yes = yes + 1
        elseif v == false then
            no = no + 1
        end
    end

    -- 50% OR MORE = PASS
    if yes >= eligible / 2 then
        finish_vote(true)
        return
    end

    -- Everyone voted but 50% was not reached.
    if yes + no >= eligible then
        finish_vote(
            false,
            "Vote failed. At least 50% of eligible players must vote yes."
        )
    end
end


-- =========================
-- Start vote
-- =========================

local function start_vote(starter)
    local starter_name = starter:get_player_name()

    if not is_vote_time() then
        core.chat_send_player(
            starter_name,
            core.colorize(
                "#FF4040",
                "You can only start a day vote between 7:00 PM and 6:00 AM."
            )
        )

        return
    end

    if vote then
        core.chat_send_player(
            starter_name,
            core.colorize(
                "#FF4040",
                "A day time vote is already in progress."
            )
        )

        return
    end

    if count_diamonds(starter) < DIAMOND_COST then
        core.chat_send_player(
            starter_name,
            core.colorize(
                "#FF4040",
                "You need 3 default:diamond to start a vote for day."
            )
        )

        return
    end

    if not remove_diamonds(starter, DIAMOND_COST) then
        core.chat_send_player(
            starter_name,
            core.colorize(
                "#FF4040",
                "You need 3 default:diamond to start a vote for day."
            )
        )

        return
    end

    vote = {
        started = os.time(),
        expires = os.time() + VOTE_DURATION,

        eligible = get_connected_names(),

        votes = {},

        idle_announced = {},
    }

    -- Starter automatically votes YES.
    vote.votes[starter_name] = true

    announce_vote(starter_name, true)

    -- Idle players automatically vote YES.
    for name in pairs(vote.eligible) do
        local player = core.get_player_by_name(name)

        if player and is_idle(player) then
            vote.votes[name] = true

            if name ~= starter_name then
                vote.idle_announced[name] = true
                announce_idle_vote(name)
            end
        end
    end

    broadcast(
        starter_name ..
        " started a day time vote. /yes to vote YES, /no to vote NO."
    )

    for _, player in ipairs(core.get_connected_players()) do
        update_hud(player)
    end

    evaluate_vote()
end


-- =========================
-- Cast vote
-- =========================

local function cast_vote(player, yes)
    if not vote then
        core.chat_send_player(
            player:get_player_name(),
            core.colorize(
                "#FF4040",
                "There is no day time vote in progress."
            )
        )

        return
    end

    local name = player:get_player_name()

    -- Must have been online when vote started.
    if not vote.eligible[name] then
        core.chat_send_player(
            name,
            core.colorize(
                "#FF4040",
                "You were not connected when this vote started."
            )
        )

        return
    end

    -- Idle players are always YES.
    if is_idle(player) then
        vote.votes[name] = true

        if not vote.idle_announced[name] then
            vote.idle_announced[name] = true
            announce_idle_vote(name)
        end

        update_hud(player)
        evaluate_vote()

        return
    end

    -- Prevent changing vote.
    if vote.votes[name] ~= nil then
        core.chat_send_player(
            name,
            core.colorize(
                "#FF4040",
                "You already voted."
            )
        )

        return
    end

    vote.votes[name] = yes

    -- Announce the vote to everyone.
    announce_vote(name, yes)

    update_hud(player)

    -- Private confirmation.
    if yes then
        core.chat_send_player(
            name,
            core.colorize(
                "#55FF55",
                "You voted YES."
            )
        )
    else
        core.chat_send_player(
            name,
            core.colorize(
                "#FF5555",
                "You voted NO."
            )
        )
    end

    evaluate_vote()
end


-- =========================
-- Commands
-- =========================

local function register_command(name, description, func)
    core.register_chatcommand(name, {
        description = description,

        func = function(player_name)
            local player = core.get_player_by_name(player_name)

            if not player then
                return false,
                    "This command can only be used by a player."
            end

            func(player)

            return true
        end,
    })
end


register_command(
    "vote_day",
    "Start a vote to change the time to day for 3 diamonds.",
    start_vote
)


register_command(
    "vd",
    "Start a vote to change the time to day for 3 diamonds.",
    start_vote
)


register_command(
    "yes",
    "Vote YES in the current day time vote.",
    function(player)
        cast_vote(player, true)
    end
)


register_command(
    "no",
    "Vote NO in the current day time vote.",
    function(player)
        cast_vote(player, false)
    end
)


-- =========================
-- Join handling
-- =========================

core.register_on_joinplayer(function(player)
    player:get_meta():set_int(HUD_ID, -1)

    if vote then
        -- Players joining after the vote started
        -- are not eligible.
        update_hud(player)
    end
end)


-- =========================
-- Leave handling
-- =========================

core.register_on_leaveplayer(function(player)
    if not vote then
        return
    end

    local name = player:get_player_name()

    -- Remove disconnected players from the vote.
    vote.eligible[name] = nil
    vote.votes[name] = nil
    vote.idle_announced[name] = nil

    evaluate_vote()
end)


-- =========================
-- Vote timeout
-- =========================

core.register_globalstep(function()
    if not vote then
        return
    end

    if os.time() >= vote.expires then
        evaluate_vote()

        if vote then
            finish_vote(
                false,
                "Vote cancelled. The 3 minute voting period expired without at least 50% voting yes."
            )
        end
    end
end)


-- =========================
-- Initialize HUD metadata
-- =========================

for _, player in ipairs(core.get_connected_players()) do
    player:get_meta():set_int(HUD_ID, -1)
end