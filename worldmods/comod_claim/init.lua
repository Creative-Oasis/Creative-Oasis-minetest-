local storage = minetest.get_mod_storage()
local S = minetest.get_translator("comod_claim")

local CLAIM_PRIV = "comod_claim"

-- =========================================================
-- STORAGE HELPERS
-- =========================================================

local function get_event_name()
    return storage:get_string("event_name")
end

local function is_event_active()
    return storage:get_string("event_active") == "true"
end

local function get_join_message()
    return storage:get_string("join_message")
end

local function get_message_version()
    return storage:get_string("message_version")
end

local function increase_message_version()
    local version = tonumber(get_message_version()) or 0
    version = version + 1

    storage:set_string(
        "message_version",
        tostring(version)
    )

    return tostring(version)
end

local function reset_player_dismissal(player)
    if not player or not player:is_player() then
        return
    end

    storage:set_string(
        "dismissed_" .. player:get_player_name(),
        ""
    )
end

-- =========================================================
-- COLORS
-- =========================================================

local function green(text)
    return minetest.colorize("#55FF55", text)
end

local function yellow(text)
    return minetest.colorize("#FFFF55", text)
end

local function red(text)
    return minetest.colorize("#FF5555", text)
end

local function cyan(text)
    return minetest.colorize("#55FFFF", text)
end

local function gold(text)
    return minetest.colorize("#FFAA00", text)
end

local function white(text)
    return minetest.colorize("#FFFFFF", text)
end

-- =========================================================
-- CLAIM STORAGE
-- =========================================================

local function get_claims()
    local raw = storage:get_string("claims")

    if raw == "" then
        return {}
    end

    local claims = {}

    for entry in raw:gmatch("[^|]+") do
        local name, timestamp =
            entry:match("^(.-);(%d+)$")

        if name and timestamp then
            table.insert(claims, {
                name = name,
                timestamp = tonumber(timestamp)
            })
        end
    end

    return claims
end

local function save_claims(claims)
    local data = {}

    for _, claim in ipairs(claims) do
        table.insert(
            data,
            claim.name .. ";" .. tostring(claim.timestamp)
        )
    end

    storage:set_string(
        "claims",
        table.concat(data, "|")
    )
end

local function player_has_claimed(player_name)
    local claims = get_claims()

    for _, claim in ipairs(claims) do
        if claim.name == player_name then
            return true
        end
    end

    return false
end

local function add_claim(player_name)
    local claims = get_claims()

    -- Extra protection against duplicate claims
    for _, claim in ipairs(claims) do
        if claim.name == player_name then
            return false
        end
    end

    table.insert(claims, {
        name = player_name,
        timestamp = os.time()
    })

    save_claims(claims)

    return true
end

-- =========================================================
-- JOIN MESSAGE / POPUP
-- =========================================================

local function show_join_popup(player)
    if not player or not player:is_player() then
        return
    end

    if not is_event_active() then
        return
    end

    local player_name =
        player:get_player_name()

    -- Do not show popup to someone who already claimed
    if player_has_claimed(player_name) then
        return
    end

    local message = get_join_message()

    if message == "" then
        return
    end

    local version =
        get_message_version()

    local dismissed =
        storage:get_string(
            "dismissed_" .. player_name
        )

    -- Only hide if the player dismissed this exact message
    if dismissed == version then
        return
    end

    local title =
        S("Event Message")

    local button_text =
        S("Happy to claim!")

    local safe_title =
        minetest.formspec_escape(title)

    local safe_message =
        minetest.formspec_escape(message)

    local safe_button =
        minetest.formspec_escape(button_text)

    -- Center all text
    local formspec =
        "formspec_version[4]" ..
        "size[10,6]" ..
        "bgcolor[#202020DD]" ..

        "style_type[label;font_size=20;align=center]" ..

        "label[5,0.65;" ..
        safe_title ..
        "]" ..

        "style_type[label;font_size=16;align=center]" ..

        "label[5,1.65;" ..
        safe_message ..
        "]" ..

        "style_type[button;align=center]" ..

        "button[2.5,4.5;5,0.9;happy_claim;" ..
        safe_button ..
        "]"

    minetest.show_formspec(
        player_name,
        "comod_claim:message",
        formspec
    )
end

-- =========================================================
-- PRIVILEGE
-- =========================================================

minetest.register_privilege(
    CLAIM_PRIV,
    {
        description = "Can manage claim events",
        give_to_singleplayer = false
    }
)

-- =========================================================
-- PLAYER JOIN
-- =========================================================

minetest.register_on_joinplayer(function(player)

    -- Event notification
    minetest.after(3, function()

        if not player or not player:is_player() then
            return
        end

        if not is_event_active() then
            return
        end

        local player_name =
            player:get_player_name()

        -- Do not send event message to
        -- someone who already claimed
        if player_has_claimed(player_name) then
            return
        end

        local event_name =
            get_event_name()

        minetest.chat_send_player(
            player_name,
            cyan("[Claim] ") ..
            gold(
                S(
                    "The \"@1\" event is happening right now!",
                    event_name
                )
            )
        )

        minetest.chat_send_player(
            player_name,
            cyan("[Claim] ") ..
            white(
                S(
                    "Type /claim to join the prize pool."
                )
            )
        )
    end)

    -- Join popup
    minetest.after(3.5, function()

        if not player or not player:is_player() then
            return
        end

        show_join_popup(player)

    end)
end)

-- =========================================================
-- FORMSPEC CALLBACK
-- =========================================================

minetest.register_on_player_receive_fields(
    function(player, formname, fields)

        if formname ~= "comod_claim:message" then
            return
        end

        if not player or not player:is_player() then
            return
        end

        local player_name =
            player:get_player_name()

        if fields.happy_claim then

            -- If they already claimed, just close it
            if player_has_claimed(player_name) then
                minetest.close_formspec(
                    player_name,
                    "comod_claim:message"
                )
                return
            end

            -- Remember that this player dismissed
            -- this exact message version
            local version =
                get_message_version()

            storage:set_string(
                "dismissed_" .. player_name,
                version
            )

            minetest.close_formspec(
                player_name,
                "comod_claim:message"
            )
        end
    end
)

-- =========================================================
-- /CLAIM
-- =========================================================

minetest.register_chatcommand(
    "claim",
    {
        description = "Join the current claim event",

        privs = {},

        func = function(name)

            if not is_event_active() then

                return false,
                    red(
                        "[Claim] " ..
                        S(
                            "There is currently no active event to claim."
                        )
                    )
            end

            -- Only one claim per event
            if player_has_claimed(name) then

                -- Make sure popup is closed
                minetest.close_formspec(
                    name,
                    "comod_claim:message"
                )

                return false,
                    yellow(
                        "[Claim] " ..
                        S(
                            "You have already joined this event."
                        )
                    )
            end

            -- Add player exactly once
            local added =
                add_claim(name)

            if not added then
                return false,
                    yellow(
                        "[Claim] " ..
                        S(
                            "You have already joined this event."
                        )
                    )
            end

            -- Mark message as dismissed
            storage:set_string(
                "dismissed_" .. name,
                get_message_version()
            )

            -- Close popup immediately after claiming
            minetest.close_formspec(
                name,
                "comod_claim:message"
            )

            local event_name =
                get_event_name()

            return true,
                green(
                    "[Claim] " ..
                    S(
                        "You joined the \"@1\" prize pool!",
                        event_name
                    )
                )
        end
    }
)

-- =========================================================
-- /CLAIM_START
-- =========================================================

minetest.register_chatcommand(
    "claim_start",
    {
        description = "Start a new claim event",

        privs = {
            [CLAIM_PRIV] = true
        },

        params = "<event name>",

        func = function(name, param)

            param = param:trim()

            if param == "" then

                return false,
                    red(
                        "[Claim] " ..
                        S(
                            "Usage: /claim_start <event name>"
                        )
                    )
            end

            -- Start new event
            storage:set_string(
                "event_name",
                param
            )

            storage:set_string(
                "event_active",
                "true"
            )

            -- Fresh claim list
            storage:set_string(
                "claims",
                ""
            )

            -- New event version
            increase_message_version()

            -- Reset popup dismissal
            for _, player in ipairs(
                minetest.get_connected_players()
            ) do

                reset_player_dismissal(player)

            end

            minetest.chat_send_all(
                cyan("[Claim] ") ..
                green(
                    S(
                        "A new event has started: \"@1\"!",
                        param
                    )
                )
            )

            return true,
                green(
                    "[Claim] " ..
                    S(
                        "Claim event started successfully."
                    )
                )
        end
    }
)

-- =========================================================
-- /CLAIM_END
-- =========================================================

minetest.register_chatcommand(
    "claim_end",
    {
        description = "End the current claim event",

        privs = {
            [CLAIM_PRIV] = true
        },

        func = function()

            if not is_event_active() then

                return false,
                    yellow(
                        "[Claim] " ..
                        S(
                            "There is no active claim event."
                        )
                    )
            end

            local event_name =
                get_event_name()

            storage:set_string(
                "event_active",
                "false"
            )

            -- Close popup for everyone
            for _, player in ipairs(
                minetest.get_connected_players()
            ) do

                minetest.close_formspec(
                    player:get_player_name(),
                    "comod_claim:message"
                )

            end

            minetest.chat_send_all(
                cyan("[Claim] ") ..
                red(
                    S(
                        "The \"@1\" event has ended.",
                        event_name
                    )
                )
            )

            return true,
                green(
                    "[Claim] " ..
                    S(
                        "Claim event ended successfully."
                    )
                )
        end
    }
)

-- =========================================================
-- /CLAIM_LIST
-- =========================================================

minetest.register_chatcommand(
    "claim_list",
    {
        description = "Show all players who claimed",

        privs = {
            [CLAIM_PRIV] = true
        },

        func = function()

            local claims = get_claims()

            if #claims == 0 then

                return true,
                    yellow(
                        "[Claim] " ..
                        S(
                            "No players have claimed yet."
                        )
                    )
            end

            -- Newest first
            table.sort(
                claims,
                function(a, b)
                    return a.timestamp > b.timestamp
                end
            )

            local lines = {}

            table.insert(
                lines,
                cyan(
                    "========== CLAIM LIST =========="
                )
            )

            for index, claim in ipairs(claims) do

                local date =
                    os.date(
                        "%Y-%m-%d %H:%M:%S",
                        claim.timestamp
                    )

                table.insert(
                    lines,
                    gold("#" .. index) ..
                    " " ..
                    white(claim.name) ..
                    " " ..
                    yellow("(" .. date .. ")")
                )
            end

            table.insert(
                lines,
                cyan(
                    "================================"
                )
            )

            return true,
                table.concat(
                    lines,
                    "\n"
                )
        end
    }
)

-- =========================================================
-- /CLAIM_CLEAR
-- =========================================================

minetest.register_chatcommand(
    "claim_clear",
    {
        description = "Clear the claim list",

        privs = {
            [CLAIM_PRIV] = true
        },

        func = function()

            storage:set_string(
                "claims",
                ""
            )

            -- Reset popup dismissal so players
            -- can claim again from the cleared list
            for _, player in ipairs(
                minetest.get_connected_players()
            ) do

                reset_player_dismissal(player)

            end

            return true,
                green(
                    "[Claim] " ..
                    S(
                        "Claim list cleared."
                    )
                )
        end
    }
)

-- =========================================================
-- /CLAIM_SEND
-- =========================================================

minetest.register_chatcommand(
    "claim_send",
    {
        description = "Set the message shown when players join",

        privs = {
            [CLAIM_PRIV] = true
        },

        params = "<text>",

        func = function(name, param)

            param = param:trim()

            if param == "" then

                return false,
                    red(
                        "[Claim] " ..
                        S(
                            "Usage: /claim_send <text>"
                        )
                    )
            end

            storage:set_string(
                "join_message",
                param
            )

            -- New message version
            increase_message_version()

            -- Reset dismissal for online players
            for _, player in ipairs(
                minetest.get_connected_players()
            ) do

                -- Do not reset already-claimed players
                if not player_has_claimed(
                    player:get_player_name()
                ) then

                    reset_player_dismissal(player)

                end
            end

            -- Show the new message immediately
            for _, player in ipairs(
                minetest.get_connected_players()
            ) do

                if not player_has_claimed(
                    player:get_player_name()
                ) then

                    minetest.after(
                        0.2,
                        function()

                            if player
                                and player:is_player() then

                                show_join_popup(player)

                            end

                        end
                    )
                end
            end

            return true,
                green(
                    "[Claim] " ..
                    S(
                        "Join message updated."
                    )
                )
        end
    }
)