local death_pos = {}
local was_killed = {}
local tip_sent = {}

minetest.register_on_dieplayer(function(player, reason)
    local name = player:get_player_name()
    local send_tip = minetest.settings:get("death_pos.send_tip_on_die") or true -- Sends tip to use 'death_pos' command when player dies (if true)
    death_pos[name] = player:get_pos()
    if reason.type == "punch" and reason.object:is_player() then
        if reason.object:get_player_name() ~= name then
            was_killed[name] = true
            minetest.after(30, function()
                was_killed[name] = nil
            end)
        end
    end
    if player and send_tip == true and not tip_sent[name] then
        minetest.chat_send_player(name, minetest.colorize("#60e645", "You died. You can return back to your last death position by using /death_pos command"))
        tip_sent[name] = true
        minetest.after(10, function()
            tip_sent[name] = nil
        end)
    end
end)

minetest.register_chatcommand("death_pos", {
    description = "Go to your last death position",
    privs = {interact = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local pos = death_pos[name]
        local clear_pos = minetest.settings:get("death_pos.clear_pos") or true -- Clears the death position when 'death_pos' command is used (if true)
        if was_killed[name] then
            return false, "You were killed by a player, you cannot teleport to your death position right now"
        end
        if pos then
            player:set_pos(pos)
            if clear_pos == true then
                    death_pos[name] = nil
            end
            return false, minetest.colorize("#60e645", "Teleported you back to your death position!")
        else
            return false, "You don't have a death position right now"
        end
    end
})