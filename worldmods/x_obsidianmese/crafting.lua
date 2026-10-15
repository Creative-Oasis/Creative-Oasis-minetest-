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
-- Craft Items
--

-- mese apple
core.register_craftitem('x_obsidianmese:mese_apple', {
    description = 'Mese apple (restores full health)',
    short_description = 'Mese apple',
    inventory_image = 'x_obsidianmese_apple.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    on_use = function(itemstack, user, pointed_thing)
        if not user then
            return
        end

        core.sound_play('x_obsidianmese_apple_eat', {
            pos = user:get_pos(),
            max_hear_distance = 32,
            gain = 0.5,
        })

        user:set_hp(20)
        itemstack:take_item()
        return itemstack
    end
})

--
-- Crafting
-- no craft for engraved sword, that is rare item obtained only by drops
--
core.register_craft({
    output = 'x_obsidianmese:chest',
    recipe = {
        { 'default:obsidian', 'default:obsidian', 'default:obsidian' },
        { 'default:obsidian', 'default:mese', 'default:obsidian' },
        { 'default:obsidian', 'default:obsidian', 'default:obsidian' }
    }
})

core.register_craft({
    output = 'x_obsidianmese:sword',
    recipe = {
        { '', 'default:mese_crystal', '' },
        { 'default:obsidian_shard', 'default:mese_crystal', 'default:obsidian_shard' },
        { '', 'default:obsidian_shard', '' },
    }
})

if x_obsidianmese.settings.x_obsidianmese_sword_engraved_recipe then
    core.register_craft({
        output = 'x_obsidianmese:sword_engraved',
        recipe = {
            { '', 'default:diamond', '' },
            { 'default:obsidian_shard', 'default:diamond', 'default:obsidian_shard' },
            { '', 'default:obsidian_shard', '' },
        }
    })
end

core.register_craft({
    output = 'x_obsidianmese:pick',
    recipe = {
        { 'default:mese_crystal', 'default:mese_crystal', 'default:mese_crystal' },
        { '', 'default:obsidian_shard', '' },
        { '', 'default:obsidian_shard', '' },
    }
})

core.register_craft({
    output = 'x_obsidianmese:shovel',
    recipe = {
        { 'default:mese_crystal' },
        { 'default:obsidian_shard' },
        { 'default:obsidian_shard' },
    }
})

core.register_craft({
    output = 'x_obsidianmese:axe',
    recipe = {
        { 'default:mese_crystal', 'default:mese_crystal' },
        { 'default:mese_crystal', 'default:obsidian_shard' },
        { '', 'default:obsidian_shard' },
    }
})

core.register_craft({
    output = 'x_obsidianmese:hoe',
    recipe = {
        { 'default:mese_crystal', 'default:mese_crystal', '' },
        { '', 'default:obsidian_shard', '' },
        { '', 'default:obsidian_shard', '' },
    }
})

core.register_craft({
    output = 'x_obsidianmese:pick_engraved',
    recipe = {
        { 'default:diamond', 'default:diamond', 'default:diamond' },
        { '', 'default:obsidian_shard', '' },
        { '', 'default:obsidian_shard', '' },
    }
})

core.register_craft({
    output = 'x_obsidianmese:mese_apple 4',
    recipe = {
        { '', 'default:apple', '' },
        { 'default:apple', 'default:mese', 'default:apple' },
        { '', 'default:apple', '' },
    }
})
