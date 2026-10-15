local NIGHT_VISION_RATIO = 0.45
local S = core.get_translator(core.get_current_modname())

-- ============================================================
-- CACHE
-- ============================================================

local sky_cache = {}
local ratio_cache = {}
local celestial_cache = {}
local state_cache = {}

-- ============================================================
-- CACHE HELPERS
-- ============================================================

local function color_key(color)
	if color == nil then
		return "nil"
	end

	if type(color) == "string" then
		return color
	end

	if type(color) == "table" then
		return table.concat({
			tostring(color.r or 0),
			tostring(color.g or 0),
			tostring(color.b or 0),
			tostring(color.a or 255)
		}, ",")
	end

	return tostring(color)
end

local function sky_key(sc)
	if not sc then
		return "nil"
	end

	return table.concat({
		color_key(sc.day_sky),
		color_key(sc.day_horizon),
		color_key(sc.dawn_sky),
		color_key(sc.dawn_horizon),
		color_key(sc.night_sky),
		color_key(sc.night_horizon),
		color_key(sc.indoors),
		color_key(sc.fog_sun_tint),
		color_key(sc.fog_moon_tint),
		tostring(sc.fog_tint_type)
	}, "|")
end

local function clear_player_cache(player)
	if not player then
		return
	end

	local name = player:get_player_name()

	sky_cache[name] = nil
	ratio_cache[name] = nil
	celestial_cache[name] = nil
	state_cache[name] = nil
end

-- ============================================================
-- SKY CACHE
-- ============================================================

local function set_cached_sky(player, sky_def, force)
	if not player or not sky_def then
		return false
	end

	local name = player:get_player_name()

	local new_key = table.concat({
		tostring(sky_def.type or "regular"),
		sky_key(sky_def.sky_color)
	}, "||")

	if sky_cache[name] == new_key and not force then
		return false
	end

	player:set_sky(sky_def)

	sky_cache[name] = new_key

	return true
end

-- ============================================================
-- CELESTIAL CACHE
-- ============================================================

local function set_cached_celestial(player, visible, force)
	if not player then
		return
	end

	local name = player:get_player_name()

	local new_key =
		visible and "visible" or "hidden"

	-- Reapply these settings each update. Another mod or a skybox change
	-- may override celestial visibility while our cache still says "visible".
	player:set_sun({
		visible = visible,
		sunrise_visible = visible
	})

	player:set_moon({
		visible = visible
	})

	-- Use the engine's normal star settings.
	player:set_stars({
		visible = visible
	})

	celestial_cache[name] = new_key
end

-- ============================================================
-- DAY / NIGHT RATIO CACHE
-- ============================================================

local function set_cached_ratio(player, ratio)
	if not player then
		return
	end

	local meta = player:get_meta()

	local has_night_vision =
		meta:get_int("night_vision") == 1

	local arg

	if has_night_vision then
		if ratio == nil then
			arg = NIGHT_VISION_RATIO
		else
			arg = math.max(
				ratio,
				NIGHT_VISION_RATIO
			)
		end
	else
		arg = ratio
	end

	if arg ~= nil then
		arg = math.floor(arg * 100) / 100
	end

	local name = player:get_player_name()

	if ratio_cache[name] == arg then
		return
	end

	player:override_day_night_ratio(arg)

	ratio_cache[name] = arg
end

-- ============================================================
-- WEATHER DETECTION
-- ============================================================

local function get_weather_at_position(pos)
	if mcl_weather.state ~= "rain"
		and mcl_weather.state ~= "thunder"
	then
		return false
	end

	if not pos
		or pos.x == nil
		or pos.y == nil
		or pos.z == nil
	then
		return false
	end

	local ok_rain, has_rain =
		pcall(
			mcl_weather.has_rain,
			pos
		)

	if ok_rain and has_rain then
		return true
	end

	local ok_snow, has_snow =
		pcall(
			mcl_weather.has_snow,
			pos
		)

	if ok_snow and has_snow then
		return true
	end

	return false
end

-- ============================================================
-- WATER CHECK
-- ============================================================

local function get_water_node(pos)
	if not pos then
		return nil
	end

	return core.get_node_or_nil(
		vector.new(
			pos.x,
			pos.y + 1.5,
			pos.z
		)
	)
end

local function is_water_node(node)
	if not node then
		return false
	end

	return core.get_item_group(
		node.name,
		"water"
	) ~= 0
end

-- ============================================================
-- CLEAR SKY
-- ============================================================

function mcl_weather.set_sky_box_clear(
	player,
	sky,
	fog
)
	if not player then
		return
	end

	local pos = player:get_pos()

	if not pos then
		return
	end

	local sc = {
		day_sky = "#87CEEB",
		day_horizon = "#FFFFFF",

		dawn_sky = "#FFA07A",
		dawn_horizon = "#FFDAB9",

		night_sky = "#5B7DB8",
                night_horizon = "#8AADE0",

		indoors = "#C0D8FF",

		fog_sun_tint = "#ff5f33",
		fog_moon_tint = nil,
		fog_tint_type = "custom"
	}

	if sky then
		sc.day_sky = sky
		sc.dawn_sky = sky
	end

	if fog then
		sc.day_horizon = fog
		sc.dawn_horizon = fog
	end

	-- IMPORTANT:
	-- skycolor.lua does NOT control clouds.
	-- rain.lua owns global weather clouds.

	set_cached_sky(player, {
		type = "regular",
		sky_color = sc
	})
end

-- ============================================================
-- WEATHER SKY COLOR
-- ============================================================

function mcl_weather.set_sky_color(player, def)
	if not player or not def then
		return
	end

	local pos = player:get_pos()

	if not pos then
		return
	end

	-- IMPORTANT:
	-- skycolor.lua does NOT control clouds.

	set_cached_sky(player, {
		type = def.type or "regular",
		sky_color = def.sky_color
	})
end

-- ============================================================
-- COLOR HELPERS
-- ============================================================

local function get_both_colors(pos)
	return mcl_weather.get_sky_fog_colors(pos)
end

-- ============================================================
-- SKYCOLOR
-- ============================================================

mcl_weather.skycolor = {

	active = true,

	force_update = true,

	update_interval = 3,

	colors = {},

	min_val = 0,

	max_val = 1000,

	layer_names = {},

	-- ========================================================
	-- ADD LAYER
	-- ========================================================

	add_layer = function(
		layer_name,
		layer_color,
		_
	)

		mcl_weather.skycolor.colors[layer_name] =
			layer_color

		for _, name in ipairs(
			mcl_weather.skycolor.layer_names
		) do

			if name == layer_name then
				mcl_weather.skycolor.force_update =
					true

				return
			end
		end

		table.insert(
			mcl_weather.skycolor.layer_names,
			layer_name
		)

		mcl_weather.skycolor.force_update =
			true
	end,

	-- ========================================================
	-- CURRENT LAYER
	-- ========================================================

	current_layer_name = function()
		return mcl_weather.skycolor.layer_names[
			#mcl_weather.skycolor.layer_names
		]
	end,

	-- ========================================================
	-- RETRIEVE LAYER
	-- ========================================================

	retrieve_layer = function()
		local last_layer =
			mcl_weather.skycolor.current_layer_name()

		if not last_layer then
			return nil
		end

		return mcl_weather.skycolor.colors[
			last_layer
		]
	end,

	-- ========================================================
	-- REMOVE LAYER
	-- ========================================================

	remove_layer = function(layer_name)
		for k, name in ipairs(
			mcl_weather.skycolor.layer_names
		) do

			if name == layer_name then
				table.remove(
					mcl_weather.skycolor.layer_names,
					k
				)

				mcl_weather.skycolor.force_update =
					true

				return
			end
		end
	end,

	-- ========================================================
	-- OVERRIDE DAY / NIGHT RATIO
	-- ========================================================

	override_day_night_ratio = function(
		player,
		ratio
	)

		set_cached_ratio(
			player,
			ratio
		)
	end,

	-- ========================================================
	-- UPDATE SKY COLOR
	-- ========================================================

	update_sky_color = function(players)

		players =
			mcl_weather.skycolor.utils.get_players(
				players
			)

		local weather_state =
			mcl_weather.state

		for _, player in ipairs(players) do

			if player then

				local pos =
					player:get_pos()

				if pos then

					local name =
						player:get_player_name()

					-- ==========================================
					-- WATER
					-- ==========================================

					local check_node =
						get_water_node(pos)

					local checkname =
						check_node
						and check_node.name
						or ""

					local underwater =
						is_water_node(check_node)

					-- ==========================================
					-- UNDERWATER
					-- ==========================================

					if underwater and weather_state ~= "none" then

						local water_color =
							"#3F76E4"

						if checkname ==
							"mclx_core:river_water_source"
							or checkname ==
							"mclx_core:river_water_flowing"
						then
							water_color =
								"#0084FF"
						end

						local new_state =
							"water:"
							.. water_color

						if state_cache[name]
							~= new_state
						then

							set_cached_sky(
								player,
								{
									type = "regular",

									sky_color = {
										day_sky =
											water_color,

										day_horizon =
											water_color,

										dawn_sky =
											water_color,

										dawn_horizon =
											water_color,

										night_sky =
											water_color,

										night_horizon =
											water_color,

										indoors =
											water_color,

										fog_sun_tint =
											water_color,

										fog_moon_tint =
											water_color,

										fog_tint_type =
											"custom"
									}
								}
							)

							set_cached_celestial(
								player,
								false
							)

							set_cached_ratio(
								player,
								nil
							)

							state_cache[name] =
								new_state
						end

					-- ==========================================
					-- RAIN / THUNDER
					-- ==========================================

					elseif weather_state == "rain"
						or weather_state == "thunder"
					then

						local day_color =
							mcl_weather.skycolor
								.get_sky_layer_color(
									0.5
								)

						local dawn_color =
							mcl_weather.skycolor
								.get_sky_layer_color(
									0.75
								)

						local night_color =
							mcl_weather.skycolor
								.get_sky_layer_color(
									0
								)

						local new_state =
							weather_state
							.. ":"
							.. color_key(day_color)
							.. ":"
							.. color_key(dawn_color)
							.. ":"
							.. color_key(night_color)

						if state_cache[name]
							~= new_state
						then

							set_cached_sky(
								player,
								{
									type = "regular",

									sky_color = {
										day_sky =
											day_color,

										day_horizon =
											day_color,

										dawn_sky =
											dawn_color,

										dawn_horizon =
											dawn_color,

										night_sky =
											night_color,

										night_horizon =
											night_color
									}
								}
							)

							set_cached_celestial(
								player,
								false
							)

							state_cache[name] =
								new_state
						end

						-- ======================================
						-- WEATHER LIGHTING
						-- ======================================

						local lf =
							mcl_weather
								.get_current_light_factor()

						if mcl_weather.skycolor
							.current_layer_name()
							== "lightning"
						then

							set_cached_ratio(
								player,
								1
							)

						elseif lf then

							local w =
								core.get_timeofday()

							local light =
								math.max(
									0.2,
									(
										(
											1
											- math.abs(
												0.5 - w
											)
										)
										* lf
									) - 0.15
								)

							light =
								math.floor(
									light * 100
								) / 100

							set_cached_ratio(
								player,
								light
							)

						else

							set_cached_ratio(
								player,
								nil
							)
						end

					-- ==========================================
					-- CLEAR WEATHER
					-- ==========================================

					else

						-- Use a stable clear-weather sky everywhere. Do not ask the
						-- biome for sky colors here: Skyland can return black colors
						-- at very high altitude. Force reapply in water/high sky in
						-- case another mod overwrites the player's skybox.

						local clear_sky = {
							day_sky = "#87CEEB",
							day_horizon = "#FFFFFF",
							dawn_sky = "#FFA07A",
							dawn_horizon = "#FFDAB9",
							night_sky = "#1A2B5A",
							night_horizon = "#304B80",
							indoors = "#C0D8FF",
							fog_sun_tint = "#ff5f33",
							fog_moon_tint = nil,
							fog_tint_type = "custom"
						}

						local new_state = "clear:fixed-sky"
						local force_sky = underwater or pos.y > 1100

						if state_cache[name] ~= new_state or force_sky then
							set_cached_sky(player, {
								type = "regular",
								sky_color = clear_sky
							}, force_sky)

							set_cached_ratio(player, nil)
							state_cache[name] = new_state
						end

						-- Always restore sun, moon, and default stars during clear weather.
						-- The cache prevents redundant engine calls.
						set_cached_celestial(player, true, pos.y > 1100)

					end
				end
			end
		end
	end,

	-- ========================================================
	-- GET SKY LAYER COLOR
	-- ========================================================

	get_sky_layer_color = function(timeofday)

		if #mcl_weather.skycolor.layer_names == 0 then
			return nil
		end

		local colors =
			mcl_weather.skycolor.retrieve_layer()

		if not colors or #colors == 0 then
			return nil
		end

		if #colors == 1 then
			return {
				r = colors[1].r,
				g = colors[1].g,
				b = colors[1].b
			}
		end

		local rounded_time =
			math.floor(
				timeofday
				* mcl_weather.skycolor.max_val
			)

		return mcl_weather.skycolor.utils.convert_to_rgb(
			mcl_weather.skycolor.min_val,
			mcl_weather.skycolor.max_val,
			rounded_time,
			colors
		)
	end,

	-- ========================================================
	-- UTILITIES
	-- ========================================================

	utils = {

		convert_to_rgb = function(
			minval,
			maxval,
			current_val,
			colors
		)

			local max_index =
				#colors - 1

			if max_index <= 0 then
				return {
					r = colors[1].r,
					g = colors[1].g,
					b = colors[1].b
				}
			end

			local val =
				(
					current_val - minval
				)
				/
				(
					maxval - minval
				)
				*
				max_index
				+ 1.0

			local index1 =
				math.floor(val)

			local index2 =
				math.min(
					index1 + 1,
					max_index + 1
				)

			index1 =
				math.max(
					1,
					math.min(
						index1,
						max_index + 1
					)
				)

			local f =
				val - index1

			local c1 =
				colors[index1]

			local c2 =
				colors[index2]

			if not c1 then
				c1 = colors[#colors]
			end

			if not c2 then
				c2 = colors[#colors]
			end

			return {
				r = math.floor(
					c1.r
					+ f * (c2.r - c1.r)
				),

				g = math.floor(
					c1.g
					+ f * (c2.g - c1.g)
				),

				b = math.floor(
					c1.b
					+ f * (c2.b - c1.b)
				)
			}
		end,

		-- ====================================================
		-- GET PLAYERS
		-- ====================================================

		get_players = function(players_in)

			local players = {}

			if players_in == nil then

				local connected_players =
					core.get_connected_players()

				for _, player in ipairs(
					connected_players
				) do
					table.insert(
						players,
						player
					)
				end

			else

				for _, player in ipairs(
					players_in
				) do
					table.insert(
						players,
						player
					)
				end
			end

			return players
		end,

		-- ====================================================
		-- CURRENT BACKGROUND COLOR
		-- ====================================================

		get_current_bg_color = function()

			local players =
				mcl_weather.skycolor.utils
					.get_players(nil)

			if players[1] then

				local sky =
					players[1]:get_sky(true)

				if sky then
					return sky.sky_color
				end
			end

			return nil
		end
	}
}

-- ============================================================
-- GLOBALSTEP
-- ============================================================

local timer = 0

core.register_globalstep(function(dtime)

	if mcl_weather.skycolor.active ~= true then
		return
	end

	if #core.get_connected_players() == 0 then
		return
	end

	-- ========================================================
	-- FORCED UPDATE
	-- ========================================================

	if mcl_weather.skycolor.force_update then

		mcl_weather.skycolor.update_sky_color()

		mcl_weather.skycolor.force_update =
			false

		timer = 0

		return
	end

	-- ========================================================
	-- NORMAL UPDATE
	-- ========================================================

	timer = timer + dtime

	if timer >=
		mcl_weather.skycolor.update_interval
	then

		mcl_weather.skycolor.update_sky_color()

		timer = 0
	end
end)

-- ============================================================
-- PLAYER INITIALIZATION
-- ============================================================

local function initsky(player)

	clear_player_cache(player)

	-- ========================================================
	-- LIGHTING
	-- ========================================================

	if player.set_lighting then

		player:set_lighting({

			shadows = {
				intensity = 0.33
			},

			volumetric_light = {
				strength = 0.2
			},

			exposure = {
				luminance_min = -3.5,
				luminance_max = -2.5,

				exposure_correction = 0.35,

				speed_dark_bright = 1500,
				speed_bright_dark = 700
			},

			saturation = 1.1
		})
	end

	-- ========================================================
	-- FORCE FIRST UPDATE
	-- ========================================================

	if mcl_weather.skycolor.active then
		mcl_weather.skycolor.force_update = true
	end

	-- Cloud tint is selected by time of day during clear weather.
end

-- ============================================================
-- PLAYER EVENTS
-- ============================================================

core.register_on_joinplayer(
	initsky
)

core.register_on_respawnplayer(
	initsky
)

core.register_on_leaveplayer(function(player)

	clear_player_cache(player)

end)
