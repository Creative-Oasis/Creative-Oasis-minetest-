-- ==========================================
-- Helper to clamp number values
-- ==========================================
local function clamp_and_save(meta, key, value, minv, maxv)
	if type(value) ~= "number" then return end
	if value < minv then value = minv end
	if value > maxv then value = maxv end
	meta:set_string(key, tostring(value))
end

-- Formspec generator
local function make_formspec(meta)
	meta:set_string("formspec", "field[time;time;${time}]")
end

-- Timer activation
local timegate_get_output_rules = function(node)
	local rules = {{x = 0, y = 0, z = 1}}
	for _ = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local timegate_get_input_rules = function(node)
	local rules = {{x = 0, y = 0, z = -1}}
	for _ = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local function timegate_activate(pos, node)
	local meta = minetest.get_meta(pos)
	local time = tonumber(meta:get_string("time"))
	if not time then return end

	node.name = "moremesecons_timegate:timegate_on"
	minetest.swap_node(pos, node)
	mesecon.receptor_on(pos)
	minetest.after(time, function()
		local node = minetest.get_node(pos)
		if node.name == "moremesecons_timegate:timegate_on" then
			mesecon.receptor_off(pos)
			node.name = "moremesecons_timegate:timegate_off"
			minetest.swap_node(pos, node)
		end
	end)
end

-- Nodebox definition
local boxes = {
	{ -6/16, -8/16, -6/16, 6/16, -7/16, 6/16 },
	{ -2/16, -7/16, -4/16, 2/16, -26/64, -3/16 },
	{ -3/16, -7/16, -3/16, 3/16, -26/64, -2/16 },
	{ -4/16, -7/16, -2/16, 4/16, -26/64, 2/16 },
	{ -3/16, -7/16, 2/16, 3/16, -26/64, 3/16 },
	{ -2/16, -7/16, 3/16, 2/16, -26/64, 4/16 },
	{ -6/16, -7/16, -6/16, -4/16, -27/64, -4/16 },
	{ -8/16, -8/16, -1/16, -6/16, -7/16, 1/16 },
	{ 6/16, -8/16, -1/16, 8/16, -7/16, 1/16 }
}

local use_texture_alpha
if minetest.features.use_texture_alpha_string_modes then
	use_texture_alpha = "opaque"
end

-- Safe on_receive_fields
local function timegate_on_receive_fields(pos, _, fields, player)
	if not fields.time or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = minetest.get_meta(pos)
	local time = tonumber(fields.time)
	if time then
		clamp_and_save(meta, "time", time, 0.1, 999) -- min 0.1s, max 999s
	end
end

-- Register node
mesecon.register_node("moremesecons_timegate:timegate", {
	description = "Time Gate",
	drawtype = "nodebox",
	inventory_image = "moremesecons_timegate_off.png",
	wield_image = "moremesecons_timegate_off.png",
	walkable = true,
	selection_box = { type="fixed", fixed={ -8/16,-8/16,-8/16, 8/16,-6/16,8/16 } },
	node_box = { type="fixed", fixed=boxes },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("time", "1") -- default 1s
		make_formspec(meta)
	end,
	on_receive_fields = timegate_on_receive_fields,
},{
	tiles = {
		"moremesecons_timegate_off.png",
		"moremesecons_timegate_bottom.png",
		"moremesecons_timegate_ends_off.png",
		"moremesecons_timegate_ends_off.png",
		"moremesecons_timegate_sides_off.png",
		"moremesecons_timegate_sides_off.png"
	},
	use_texture_alpha = use_texture_alpha,
	groups = {bendy=2,snappy=1,dig_immediate=2},
	mesecons = {
		receptor = { state = mesecon.state.off, rules = timegate_get_output_rules },
		effector = { rules = timegate_get_input_rules, action_on = timegate_activate }
	}
},{
	tiles = {
		"moremesecons_timegate_on.png",
		"moremesecons_timegate_bottom.png",
		"moremesecons_timegate_ends_on.png",
		"moremesecons_timegate_ends_on.png",
		"moremesecons_timegate_sides_on.png",
		"moremesecons_timegate_sides_on.png"
	},
	use_texture_alpha = use_texture_alpha,
	groups = {bendy=2,snappy=1,dig_immediate=2, not_in_creative_inventory=1},
	mesecons = {
		receptor = { state = mesecon.state.on, rules = timegate_get_output_rules },
		effector = { rules = timegate_get_input_rules }
	}
})

-- Craft
minetest.register_craft({
	output = "moremesecons_timegate:timegate_off 2",
	recipe = {
		{"group:mesecon_conductor_craftable", "mesecons_delayer:delayer_off_1", "group:mesecon_conductor_craftable"},
		{"default:wood","default:wood", "default:wood"}
	}
})

-- Aliases for old versions
minetest.register_alias("moremesecons_temporarygate:temporarygate_off", "moremesecons_timegate:timegate_off")
minetest.register_alias("moremesecons_temporarygate:temporarygate_on", "moremesecons_timegate:timegate_on")
