local modpath = core.get_modpath(core.get_current_modname())

mcl_weather = {}
dofile(modpath .. "/lightning.lua")
dofile(modpath.."/biomes.lua")

dofile(modpath.."/skycolor.lua")

dofile(modpath.."/weather_core.lua")
dofile(modpath.."/snow.lua")
dofile(modpath.."/rain.lua")
dofile(modpath.."/thunder.lua")

core.register_globalstep(function(dtime)
	local weather = mcl_weather[mcl_weather.state]
	if not (weather and weather.step) then return end

	weather.step(dtime)
end)

