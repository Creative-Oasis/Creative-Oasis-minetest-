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

x_obsidianmese = {
    mod = {
        ethereal = core.get_modpath('ethereal')
    },
    settings = {
        x_obsidianmese_chest = core.settings:get_bool('x_obsidianmese_chest', true),
        x_obsidianmese_sword_engraved_recipe = core.settings:get_bool('x_obsidianmese_sword_engraved_recipe', true),
        x_obsidianmese_swing_trail_enabled = core.settings:get_bool('x_obsidianmese_swing_trail_enabled', true)
    },
    capitator_tree_names = {
        'default:cactus',
        'x_farming:cactus',
    },
    path_node_defs = {},
    controls = {
        registered_on_press = {},
        registered_on_hold = {},
        registered_on_release = {},
        players = {}
    },
    sword_projectile = {},
    protocol_versions = core.protocol_versions or {
        ["5.0.0"] = 37,
        ["5.1.0"] = 38,
        ["5.2.0"] = 39,
        ["5.3.0"] = 39,
        ["5.4.0"] = 39,
        ["5.5.0"] = 40,
        ["5.6.0"] = 41,
        ["5.7.0"] = 42,
        ["5.8.0"] = 43,
        ["5.9.0"] = 44,
        ["5.9.1"] = 45,
        ["5.10.0"] = 46,
        ["5.11.0"] = 47,
        ["5.12.0"] = 48,
    }
}

-- save how many bullets owner fired
local enable_particles = core.settings:get_bool('enable_particles', true)

---Limits number `x` between `min` and `max` values
---@param x integer
---@param min integer
---@param max integer
---@return integer
local function limit(x, min, max)
    return math.min(math.max(x, min), max)
end

---Gets total armor level from 3d armor
---@param player ObjectRef
---@return integer
local function get_3d_armor_armor(player)
    local armor_total = 0

    if not player:is_player() or not core.get_modpath('3d_armor') or not armor.def[player:get_player_name()] then
        return armor_total
    end

    armor_total = armor.def[player:get_player_name()].level

    return armor_total
end

--- Punch damage calculator.
-- By default, this just calculates damage in the vanilla way. Switch it out for something else to change the default
function x_obsidianmese.damage_calculator(player, hitter, time_from_last_punch)
    local damage = 0
    local wielditem = hitter:get_wielded_item()
    local tool_capabilities = wielditem:get_tool_capabilities()
    local target_armor_groups = player:get_armor_groups()

    for group, base_damage in pairs(tool_capabilities.damage_groups) do
        damage = damage
        + base_damage
        * limit(time_from_last_punch / tool_capabilities.full_punch_interval, 0.0, 1.0)
        * ((target_armor_groups[group] or 0) + get_3d_armor_armor(player)) / 100.0
    end

    return damage
end

function x_obsidianmese.knockback_calculator(player, hitter, time_from_last_punch, dir, distance, damage)
    local old_calculate_knockback = core.calculate_knockback
    local wielditem = hitter:get_wielded_item()
    local tool_capabilities = wielditem:get_tool_capabilities()

    local knockback = old_calculate_knockback(
        player,
        hitter,
        time_from_last_punch,
        {
            full_punch_interval = tool_capabilities.full_punch_interval,
            damage_groups = { fleshy = damage }
        },
        dir,
        distance,
        damage
    )

    return knockback
end

function x_obsidianmese.is_valid_player_or_entity(self, object, hitter)
    local is_valid = false

    if object ~= hitter
        and (
            (
                object:is_player()
                and object:get_player_name() ~= hitter:get_player_name()
            )
            or (
                object:get_luaentity()
                and (
                    object:get_luaentity().physical
                    or object:get_properties().physical
                )
                and object:get_luaentity().name ~= '__builtin:item'
                and object:get_luaentity().name ~= 'x_obsidianmese:sword_bullet'
            )
        )
    then
        is_valid = true
    end

    return is_valid
end

function x_obsidianmese.punch_player_or_entity(self, pos, player, hitter, damage_modifier)
    if not player or (player and not self:is_valid_player_or_entity(player, hitter)) then
        return
    end

    local is_player = player:is_player()
    local obj_pos = player:get_pos()
    local direction = vector.direction(hitter:get_pos(), obj_pos)
    local distance = vector.distance(pos, obj_pos)
    local wielditem = hitter:get_wielded_item()
    local tool_capabilities = wielditem:get_tool_capabilities()
    local damage = self.damage_calculator(player, hitter, tool_capabilities.full_punch_interval)

    if damage_modifier and type(damage_modifier) == 'function' then
        damage = damage_modifier(damage)
    end

    local knockback_player = is_player and player or hitter
    local knockback_hitter = is_player and hitter or player
    local knockback = self.knockback_calculator(knockback_player, knockback_hitter, tool_capabilities.full_punch_interval, direction, distance, damage)

    if is_player then
        local hitter_meta = hitter:get_meta()
        -- Skip raycast for Swing Trail and Crit Hits
        hitter_meta:set_int('x_obsidianmese_skip_do_raycast', 1)
    elseif player:get_luaentity() then
        local luaentity = player:get_luaentity()
        -- Skip raycast for Swing Trail and Crit Hits
        luaentity._x_obsidianmese_skip_do_raycast = true
    end

    -- punch player or entity
    player:punch(
        hitter,
        tool_capabilities.full_punch_interval,
        {
            full_punch_interval = tool_capabilities.full_punch_interval,
            damage_groups = { fleshy = damage, knockback = knockback }
        },
        direction
    )

    -- knockback player or entity
    player:add_velocity(vector.multiply(direction, knockback))
end

function x_obsidianmese.punch_objects_inside_radius(self, pos, player, hitter, damage_modifier)
    local radius = 1.5
    local pos1 = vector.subtract(pos, radius)
    local pos2 = vector.add(pos, radius)

    for obj in core.objects_in_area(pos1, pos2) do
        -- Don't hit the same entity egain
        if obj ~= player then
            self:punch_player_or_entity(pos, obj, hitter, damage_modifier)
        end
    end

    -- Node (damage) particles
    for z = pos1.z, pos2.z do
        for y = pos1.y, pos2.y do
            for x = pos1.x, pos2.x do
                local p = vector.new(x, y, z)
                local node = core.get_node(p)
                local node_def = core.registered_nodes[node.name]

                if node_def and node_def.walkable then
                    -- check all sides of the node
                    for i = 1, 6 do
                        local _p = vector.new(p)
                        if i == 1 then
                            _p = vector.new(p.x, p.y + 1, p.z)
                        elseif i == 2 then
                            _p = vector.new(p.x, p.y - 1, p.z)
                        elseif i == 3 then
                            _p = vector.new(p.x + 1, p.y, p.z)
                        elseif i == 4 then
                            _p = vector.new(p.x - 1, p.y, p.z)
                        elseif i == 5 then
                            _p = vector.new(p.x, p.y, p.z + 1)
                        elseif i == 6 then
                            _p = vector.new(p.x, p.y, p.z - 1)
                        end

                        local n

                        if math.random(1, 2) == 1 then
                            n = core.get_node(_p)
                        end

                        if n and n.name == 'air' then
                            local direction = vector.direction(p, _p)
                            local minpos = vector.subtract(vector.new(p.x, p.y, p.z), vector.add(vector.multiply(direction, -1), 0.4))
                            local maxpos = vector.add(vector.new(p.x, p.y, p.z), vector.add(direction, 0.4))

                            core.add_particlespawner({
                                amount = 3,
                                time = 0.1,
                                minpos = minpos,
                                maxpos = maxpos,
                                minvel = vector.multiply(direction, 2),
                                maxvel = vector.multiply(direction, 3),
                                minacc = vector.new(0, -28, 0),
                                maxacc = vector.new(0, -32, 0),
                                minexptime = 0.2,
                                maxexptime = 0.4,
                                node = { name = node.name },
                                collisiondetection = false,
                                object_collision = false,
                            })
                        end
                    end
                end
            end
        end
    end
end

-- particles
function x_obsidianmese.add_effects(pos)

    if not enable_particles then return end

    if core.has_feature({ dynamic_add_media_table = true, particlespawner_tweenable = true }) then
        -- new syntax, after v5.6.0
        local particlespawner_def = {
            amount = 20,
            time = 5,
            size = {
                min = 0.5,
                max = 1.5,
            },
            exptime = 5,
            pos = {
                min = vector.new({ x = pos.x - 1.5, y = pos.y, z = pos.z - 1.5 }),
                max = vector.new({ x = pos.x + 1.5, y = pos.y + 1.5, z = pos.z + 1.5 }),
            },
            attract = {
                kind = 'point',
                strength = math.random(10, 30) / 100,
                origin = vector.new({ x = pos.x, y = pos.y, z = pos.z })
            },
            texture = {
                name = 'x_obsidianmese_chest_particle.png',
                alpha_tween = {
                    0.5, 1,
                    style = 'fwd',
                    reps = 1
                }
            },
            radius = { min = 1, max = 1.5, bias = 1 },
            glow = 6
        }

        core.add_particlespawner(particlespawner_def)
    else
        local nodes = core.find_nodes_in_area(
            vector.subtract(pos, 2),
            vector.add(pos, 2),
            { 'air' }
        )

        if #nodes == 0 then
            return
        end

        for i = 1, 10, 1 do
            local pos_random = nodes[math.random(1, #nodes)]
            local x = pos.x - pos_random.x
            local y = pos_random.y - pos.y
            local z = pos.z - pos_random.z
            local rand1 = (math.random(1, 10) / 10) * -1
            local rand2 = math.random(10, 500) / 100
            local rand3 = math.random(50, 150) / 100

            core.after(rand2, function()
                core.add_particle({
                    pos = pos_random,
                    velocity = vector.divide({ x = x, y = 1 - y, z = z }, 4),
                    acceleration = vector.divide({ x = 0, y = rand1, z = 0 }, 4),
                    expirationtime = 4.5,
                    size = rand3,
                    texture = 'x_obsidianmese_chest_particle.png',
                    glow = 6,
                    collisiondetection = true,
                    collision_removal = true
                })
            end)
        end
    end
end

-- check for player near by to activate particles
function x_obsidianmese.check_around_radius(pos)
    local player_near = false

    for _, obj in ipairs(core.get_objects_inside_radius(pos, 16)) do
        if obj:is_player() then
            player_near = true
            break
        end
    end

    return player_near
end

-- check if within physical map limits (-30911 to 30927)
function x_obsidianmese.within_limits(pos, radius)
    if not pos then
        return false
    end

    if (pos.x - radius) > -30913
    and (pos.x + radius) < 30928
    and (pos.y - radius) > -30913
    and (pos.y + radius) < 30928
    and (pos.z - radius) > -30913
    and (pos.z + radius) < 30928 then
        return true -- within limits
    end

    return false -- beyond limits
end

function x_obsidianmese.fire_sword(user)
    local pos = user:get_pos()
    local player_name = user:get_player_name()

    -- play shoot attack sound
    core.sound_play({
        name = 'x_obsidianmese_throwing',
        gain = 0.4,
    }, {
        pitch = math.random(7, 13) / 10,
        object = user,
        max_hear_distance = 32
    }, true)

    local player_props = user:get_properties()
    local eye_height = player_props.eye_height or 1.625
    local entity_pos = vector.new(pos.x, pos.y + eye_height, pos.z)
    local look_dir = user:get_look_dir()

    local staticdata = {
        _user_name = player_name,
        _set_velocity = true,
        _set_acceleration = true
    }

    if x_obsidianmese.sword_projectile[player_name].is_critical_hit then
        staticdata._is_critical_hit = true
        x_obsidianmese.sword_projectile[player_name].is_critical_hit = false
    end

    core.add_entity(vector.add(entity_pos, vector.multiply(look_dir, 1)), 'x_obsidianmese:sword_bullet', core.serialize(staticdata))

    -- wear tool
    if not core.is_creative_enabled(user:get_player_name()) then
        local wdef = x_obsidianmese.sword_projectile[player_name].wielditem:get_definition()
        x_obsidianmese.sword_projectile[player_name].wielditem:add_wear(65535 / (150 - 1))

        -- Tool break sound
        if x_obsidianmese.sword_projectile[player_name].wielditem:get_count() == 0 and wdef.sound and wdef.sound.breaks then
            core.sound_play(wdef.sound.breaks, { pos = pos, gain = 0.5 })
        end
    end
end

function x_obsidianmese.add_wear(itemstack, pos)
    -- wear tool
    local wdef = itemstack:get_definition()
    itemstack:add_wear(65535 / (400 - 1))
    -- Tool break sound
    if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
        core.sound_play(wdef.sound.breaks, { pos = pos, gain = 0.5 })
    end

    return itemstack
end

function x_obsidianmese.pick_engraved_place(itemstack, placer, pointed_thing)
    local idx = placer:get_wield_index() + 1 -- item to right of wielded tool
    local inv = placer:get_inventory() --[[@as InvRef]]
    -- stack to right of tool
    local stack = inv:get_stack('main', idx)
    local stack_name = stack:get_name()
    local under = pointed_thing.under
    local above = pointed_thing.above
    local temp_stack

    -- handle nodes
    if pointed_thing.type == 'node' then
        local pos = core.get_pointed_thing_position(pointed_thing)

        if not pos or stack_name == '' then
            return itemstack
        end

        local pointed_node = core.get_node(pos)
        local pointed_node_def = core.registered_nodes[pointed_node.name]

        if not pointed_node then
            return itemstack
        end

        -- check if we have to use default on_place first
        if pointed_node_def.on_rightclick then
            return pointed_node_def.on_rightclick(pos, pointed_node, placer, itemstack, pointed_thing)
        end

        local udef = core.registered_nodes[stack_name] or core.registered_items[stack_name]

        if udef and udef.on_place then
            temp_stack = udef.on_place(stack, placer, pointed_thing) or stack
            inv:set_stack('main', idx, temp_stack)

            -- play sound
            if udef.sounds then
                if udef.sounds.place then
                    core.sound_play(udef.sounds.place.name, {
                        gain = udef.sounds.place.gain or 1
                    })
                end
            end

            return itemstack
        elseif udef and udef.on_use then
            temp_stack = udef.on_use(stack, placer, pointed_thing) or stack
            inv:set_stack('main', idx, temp_stack)

            return itemstack
        end

        -- handle default torch placement
        if stack_name == 'default:torch' then
            local wdir = core.dir_to_wallmounted(vector.subtract(under, above))
            local fakestack = stack

            if wdir == 0 then
                fakestack:set_name('default:torch_ceiling')
            elseif wdir == 1 then
                fakestack:set_name('default:torch')
            else
                fakestack:set_name('default:torch_wall')
            end

            temp_stack = core.item_place(fakestack, placer, pointed_thing, wdir)

            temp_stack:set_name('default:torch')
            inv:set_stack('main', idx, temp_stack)

            -- play sound
            if udef.sounds then
                if udef.sounds.place then
                    core.sound_play(udef.sounds.place.name, {
                        gain = udef.sounds.place.gain or 1
                    })
                end
            end

            return itemstack
        end

        -- if everything else fails use default on_place
        stack = core.item_place(stack, placer, pointed_thing)
        inv:set_stack('main', idx, stack)

        -- play sound
        if udef.sounds then
            if udef.sounds.place then
                core.sound_play(udef.sounds.place.name, {
                    gain = udef.sounds.place.gain or 1
                })
            end
        end

        return itemstack
    end

    return itemstack
end

function x_obsidianmese.shovel_place(itemstack, placer, pointed_thing)
    local pt = pointed_thing

    -- check if pointing at a node
    if not pt then
        return itemstack
    end

    if pt.type ~= 'node' then
        return itemstack
    end

    local pos = core.get_pointed_thing_position(pointed_thing)

    if not pos then
        return itemstack
    end

    local pointed_node = core.get_node(pos)
    local pointed_node_def = core.registered_nodes[pointed_node.name]
    if pointed_node_def and pointed_node_def.on_rightclick then
        return pointed_node_def.on_rightclick(pos, pointed_node, placer, itemstack, pointed_thing)
    end

    local under = core.get_node(pt.under)
    local p = { x = pt.under.x, y = pt.under.y + 1, z = pt.under.z }
    local above = core.get_node(p)

    -- return if any of the nodes is not registered
    if not core.registered_nodes[under.name] then
        return itemstack
    end

    if not core.registered_nodes[above.name] then
        return itemstack
    end

    -- check if the node above the pointed thing is air
    if above.name ~= 'air' then
        return itemstack
    end

    if core.is_protected(pt.under, placer:get_player_name()) then
        core.record_protection_violation(pt.under, placer:get_player_name())
        return itemstack
    end

    if (under.name == 'default:dirt' or under.name == 'farming:soil' or under.name == 'farming:soil_wet')
        and under.name ~= 'x_obsidianmese:path_dirt'
    then
        -- dirt path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dirt' })

    elseif (under.name == 'default:dirt_with_grass' or under.name == 'default:dirt_with_grass_footsteps')
        and under.name ~= 'x_obsidianmese:path_grass'
    then
        -- grass path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_grass' })

    elseif under.name == 'default:dirt_with_rainforest_litter'
        and under.name ~= 'x_obsidianmese:path_dirt_with_rainforest_litter'
    then
        -- rainforest litter path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dirt_with_rainforest_litter' })

    elseif under.name == 'default:dirt_with_snow'
        and under.name ~= 'x_obsidianmese:path_dirt_with_snow'
    then
        -- dirt with snow path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dirt_with_snow' })

    elseif under.name == 'default:dirt_with_dry_grass'
        and under.name ~= 'x_obsidianmese:path_dirt_with_dry_grass'
    then
        -- dirt with dry grass path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dirt_with_dry_grass' })

    elseif under.name == 'default:dirt_with_coniferous_litter'
        and under.name ~= 'x_obsidianmese:path_dirt_with_coniferous_litter'
    then
        -- dirt with coniferous litter path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dirt_with_coniferous_litter' })

    elseif under.name == 'default:dry_dirt'
        and under.name ~= 'x_obsidianmese:path_dry_dirt'
    then
        -- dry dirt path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dry_dirt' })

    elseif under.name == 'default:dry_dirt_with_dry_grass'
        and under.name ~= 'x_obsidianmese:path_dry_dirt_with_dry_grass'
    then
        -- dry dirt with dry grass path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_dry_dirt_with_dry_grass' })

    elseif under.name == 'default:permafrost'
        and under.name ~= 'x_obsidianmese:path_permafrost'
    then
        -- permafrost path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_permafrost' })

    elseif under.name == 'default:permafrost_with_stones'
        and under.name ~= 'x_obsidianmese:path_permafrost_with_stones'
    then
        -- permafrost with stones path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_permafrost_with_stones' })

    elseif under.name == 'default:permafrost_with_moss'
        and under.name ~= 'x_obsidianmese:path_permafrost_with_moss'
    then
        -- permafrost with moss path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_permafrost_with_moss' })

    elseif under.name == 'default:sand'
        and under.name ~= 'x_obsidianmese:path_sand'
    then
        -- sand path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_sand' })

    elseif under.name == 'default:desert_sand'
        and under.name ~= 'x_obsidianmese:path_desert_sand'
    then
        -- desert sand path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_desert_sand' })

    elseif under.name == 'default:silver_sand'
        and under.name ~= 'x_obsidianmese:path_silver_sand'
    then
        -- silver sand path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_silver_sand' })

    elseif under.name == 'default:snowblock'
        and under.name ~= 'x_obsidianmese:path_snowblock'
    then
        -- snow path
        core.set_node(pt.under, { name = 'x_obsidianmese:path_snowblock' })

    elseif x_obsidianmese.mod.ethereal then
        x_obsidianmese.place_path_ethereal(under, pt.under)

    else
        -- New API approach
        local path_def = x_obsidianmese.path_node_defs[under.name]

        if not path_def then
            return
        end

        if path_def.path_node_name then
            core.set_node(pt.under, { name = path_def.path_node_name })
        end
    end

    -- play sound
    core.sound_play('default_dig_crumbly', {
        pos = pt.under,
        gain = 0.5
    })

    -- add wear
    if not core.settings:get_bool('creative_mode')
        or not core.check_player_privs(placer:get_player_name(), { creative = true })
    then
        itemstack = x_obsidianmese.add_wear(itemstack)
    end

    return itemstack
end

-- axe dig upwards
function x_obsidianmese.dig_up(pos, node, digger)
    if not digger then
        return
    end

    local wielditemname = digger:get_wielded_item():get_name()
    local whitelist = {
        ['x_obsidianmese:axe'] = true,
        ['x_obsidianmese:enchanted_axe_durable'] = true,
        ['x_obsidianmese:enchanted_axe_fast'] = true
    }

    if not whitelist[wielditemname] then
        return
    end

    local np = { x = pos.x, y = pos.y + 1, z = pos.z }
    local nn = core.get_node(np)

    if nn.name == node.name then
        local branches_pos = core.find_nodes_in_area(
            { x = np.x - 1, y = np.y, z = np.z - 1 },
            { x = np.x + 1, y = np.y + 1, z = np.z + 1 },
            node.name
        )

        core.node_dig(np, nn, digger)

        -- add particles only when not too far
        core.add_particlespawner({
            amount = math.random(1, 3),
            time = 0.5,
            minpos = { x = np.x - 0.7, y = np.y, z = np.z - 0.7 },
            maxpos = { x = np.x + 0.7, y = np.y + 0.75, z = np.z + 0.7 },
            minvel = { x = -0.5, y = -4, z = -0.5 },
            maxvel = { x = 0.5, y = -2, z = 0.5 },
            minacc = { x = -0.5, y = -4, z = -0.5 },
            maxacc = { x = 0.5, y = -2, z = 0.5 },
            minexptime = 0.5,
            maxexptime = 1,
            minsize = 0.5,
            maxsize = 2,
            collisiondetection = true,
            node = { name = nn.name }
        })

        if #branches_pos > 0 then
            for i = 1, #branches_pos do
                -- prevent infinite loop when node protected
                if core.is_protected(branches_pos[i], digger:get_player_name()) then
                    break
                end

                x_obsidianmese.dig_up(
                    { x = branches_pos[i].x, y = branches_pos[i].y - 1, z = branches_pos[i].z },
                    node,
                    digger
                )
            end
        end
    end
end

function x_obsidianmese.register_capitator()
    local trees = x_obsidianmese.capitator_tree_names

    for i = 1, #trees do
        local ndef = core.registered_nodes[trees[i]]

        if ndef then
            local prev_after_dig = ndef.after_dig_node
            local func = function(pos, node, metadata, digger)
                x_obsidianmese.dig_up(pos, node, digger)
            end

            if prev_after_dig then
                func = function(pos, node, metadata, digger)
                    prev_after_dig(pos, node, metadata, digger)
                    x_obsidianmese.dig_up(pos, node, digger)
                end
            end

            core.override_item(trees[i], { after_dig_node = func })
        end
    end
end

-- Taken from WorldEdit
-- Determines the axis in which a player is facing, returning an axis ('x', 'y', or 'z') and the sign (1 or -1)
function x_obsidianmese.player_axis(player)
    local dir = player:get_look_dir()
    local x, y, z = math.abs(dir.x), math.abs(dir.y), math.abs(dir.z)
    if x > y then
        if x > z then
            return 'x', dir.x > 0 and 1 or -1
        end
    elseif y > z then
        return 'y', dir.y > 0 and 1 or -1
    end
    return 'z', dir.z > 0 and 1 or -1
end

function x_obsidianmese.hoe_on_use(itemstack, user, pointed_thing)
    local pt = pointed_thing
    -- check if pointing at a node
    if not pt then
        return
    end

    if pt.type ~= 'node' then
        return
    end

    local under = core.get_node(pt.under)
    local above = core.get_node(pt.above)

    -- return if any of the nodes is not registered
    if not core.registered_nodes[under.name] then
        return
    end
    if not core.registered_nodes[above.name] then
        return
    end

    -- check if the node above the pointed thing is air
    if above.name ~= 'air' then
        return
    end

    -- check if pointing at soil
    if core.get_item_group(under.name, 'soil') ~= 1 then
        return
    end

    -- check if (wet) soil defined
    local regN = core.registered_nodes
    if regN[under.name].soil == nil or regN[under.name].soil.wet == nil or regN[under.name].soil.dry == nil then
        return
    end

    -- turn the node into soil and play sound
    core.set_node(pt.under, { name = regN[under.name].soil.dry })
    core.sound_play('default_dig_crumbly', {
        pos = pt.under,
        gain = 0.5,
    })

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
        node = { name = regN[under.name].soil.dry },
        collisiondetection = true,
        object_collision = true,
    })
end

function x_obsidianmese.register_path_node(self, defs)
    if type(defs) ~= 'table' then
        core.log('warning', '[x_obsidianmese] Not registering path nodes due to incorrect node definition!')
        return
    end

    for key, value in pairs(defs) do
        local def = table.copy(value)
        local name = def.mod_origin .. ':path_' .. def.name

        def.path_node_name = name

        if not self.path_node_defs[key] then
            self.path_node_defs[key] = def
        end

        core.register_node(name, {
            description = def.description,
            short_description = def.short_description or def.description,
            drawtype = 'nodebox',
            tiles = def.tiles,
            use_texture_alpha = 'clip',
            is_ground_content = false,
            paramtype = 'light',
            node_box = {
                type = 'fixed',
                fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
            },
            collision_box = {
                type = 'fixed',
                fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
            },
            selection_box = {
                type = 'fixed',
                fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 1 / 16, 1 / 2 },
            },
            drop = def.drop or 'default:dirt',
            groups = { no_silktouch = 1, crumbly = 3, not_in_creative_inventory = 1 },
            sounds = def.sounds or default.node_sound_dirt_defaults(),
            mod_origin = def.mod_origin
        })
    end
end

function x_obsidianmese.update_tool_meta(self, props)
    local _props = props or {}
    local player = _props.player

    if not player then
        return
    end

    local wielditem = player:get_wielded_item()
    local _x_obsidianmese_def = wielditem:get_definition()._x_obsidianmese or {}
    local crit_chance = _x_obsidianmese_def.crit_chance

    local time_from_last_punch = _props.time_from_last_punch
    local tool_capabilities = _props.tool_capabilities
    local wielditem_name = wielditem:get_name()
    local wieldeditem_meta = wielditem:get_meta()
    local slash_time_start = wieldeditem_meta:get_string('x_obsidianmese:slash_time_start')
    local full_punch_interval = tool_capabilities.full_punch_interval
    -- microseconds to seconds
    local current_time = core.get_us_time() / 1000000

    if slash_time_start == '' then
        -- First puch, assume full punch
        slash_time_start = current_time
        current_time = current_time + full_punch_interval
    else
        slash_time_start = tonumber(slash_time_start)
    end

    local tflp = time_from_last_punch or current_time - slash_time_start
    local is_critical_hit = 0
    local is_full_punch = 0

    -- Full-Punch
    if tflp >= full_punch_interval then
        is_full_punch = 1
    end

    -- Crit Hit
    if is_full_punch ~= 0 and crit_chance then
        if math.random(1, crit_chance) == 1 then
            is_critical_hit = 1
        end
    end

    wieldeditem_meta:set_string('x_obsidianmese:slash_time_start', tostring(current_time))

    core.after(0, function(v_wielditem_name, v_player, v_wielditem)
        if v_player and v_wielditem_name == v_player:get_wielded_item():get_name() then
            v_player:set_wielded_item(v_wielditem)
        end
    end, wielditem_name, player, wielditem)

    return {
        is_critical_hit = is_critical_hit ~= 0,
        is_full_punch = is_full_punch ~= 0,
        tflp = tflp
    }
end

local old_calculate_knockback = core.calculate_knockback

function x_obsidianmese.do_raycast(self, props)
    -- Props
    local _props = props or {}
    local pos = _props.pos
    local player = _props.player

    if not player then
        return
    end

    if not player:is_player() then
        return
    end

    local wielditem = player:get_wielded_item()

    if not core.registered_tools[wielditem:get_name()] then
        return
    end

    local item_definition = wielditem:get_definition()
    local _x_obsidianmese_def = item_definition._x_obsidianmese or {}
    local slash_texture = _x_obsidianmese_def.slash_texture

    if not slash_texture then
        return
    end

    local time_from_last_punch = _props.time_from_last_punch
    local tool_capabilities = props.tool_capabilities or wielditem:get_tool_capabilities()
    local dir = props.dir
    -- Anomation constants
    local anim_frames_amount = 6
    local anim_total_duration = 0.4
    local anim_frame_duration = anim_total_duration / anim_frames_amount
    -- Data based on tool meta
    local from_tool_meta = x_obsidianmese:update_tool_meta({
        pos = pos,
        player = player,
        time_from_last_punch = time_from_last_punch,
        tool_capabilities = tool_capabilities
    })

    local protocol_version = core.get_player_information(player:get_player_name()).protocol_version
    local is_new_particle = protocol_version >= (x_obsidianmese.protocol_versions['5.9.0'] or 0)
    local slash_glow = _x_obsidianmese_def.slash_glow
    local slash_size = _x_obsidianmese_def.slash_size
    local slash_scale = _x_obsidianmese_def.slash_scale
    local slash_sound_name = _x_obsidianmese_def.slash_sound_name
    local crit_chance = _x_obsidianmese_def.crit_chance

    if slash_texture or crit_chance then
        local is_critical_hit = from_tool_meta.is_critical_hit
        local is_full_punch = from_tool_meta.is_full_punch

        if is_full_punch then
            local player_pos = player:get_pos()
            local player_props = player:get_properties()
            local eye_height = player_props.eye_height or 1.625
            local player_pos_with_eye_height = vector.new(player_pos.x, player_pos.y + eye_height, player_pos.z)
            local look_dir = player:get_look_dir()
            local distance = vector.distance(player_pos_with_eye_height, pos) + 0.5
            local new_pos = vector.add(player_pos_with_eye_height, vector.multiply(look_dir, distance))

            local ray = core.raycast(player_pos_with_eye_height, new_pos, true, false, nil)
            local particle_def = {
                velocity = vector.new(),
                acceleration = vector.new(),
                expirationtime = anim_total_duration - anim_frame_duration,
                collisiondetection = false,
                collision_removal = false,
                object_collision = false,
                vertical = false,
                animation = {
                    type = 'vertical_frames',
                    aspect_w = 32,
                    aspect_h = 32,
                    length = anim_total_duration
                },
                glow = slash_glow or 2
            }

            local rand_scale = math.random(20, 40)

            if is_new_particle then
                -- new particle def > 5.9.0
                particle_def.texture = {
                    name = 'x_obsidianmese_default_slash.png',
                    alpha_tween = { math.random(50, 100) / 100, math.random(0, 30) / 100 },
                    scale = slash_scale or { x = rand_scale, y = rand_scale },
                    blend = 'alpha'
                }
            else
                -- old particle def
                particle_def.texture = 'x_obsidianmese_default_slash.png'
                particle_def.size = slash_size or rand_scale
            end

            -- custom texture (if bool == true then keep default texture)
            if type(slash_texture) ~= 'boolean' then
                if is_new_particle then
                    -- new particle def > 5.9.0
                    particle_def.texture.name = slash_texture
                else
                    -- old particle def
                    particle_def.texture = slash_texture
                end
            end

            -- Crit Hit appearance and sound
            if is_critical_hit then
                if is_new_particle then
                    -- new particle def > 5.9.0
                    particle_def.texture.name = particle_def.texture.name .. '^[colorize:#FF0000:127'
                else
                    -- old particle def
                    particle_def.texture = particle_def.texture .. '^[colorize:#FF0000:127'
                end

                slash_sound_name = 'x_obsidianmese_sword_crit'
            end

            --
            -- Raycast
            --
            for pt in ray do
                if pt.type == 'node' then
                    --
                    -- Node
                    --

                    -- Swing Trail
                    particle_def.pos = vector.add(pt.intersection_point, vector.divide(pt.intersection_normal, 3))

                elseif pt.type == 'object'
                    and not pt.ref:is_player()
                    and pt.ref:get_luaentity()
                then
                    --
                    -- Lua Entity
                    --

                    -- Swing Trail
                    particle_def.pos = pt.intersection_point

                    -- Crit Hit
                    if is_critical_hit then
                        local luaentity = pt.ref:get_luaentity()
                        local target_armor_groups = pt.ref:get_armor_groups()
                        local damage = 0

                        -- Prevent infinite loop since we call `punch` here what will trigger `on_punch` again
                        luaentity._x_obsidianmese_skip_do_raycast = true

                        for group, base_damage in pairs(tool_capabilities.damage_groups) do
                            damage = damage
                                + base_damage
                                * limit(from_tool_meta.tflp / tool_capabilities.full_punch_interval, 0.0, 1.0)
                                * ((target_armor_groups[group] or 0) + get_3d_armor_armor(pt.ref)) / 100.0
                        end

                        -- knockback will be zero for lua entities, so `player` and `hitter` are switched
                        local knockback = old_calculate_knockback(
                            player,
                            pt.ref,
                            from_tool_meta.tflp,
                            {
                                full_punch_interval = tool_capabilities.full_punch_interval,
                                damage_groups = { fleshy = damage * 2 }
                            },
                            dir,
                            distance,
                            damage * 2
                        )

                        -- Second (crit) punch
                        pt.ref:punch(
                            player,
                            from_tool_meta.tflp,
                            {
                                full_punch_interval = tool_capabilities.full_punch_interval,
                                damage_groups = { fleshy = damage, knockback = knockback }
                            },
                            dir
                        )

                        if dir then
                            pt.ref:add_velocity(vector.multiply(dir, knockback))
                        end
                    end

                elseif pt.type == 'object'
                    and pt.ref:is_player()
                    and pt.ref:get_player_name() ~= player:get_player_name()
                then
                    --
                    -- Player Object
                    --

                    -- Swing Trail
                    particle_def.pos = pt.intersection_point

                    -- Crit Hit
                    if is_critical_hit then
                        local player_meta = player:get_meta()
                        local target_armor_groups = pt.ref:get_armor_groups()
                        local damage = 0

                        -- Prevent infinite loop since we call `punch` here what will trigger `on_punch` again
                        player_meta:set_int('x_obsidianmese_skip_do_raycast', 1)

                        for group, base_damage in pairs(tool_capabilities.damage_groups) do
                            damage = damage
                                + base_damage
                                * limit(from_tool_meta.tflp / tool_capabilities.full_punch_interval, 0.0, 1.0)
                                * ((target_armor_groups[group] or 0) + get_3d_armor_armor(pt.ref)) / 100.0
                        end

                        local knockback = old_calculate_knockback(
                            pt.ref,
                            player,
                            from_tool_meta.tflp,
                            {
                                full_punch_interval = tool_capabilities.full_punch_interval,
                                damage_groups = { fleshy = damage * 2 }
                            },
                            dir,
                            distance,
                            damage * 2
                        )

                        -- Second (crit) punch
                        pt.ref:punch(
                            player,
                            from_tool_meta.tflp,
                            {
                                full_punch_interval = tool_capabilities.full_punch_interval,
                                damage_groups = { fleshy = damage, knockback = knockback }
                            },
                            dir
                        )

                        pt.ref:add_velocity(vector.multiply(dir, knockback))
                    end
                end

                -- Add swing trail visual effect and sound
                if particle_def.pos and self.settings.x_obsidianmese_swing_trail_enabled then
                    core.add_particle(particle_def)
                    local rand_pitch = math.random(5, 15) / 10

                    if is_critical_hit then
                        rand_pitch = math.random(7, 10) / 10
                    end

                    core.sound_play({
                        name = slash_sound_name or 'x_obsidianmese_sword_swing',
                        gain = 0.4,
                    }, {
                        pitch = rand_pitch,
                        object = player,
                        max_hear_distance = 32
                    }, true)
                    break
                end
            end
        end
    end
end

function x_obsidianmese.get_particlespwaner_def(self, def_name, props)
    local def = {}
    local _props = props or {}
    local pos = _props.pos
    local attached = _props.attached
    local origin_attached = _props.origin_attached
    local direction_attached = _props.direction_attached
    local is_crit = _props.is_crit

    if def_name == 'projectile_explode' then
        def = {
            amount = 50,
            time = 0.1,
            exptime = 1,
            size = {
                min = 3,
                max = 5,
            },
            pos = pos,
            texture = {
                name = is_crit and 'x_obsidianmese_sword_projectile_smoke_crit.png' or 'x_obsidianmese_sword_projectile_smoke.png',
                alpha_tween = {
                    1, 0,
                    style = 'fwd',
                    reps = 1
                },
                scale_tween = {
                    1, 0.25,
                    style = 'fwd',
                    reps = 1
                }
            },
            radius = { min = 0.75, max = 1 },
            attract = {
                kind = 'point',
                strength = -1,
                origin = pos,
            },
            glow = 8
        }
    elseif def_name == 'projectile_trail' then
        def = {
            amount = 10,
            time = 0.1,
            exptime = 2,
            size = {
                min = 0.5,
                max = 1,
            },
            texture = {
                name = 'x_obsidianmese_obsidian.png',
                alpha_tween = {
                    1, 0,
                    style = 'fwd',
                    reps = 1
                },
                scale_tween = {
                    1, 0.25,
                    style = 'fwd',
                    reps = 1
                }
            },
            radius = { min = 0.2, max = 0.3 },
            attract = {
                kind = 'line',
                strength = 1,
                origin_attached = origin_attached,
                direction_attached = direction_attached
            },
            glow = 8,
            attached = attached
        }
    end

    return def
end

function x_obsidianmese.register_on_press(self, callback)
    table.insert(self.controls.registered_on_press, callback)
end

function x_obsidianmese.register_on_hold(self, callback)
    table.insert(self.controls.registered_on_hold, callback)
end

function x_obsidianmese.register_on_release(self, callback)
    table.insert(self.controls.registered_on_release, callback)
end

function x_obsidianmese.remove_projectile(self, player, props)
    local _props = props or {}
    local fade_out = _props.fade_out
    local player_name = player:get_player_name()

    if not self.sword_projectile[player_name].charge_ent_obj then
        return
    end

    local obj_pos = self.sword_projectile[player_name].charge_ent_obj:get_pos()

    if not obj_pos then
        return
    end

    if fade_out then
        -- Fade out entity - this will also remove the entity
        local luaentity = self.sword_projectile[player_name].charge_ent_obj:get_luaentity()

        if luaentity then
            luaentity._fade_out = true
        end
    else
        self.sword_projectile[player_name].charge_ent_obj:remove()
    end

    self.sword_projectile[player_name].charge_ent_obj = nil

    -- Additional cleanup if we have a stuck projectile on us
    local player_pos = player:get_pos()
    local player_props = player:get_properties()
    local eye_height = player_props.eye_height or 1.625
    local look_dir = player:get_look_dir()
    local player_pos_offset = vector.add(
        vector.new(player_pos.x, player_pos.y + eye_height, player_pos.z),
        look_dir
    )
    local distance = vector.distance(
        obj_pos,
        vector.add(player_pos_offset, 0.5)
    )

    for obj in core.objects_inside_radius(player_pos_offset, distance) do
        if
        obj ~= player
        and not obj:is_player()
        and (
            obj:get_luaentity()
            and obj:get_luaentity().name ~= '__builtin:item'
            and obj:get_luaentity()._user_name == player_name
        )
        then
            if fade_out then
                -- Fade out entity - this will also remove the entity
                local luaentity = obj:get_luaentity()
                luaentity._fade_out = true
            else
                obj:remove()
            end
        end
    end
end

function x_obsidianmese.remove_projectile_sounds(self, player, props)
    local _props = props or {}
    local player_name = player:get_player_name()

    -- Fade out sounds
    if _props.charge_sound and self.sword_projectile[player_name].charge_sound_handle then
        -- >= 5.8.0, below this the fade sounds take longer to fade and it results in overlapping sounds
        if core.get_player_information(player_name).protocol_version >= (self.protocol_versions['5.8.0'] or 0) and _props.charge_sound_fade then
            core.sound_fade(self.sword_projectile[player_name].charge_sound_handle, 0.5, 0)
        else
            core.sound_stop(self.sword_projectile[player_name].charge_sound_handle)
        end

        self.sword_projectile[player_name].charge_sound_handle = nil
    end

    if  _props.charged_sound and self.sword_projectile[player_name].charged_sound_handle then
        -- >= 5.8.0, below this the fade sounds take longer to fade and it results in overlapping sounds
        if core.get_player_information(player_name).protocol_version >= (self.protocol_versions['5.8.0'] or 0) and _props.charged_sound_fade then
            core.sound_fade(self.sword_projectile[player_name].charged_sound_handle, 0.5, 0)
        else
            core.sound_stop(self.sword_projectile[player_name].charged_sound_handle)
        end

        self.sword_projectile[player_name].charged_sound_handle = nil
    end
end

function x_obsidianmese.itemstack_equals(self, a, b)
    local name = a:get_name() == b:get_name()
    local count = a:get_count() == b:get_count()
    local wear = a:get_wear() == b:get_wear()
    local meta = a:get_meta():equals(b:get_meta())

    return name and count and wear and meta
end

function x_obsidianmese.set_sword_wielded_item(self, player)
    if not player then
        return
    end

    local player_name = player:get_player_name()
    local stored_wield_index = self.sword_projectile[player_name].wield_index
    local stored_wielditem = self.sword_projectile[player_name].wielditem
    local stored_wielditem_orig = self.sword_projectile[player_name].wielditem_orig
    local inv = player:get_inventory()
    local listname = player:get_wield_list()
    -- Ensure stored_wield_index is valid before using it
	if stored_wield_index == nil then
	    minetest.log("error", "[x_obsidianmese] stored_wield_index is nil, cannot get_stack")
	    return  -- stop here to prevent crash
	end
	
	-- Make sure listname is valid too
	if listname == nil then
 	   minetest.log("error", "[x_obsidianmese] listname is nil, cannot get_stack")
	    return
	end

	-- Now safe to get the inventory stack
	local inv_stack = inv:get_stack(listname, stored_wield_index)

	-- Optional: check the stack is not empty before continuing
	if inv_stack:is_empty() then
  	  minetest.log("warning", "[x_obsidianmese] inventory slot "..stored_wield_index.." is empty")
 	   return
	end


    if not stored_wield_index or not stored_wielditem then
        return
    end

    -- Fake loaded sword meta, the one in `stored_wielditem_orig` are for unloaded sword
    local stack_copy = ItemStack(stored_wielditem_orig)
    -- from 5.9.0
    stack_copy:get_meta():set_float('range', 0)

    if x_obsidianmese.sword_projectile[player_name].wielditem:get_count() == 0 then
        -- Remove item (no wear left)
        local player_inv = player:get_inventory()
        local wield_list = player:get_wield_list()

        player_inv:set_stack(
            wield_list,
            self.sword_projectile[player_name].wield_index,
            ItemStack()
        )
    elseif x_obsidianmese:itemstack_equals(inv_stack, stack_copy) or x_obsidianmese:itemstack_equals(inv_stack, stored_wielditem_orig) then
        local player_inv = player:get_inventory()
        local wield_list = player:get_wield_list()

        player_inv:set_stack(
            wield_list,
            self.sword_projectile[player_name].wield_index,
            self.sword_projectile[player_name].wielditem
        )
    end
end

function x_obsidianmese.cancel_charging(self, player, props)
    local player_name = player:get_player_name()

    if not self.sword_projectile[player_name] or (self.sword_projectile[player_name] and not self.sword_projectile[player_name].wielditem) then
        return
    end

    local _props = props or {}
    local fade_out = _props.fade_out
    local ignore_after = _props.ignore_after
    local wielditem_def = self.sword_projectile[player_name].wielditem:get_definition()
    local wielditem_meta = self.sword_projectile[player_name].wielditem:get_meta()

    self:remove_projectile(player, { fade_out = fade_out })
    self:remove_projectile_sounds(player, { charge_sound = true, charged_sound = true, charge_sound_fade = true, charged_sound_fade = true })
    -- >= 5.9.0
    wielditem_meta:set_float('range', wielditem_def.range or 4.0)

    if ignore_after then
        self:set_sword_wielded_item(player)
    else
        core.after(0, function(v_player)
            x_obsidianmese:set_sword_wielded_item(v_player)

            if not x_obsidianmese.sword_projectile[player_name] then
                return
            end

            if x_obsidianmese.sword_projectile[player_name].charging then
                -- we are charging
                x_obsidianmese.sword_projectile[player_name].wield_index = nil
                x_obsidianmese.sword_projectile[player_name].wielditem = nil
                x_obsidianmese.sword_projectile[player_name].wielditem_orig = nil
                x_obsidianmese.sword_projectile[player_name].charging = false
                x_obsidianmese.sword_projectile[player_name].charged = false
                x_obsidianmese.sword_projectile[player_name].charge_time = 0
                x_obsidianmese.sword_projectile[player_name].charge_time_start = core.get_us_time() / 1e6

            elseif x_obsidianmese.sword_projectile[player_name].charged then
                -- we shoot the shot, restart data
                self.sword_projectile[player_name] = {}
            end
        end, player)
    end
end
