-- Comod Size Mod
comod_size = {}
comod_size.priv = "comod_size"

-- Default player properties
comod_size.default_props = {
    visual_size = {x = 1, y = 1},
    collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
    eye_height = 1.47
}

-- Privilege
minetest.register_privilege(comod_size.priv, {
    description = "Allows player to change their size",
    give_to_singleplayer = true
})

local function has_privilege(name)
    return minetest.check_player_privs(name, {[comod_size.priv] = true})
end

-- ======================
-- CHAT COMMANDS
-- ======================

minetest.register_chatcommand("setsize", {
    params = "<size>",
    description = "Set your size (0.01 - 20)",
    func = function(name, param)
        if not has_privilege(name) then
            return false, "You need the '" .. comod_size.priv .. "' privilege"
        end

        local size = tonumber(param)
        if not size or size < 0.01 or size > 20 then
            return false, "Size must be between 0.01 and 20"
        end

        comod_size.set_player_size(name, size)
        return true, "Size set to " .. size
    end
})

minetest.register_chatcommand("small", {
    params = "<amount>",
    description = "Decrease size (1-100 levels)",
    func = function(name, param)
        if not has_privilege(name) then
            return false, "Missing privilege: " .. comod_size.priv
        end

        local amount = tonumber(param) or 1
        if amount < 1 or amount > 100 then
            return false, "Amount must be between 1 and 100"
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local meta = player:get_meta()
        local current = meta:get_float("player_size")
        if current <= 0 then current = 1 end

        local new_size = math.max(0.01, current - (amount * 0.01))
        comod_size.set_player_size(name, new_size)

        return true, "Size decreased to " .. new_size
    end
})

minetest.register_chatcommand("large", {
    params = "<amount>",
    description = "Increase size (1-100 levels)",
    func = function(name, param)
        if not has_privilege(name) then
            return false, "Missing privilege: " .. comod_size.priv
        end

        local amount = tonumber(param) or 1
        if amount < 1 or amount > 100 then
            return false, "Amount must be between 1 and 100"
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local meta = player:get_meta()
        local current = meta:get_float("player_size")
        if current <= 0 then current = 1 end

        local new_size = math.min(20, current + (amount * 0.01))
        comod_size.set_player_size(name, new_size)

        return true, "Size increased to " .. new_size
    end
})

minetest.register_chatcommand("normal_size", {
    description = "Return to normal size",
    func = function(name)
        if not has_privilege(name) then
            return false, "Missing privilege: " .. comod_size.priv
        end

        comod_size.set_player_size(name, 1)
        return true, "Back to normal size"
    end
})

minetest.register_chatcommand("micro", {
    description = "Become microscopic (0.01)",
    func = function(name)
        if not has_privilege(name) then
            return false, "Missing privilege: " .. comod_size.priv
        end

        comod_size.set_player_size(name, 0.01)
        return true, "You are now microscopic"
    end
})

minetest.register_chatcommand("super_large", {
    description = "Become very large (20)",
    func = function(name)
        if not has_privilege(name) then
            return false, "Missing privilege: " .. comod_size.priv
        end

        comod_size.set_player_size(name, 20)
        return true, "You are now super large"
    end
})

-- ======================
-- CORE SIZE FUNCTION
-- ======================

function comod_size.set_player_size(name, size)
    local player = minetest.get_player_by_name(name)
    if not player then return end

    -- Absolute safety
    if not size or size < 0.01 then
        size = 1
    end

    local meta = player:get_meta()
    meta:set_float("player_size", size)

    local collbox = {
        -0.3 * size,
         0.0 * size,
        -0.3 * size,
         0.3 * size,
         1.7 * size,
         0.3 * size
    }

    local step_height = math.min(0.6, math.max(0.05, 0.6 * size))
    local eye_height = comod_size.default_props.eye_height * size

    player:set_properties({
        visual_size = {x = size, y = size},
        collisionbox = collbox,
        eye_height = eye_height,
        stepheight = step_height
    })

    -- Do NOT override physics (armor & buffs stay intact)
    player:set_physics_override({
        speed = nil,
        jump = nil,
        gravity = nil
    })

    comod_size.size_change_effect(player)
end

-- ======================
-- VISUAL EFFECT
-- ======================

function comod_size.size_change_effect(player)
    local pos = vector.add(player:get_pos(), {x = 0, y = 0.5, z = 0})

    for i = 1, 12 do
        minetest.after(i * 0.05, function()
            minetest.add_particle({
                pos = pos,
                velocity = {
                    x = math.random() - 0.5,
                    y = math.random() * 0.5,
                    z = math.random() - 0.5
                },
                acceleration = {x = 0, y = -1, z = 0},
                expirationtime = 1,
                size = math.random(1, 3),
                texture = "default_item_smoke.png",
                glow = 3
            })
        end)
    end
end

-- ======================
-- ADMIN COMMAND
-- ======================

minetest.register_chatcommand("comod_size", {
    params = "<player> <size>",
    description = "Set your size or another player's size (0.01-20)",
    func = function(name, param)
        local target_name, size_str = param:match("^(%S+)%s+(%S+)$")
        local size

        -- Self resize
        if not target_name and param ~= "" then
            size = tonumber(param)
            if not size then return false, "Invalid size" end

            if not has_privilege(name) then
                return false, "You need the 'comod_size' privilege"
            end

            size = math.max(0.01, math.min(20, size))
            comod_size.set_player_size(name, size)
            return true, "Your size set to " .. size
        end

        -- Resize others
        if target_name and size_str then
            local target = minetest.get_player_by_name(target_name)
            if not target then return false, "Player '" .. target_name .. "' not found" end

            size = tonumber(size_str)
            if not size then return false, "Invalid size" end

            if name ~= target_name and not minetest.check_player_privs(name, {server = true}) then
                return false, "You can only resize other players as server/admin"
            end

            size = math.max(0.01, math.min(20, size))
            comod_size.set_player_size(target_name, size)
            return true, "Set " .. target_name .. "'s size to " .. size
        end

        return false, "Usage: /comod_size <size> OR /comod_size <player> <size>"
    end
})

-- ======================
-- JOIN HANDLER
-- ======================

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()

    -- Everyone always starts normal
    meta:set_float("player_size", 1)

    minetest.after(0.5, function()
        if player and player:is_player() then
            comod_size.set_player_size(name, 1)
        end
    end)
end)
