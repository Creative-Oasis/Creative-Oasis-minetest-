--I need to make this respect protections later
local dist = 4 -- distance from zero

minetest.register_node("technic_more_machines:hv_laser", {
	description = "HV Laser Emitter",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_hv_laser_side.png^[transformFX",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_hv_laser_side.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_spotlight_top.png^technic_more_machines_hv_laser_front.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 5,
	groups = {cracky=2, technic_machine = 1, technic_hv = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "back"},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("HV_EU_demand", 1000)
		meta:set_int("mesecon_effect", 1)
--[[			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, dist do
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
					minetest.set_node(pos,{name = "technic_more_machines:laser_bar", param2 = p2+1})
				else
					break
				end
			end]]
	end,
	on_destruct = function(pos)
		local p2 = minetest.get_node(pos).param2
		local yi
		for yi = 0, dist do
			if p2 == 0 then		
				pos.z = pos.z - 1
			elseif p2 == 1 then
				pos.x = pos.x - 1
			elseif p2 == 2 then
				pos.z = pos.z + 1
			elseif p2 == 3 then
				pos.x = pos.x + 1
			end
			if (minetest.get_node(pos)).name == "technic_more_machines:laser_bar" then
				minetest.set_node(pos,{name = "air"})
			end
		end
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("mesecon_effect") == 0 then
			meta:set_string("infotext", "HV Laser emitter disabled")
			meta:set_int("HV_EU_demand", 0)
		else
			meta:set_string("infotext", "HV Laser emitter active (1000EU HV)")
			meta:set_int("HV_EU_demand", 1000)
--			minetest.sound_play("default_cool_lava.1.ogg",{max_hear_distance = 16,pos = pos,gain = 1.0})
		end
	end,
	mesecons = {
		effector = {
			action_on = function(pos, node)
				minetest.get_meta(pos):set_int("mesecon_effect", 1)
			end,
			action_off = function(pos, node)
				minetest.get_meta(pos):set_int("mesecon_effect", 0)
			end
		}
	}
})

technic.register_machine("HV", "technic_more_machines:hv_laser", technic.receiver)

minetest.register_node("technic_more_machines:laser_bar", {
	description = "Laser Bar",
	tiles = {
		"technic_more_machines_hv_laser_bar.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = true,
	light_source = 9,
	damage_per_second = 18,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.125, 0.125, 0.5, 0.375, 0.375}, -- NodeBox1
			{-0.5, 0.125, -0.375, 0.5, 0.375, -0.125}, -- NodeBox2
			{-0.5, -0.375, -0.375, 0.5, -0.125, -0.125}, -- NodeBox3
			{-0.5, -0.375, 0.125, 0.5, -0.125, 0.375}, -- NodeBox4
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1, -1, -1, 1, 1, 1},
		}
	},
	liquid_viscosity = 8,
	liquidtype = "source",
	liquid_alternative_flowing = "technic_more_machines:laser_bar",
	liquid_alternative_source = "technic_more_machines:laser_bar",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	pointable = false,
	diggable = false,
--	buildable_to = true,
})

minetest.register_abm({
	nodenames = {"technic_more_machines:hv_laser"},
	interval = 3,
	chance = 1,
	action = function(pos, node, active_object_count, 	active_object_count_wider)
		local meta = minetest.get_meta(pos)
		if meta:get_int("HV_EU_input") < 1000 or meta:get_int("mesecon_effect") == 0 then
			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, dist do
				if p2 == 0 then		
					pos.z = pos.z - 1
				elseif p2 == 1 then
					pos.x = pos.x - 1
				elseif p2 == 2 then
					pos.z = pos.z + 1
				elseif p2 == 3 then
					pos.x = pos.x + 1
				end
				if (minetest.get_node(pos)).name == "technic_more_machines:laser_bar" then
					minetest.set_node(pos,{name = "air"})
				end
			end
		else
			local p2 = minetest.get_node(pos).param2
			local yi
			for yi = 0, dist do
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
					minetest.set_node(pos,{name = "technic_more_machines:laser_bar", param2 = p2+1})
				else
					break
				end
			end
		end
	end
})

minetest.register_craft({
	output = "technic_more_machines:hv_laser",
	recipe = {
	{"technic:red_energy_crystal", "technic:red_energy_crystal", "technic:stainless_steel_ingot"},
	{"technic:red_energy_crystal", "technic:red_energy_crystal", "technic:stainless_steel_ingot"},
	{"technic:stainless_steel_ingot", "technic:hv_transformer", "technic:hv_cable"}
  }
})
