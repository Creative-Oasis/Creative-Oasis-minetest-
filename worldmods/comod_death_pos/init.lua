local storage = minetest.get_mod_storage()
local death_markers = {}
local hidden_death = {}

-- Add death marker
local function add_death_marker(player, pos)
    local name = player:get_player_name()

    -- Remove old HUD marker if exists
    if death_markers[name] then
        player:hud_remove(death_markers[name])
        death_markers[name] = nil
    end

    -- If temporarily hidden, don't add it
    if hidden_death[name] then
        return
    end

    -- Add red waypoint marker
    death_markers[name] = player:hud_add({
        hud_elem_type = "waypoint",
        name = "You died here!",
        number = 0xFF0000,
        world_pos = pos
    })
end

-- On death
minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    local pos = vector.round(player:get_pos())

    -- IMPORTANT:
    -- Dying again resets the hidden state,
    -- so the new death marker will show.
    hidden_death[name] = nil

    -- Save death position
    storage:set_string(name, minetest.serialize(pos))

    -- Send chat message
    minetest.chat_send_player(
        name,
        minetest.colorize("#ff0000",
            "You died at: X=" .. pos.x ..
            " Y=" .. pos.y ..
            " Z=" .. pos.z
        )
    )

    -- Add new marker
    add_death_marker(player, pos)
end)

-- On join
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local data = storage:get_string(name)

    -- Reset temporary hide when joining
    hidden_death[name] = nil

    if data ~= "" then
        local pos = minetest.deserialize(data)

        if pos then
            add_death_marker(player, pos)
        end
    end
end)

-- Hide death marker
minetest.register_chatcommand("hide_death", {
    description = "Hide your death waypoint",
    privs = {},

    func = function(name)
        local player = minetest.get_player_by_name(name)

        if not player then
            return false, "You must be online."
        end

        hidden_death[name] = true

        if death_markers[name] then
            player:hud_remove(death_markers[name])
            death_markers[name] = nil
        end

        return true, "Death waypoint hidden."
    end
})

-- Show death marker
minetest.register_chatcommand("show_death", {
    description = "Show your death waypoint",
    privs = {},

    func = function(name)
        local player = minetest.get_player_by_name(name)

        if not player then
            return false, "You must be online."
        end

        hidden_death[name] = nil

        local data = storage:get_string(name)

        if data == "" then
            return true, "You don't have a saved death position."
        end

        local pos = minetest.deserialize(data)

        if not pos then
            return false, "Your saved death position is invalid."
        end

        add_death_marker(player, pos)

        return true, "Death waypoint shown."
    end
})

-- Clean up when player leaves
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    death_markers[name] = nil
    hidden_death[name] = nil
end)