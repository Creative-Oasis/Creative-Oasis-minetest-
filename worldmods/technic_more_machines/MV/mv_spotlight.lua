minetest.register_node("technic_more_machines:mv_spotlight", {
	description = "MV Spotlight",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_side.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_side.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_front_on.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 5,
	groups = {cracky=2, technic_machine = 1, technic_mv = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left", "right", "back"},
	drop = "technic_more_machines:mv_spotlight_off",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_demand", 500)
			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, 50 do
				if p2 == 0 then		
					pos.z = pos.z - 1
				elseif p2 == 1 then
					pos.x = pos.x - 1
				elseif p2 == 2 then
					pos.z = pos.z + 1
				elseif p2 == 3 then
					pos.x = pos.x + 1
				end
				if (minetest.get_node(pos)).name == "air" then
					minetest.set_node(pos,{name = "technic_more_machines:airlight"})
				else
					break
				end
			end
	end,
	on_destruct = function(pos)
		local p2 = minetest.get_node(pos).param2
		local yi
		for yi = 0, 50 do
			if p2 == 0 then		
				pos.z = pos.z - 1
			elseif p2 == 1 then
				pos.x = pos.x - 1
			elseif p2 == 2 then
				pos.z = pos.z + 1
			elseif p2 == 3 then
				pos.x = pos.x + 1
			end
			if (minetest.get_node(pos)).name == "technic_more_machines:airlight" then
				minetest.set_node(pos,{name = "air"})
			end
		end
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Spotlight active (500EU MV)")
	end,
})

minetest.register_node("technic_more_machines:mv_spotlight_off", {
	description = "MV Spotlight",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_side.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_side.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_mv_spotlight_front_off.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2, technic_machine = 1, technic_mv = 1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_demand", 500)
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Spotlight disabled (500EU MV required)")
	end,
})

technic.register_machine("MV", "technic_more_machines:mv_spotlight", technic.receiver)
technic.register_machine("MV", "technic_more_machines:mv_spotlight_off", technic.receiver)

minetest.register_craft({
	output = "technic_more_machines:mv_spotlight_off",
	recipe = {
	{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"},
	{"default:steel_ingot", "default:meselamp", "default:steel_ingot"},
	{"default:steel_ingot", "technic:mv_cable", "default:steel_ingot"}
  }
})

minetest.register_abm({
	nodenames = {"technic_more_machines:mv_spotlight"},
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, 	active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if meta:get_int("MV_EU_input") < 500 then
			minetest.swap_node(pos, {name = "technic_more_machines:mv_spotlight_off", param2=node.param2,})
			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, 50 do
				if p2 == 0 then		
					pos.z = pos.z - 1
				elseif p2 == 1 then
					pos.x = pos.x - 1
				elseif p2 == 2 then
					pos.z = pos.z + 1
				elseif p2 == 3 then
					pos.x = pos.x + 1
				end
				if (minetest.get_node(pos)).name == "technic_more_machines:airlight" then
					minetest.set_node(pos,{name = "air"})
				end
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"technic_more_machines:mv_spotlight_off"},
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, 	active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if meta:get_int("MV_EU_input") >= 500 then
			minetest.swap_node(pos, {name = "technic_more_machines:mv_spotlight", param2=node.param2,})
			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, 50 do
				if p2 == 0 then		
					pos.z = pos.z - 1
				elseif p2 == 1 then
					pos.x = pos.x - 1
				elseif p2 == 2 then
					pos.z = pos.z + 1
				elseif p2 == 3 then
					pos.x = pos.x + 1
				end
				if (minetest.get_node(pos)).name == "air" then
					minetest.set_node(pos,{name = "technic_more_machines:airlight"})
				else
					break
				end
			end
		end
	end
})

minetest.register_node("technic_more_machines:airlight", {
   description = "air light",
   paramtype = "light",
   drawtype = "airlike",
   light_source = 14,
   sunlight_propagates = true,
   walkable = false,
   pointable = false,
   diggable = false,
   buildable_to = true,
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      meta:set_int("life", 12)
   end
})
