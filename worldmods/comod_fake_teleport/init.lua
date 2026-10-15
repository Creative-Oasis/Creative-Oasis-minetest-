local PLAYER_A = "A"
local PLAYER_B = "Hailey"

local POS_A = vector.new(-30000, 50, -30000)
local POS_B = vector.new(30000, 50, 30000)

local TIMER = 120 -- 2 minutes
local timer = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime

    if timer >= TIMER then
        timer = 0

        local player_a = minetest.get_player_by_name(PLAYER_A)
        local player_b = minetest.get_player_by_name(PLAYER_B)

        -- Only teleport when both players are online
        if player_a and player_b then
            player_a:set_pos(POS_A)
            player_b:set_pos(POS_B)

        end
    end
end)