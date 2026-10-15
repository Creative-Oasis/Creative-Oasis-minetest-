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

--
-- Tools
--

local S = core.get_translator(core.get_current_modname())

-- sword
core.register_tool('x_obsidianmese:sword', {
    description = 'Obsidian Mese Sword'
    .. '\n' .. core.colorize('#AAAAAA', S('Durable'))
    .. '\n' .. core.colorize('#AAAAAA', S('Damage: 10'))
    .. '\n' .. core.colorize('#00FF00', S('Critical Hit Chance') .. ': ' .. (1 / 10) * 100 .. '%'),
    short_description = 'Obsidian Mese Sword',
    inventory_image = 'x_obsidianmese_sword.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.45,
        max_drop_level = 2,
        groupcaps = {
            fleshy = { times = { [1] = 2.00, [2] = 0.65, [3] = 0.25 }, uses = 400, maxlevel = 3 },
            snappy = { times = { [1] = 1.90, [2] = 0.70, [3] = 0.25 }, uses = 350, maxlevel = 3 },
            choppy = { times = { [3] = 0.65 }, uses = 300, maxlevel = 0 }
        },
        damage_groups = { fleshy = 10 },
    },
    sound = { breaks = 'default_tool_breaks' },
    groups = { sword = 1, enchantability = 10 },
    _x_obsidianmese = {
        slash_texture = 'x_obsidianmese_sword_slash.png',
        crit_chance = 10
    }
})

local x_obsidianmese_sword_engraved_conf = {
    description = 'Obsidian Mese Sword Engraved'
        .. '\n' .. core.colorize('#AAAAAA', S('Shoots Projectiles with Splash Damage'))
        .. '\n' .. core.colorize('#AAAAAA', S('Damage: 8'))
        .. '\n' .. core.colorize('#00BFFF', S('Charge Time: 2s'))
        .. '\n' .. core.colorize('#00FF00', S('Projectile Critical Hit Chance') .. ': ' .. (1 / 10) * 100 .. '%')
        .. '\n' .. core.colorize('#FF8080', S('Projectile Damage') .. ': +2'),
    short_description = 'Obsidian Mese Sword Engraved',
    inventory_image = 'x_obsidianmese_sword_diamond_engraved.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.6,
        max_drop_level = 1,
        groupcaps = {
            snappy = { times = { [1] = 1.90, [2] = 0.90, [3] = 0.30 }, uses = 300, maxlevel = 3 },
        },
        damage_groups = { fleshy = 8 },
    },
    sound = { breaks = 'default_tool_breaks' },
    groups = { sword = 1, enchantability = 5 },
    _x_obsidianmese = {
        slash_texture = 'x_obsidianmese_sword_diamond_engraved_slash.png'
    }
}

-- sword engraved
core.register_tool('x_obsidianmese:sword_engraved', table.copy(x_obsidianmese_sword_engraved_conf))

-- sword engraved - charging
-- needed for < 5.9.0
-- local x_obsidianmese_sword_engraved_charging_conf = table.copy(x_obsidianmese_sword_engraved_conf)
-- x_obsidianmese_sword_engraved_charging_conf.range = 0

-- core.register_tool('x_obsidianmese:sword_engraved_charging', x_obsidianmese_sword_engraved_charging_conf)

-- pick axe
core.register_tool('x_obsidianmese:pick', {
    description = 'Obsidian Mese Pickaxe. Very durable and versatile pick for long mining.',
    short_description = 'Obsidian Mese Pickaxe',
    inventory_image = 'x_obsidianmese_pick.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 4,
        groupcaps = {
            cracky = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.50 }, uses = 250, maxlevel = 3 },
            crumbly = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.5 }, uses = 350, maxlevel = 3 },
            snappy = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.5 }, uses = 300, maxlevel = 3 }
        },
        damage_groups = { fleshy = 5 },
    },
    sound = { breaks = 'default_tool_breaks' },
    groups = { pickaxe = 1, enchantability = 10 },
    _x_obsidianmese = {
        slash_texture = 'x_obsidianmese_pick_slash.png',
        slash_glow = 7,
        -- old particle def
        slash_size = 40,
         -- new particle def > 5.9.0
        slash_scale = { x = 40, y = 40 },
        slash_sound_name = 'x_obsidianmese_heavy_swing'
    }
})

-- pick axe engraved
core.register_tool('x_obsidianmese:pick_engraved', {
    description =
        'Obsidian Mese Pickaxe Engraved - right click to place item next to the pickaxe in your inventory slot',
    short_description = 'Obsidian Mese Pickaxe Engraved',
    inventory_image = 'x_obsidianmese_pick_engraved.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 4,
        groupcaps = {
            cracky = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.50 }, uses = 200, maxlevel = 3 }
        },
        damage_groups = { fleshy = 5 },
    },
    sound = { breaks = 'default_tool_breaks' },
    groups = { pickaxe = 1, enchantability = 10 },
    on_place = x_obsidianmese.pick_engraved_place,
    _x_obsidianmese = {
        slash_texture = 'x_obsidianmese_pick_slash_2.png',
        slash_glow = 7,
        slash_sound_name = 'x_obsidianmese_heavy_swing'
    }
})

-- shovel
core.register_tool('x_obsidianmese:shovel', {
    description = 'Obsidian Mese Shovel - right click (secondary click) for creating a path.',
    short_description = 'Obsidian Mese Shovel',
    inventory_image = 'x_obsidianmese_shovel.png',
    wield_image = 'x_obsidianmese_shovel.png^[transformR90',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 2,
        groupcaps = {
            crumbly = { times = { [1] = 1.10, [2] = 0.50, [3] = 0.30 }, uses = 50, maxlevel = 3 },
        },
        damage_groups = { fleshy = 4 },
    },
    sound = { breaks = 'default_tool_breaks' },
    groups = { shovel = 1, enchantability = 10 },
    on_place = x_obsidianmese.shovel_place
})

-- axe
core.register_tool('x_obsidianmese:axe', {
    description = 'Obsidian Mese Axe - Tree Capitator',
    short_description = 'Obsidian Mese Axe',
    inventory_image = 'x_obsidianmese_axe.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 1,
        groupcaps = {
            choppy = { times = { [1] = 2.10, [2] = 0.90, [3] = 0.50 }, uses = 30, maxlevel = 3 },
        },
        damage_groups = { fleshy = 7 },
    },
    groups = { axe = 1, enchantability = 10 },
    sound = { breaks = 'default_tool_breaks' },
    _x_obsidianmese = {
        slash_texture = true
    }
})

-- hoe
core.register_tool('x_obsidianmese:hoe', {
    description = 'Obsidian Mese Hoe',
    short_description = 'Obsidian Mese Hoe',
    inventory_image = 'x_obsidianmese_hoe.png',
    sound = { breaks = 'default_tool_breaks' },
    wield_scale = { x = 2, y = 2, z = 1 },
    groups = { hoe = 1 },

    on_use = function(itemstack, user, pointed_thing)
        if not user then
            return
        end

        local player_name = user and user:get_player_name() or ''
        local uses = 750

        if pointed_thing.type == 'object' then
            local ent = pointed_thing.ref:get_luaentity()
            local obj = ent.object
            local stack = ItemStack(ent.itemstring)
            local stack_name = stack:get_name()

            if stack_name ~= 'bucket:bucket_water' then
                return
            end

            if obj and ent.name == '__builtin:item' then
                -- place plowed farm
                local obj_pos = obj:get_pos()
                local pos1 = { x = obj_pos.x + 3, y = obj_pos.y, z = obj_pos.z + 3 }
                local pos2 = { x = obj_pos.x - 3, y = obj_pos.y, z = obj_pos.z - 3 }
                local nodes = core.find_nodes_in_area_under_air(pos1, pos2, { 'group:soil' })
                local nodes_remove_protected = {}

                -- check the center first (where the bucket is)
                if core.is_protected(obj_pos, player_name) then
                    core.record_protection_violation(obj_pos, player_name)
                    core.chat_send_player(player_name, 'This area is protected.')
                    return itemstack
                end

                for i, val in ipairs(nodes) do
                    if not core.is_protected(val, player_name) then
                        table.insert(nodes_remove_protected, val)
                    end
                end

                nodes = nodes_remove_protected

                if #nodes > 1 then
                    -- replace bucket with water
                    core.set_node(obj_pos, { name = 'default:water_source' })
                    obj:remove()

                    core.sound_play('default_dig_crumbly', {
                        pos = obj_pos,
                        gain = 0.5,
                    }, true)

                    -- place plowed farm dirt
                    for i, p in ipairs(nodes) do
                        local n = core.get_node(p)
                        local n_def = core.registered_nodes[n.name]

                        if n_def and core.get_item_group(n.name, 'soil') == 1 then
                            local p_above = {
                                x = p.x,
                                y = p.y + 1,
                                z = p.z
                            }

                            -- turn the node into soil and play sound
                            core.set_node(p, { name = n_def.soil.dry })

                            core.add_particlespawner({
                                amount = 10,
                                time = 0.5,
                                minpos = { x = p_above.x - 0.4, y = p_above.y - 0.4, z = p_above.z - 0.4 },
                                maxpos = { x = p_above.x + 0.4, y = p_above.y - 0.5, z = p_above.z + 0.4 },
                                minvel = { x = 0, y = 1, z = 0 },
                                maxvel = { x = 0, y = 2, z = 0 },
                                minacc = { x = 0, y = -4, z = 0 },
                                maxacc = { x = 0, y = -8, z = 0 },
                                minexptime = 1,
                                maxexptime = 1.5,
                                node = { name = n_def.soil.dry },
                                collisiondetection = true,
                                object_collision = true,
                            })

                            if not core.is_creative_enabled(user:get_player_name()) then
                                -- wear tool
                                local wdef = itemstack:get_definition()
                                itemstack:add_wear(65535 / (uses - 1))
                                -- tool break sound
                                if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
                                    core.sound_play(
                                        wdef.sound.breaks,
                                        {
                                            pos = pointed_thing.above,
                                            gain = 0.5
                                        },
                                        true
                                    )
                                end
                            end
                        end
                    end
                end
            end

        elseif pointed_thing.type == 'node' then
            -- plow row of soil
            local axis, dir = x_obsidianmese.player_axis(user)
            local pt = pointed_thing
            local under = pt.under

            if not under then
                return
            end

            local itemstack_def = itemstack:get_definition()

            for i = 0, 4 do
                if axis == 'x' then
                    pt.under = {
                        x = under.x + (i * dir),
                        y = under.y,
                        z = under.z
                    }

                    pt.above = {
                        x = pt.under.x,
                        y = pt.under.y + 1,
                        z = pt.under.z
                    }

                elseif axis == 'z' then
                    pt.under = {
                        x = under.x,
                        y = under.y,
                        z = under.z + (i * dir)
                    }

                    pt.above = {
                        x = pt.under.x,
                        y = pt.under.y + 1,
                        z = pt.under.z
                    }
                end

                if not core.is_protected(pt.under, player_name) then
                    x_obsidianmese.hoe_on_use(itemstack, user, pt)

                    if not core.is_creative_enabled(user:get_player_name()) then
                        -- wear tool
                        itemstack:add_wear(65535 / (uses - 1))
                        -- tool break sound
                        if itemstack:get_count() == 0 and itemstack_def.sound and itemstack_def.sound.breaks then
                            core.sound_play(itemstack_def.sound.breaks, { pos = pt.above, gain = 0.5 })
                        end
                    end
                end
            end
        elseif core.global_exists('farming') then
            return farming.hoe_on_use(itemstack, user, pointed_thing, uses)
        end

        return itemstack
    end,

    on_place = function(itemstack, placer, pointed_thing)
        if not placer then
            return
        end

        local axis, dir = x_obsidianmese.player_axis(placer)
        local pt = pointed_thing
        local above = pt.above
        local under = pt.under

        if not above or not under then
            return
        end

        if pt.type == 'node' then
            local pos = core.get_pointed_thing_position(pt)

            if not pos then
                return
            end

            local pointed_node = core.get_node(pos)
            local node_def = core.registered_nodes[pointed_node.name]

            if node_def and node_def.on_rightclick then
                return node_def.on_rightclick(under, pointed_node, placer, itemstack, pointed_thing) or itemstack
            end

            for i = 0, 4 do
                local inv = placer:get_inventory() --[[@as InvRef]]
                local inv_list = inv:get_list('main')
                local itemstack_seeds = {
                    stack = nil,
                    idx = nil
                }

                for k, st in ipairs(inv_list) do
                    if not st:is_empty() and core.get_item_group(st:get_name(), 'seed') > 0 then
                        table.insert(itemstack_seeds, { stack = st, idx = k })
                        break
                    end
                end

                if #itemstack_seeds == 0 then
                    return itemstack
                end

                -- take 1st found seed in the list
                local stack = itemstack_seeds[1].stack
                local stack_name = stack:get_name()
                local stack_name_split = stack_name:split(':')
                local stack_mod = stack_name_split[1]

                if pointed_node ~= nil and stack_name ~= '' and core.global_exists('farming') then
                    -- handle default farming and farming_addons placement
                    if stack_mod == 'farming' or stack_mod == 'x_farming' then
                        if axis == 'x' then
                            pt.above = {
                                x = above.x + (i * dir),
                                y = above.y,
                                z = above.z
                            }
                            pt.under = {
                                x = under.x + (i * dir),
                                y = under.y,
                                z = under.z
                            }

                        elseif axis == 'z' then
                            pt.above = {
                                x = above.x,
                                y = above.y,
                                z = above.z + (i * dir)
                            }
                            pt.under = {
                                x = under.x,
                                y = under.y,
                                z = under.z + (i * dir)
                            }
                        end

                        local stack_count = stack:get_count()
                        local seed_def = core.registered_items[stack_name]
						if not seed_def or not seed_def._farming_plant then
					    return itemstack
							end

						local plantname = seed_def._farming_plant

						local taken_stack = farming.place_seed(stack, placer, pt, plantname)


                        if taken_stack and stack_count ~= taken_stack:get_count() then
                            inv:set_stack('main', itemstack_seeds[1].idx, taken_stack)

                            if not core.settings:get_bool('creative_mode')
                                or not core.check_player_privs(placer:get_player_name(), { creative = true })
                            then
                                itemstack = x_obsidianmese.add_wear(itemstack)
                            end

                            core.add_particlespawner({
                                amount = 10,
                                time = 0.5,
                                minpos = { x = pt.above.x - 0.4, y = pt.above.y - 0.4, z = pt.above.z - 0.4 },
                                maxpos = { x = pt.above.x + 0.4, y = pt.above.y - 0.5, z = pt.above.z + 0.4 },
                                minvel = { x = 0, y = 1, z = 0 },
                                maxvel = { x = 0, y = 2, z = 0 },
                                minacc = { x = 0, y = -4, z = 0 },
                                maxacc = { x = 0, y = -8, z = 0 },
                                minexptime = 1,
                                maxexptime = 1.5,
                                node = { name = stack_name },
                                collisiondetection = true,
                                object_collision = true,
                            })
                        end
                    end
                end
            end

            return itemstack
        end
    end,
})
