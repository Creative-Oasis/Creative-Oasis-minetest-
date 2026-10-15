local cable_entry = "^technic_cable_connection_overlay.png"
--i am doing everything i can to optomize since i am gonna SPAM this node in my server
--i tried to replicate technics hydro
local function get_flow(pos)
    --apparently this is the fastest way to go about modifying coordinates, since it isnt making new tables
    --i didnt loop since i was feeling lazy, got tired after the forge spaghetti
    local flow = 0
    local node
    pos.x = pos.x + 1
    node = core.get_node(pos)
    if core.get_item_group(node.name, "water") == 3 then
        flow = node.param2
    end
    pos.x = pos.x - 2
    node = core.get_node(pos)
	if core.get_item_group(node.name, "water") == 3 then
		flow = flow + node.param2
	end
    pos.x = pos.x + 1
    pos.z = pos.z + 1
    node = core.get_node(pos)
	if core.get_item_group(node.name, "water") == 3 then
		flow = flow + node.param2
	end
    pos.z = pos.z - 2
    node = core.get_node(pos)
	if core.get_item_group(node.name, "water") == 3 then
		flow = flow + node.param2
	end
    --took me so long to figure out this is why it was failing... why do i need to do this
    pos.z = pos.z + 1
    return flow
end

function technic_many_machines.register_hydro_generator(name, data)
    local groups = data.groups or {}
    local tier = data.tier
    local ltier = string.lower(tier)
    local supplytype = tier .. "_EU_supply"
    local max_supply = data.max_supply
    local supply_mult = math.ceil(data.max_supply/45)


    --add groups standard to technic machines
    groups["technic_machine"] = 1
    groups["technic_" .. ltier] = 1


    core.register_node(name, {
        description = data.description,
        tiles = data.tiles,
        paramtype2 = "facedir",
        groups = groups,
        is_ground_content = false,
        sounds = data.sounds or technic.sounds.node_sound_wood_defaults(),
        on_construct = function(pos)
		    local meta = core.get_meta(pos)
		    meta:set_string("infotext", data.description)
		    meta:set_int(supplytype, 0)
            meta:set_int("step", 0)
	    end,
        technic_run = function(pos)
    	    local meta = core.get_meta(pos)
            local step = meta:get_int("step")
            --only check once every 4 seconds, this thing is so easy to set up it doesnt really matter
            if step ~= 0 then
                meta:set_int("step", step - 1)
            else
                meta:set_int("step", 4)
                 --get water flow
                local flow = get_flow(pos)
                --eu supply
                local eu_supply = math.min(supply_mult * flow, max_supply)
                --what percent of efficiency this is being used in
                local production_level = math.floor(100 * eu_supply / max_supply)
                meta:set_int(supplytype, eu_supply)
                --infotext
                meta:set_string("infotext", data.description .. " (" .. production_level .. "%) Efficiency")
            end
        end,
    })

    technic.register_machine(tier, name, technic.producer)
end

technic_many_machines.register_hydro_generator("technic_many_machines:hydro_mv_generator_mk2", {
    groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, technic_mv=1},
    tier = "MV",
    max_supply= 9000,
    description = "Hydro MV Generator MK2",
    tiles = {
		"technic_many_machines_mv_hydro_top_mk2.png",
		"technic_many_machines_machine_bottom_mk2.png"..cable_entry,
		"technic_many_machines_mv_hydro_side_mk2.png",
		"technic_many_machines_mv_hydro_side_mk2.png",
		"technic_many_machines_mv_hydro_side_mk2.png",
		"technic_many_machines_mv_hydro_side_mk2.png"
	},
})
