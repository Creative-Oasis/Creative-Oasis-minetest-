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

core.register_on_mods_loaded(function()
    --
    -- Custom: Add compatible trees to axe - tree capitator
    --
    for key, value in pairs(core.registered_nodes) do
        if core.get_item_group(key, 'tree') > 0 then
            table.insert(x_obsidianmese.capitator_tree_names, key)
        end
    end

    x_obsidianmese.register_capitator()

    --
    -- Custom: `on_punch` for Entities
    --
    for name, def in pairs(core.registered_entities) do
        local old_punch = def.on_punch

        if not old_punch then
            old_punch = function() end
        end

        local on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
            old_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)

            local pos = self.object:get_pos()

            if not pos then
                return
            end

            -- Prevent infinite loop
            if not self._x_obsidianmese_skip_do_raycast then
                x_obsidianmese:do_raycast({
                    pos = pos,
                    player = puncher,
                    time_from_last_punch = time_from_last_punch,
                    tool_capabilities = tool_capabilities,
                    dir = dir
                })
            end

            self._x_obsidianmese_skip_do_raycast = false
        end

        def.on_punch = on_punch

        core.register_entity(':' .. name, def)
    end
end)

core.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    x_obsidianmese:do_raycast({
        pos = pos,
        player = puncher
    })
end)

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter:is_player() then
        return
    end

    local hitter_meta = hitter:get_meta()
    local x_obsidianmese_skip_do_raycast = hitter_meta:get_int('x_obsidianmese_skip_do_raycast') ~= 0

    -- Prevent infinite loop
    if not x_obsidianmese_skip_do_raycast then
        x_obsidianmese:do_raycast({
            pos = player:get_pos(),
            player = hitter,
            time_from_last_punch = time_from_last_punch,
            tool_capabilities = tool_capabilities,
            dir = dir
        })
    end

    hitter_meta:set_int('x_obsidianmese_skip_do_raycast', 0)
end)

core.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()

    x_obsidianmese.controls.players[player_name] = {}
    x_obsidianmese.sword_projectile[player_name] = {}

    for key in pairs(player:get_player_control()) do
        x_obsidianmese.controls.players[player_name][key] = {false}
    end
end)

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()

    x_obsidianmese:cancel_charging(player, { ignore_after = true })

    x_obsidianmese.controls.players[player_name] = nil
    x_obsidianmese.sword_projectile[player_name] = nil
end)

local time_to_charge = 2

x_obsidianmese:register_on_press(function(player, key, length)
    local player_name = player:get_player_name()

    if key == 'dig' and (x_obsidianmese.sword_projectile[player_name].charging or
    x_obsidianmese.sword_projectile[player_name].charged) then
        -- Reset timer
        x_obsidianmese:cancel_charging(player, { fade_out = true })
        return
    end

    if key ~= 'place' then
        return
    end

    local wielditem = player:get_wielded_item()
    local wielditem_name = wielditem:get_name()

    if wielditem_name == 'x_obsidianmese:sword_engraved' then
        local time = core.get_us_time() / 1e6

        x_obsidianmese.sword_projectile[player_name].charge_time_start = time
        x_obsidianmese.sword_projectile[player_name].wield_index = player:get_wield_index()
        x_obsidianmese.sword_projectile[player_name].wielditem = player:get_wielded_item()
        x_obsidianmese.sword_projectile[player_name].wielditem_orig = player:get_wielded_item()
    end
end)

x_obsidianmese:register_on_hold(function(player, key, length)
    if key ~= 'place' then
        return
    end

    local player_name = player:get_player_name()
    local stored_wield_index = x_obsidianmese.sword_projectile[player_name].wield_index
    local stored_wielditem = x_obsidianmese.sword_projectile[player_name].wielditem

    if not stored_wield_index or not stored_wielditem then
        return
    end

    local wielditem = player:get_wielded_item()
    local wield_index = player:get_wield_index()
    local wielditem_name = wielditem:get_name()
    local wielditem_meta = stored_wielditem:get_meta()
    local time = core.get_us_time() / 1e6

    if wield_index == stored_wield_index and wielditem_name == 'x_obsidianmese:sword_engraved' then
        -- Same/valid tool/slot index selected
        x_obsidianmese.sword_projectile[player_name].charge_time = time - x_obsidianmese.sword_projectile[player_name].charge_time_start
    else
        -- Reset timer
        x_obsidianmese:cancel_charging(player, { fade_out = true })
        return
    end

    if x_obsidianmese.sword_projectile[player_name].charge_time > 0.6 and x_obsidianmese.sword_projectile[player_name].charge_time <= time_to_charge then
        if not x_obsidianmese.sword_projectile[player_name].charging then
            -- Charging
            local pos = player:get_pos()
            local player_props = player:get_properties()
            local eye_height = player_props.eye_height or 1.625
            local entity_pos = vector.new(pos.x, pos.y + eye_height, pos.z)
            local look_dir = player:get_look_dir()

            x_obsidianmese.sword_projectile[player_name].charging = true
            x_obsidianmese.sword_projectile[player_name].charged = false
            -- from 5.9.0
            wielditem_meta:set_float('range', 0)

            core.after(0, function(v_player)
                x_obsidianmese:set_sword_wielded_item(v_player)
            end, player)

            local staticdata = {
                _user_name = player_name,
                _set_velocity = false,
                _set_acceleration = false,
                _lifetime = 30,
                _lifetime_cancel_charging = true,
                _skip_raycast = true,
                _follow_look_dir = true,
                _fade_in = true,
                _textures = { 'x_obsidianmese_sword_projectile_discharged.png' }
            }

            -- Add "charging" entity
            x_obsidianmese.sword_projectile[player_name].charge_ent_obj = core.add_entity(vector.add(entity_pos, vector.multiply(look_dir, 1)), 'x_obsidianmese:sword_bullet', core.serialize(staticdata))

            if x_obsidianmese.sword_projectile[player_name].charge_ent_obj then
                -- Add "charging" sound
                x_obsidianmese.sword_projectile[player_name].charge_sound_handle = core.sound_play({
                    name = 'x_obsidianmese_projectile_charge',
                    gain = 1,
                    fade = 0.33
                }, {
                    -- total sound length: 5.143 s
                    start_time = math.random(0, 50) / 10,
                    object = x_obsidianmese.sword_projectile[player_name].charge_ent_obj,
                    loop = true
                }, false)
            end
        end
    elseif x_obsidianmese.sword_projectile[player_name].charge_time > time_to_charge then
        if not x_obsidianmese.sword_projectile[player_name].charged then
            -- Charged
            x_obsidianmese.sword_projectile[player_name].charging = false
            x_obsidianmese.sword_projectile[player_name].charged = true
            x_obsidianmese:remove_projectile_sounds(player, { charge_sound = true })

            if x_obsidianmese.sword_projectile[player_name].charge_ent_obj then
                local luaentity = x_obsidianmese.sword_projectile[player_name].charge_ent_obj:get_luaentity()

                if not luaentity then
                    return
                end

                 -- Crit Hit (10% chance)
                if math.random(1, 10) == 1 then
                    x_obsidianmese.sword_projectile[player_name].is_critical_hit = true
                    luaentity._is_critical_hit = true
                end

                -- Change "charging" enity appearance (now it's charged)
                x_obsidianmese.sword_projectile[player_name].charge_ent_obj:set_properties({ textures = x_obsidianmese.sword_projectile[player_name].is_critical_hit and { 'x_obsidianmese_sword_projectile_crit.png' } or luaentity._orig_textures })

                -- Add "charged" sound
                x_obsidianmese.sword_projectile[player_name].charged_sound_handle = core.sound_play({
                    name = 'x_obsidianmese_projectile_charged',
                    gain = 1,
                    fade = 0.33
                }, {
                    object = x_obsidianmese.sword_projectile[player_name].charge_ent_obj,
                    loop = true
                }, false)
            end
        end
    end
end)

x_obsidianmese:register_on_release(function(player, key, length)
    if key ~= 'place' then
        return
    end

    local player_name = player:get_player_name()

    if (x_obsidianmese.sword_projectile[player_name].charge_time or 0) > time_to_charge then
        x_obsidianmese.sword_projectile[player_name].charge_time = 0
        local wielditem = player:get_wielded_item()

        x_obsidianmese:cancel_charging(player)

        if  wielditem:get_name() == 'x_obsidianmese:sword_engraved' then
            x_obsidianmese.fire_sword(player)
        end
    else
        x_obsidianmese:cancel_charging(player, { fade_out = true })
    end
end)

--- Controls code from: https://github.com/mt-mods/controls
core.register_globalstep(function(dtime)
    for k, player in pairs(core.get_connected_players()) do
        local name = player:get_player_name()

        if x_obsidianmese.controls.players[name] then
            -- microseconds to seconds
            local time = core.get_us_time() / 1e6
            local player_controls = x_obsidianmese.controls.players[name]

            for key, pressed in pairs(player:get_player_control()) do
                if player_controls[key] then
                    if pressed and not player_controls[key][1] then
                        for _, callback in pairs(x_obsidianmese.controls.registered_on_press) do
                            callback(player, key)
                        end

                        player_controls[key] = { true, time }

                    elseif pressed and player_controls[key][1] then
                        for _, callback in pairs(x_obsidianmese.controls.registered_on_hold) do
                            callback(player, key, (time - player_controls[key][2]))
                        end

                    elseif not pressed and player_controls[key][1] then
                        for _, callback in pairs(x_obsidianmese.controls.registered_on_release) do
                            callback(player, key, (time - player_controls[key][2]))
                        end

                        player_controls[key] = {false}
                    end
                end
            end
        end
    end
end)
