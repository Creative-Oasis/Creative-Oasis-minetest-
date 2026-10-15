--[[
Commands
Copyright (C) 2014-2024 ChaosWormz and contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation, either
version 2.1 of the License, or at your option any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--]]

local S = tp.S or function(s) return s end  -- fallback if translator not ready

-- Helper wrapper for safe command execution
local function safe_func(func)
    return function(player, param)
        if tp and func then
            return func(player, param)
        else
            minetest.chat_send_player(player, "[TELEPORT] Command not ready yet.")
            return true
        end
    end
end

-- Safe version of list_requests if missing
if not tp.list_requests then
    tp.list_requests = function(player)
        minetest.chat_send_player(player, "[TELEPORT] list_requests function is not available.")
        -- Optionally, you can print active requests if you store them somewhere
        -- e.g., tp.active_requests[player]
    end
end

-- Register commands
minetest.register_chatcommand("tpr", {
    description = S("Request teleport to another player"),
    params = S("<playername> | leave playername empty to see help message"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tpr_send)
})

minetest.register_chatcommand("tphr", {
    description = S("Request player to teleport to you"),
    params = S("<playername> | leave playername empty to see help message"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tphr_send)
})

minetest.register_chatcommand("tpc", {
    description = S("Teleport to coordinates"),
    params = S("<coordinates> | leave coordinates empty to see help message"),
    privs = {interact = true, tp = true, comod_teleport = true},
    func = safe_func(tp.tpc_send)
})

minetest.register_chatcommand("tpj", {
    description = S("Teleport to relative position"),
    params = S("<axis> <distance> | leave empty to see help message"),
    privs = {interact = true, tp = true, comod_teleport = true},
    func = safe_func(tp.tpj)
})

minetest.register_chatcommand("tpe", {
    description = S("Evade Enemy"),
    privs = {interact = true, tp = true, comod_teleport = true},
    func = safe_func(tp.tpe)
})

minetest.register_chatcommand("tpy", {
    description = S("Accept teleport requests from another player"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tpr_accept)
})

minetest.register_chatcommand("tpn", {
    description = S("Deny teleport requests from another player"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tpr_deny)
})

minetest.register_chatcommand("tpf", {
    description = S("Show all teleport requests, made by you or to you, that are still active"),
    privs = {interact = true, tp = true},
    func = safe_func(function(player)
        tp.tpf_update_time = tp.tpf_update_time or {}
        tp.tpf_update_time[player] = true
        -- safely call list_requests
        if tp.list_requests then
            tp.list_requests(player)
        else
            minetest.chat_send_player(player, "[TELEPORT] No teleport requests available.")
        end
    end)
})

minetest.register_chatcommand("tpr_mute", {
    description = S("Mutes a player: denies them from sending you teleport requests"),
    params = S("<playername> | leave playername empty to see help message"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tpr_mute)
})

minetest.register_chatcommand("tpr_unmute", {
    description = S("Unmutes a player: allow them to send you teleport requests again"),
    params = S("<playername> | leave playername empty to see help message"),
    privs = {interact = true, tp = true},
    func = safe_func(tp.tpr_unmute)
})
