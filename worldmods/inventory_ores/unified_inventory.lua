local f = string.format

local m_round = math.round

unified_inventory.register_craft_type("inventory_ores:ore_spawns", {
	description = "Ore spawns",
	icon = "default_stone.png",
	width = 1,
	height = 1,
	uses_crafting_grid = false,
})

local function register_ore(def)
	if type(def.wherein) == "table" then
		for _, wherein in ipairs(def.wherein) do
			local d2 = table.copy(def)
			d2.wherein = wherein
			register_ore(d2)
		end
		return
	end

	local wherein = ItemStack(def.wherein)
	if wherein:is_empty() then
		wherein = ItemStack("mapgen_stone")
	end

	local ore_desc = futil.get_safe_short_description(def.ore)
	local matrix_desc = futil.get_safe_short_description(wherein)

	local description = { f("%s in %s", ore_desc, matrix_desc) }
	if def.clust_scarcity then
		table.insert(description, f("1 cluster about every %i nodes", m_round(def.clust_scarcity)))
	end
	if def.clust_size then
		table.insert(
			description,
			f("a cluster is %i*%i*%i (%i) nodes", def.clust_size, def.clust_size, def.clust_size, def.clust_size ^ 3)
		)
	end
	if def.clust_num_ores then
		table.insert(description, f("about %i ores in a cluster", def.clust_num_ores))
	end
	if def.clust_scarcity and def.clust_num_ores then
		table.insert(
			description,
			f("so 1 %s in about every %i %s", ore_desc, m_round(def.clust_scarcity / def.clust_num_ores), matrix_desc)
		)
	end
	if def.y_max then
		table.insert(description, f("upper y level = %i", def.y_max))
	end
	if def.y_min then
		table.insert(description, f("lower y level = %i", def.y_min))
	end
	if def.ore_type then
		table.insert(description, f("ore_type = %s", def.ore_type))
	end

	local meta = wherein:get_meta()
	meta:set_string("description", table.concat(description, "\n"))

	unified_inventory.register_craft({
		output = def.ore,
		type = "inventory_ores:ore_spawns",
		items = { wherein:to_string() },
		width = 1,
	})
end

local i = 0
for _, def in pairs(minetest.registered_ores) do
	register_ore(def)
	i = i + 1
end

inventory_ores.register_on_register_ore(register_ore)
