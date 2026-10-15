-- I need to make this respect protection later
local maxr = 100
local r = 1 -- radius

minetest.register_node("technic_more_machines:hv_terraformer1", {
    description = "HV Terraformer",
	tiles = {
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_furnace_side.png^technic_more_machines_snow.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1}, --delete not_in_creative_inventory = 1
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") >= 4000 + r*4000 then
			meta:set_string("infotext", "HV Terraformer active ("..meta:get_int("HV_EU_demand").."EU HV)")
		else
			meta:set_string("infotext", "HV Terraformer disabled ("..meta:get_int("HV_EU_demand").."EU HV required)")
		end	
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "technic_more_machines:hv_terraformer2", param2=node.param2,})
		r = 1
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
		minetest.sound_play("click_1",{max_hear_distance = 16,pos = pos,gain = 1.0})
	end,
})

--[[minetest.register_craft({
	output = "technic_more_machines:hv_terraformer1",
	recipe = {
		{"pipeworks:nodebreaker_off","basic_materials:gold_wire","pipeworks:deployer_off"},
		{"technic:control_logic_unit", "technic:uranium_fuel", "technic:control_logic_unit"},
		{"technic:carbon_steel_block","technic:hv_cable","technic:carbon_steel_block"},
	}
})
]]--
minetest.register_abm({
	nodenames = {"technic_more_machines:hv_terraformer1"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if r <= maxr and meta:get_int("HV_EU_input") >= 4000 + r*4000 then
		
	-- remove flora (grass, flowers etc.)
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:flora"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "air"})
	end

	-- replace dirt
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:dirt", "default:dirt_with_coniferous_litter", "default:dirt_with_grass", "default:dirt_with_dry_grass", "default:dirt_with_rainforest_litter",
		"default:dry_dirt", "default:dry_dirt_with_dry_grass", "default:permafrost"}) --group:soil
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dirt_with_snow"})
	end

	-- replace sand
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:desert_sand", "default:sand"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:silver_sand"})
	end

	-- replace water, leaves, tree
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:water", "default:cactus"}) --"group:leaves", "group:tree", 
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:ice"})
	end

	-- replace lava
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:lava_source"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:obsidian"})
	end

	-- replace fake_fire:embers
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"fake_fire:embers"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:coalblock"})
	end

	r = r + 1
	meta:set_int("HV_EU_demand", 4000 + r*4000)

	end
	end
})

----------------------------------------------------

minetest.register_node("technic_more_machines:hv_terraformer2", {
    description = "HV Terraformer",
	tiles = {
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_furnace_side.png^technic_more_machines_coniferous.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	drop = "technic_more_machines:hv_terraformer1",
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") >= 4000 + r*4000 then
			meta:set_string("infotext", "HV Terraformer active ("..meta:get_int("HV_EU_demand").."EU HV)")
		else
			meta:set_string("infotext", "HV Terraformer disabled ("..meta:get_int("HV_EU_demand").."EU HV required)")
		end	
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "technic_more_machines:hv_terraformer3", param2=node.param2,})
		r = 1
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
		minetest.sound_play("click_1",{max_hear_distance = 16,pos = pos,gain = 1.0})
	end,
})

minetest.register_abm({
	nodenames = {"technic_more_machines:hv_terraformer2"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if r <= maxr and meta:get_int("HV_EU_input") >= 4000 + r*4000 then

	-- add grass
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:flora"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:fern_"..math.random(1,3)})
	end
		
	-- replace dirt
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:dirt", "default:dirt_with_snow", "default:dirt_with_grass", "default:dirt_with_dry_grass", "default:dirt_with_rainforest_litter",
		"default:dry_dirt", "default:dry_dirt_with_dry_grass", "default:permafrost"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dirt_with_coniferous_litter"})
		if minetest.get_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}).name == "air" and math.random(10) == 1 then
			minetest.set_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}, {name = "default:fern_"..math.random(1,3)})
		end
	end

	-- replace snow and ice
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:ice", "default:snowblock", "default:cave_ice"})
	
	for n = 1, #res do
		if res[n].y > 0 then
			minetest.swap_node(res[n], {name = "air"})
		else
			minetest.swap_node(res[n], {name = "default:water_source"})
		end
	end

	-- remove snow
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:snow"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "air"})
	end

	r = r + 1
	meta:set_int("HV_EU_demand", 4000 + r*4000)

	end
	end
})

----------------------------------------------------

minetest.register_node("technic_more_machines:hv_terraformer3", {
    description = "HV Terraformer",
	tiles = {
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_furnace_side.png^technic_more_machines_grass.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	drop = "technic_more_machines:hv_terraformer1",
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") >= 4000 + r*4000 then
			meta:set_string("infotext", "HV Terraformer active ("..meta:get_int("HV_EU_demand").."EU HV)")
		else
			meta:set_string("infotext", "HV Terraformer disabled ("..meta:get_int("HV_EU_demand").."EU HV required)")
		end	
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "technic_more_machines:hv_terraformer4", param2=node.param2,})
		r = 1
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
		minetest.sound_play("click_1",{max_hear_distance = 16,pos = pos,gain = 1.0})
	end,
})

minetest.register_abm({
	nodenames = {"technic_more_machines:hv_terraformer3"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if r <= maxr and meta:get_int("HV_EU_input") >= 4000 + r*4000 then
		
	-- add grass
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:flora"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:grass_"..math.random(1,4)})
	end

	-- replace dirt
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:dirt", "default:dirt_with_coniferous_litter", "default:dirt_with_snow", "default:dirt_with_dry_grass", "default:dirt_with_rainforest_litter",
		"default:dry_dirt", "default:dry_dirt_with_dry_grass", "default:permafrost"}) --group:soil
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dirt_with_grass"})
		if minetest.get_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}).name == "air" and math.random(10) == 1 then
			minetest.set_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}, {name = "default:grass_"..math.random(1,4)})
		end
	end

	-- replace snow and ice
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:ice", "default:snowblock", "default:cave_ice"})
	
	for n = 1, #res do
		if res[n].y > 0 then
			minetest.swap_node(res[n], {name = "air"})
		else
			minetest.swap_node(res[n], {name = "default:water_source"})
		end
	end

	-- remove snow
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:snow"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "air"})
	end

	r = r + 1
	meta:set_int("HV_EU_demand", 4000 + r*4000)

	end
	end
})

----------------------------------------------------

minetest.register_node("technic_more_machines:hv_terraformer4", {
    description = "HV Terraformer",
	tiles = {
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_furnace_side.png^technic_more_machines_rainforest.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	drop = "technic_more_machines:hv_terraformer1",
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") >= 4000 + r*4000 then
			meta:set_string("infotext", "HV Terraformer active ("..meta:get_int("HV_EU_demand").."EU HV)")
		else
			meta:set_string("infotext", "HV Terraformer disabled ("..meta:get_int("HV_EU_demand").."EU HV required)")
		end	
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "technic_more_machines:hv_terraformer5", param2=node.param2,})
		r = 1
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
		minetest.sound_play("click_1",{max_hear_distance = 16,pos = pos,gain = 1.0})
	end,
})

minetest.register_abm({
	nodenames = {"technic_more_machines:hv_terraformer4"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if r <= maxr and meta:get_int("HV_EU_input") >= 4000 + r*4000 then
		
	-- add grass
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:flora"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:junglegrass"})
	end

	-- replace dirt
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:dirt", "default:dirt_with_coniferous_litter", "default:dirt_with_snow", "default:dirt_with_dry_grass", "default:dirt_with_grass",
		"default:dry_dirt", "default:dry_dirt_with_dry_grass", "default:permafrost"}) --group:soil
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dirt_with_rainforest_litter"})
		if minetest.get_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}).name == "air" and math.random(10) == 1 then
			minetest.set_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}, {name = "default:junglegrass"})
		end
	end

	-- replace snow and ice
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:ice", "default:snowblock", "default:cave_ice"})
	
	for n = 1, #res do
		if res[n].y > 0 then
			minetest.swap_node(res[n], {name = "air"})
		else
			minetest.swap_node(res[n], {name = "default:water_source"})
		end
	end

	-- remove snow
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:snow"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "air"})
	end

	r = r + 1
	meta:set_int("HV_EU_demand", 4000 + r*4000)

	end
	end
})

----------------------------------------------------

minetest.register_node("technic_more_machines:hv_terraformer5", {
    description = "HV Terraformer",
	tiles = {
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_bottom.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_terraformer_side.png",
		"technic_more_machines_hv_furnace_side.png^technic_more_machines_dry_grass.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	drop = "technic_more_machines:hv_terraformer1",
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") >= 4000 + r*4000 then
			meta:set_string("infotext", "HV Terraformer active ("..meta:get_int("HV_EU_demand").."EU HV)")
		else
			meta:set_string("infotext", "HV Terraformer disabled ("..meta:get_int("HV_EU_demand").."EU HV required)")
		end	
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "technic_more_machines:hv_terraformer1", param2=node.param2,})
		r = 1
		minetest.get_meta(pos):set_int("HV_EU_demand", 8000)
		minetest.sound_play("click_1",{max_hear_distance = 16,pos = pos,gain = 1.0})
	end,
})

minetest.register_abm({
	nodenames = {"technic_more_machines:hv_terraformer5"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if r <= maxr and meta:get_int("HV_EU_input") >= 4000 + r*4000 then
		
	-- add grass
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"group:flora"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dry_grass_"..math.random(1,5)})
	end

	-- replace dirt
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:dirt", "default:dirt_with_coniferous_litter", "default:dirt_with_snow", "default:dirt_with_rainforest_litter", "default:dirt_with_grass",
		"default:dry_dirt", "default:dry_dirt_with_dry_grass", "default:permafrost"}) --group:soil
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "default:dry_dirt_with_dry_grass"})
		if minetest.get_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}).name == "air" and math.random(10) == 1 then
			minetest.set_node({x = res[n].x, y = res[n].y + 1, z = res[n].z}, {name = "default:dry_grass_"..math.random(1,5)})
		end
	end

	-- replace snow and ice
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:ice", "default:snowblock", "default:cave_ice"})
	
	for n = 1, #res do
		if res[n].y > 0 then
			minetest.swap_node(res[n], {name = "air"})
		else
			minetest.swap_node(res[n], {name = "default:water_source"})
		end
	end

	-- remove snow
	local res = minetest.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - 1, z = pos.z - r},
		{x = pos.x + r, y = pos.y + 10, z = pos.z + r},
		{"default:snow"})
	
	for n = 1, #res do
		minetest.swap_node(res[n], {name = "air"})
	end

	r = r + 1
	meta:set_int("HV_EU_demand", 4000 + r*4000)

	end
	end
})

technic.register_machine("HV", "technic_more_machines:hv_terraformer1", technic.receiver)
technic.register_machine("HV", "technic_more_machines:hv_terraformer2", technic.receiver)
technic.register_machine("HV", "technic_more_machines:hv_terraformer3", technic.receiver)
technic.register_machine("HV", "technic_more_machines:hv_terraformer4", technic.receiver)
technic.register_machine("HV", "technic_more_machines:hv_terraformer5", technic.receiver)
