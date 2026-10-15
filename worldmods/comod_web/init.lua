local MODNAME = core.get_current_modname()

local function log(message)
    core.log("action", "[" .. MODNAME .. "] " .. message)
end

local function warn(message)
    core.log("warning", "[" .. MODNAME .. "] " .. message)
end

-- ============================================================
-- SETTINGS
-- ============================================================

local WEB_URL =
    core.settings:get("comod_web_url") or ""

local API_KEY =
    core.settings:get("comod_web_api_key") or ""

local POLL_INTERVAL =
    tonumber(
        core.settings:get("comod_web_poll_interval")
    ) or 2

local ENABLE_CHAT =
    core.settings:get_bool(
        "comod_web_chat",
        true
    )

local ENABLE_COMMANDS =
    core.settings:get_bool(
        "comod_web_commands",
        true
    )

-- ============================================================
-- STATE
-- ============================================================

local http = nil
local http_available = false

local request_running = false
local request_queue = {}

local queued_keys = {}

local chat_queue = {}

local elapsed = 0

-- ============================================================
-- HTTP API
-- ============================================================

if core.request_http_api then
    http = core.request_http_api()
end

if http then
    http_available = true
else
    warn("HTTP API unavailable.")
    warn("Make sure comod_web is included in secure.http_mods.")
end

-- ============================================================
-- JSON
-- ============================================================

local function encode(data)
    return core.write_json(data)
end

local function decode(data)

    if not data or data == "" then
        return nil
    end

    local success, result =
        pcall(
            core.parse_json,
            data
        )

    if success then
        return result
    end

    return nil
end

-- ============================================================
-- HTTP QUEUE
-- ============================================================

local process_http_queue

local function api_request(
    method,
    path,
    body,
    callback,
    queue_key
)

    if not http_available then
        return
    end

    if WEB_URL == "" then
        return
    end

    -- Prevent duplicate periodic requests.
    if queue_key then

        if queued_keys[queue_key] then
            return
        end

        queued_keys[queue_key] = true
    end

    table.insert(
        request_queue,
        {
            method = method,
            path = path,
            body = body,
            callback = callback,
            queue_key = queue_key
        }
    )

    process_http_queue()
end

process_http_queue = function()

    if request_running then
        return
    end

    local request_data =
        table.remove(
            request_queue,
            1
        )

    if not request_data then
        return
    end

    request_running = true

    local request = {
        url =
            WEB_URL ..
            request_data.path,

        timeout = 10,

        method =
            request_data.method,

        extra_headers = {
            "Content-Type: application/json",
            "Authorization: Bearer " ..
                API_KEY
        }
    }

    if request_data.body then

        request.data =
            encode(
                request_data.body
            )

    end

    http.fetch(
        request,
        function(result)

            request_running = false

            if request_data.queue_key then

                queued_keys[
                    request_data.queue_key
                ] = nil

            end

            if not result then

                warn(
                    "HTTP request returned no result."
                )

            elseif result.succeeded ~= true then

                warn(
                    "HTTP request failed: " ..
                    tostring(
                        result.code or "unknown"
                    )
                )

            elseif request_data.callback then

                local success, err =
                    pcall(
                        request_data.callback,
                        result
                    )

                if not success then

                    warn(
                        "HTTP callback error: " ..
                        tostring(err)
                    )

                end

            end

            process_http_queue()

        end
    )
end

-- ============================================================
-- PLAYER LIST
-- ============================================================

local function get_players()

    local players = {}

    for _, player in ipairs(
        core.get_connected_players()
    ) do

        table.insert(
            players,
            {
                name =
                    player:get_player_name()
            }
        )

    end

    return players
end

-- ============================================================
-- SERVER STATUS
-- ============================================================

local function get_status()

    local players =
        get_players()

    return {

        online = true,

        server_name =
            core.settings:get(
                "server_name"
            )
            or
            "Creative Oasis [Minetest]",

        game =
            core.settings:get(
                "gameid"
            )
            or
            "minetest_game",

        version =
            core.get_version().string,

        port = 30500,

        players = players,

        player_count =
            #players,

        max_players =
            tonumber(
                core.settings:get(
                    "max_users"
                )
            )
            or
            15,

        time =
            os.time()
    }
end

local function send_status()

    api_request(
        "POST",
        "/api/luanti/status",
        get_status(),
        nil,
        "status"
    )

end

-- ============================================================
-- CHAT: LUANTI → WEBSITE
-- ============================================================

if ENABLE_CHAT then

    core.register_on_chat_message(
        function(
            name,
            message
        )

            table.insert(
                chat_queue,
                {
                    player = name,
                    message = message,
                    time = os.time()
                }
            )

            return false
        end
    )

end

local function send_chat()

    if not ENABLE_CHAT then
        return
    end

    if #chat_queue == 0 then
        return
    end

    local messages =
        chat_queue

    chat_queue = {}

    api_request(
        "POST",
        "/api/luanti/chat",
        {
            messages = messages
        }
    )

end

-- ============================================================
-- WEBSITE → LUANTI CHAT
-- ============================================================

local function poll_webchat()

    api_request(
        "GET",
        "/api/luanti/webchat",
        nil,

        function(result)

            local data =
                decode(result.data)

            if not data then
                return
            end

            if type(
                data.messages
            ) ~= "table" then
                return
            end

            for _, item in ipairs(
                data.messages
            ) do

                local name =
                    tostring(
                        item.name
                        or "Website"
                    )

                local message =
                    tostring(
                        item.message
                        or ""
                    )

                if message ~= "" then

                    core.chat_send_all(
                        "[website] <" ..
                        name ..
                        "> " ..
                        message
                    )

                end
            end

        end,

        "webchat"
    )

end

-- ============================================================
-- WEBSITE LOGIN AUTHENTICATION
-- ============================================================

local function process_auth_requests()

    api_request(
        "GET",
        "/api/luanti/auth",
        nil,

        function(result)

            local data =
                decode(result.data)

            if not data then
                return
            end

            if type(
                data.requests
            ) ~= "table" then
                return
            end

            local auth_handler =
                core.get_auth_handler()

            if not auth_handler then

                warn(
                    "Could not get Luanti auth handler."
                )

                return
            end

            for _, item in ipairs(
                data.requests
            ) do

                local id =
                    tostring(
                        item.id or ""
                    )

                local username =
                    tostring(
                        item.username or ""
                    )

                local password =
                    tostring(
                        item.password or ""
                    )

                local success = false

                local reason =
                    "Invalid username or password."

                if username ~= ""
                    and password ~= ""
                then

                    local auth_data =
                        auth_handler.get_auth(
                            username
                        )

                    if auth_data
                        and auth_data.password
                    then

                        success =
                            core.check_password_entry(
                                username,
                                auth_data.password,
                                password
                            )

                    end

                    if success then
                        reason = "Login successful."
                    end

                end

                -- IMPORTANT:
                -- Do not log the password.

                api_request(
                    "POST",
                    "/api/luanti/auth_result",
                    {
                        id = id,
                        username = username,
                        success = success,
                        message = reason
                    }
                )

            end

        end,

        "auth"
    )

end

-- ============================================================
-- WEB COMMANDS
-- ============================================================

local function execute_command(
    command
)

    if type(command) ~= "string" then
        return false,
            "Invalid command."
    end

    command =
        command:gsub(
            "^%s+",
            ""
        )

    command =
        command:gsub(
            "%s+$",
            ""
        )

    if command == "" then

        return false,
            "Empty command."

    end

    if command:sub(1, 1) == "/" then

        command =
            command:sub(2)

    end

    -- /say

    local say_message =
        command:match(
            "^say%s+(.+)$"
        )

    if say_message then

        core.chat_send_all(
            say_message
        )

        return true,
            "Message sent."

    end

    -- /kick

    local kick_player,
        kick_reason =
        command:match(
            "^kick%s+(%S+)%s*(.*)$"
        )

    if kick_player then

        if kick_reason == "" then

            kick_reason =
                "Kicked by web administrator."

        end

        local success =
            core.kick_player(
                kick_player,
                kick_reason
            )

        if success then

            return true,
                "Player kicked."

        end

        return false,
            "Player not found."

    end

    return false,
        "Command not allowed by comod_web."
end

-- ============================================================
-- POLL WEB COMMANDS
-- ============================================================

local function poll_commands()

    if not ENABLE_COMMANDS then
        return
    end

    api_request(
        "GET",
        "/api/luanti/commands",
        nil,

        function(result)

            local data =
                decode(result.data)

            if not data then
                return
            end

            if type(
                data.commands
            ) ~= "table" then
                return
            end

            for _, item in ipairs(
                data.commands
            ) do

                local id =
                    item.id

                local command =
                    item.command

                local success,
                    message =
                    execute_command(
                        command
                    )

                api_request(
                    "POST",
                    "/api/luanti/command_result",
                    {
                        id = id,
                        success = success,
                        message = message
                    }
                )

            end

        end,

        "commands"
    )

end

-- ============================================================
-- JOIN
-- ============================================================

core.register_on_joinplayer(
    function(player)

        local name =
            player:get_player_name()

        api_request(
            "POST",
            "/api/luanti/event",
            {
                event = "join",
                player = name,
                time = os.time()
            }
        )

    end
)

-- ============================================================
-- LEAVE
-- ============================================================

core.register_on_leaveplayer(
    function(player)

        local name =
            player:get_player_name()

        api_request(
            "POST",
            "/api/luanti/event",
            {
                event = "leave",
                player = name,
                time = os.time()
            }
        )

    end
)

-- ============================================================
-- SHUTDOWN
-- ============================================================

core.register_on_shutdown(
    function()

        if not http_available then
            return
        end

        if WEB_URL == "" then
            return
        end

        api_request(
            "POST",
            "/api/luanti/event",
            {
                event = "shutdown",
                time = os.time()
            }
        )

    end
)

-- ============================================================
-- MAIN LOOP
-- ============================================================

core.register_globalstep(
    function(dtime)

        elapsed =
            elapsed + dtime

        if elapsed < POLL_INTERVAL then
            return
        end

        elapsed = 0

        if not http_available then
            return
        end

        if WEB_URL == "" then
            return
        end

        -- Queue everything.
        --
        -- The HTTP queue makes sure only ONE request
        -- is actually running at a time, while allowing
        -- all of these operations to eventually execute.

        send_status()

        send_chat()

        poll_commands()

        poll_webchat()

        process_auth_requests()

    end
)

-- ============================================================
-- STARTUP
-- ============================================================

log("Loaded.")

log(
    "Luanti port: " ..
    tostring(
        core.settings:get("port")
        or "30500"
    )
)

if WEB_URL == "" then

    warn(
        "comod_web_url is not configured."
    )

else

    log(
        "Web API: " ..
        WEB_URL
    )

end
