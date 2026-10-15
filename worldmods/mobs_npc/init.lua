
-- translation and get mod path
local S = core.get_translator("mobs_npc")
local path = core.get_modpath(core.get_current_modname()) .. "/"

-- Global
mobs_npc = {}

-- Check for custom mob spawn file

local input = io.open(path .. "spawn.lua", "r")

if input then
	mobs.custom_spawn_npc = true
	input:close()
	input = nil
end

dofile(path .. "functions.lua") -- useful functions
dofile(path .. "npc.lua") -- TenPlus1
dofile(path .. "trader.lua")
dofile(path .. "igor.lua")

-- Load custom spawning if found

if mobs.custom_spawn_npc then
	dofile(path .. "spawn.lua")
end

-- Lucky Blocks

if core.get_modpath("lucky_block") then
	dofile(path .. "/lucky_block.lua")
end

-- Ensure mobs_npc exists
-- spawn.lua


mobs_npc = mobs_npc or {}

-- Utility function: remove nodes that do not exist
local function filter_existing_nodes(nodes)
	local existing = {}
	for _, name in ipairs(nodes) do
		if minetest.registered_nodes[name] then
			table.insert(existing, name)
		end
	end
	return existing
end


-- List of NPCs
local npc_list = {
	"mobs_npc:igor",
	"mobs_npc:npc",
	"mobs_npc:trader",
}


local spawn_nodes = filter_existing_nodes({
	"default:bamboo_dirt",
	"default:clay_soil",
	"default:cobble",
	"default:desert_cobble",
	"default:desert_dirt",
	"default:desert_dirt_with_grass",
	"default:desert_sand",
	"default:desert_stone",
	"default:desert_stone_block",
	"default:desert_stonebrick",
	"default:dirt",
	"default:dirt_with_dry_grass",
	"default:dirt_with_grass",
	"default:dirt_with_grass_footsteps",
	"default:dirt_with_snow",
	"default:dry_dirt",
	"default:dry_dirt_with_grass",
	"default:grassydirt",
	"default:jungle_dirt",
	"default:jungle_dirt_with_grass",
	"default:sand",
	"default:savanna_dirt",
	"default:savanna_dirt_with_grass",
	"default:silver_sand",
	"default:snow",
	"default:stone",
	"default:stone_block",
	"default:stonebrick",
	"ethereal:crystal_dirt",
	"ethereal:frost_dirt",
	"ethereal:grove_dirt",
	"ethereal:gray_dirt",
	"ethereal:healing_dirt",
	"ethereal:mushroom_dirt",
	"ethereal:prairie_dirt",
	"ethereal:swamp_dirt",
	"ethereal:grassydirt",
	"ethereal:sandy",
})

-- Spawn each NPC on the filtered nodes
for _, mob_name in ipairs(npc_list) do
	mobs:spawn({
		name = mob_name,
		nodes = spawn_nodes,        -- only solid ground nodes
		neighbors = {"air"},
		min_light = 2,
		max_light = 15,
		interval = 60,
		chance = 4000,
		active_object_count = 2,
		min_height = -50,
		max_height = 4000,
	})
end

print ("[MOD] Mobs Redo NPC's loaded")
