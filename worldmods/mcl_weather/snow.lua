mcl_weather.snow = {}

-- ============================================================
-- SNOW NODE DATA
-- ============================================================

local snowdata = {
	["default:snow"] = "mcl_weather:snow2",
	["mcl_weather:snow2"] = "mcl_weather:snow3",
	["mcl_weather:snow3"] = "mcl_weather:snow4",
	["mcl_weather:snow4"] = "mcl_weather:snow5",
	["mcl_weather:snow5"] = "mcl_weather:snow6",
	["mcl_weather:snow6"] = "mcl_weather:snow7",
	["mcl_weather:snow7"] = "mcl_weather:snow8",
	["mcl_weather:snow8"] = "default:snowblock"
}

-- ============================================================
-- SNOW NODEBOX
-- ============================================================

local function get_snow_nodebox_collisionbox(layer)
	local height = layer / 8 - 0.5
	local walkheight = (height + 0.5) / 2 - 0.5

	local node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, height, 0.5},
		},
	}

	local collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, walkheight, 0.5},
		},
	}

	return node_box, collision_box
end

-- ============================================================
-- SNOW NODE OVERRIDE
-- ============================================================

local snowdef =
	table.copy(core.registered_nodes["default:snow"])

snowdef.groups.snow_pilable = 1

-- First snow layer.
local nodebox1, collisionbox1 =
	get_snow_nodebox_collisionbox(1)

core.override_item("default:snow", {
	node_box = nodebox1,

	collision_box = collisionbox1,

	selection_box = nodebox1,

	on_place = function(
		itemstack,
		placer,
		pointed_thing
	)
		if pointed_thing
			and pointed_thing.type == "node"
			and placer
		then
			local playername =
				placer:get_player_name()
				or "idk someone"

			local under = pointed_thing.under

			if under
				and not core.is_protected(
					under,
					playername
				)
			then
				local name =
					core.get_node(under).name

				if name then
					local nextnode =
						snowdata[name]

					if nextnode then
						core.set_node(
							under,
							{name = nextnode}
						)

						if not core.is_creative_enabled(
							playername
						)
						then
							itemstack:take_item()
						end

						return itemstack
					end
				end
			end
		end

		core.item_place(
			itemstack,
			placer,
			pointed_thing
		)

		return itemstack
	end,

	groups = snowdef.groups,
})

-- ============================================================
-- REGISTER SNOW LAYERS
-- ============================================================

for i = 2, 8 do
	local name =
		"mcl_weather:snow" .. i

	local nodebox, collisionbox =
		get_snow_nodebox_collisionbox(i)

	snowdef.node_box = nodebox
	snowdef.collision_box = collisionbox
	snowdef.selection_box = nodebox
	snowdef.drop = "default:snow " .. i

	core.register_node(name, snowdef)
end

-- ============================================================
-- SNOW PARTICLES
-- ============================================================

local PARTICLES_COUNT_SNOW = 100

mcl_weather.snow.init_done = false

local psdef = {
	amount = PARTICLES_COUNT_SNOW,

	time = 0,

	minpos = vector.new(-25, 20, -25),
	maxpos = vector.new(25, 25, 25),

	minvel = vector.new(-0.2, -1, -0.2),
	maxvel = vector.new(0.2, -4, 0.2),

	minacc = vector.new(0, -1, 0),
	maxacc = vector.new(0, -4, 0),

	minexptime = 3,
	maxexptime = 5,

	minsize = 2,
	maxsize = 5,

	collisiondetection = true,
	collision_removal = true,

	object_collision = true,
	vertical = true,

	glow = 1
}

-- ============================================================
-- SNOW CHECK
-- ============================================================

function mcl_weather.has_snow(pos)
	if not mcl_weather.can_see_outdoors(pos) then
		return false
	end

	local name =
		mcl_weather.get_biome_name(pos)

	return name
		and mcl_weather.is_position_cold(
			name,
			pos
		)
end

-- ============================================================
-- SNOW SKY
-- ============================================================

function mcl_weather.snow.set_sky_box()
	mcl_weather.skycolor.add_layer(
		"weather-pack-snow-sky",
		{
			{r = 0, g = 0, b = 0},
			{r = 85, g = 86, b = 86},
			{r = 135, g = 135, b = 135},
			{r = 85, g = 86, b = 86},
			{r = 0, g = 0, b = 0}
		}
	)

	mcl_weather.skycolor.active = true

	-- IMPORTANT:
	-- Do NOT call player:set_clouds() here.
	-- rain.lua owns global cloud state.
end

-- ============================================================
-- CLEAR SNOW
-- ============================================================

function mcl_weather.snow.clear()
	mcl_weather.skycolor.remove_layer(
		"weather-pack-snow-sky"
	)

	mcl_weather.snow.init_done = false

	mcl_weather.remove_all_spawners()
end

-- ============================================================
-- SNOW FOR ONE PLAYER
-- ============================================================

local function make_weather_for_player(player)
	mcl_weather.rain.remove_sound(player)

	mcl_weather.snow.add_player(player)

	-- Only initialize the snow sky once.
	if not mcl_weather.snow.init_done then
		mcl_weather.snow.set_sky_box()
		mcl_weather.snow.init_done = true
	end
end

mcl_weather.snow.make_weather_for_player =
	make_weather_for_player

-- ============================================================
-- SNOW WEATHER
-- ============================================================

function mcl_weather.snow.make_weather()
	for _, player in ipairs(
		core.get_connected_players()
	) do
		local pos = player:get_pos()

		if pos and mcl_weather.has_snow(pos) then
			make_weather_for_player(player)
		end
	end
end

function mcl_weather.snow.step(_)
	mcl_weather.snow.make_weather()
end

-- ============================================================
-- SNOW PLAYER PARTICLES
-- ============================================================

function mcl_weather.snow.add_player(player)
	for i = 1, 2 do
		psdef.texture =
			"weather_pack_snow_snowflake"
			.. i
			.. ".png"

		mcl_weather.add_spawner_player(
			player,
			"snow" .. i,
			psdef
		)
	end
end

-- ============================================================
-- SNOW ABM
-- ============================================================

if mcl_weather.allow_abm then
	core.register_abm({
		label = "Snow piles up",

		nodenames = {
			"group:opaque",
			"group:leaves",
			"group:snow_cover",
			"group:soil",
			"group:snow_pilable"
		},

		neighbors = {"air"},

		interval = 100,
		chance = 4,

		min_y = -30,

		action = function(pos, node)
			local abovehalf =
				vector.offset(pos, 0, 0.5, 0)

			if (
				mcl_weather.state ~= "rain"
				and mcl_weather.state ~= "thunder"
				and mcl_weather.state ~= "snow"
			)
				or mcl_weather.has_snow(pos) ~= true
			then
				return
			end

			local above =
				vector.offset(pos, 0, 1, 0)

			local above_node =
				core.get_node(above)

			if above_node.name == "air"
				and mcl_weather.is_outdoor(pos)
			then
				if snowdata[node.name] then
					core.set_node(
						pos,
						{
							name =
								snowdata[node.name]
						}
					)
				else
					core.set_node(
						above,
						{
							name =
								"mcl_weather:snow2"
						}
					)
				end
			end
		end,
	})
end