minetest.register_craft({
	output = 'technic_more_machines:mv_geothermal',
	recipe = {
		{'technic:geothermal', 'technic:geothermal', 'technic:geothermal'},
		{'technic:geothermal', 'technic:mv_transformer', 'technic:geothermal'},
		{'',                   'technic:mv_cable', ''},
	}
})

-- the rest is pretty much just copied from technic

local check_node_around = function(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "water") > 0 or minetest.get_node(pos).name == "default:ice" or minetest.get_node(pos).name == "default:snowblock" then return 1 end
	if minetest.get_item_group(node.name, "lava") > 0 then return 2 end
	return 0
end

local geo_run = function(pos, node)
	local meta             = minetest.get_meta(pos)
	local water_nodes      = 0
	local lava_nodes       = 0
	local production_level = 0
	local eu_supply        = 0

	-- assume MV by default
	local supply_name      = "MV_EU_supply"
	local tier_name        = "MV"
	local name_off         = "technic_more_machines:mv_geothermal"
	local name_on          = "technic_more_machines:mv_geothermal_active"
	local unit_value       = 375	-- 75 * 5 (1500 at full power)

	-- assume machine is inactive
	local is_on            = false

	local n = minetest.get_node(pos).name

	-- check whether it really is active
	if n == "technic_more_machines:mv_geothermal_active" then
		is_on = true
	end

	local ice = minetest.find_nodes_in_area(
		{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
		{x = pos.x + 2, y = pos.y, z = pos.z + 2},
		{"default:ice"})

	local water = minetest.find_nodes_in_area(
		{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
		{x = pos.x + 2, y = pos.y, z = pos.z + 2},
		{"caverealms:thin_ice", "default:snowblock", "default:water_source", "default:water_flowing"})

	local lava = minetest.find_nodes_in_area(
		{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
		{x = pos.x + 2, y = pos.y, z = pos.z + 2},
		{"default:lava_source", "default:lava_flowing"})
		
	for n = 1, #ice do
		if math.random(500) == 1 then
			minetest.swap_node(ice[n], {name = "default:water_source"})
		end
	end

	for n = 1, #water do
		if math.random(500) == 1 then
			minetest.swap_node(water[n], {name = "air"})
		end
	end
	
	for n = 1, #lava do
		if math.random(500) == 1 then
			if minetest.get_node(lava[n]).name == "default:lava_flowing" then
				minetest.swap_node(lava[n], {name = "default:desert_sand"})
			end
		end
	end

	meta:set_int("MV_EU_supply", 25 * #water + 50 * #ice + 50 * #lava)

	-- no lava or no water = no steam = no power
	if #lava == 0 or (#water + #ice) == 0 then
		meta:set_int("MV_EU_supply", 0)
	end

	meta:set_string("infotext", "MV Geothermal Generator".." ("..meta:get_int("MV_EU_supply").."EU)")

	-- check for and deploy change state
	if meta:get_int("MV_EU_supply") > 0 and not is_on then
		technic.swap_node(pos, name_on)
	elseif meta:get_int("MV_EU_supply") == 0 and is_on then
		technic.swap_node(pos, name_off)
	end
end

minetest.register_node("technic_more_machines:mv_geothermal", {
	description = "MV Geothermal Generator",
	tiles = {"technic_geothermal_top.png",
			"technic_more_machines_mv_geo_bottom.png",
			"default_ice.png^technic_more_machines_mv_geo_side.png",
			"default_lava.png^technic_more_machines_mv_geo_side.png",
			"technic_more_machines_mv_distiller_top.png",
			"technic_more_machines_mv_distiller_top.png"},
	paramtype2 = "facedir",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, technic_mv=1},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Geothermal Generator")
		meta:set_int("MV_EU_supply", 0)
	end,
	technic_run = geo_run,
})

minetest.register_node("technic_more_machines:mv_geothermal_active", {
	description = "MV Geothermal Generator",
	tiles = {"technic_geothermal_top_active.png",
			"technic_more_machines_mv_geo_bottom.png",
			"default_ice.png^technic_more_machines_mv_geo_side.png",
			"default_lava.png^technic_more_machines_mv_geo_side.png",
			"technic_more_machines_mv_distiller_top.png",
			"technic_more_machines_mv_distiller_top.png"},
	paramtype2 = "facedir",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, technic_mv=1,
		not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	drop = "technic_more_machines:mv_geothermal",
	technic_run = geo_run,
})

technic.register_machine("MV", "technic_more_machines:mv_geothermal",        technic.producer)
technic.register_machine("MV", "technic_more_machines:mv_geothermal_active", technic.producer)
