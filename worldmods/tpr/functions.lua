--[[
Functions
Copyright (C) 2014-2024 ChaosWormz and contributors
--]]

tp = tp or {}
tp.S = tp.S or function(s) return s end
tp.message_color = tp.message_color or "#FFFFFF"
tp.timeout_delay = tp.timeout_delay or 60

-- Placeholders
local chatmsg, source, target
local target_coords, tpc_target_coords, old_tpc_target_coords
local spam_prevention = {}
local band = false
local muted_players = {}

-- Message colors
local message_color = tp.message_color
local TELEPORT_PREFIX = minetest.colorize("#AAAAFF", "[TELEPORT] ")
local NAME_COLOR = "#ADFF2F"
local function pname(name) return minetest.colorize(NAME_COLOR, name) end

-- Helper to safely get player name from object or string
local function get_name(player)
    if type(player) == "string" then return player end
    if player and player.get_player_name then return player:get_player_name() end
    return nil
end

-- Chat2 color conversion
local function color_string_to_number(color)
    if string.sub(color,1,1) == '#' then color = string.sub(color,2) end
    if #color < 6 then
        local r,g,b = string.sub(color,1,1),string.sub(color,2,2),string.sub(color,3,3)
        color = r..r..g..g..b..b
    elseif #color > 6 then
        color = string.sub(color,1,6)
    end
    return tonumber(color,16)
end
local message_color_number = color_string_to_number(message_color)

-- Send chat message
local function send_message(player, message)
    local pname_obj = get_name(player)
    if pname_obj then
        minetest.chat_send_player(pname_obj, minetest.colorize(message_color, message))
        if minetest.get_modpath("chat2") then
            local obj = minetest.get_player_by_name(pname_obj)
            if obj then
                chat2.send_message(obj, message, message_color_number)
            end
        end
    end
end

-- Cooldown functions
function tp.format_time(seconds)
    local min = math.floor(seconds/60)
    local sec = seconds % 60
    return min.." min "..sec.." s"
end

local request_cooldowns = {}
function tp.can_send_request(sender,receiver,mode)
    local key = sender.."->"..receiver.."@"..mode
    if request_cooldowns[key] and os.time()-request_cooldowns[key] < tp.timeout_delay then
        return false
    end
    return true
end
function tp.set_request_timestamp(sender,receiver,mode)
    request_cooldowns[sender.."->"..receiver.."@"..mode] = os.time()
end
function tp.cooldown_left(sender,receiver,mode)
    local key = sender.."->"..receiver.."@"..mode
    if request_cooldowns[key] then
        local passed = os.time() - request_cooldowns[key]
        return math.max(tp.timeout_delay - passed,0)
    end
    return 0
end

-- Teleport requests
local next_request_id = 0
local request_list,sender_list,receiver_list,area_list = {},{},{},{}

function tp.make_request(sender,receiver,direction)
    next_request_id = next_request_id+1
    request_list[next_request_id] = {time=os.time(),direction=direction or "receiver",receiver=receiver,sender=sender}

    receiver_list[receiver] = receiver_list[receiver] or {count=0}
    receiver_list[receiver][next_request_id] = true
    receiver_list[receiver].count = receiver_list[receiver].count+1

    sender_list[sender] = sender_list[sender] or {count=0}
    sender_list[sender][next_request_id] = true
    sender_list[sender].count = sender_list[sender].count+1

    tp.set_request_timestamp(sender,receiver,(direction=="receiver") and "tpr" or "tphr")
    return next_request_id
end

function tp.clear_request(id)
    local request = request_list[id]
    if not request then return end
    request_list[id] = nil
    sender_list[request.sender][id] = nil
    receiver_list[request.receiver][id] = nil
    sender_list[request.sender].count = sender_list[request.sender].count-1
    receiver_list[request.receiver].count = receiver_list[request.receiver].count-1
    return request
end

-- Teleport player function
function tp.tpp_teleport_player(player,pos)
    if not player or not pos then return end
    local player_obj = player
    if type(player)=="string" then player_obj = minetest.get_player_by_name(player) end
    if not player_obj then return end
    player_obj:set_pos(pos)
    send_message(player_obj, TELEPORT_PREFIX.."Teleported!")
end

-- /tpr
function tp.tpr_send(sender,receiver)
    local sender_name = get_name(sender)
    if sender_name==receiver then send_message(sender_name,TELEPORT_PREFIX.."You cannot teleport to yourself.") return end
    if muted_players[receiver]==sender_name then send_message(sender_name,TELEPORT_PREFIX.."They muted you, cannot send request to "..receiver) return end
    if receiver=="" then send_message(sender_name,TELEPORT_PREFIX.."Usage: /tpr <playername>") return end
    if not minetest.get_player_by_name(receiver) then send_message(sender_name,TELEPORT_PREFIX.."Player not online") return end
    if not tp.can_send_request(sender_name,receiver,"tpr") then
        send_message(sender_name,minetest.colorize("#FFFF00","You cannot send teleport request within next "..tp.format_time(tp.cooldown_left(sender_name,receiver,"tpr"))))
        return
    end
    send_message(receiver, TELEPORT_PREFIX..pname(sender_name).." wants to teleport to you. /tpy to accept.")
    send_message(sender_name, TELEPORT_PREFIX.."Teleport request sent! You will be able to send request again in "..tp.timeout_delay.." seconds.")
    local tp_id = tp.make_request(sender_name,receiver,"receiver")
    minetest.after(tp.timeout_delay,function(id)
        if request_list[id] then
            local r = tp.clear_request(id)
            send_message(r.sender, TELEPORT_PREFIX.."Request timed-out.")
            send_message(r.receiver, TELEPORT_PREFIX.."Request timed-out.")
        end
    end,tp_id)
end

-- /tphr
function tp.tphr_send(sender,receiver)
    local sender_name = get_name(sender)
    if sender_name==receiver then send_message(sender_name,TELEPORT_PREFIX.."You cannot teleport to yourself.") return end
    if muted_players[receiver]==sender_name then send_message(sender_name,TELEPORT_PREFIX.."They muted you, cannot send request to "..receiver) return end
    if receiver=="" then send_message(sender_name,TELEPORT_PREFIX.."Usage: /tphr <playername>") return end
    if not minetest.get_player_by_name(receiver) then send_message(sender_name,TELEPORT_PREFIX.."Player not online") return end
    if not tp.can_send_request(sender_name,receiver,"tphr") then
        send_message(sender_name,minetest.colorize("#FFFF00","You cannot send teleport request within next "..tp.format_time(tp.cooldown_left(sender_name,receiver,"tphr"))))
        return
    end
    send_message(receiver, TELEPORT_PREFIX..pname(sender_name).." wants you to teleport to them. /tpy to accept, /tpn to deny.")
    send_message(sender_name, TELEPORT_PREFIX.."Teleport request sent! You will be able to send request again in "..tp.timeout_delay.." seconds.")
    local tp_id = tp.make_request(sender_name,receiver,"sender")
    minetest.after(tp.timeout_delay,function(id)
        if request_list[id] then
            local r = tp.clear_request(id)
            send_message(r.sender, TELEPORT_PREFIX.."Request timed-out.")
            send_message(r.receiver, TELEPORT_PREFIX.."Request timed-out.")
        end
    end,tp_id)
end

-- /tpy (accept teleport requests)
function tp.tpr_accept(player)
    local pname_obj = get_name(player)
    if not pname_obj then return end

    for id,r in pairs(request_list) do
        if r.receiver == pname_obj then
            local sender_obj = minetest.get_player_by_name(r.sender)
            local receiver_obj = minetest.get_player_by_name(pname_obj)
            if sender_obj and receiver_obj then
                if r.direction == "receiver" then
                    -- /tpr: teleport sender to receiver
                    tp.tpp_teleport_player(sender_obj, receiver_obj:get_pos())
                elseif r.direction == "sender" then
                    -- /tphr: teleport receiver to sender
                    tp.tpp_teleport_player(receiver_obj, sender_obj:get_pos())
                end
                send_message(sender_obj, TELEPORT_PREFIX.."Request accepted!")
                send_message(receiver_obj, TELEPORT_PREFIX.."You accepted "..pname(r.sender).."'s request.")
            end
            tp.clear_request(id)
            return
        end
    end

    send_message(minetest.get_player_by_name(pname_obj), TELEPORT_PREFIX.."No requests to accept.")
end


-- /tpn
function tp.tpr_deny(player)
    local pname_obj = get_name(player)
    if not pname_obj then return end
    for id,r in pairs(request_list) do
        if r.receiver==pname_obj then
            local sender_obj = minetest.get_player_by_name(r.sender)
            if sender_obj then send_message(sender_obj, TELEPORT_PREFIX.."Your request was denied.") end
            send_message(minetest.get_player_by_name(pname_obj), TELEPORT_PREFIX.."You denied "..pname(r.sender).."'s request.")
            tp.clear_request(id)
            return
        end
    end
    send_message(minetest.get_player_by_name(pname_obj), TELEPORT_PREFIX.."No requests to deny.")
end

-- Teleport to coordinates
function tp.tpc_send(player,param)
    local x,y,z = string.match(param,"(-?%d+),(-?%d+),(-?%d+)")
    x,y,z = tonumber(x), tonumber(y), tonumber(z)
    if x and y and z then
        tp.tpp_teleport_player(player,{x=x,y=y,z=z})
    else
        send_message(player, TELEPORT_PREFIX.."Usage: /tpc <x,y,z>")
    end
end

-- Teleport relative
function tp.tpj(player,param)
    local axis,dist = string.match(param,"(%a+)%s+(-?%d+)")
    dist = tonumber(dist)
    if not axis or not dist then send_message(player, TELEPORT_PREFIX.."Usage: /tpj <x/y/z> <distance>") return end
    local pos = player:get_pos()
    if axis=="x" then pos.x = pos.x + dist
    elseif axis=="y" then pos.y = pos.y + dist
    elseif axis=="z" then pos.z = pos.z + dist
    else send_message(player, TELEPORT_PREFIX.."Axis must be x, y, or z") return end
    tp.tpp_teleport_player(player,pos)
end

-- Evade enemy
function tp.tpe(player)
    local pos = player:get_pos()
    pos.y = pos.y + 10
    tp.tpp_teleport_player(player,pos)
end

-- Mute a player from sending you teleport requests
function tp.tpr_mute(player, param)
    local target = param
    if not target or target == "" then
        send_message(player, "[TELEPORT] Usage: /tpr_mute <playername>")
        return
    end
    muted_players[target] = get_name(player)
    send_message(player, "[TELEPORT] You muted "..target.." from sending teleport requests.")
end

-- Unmute a player
function tp.tpr_unmute(player, param)
    local target = param
    if not target or target == "" then
        send_message(player, "[TELEPORT] Usage: /tpr_unmute <playername>")
        return
    end
    muted_players[target] = nil
    send_message(player, "[TELEPORT] You unmuted "..target.." for teleport requests.")
end
