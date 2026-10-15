--[[
    X Obsidianmese. Adds obsidian and mese tools and items.
    Copyright (C) 2025 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
--]]

x_obsidianmese = x_obsidianmese --[[@as XObsidianmese]]
default = default --[[@as MtgDefault]]

function x_obsidianmese.get_chest_formspec()
    local formspec =
        'size[8,9]' ..
        'list[current_player;x_obsidianmese:chest;0,0.3;8,4;]' ..
        'list[current_player;main;0,4.85;8,1;]' ..
        'list[current_player;main;0,6.08;8,3;8]' ..
        'listring[current_player;x_obsidianmese:chest]' ..
        'listring[current_player;main]' ..
        default.get_hotbar_bg(0, 4.85)
    return formspec
end

local function chest_lid_obstructed(pos)
    local above = { x = pos.x, y = pos.y + 1, z = pos.z }
    local def = core.registered_nodes[core.get_node(above).name]
    -- allow ladders, signs, wallmounted things and torches to not obstruct
    if def and
            (def.drawtype == 'airlike' or
            def.drawtype == 'signlike' or
            def.drawtype == 'torchlike' or
            (def.drawtype == 'nodebox' and def.paramtype2 == 'wallmounted')) then
        return false
    end
    return true
end

local open_chests = {}

local function chest_lid_close(pn)
    local chest_open_info = open_chests[pn]
    local pos = chest_open_info.pos
    local sound = chest_open_info.sound
    local swap = chest_open_info.swap

    open_chests[pn] = nil
    for k, v in pairs(open_chests) do
        if v.pos.x == pos.x and v.pos.y == pos.y and v.pos.z == pos.z then
            return true
        end
    end

    local node = core.get_node(pos)
    core.after(0.2, core.swap_node, pos, { name = 'x_obsidianmese:' .. swap,
            param2 = node.param2 })
    core.sound_play(sound, { gain = 0.3, pos = pos,
        max_hear_distance = 10 }, true)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= 'x_obsidianmese:chest' then
        return
    end
    if not player or not fields.quit then
        return
    end
    local pn = player:get_player_name()

    if not open_chests[pn] then
        return
    end

    chest_lid_close(pn)
end)

core.register_on_leaveplayer(function(player, timed_out)
    local pn = player:get_player_name()
    if open_chests[pn] then
        chest_lid_close(pn)
    end
end)

function x_obsidianmese.register_chest(name, d)
    local def = table.copy(d)
    def.drawtype = 'mesh'
    def.visual = 'mesh'
    def.paramtype = 'light'
    def.paramtype2 = 'facedir'
    def.legacy_facedir_simple = true
    def.is_ground_content = false

    def.on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string('infotext', 'Obsidian Mese Chest')
        x_obsidianmese.add_effects(pos)
        core.get_node_timer(pos):start(5)
    end

    def.on_destruct = function(pos)
        core.get_node_timer(pos):stop()
    end

    def.on_rightclick = function(pos, node, clicker)
        core.sound_play(def.sound_open, { gain = 0.3, pos = pos,
                max_hear_distance = 10 })
        if not chest_lid_obstructed(pos) then
            core.swap_node(pos, {
                    name = 'x_obsidianmese:' .. name .. '_open',
                    param2 = node.param2 })
        end
        core.after(0.2, core.show_formspec,
                clicker:get_player_name(),
                'x_obsidianmese:chest', x_obsidianmese.get_chest_formspec())
        open_chests[clicker:get_player_name()] = { pos = pos,
                sound = def.sound_close, swap = name }
    end

    def.on_timer = function(pos, elapsed)
        x_obsidianmese.add_effects(pos)
        return true
    end

    def.on_metadata_inventory_move = function(pos, from_list, from_index,
            to_list, to_index, count, player)
        core.log('action', player:get_player_name() ..
            ' moves stuff in chest at ' .. core.pos_to_string(pos))
    end

    def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
        core.log('action', player:get_player_name() ..
            ' moves ' .. stack:get_name() ..
            ' to chest at ' .. core.pos_to_string(pos))
    end

    def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
        core.log('action', player:get_player_name() ..
            ' takes ' .. stack:get_name() ..
            ' from chest at ' .. core.pos_to_string(pos))
    end

    def.on_blast = function() end

    local def_opened = table.copy(def)
    local def_closed = table.copy(def)

    def_opened.mesh = 'chest_open.obj'

    for i = 1, #def_opened.tiles do
        if type(def_opened.tiles[i]) == 'string' then
            def_opened.tiles[i] = { name = def_opened.tiles[i], backface_culling = true }
        elseif def_opened.tiles[i].backface_culling == nil then
            def_opened.tiles[i].backface_culling = true
        end
    end

    def_opened.drop = 'x_obsidianmese:' .. name
    def_opened.groups.not_in_creative_inventory = 1
    def_opened.selection_box = {
        type = 'fixed',
        fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 3 / 16, 1 / 2 },
    }

    def_opened.can_dig = function()
        return false
    end

    def_closed.mesh = nil
    def_closed.drawtype = nil
    def_closed.tiles[6] = def.tiles[5] -- swap textures around for 'normal'
    def_closed.tiles[5] = def.tiles[3] -- drawtype to make them match the mesh
    def_closed.tiles[3] = def.tiles[3] .. '^[transformFX'

    core.register_node('x_obsidianmese:' .. name, def_closed)
    core.register_node('x_obsidianmese:' .. name .. '_open', def_opened)
end

x_obsidianmese.register_chest('chest', {
    description = 'Obsidian Mese Chest',
    tiles = {
        'x_obsidianmese_chest_top.png',
        'x_obsidianmese_chest_top.png',
        'x_obsidianmese_chest_side.png',
        'x_obsidianmese_chest_side.png',
        'x_obsidianmese_chest_front.png',
        'x_obsidianmese_chest_inside.png'
    },
    sounds = default.node_sound_stone_defaults(),
    sound_open = 'x_obsidianmese_chest_open',
    sound_close = 'x_obsidianmese_chest_close',
    groups = { cracky = 1, level = 2 },
    light_source = 6,
})

core.register_on_joinplayer(function(player)
    local inv = player:get_inventory() --[[@as InvRef]]
    inv:set_size('x_obsidianmese:chest', 8 * 4)
end)
