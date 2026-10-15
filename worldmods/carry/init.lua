local carried_players = {}

-- Saved physics for players who are currently being carried
local saved_physics = {}

-- Check if carrying target would create a carry loop
local function would_create_loop(carrier_name, target_name)
    local current = carrier_name
    local checked = {}

    while current do
        if checked[current] then
            return true
        end

        checked[current] = true

        if current == target_name then
            return true
        end

        current = carried_players[current]
    end

    return false
end

-- Save the player's current physics settings
local function save_player_physics(player)
    if not player or not player:is_player() then
        return
    end

    local name = player:get_player_name()
    local physics = player:get_physics_override()

    saved_physics[name] = {
        speed = physics.speed,
        jump = physics.jump,
        gravity = physics.gravity,
        sneak = physics.sneak,
        sneak_glitch = physics.sneak_glitch,
        new_move = physics.new_move,
        pitch_move = physics.pitch_move
    }
end

-- Restore the player's original physics settings
local function restore_player_physics(player)
    if not player or not player:is_player() then
        return
    end

    local name = player:get_player_name()
    local physics = saved_physics[name]

    if physics then
        player:set_physics_override({
            speed = physics.speed,
            jump = physics.jump,
            gravity = physics.gravity,
            sneak = physics.sneak,
            sneak_glitch = physics.sneak_glitch,
            new_move = physics.new_move,
            pitch_move = physics.pitch_move
        })

        saved_physics[name] = nil
    end
end

-- Reset carrier arms
local function reset_carrier_arms(carrier)
    if not carrier or not carrier:is_player() then
        return
    end

    carrier:set_bone_override("Arm_Right", {
        rotation = {
            absolute = false,
            interpolation = 0,
            vec = {x = 0, y = 0, z = 0}
        }
    })

    carrier:set_bone_override("Arm_Left", {
        rotation = {
            absolute = false,
            interpolation = 0,
            vec = {x = 0, y = 0, z = 0}
        }
    })
end

-- Stop carrying a player
local function drop_player(target_name)
    local carrier_name = carried_players[target_name]

    if not carrier_name then
        return
    end

    local target = minetest.get_player_by_name(target_name)
    local carrier = minetest.get_player_by_name(carrier_name)

    if target then
        restore_player_physics(target)

        -- Make sure they are no longer being held in place
        target:set_velocity({
            x = 0,
            y = 0,
            z = 0
        })

        target:set_acceleration({
            x = 0,
            y = 0,
            z = 0
        })
    else
        saved_physics[target_name] = nil
    end

    if carrier then
        reset_carrier_arms(carrier)
    end

    carried_players[target_name] = nil
end

-- Drop everyone carried by a specific carrier
local function drop_all_carried_by(carrier_name)
    local targets = {}

    for target_name, current_carrier in pairs(carried_players) do
        if current_carrier == carrier_name then
            table.insert(targets, target_name)
        end
    end

    for _, target_name in ipairs(targets) do
        drop_player(target_name)
    end
end

-- Toggle carry by sneak + punch
minetest.register_on_punchplayer(function(player, hitter)
    if not player or not hitter then
        return false
    end

    if not player:is_player() or not hitter:is_player() then
        return false
    end

    -- Must be sneaking
    if not hitter:get_player_control().sneak then
        return false
    end

    local carrier_name = hitter:get_player_name()
    local target_name = player:get_player_name()

    -- Cannot carry yourself
    if carrier_name == target_name then
        return true
    end

    -- If the target is already being carried by this player,
    -- drop them
    if carried_players[target_name] == carrier_name then
        drop_player(target_name)

        minetest.chat_send_player(
            carrier_name,
            "Dropped " .. target_name
        )

        return true
    end

    -- Prevent carry loops
    if would_create_loop(carrier_name, target_name) then
        minetest.chat_send_player(
            carrier_name,
            "You cannot carry this player because it would create a carry loop."
        )

        return true
    end

    -- A player who is already being carried cannot carry somebody else
    if carried_players[carrier_name] then
        minetest.chat_send_player(
            carrier_name,
            "You cannot carry someone while you are being carried."
        )

        return true
    end

    -- Don't steal a player from another carrier
    if carried_players[target_name] then
        minetest.chat_send_player(
            carrier_name,
            target_name .. " is already being carried."
        )

        return true
    end

    -- Save the target's current physics BEFORE changing anything
    save_player_physics(player)

    -- Pick up player
    carried_players[target_name] = carrier_name

    player:set_physics_override({
        speed = 0,
        jump = 0,
        gravity = 0
    })

    minetest.chat_send_player(
        carrier_name,
        "Carrying " .. target_name
    )

    return true
end)

-- Keep carried player attached
minetest.register_globalstep(function(dtime)
    for target_name, carrier_name in pairs(carried_players) do
        local target = minetest.get_player_by_name(target_name)
        local carrier = minetest.get_player_by_name(carrier_name)

        -- Either player disappeared
        if not target or not carrier then
            drop_player(target_name)

        -- Extra safety against circular carrying
        elseif target_name == carrier_name
            or carried_players[carrier_name] == target_name then

            drop_player(target_name)

        -- Carried player presses sneak
        elseif target:get_player_control().sneak then
            drop_player(target_name)

            minetest.chat_send_player(
                target_name,
                "You dropped yourself."
            )

        else
            local pos = carrier:get_pos()
            local dir = carrier:get_look_dir()

            -- Position the carried player slightly
            -- in front of and above the carrier
            local carry_pos = {
                x = pos.x + dir.x * 0.25,
                y = pos.y + 0.8,
                z = pos.z + dir.z * 0.25
            }

            target:set_pos(carry_pos)

            target:set_velocity({
                x = 0,
                y = 0,
                z = 0
            })

            target:set_acceleration({
                x = 0,
                y = 0,
                z = 0
            })

            target:set_look_horizontal(
                carrier:get_look_horizontal()
            )

            target:set_look_vertical(0)

            -- Carrying animation
            carrier:set_bone_override("Arm_Right", {
                rotation = {
                    absolute = false,
                    interpolation = 0,
                    vec = {
                        x = math.rad(45),
                        y = 0,
                        z = 0
                    }
                }
            })

            carrier:set_bone_override("Arm_Left", {
                rotation = {
                    absolute = false,
                    interpolation = 0,
                    vec = {
                        x = math.rad(45),
                        y = 0,
                        z = 0
                    }
                }
            })
        end
    end
end)

-- Clean up when a player leaves
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    -- If this player was being carried
    if carried_players[name] then
        local carrier_name = carried_players[name]
        local carrier = minetest.get_player_by_name(carrier_name)

        if carrier then
            reset_carrier_arms(carrier)
        end

        carried_players[name] = nil
        saved_physics[name] = nil
    end

    -- If this player was carrying someone
    drop_all_carried_by(name)
end)

-- Clean up when a player dies
minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()

    -- If this player was being carried,
    -- drop them from their carrier
    if carried_players[name] then
        drop_player(name)
    end

    -- If this player was the carrier,
    -- immediately drop everyone they were carrying
    drop_all_carried_by(name)
end)