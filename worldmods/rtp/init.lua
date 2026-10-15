-- Nom du mod
local modname = minetest.get_current_modname()

-- Cooldown in seconds
local TELEPORT_COOLDOWN = 5 * 60 -- 10 minutes

-- Table to track last teleport time per player
local last_teleport_time = {}

-- Function to teleport player to a random location anywhere
local function teleport_to_random_location(player)
    local name = player:get_player_name()

    -- Check cooldown
    local now = os.time()
    local last_time = last_teleport_time[name] or 0
    if now - last_time < TELEPORT_COOLDOWN then
        local remaining = TELEPORT_COOLDOWN - (now - last_time)
        minetest.chat_send_player(name, "You must wait " .. math.ceil(remaining / 60) .. " minute(s) before using /rtp again.")
        return
    end

    -- Generate random coordinates (full map range)
    local pos = {
        x = math.random(-30000, 30000),  -- Full X range
        y = math.random(-10, 50),        -- Y range from -10 to 50
        z = math.random(-30000, 30000),  -- Full Z range
    }

    -- Teleport the player
    player:set_pos(pos)
    minetest.chat_send_player(name, "Teleported to " .. minetest.pos_to_string(pos))

    -- Update last teleport time
    last_teleport_time[name] = now
end

-- Register /rtp command
minetest.register_chatcommand("rtp", {
    description = "Teleport to a random position anywhere in the world (-10 to 50 Y, 10min cooldown)",
    privs = {shout = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player then
            teleport_to_random_location(player)
        end
    end,
})

-- Log for mod load
minetest.log("action", "<RTP>[" .. modname .. "] Mod loaded successfully for full map teleportation (-10 to 50 Y) with 10min cooldown.")
