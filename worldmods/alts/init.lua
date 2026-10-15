-- File: init.lua
-- mcl_alt_detect: record player IPs on join and allow admins to query alts
-- Works with Minetest / MineClone2 servers.
-- Made for Creative Oasis server

local S = minetest.get_translator(minetest.get_current_modname())

-- Privilege for admins
minetest.register_privilege("alt_detect_admin", {
    description = "Allows use of /ip and /reload_alts commands",
    give_to_singleplayer = false,
})

-- Storage
local storage = minetest.get_mod_storage()

-- Load/save helpers
local function load_table(key)
    local s = storage:get_string(key)
    if s == "" then return {} end
    local ok, t = pcall(minetest.deserialize, s)
    if ok and type(t) == "table" then return t end
    return {}
end

local function save_table(key, t)
    storage:set_string(key, minetest.serialize(t))
end

-- Tables in memory
local ip_map = load_table("ip_map")
local name_map = load_table("name_map")

-- Utility
local function normalize_ip(ip)
    if not ip then return "" end
    local noport = ip:match("^([^:]+)") or ip
    return noport
end

-- Store player join info
local function add_join(name)
    local ip = minetest.get_player_ip(name)
    if not ip then return end
    ip = normalize_ip(ip)
    local ts = os.time()

    name_map[name] = { ip = ip, last_join = ts }

    ip_map[ip] = ip_map[ip] or {}
    ip_map[ip][name] = ts

    save_table("ip_map", ip_map)
    save_table("name_map", name_map)
end

-- When player joins, record IP
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    add_join(name)
end)

-- Get alts by player name
local function get_alts_for_name(name)
    local info = name_map[name]
    if not info then return nil, "no-record" end
    local ip = info.ip
    if not ip then return nil, "no-ip" end
    local list = {}
    for n, _ in pairs(ip_map[ip] or {}) do
        if n ~= name then table.insert(list, n) end
    end
    return list, ip
end

-- /ip command
minetest.register_chatcommand("ip", {
    params = "<player>",
    description = "Show the IP and linked accounts of a player",
    privs = { alt_detect_admin = true },
    func = function(caller, param)
        if param == "" then
            return false, "Usage: /ip <player>"
        end
        local target = param
        local alts, ip_or_err = get_alts_for_name(target)
        if not alts then
            if ip_or_err == "no-record" then
                return false, "No record for player: " .. target
            else
                return false, "Player has no recorded IP: " .. target
            end
        end
        local alt_text = (#alts > 0) and table.concat(alts, ", ") or "none"
        return true, string.format("- %s: %s, linked: %s", target, ip_or_err, alt_text)
    end,
})

-- /reload_alts command
minetest.register_chatcommand("reload_alts", {
    params = "",
    description = "Reload alt detection data from storage",
    privs = { alt_detect_admin = true },
    func = function(caller)
        ip_map = load_table("ip_map")
        name_map = load_table("name_map")
        return true, "Alt detection data reloaded from storage."
    end,
})

-- Optional auto-save (every 5 minutes)
local autosave_interval = 300
local function autosave()
    save_table("ip_map", ip_map)
    save_table("name_map", name_map)
    minetest.after(autosave_interval, autosave)
end
minetest.after(autosave_interval, autosave)

minetest.log("action", "[mcl_alt_detect] /ip and /reload_alts commands loaded.")
