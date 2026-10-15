minetest.register_node("technic_more_machines:lv_tubelib_repairer", {
    description = "LV Tubelib Repairer (Prevent tubelib machines from defecting)",
	tiles = {
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png^technic_more_machines_lv_tubelib_repairer.png",
	},
    is_ground_content = false,
	groups = {cracky=2, technic_machine = 1, technic_lv = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"top", "bottom", "left", "right", "back"},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_int("LV_EU_demand", 2000)
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("LV_EU_input") < 2000 then
			meta:set_string("infotext", "LV Tubelib Repairer disabled (2000EU LV required)")
		end	
	end,
})

minetest.register_craft({
	output = "technic_more_machines:lv_tubelib_repairer",
	recipe = {
		{"default:steel_ingot","tubelib_addons2:timer","default:steel_ingot"},
		{"tubelib:repairkit", "technic:machine_casing", "tubelib:end_wrench"},
		{"default:steel_ingot","technic:lv_cable","default:steel_ingot"},
	}
})

minetest.register_abm({
	nodenames = {"technic_more_machines:lv_tubelib_repairer"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local count = 0
		local meta = minetest.get_meta(pos)
		if meta:get_int("LV_EU_input") >= 2000 then
		
	local res = minetest.find_nodes_with_meta(
		{x = pos.x - 10, y = pos.y - 10, z = pos.z - 10},
		{x = pos.x + 10, y = pos.y + 10, z = pos.z + 10})
	
	for n = 1, #res do
		if minetest.get_meta(res[n]):get_int("tubelib_aging") > 0 then
				minetest.get_meta(res[n]):set_int("tubelib_aging", 0)
				count = count + 1
		end
	end
	
	meta:set_string("infotext", "LV Tubelib Repairer active (2000EU LV), "..count.." damaged tubelib devices found within a radius of 10m")

	end
	end
})

technic.register_machine("LV", "technic_more_machines:lv_tubelib_repairer", technic.receiver)
