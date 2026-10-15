-- ===============================
-- Helper to clamp number values
-- ===============================
local function clamp_and_save(meta, key, value, minv, maxv, formspec_func)
	if type(value) ~= "number" then return end
	if value < minv then value = minv end
	if value > maxv then value = maxv end
	meta:set_string(key, tostring(value))
	if formspec_func then
		meta:set_string("formspec", formspec_func(value))
	end
end

-- Timer toggle function
local toggle_timer = function(pos, restart)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() and not restart then
		timer:stop()
	else
		local meta = minetest.get_meta(pos)
		local interval = tonumber(meta:get_string("interval")) or 1
		local min_interval = moremesecons.setting("adjustable_blinky_plant", "min_interval", 0.5)
		if interval < min_interval then
			interval = min_interval
		end
		timer:start(interval)
	end
end

local on_timer = function(pos)
	if mesecon.flipstate(pos, minetest.get_node(pos)) == "on" then
		mesecon.receptor_on(pos)
	else
		mesecon.receptor_off(pos)
	end
	toggle_timer(pos, false)
end

-- Formspec generator function
local function make_formspec(interval)
	return "field[interval;interval;"..interval.."]"
end

-- Node registration
mesecon.register_node("moremesecons_adjustable_blinkyplant:adjustable_blinky_plant", {
	description="Adjustable Blinky Plant",
	drawtype = "plantlike",
	inventory_image = "moremesecons_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	on_timer = on_timer,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("interval", "1")
		meta:set_string("formspec", make_formspec(1))
		toggle_timer(pos, true)
	end,
	on_receive_fields = function(pos, _, fields, player)
		if not fields.interval then return end
		if minetest.is_protected(pos, player:get_player_name()) then return end

		local meta = minetest.get_meta(pos)
		local interval = tonumber(fields.interval)

		-- Clamp interval to min allowed
		local min_interval = moremesecons.setting("adjustable_blinky_plant", "min_interval", 0.5)
		clamp_and_save(meta, "interval", interval, min_interval, 999, make_formspec) -- 999 = max interval

		toggle_timer(pos, true)
	end,
},{
	tiles = {"moremesecons_blinky_plant_off.png"},
	groups = {dig_immediate=3},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	tiles = {"moremesecons_blinky_plant_off.png^moremesecons_blinky_plant_on.png"},
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	sunlight_propagates = true,
	mesecons = {receptor = { state = mesecon.state.on }},
})

-- Craft
minetest.register_craft({
	output = "moremesecons_adjustable_blinkyplant:adjustable_blinky_plant_off 1",
	recipe = {
		{"mesecons_blinkyplant:blinky_plant_off"},
		{"default:mese_crystal_fragment"},
	}
})
