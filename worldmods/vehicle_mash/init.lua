vehicle_mash = {
	S = minetest.get_translator(minetest.get_current_modname())
}

-- Fix player_api eye height model safely
if (minetest.settings:get_bool("vehicle_mash.player_api_fix") ~= false)
   and player_api
   and player_api.registered_models
   and player_api.registered_models["character.b3d"] then

	player_api.registered_models["character.b3d"].animations.sit.eye_height = 1.7 -- raised from 1.47
end

-- Modpath and settings
local mpath = minetest.get_modpath("vehicle_mash")
local craft_check = minetest.settings:get_bool("vehicle_mash.enable_crafts")
local api_check = minetest.settings:get_bool("vehicle_mash.api_mode") or false

-- Load framework and crafts
dofile(mpath .. "/framework.lua")
if craft_check ~= false then
	dofile(mpath .. "/crafts.lua")
end

-- Helper to load vehicles
local function load_vehicles(def, names, folder)
	for _, name in ipairs(names) do
		local enabled = minetest.settings:get_bool("vehicle_mash.enable_"..name)
		if enabled ~= false then
			local file_path = mpath.."/"..folder.."/"..name..".lua"
			if minetest.get_modpath("vehicle_mash") then
				loadfile(file_path)(table.copy(def))
			end
		end
	end
end

if not api_check then
	-- ** CAR01s **
	local car01_def = {
		terrain_type = 1,
		max_speed_forward = 10,
		max_speed_reverse = 7,
		accel = 2,
		braking = 4,
		turn_speed = 2,
		stepheight = 1.1,
		visual = "mesh",
		mesh = "car.x",
		visual_size = {x=1, y=1},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.6, -0.05, -0.6, 0.6, 1, 0.6},
		onplace_position_adj = -0.45,
		player_rotation = vector.new(0,90,0),
		driver_attach_at = vector.new(3.5,3.7,3.5),
		driver_eye_offset = vector.new(0,2,0), -- raised camera
		number_of_passengers = 3,
		passengers = {
			{ attach_at = vector.new(3.5,3.7,-3.5), eye_offset = vector.new(0,1.8,0) },
			{ attach_at = vector.new(-4,3.7,3.5), eye_offset = vector.new(0,1.8,0) },
			{ attach_at = vector.new(-4,3.7,-3.5), eye_offset = vector.new(0,1.8,0) },
		},
		drop_on_destroy = {"vehicle_mash:tire 2", "vehicle_mash:windshield","vehicle_mash:battery","vehicle_mash:motor"},
		recipe = nil
	}
	local car01_names = {
		"black", "blue", "brown", "cyan",
		"dark_green", "dark_grey", "green",
		"grey", "magenta", "orange",
		"pink", "red", "violet",
		"white", "yellow", "hot_rod",
		"nyan_ride", "oerkki_bliss", "road_master",
	}
	load_vehicles(car01_def, car01_names, "car01s")

	-- ** MeseCars **
	local mesecar_def = {
		terrain_type = 1,
		max_speed_forward = 10,
		max_speed_reverse = 7,
		accel = 3,
		braking = 6,
		turn_speed = 4,
		stepheight = 0.6,
		visual = "cube",
		visual_size = {x=1.5, y=1.5},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.75, -0.75, -0.75, 0.75, 0.75, 0.75},
		onplace_position_adj = 0.25,
		player_rotation = vector.new(0,0,0),
		driver_attach_at = vector.new(0,0,-2),
		driver_eye_offset = vector.new(0,1.5,0), -- raised camera
		number_of_passengers = 0,
		passengers = {{ attach_at = vector.new(0,0,0), eye_offset = vector.new(0,1.5,0) }},
		drop_on_destroy = {"vehicle_mash:motor","vehicle_mash:battery"},
		recipe = nil
	}
	local mesecar_names = {"mese_blue","mese_pink","mese_purple","mese_yellow"}
	load_vehicles(mesecar_def, mesecar_names, "mesecars")

	-- ** Boats **
	local boat_def = {
		terrain_type = 2,
		max_speed_forward = 3,
		max_speed_reverse = 3,
		accel = 3,
		braking = 3,
		turn_speed = 3,
		stepheight = 0,
		visual = "mesh",
		visual_size = {x=1, y=1},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		onplace_position_adj = 0,
		textures = {"default_wood.png"},
		player_rotation = vector.new(0,0,0),
		driver_attach_at = vector.new(0.5,1,-3),
		driver_eye_offset = vector.new(0,1,0), -- raised camera
		number_of_passengers = 0,
		passengers = {{ attach_at = vector.new(0,0,0), eye_offset = vector.new(0,1,0) }},
	}
	local boat_names = {"boat","rowboat"}
	load_vehicles(boat_def, boat_names, "boats")

	-- ** Hovercrafts **
	local hover_def = {
		terrain_type = 3,
		max_speed_forward = 10,
		max_speed_reverse = 0,
		accel = 3,
		braking = 1,
		turn_speed = 2,
		stepheight = 1.1,
		visual = "mesh",
		mesh = "hovercraft.x",
		visual_size = {x=1, y=1},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.8, -0.25, -0.8, 0.8, 1.2, 0.8},
		onplace_position_adj = -0.25,
		player_rotation = vector.new(0,90,0),
		driver_attach_at = vector.new(-2,6.3,0),
		driver_eye_offset = vector.new(0,2.5,0), -- raised camera
		number_of_passengers = 0,
		passengers = {{ attach_at = vector.new(0,0,0), eye_offset = vector.new(0,2,0) }},
		recipe = nil
	}
	local hover_names = {"hover_blue","hover_green","hover_red","hover_yellow"}
	load_vehicles(hover_def, hover_names, "hovers")
end

-- Free global after 10 seconds
core.after(10, function()
	vehicle_mash.register_vehicle = nil
end)
