local S = minetest.get_translator("j_mute")

-- Helper function to split a string
local function split(str, sep)
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

-- Table to track active mutes
local active_mutes = {}

-- Mute command
minetest.register_chatcommand("mute", {
    params = S("<playername> <seconds>"),
    description = S("Mute a player for a certain number of seconds"),
    func = function(name, param)
        local args = split(param, " ")
        local playername = args[1]
        local seconds = tonumber(args[2])

        if not playername or not seconds then
            return false, S("Usage: /mute <playername> <seconds>")
        end

        local sender_privs = minetest.get_player_privs(name)
        local max_seconds

        if sender_privs.ezmod_trusted then
            max_seconds = nil  -- unlimited
        elseif sender_privs.mute then
            max_seconds = 600 
            if seconds > max_seconds then
                return false, S("You are a Guardian; you can only mute a player for 10 minutes maximum.")
            end
        else
            return false, S("You do not have permission to mute players.")
        end

        -- Check if player is already muted
        if active_mutes[playername] then
            local remaining = math.ceil(active_mutes[playername] - os.time())
            if remaining > 0 then
                return false, S("@1 is already muted. @2 seconds remaining.", playername, remaining)
            end
        end

        -- Apply mute
        local privs = minetest.get_player_privs(playername)
        local was_shout = privs.shout
        privs.shout = nil
        minetest.set_player_privs(playername, privs)
        minetest.chat_send_all(S("@1 has been muted for @2 seconds.", playername, seconds))

        -- Track mute
        active_mutes[playername] = os.time() + seconds

        -- Schedule unmute
        minetest.after(seconds, function()
            local privs = minetest.get_player_privs(playername)
            privs.shout = was_shout or true
            minetest.set_player_privs(playername, privs)
            minetest.chat_send_all(S("@1 has been unmuted.", playername))
            active_mutes[playername] = nil
        end)
    end,
})

-- Unmute command
minetest.register_chatcommand("unmute", {
    params = S("<playername>"),
    description = S("Unmute a player"),
    func = function(name, param)
        if param == "" then
            return false, S("You must specify a player name.")
        end

        local sender_privs = minetest.get_player_privs(name)
        if not (sender_privs.mute or sender_privs.ezmod_trusted) then
            return false, S("You do not have permission to unmute players.")
        end

        local playername = param
        local privs = minetest.get_player_privs(playername)
        privs.shout = true
        minetest.set_player_privs(playername, privs)
        minetest.chat_send_all(S("@1 has been unmuted.", playername))
        active_mutes[playername] = nil
    end,
})

-- Notify muted players when they try to chat
minetest.register_on_chat_message(function(name, message)
    local privs = minetest.get_player_privs(name)
    if not privs.shout then
        local remaining = active_mutes[name] and math.max(0, math.ceil(active_mutes[name] - os.time())) or 0
        minetest.chat_send_player(name, S("You are currently muted. Remaining time: @1 seconds.", remaining))
        return true -- block message
    end
end)

-- Privileges
minetest.register_privilege("ezmod_trusted", S("Full access to /mute commands"))
minetest.register_privilege("mute", S("Guardian: mute a player for up to 5 minutes"))
