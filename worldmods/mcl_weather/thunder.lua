mcl_weather.thunder = {
	next_strike = 0,
	min_delay = 3,
	max_delay = 12,
	init_done = false,
}

-- ============================================================
-- LIGHTNING CHECK
-- ============================================================

mcl_lightning.register_on_strike(function(pos, pos2, objects)
	if not mcl_weather.has_rain(pos) then
		return nil, true
	end
end)

-- ============================================================
-- THUNDER STEP
-- ============================================================

function mcl_weather.thunder.step(_)
	-- Use thunder particle count.
	mcl_weather.rain.set_particles_mode("thunder")

	-- Rain handles rain/thunder particles.
	mcl_weather.rain.make_weather()

	-- Add thunder sky layer only once.
	if mcl_weather.thunder.init_done == false then
		mcl_weather.skycolor.add_layer(
			"weather-pack-thunder-sky",
			{
				{r = 0, g = 0, b = 0},
				{r = 40, g = 40, b = 40},
				{r = 85, g = 86, b = 86},
				{r = 40, g = 40, b = 40},
				{r = 0, g = 0, b = 0},
			}
		)

		mcl_weather.skycolor.active = true

		-- Clouds are controlled by rain.lua's global
		-- weather cloud controller.
		mcl_weather.thunder.init_done = true
	end

	-- Lightning strike timer.
	if mcl_weather.thunder.next_strike
		<= core.get_gametime()
	then
		mcl_lightning.strike()

		local delay = math.random(
			mcl_weather.thunder.min_delay,
			mcl_weather.thunder.max_delay
		)

		mcl_weather.thunder.next_strike =
			core.get_gametime() + delay
	end
end

-- ============================================================
-- CLEAR
-- ============================================================

function mcl_weather.thunder.clear()
	mcl_weather.rain.clear()

	mcl_weather.skycolor.remove_layer(
		"weather-pack-thunder-sky"
	)

	mcl_weather.skycolor.remove_layer(
		"lightning"
	)

	mcl_weather.thunder.init_done = false
end

-- ============================================================
-- REGISTER THUNDERSTORM
-- ============================================================

if mcl_weather.reg_weathers.thunder == nil then
	mcl_weather.reg_weathers.thunder = {
		clear = mcl_weather.thunder.clear,

		light_factor = 0.33333,

		-- 10 min - 20 min
		min_duration = 300,
		max_duration = 540,

		transitions = {
			[100] = "rain",
		}
	}
end