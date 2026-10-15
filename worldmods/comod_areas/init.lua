-- comod_areas/init.lua

local violations = {}
local last_positions = {}

local LIMIT = 10
local WINDOW = 20 

-------------------------------------------------
-- Track last safe position continuously
-------------------------------------------------
minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        last_positions[player:get_player_name()] = player:get_pos()
    end
end)

-------------------------------------------------
-- Cleanup old violations
-------------------------------------------------
local function cleanup(name, now)
    violations[name] = violations[name] or {}
    local v = violations[name]
    for i = #v, 1, -1 do
        if now - v[i] > WINDOW then
            table.remove(v, i)
        end
    end
end

-------------------------------------------------
-- Show GUI warning every violation
-------------------------------------------------
local function show_warning_formspec(player)
    if not player or not player:is_player() then return end
    local name = player:get_player_name()
    minetest.show_formspec(name, "comod_areas:warning",
        "formspec_version[4]" ..
        "size[7,2]" ..
        "label[0.5,0.5;⚠ You cannot dig or place here!]" ..
        "button_exit[5.2,1.2;1.5,0.6;ok;OK]"
    )
end

-------------------------------------------------
-- Handle violations (count + kick)
-------------------------------------------------
local function handle_violation(player)
    local name = player:get_player_name()
    local now = minetest.get_gametime()
    cleanup(name, now)

    violations[name] = violations[name] or {}
    table.insert(violations[name], now)
    local count = #violations[name]

    -- Show GUI every violation
    show_warning_formspec(player)

    -- Kick if over limit
    if count >= LIMIT then
        minetest.chat_send_all("[Areas] "..name.." was kicked for repeated protected digging/placing!")
        minetest.kick_player(name, "You exceeded the protected area violation limit!")

        violations[name] = {}
    end
end

-------------------------------------------------
-- Main protection violation handler
-------------------------------------------------
minetest.register_on_protection_violation(function(pos, name)
    if not name or not areas then return end

    local player = minetest.get_player_by_name(name)
    if not player then return end

    -- Teleport back to last safe position
    local safe_pos = last_positions[name]
    if safe_pos then
        local yaw = player:get_look_horizontal()
        local pitch = player:get_look_vertical()
        player:set_pos(safe_pos)
        player:set_look_horizontal(yaw + math.pi)
        player:set_look_vertical(-pitch)
    end

    -- Handle violation (GUI + kick)
    handle_violation(player)
end)
