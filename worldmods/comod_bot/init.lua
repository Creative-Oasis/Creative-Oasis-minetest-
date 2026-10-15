-- comod_bot - optimized Luanti <-> Discord bridge
-- Compatible with the existing Main.py relay format.
--
-- Main goals:
--   * Fast Discord -> Luanti chat delivery
--   * Less filesystem I/O
--   * Batch file writes instead of one write per message
--   * Faster Discord identity lookups
--   * Preserve existing commands, reports, auth, debug and chat relays
--
-- Required setting:
--   secure.trusted_mods = comod_bot
--
-- Relay files:
--   Relay/Lua.txt
--   Relay/Python.txt
--   Relay/Report.txt
--   Relay/Debug_action.txt
--   Relay/Auth_request.txt
--   Relay/Auth_response.txt
--   Relay/Discord_Names.txt
--   Relay/Discord_Command.txt
--   Relay/Discord_Command_Response.txt

local insecure = minetest.request_insecure_environment()
if not insecure then
    error("[comod_bot] request_insecure_environment() failed. Add comod_bot to secure.trusted_mods.")
end

local io = insecure.io
local os = insecure.os
local debug_lib = insecure.debug

local MODPATH = minetest.get_modpath(minetest.get_current_modname())

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

local function read_bot_conf()
    local cfg = {}
    local path = MODPATH .. "/bot.conf"
    local file = io.open(path, "r")

    if not file then
        minetest.log(
            "warning",
            "[comod_bot] bot.conf not found: " .. path
        )
        return cfg
    end

    for line in file:lines() do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")

        if line ~= ""
            and not line:match("^#")
            and not line:match("^%[") then

            local key, value =
                line:match("^([%w_]+)%s*=%s*(.-)%s*$")

            if key and value then
                cfg[key] = value
            end
        end
    end

    file:close()
    return cfg
end

local bot_conf = read_bot_conf()

local function conf_bool(value, default)
    if value == nil then
        return default
    end

    value = tostring(value):lower()

    if value == "true"
        or value == "1"
        or value == "yes" then
        return true
    end

    if value == "false"
        or value == "0"
        or value == "no" then
        return false
    end

    return default
end

local function resolve_relay_path(value, default_name)
    if value == nil or value == "" then
        return MODPATH .. "/" .. default_name
    end

    if value:sub(1, 1) == "/" then
        return value
    end

    return MODPATH .. "/" .. value
end

local relay_paths = {
    lua = resolve_relay_path(
        bot_conf.lua_file_path,
        "Relay/Lua.txt"
    ),

    python = resolve_relay_path(
        bot_conf.python_file_path,
        "Relay/Python.txt"
    ),

    report = resolve_relay_path(
        bot_conf.report_file_path,
        "Relay/Report.txt"
    ),

    debug = resolve_relay_path(
        bot_conf.debug_action_file_path,
        "Relay/Debug_action.txt"
    ),

    auth_request = resolve_relay_path(
        bot_conf.auth_request_file_path,
        "Relay/Auth_request.txt"
    ),

    auth_response = resolve_relay_path(
        bot_conf.auth_response_file_path,
        "Relay/Auth_response.txt"
    ),

    identity = resolve_relay_path(
        bot_conf.identity_file_path,
        "Relay/Discord_Names.txt"
    ),

    command = resolve_relay_path(
        bot_conf.command_file_path,
        "Relay/Discord_Command.txt"
    ),

    command_response = resolve_relay_path(
        bot_conf.command_response_file_path,
        "Relay/Discord_Command_Response.txt"
    ),
}

-- ---------------------------------------------------------------------------
-- Relay timing
-- ---------------------------------------------------------------------------

local poll_interval = tonumber(
    bot_conf.relay_cooldown or "0.05"
) or 0.05

if poll_interval < 0.02 then
    poll_interval = 0.02
end

if poll_interval > 1 then
    poll_interval = 1
end

local identity_interval = 2.0

local enable_debug = conf_bool(
    bot_conf.enable_debug,
    false
)

local relay = {
    messages = {},
    reports = {},
    debugs = {},
}

local comod_bot = {}
_G.comod_bot = comod_bot

-- ---------------------------------------------------------------------------
-- Utility helpers
-- ---------------------------------------------------------------------------

local function trim(s)
    return (
        tostring(s or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    )
end

local function strip_newlines(s)
    return tostring(s or ""):gsub(
        "[\r\n]",
        " "
    )
end

local function strip_colors(s)
    s = tostring(s or "")

    if minetest.strip_color then
        s = minetest.strip_color(s)
    end

    s = s:gsub(
        "\27%([^)]*%)",
        ""
    )

    s = s:gsub(
        "\27.",
        ""
    )

    return s
end

local function debug_log(message)
    if enable_debug then
        minetest.log(
            "action",
            "[comod_bot] " .. tostring(message)
        )
    end
end

-- ---------------------------------------------------------------------------
-- File helpers
-- ---------------------------------------------------------------------------

local function read_and_clear(path)
    local file, err = io.open(
        path,
        "r"
    )

    if not file then
        return nil, err
    end

    local data = file:read("*a") or ""
    file:close()

    if data == "" then
        return ""
    end

    local clear_file, clear_err = io.open(
        path,
        "w"
    )

    if not clear_file then
        debug_log(
            "could not clear relay file "
            .. tostring(path)
            .. ": "
            .. tostring(clear_err)
        )

        return data
    end

    clear_file:close()

    return data
end

local function append_lines(path, messages, name)
    if #messages == 0 then
        return true
    end

    local output =
        table.concat(messages, "\n")
        .. "\n"

    local file, err = io.open(
        path,
        "a"
    )

    if not file then
        minetest.log(
            "error",
            "[comod_bot] Failed to open "
            .. name
            .. ": "
            .. tostring(err)
        )

        return false
    end

    local ok, write_err = file:write(
        output
    )

    file:flush()
    file:close()

    if not ok then
        minetest.log(
            "error",
            "[comod_bot] Failed to write "
            .. name
            .. ": "
            .. tostring(write_err)
        )

        return false
    end

    return true
end

local function split_lines(data)
    local lines = {}

    if not data or data == "" then
        return lines
    end

    for line in tostring(data):gmatch(
        "[^\r\n]+"
    ) do
        if line ~= "" then
            lines[#lines + 1] = line
        end
    end

    return lines
end

local function split_tabs(line)
    local fields = {}
    local start = 1

    while true do
        local pos = line:find(
            "\t",
            start,
            true
        )

        if not pos then
            fields[#fields + 1] =
                line:sub(start)

            break
        end

        fields[#fields + 1] =
            line:sub(
                start,
                pos - 1
            )

        start = pos + 1
    end

    return fields
end

-- ---------------------------------------------------------------------------
-- Public outgoing functions
-- ---------------------------------------------------------------------------

function comod_bot.send_message_on_discord(message)
    message = strip_newlines(message)

    if message ~= "" then
        relay.messages[#relay.messages + 1] =
            message
    end
end

function comod_bot.send_message_on_discord_reports(message)
    message = strip_newlines(message)

    if message ~= "" then
        relay.reports[#relay.reports + 1] =
            message
    end
end

function comod_bot.send_message_on_discord_debugs(message)
    message = strip_newlines(message)

    if message ~= "" then
        relay.debugs[#relay.debugs + 1] =
            message
    end
end

local function send_action_debug(message)
    debug_log(message)

    comod_bot.send_message_on_discord_debugs(
        message
    )
end

-- ---------------------------------------------------------------------------
-- Discord command access
-- ---------------------------------------------------------------------------

local blocked_discord_commands = {
    tp = true,
    teleport = true,
    tpa = true,
    tpaccept = true,
    tpdeny = true,
    home = true,
    spawn = true,
    back = true,
    sethome = true,
    delhome = true,
    setspawn = true,

    suicide = true,
    sit = true,
    lay = true,
    stand = true,
    jump = true,
    fly = true,
    fast = true,
    noclip = true,
}

local function is_discord_command_blocked(command_name)
    return blocked_discord_commands[
        tostring(command_name):lower()
    ] == true
end

-- ---------------------------------------------------------------------------
-- Authentication relay
-- ---------------------------------------------------------------------------

local function process_login_requests()
    local data =
        read_and_clear(
            relay_paths.auth_request
        )

    if not data or data == "" then
        return
    end

    for _, line in ipairs(
        split_lines(data)
    ) do

        local fields = split_tabs(line)

        local request_id
        local user_id
        local ign
        local password

        if fields[1] == "AUTH" then
            request_id = fields[2]
            user_id = fields[3]
            ign = fields[4]

            password = table.concat(
                fields,
                "\t",
                5
            )
        else
            request_id,
            user_id,
            ign,
            password =
                line:match(
                    "^(%S+)%s+(%S+)%s+(%S+)%s+(.*)$"
                )
        end

        if request_id
            and user_id
            and ign
            and password then

            ign = trim(ign)

            local response_privs = {}
            local ok = false
            local reason = "invalid login"

            local auth_handler =
                minetest.get_auth_handler()

            local entry =
                auth_handler
                and auth_handler.get_auth
                and auth_handler.get_auth(ign)

            if entry then
                if entry.password then
                    ok =
                        minetest.check_password_entry(
                            ign,
                            entry.password,
                            password
                        )
                else
                    reason = "account has no password"
                end
            else
                reason = "account not found"
            end

            if ok then
                response_privs =
                    minetest.get_player_privs(
                        ign
                    )

                reason = "OK"
            else
                if reason == "invalid login" then
                    reason = "invalid password"
                end
            end

            local response

            if ok then
                local priv_list = {}

                for priv, enabled in pairs(
                    response_privs
                ) do
                    if enabled then
                        priv_list[#priv_list + 1] =
                            priv
                    end
                end

                table.sort(priv_list)

                response = table.concat({
                    tostring(request_id),
                    tostring(user_id),
                    tostring(ign),
                    "OK",
                    "",
                    table.concat(
                        priv_list,
                        ","
                    ),
                }, "\t")
            else
                response = table.concat({
                    tostring(request_id),
                    tostring(user_id),
                    tostring(ign),
                    "FAIL",
                    reason,
                    "",
                }, "\t")
            end

            local file =
                io.open(
                    relay_paths.auth_response,
                    "a"
                )

            if file then
                file:write(
                    response,
                    "\n"
                )

                file:flush()
                file:close()
            else
                minetest.log(
                    "error",
                    "[comod_bot] Could not write Auth_response.txt"
                )
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Discord identity mapping
-- ---------------------------------------------------------------------------

local discord_identity = {}
local discord_to_ign = {}

local function read_identity_mappings()
    local data =
        read_and_clear(
            relay_paths.identity
        )

    if not data or data == "" then
        return
    end

    local new_by_ign = {}
    local new_by_discord = {}

    for _, line in ipairs(
        split_lines(data)
    ) do

        local fields = split_tabs(line)

        local ign
        local user_id
        local nickname

        if fields[1] == "NAME" then
            ign = fields[2]
            user_id = fields[3]

            nickname = table.concat(
                fields,
                "\t",
                4
            )

        elseif #fields >= 2
            and tostring(fields[1]):match("^%d+$") then

            user_id = fields[1]
            ign = fields[2]
            nickname = fields[3] or ""

            if #fields > 3 then
                nickname = table.concat(
                    fields,
                    "\t",
                    3
                )
            end

        else
            ign,
            user_id,
            nickname =
                line:match(
                    "^(%S+)%s+(%S+)%s*(.*)$"
                )
        end

        if ign and user_id then
            new_by_ign[ign] = {
                user_id = user_id,
                nickname = nickname or "",
            }

            new_by_discord[user_id] = ign
        end
    end

    discord_identity = new_by_ign
    discord_to_ign = new_by_discord

    local identity_count = 0

    for _ in pairs(new_by_discord) do
        identity_count = identity_count + 1
    end

    debug_log(
        "Loaded "
        .. tostring(identity_count)
        .. " Discord identity mapping(s)."
    )
end

local function get_ign_for_discord_id(user_id)
    return discord_to_ign[
        tostring(user_id)
    ]
end

-- ---------------------------------------------------------------------------
-- Discord command execution
-- ---------------------------------------------------------------------------

local function write_command_response(
    request_id,
    user_id,
    success,
    message
)
    local status =
        success
        and "OK"
        or "FAIL"

    local response = table.concat({
        tostring(request_id or ""),
        tostring(user_id or ""),
        status,
        strip_newlines(message or ""),
    }, "\t")

    local file =
        io.open(
            relay_paths.command_response,
            "a"
        )

    if not file then
        minetest.log(
            "error",
            "[comod_bot] Could not open Discord_Command_Response.txt"
        )

        return
    end

    file:write(
        response,
        "\n"
    )

    file:flush()
    file:close()
end

local function get_discord_command_list()
    local available = {}

    for command_name in pairs(
        minetest.chatcommands
        or minetest.registered_chatcommands
        or {}
    ) do
        if not is_discord_command_blocked(
            command_name
        ) then
            available[#available + 1] =
                command_name
        end
    end

    table.sort(available)

    return table.concat(
        available,
        ", "
    )
end

local function command_has_required_privileges(
    ign,
    command_def
)
    if not command_def.privs then
        return true
    end

    local player_privs =
        minetest.get_player_privs(
            ign
        )

    for priv, required in pairs(
        command_def.privs
    ) do

        if required
            and not player_privs[priv] then

            return false
        end
    end

    return true
end

local function execute_discord_command(
    request_id,
    user_id,
    raw_command
)
    raw_command = trim(raw_command)

    raw_command =
        raw_command:gsub(
            "^!",
            ""
        )

    raw_command =
        raw_command:gsub(
            "^/",
            ""
        )

    if raw_command == "" then
        write_command_response(
            request_id,
            user_id,
            false,
            "Missing command."
        )

        return
    end

    local command_name, param =
        raw_command:match(
            "^(%S+)%s*(.*)$"
        )

    command_name =
        (command_name or ""):lower()

    param = param or ""

    if command_name == "cmd"
        and trim(param) == "+" then

        write_command_response(
            request_id,
            user_id,
            true,
            "Available commands: "
            .. get_discord_command_list()
        )

        return
    end

    if is_discord_command_blocked(
        command_name
    ) then

        write_command_response(
            request_id,
            user_id,
            false,
            "That command requires in-game player context or an in-game action, so it cannot be run from Discord."
        )

        return
    end

    local command_table =
        minetest.chatcommands
        or minetest.registered_chatcommands
        or {}

    local command_def =
        command_table[
            command_name
        ]

    if not command_def then
        write_command_response(
            request_id,
            user_id,
            false,
            "That command does not exist on this server."
        )

        return
    end

    local ign =
        get_ign_for_discord_id(
            user_id
        )

    if not ign then
        write_command_response(
            request_id,
            user_id,
            false,
            "Your Discord account is not linked to a Luanti player."
        )

        return
    end

    if not command_has_required_privileges(
        ign,
        command_def
    ) then

        write_command_response(
            request_id,
            user_id,
            false,
            "You do not have the required privileges."
        )

        return
    end

    local ok, result_a, result_b =
        pcall(
            command_def.func,
            ign,
            param
        )

    if not ok then
        minetest.log(
            "error",
            "[comod_bot] Discord command /"
            .. command_name
            .. " failed: "
            .. tostring(result_a)
        )

        write_command_response(
            request_id,
            user_id,
            false,
            "Command failed on the Luanti server."
        )

        return
    end

    if result_a == false then
        write_command_response(
            request_id,
            user_id,
            false,
            tostring(
                result_b
                or "Command failed."
            )
        )

        return
    end

    write_command_response(
        request_id,
        user_id,
        true,
        tostring(
            result_b
            or result_a
            or "Command executed."
        )
    )
end

local function read_discord_commands()
    local data, read_err =
        read_and_clear(
            relay_paths.command
        )

    if read_err then
        return
    end

    if not data or data == "" then
        return
    end

    debug_log(
        "Discord command file received: "
        .. strip_newlines(data)
    )

    for _, line in ipairs(
        split_lines(data)
    ) do

        local fields =
            split_tabs(line)

        local request_id
        local user_id
        local command

        if fields[1] == "CMD" then
            request_id = fields[2]
            user_id = fields[3]

            command = table.concat(
                fields,
                "\t",
                4
            )
        else
            request_id,
            user_id,
            command =
                line:match(
                    "^(%S+)%s+(%S+)%s+(.+)$"
                )
        end

        if request_id
            and user_id
            and command then

            debug_log(
                "Executing Discord command: "
                .. tostring(command)
                .. " from Discord ID "
                .. tostring(user_id)
            )

            execute_discord_command(
                request_id,
                user_id,
                command
            )
        else
            minetest.log(
                "warning",
                "[comod_bot] Invalid Discord command relay line: "
                .. tostring(line)
            )
        end
    end
end

-- ---------------------------------------------------------------------------
-- Discord -> Luanti chat
-- ---------------------------------------------------------------------------

local function colorize_name(
    color,
    text
)
    text = tostring(text or "")

    if color and color ~= "" then
        return minetest.colorize(
            color,
            text
        )
    end

    return text
end

local function parse_discord_message(line)
    local fields =
        split_tabs(line)

    if fields[1] == "DMSG" then
        local role_color = fields[2] or ""
        local role_name = fields[3] or ""
        local display_name = fields[4] or ""
        local username = fields[5] or ""
        local message = table.concat(fields, "\t", 6)

        if role_color == "#5865F2" and role_name:sub(1, 1) == "#" then
            role_color, role_name = role_name, ""
            local old_styled = display_name
            local old_role, old_name = old_styled:match("^%[([^%]]+)%]%s+(.+)$")
            if old_role then
                role_name = old_role
                display_name = old_name
            end
        end

        local styled_nickname = display_name

        return {
            role_color = role_color,
            role_name = role_name,
            nickname = styled_nickname,
            username = username,
            message = message,
        }
    end

    local legacy_name,
        legacy_message =
        line:match(
            "^%[Discord%]%s+<([^>]+)>%s*(.*)$"
        )

    if legacy_name then
        return {
            role_color = "",
            role_name = "",
            nickname = legacy_name,
            username = "",
            message = legacy_message,
        }
    end

    return nil
end

local function render_discord_message(info)
    local message =
        strip_newlines(
            info.message or ""
        )

    if message == "" then
        return nil
    end

    local role_color =
        info.role_color

    local nickname =
        strip_newlines(
            info.nickname or ""
        )

    local username =
        strip_newlines(
            info.username or ""
        )

    local username_role =
        username:match(
            "^%[([^%]]+)%]$"
        )

    -- Use the Discord nickname exactly as received.
    -- Discord roles are NOT added here because the rank
    -- is already included in the nickname.
    local display_name =
        nickname

    if display_name == "" then
        display_name = username
    end

    if display_name == "" then
        display_name = "Discord"
    end

    local name_part =
        colorize_name(
            role_color,
            display_name
        )

    local sender

    if username ~= ""
        and username ~= nickname then

        sender =
            "<"
            .. name_part
            .. "> ("
            .. username
            .. ")"
    else
        sender =
            "<"
            .. name_part
            .. ">"
    end

    return minetest.colorize(
        "#5865F2",
        "[Discord] "
    )
    .. sender
    .. minetest.colorize(
        "#FFFFFF",
        " : "
    )
    .. message
end

local original_chat_send_all =
    minetest.chat_send_all

local suppress_global_chat_relay = false

local function read_discord_messages()
    local data =
        read_and_clear(
            relay_paths.python
        )

    if not data or data == "" then
        return
    end

    local output = {}

    for _, line in ipairs(
        split_lines(data)
    ) do

        local info =
            parse_discord_message(line)

        if info then
            local rendered =
                render_discord_message(info)

            if rendered then
                output[#output + 1] =
                    rendered
            end
        end
    end

    if #output == 0 then
        return
    end

    suppress_global_chat_relay = true

    for i = 1, #output do
        original_chat_send_all(
            output[i]
        )
    end

    suppress_global_chat_relay = false
end

-- ---------------------------------------------------------------------------
-- Global chat relay
-- ---------------------------------------------------------------------------

local function is_excluded_global_chat_source()
    if not debug_lib
        or not debug_lib.getinfo then

        return false
    end

    local excluded_sources = {
        "comod_fsay",
        "comod_random_msg",
    }

    for level = 2, 15 do
        local info =
            debug_lib.getinfo(
                level,
                "S"
            )

        if not info then
            break
        end

        local source =
            tostring(
                info.source or ""
            )

        for i = 1, #excluded_sources do
            if source:find(
                excluded_sources[i],
                1,
                true
            ) then

                return true
            end
        end
    end

    return false
end

minetest.chat_send_all = function(message)
    original_chat_send_all(message)

    if suppress_global_chat_relay then
        return
    end

    if is_excluded_global_chat_source() then
        return
    end

    local clean =
        strip_colors(message)

    clean =
        strip_newlines(clean)

    if clean == "" then
        return
    end

    comod_bot.send_message_on_discord(
        "[Server] " .. clean
    )
end

-- ---------------------------------------------------------------------------
-- Luanti chat -> Discord
-- ---------------------------------------------------------------------------

minetest.register_on_chat_message(
    function(name, message)
        message =
            strip_newlines(message)

        if message == "" then
            return false
        end

        comod_bot.send_message_on_discord(
            "<"
            .. name
            .. "> "
            .. message
        )

        return false
    end
)

-- ---------------------------------------------------------------------------
-- Reports
-- ---------------------------------------------------------------------------

minetest.register_chatcommand(
    "report",
    {
        params = "<message>",

        description =
            "Report a player/problem to Discord staff.",

        privs = {
            interact = true,
        },

        func = function(name, param)
            param = trim(param)

            if param == "" then
                return false,
                    "Usage: /report <message>"
            end

            comod_bot.send_message_on_discord_reports(
                "[Report] "
                .. name
                .. ": "
                .. strip_newlines(param)
            )

            return true,
                "Report sent to staff."
        end,
    }
)

-- ---------------------------------------------------------------------------
-- Join / leave
-- ---------------------------------------------------------------------------

minetest.register_on_joinplayer(
    function(player)
        local name =
            player:get_player_name()

        comod_bot.send_message_on_discord(
            "[Server] :arrow_up: "
            .. name
            .. " joined the server."
        )
    end
)

minetest.register_on_leaveplayer(
    function(player)
        local name =
            player:get_player_name()

        comod_bot.send_message_on_discord(
            "[Server] :arrow_down: "
            .. name
            .. " left the server."
        )
    end
)

-- ---------------------------------------------------------------------------
-- Main polling loop
-- ---------------------------------------------------------------------------

local poll_timer = 0

local identity_timer =
    identity_interval

local function flush_outgoing()
    if #relay.messages > 0 then
        local queue =
            relay.messages

        relay.messages = {}

        if not append_lines(
            relay_paths.lua,
            queue,
            "Lua.txt"
        ) then

            local old =
                relay.messages

            relay.messages = queue

            for i = 1, #old do
                relay.messages[
                    #relay.messages + 1
                ] = old[i]
            end
        end
    end

    if #relay.reports > 0 then
        local queue =
            relay.reports

        relay.reports = {}

        if not append_lines(
            relay_paths.report,
            queue,
            "Report.txt"
        ) then

            for i = 1, #queue do
                relay.reports[
                    #relay.reports + 1
                ] = queue[i]
            end
        end
    end

    if #relay.debugs > 0 then
        local queue =
            relay.debugs

        relay.debugs = {}

        if not append_lines(
            relay_paths.debug,
            queue,
            "Debug_action.txt"
        ) then

            for i = 1, #queue do
                relay.debugs[
                    #relay.debugs + 1
                ] = queue[i]
            end
        end
    end
end

minetest.register_globalstep(
    function(dtime)
        poll_timer =
            poll_timer + dtime

        identity_timer =
            identity_timer + dtime

        if poll_timer < poll_interval then
            return
        end

        poll_timer =
            poll_timer - poll_interval

        if poll_timer >
            poll_interval * 4 then

            poll_timer = 0
        end

        read_discord_messages()

        process_login_requests()

        read_discord_commands()

        if identity_timer >=
            identity_interval then

            identity_timer =
                identity_timer
                - identity_interval

            if identity_timer >
                identity_interval * 4 then

                identity_timer = 0
            end

            read_identity_mappings()
        end

        flush_outgoing()
    end
)

-- ---------------------------------------------------------------------------
-- Startup diagnostics
-- ---------------------------------------------------------------------------

debug_log("Bridge loaded.")

debug_log(
    "Poll interval: "
    .. tostring(poll_interval)
    .. "s"
)

debug_log(
    "Identity interval: "
    .. tostring(identity_interval)
    .. "s"
)

debug_log(
    "Lua relay: "
    .. relay_paths.lua
)

debug_log(
    "Python relay: "
    .. relay_paths.python
)

debug_log(
    "Command relay: "
    .. relay_paths.command
)

debug_log(
    "Command response relay: "
    .. relay_paths.command_response
)