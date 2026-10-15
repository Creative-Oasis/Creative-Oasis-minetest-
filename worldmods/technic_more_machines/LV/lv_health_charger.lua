minetest.register_node("technic_more_machines:lv_health_charger", {
	description = "LV Health Charger",
	tiles = {
		"technic_more_machines_lv_health_charger_side.png",
		"technic_more_machines_lv_health_charger_side.png",
		"technic_more_machines_lv_health_charger_side.png",
		"technic_more_machines_lv_health_charger_side.png",
		"technic_more_machines_lv_health_charger_side.png",
		"technic_more_machines_lv_health_charger.png",
	},
	groups = {cracky=2, technic_machine = 1, technic_lv = 1},
	connect_sides = {"top", "bottom", "back", "left", "right"},
	paramtype2 = "facedir",
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Alien Charger")
		meta:set_int("LV_EU_demand", 2500)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if player:get_hp() < 20 then
			minetest.sound_play("health_charger",{max_hear_distance = 16,pos = pos,gain = 1.0})
--			stamina.change(player, 20)
			player:set_hp(player:get_hp() + 10)
		end

--poison from water life support
--Opons1: I never used water life and I don't have it, hopfully this still works fine with it
		local meta = player:get_meta()
		if meta:get_int("snakepoison") > 0 then 
			meta:set_int("snakepoison",0) 
			water_life.change_hud(player,"poison",0) 
		end
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("LV_EU_input") < 2500 then
			meta:set_string("infotext", "LV Health Charger disabled ("..meta:get_int("LV_EU_demand").."EU LV required)")
		else
			meta:set_string("infotext", "LV Health Charger active ("..meta:get_int("LV_EU_demand").."EU LV)")
		end	
	end,
})

minetest.register_craft({
	output = "technic_more_machines:lv_health_charger",
	recipe = {
	{"technic:stainless_steel_ingot", "basic_materials:energy_crystal_simple", "technic:stainless_steel_ingot"},
	{"technic:stainless_steel_ingot", "technic:lv_transformer", "technic:stainless_steel_ingot"},
	{"technic:stainless_steel_ingot", "technic:lv_cable", "technic:stainless_steel_ingot"}
  }
})

technic.register_machine("LV", "technic_more_machines:lv_health_charger", technic.receiver)
