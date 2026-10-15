node_positions = {}

local elepower_users = {
	["elepower_dynamics:conduit"] = true,
	["elepower_dynamics:conduit_wall"] = true,
	["elepower_dynamics:conduit_dirt_with_grass"] = true,
	["elepower_dynamics:conduit_dirt_with_dry_grass"] = true,
	["elepower_dynamics:conduit_stone_block"] = true,
	["elepower_dynamics:conduit_stone_block_desert"] = true,
	["elepower_lighting:conduit_iron_thin"] = true,
	["elepower_lighting:conduit_iron_thick"] = true,
	["elepower_lighting:conduit_steel_thin"] = true,
	["elepower_lighting:conduit_steel_thick"] = true,
	["elepower_lighting:conduit_gold_thin"] = true,
	["elepower_lighting:conduit_gold_thick"] = true,
	["elepower_lighting:conduit_wood_thin"] = true,
	["elepower_lighting:conduit_wood_thick"] = true,
	["elepower_farming:harvester"] = true,
	["elepower_farming:harvester_active"] = true,
	["elepower_farming:tree_processor"] = true,
	["elepower_farming:planter"] = true,
	["elepower_farming:spawner"] = true,
	["elepower_lighting:bulb_incandescent"] = true,
	["elepower_lighting:bulb_incandescent_active"] = true,
	["elepower_dynamics:uv_bulb"] = true,
	["elepower_dynamics:uv_bulb_active"] = true,
	["elepower_lighting:bulb_cf"] = true,
	["elepower_lighting:bulb_cf_active"] = true,
	["elepower_lighting:fluro_light_bank"] = true,
	["elepower_lighting:fluro_light_bank_active"] = true,
	["elepower_lighting:bulb_led"] = true,
	["elepower_lighting:bulb_led_active"] = true,
	["elepower_lighting:led_light_panel"] = true,
	["elepower_lighting:led_light_panel_active"] = true,
	["elepower_lighting:led_light_panel_colored"] = true,
	["elepower_lighting:led_light_panel_colored_active"] = true,
	["elepower_lighting:led_1x3_light_panel"] = true,
	["elepower_lighting:led_1x3_light_panel_active"] = true,
	["elepower_lighting:led_2x3_light_panel"] = true,
	["elepower_lighting:led_2x3_light_panel_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yp0"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yp0"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yp0"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yp20"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yp20"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yn20"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yn20"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yn20"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yp20"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yp0_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yp0_active"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yp0_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yp20_active"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yp20_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp45_yn20_active"] = true,
	["elepower_lighting:incandescent_floodlight_xn45_yn20_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yn20_active"] = true,
	["elepower_lighting:incandescent_floodlight_xp0_yp20_active"] = true,
	["elepower_lighting:cf_floodlight_xp0_yp0_active"] = true,
	["elepower_lighting:led_floodlight_xp0_yp0_active"] = true,
	["elepower_machines:alloy_furnace"] = true,
	["elepower_machines:alloy_furnace_active"] = true,
	["elepower_machines:canning_machine"] = true,
	["elepower_machines:compressor"] = true,
	["elepower_machines:electrolyzer"] = true,
	["elepower_machines:evaporator"] = true,
	["elepower_machines:evaporator_active"] = true,
	["elepower_machines:furnace"] = true,
	["elepower_machines:furnace_active"] = true,
	["elepower_machines:lava_cooler"] = true,
	["elepower_machines:pcb_plant"] = true,
	["elepower_machines:pcb_plant_active"] = true,
	["elepower_machines:pulverizer"] = true,
	["elepower_machines:pulverizer_active"] = true,
	["elepower_machines:pump"] = true,
	["elepower_machines:sawmill"] = true,
	["elepower_machines:solderer"] = true, 
	["elepower_mining:miner_controller"] = true,
	["elepower_machines:power_cell_0"] = true,
	["elepower_machines:power_cell_1"] = true,
	["elepower_machines:power_cell_2"] = true,
	["elepower_machines:power_cell_3"] = true,
	["elepower_machines:power_cell_4"] = true,
	["elepower_machines:power_cell_5"] = true,
	["elepower_machines:power_cell_6"] = true,
	["elepower_machines:power_cell_7"] = true,
	["elepower_machines:power_cell_8"] = true,
	["elepower_machines:hardened_power_cell_0"] = true,
	["elepower_machines:hardened_power_cell_1"] = true,
	["elepower_machines:hardened_power_cell_2"] = true,
	["elepower_machines:hardened_power_cell_3"] = true,
	["elepower_machines:hardened_power_cell_4"] = true,
	["elepower_machines:hardened_power_cell_5"] = true,
	["elepower_machines:hardened_power_cell_6"] = true,
	["elepower_machines:hardened_power_cell_7"] = true,
	["elepower_machines:hardened_power_cell_8"] = true,
	["elepower_machines:reinforced_power_cell_0"] = true,
	["elepower_machines:reinforced_power_cell_1"] = true,
	["elepower_machines:reinforced_power_cell_2"] = true,
	["elepower_machines:reinforced_power_cell_3"] = true,
	["elepower_machines:reinforced_power_cell_4"] = true,
	["elepower_machines:reinforced_power_cell_5"] = true,
	["elepower_machines:reinforced_power_cell_6"] = true,
	["elepower_machines:reinforced_power_cell_7"] = true,
	["elepower_machines:reinforced_power_cell_8"] = true,
	["elepower_machines:resonant_power_cell_0"] = true,
	["elepower_machines:resonant_power_cell_1"] = true,
	["elepower_machines:resonant_power_cell_2"] = true,
	["elepower_machines:resonant_power_cell_3"] = true,
	["elepower_machines:resonant_power_cell_4"] = true,
	["elepower_machinesresonant_:power_cell_5"] = true,
	["elepower_machines:resonant_power_cell_6"] = true,
	["elepower_machines:resonant_power_cell_7"] = true,
	["elepower_machines:resonant_power_cell_8"] = true,
	["elepower_machines:super_power_cell_0"] = true,
	["elepower_machines:super_power_cell_1"] = true,
	["elepower_machines:super_power_cell_2"] = true,
	["elepower_machines:super_power_cell_3"] = true,
	["elepower_machines:super_power_cell_4"] = true,
	["elepower_machines:super_power_cell_5"] = true,
	["elepower_machines:super_power_cell_6"] = true,
	["elepower_machines:super_power_cell_7"] = true,
	["elepower_machines:super_power_cell_8"] = true,
	["elepower_mining:miner_controller"] = true,
	["elepower_nuclear:enrichment_plant"] = true,
	["elepower_nuclear:reactor_power"] = true,
	["elepower_wireless:dialler"] = true,
	["elepower_wireless:dialler_active"] = true,
	["elepower_wireless:matter_receiver"] = true,
	["elepower_wireless:matter_receiver_active"] = true,
	["elepower_wireless:matter_transmitter"] = true,
	["elepower_wireless:matter_transmitter_active"] = true,
	["elepower_wireless:station"] = true,
	["technic_elepower_compat:power_converter"] = true,
}

-- Function to check if a node is an Elepower user
local function is_elepower_user(node_name)
    return elepower_users[node_name] ~= nil
end

-- Function to check if a node is connected to an Elepower component
local function is_connected_to_elepower_user(pos)
    -- Define the positions of the neighboring nodes
    local neighbors = {
        {x = pos.x - 1, y = pos.y, z = pos.z},
        {x = pos.x + 1, y = pos.y, z = pos.z},
        {x = pos.x, y = pos.y - 1, z = pos.z},
        {x = pos.x, y = pos.y + 1, z = pos.z},
        {x = pos.x, y = pos.y, z = pos.z - 1},
        {x = pos.x, y = pos.y, z = pos.z + 1},
    }

    -- Check each neighboring node
    for _, neighbor in ipairs(neighbors) do
        local node = minetest.get_node(neighbor)
        if is_elepower_user(node.name) then
            return true
        end
    end

    -- No neighboring Elepower users were found
    return false
end

local elepower_producers = {
	["technic_elepower_compat:power_converter"] = true,
	["elepower_solar:solar_generator"] = true,
	["elepower_dynamics:conduit"] = true,
	["elepower_dynamics:conduit_wall"] = true,
	["elepower_dynamics:conduit_dirt_with_grass"] = true,
	["elepower_dynamics:conduit_dirt_with_dry_grass"] = true,
	["elepower_dynamics:conduit_stone_block"] = true,
	["elepower_dynamics:conduit_stone_block_desert"] = true,
	["elepower_lighting:conduit_iron_thin"] = true,
	["elepower_lighting:conduit_iron_thick"] = true,
	["elepower_lighting:conduit_steel_thin"] = true,
	["elepower_lighting:conduit_steel_thick"] = true,
	["elepower_lighting:conduit_gold_thin"] = true,
	["elepower_lighting:conduit_gold_thick"] = true,
	["elepower_lighting:conduit_wood_thin"] = true,
	["elepower_lighting:conduit_wood_thick"] = true,
}

-- Function to check if a node is an Elepower producer
local function is_elepower_producer(node_name)
    return elepower_producers[node_name] ~= nil
end

-- Function to check if a node is connected to an Elepower producer
local function is_connected_to_elepower_producer(pos)
    -- Define the positions of the neighboring nodes
    local neighbors = {
        {x = pos.x - 1, y = pos.y, z = pos.z},
        {x = pos.x + 1, y = pos.y, z = pos.z},
        {x = pos.x, y = pos.y - 1, z = pos.z},
        {x = pos.x, y = pos.y + 1, z = pos.z},
        {x = pos.x, y = pos.y, z = pos.z - 1},
        {x = pos.x, y = pos.y, z = pos.z + 1},
    }

    -- Check each neighboring node
    for _, neighbor in ipairs(neighbors) do
        local node = minetest.get_node(neighbor)
        if is_elepower_producer(node.name) then
            return true
        end
    end

    -- No neighboring Elepower producers were found
    return false
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "technic_elepower_compat:power_converter" then
        -- If the formname does not match, do nothing
        return
    end

    -- Get the position of the node that the player was interacting with
    local pos = node_positions[player:get_player_name()]

    -- Get the metadata of the node
    local meta = minetest.get_meta(pos)

    -- Check which button was pressed and update the metadata accordingly
    if fields.toggle_direction then
        local current_direction = meta:get_string("conversion_direction")
        if current_direction == "technic_to_elepower" then
            meta:set_string("conversion_direction", "elepower_to_technic")
            minetest.chat_send_player(player:get_player_name(), "Power converter conversion direction set to elepower_to_technic.")
        else
            meta:set_string("conversion_direction", "technic_to_elepower")
            minetest.chat_send_player(player:get_player_name(), "Power converter conversion direction set to technic_to_elepower.")
        end
    elseif fields.toggle_on_off then
        local current_state = meta:get_string("state")
        if current_state == "on" then
            meta:set_string("state", "off")
            minetest.chat_send_player(player:get_player_name(), "Power converter was turned off.")
        else
            meta:set_string("state", "on")
            minetest.chat_send_player(player:get_player_name(), "Power converter was turned on.")
        end
    elseif fields.set_en_input then
        meta:set_string("en_input", fields.en_input)
        -- Send a chat message to the player
        minetest.chat_send_player(player:get_player_name(), "Power converter Energy Input set to " .. fields.en_input .. ".")
    end
end)

function get_formspec(pow_buffer)
    return "size[5,4]" ..
        "label[0,0;Storage: " .. pow_buffer.storage .. "/" .. pow_buffer.capacity .. "]" ..
        "label[0,1;Output: " .. pow_buffer.usage .. "]" ..
        "button[0,2;5,1;toggle;Toggle On/Off]"
end

local function run_conversion_logic(pos)
	is_converting = true
	
			local meta = minetest.get_meta(pos)
		local state = meta:get_string("state")
		local direction = meta:get_string("conversion_direction")
		local en_input_str = meta:get_string("en_input")
		local en_input = tonumber(en_input_str)
		local eu_input = meta:get_int("LV_EU_input")
		local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
		local inrush     = ele.helpers.get_node_property(meta, pos, "inrush")
		local storage    = meta:get_int("storage")
		local generation = ele.helpers.get_node_property(meta, pos, "usage")
		local is_enabled = state == "on"
		local pow_buffer = {capacity = capacity, storage = storage, usage = 0}
		local status = "Idle"

		local function set_infotext()
			meta:set_string("infotext", ("%s %s\n%s"):format("Power Converter", status, ele.capacity_text(capacity, pow_buffer.storage)))
		end
		
		if en_input == nil or en_input < 0 then
			en_input = 0
			meta:set_string("en_input", "0")
		end

		-- this is commented because it is a conversion limiter and I have it off right no
		--[[if en_input > 1000  then
			en_input = 1000
			meta:set_string("en_input", "1000")
		end ]]
	
		if is_enabled then
			pow_buffer.usage = generation
			pow_buffer.storage = pow_buffer.storage + pow_buffer.usage
			if pow_buffer.storage > capacity then
				pow_buffer.storage = capacity
			end
			status = "Active 0"
		end

		meta:set_string("formspec", get_formspec(pow_buffer))
		meta:set_string("infotext", ("%s %s\n%s"):format("Test Node", status, ele.capacity_text(capacity, pow_buffer.storage)))
		meta:set_int("storage", pow_buffer.storage)
		
		meta:set_string("infotext", ("%s %s\n%s"):format("Power Converter", status, ele.capacity_text(capacity, pow_buffer.storage)))
	

	if direction == "elepower_to_technic" then
		if is_connected_to_elepower_producer(pos) then
			if storage >=  2 * en_input and storage <= 10000 - en_input then
				meta:set_int("LV_EU_demand", 0)
				meta:set_int("output", 0) 
				meta:set_int("inrush", en_input)
				meta:set_int("usage", 1/2 * -en_input)
				meta:set_int("LV_EU_supply", en_input)
				status = "Active 1"
				set_infotext()
			elseif storage >= 10000 - en_input then
				meta:set_int("LV_EU_demand", 0)
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("inrush", 0)
				meta:set_int("output", 0) 
				meta:set_int("usage", -en_input)
				status = "Active 2"
				set_infotext()
			elseif storage < 2 * en_input then
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("usage", 0)
				meta:set_int("LV_EU_demand", 0)
				meta:set_int("output", 0)
				meta:set_int("inrush", en_input)
				mtatus = "Unpowered 3"
				set_infotext()
			end
		elseif is_connected_to_elepower_producer == false and is_converting == false then
			-- Storage hasn't changed, so we're not connected to an Elepower node
			meta:set_int("output", 0)
			meta:set_int("inrush", 0)
			meta:set_int("usage", 0)
			meta:set_int("LV_EU_supply", 0)
			meta:set_int("LV_EU_demand", 0)
			status = "has no elepower network 4"
			set_infotext()
		end
	elseif direction == "technic_to_elepower" then
		if is_connected_to_elepower_user(pos) then
			if storage >= 2 * en_input and storage <= 10000 - en_input then
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("inrush", 0)
				meta:set_int("LV_EU_demand", en_input)
				meta:set_int("usage", 0)
				meta:set_int("output", en_input)
				status = "Active 5"
				set_infotext()
			elseif storage >= 10000 - en_input then
				meta:set_int("usage", 0)
				meta:set_int("LV_EU_demand", 0)
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("inrush", 0)
				meta:set_int("output", en_input)
				status = "Active 6"
				set_infotext()
			elseif eu_input >= en_input then
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("LV_EU_demand", en_input)
				meta:set_int("usage", en_input)
				meta:set_int("inrush", 0)
				meta:set_int("output", en_input)
				status = "Active 7"
				set_infotext()
			elseif eu_input < en_input and storage < en_input then
				meta:set_int("output", 0)
				meta:set_int("inrush", 0)
				meta:set_int("usage", 0)
				meta:set_int("LV_EU_supply", 0)
				meta:set_int("LV_EU_demand", en_input)
				status = "Unpowered 8"
				set_infotext()
			end
		elseif is_connected_to_elepower_user == false and is_converting == false then
			meta:set_int("output", 0)
			meta:set_int("inrush", 0)
			meta:set_int("usage", 0)
			meta:set_int("LV_EU_supply", 0)
			meta:set_int("LV_EU_demand", 0)
			status = "has no elepower network 9"
			set_infotext()
		end
		if meta:get_int("LV_EU_demand") == 0 then
			meta:set_int("output", 0)
			meta:set_int("inrush", 0)
			meta:set_int("usage", 0)
		end
	end
	is_converting = false
end

ele.register_machine("technic_elepower_compat:power_converter", {
    description = "Power Converter",
    tiles = {"converter_top.png", "converter_bottom.png", "converter_side.png"},
    groups = {cracky=3, ele_machine = 1, ele_user = 1, ele_provider = 1, technic_machine=1, technic_lv=1},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Store the position of the node that the player is interacting with
        node_positions[clicker:get_player_name()] = pos

        -- Get the metadata of the node
        local meta = minetest.get_meta(pos)

        -- Create the formspec
        local formspec = "size[5,4]" ..
            "button[0.5,-0.1;4,1;toggle_direction;Toggle Conversion Direction]" ..
            "button[0.5,0.8;4,1;toggle_on_off;Toggle On/Off]" ..
            "field[0.79,2.65;4,1;en_input;Energy Input;" .. meta:get_string("en_input") .. "]" ..
            "button[0.5,3.15;4,1;set_en_input;Set EU Input]"

        -- Show the formspec to the player
        minetest.show_formspec(clicker:get_player_name(), "technic_elepower_compat:power_converter", formspec)
    end,
    on_construct = function(pos)
		is_converting = false
        local meta = minetest.get_meta(pos)
        -- initialize en_input, state, and conversion_direction to default values
        meta:set_string("en_input", "0")
        meta:set_string("state", "off")
        meta:set_string("conversion_direction", "technic_to_elepower")
        -- start the timer
        minetest.get_node_timer(pos):start(1.0)
	    meta:set_string("pos", minetest.pos_to_string(pos))
    end,

    ele_capacity = 8000,
    ele_usage = 0,
    ele_inrush = 0,
    ele_output = 0,
    connect_sides = {"right", "left", "back", "front", "bottom"},
    sounds = default.node_sound_metal_defaults(),
	
	after_place_node = function(pos)
        table.insert(node_positions, pos)
    end,
	
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local state = meta:get_string("state")
		local direction = meta:get_string("conversion_direction")
		local en_input_str = meta:get_string("en_input")
		local en_input = tonumber(en_input_str)
		local eu_input = meta:get_int("LV_EU_input")
		local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
		local inrush     = ele.helpers.get_node_property(meta, pos, "inrush")
		local storage    = meta:get_int("storage")
		local generation = ele.helpers.get_node_property(meta, pos, "usage")
		local is_enabled = state == "on"
		local pow_buffer = {capacity = capacity, storage = storage, usage = 0}
		local status = "Idle"

		local function set_infotext()
			meta:set_string("infotext", ("%s %s\n%s"):format("Power Converter", status, ele.capacity_text(capacity, pow_buffer.storage)))
		end
		
		if en_input == nil or en_input < 0 then
			en_input = 0
			meta:set_string("en_input", "0")
		end

		-- this is commented because it is a conversion limiter and is not currently ready to be used.
		--[[if en_input > 1000  then
			en_input = 1000
			meta:set_string("en_input", "1000")
		end ]]
	
		if is_enabled then
			pow_buffer.usage = generation
			pow_buffer.storage = pow_buffer.storage + pow_buffer.usage
			if pow_buffer.storage > capacity then
				pow_buffer.storage = capacity
			end
			status = "Active 0"
		end

		meta:set_string("formspec", get_formspec(pow_buffer))
		meta:set_string("infotext", ("%s %s\n%s"):format("Test Node", status, ele.capacity_text(capacity, pow_buffer.storage)))
		meta:set_int("storage", pow_buffer.storage)
		
		meta:set_string("infotext", ("%s %s\n%s"):format("Power Converter", status, ele.capacity_text(capacity, pow_buffer.storage)))
	
		if state == "on" and is_converting == false then
			run_conversion_logic(pos)
		elseif state == "off" and is_converting == false then
			meta:set_int("output", 0)
			meta:set_int("inrush", 0)
			meta:set_int("usage", 0)
			meta:set_int("LV_EU_supply", 0)
			meta:set_int("LV_EU_demand", 0)
			status = "Off 10"
			set_infotext()
		elseif is_converting == true then
			return false
		end
		
		local timer = minetest.get_node_timer(pos)
        timer:start(1.0)
	end,
})

technic.register_machine("LV", "technic_elepower_compat:power_converter", technic.producer_receiver)

minetest.register_craft({
    output = "technic_elepower_compat:power_converter",
    recipe = {
        {"group:battery", "elepower_dynamics:conduit", "group:battery"},
        {"elepower_dynamics:wound_copper_coil", "technic:supply_converter", "elepower_dynamics:wound_copper_coil"},
        {"group:battery", "elepower_dynamics:conduit", "group:battery"}
    }
})
