-- Minetest Player Stats Mod (playtime, last login, position, HP)

local player_data = {}
local path = minetest.get_worldpath() .. "/mt_stats_data.txt"

-- Load data
local function load_data()
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content ~= "" then
            player_data = minetest.deserialize(content) or {}
        end
    end
end

-- Save data
local function save_data()
    local file = io.open(path, "w")
    if file then
        file:write(minetest.serialize(player_data))
        file:close()
    else
        minetest.log("error", "[mt_stats] Failed to save data to " .. path)
    end
end

load_data()

-- Trim helper
local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

-- Format playtime
local function format_playtime_hms(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Player join
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local now = os.time()
    local pos = player:get_pos()

    if not player_data[name] then
        player_data[name] = {
            last_login = now,
            last_logout = now,
            playtime = 0,
            pos = pos,
            hp = player:get_hp(),
        }
    end

    player_data[name].last_login = now
    player_data[name].pos = pos
    player_data[name].hp = player:get_hp()
    save_data()

    -- Optional: blank colored line
    minetest.chat_send_player(name, minetest.colorize("#00FF00", ""))
end)

-- Player leave
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if not player_data[name] then player_data[name] = {} end

    player_data[name].last_logout = os.time()
    player_data[name].pos = player:get_pos()
    player_data[name].hp = player:get_hp()
    save_data()
end)

-- Globalstep: update playtime, HP, pos
local save_timer = 0
minetest.register_globalstep(function(dtime)
    save_timer = save_timer + dtime

    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        player_data[name] = player_data[name] or {}

        player_data[name].playtime = (player_data[name].playtime or 0) + dtime
        player_data[name].hp = player:get_hp()
        player_data[name].pos = player:get_pos()
    end

    if save_timer >= 60 then
        save_data()
        save_timer = 0
    end
end)

-- /stats command
minetest.register_chatcommand("stats", {
    params = "[player]",
    description = "Show your stats or another player's stats",
    privs = {interact=true},
    func = function(name, param)
        local target = trim(param)
        if target == "" then target = name end

        local data = player_data[target]
        if not data then
            return false, "No stats found for: " .. target
        end

        local pos = data.pos or {x=0, y=0, z=0}
        local hp = data.hp or 20
        local playtime = data.playtime or 0

        -- Determine if online
        local is_online = false
        for _, player in ipairs(minetest.get_connected_players()) do
            if player:get_player_name() == target then
                is_online = true
                break
            end
        end

        local last_logout_str = is_online
            and "Player is currently online"
            or os.date("%Y-%m-%d %H:%M:%S", data.last_logout or 0)

        local msg = minetest.colorize("#00FFFF", "Stats for " .. target .. ":\n") ..
            minetest.colorize("#808080",
                string.format(
                    "HP: %d\nPosition: (%.1f, %.1f, %.1f)\nLast login: %s\nLast logout: %s\nPlaytime: %s",
                    hp,
                    pos.x, pos.y, pos.z,
                    os.date("%Y-%m-%d %H:%M:%S", data.last_login or 0),
                    last_logout_str,
                    format_playtime_hms(playtime)
                )
            )

        -- Notify if someone checks another player
        if target ~= name then
            minetest.chat_send_player(target,
                minetest.colorize("#C0C0C0", "[Notice] " .. name .. " viewed your '/stats'"))
        end

        return true, msg
    end
})
