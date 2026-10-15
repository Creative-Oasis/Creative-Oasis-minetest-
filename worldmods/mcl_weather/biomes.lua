--replace dispatch system(it was cool though so imma make something similiar)
mcl_weather.biome_sky_colors = {}
mcl_weather.biome_fog_colors = {}

--default color(at the time of writing this idk what this will be for, i just know i dont want the get_sky_color to return nil)
mcl_weather.default_sky_color = "#7BA4FF"
mcl_weather.default_fog_color = "#C0D8FF"

local is_runtime = false

--register a biome sky color(cannot be called after the core.after below)
function mcl_weather.register_biome_sky_color(biome, color)
	if is_runtime then
		error("[mcl_weather] mcl_weather.register_biome_sky_color called too late (only use during load time)")
	end

	if type(biome) ~= "string" then
		error("[mcl_weather] biome_name needs to be a string")
	end

	local colorstr = core.colorspec_to_colorstring(color)

	if colorstr then
		mcl_weather.biome_sky_colors[biome] = colorstr
	else
		error("[mcl_weather] luanti does not recognize that color format or invalid color (try hexcode)")
	end
end

--register a biome fog color
function mcl_weather.register_biome_fog_color(biome, color)
	if is_runtime then
		error("[mcl_weather] mcl_weather.register_biome_fog_color called too late (only use during load time)")
	end

	if type(biome) ~= "string" then
		error("[mcl_weather] biome_name needs to be a string")
	end

	local colorstr = core.colorspec_to_colorstring(color)

	if colorstr then
		mcl_weather.biome_fog_colors[biome] = colorstr
	else
		error("[mcl_weather] luanti does not recognize that color format or invalid color (try hexcode)")
	end
end

--biome_to_sky_color[biome_id] = color
local biome_to_sky_color = {}

--biome_to_fog_color[biome_id] = color
local biome_to_fog_color = {}

--collects colors for every biome
core.after(0, function()
	--let previous func know its runtime
	is_runtime = true

	local biomes = core.registered_biomes

	--first look through registered biomes
	for name, biome_data in pairs(biomes) do
		local biome_id = core.get_biome_id(name)

		--get the color if it exists, and make it a string
		local skycolor = biome_data._mcl_skycolor
		local skycolorstring = core.colorspec_to_colorstring(skycolor)

		--i dont want to deal with tables
		if skycolorstring and biome_id then
			biome_to_sky_color[biome_id] = skycolorstring
		end

		--repeat
		local fogcolor = biome_data._mcl_fogcolor
		local fogcolorstring = core.colorspec_to_colorstring(fogcolor)

		if fogcolorstring and biome_id then
			biome_to_fog_color[biome_id] = fogcolorstring
		end
	end

	--then look through the colors registered via functions
	--im not gonna check the global table to see if its clean,
	--since any issues will be caused by people not using the function

	for biome_name, color in pairs(mcl_weather.biome_sky_colors) do
		local biome_id = core.get_biome_id(biome_name)

		if biome_id then
			biome_to_sky_color[biome_id] = color
		end
	end

	for biome_name, color in pairs(mcl_weather.biome_fog_colors) do
		local biome_id = core.get_biome_id(biome_name)

		if biome_id then
			biome_to_fog_color[biome_id] = color
		end
	end
end)

--gets sky color
function mcl_weather.get_sky_color(pos)
	local biome_data = core.get_biome_data(pos)

	if not biome_data then
		return mcl_weather.default_sky_color
	end

	local biome_id = biome_data.biome

	--if the biome_id exists
	if biome_id then
		local color = biome_to_sky_color[biome_id]

		--and the color exists
		if color then
			return color
		end
	end

	--return the default color if the previous fails
	return mcl_weather.default_sky_color
end

--gets the fog color
function mcl_weather.get_fog_color(pos)
	local biome_data = core.get_biome_data(pos)

	if not biome_data then
		return mcl_weather.default_fog_color
	end

	local biome_id = biome_data.biome

	--if the biome_id exists
	if biome_id then
		local color = biome_to_fog_color[biome_id]

		--and the color exists
		if color then
			return color
		end
	end

	--return the default color if the previous fails
	return mcl_weather.default_fog_color
end

--gets both colors
function mcl_weather.get_sky_fog_colors(pos)
	local biome_data = core.get_biome_data(pos)

	local skycolor = mcl_weather.default_sky_color
	local fogcolor = mcl_weather.default_fog_color
	local biome_id = nil

	if biome_data then
		biome_id = biome_data.biome
	end

	if biome_id then
		skycolor =
			biome_to_sky_color[biome_id]
			or mcl_weather.default_sky_color

		fogcolor =
			biome_to_fog_color[biome_id]
			or mcl_weather.default_fog_color
	end

	return skycolor, fogcolor
end

--check if a place is cold
function mcl_weather.is_position_cold(biome_name, pos)
	local biome_data = core.get_biome_data(pos)

	if biome_data then
		local data = core.registered_biomes[biome_name]

		if data and data._mcl_biome_type == "snowy" then
			return true

		elseif data
			and data._mcl_biome_type == "cold"
			and pos.y > 100
		then
			return true

		elseif biome_data.heat
			and biome_data.heat < 30
		then
			return true

		elseif biome_data.heat
			and biome_data.heat < 50
			and pos.y > 100
		then
			return true
		end
	end

	return false
end

--gets biome
function mcl_weather.get_biome_name(pos)
	local data = core.get_biome_data(pos)

	if not data then
		return nil
	end

	return core.get_biome_name(data.biome)
end

--checks if biome is arid
function mcl_weather.is_position_arid(biome_name)
	if not biome_name then
		return false
	end

	local data = core.registered_biomes[biome_name]

	--unknown/unregistered biome
	if not data then
		return false
	end

	if data.heat_point
		and data.heat_point > 80
		and not (
			data.humidity_point
			and data.humidity_point > 30
		)
	then
		return true
	end

	return data._mcl_biome_type == "hot"
end

--for group:opaque
core.register_on_mods_loaded(function()
	for name, data in pairs(core.registered_nodes) do
		local drawtype = data.drawtype
		local groups = data.groups

		if drawtype == "normal" then
			groups.opaque = 1
			core.override_item(name, {
				groups = groups
			})
		end
	end
end)