-- Creative Oasis comod_bot action debug
-- Sends important server/player actions to the Discord debug channel.

local function send_debug(message)
    if comod_bot and comod_bot.send_message_on_discord_debugs then
        comod_bot.send_message_on_discord_debugs(message)
    end

    minetest.log("action", "[comod_bot] " .. message)
end


local function pos_text(pos)
    if not pos then
        return "[x=?, y=?, z=?]"
    end

    return "[x=" .. math.floor(pos.x) ..
        ", y=" .. math.floor(pos.y) ..
        ", z=" .. math.floor(pos.z) .. "]"
end


-- Player joins
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    send_debug(
        "[Server] Player " .. name .. " joined the server"
    )
end)


-- Player leaves
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    send_debug(
        "[Server] Player " .. name .. " left the server"
    )
end)


-- Player dies
minetest.register_on_dieplayer(function(player, reason)
    local name = player:get_player_name()
    local pos = player:get_pos()

    local death_reason = ""

    if reason then
        if reason.type then
            death_reason = " | reason=" .. tostring(reason.type)
        end

        if reason.from then
            death_reason = death_reason ..
                " | from=" .. tostring(reason.from)
        end
    end

    send_debug(
        "[Server] Player " .. name ..
        " died at " .. pos_text(pos) ..
        death_reason
    )
end)


-- Player respawns
minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local pos = player:get_pos()

    send_debug(
        "[Server] Player " .. name ..
        " respawned at " .. pos_text(pos)
    )

    return false
end)


-- Player digs a node
minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger or not oldnode then
        return
    end

    local name = digger:get_player_name()

    send_debug(
        "[Server] Player " .. name ..
        " dug " .. oldnode.name ..
        " at " .. pos_text(pos)
    )
end)


-- Player places a node
minetest.register_on_placenode(function(pos, newnode, placer)
    if not placer or not newnode then
        return
    end

    local name = placer:get_player_name()

    send_debug(
        "[Server] Player " .. name ..
        " placed " .. newnode.name ..
        " at " .. pos_text(pos)
    )
end)


-- Player punches a node
minetest.register_on_punchnode(function(pos, node, puncher)
    if not puncher or not node then
        return
    end

    local name = puncher:get_player_name()

    send_debug(
        "[Server] Player " .. name ..
        " punched " .. node.name ..
        " at " .. pos_text(pos)
    )
end)


-- Player eats food/items
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, player, pointed_thing)
    if not player then
        return
    end

    local name = player:get_player_name()
    local item_name = itemstack:get_name()
    local pos = player:get_pos()

    send_debug(
        "[Food] Player " .. name ..
        " ate " .. item_name ..
        " at " .. pos_text(pos) ..
        " | hp_change=" .. tostring(hp_change)
    )
end)


-- Player takes damage
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if not player then
        return hp_change
    end

    if hp_change < 0 then
        local name = player:get_player_name()
        local pos = player:get_pos()
        local damage = math.abs(hp_change)

        local source = ""

        if reason then
            if reason.type then
                source = " | type=" .. tostring(reason.type)
            end

            if reason.from then
                source = source ..
                    " | from=" .. tostring(reason.from)
            end

            if reason.object then
                source = source ..
                    " | object=" .. tostring(reason.object)
            end

            if reason.node then
                source = source ..
                    " | node=" .. tostring(reason.node)
            end
        end

        send_debug(
            "[Damage] Player " .. name ..
            " took " .. tostring(damage) ..
            " damage at " .. pos_text(pos) ..
            source
        )
    end

    return hp_change
end)


-- Player grants a privilege
minetest.register_on_priv_grant(function(name, granter, priv)
    send_debug(
        "[Server] " .. granter ..
        " granted " .. priv ..
        " to " .. name
    )
end)


-- Player revokes a privilege
minetest.register_on_priv_revoke(function(name, revoker, priv)
    send_debug(
        "[Server] " .. revoker ..
        " revoked " .. priv ..
        " from " .. name
    )
end)


-- Chat messages
minetest.register_on_chat_message(function(name, message)
    send_debug(
        "[Chat] <" .. name .. "> " .. message
    )

    return false
end)