-- Simple HUD: Position, Time, TPS, Lag, CPU, AFK, Events
-- Center aligned
-- Smooth update, AFK based on no action

poshud = {
    posx = tonumber(minetest.settings:get("poshud_hud_offsetx") or 0.8),
    posy = tonumber(minetest.settings:get("poshud_hud_offsety") or 0.92)
}

-- AFK thresholds (seconds)
local afk_warn = 6 * 60
local afk_long = 20 * 60

-- HUD storage
local player_hud = {}
local player_hud_enabled = {}
local player_last_pos = {}
local player_last_action = {}
local player_online_time = {}
local poshud_event = "None"

-- HUD functions
local function generatehud(player)
    local name = player:get_player_name()
    if player_hud[name] then return end

    local hud = {}

    hud.id = player:hud_add({
        hud_elem_type = "text",
        name = "poshud",
        position = {x = poshud.posx, y = poshud.posy},
        offset = {x = 0, y = -8},
        text = "Initializing...",
        scale = {x = 100, y = 100},

        -- Center align
        alignment = {x = 0, y = 0},

        number = 0xFFFFFF,
    })

    hud.text = ""
    player_hud[name] = hud
end

local function updatehud(player, text)
    local name = player:get_player_name()

    if player_hud_enabled[name] == false then
        return
    end

    if not player_hud[name] then
        generatehud(player)
    end

    local hud = player_hud[name]

    if hud and text ~= hud.text then
        player:hud_change(hud.id, "text", text)
        hud.text = text
    end
end

local function removehud(player)
    local name = player:get_player_name()

    if player_hud[name] then
        player:hud_remove(player_hud[name].id)
        player_hud[name] = nil
    end
end

-- Track online time
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    player_online_time[name] = 0
    player_last_action[name] = os.time()

    -- HUD enabled by default
    player_hud_enabled[name] = true

    generatehud(player)
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    player_online_time[name] = nil
    player_last_pos[name] = nil
    player_last_action[name] = nil
    player_hud_enabled[name] = nil

    minetest.after(1, function()
        player_hud[name] = nil
    end)
end)

-- Chat command
minetest.register_chatcommand("poshud", {
    params = "on|off",
    description = "Turn poshud on or off",

    func = function(name, param)
        local player = minetest.get_player_by_name(name)

        if not player then
            return
        end

        if param == "on" then
            player_hud_enabled[name] = true
            generatehud(player)

        elseif param == "off" then
            player_hud_enabled[name] = false
            removehud(player)

        else
            return true, "Usage: /poshud [on|off]"
        end
    end
})

-- Time function
local function floormod(x, y)
    return math.floor(x) % y
end

local function get_time()
    local secs = 60 * 60 * 24 * minetest.get_timeofday()

    local s = floormod(secs, 60)
    local m = floormod(secs / 60, 60)
    local h = floormod(secs / 3600, 24)

    return ("%02d:%02d"):format(h, m)
end

-- Lag / TPS / CPU tracking
local cpu_samples = {}
local tps_samples = {}

local max_samples = 10
local last_cpu_time = os.clock()

-- Normal server tick = 0.05 seconds = 20 TPS
local TARGET_TICK = 0.05

-- Reset AFK timer
local function reset_afk(player)
    local name = player:get_player_name()
    player_last_action[name] = os.time()
end

-- Track player actions
minetest.register_on_chat_message(function(name)
    local player = minetest.get_player_by_name(name)

    if player then
        reset_afk(player)
    end
end)

minetest.register_on_player_inventory_action(function(player)
    reset_afk(player)
end)

minetest.register_on_punchnode(function(_, _, player)
    if player then
        reset_afk(player)
    end
end)

minetest.register_on_punchplayer(function(player, hitter)
    if player then
        reset_afk(player)
    end

    if hitter then
        reset_afk(hitter)
    end
end)

-- Globalstep
minetest.register_globalstep(function(dtime)

    -- CPU processing delay
    local now_cpu = os.clock()
    local cpu_delay = now_cpu - last_cpu_time
    last_cpu_time = now_cpu

    table.insert(cpu_samples, cpu_delay)

    if #cpu_samples > max_samples then
        table.remove(cpu_samples, 1)
    end

    local cpu_sum = 0

    for _, v in ipairs(cpu_samples) do
        cpu_sum = cpu_sum + v
    end

    local avg_cpu_delay = cpu_sum / #cpu_samples

    -- Server tick / TPS
    table.insert(tps_samples, dtime)

    if #tps_samples > max_samples then
        table.remove(tps_samples, 1)
    end

    local tick_sum = 0

    for _, v in ipairs(tps_samples) do
        tick_sum = tick_sum + v
    end

    local avg_tick = tick_sum / #tps_samples

    local tps = 0

    if avg_tick > 0 then
        tps = math.min(20, 1 / avg_tick)
    end

    -- Delay above normal 20 TPS
    local tick_lag = math.max(0, avg_tick - TARGET_TICK)

    -- Update all players
    local connected_players = minetest.get_connected_players()
    local player_count = #connected_players

    for _, player in ipairs(connected_players) do

        local name = player:get_player_name()

        -- Position
        local posi = player:get_pos()

        local x = math.floor(posi.x + 0.5)
        local y = math.floor(posi.y + 0.5)
        local z = math.floor(posi.z + 0.5)

        local posistr = x .. " " .. y .. " " .. z

        -- Movement-based AFK reset
        local last_pos = player_last_pos[name]

        if last_pos then
            local dx = posi.x - last_pos.x
            local dy = posi.y - last_pos.y
            local dz = posi.z - last_pos.z

            if dx * dx + dy * dy + dz * dz > 0.01 then
                reset_afk(player)
            end
        end

        player_last_pos[name] = vector.new(posi)

        -- AFK duration
        local last_action = player_last_action[name] or os.time()
        local afk_duration = os.time() - last_action

        local idle_msg = ""

        if afk_duration >= afk_long then
            idle_msg = minetest.colorize(
                "#8B4513",
                "AFK for a long time..."
            )
        elseif afk_duration >= afk_warn then
            idle_msg = minetest.colorize(
                "#FFFF00",
                "You are idle..."
            )
        end

        -- Online time
        player_online_time[name] =
            (player_online_time[name] or 0) + dtime

        local ot_sec = math.floor(player_online_time[name])
        local ot_min = math.floor(ot_sec / 60)
        local ot_hour = math.floor(ot_min / 60)

        ot_min = ot_min % 60
        ot_sec = ot_sec % 60

        local ot_str = string.format(
            "%02d:%02d:%02d",
            ot_hour,
            ot_min,
            ot_sec
        )

        -- HUD
        local grey = "#AAAAAA"
        local green = "#00ff00"


        local hud_display =
            (idle_msg ~= "" and idle_msg or " ") .. "\n"

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                "Time: " .. get_time() .. "\n"
            )

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                "Event: " .. poshud_event .. "\n"
            )

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                "Players: " .. player_count .. "\n"
            )

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                string.format(
                    "TPS: %.1f | Lag: %.2fs | CPU: %.2fs\n",
                    tps,
                    tick_lag,
                    avg_cpu_delay
                )
            )

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                "Pos: " .. posistr .. "\n"
            )

        hud_display = hud_display ..
            minetest.colorize(
                grey,
                "Online Time: " .. ot_str
            )

        -- Update HUD
        updatehud(player, hud_display)
    end
end)