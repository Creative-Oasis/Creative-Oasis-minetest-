-- MineStars Spawn & City Command
-- Made by D. J. V. P. + improvements
-- License: LGPLv2.1+

spw = {
    pos_not_set = false,
    pos = {
        lobby = vector.new(),
        city = vector.new(),
    }
}

local S = core.get_translator("spw")

-- Load positions from settings
if core.setting_get_pos("static_spawnpoint") then
    spw.pos.lobby = core.setting_get_pos("static_spawnpoint")
else
    core.log("error", "Spawn pos not set! Fallback to (0,0,0)")
    spw.pos_not_set = true
end

if core.setting_get_pos("city_pos") then
    spw.pos.city = core.setting_get_pos("city_pos")
else
    core.log("error", "City pos not set! Fallback to (0,0,0)")
end

-- Function to teleport player and announce
local function teleport_and_announce(player, dest_pos, dest_name)
    player:set_pos(dest_pos)
    core.chat_send_all(
        core.colorize("#FFFF00", player:get_player_name()) ..
        " " ..
        core.colorize("#00FF00", "teleported to the server "..dest_name)
    )
end

-- Spawn command
core.register_chatcommand("spawn", {
    description = "Teleport to the server spawn",
    params = "[set]",
    func = function(name, params)
        local player = core.get_player_by_name(name)
        if not player then return end

        if params:lower():match("set") then
            if core.check_player_privs(name, {server=true}) then
                spw.pos.lobby = vector.floor(player:get_pos())
                core.settings:set("static_spawnpoint", core.pos_to_string(spw.pos.lobby))
                core.settings:write()
                spw.pos_not_set = false
                return true, core.colorize("lightgreen", "-!- "..S("Done!"))
            else
                return true, core.colorize("#FF7C7C", "-!- "..S("No enough permissions to modify the spawn position!"))
            end
        else
            if spw.pos_not_set then
                return true, core.colorize("#FF7C7C", "-!- "..S("Position for spawn is not set!"))
            end
            teleport_and_announce(player, spw.pos.lobby, "spawn")
            return true, core.colorize("lightgreen", "-!- "..S("Teleporting..."))
        end
    end
})

-- City command
core.register_chatcommand("city", {
    description = "Teleport to the server city",
    params = "[set]",
    func = function(name, params)
        local player = core.get_player_by_name(name)
        if not player then return end

        if params:lower():match("set") then
            if core.check_player_privs(name, {server=true}) then
                spw.pos.city = vector.floor(player:get_pos())
                core.settings:set("city_pos", core.pos_to_string(spw.pos.city))
                core.settings:write()
                return true, core.colorize("lightgreen", "-!- "..S("Done!"))
            else
                return true, core.colorize("#FF7C7C", "-!- "..S("No enough permissions to modify the city position!"))
            end
        else
            teleport_and_announce(player, spw.pos.city, "city")
            return true, core.colorize("lightgreen", "-!- "..S("Teleporting..."))
        end
    end
})

-- Notify server admins if spawn not set
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if name and spw.pos_not_set then
        if core.check_player_privs(name, {server = true}) then
            core.chat_send_player(name, core.colorize("#FF7C7C",
                "-!- "..S("Please set a place for /spawn").."\n"..S("Use \"/spawn set\" to set a place")))
        end
    end
end)
