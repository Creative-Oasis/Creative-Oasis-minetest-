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

local mod_start_time = core.get_us_time()
local path = core.get_modpath('x_obsidianmese')

dofile(path .. '/api.lua')
dofile(path .. '/entities.lua')
dofile(path .. '/tools.lua')
dofile(path .. '/nodes.lua')

if x_obsidianmese.settings.x_obsidianmese_chest then
    dofile(path .. '/obsidianmese_chest.lua')
end

dofile(path .. '/crafting.lua')
dofile(path .. '/functions.lua')

if x_obsidianmese.mod.ethereal then
    dofile(path .. '/mods/ethereal/init.lua')
end

local mod_end_time = (core.get_us_time() - mod_start_time) / 1000000

print('[Mod] x_obsidianmese loaded.. [' .. mod_end_time .. 's]')
