local modpath = core.get_modpath(core.get_current_modname())

mcl_weather.PARTICLES_COUNT_RAIN = 700
mcl_weather.PARTICLES_COUNT_THUNDER = 1300

mcl_weather.rain = {
	particles_count = mcl_weather.PARTICLES_COUNT_RAIN,
	extinguish_fire = true,
	raining = false,
	sky_last_update = -1,
	init_done = false,
	update_timer = 0,
	update_interval = 0.5,
	player_particles = {},
}

local update_sound = {}

-- ============================================================
-- CLOUD CONTROL
-- Clouds are controlled by GLOBAL weather state only.
-- ============================================================

local cloud_state = nil

local function set_weather_clouds(state)
	if cloud_state == state then
		return
	end

	cloud_state = state

	local settings

	if state == "thunder" then
		settings = {
			color = "#3D3D3FE8",
			density = 0.8,
		}
	elseif state == "snow" then
		settings = {
			color = "#ADADADE8",
			density = 0.8,
		}
	elseif state == "rain" then
		settings = {
			color = "#5D5D5FE8",
			density = 0.8,
		}
	else
		settings = {
			color = "#FFF0F0E5",
			density = 0.4,
		}
	end

	for _, player in ipairs(core.get_connected_players()) do
		player:set_clouds(settings)
	end
end

local function reset_cloud_state()
	cloud_state = nil
end

-- ============================================================
-- RAIN PARTICLES
-- ============================================================

local psdef = {
	amount = mcl_weather.rain.particles_count,
	time = 0,

	minpos = vector.new(-15, 20, -15),
	maxpos = vector.new(15, 25, 15),

	minvel = vector.new(0, -20, 0),
	maxvel = vector.new(0, -15, 0),

	minacc = vector.new(0, -0.8, 0),
	maxacc = vector.new(0, -0.8, 0),

	minexptime = 1,
	maxexptime = 4,

	minsize = 4,
	maxsize = 8,

	collisiondetection = true,
	collision_removal = true,

	vertical = true,
}

local textures = {
	"weather_pack_rain_raindrop_1.png",
	"weather_pack_rain_raindrop_2.png",
}

-- ============================================================
-- WEATHER CHECKS
-- ============================================================

function mcl_weather.is_exposed_to_rain(pos)
	if not mcl_weather.rain.raining then
		return false
	end

	local name = mcl_weather.get_biome_name(pos)

	return not mcl_weather.is_position_arid(name)
		and mcl_weather.is_outdoor(pos)
		and not mcl_weather.is_position_cold(name, pos)
end

function mcl_weather.has_rain(pos)
	if not pos then
		return false
	end

	local name = mcl_weather.get_biome_name(pos)

	return not mcl_weather.is_position_arid(name)
end

-- ============================================================
-- SOUND
-- ============================================================

function mcl_weather.rain.sound_handler(player)
	return core.sound_play("weather_rain", {
		to_player = player:get_player_name(),
		loop = true,
	})
end

-- ============================================================
-- SKY
-- ============================================================

function mcl_weather.rain.set_sky_box()
	if mcl_weather.state ~= "rain"
		and mcl_weather.state ~= "thunder"
	then
		return
	end

	mcl_weather.skycolor.add_layer(
		"weather-pack-rain-sky",
		{
			{r = 0, g = 0, b = 0},
			{r = 85, g = 86, b = 98},
			{r = 135, g = 135, b = 151},
			{r = 85, g = 86, b = 98},
			{r = 0, g = 0, b = 0}
		}
	)

	mcl_weather.skycolor.active = true

	if mcl_weather.state == "thunder" then
		set_weather_clouds("thunder")
	else
		set_weather_clouds("rain")
	end
end

-- ============================================================
-- RAIN PARTICLES
-- ============================================================

function mcl_weather.rain.add_rain_particles(player)
	local name = player:get_player_name()

	if mcl_weather.rain.player_particles[name] then
		return
	end

	mcl_weather.rain.player_particles[name] = true

	mcl_weather.rain.last_rp_count =
		mcl_weather.rain.particles_count

	local created_any = false

	for k, texture in pairs(textures) do
		psdef.texture = texture

		local created =
			mcl_weather.add_spawner_player(
				player,
				"rain" .. k,
				psdef
			)

		if created then
			created_any = true
		end
	end

	if created_any then
		update_sound[name] = true
	end
end

-- ============================================================
-- PLAYER
-- ============================================================

function mcl_weather.rain.add_player(player)
	local name = player:get_player_name()

	if mcl_weather.players[name] == nil then
		local player_meta = {}

		player_meta.origin_sky = {
			player:get_sky(true)
		}

		mcl_weather.players[name] = player_meta

		update_sound[name] = true
	end
end

function mcl_weather.rain.remove_player(player)
	local name = player:get_player_name()

	local player_meta = mcl_weather.players[name]

	if player_meta and player_meta.origin_sky then
		mcl_weather.players[name] = nil
		update_sound[name] = true
	end

	mcl_weather.rain.player_particles[name] = nil
end

-- ============================================================
-- SOUND UPDATE
-- ============================================================

function mcl_weather.rain.update_sound(player)
	local name = player:get_player_name()

	if not update_sound[name] then
		return
	end

	local player_meta = mcl_weather.players[name]

	if player_meta then
		if player_meta.sound_updated
			and player_meta.sound_updated + 5 > core.get_gametime()
		then
			return false
		end

		if player_meta.sound_handler then
			if mcl_weather.rain.last_rp_count == 0 then
				core.sound_fade(
					player_meta.sound_handler,
					-0.5,
					0.0
				)

				player_meta.sound_handler = nil
			end
		elseif mcl_weather.rain.last_rp_count > 0 then
			player_meta.sound_handler =
				mcl_weather.rain.sound_handler(player)
		end

		player_meta.sound_updated =
			core.get_gametime()
	end

	update_sound[name] = false
end

function mcl_weather.rain.remove_sound(player)
	local name = player:get_player_name()

	local player_meta = mcl_weather.players[name]

	if player_meta and player_meta.sound_handler then
		core.sound_fade(
			player_meta.sound_handler,
			-0.5,
			0.0
		)

		player_meta.sound_handler = nil
		player_meta.sound_updated = nil
	end
end

-- ============================================================
-- CLEAR
-- ============================================================

function mcl_weather.rain.clear()
	mcl_weather.rain.raining = false
	mcl_weather.rain.sky_last_update = -1
	mcl_weather.rain.init_done = false
	mcl_weather.rain.update_timer = 0

	mcl_weather.rain.set_particles_mode("rain")

	mcl_weather.skycolor.remove_layer(
		"weather-pack-rain-sky"
	)

	mcl_weather.skycolor.force_update = true

	for _, player in ipairs(core.get_connected_players()) do
		mcl_weather.rain.remove_sound(player)
		mcl_weather.rain.remove_player(player)
		mcl_weather.remove_spawners_player(player)
	end

	mcl_weather.rain.player_particles = {}

	-- Restore normal clouds ONCE.
	set_weather_clouds("none")

	-- Allow the next weather state to set clouds.
	reset_cloud_state()
end

-- ============================================================
-- STEP
-- ============================================================

function mcl_weather.rain.step(dtime)
	mcl_weather.rain.update_timer =
		mcl_weather.rain.update_timer + dtime

	if mcl_weather.rain.update_timer
		< mcl_weather.rain.update_interval
	then
		return
	end

	mcl_weather.rain.update_timer = 0

	mcl_weather.rain.make_weather()
end

-- ============================================================
-- WEATHER
-- ============================================================

function mcl_weather.rain.make_weather()
	if not mcl_weather.rain.init_done then
		mcl_weather.rain.raining = true

		mcl_weather.rain.set_sky_box()

		mcl_weather.rain.set_particles_mode(
			mcl_weather.mode
		)

		mcl_weather.rain.init_done = true
	end

	for _, player in ipairs(core.get_connected_players()) do
		local pos = player:get_pos()

		if pos then
			local underwater =
				mcl_weather.is_underwater(player)

			local has_rain =
				mcl_weather.has_rain(pos)

			local underground =
				mcl_weather.is_underground(pos)

			if underwater
				or not has_rain
				or not underground
			then
				mcl_weather.rain.remove_sound(player)

				mcl_weather.remove_spawners_player(player)

				mcl_weather.rain.player_particles[
					player:get_player_name()
				] = nil
			else
				if mcl_weather.has_snow(pos) then
					mcl_weather.snow.make_weather_for_player(player)
				else
					mcl_weather.rain.add_player(player)

					mcl_weather.rain.add_rain_particles(
						player
					)

					mcl_weather.rain.update_sound(player)
				end
			end
		end
	end
end

-- ============================================================
-- PARTICLE MODE
-- ============================================================

function mcl_weather.rain.set_particles_mode(mode)
	if mode == "thunder" then
		psdef.amount =
			mcl_weather.PARTICLES_COUNT_THUNDER

		mcl_weather.rain.particles_count =
			mcl_weather.PARTICLES_COUNT_THUNDER
	else
		psdef.amount =
			mcl_weather.PARTICLES_COUNT_RAIN

		mcl_weather.rain.particles_count =
			mcl_weather.PARTICLES_COUNT_RAIN
	end

	mcl_weather.rain.player_particles = {}
end

-- ============================================================
-- ABM
-- ============================================================

if mcl_weather.allow_abm then
	core.register_abm({
		label = "Rain extinguishes fire",

		nodenames = {
			"fire:basic_flame",
			"fire:permanent_flame"
		},

		interval = 2.0,
		chance = 2,

		action = function(pos)
			if mcl_weather.rain.raining
				and mcl_weather.rain.extinguish_fire
			then
				local around = {
					{x = 0, y = 0, z = 0},
					{x = -1, y = 0, z = 0},
					{x = 1, y = 0, z = 0},
					{x = 0, y = 0, z = -1},
					{x = 0, y = 0, z = 1},
				}

				for a = 1, #around do
					local apos =
						vector.add(pos, around[a])

					if mcl_weather.is_outdoor(apos)
						and mcl_weather.has_rain(apos)
					then
						core.remove_node(pos)

						core.sound_play(
							"fire_extinguish_flame",
							{
								pos = pos,
								max_hear_distance = 8,
								gain = 0.1
							},
							true
						)

						return
					end
				end
			end
		end,
	})
end

-- ============================================================
-- REGISTER RAIN
-- ============================================================

if mcl_weather.reg_weathers.rain == nil then
	mcl_weather.reg_weathers.rain = {
		clear = mcl_weather.rain.clear,

		light_factor = 0.6,

		min_duration = 200,
		max_duration = 300,

		transitions = {
			[90] = "none",
			[97] = "rain",
			[100] = "thunder",
		}
	}
end

-- ============================================================
-- PLAYER JOIN
-- ============================================================

core.register_on_joinplayer(function(player)
	reset_cloud_state()

	if mcl_weather.state == "rain" then
		set_weather_clouds("rain")
	elseif mcl_weather.state == "thunder" then
		set_weather_clouds("thunder")
	elseif mcl_weather.state == "snow" then
		set_weather_clouds("snow")
	else
		set_weather_clouds("none")
	end
end)

core.register_on_leaveplayer(function(player)
	mcl_weather.rain.player_particles[
		player:get_player_name()
	] = nil

	update_sound[
		player:get_player_name()
	] = nil
end)