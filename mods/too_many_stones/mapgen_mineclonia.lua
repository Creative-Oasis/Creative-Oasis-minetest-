-- Mapgen for Mineclonia
-- Handles duplicate block aliases and ore registration using Mineclonia's node names
-- Uses MCL-style ore parameters for proper blob spawning

------------------------------------------------------------------------
-- ALIASES: Redirect Mineclonia duplicates to TMS equivalents
------------------------------------------------------------------------

minetest.register_alias("mcl_core:diorite", "too_many_stones:diorite")
minetest.register_alias("mcl_core:andesite", "too_many_stones:andesite")
minetest.register_alias("mcl_core:granite", "too_many_stones:granite_pink")
minetest.register_alias("mcl_deepslate:tuff", "too_many_stones:tuff_grey")

------------------------------------------------------------------------
-- ORE REGISTRATION SYSTEM
-- Climate-based ore queuing system kindly provided by EmptyStar
------------------------------------------------------------------------

local oreq = {}
local function register_ore_by_climate(ore)
	table.insert(oreq, ore)
end

minetest.register_on_mods_loaded(function()
	for _, ore in ipairs(oreq) do
		ore.biomes = ore.biomes or {}

		local checksum = 0
		if not ore.heat_min then
			ore.heat_min = -100
			checksum = checksum + 1
		end

		if not ore.heat_max then
			ore.heat_max = 200
			checksum = checksum + 1
		end

		if not ore.humidity_min then
			ore.humidity_min = -100
			checksum = checksum + 1
		end

		if not ore.humidity_max then
			ore.humidity_max = 200
			checksum = checksum + 1
		end

		if checksum ~= 4 then
			checksum = #ore.biomes
			for name, biome in pairs(minetest.registered_biomes) do
				checksum = checksum + 1
				local heat = biome.heat_point or 50
				local humidity = biome.humidity_point or 50

				if (
					heat >= ore.heat_min and
					heat <= ore.heat_max and
					humidity >= ore.humidity_min and
					humidity <= ore.humidity_max
				) then
					table.insert(ore.biomes, name)
				end
			end
		else
			checksum = #ore.biomes + 1
		end

		ore.biomes = #ore.biomes > 0 and #ore.biomes < checksum and ore.biomes or nil

		local sources = ore.wherein
		for i = 1, #sources do
			ore.wherein = sources[i]
			minetest.register_ore(ore)
		end
	end
end)

-- Generate unique seeds for each stone
local _seed = 12345
local function seed()
	_seed = _seed + 97
	return _seed
end

------------------------------------------------------------------------
-- SCARCITY TIERS (MCL-style)
-- MCL uses 15*15*15 (3,375) for diorite/andesite/granite
-- TMS has ~70 stones, so we use slightly higher values to avoid overwhelming
------------------------------------------------------------------------

local COMMON    = 18 * 18 * 18   -- 5,832 - common building stones
local MEDIUM    = 24 * 24 * 24   -- 13,824 - most TMS stones
local RARE      = 32 * 32 * 32   -- 32,768 - less common minerals
local VERY_RARE = 48 * 48 * 48   -- 110,592 - precious stones

-- Nether/End have less volume and fewer biomes, so stones need to be more common
local NETHER_COMMON = 12 * 12 * 12  -- 1,728 - common nether stones
local NETHER_MEDIUM = 16 * 16 * 16  -- 4,096 - most nether stones
local NETHER_RARE   = 24 * 24 * 24  -- 13,824 - rare nether finds

-- MCL-style noise params
local function mcl_noise(seed_val)
	return {
		offset  = 0,
		scale   = 1,
		spread  = {x = 250, y = 250, z = 250},
		seed    = seed_val,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
end

------------------------------------------------------------------------
-- WHEREIN TARGETS
------------------------------------------------------------------------

-- Overworld stones
local mcl_stone = {"mcl_core:stone"}
local mcl_stonelike = {"mcl_core:stone", "too_many_stones:diorite", "too_many_stones:andesite", "too_many_stones:granite_pink"}
local mcl_deepslate = {"mcl_deepslate:deepslate"}
local mcl_deep_all = {"mcl_deepslate:deepslate", "too_many_stones:tuff_grey"}

-- Nether stones
local mcl_netherrack = {"mcl_nether:netherrack"}
local mcl_blackstone = {"mcl_blackstone:blackstone"}
local mcl_basalt = {"mcl_blackstone:basalt"}
local mcl_nether_all = {"mcl_nether:netherrack", "mcl_blackstone:blackstone", "mcl_blackstone:basalt"}

-- End stone
local mcl_end_stone = {"mcl_end:end_stone"}

-- Sediments
local mcl_dirt = {"mcl_core:dirt"}
local mcl_gravel = {"mcl_core:gravel"}
local mcl_sand = {"mcl_core:sand"}

------------------------------------------------------------------------
-- SPECIAL MECHANICS
------------------------------------------------------------------------

-- Replace some naturally generated lapis lazuli with pyrite
minetest.register_lbm({
	label = "Replace a fraction of lapis lazuli with pyrite",
	name = "too_many_stones:lapis2pyrite",
	nodenames = {"too_many_stones:lapis_lazuli"},
	run_at_every_load = true,
	action = function(pos, node)
		local coordinate_sum = pos.x ^ 2 + pos.y * 2 + pos.z
		local newnode = "too_many_stones:lapis_lazuli"
		if coordinate_sum % 17 == 4 and node.param2 == 1 then
			newnode = "too_many_stones:pyrite"
		end
		minetest.set_node(pos, {name = newnode, param2 = 0})
	end,
})

------------------------------------------------------------------------
-- ORE REGISTRATIONS
-- Note: Diorite, Andesite, Pink Granite, and Grey Tuff are SKIPPED
-- because they are aliased from Mineclonia's versions
------------------------------------------------------------------------

-- Aegirine (cold, dry)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:aegirine",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 50,
	humidity_min    = 0,
	humidity_max    = 50,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:aegirine_budding",
	wherein         = mcl_stonelike,
	clust_scarcity  = RARE,
	clust_num_ores  = 12,
	clust_size      = 3,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Agates (hot, humid - volcanic cavities)
local agates = {"agate_blue", "agate_gray", "agate_green", "agate_moss", "agate_orange", "agate_purple", "agate_red"}
for _, agate in ipairs(agates) do
	register_ore_by_climate({
		ore_type        = "blob",
		ore             = "too_many_stones:" .. agate,
		wherein         = mcl_stonelike,
		clust_scarcity  = MEDIUM,
		clust_num_ores  = 20,
		clust_size      = 4,
		heat_min        = 60,
		heat_max        = 100,
		humidity_min    = 60,
		humidity_max    = 100,
		y_max           = 31000,
		y_min           = -31000,
		noise_params    = mcl_noise(seed()),
	})
end

-- Amazonite (hot, humid - granite pegmatites)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:amazonite",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Amber (in sediments, not rock!)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:amber",
	wherein         = mcl_gravel,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Amethyst (universal, volcanic cavities) - NOT ALIASED, has transparency
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:amethyst",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Ammolite (deep, hot humid - fossils)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:ammolite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 50,
	heat_max        = 100,
	humidity_min    = 50,
	humidity_max    = 100,
	y_max           = -5,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- SKIP: Andesite (aliased)

-- Basalt (hot, dry - volcanic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:basalt",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Columnar Basalt
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:basalt_columnar",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Black Moonstone (universal)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:black_moonstone",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Calcites - NOT ALIASED, has transparency
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:calcite",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:calcite_grey",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 30,
	humidity_min    = 50,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:calcite_orange",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 70,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 50,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Carnotite (deep, dry - uranium deposits)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:carnotite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 12,
	clust_size      = 3,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = -300,
	y_min           = -1000,
	noise_params    = mcl_noise(seed()),
})

-- Celestine (humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:celestine",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Chalcanthite (hot, dry - volcanic/hydrothermal) - ALSO IN NETHER
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:chalcanthite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 80,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = -10,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Chrysoprase
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:chrysoprase",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -1000,
	noise_params    = mcl_noise(seed()),
})

-- Citrine (hot - heat-altered amethyst)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:citrine",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Covellite (humid - hydrothermal)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:covellite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Crocoite (hot - volcanic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:crocoite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- SKIP: Diorite (aliased)

-- Erythrite (dry - cobalt deposits)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:erythrite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Eudialite (dry - alkaline volcanic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:eudialite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Fluorite (dry - hydrothermal)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:fluorite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Gabbro (hot - plutonic basalt equivalent)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:gabbro",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 40,
	clust_size      = 6,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Galena (universal, deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:galena",
	ore_param2      = 1,
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Geyserite (hot, humid - hot springs)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:geyserite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 40,
	heat_max        = 100,
	humidity_min    = 70,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -200,
	noise_params    = mcl_noise(seed()),
})

-- Gneiss (metamorphic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:gneiss",
	wherein         = mcl_deep_all,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 50,
	heat_max        = 90,
	humidity_min    = 40,
	humidity_max    = 80,
	y_max           = 31000,
	y_min           = -800,
	noise_params    = mcl_noise(seed()),
})

-- Granites (various colors) - SKIP Pink Granite (aliased)
local granites = {
	{name = "granite_black", heat_min = 0, heat_max = 40, humidity_min = 0, humidity_max = 100},
	{name = "granite_blue", heat_min = 0, heat_max = 40, humidity_min = 60, humidity_max = 100, y_max = 30},
	{name = "granite_gray", heat_min = 0, heat_max = 100, humidity_min = 0, humidity_max = 100},
	{name = "granite_green", heat_min = 0, heat_max = 100, humidity_min = 60, humidity_max = 100, y_min = -60},
	-- SKIP granite_pink (aliased)
	{name = "granite_red", heat_min = 60, heat_max = 100, humidity_min = 0, humidity_max = 100, y_min = -500},
	{name = "granite_white", heat_min = 0, heat_max = 100, humidity_min = 0, humidity_max = 100, y_min = -300},
	{name = "granite_yellow", heat_min = 0, heat_max = 40, humidity_min = 0, humidity_max = 100, y_max = 10},
}

for _, g in ipairs(granites) do
	register_ore_by_climate({
		ore_type        = "blob",
		ore             = "too_many_stones:" .. g.name,
		wherein         = mcl_stonelike,
		clust_scarcity  = COMMON,
		clust_num_ores  = 33,
		clust_size      = 5,
		heat_min        = g.heat_min,
		heat_max        = g.heat_max,
		humidity_min    = g.humidity_min,
		humidity_max    = g.humidity_max,
		y_max           = g.y_max or 31000,
		y_min           = g.y_min or -31000,
		noise_params    = mcl_noise(seed()),
	})
end

-- Heliodor (deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:heliodor",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = -30,
	y_min           = -500,
	noise_params    = mcl_noise(seed()),
})

-- Howlite (cold)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:howlite",
	wherein         = {"mcl_core:stone", "too_many_stones:diorite"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 1000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Ilvaite (cold)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:ilvaite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -100,
	noise_params    = mcl_noise(seed()),
})

-- Jade (universal)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:jade",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Jaspers
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:jasper_red",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 20,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:picture_jasper",
	wherein         = mcl_deep_all,
	clust_scarcity  = VERY_RARE,
	clust_num_ores  = 8,
	clust_size      = 2,
	y_max           = -1000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Kyanite (cold, humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:kyanite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 300,
	y_min           = -60,
	noise_params    = mcl_noise(seed()),
})

-- Lapis Lazuli
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:lapis_lazuli",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	ore_param2      = 1,
	noise_params    = mcl_noise(seed()),
})

-- Lepidolite (cold, humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:lepidolite",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 30,
	humidity_min    = 40,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Limestones
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:limestone_blue",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 300,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:limestone_white",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -300,
	noise_params    = mcl_noise(seed()),
})

-- Marble (hot, humid - metamorphic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:marble",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -500,
	noise_params    = mcl_noise(seed()),
})

-- Moonstone (hot, humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:moonstone",
	wherein         = {"mcl_core:stone", "too_many_stones:diorite"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Morion Quartz (cold, deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:morion_quartz",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = -300,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Mudstone (humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:mudstone",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -100,
	noise_params    = mcl_noise(seed()),
})

-- Opals (deep)
local opals = {"opal", "black_opal", "fire_opal"}
for _, opal in ipairs(opals) do
	register_ore_by_climate({
		ore_type        = "blob",
		ore             = "too_many_stones:" .. opal,
		wherein         = mcl_deep_all,
		clust_scarcity  = VERY_RARE,
		clust_num_ores  = 8,
		clust_size      = 2,
		y_max           = -1000,
		y_min           = -31000,
		noise_params    = mcl_noise(seed()),
	})
end

-- Prasiolite (dry)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:prasiolite",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 50,
	y_min           = -1000,
	noise_params    = mcl_noise(seed()),
})

-- Pumice (dry - volcanic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:pumice",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Pyrite (deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:pyrite",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = -40,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Quartz (deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:quartz",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = -300,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Rhodonite (hot, humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:rhodonite",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Rose Quartz (cold, deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:rose_quartz",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = -300,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Scoria (dry - volcanic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:scoria",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -60,
	noise_params    = mcl_noise(seed()),
})

-- Serpentine (humid - metamorphic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:serpentine",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Shale (humid)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:shale",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 40,
	humidity_max    = 100,
	y_max           = 300,
	y_min           = -60,
	noise_params    = mcl_noise(seed()),
})

-- Slate (universal, shallow)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:slate",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 300,
	y_min           = -60,
	noise_params    = mcl_noise(seed()),
})

-- Smokey Quartz (hot, dry)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:smokey_quartz",
	wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 40,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Soapstone (cold, deep - metamorphic)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:soapstone",
	wherein         = mcl_deep_all,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 0,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Sodalite (cold)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:sodalite",
	wherein         = {"mcl_core:stone", "too_many_stones:diorite"},
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 40,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Sugilite (deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:sugilite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 30,
	y_min           = -2000,
	noise_params    = mcl_noise(seed()),
})

-- Tourmalines (cold - granite pegmatites)
local tourmalines = {"tourmaline_green", "tourmaline_paraiba", "tourmaline_pink"}
for _, t in ipairs(tourmalines) do
	register_ore_by_climate({
		ore_type        = "blob",
		ore             = "too_many_stones:" .. t,
		wherein         = {"mcl_core:stone", "too_many_stones:granite_pink"},
		clust_scarcity  = MEDIUM,
		clust_num_ores  = 20,
		clust_size      = 4,
		heat_min        = 0,
		heat_max        = 20,
		humidity_min    = 0,
		humidity_max    = 100,
		y_max           = 31000,
		y_min           = -31000,
		noise_params    = mcl_noise(seed()),
	})
end

-- Travertines
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:travertine",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:travertine_yellow",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Tuffs - SKIP Grey Tuff (aliased)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:tuff_beige",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:tuff_red",
	wherein         = mcl_stonelike,
	clust_scarcity  = COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	heat_min        = 60,
	heat_max        = 100,
	humidity_min    = 0,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Turquoise (mild climate)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:turquoise",
	wherein         = mcl_stonelike,
	clust_scarcity  = MEDIUM,
	clust_num_ores  = 25,
	clust_size      = 5,
	heat_min        = 20,
	heat_max        = 60,
	humidity_min    = 20,
	humidity_max    = 60,
	y_max           = 300,
	y_min           = -60,
	noise_params    = mcl_noise(seed()),
})

-- Vivianite (humid, deep)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:vivianite",
	wherein         = mcl_deep_all,
	clust_scarcity  = RARE,
	clust_num_ores  = 15,
	clust_size      = 4,
	heat_min        = 0,
	heat_max        = 100,
	humidity_min    = 60,
	humidity_max    = 100,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

------------------------------------------------------------------------
-- GLOWING STONES (Deep only - mcl_deepslate:deepslate and tuff)
------------------------------------------------------------------------

local glow_stones = {
	"glow_apatite", "glow_calcite", "glow_esperite",
	"glow_fluorite", "glow_selenite", "glow_sodalite", "glow_willemite"
}

for _, stone in ipairs(glow_stones) do
	register_ore_by_climate({
		ore_type        = "blob",
		ore             = "too_many_stones:" .. stone,
		wherein         = mcl_deep_all,
		clust_scarcity  = VERY_RARE,
		clust_num_ores  = 8,
		clust_size      = 2,
		y_max           = -1000,
		y_min           = -31000,
		noise_params    = mcl_noise(seed()),
	})
end

------------------------------------------------------------------------
-- NETHER STONES
-- More common than overworld due to limited volume and only 4 biomes
-- No climate filtering - nether doesn't use the same biome system
------------------------------------------------------------------------

-- Chalcanthite in netherrack (blue copper sulfate - contrast color)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:chalcanthite",
	wherein         = mcl_netherrack,
	clust_scarcity  = NETHER_COMMON,
	clust_num_ores  = 25,
	clust_size      = 5,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Crocoite in blackstone (bright orange - fits nether palette)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:crocoite",
	wherein         = mcl_blackstone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Fire Opal in nether basalt (fire theme)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:fire_opal",
	wherein         = mcl_basalt,
	clust_scarcity  = NETHER_RARE,
	clust_num_ores  = 12,
	clust_size      = 3,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Ilvaite in blackstone (black iron mineral)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:ilvaite",
	wherein         = mcl_blackstone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Carnotite in netherrack (radioactive yellow - dangerous feel)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:carnotite",
	wherein         = mcl_netherrack,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 15,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Erythrite in blackstone (cobalt bloom - purple-red fits nether)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:erythrite",
	wherein         = mcl_blackstone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 15,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Citrine in netherrack (heat-altered amethyst - fits hot theme)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:citrine",
	wherein         = mcl_netherrack,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Scoria in all nether materials (volcanic slag)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:scoria",
	wherein         = mcl_nether_all,
	clust_scarcity  = NETHER_COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Gabbro in basalt (plutonic basalt equivalent)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:gabbro",
	wherein         = mcl_basalt,
	clust_scarcity  = NETHER_COMMON,
	clust_num_ores  = 33,
	clust_size      = 5,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

------------------------------------------------------------------------
-- END STONES
-- End has very limited space, so stones need to be fairly common
-- Purple/black/mysterious theme to match End aesthetic
------------------------------------------------------------------------

-- Black Opal in end stone (dark, mysterious)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:black_opal",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_RARE,
	clust_num_ores  = 12,
	clust_size      = 3,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Black Moonstone in end stone (moon theme fits End)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:black_moonstone",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Sugilite in end stone (purple matches End theme)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:sugilite",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Ammolite in end stone (rainbow fossil - alien appearance)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:ammolite",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_RARE,
	clust_num_ores  = 12,
	clust_size      = 3,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Morion Quartz in end stone (dark smoky quartz - fits void theme)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:morion_quartz",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})

-- Fluorite in end stone (glows under UV - otherworldly)
register_ore_by_climate({
	ore_type        = "blob",
	ore             = "too_many_stones:fluorite",
	wherein         = mcl_end_stone,
	clust_scarcity  = NETHER_MEDIUM,
	clust_num_ores  = 20,
	clust_size      = 4,
	y_max           = 31000,
	y_min           = -31000,
	noise_params    = mcl_noise(seed()),
})
