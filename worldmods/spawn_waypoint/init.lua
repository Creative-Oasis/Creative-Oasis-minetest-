-- spawn_waypoint/init.lua

local spawn_pos = {x = 3111, y = 40, z = -4235}
local waypoint_name = "[Spawn]"

-- name -> waypoint HUD ID
local player_waypoints = {}

local function update_waypoint(player)
    if not player or not player:is_player() then
        return
    end

    local name = player:get_player_name()
    if not name or name == "" then
        return
    end

    -- Create the waypoint once for this player
    if not player_waypoints[name] then
        player_waypoints[name] = player:hud_add({
            hud_elem_type = "waypoint",

            -- World position of Spawn
            world_pos = spawn_pos,

            -- Waypoint name
            name = waypoint_name,

            -- Distance suffix
            -- Empty so the distance is displayed normally
            text = "",

            -- Blue
            number = 0x0000FF,
        })
    end
end

-- Ensure waypoint exists
local timer = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime

    if timer < 1 then
        return
    end

    timer = timer - 1

    for _, player in ipairs(minetest.get_connected_players()) do
        update_waypoint(player)
    end
end)

-- Add shortly after joining
minetest.register_on_joinplayer(function(player)
    minetest.after(0.2, function()
        if player and player:is_player() then
            update_waypoint(player)
        end
    end)
end)

-- Cleanup when player leaves
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    if name then
        player_waypoints[name] = nil
    end
end)