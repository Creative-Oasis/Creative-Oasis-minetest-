
local S = core.get_translator(core.get_current_modname())

-- Weather states
mcl_weather.miny = -10

function mcl_weather.is_underground(pos)
	return pos.y >= mcl_weather.miny
end

mcl_weather.state = "none"
mcl_weather.players = {}

-- Weather check interval
mcl_weather.check_interval = 5

-- Default weather duration (seconds)
mcl_weather.min_duration = 300
mcl_weather.max_duration = 420

mcl_weather.end_time = nil
mcl_weather.reg_weathers = {}
mcl_weather.allow_abm = true

-- Default clear weather
mcl_weather.reg_weathers["none"] = {
	min_duration = mcl_weather.min_duration,
	max_duration = mcl_weather.max_duration,
	light_factor = nil,

	-- 5% chance to start rain when clear weather ends
	transitions = {
		[5] = "rain",
	},

	clear = function() end,
}

local storage = core.get_mod_storage()

-- Save weather state
local function save_weather()
	if not mcl_weather.end_time then
		return
	end

	storage:set_string("mcl_weather_state", mcl_weather.state)
	storage:set_int("mcl_weather_end_time", mcl_weather.end_time)

	core.log("verbose",
		"[mcl_weather] Weather data saved: state="
		.. mcl_weather.state
		.. " end_time="
		.. mcl_weather.end_time
	)
end

core.register_on_shutdown(save_weather)

-- Particle spawners
local particlespawners = {}

function mcl_weather.add_spawner_player(pl, id, ps)
	local name = pl:get_player_name()
	local meta = pl:get_meta()

	if meta:get_int("mcl_weather") == 1 then
		return false
	end

	if not particlespawners[name] then
		particlespawners[name] = {}
	end

	if not particlespawners[name][id] then
		mcl_weather.remove_spawners_player(pl)
		particlespawners[name] = {}

		ps.playername = name
		ps.attached = pl

		particlespawners[name][id] = core.add_particlespawner(ps)
		return particlespawners[name][id]
	end
end

function mcl_weather.remove_spawners_player(pl)
	local name = pl:get_player_name()

	if not particlespawners[name] then
		return
	end

	for _, v in pairs(particlespawners[name]) do
		core.delete_particlespawner(v)
	end

	particlespawners[name] = nil
	return true
end

function mcl_weather.remove_all_spawners()
	for _, pl in ipairs(core.get_connected_players()) do
		mcl_weather.remove_spawners_player(pl)
	end
end

-- Calculate weather end time
function mcl_weather.get_rand_end_time(min_duration, max_duration)
	local r

	if min_duration and max_duration then
		r = math.random(min_duration, max_duration)
	else
		r = math.random(
			mcl_weather.min_duration,
			mcl_weather.max_duration
		)
	end

	return core.get_gametime() + r
end

function mcl_weather.get_current_light_factor()
	if mcl_weather.state == "none" then
		return nil
	end

	local weather = mcl_weather.reg_weathers[mcl_weather.state]
	return weather and weather.light_factor
end

-- Check if position is outdoors
function mcl_weather.is_outdoor(pos)
	local cpos = vector.offset(pos, 0, 1, 0)
	return core.get_natural_light(cpos, 0.5) == 15
end

function mcl_weather.can_see_outdoors(pos)
	local light = core.get_natural_light(pos, 0.5)
	return light ~= nil and light >= 1
end

local floor = math.floor

-- Check if player is underwater
function mcl_weather.is_underwater(player)
	local ppos = player:get_pos()
	local offset = player:get_eye_offset()

	local player_eye_pos = {
		x = floor(ppos.x + offset.x + 0.5),
		y = floor(ppos.y + offset.y + 2.0),
		z = floor(ppos.z + offset.z + 0.5),
	}

	local node_level = core.get_node_level(player_eye_pos)
	return node_level == 8 or node_level == 7
end

-- Periodically check whether the weather should change
local t = 0

core.register_globalstep(function(dtime)
	t = t + dtime

	if t < mcl_weather.check_interval then
		return
	end

	t = 0

	if mcl_weather.end_time == nil then
		mcl_weather.end_time = mcl_weather.get_rand_end_time()
	end

	if mcl_weather.end_time <= core.get_gametime() then
		local changeWeather = core.settings:get_bool("mcl_doWeatherCycle")

		if changeWeather == nil then
			changeWeather = true
		end

		if changeWeather then
			mcl_weather.set_random_weather(
				mcl_weather.state,
				mcl_weather.reg_weathers[mcl_weather.state]
			)
		else
			mcl_weather.end_time = mcl_weather.get_rand_end_time()
		end
	end
end)

-- Set random weather using sorted transition thresholds.
-- A transition [5] = "rain" means a 5% chance of rain;
-- the remaining rolls keep the current weather.
function mcl_weather.set_random_weather(_, weather_meta)
	if not weather_meta or not weather_meta.transitions then
		return
	end

	local transitions = weather_meta.transitions
	local thresholds = {}

	for threshold in pairs(transitions) do
		thresholds[#thresholds + 1] = threshold
	end

	table.sort(thresholds)

	local random_roll = math.random(1, 100)

	for _, threshold in ipairs(thresholds) do
		if random_roll <= threshold then
			mcl_weather.change_weather(transitions[threshold])
			return
		end
	end

	-- No transition selected: keep the current weather
	-- and schedule its next duration.
	local current_weather = mcl_weather.reg_weathers[mcl_weather.state]

	if current_weather then
		mcl_weather.end_time = mcl_weather.get_rand_end_time(
			current_weather.min_duration,
			current_weather.max_duration
		)
		save_weather()
	end
end

-- Change weather
function mcl_weather.change_weather(new_weather, explicit_end_time, changer_name)
	changer_name = changer_name
		or (debug.getinfo(2) and debug.getinfo(2).name)
		or "unknown"

	if not mcl_weather.reg_weathers
		or not mcl_weather.reg_weathers[new_weather] then
		return false
	end

	if mcl_weather.state and mcl_weather.reg_weathers[mcl_weather.state] then
		mcl_weather.reg_weathers[mcl_weather.state].clear()
	end

	local old_weather = mcl_weather.state
	mcl_weather.state = new_weather

	if old_weather == "none" then
		old_weather = "clear"
	end

	local log_weather = new_weather
	if log_weather == "none" then
		log_weather = "clear"
	end

	core.log("info",
		"[mcl_weather] " .. changer_name
		.. " changed the weather from " .. old_weather
		.. " to " .. log_weather
	)

	local weather_meta = mcl_weather.reg_weathers[mcl_weather.state]

	if explicit_end_time then
		mcl_weather.end_time = explicit_end_time
	else
		mcl_weather.end_time = mcl_weather.get_rand_end_time(
			weather_meta.min_duration,
			weather_meta.max_duration
		)
	end

	core.after(0, mcl_weather.skycolor.update_sky_color)
	save_weather()

	return true
end

function mcl_weather.get_weather()
	return mcl_weather.state
end

-- Weather privilege
core.register_privilege("weather_manager", {
	description = S("Gives ability to control weather"),
	give_to_singleplayer = false,
})

-- Weather command
core.register_chatcommand("weather", {
	params = "(clear | rain | thunder | snow) [<duration>]",
	description = S("Changes the weather to the specified parameter."),
	privs = {weather_manager = true},

	func = function(name, param)
		if param == "" then
			return false, S("Error: No weather specified.")
		end

		local new_weather, duration_text = string.match(param, "(%w+) ?(%d*)")

		if not new_weather then
			return false, S("Error: Invalid parameters.")
		end

		if new_weather == "clear" then
			new_weather = "none"
		end

		local end_time

		if duration_text and duration_text ~= "" then
			local duration = tonumber(duration_text)

			if not duration or duration < 1 then
				return false, S("Error: Duration must be at least 1 second.")
			end

			end_time = core.get_gametime() + duration
		end

		if mcl_weather.change_weather(new_weather, end_time, name) then
			return true
		end

		return false, S("Error: Invalid weather specified.")
	end,
})

-- Toggle downfall
core.register_chatcommand("toggledownfall", {
	params = "",
	description = S("Toggles between clear weather and rain, thunder, or snow."),
	privs = {weather_manager = true},

	func = function(name)
		if mcl_weather.state ~= "none" then
			return mcl_weather.change_weather("none", nil, name)
		end

		local choices = {}

		for _, weather in ipairs({"rain", "thunder", "snow"}) do
			if mcl_weather.reg_weathers[weather] then
				choices[#choices + 1] = weather
			end
		end

		if #choices == 0 then
			return false, S("No other weather types are registered.")
		end

		local new_weather = choices[math.random(1, #choices)]
		return mcl_weather.change_weather(new_weather, nil, name)
	end,
})

-- Configuration for weather ABMs
local weather_allow_abm = core.settings:get_bool("weather_allow_abm")

if weather_allow_abm == false then
	mcl_weather.allow_abm = false
end

-- Load saved weather
local function load_weather()
	local weather = storage:get_string("mcl_weather_state")

	-- Handle older saved weather states
	if weather == "snow" and not mcl_weather.reg_weathers["snow"] then
		weather = "rain"
	end

	if weather ~= "" then
		if not mcl_weather.reg_weathers[weather] then
			weather = "none"
		end

		local saved_end_time = storage:get_int("mcl_weather_end_time")

		mcl_weather.state = weather
		mcl_weather.end_time = saved_end_time

		mcl_weather.change_weather(weather, saved_end_time)

		core.log("info", "[mcl_weather] Weather restored.")
	else
		core.log("info",
			"[mcl_weather] No weather data found. Starting with clear weather."
		)
	end
end

load_weather()

-- Toggle weather particles
core.register_chatcommand("toggle_weather_particles", {
	func = function(name)
		local player = core.get_player_by_name(name)

		if not player then
			return
		end

		local meta = player:get_meta()
		local setting = meta:get_int("mcl_weather")

		if setting == 1 then
			meta:set_int("mcl_weather", 0)
			return true, "Weather particles and sounds enabled"
		end

		meta:set_int("mcl_weather", 1)
		mcl_weather.remove_spawners_player(player)

		return true, "Weather particles and sounds disabled (mostly)"
	end,
})