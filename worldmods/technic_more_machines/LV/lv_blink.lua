minetest.register_node("technic_more_machines:lv_blink", {
    description = "LV Blink Teleporter",
	tiles = {
		{name="technic_more_machines_lv_blink_top.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
	},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand=3, technic_machine=1, technic_lv=1},
	paramtype = "light",
	paramtype2 = "facedir",
	connect_sides = {"front", "bottom", "left", "right", "back"},
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(1.5)
		local meta = minetest.get_meta(pos)
		meta:set_int("LV_EU_demand", 900)
	end,
	on_timer = function(pos)
		local p2 = minetest.get_node(pos).param2
		local meta = minetest.get_meta(pos)
		local dest
		for k,v in ipairs(minetest.get_objects_inside_radius({x=pos.x, y=pos.y+1, z=pos.z}, 1)) do
			if v:is_player() and meta:get_int("LV_EU_input") >= 900 then
				if p2 == 0 then
					dest = {x=pos.x, y=pos.y+1, z=pos.z+100}
--					v:setpos({x=pos.x, y=pos.y+1, z=pos.z+100})
				elseif p2 == 1 then
					dest = {x=pos.x+100, y=pos.y+1, z=pos.z}
				elseif p2 == 2 then
					dest = {x=pos.x, y=pos.y+1, z=pos.z-100}
				elseif p2 == 3 then
					dest = {x=pos.x-100, y=pos.y+1, z=pos.z}
				end
				v:setpos(dest)
				minetest.after(0.5, function(dest) minetest.sound_play( {name="travelnet_travel", gain=1}, {pos=dest, max_hear_distance=12}, true) end, dest)
				minetest.add_particlespawner({
					amount = 25,
					time = 1,
					minpos = {x=dest.x-0.4, y=dest.y+0.25, z=dest.z-0.4},
					maxpos = {x=dest.x+0.4, y=dest.y+0.75, z=dest.z+0.4},
					minvel = {x=0, y=-0.1, z=0},
					maxvel = {x=0.1, y=0.1, z=0.1},
					minexptime=1,
					maxexptime=1.5,
					minsize=2,
					maxsize=5,
					texture = "scifi_nodes_tp_part.png"
				})
			end
		end
		return true
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("LV_EU_input") >= 900 then
			meta:set_string("infotext", "LV Blink Teleporter active (900EU LV)")
		else
			meta:set_string("infotext", "LV Blink Teleporter disabled (900EU LV required)")
		end	
	end,
})

technic.register_machine("LV", "technic_more_machines:lv_blink", technic.receiver)

minetest.register_craft({
	output = "technic_more_machines:lv_blink",
	recipe = {
		{"basic_materials:gold_wire","technic:green_energy_crystal","basic_materials:gold_wire"},
		{"technic:control_logic_unit", "technic:machine_casing", "technic:control_logic_unit"},
		{"technic:carbon_steel_ingot","technic:lv_cable","technic:carbon_steel_ingot"},
	}
})
