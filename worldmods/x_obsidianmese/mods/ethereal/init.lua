-- X Obsidianmese - Ethereal support
-- by SaKeL

local mod_start_time = core.get_us_time()
local path = core.get_modpath('x_obsidianmese')

dofile(path .. '/mods/ethereal/utils.lua')
dofile(path .. '/mods/ethereal/nodes.lua')

local mod_end_time = (core.get_us_time() - mod_start_time) / 1000000

print('[Mod] x_obsidianmese - Ethereal support loaded.. [' .. mod_end_time .. 's]')
