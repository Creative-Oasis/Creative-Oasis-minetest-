minetest.register_craft({
	output = 'technic_more_machines:mv_oxygen_generator',
	recipe = {
		{'technic:stainless_steel_ingot', 'basic_materials:motor', 'technic:stainless_steel_ingot'},
		{'technic:carbon_cloth', 'technic:machine_casing', 'technic:carbon_cloth'},
		{'technic:stainless_steel_ingot', 'technic:mv_cable', 'technic:stainless_steel_ingot'},
	}
})

local oxigen_generator_demand = {5000, 4000, 3000}

local oxigen_formspec =
	"size[8,9;]"..
	"list[current_name;src;3,1;1,1;]"..
	"label[0,0;MV Oxygen Generator]"..
	"list[current_name;upgrade1;1,3;1,1;]"..
	"list[current_name;upgrade2;2,3;1,1;]"..
	"label[1,4;Upgrade Slots]"..
	"list[current_player;main;0,5;8,4;]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;upgrade1]"..
	"listring[current_player;main]"..
	"listring[current_name;upgrade2]"..
	"listring[current_player;main]"

minetest.register_node("technic_more_machines:mv_oxygen_generator", {
	description = "MV Oxygen Generator",
	paramtype2 = "facedir",
	tiles = {
		"technic_more_machines_mv_oxy_top.png",
		"technic_machine_bottom.png^technic_more_machines_mv_oxy_side.png",
		"technic_machine_bottom.png^technic_more_machines_mv_oxy_side.png",
		"technic_machine_bottom.png^technic_more_machines_mv_oxy_side.png",
		"technic_machine_bottom.png^technic_more_machines_mv_oxy_side.png",
		{name="technic_more_machines_mv_oxygen_generator.png",animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=0.50}}
	},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, technic_mv=1, tubedevice=1, tubedevice_receiver=1, tube=1},
	connect_sides = {"bottom", "back", "left", "right"},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Oxygen_generator")
		meta:set_string("formspec", oxigen_formspec)
		meta:set_int("MV_EU_demand", oxigen_generator_demand[1])
		local inv = meta:get_inventory()
		inv:set_size("src", 1)
		inv:set_size("upgrade1", 1)
		inv:set_size("upgrade2", 1)
	end,
	can_dig = technic.machine_can_dig,
	allow_metadata_inventory_put = technic.machine_inventory_put,
	allow_metadata_inventory_take = technic.machine_inventory_take,
	tube = {
		can_insert = function (pos, node, stack, direction)
			return minetest.get_meta(pos):get_inventory():room_for_item("src", stack)
		end,
		insert_object = function (pos, node, stack, direction)
			return minetest.get_meta(pos):get_inventory():add_item("src", stack)
		end,
		connect_sides = {left = 1, right = 1, back = 1, top = 1, bottom = 1},
	},
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Oxygen Generator - "..meta:get_int("MV_EU_demand").."EU")
	end,
	after_place_node = pipeworks.after_place,
	after_dig_node = technic.machine_after_dig_node
})

technic.register_machine("MV", "technic_more_machines:mv_oxygen_generator", technic.receiver)

minetest.register_craftitem("technic_more_machines:oxygen", {
	description = "Oxygen",
	inventory_image = "technic_more_machines_oxygen.png",
})

minetest.register_abm({
	nodenames = {"technic_more_machines:mv_oxygen_generator"},
	interval = 120, --2 minutes
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta         = minetest.get_meta(pos)
		local inv          = meta:get_inventory()
		local eu_input     = meta:get_int("MV_EU_input")
		local machine_name = ("MV Oxygen Generator"):format("MV")

		-- Setup meta data if it does not exist.
		if not eu_input then
			meta:set_int("MV_EU_demand", oxigen_generator_demand[1])
			meta:set_int("MV_EU_input", 0)
			return
		end

		local EU_upgrade, tube_upgrade = technic.handle_machine_upgrades(meta)

		technic.handle_machine_pipeworks(pos, tube_upgrade, function (pos, x_velocity, z_velocity)
			if not repairable then
				technic.send_items(pos, x_velocity, z_velocity, "src")
			end
		end)

		if eu_input < oxigen_generator_demand[EU_upgrade+1] then
			meta:set_string("infotext", "MV Oxygen Generator Inactive")
		elseif eu_input >= oxigen_generator_demand[EU_upgrade+1] then
			meta:set_string("infotext", "MV Oxygen Generator Active")
			inv:add_item("src", "technic_more_machines:oxygen")
		end
		meta:set_int("MV_EU_demand", oxigen_generator_demand[EU_upgrade+1])

	end
})

--recipes

minetest.register_craftitem("technic_more_machines:iron_oxide", {
	description = "Iron Oxide",
	inventory_image = "technic_more_machines_iron_oxide.png",
})

technic.register_alloy_recipe({input = {'technic:wrought_iron_dust', 'technic_more_machines:oxygen'}, output = 'technic_more_machines:iron_oxide', time = 3})

minetest.register_craft({
	output = "dye:orange 3",
	recipe = {{'technic_more_machines:iron_oxide', 'default:clay_lump'}}
})

technic.register_alloy_recipe({input = {'technic:lead_dust', 'technic_more_machines:oxygen'}, output = 'dye:red 3', time = 3})

technic.register_alloy_recipe({input = {'technic:zinc_dust', 'technic_more_machines:oxygen'}, output = 'dye:white 3', time = 3})

technic.register_grinder_recipe({input = {'default:silver_sand'}, output = 'dye:white 3', time = 3})

technic.register_alloy_recipe({input = {'technic:sulfur_dust', 'technic:tin_dust'}, output = 'dye:yellow 3', time = 3})

technic.register_alloy_recipe({input = {'technic:sulfur_dust', 'technic:copper_dust'}, output = 'dye:green 3', time = 3})

technic.register_alloy_recipe({input = {'technic:chromium_dust', 'technic_more_machines:oxygen'}, output = 'dye:dark_green 3', time = 3})

technic.register_alloy_recipe({input = {'default:sand', 'technic:copper_dust'}, output = 'dye:blue 3', time = 3})

technic.register_alloy_recipe({input = {'default:sand', 'dye:orange'}, output = 'default:desert_sandstone', time = 3})
technic.register_alloy_recipe({input = {'default:silver_sand', 'dye:orange'}, output = 'default:desert_sandstone', time = 3})

technic.register_alloy_recipe({input = {'default:sand', 'dye:white'}, output = 'default:silver_sandstone', time = 3})
technic.register_alloy_recipe({input = {'default:desert_sand', 'dye:white'}, output = 'default:silver_sandstone', time = 3})

technic.register_alloy_recipe({input = {'default:desert_sand', 'dye:yellow'}, output = 'default:sandstone', time = 3})
technic.register_alloy_recipe({input = {'default:silver_sand', 'dye:yellow'}, output = 'default:sandstone', time = 3})

technic.register_alloy_recipe({input = {'default:cobble', 'dye:red'}, output = 'default:desert_stone', time = 3})
