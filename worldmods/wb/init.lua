local welcome_data = {}
local path = minetest.get_worldpath() .. "/mcl_welcome_back_data.txt"

-- Load stored data
local function load_data()
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content ~= "" then
            welcome_data = minetest.deserialize(content) or {}
        end
    end
end

-- Save data to file
local function save_data()
    local file = io.open(path, "w")
    if file then
        file:write(minetest.serialize(welcome_data))
        file:close()
    end
end

load_data()

-- Helper to convert seconds to human-readable time
local function time_ago(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    local parts = {}
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end

    return table.concat(parts, " ")
end

-- On player join
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local now = os.time()

    if not welcome_data[name] then
        -- First time join (light green)
        minetest.chat_send_all(minetest.colorize("#90EE90", "Welcome " .. name .. " to the server!"))
    else
        -- Returning player (dark green)
        local last_login = welcome_data[name].last_login or now
        local diff = now - last_login
        minetest.chat_send_all(
            minetest.colorize("#006400",
                string.format(
                    "Welcome back %s, last login: %s (%s ago)",
                    name,
                    os.date("%Y-%m-%d %H:%M:%S", last_login),
                    time_ago(diff)
                )
            )
        )
    end

    -- Update last login
    welcome_data[name] = {last_login = now}
    save_data()
end)
