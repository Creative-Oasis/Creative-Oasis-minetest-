technic_many_machines = {}
-- new tier because why not
--[[technic.register_tier("EV", "Extreme Voltage")
technic.register_cable("technic_many_machines:ev_cable", {
	tier = "EV",
	size = 2/16,
	description = core.colorize("#ff0000ff", "EV Cable"),
    tiles = {"technic_many_machines_hv_bottom.png"}
})
]]

local mp = core.get_modpath(core.get_current_modname())
--i need help, the code in the cryptominer is garbage but idk how to make better
local enable_cryptominer = core.settings:get_bool("technic_many_machines_enable_cryptominer") or false
technic_many_machines.cryptominer_output = core.settings:get("technic_many_machines_cryptominer_output") or ""
--common functions go here
dofile(mp .. "/helpers.lua")

--crusher cuz yes
dofile(core.get_modpath("technic_many_machines").."/machines/crusher.lua")
--items
dofile(core.get_modpath("technic_many_machines").."/items.lua")
--decorative
dofile(core.get_modpath("technic_many_machines") .. "/decorative.lua")
--tools
dofile(core.get_modpath("technic_many_machines").."/tools.lua")

dofile(core.get_modpath("technic_many_machines").."/machines/mass_compressor.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/advanced_alloy_furnace.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/bulk_alloy_furnace.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/cobblegen.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/movingwalkway.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/sawmill.lua")
--fun unoptmized fun
if enable_cryptominer then
dofile(core.get_modpath("technic_many_machines").."/machines/cryptominer.lua")
end
dofile(core.get_modpath("technic_many_machines").."/machines/drop_extractor.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/asteroidteleporter.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/radiation_chamber.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/forge.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/hydro.lua")
dofile(core.get_modpath("technic_many_machines").."/machines/grinder.lua")

dofile(core.get_modpath("technic_many_machines").."/machines/areaminer.lua")


dofile(core.get_modpath("technic_many_machines").."/recipes.lua")

--tutorials
local guides = {
	{
		id = "moving_floor",
        title = "LV Moving Floor",
        image = "technic_many_machines_moving_floor.png",
        desc = "When given 80 EU, it moves the player on top of it in the direction it is facing."
	},
	{
		id = "cobblestone_generators",
		title = "Cobblestone Generators",
		image = "technic_many_machines_lv_cobblestone_generator.png",
		desc = "Generates cobblestone. The LV generates 1 cobblestone per second, and each tier higher generates 3 times more."
	},
	{
		id = "drop_extractors",
		title = "Drop Extractors",
		image = "technic_many_machines_lv_side.png^technic_many_machines_base_metal_gear.png",
		desc = "Simulates the breaking of a block to obtain chance drops. Gravel turns into flint and leaves into saplings. Can only handle up to 4 possible outputs."
	},
    {
        id = "hv_sawmill",
        title = "HV Sawmill",
        image = "technic_many_machines_hv_sawmill_front.png",
        desc = "Doubles the yield of wood from trees."
    },
    {
        id = "hv_bulk_alloy_furnace",
        title = "HV Bulk Alloy Furnace",
        image = "technic_many_machines_hv_alloy_furnace_front.png",
        desc = "An alloy furnace 6 times faster than its MV counterpart."
    },
    { 
        id = "hv_advanced_alloy_furnace", 
        title = "HV Advanced Alloy Furnace", 
        image = "technic_many_machines_hv_advancedalloyfurnace_front.png", 
        desc = "An alloy furnace you will need to use for many machines. Made to do alloying recipes with 3 inputs." 
    },
    {
        id = "hv_mass_compressor",
        title = "HV Bulk Compressor",
        image = "technic_many_machines_hv_masscompressor_front.png",
        desc = "Can compress 2 different items together, and can do some normal compressor recipes at great speeds."
    },
    {
        id = "hv_radiation_chamber",
        title = "HV Radiation Chamber",
        image = "technic_many_machines_hv_radiation_chamber.png",
        desc = "Turns 10 uranium dust into thorium. The higher the fissile, the faster it goes."
    },
    {
        id = "hv_asteroid_teleporter",
        title = "HV Asteroid Teleporter",
        image = "technic_many_machines_asteroid_teleporter.png",
        desc = "This machine teleports asteroids from far beyond our reach, for us to harvest for minerals(best used with HV Quarry). To construct, you must build a hollow 7x7x7 cube, with the center of the bottom. The shell described here must be made of HV Machine Casing Parts, HV Glass Parts, or HV Airlock Parts. Once the structure is complete, connect the asteroid teleporter to a network then right-click to complete the structure. Requires 50 KEU of power to run."
    },
    {
        id = "hv_forge",
        title = "The Forge",
        image = "technic_many_machines_forge.png",
        desc = "This machines main purpose is to make new and/or better machines, such as MV Hydro Generator MK2. To build, first place the controller. Nodes avaliable for the floors and walls are HV Forge Wall part, and HV Glass Parts 1 and 2. Build a 5x5 platform, where it is the middle of the front. Place a power port somewhere on the perimeter of this platform. Use the avaliable walls to then make a hollow 5x5x5 cube, with the bottom being the base. Fill the cube with Forge Catalysts, then punch the controller. Power used varies depending on the recipe."
    }
}

local function get_main_formspec()
    local fs = "formspec_version[4]" ..
               "size[13,9.5]" ..
               "label[0.5,0.4;Extra Technic Machines]" ..
               "scroll_container[0.5,0.8;11.2,8.2;menu_scroll;vertical;0.1]"
    
    for i, guide in ipairs(guides) do
        local y = (i - 1) * 4
        fs = fs .. "image_button[0," .. y .. ";4,4;" .. guide.image .. ";click_" .. guide.id .. ";]" ..
                   "label[4.5," .. (y + 1.5) .. ";" .. core.formspec_escape(guide.title) .. "]"
    end
    
    fs = fs .. "scroll_container_end[]"
    
    local total_height = #guides * 4
    local scroll_max = math.max(0, (total_height - 8.2) * 10)
    
    fs = fs .. "scrollbaroptions[max=" .. scroll_max .. ";thumbsize=10]" ..
               "scrollbar[12,0.8;0.4,8.2;vertical;menu_scroll;0]"
    return fs
end

local function get_guide_formspec(guide)
    return "formspec_version[4]" ..
           "size[13,9.5]" ..
           "label[0.5,0.5;" .. core.formspec_escape(guide.title) .. "]" ..
           "image[0.5,1.2;5,5;" .. guide.image .. "]" ..
           "textarea[6,1.2;6.5,7;;;" .. core.formspec_escape(guide.desc) .. "]" ..
           "button[0.5,8.5;3,0.8;back_to_menu;Back]"
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "technic_many_machines:tutorial" then return false end
    local player_name = player:get_player_name()

    if fields.back_to_menu then
        core.show_formspec(player_name, "technic_many_machines:tutorial", get_main_formspec())
        return true
    end
    for _, guide in ipairs(guides) do
        if fields["click_" .. guide.id] then
            core.show_formspec(player_name, "technic_many_machines:tutorial", get_guide_formspec(guide))
            return true
        end
    end
end)

core.register_chatcommand("etmguide", {
    description = "Opens the documentation for the machines added by this mod.",
    privs = {interact = true},
    func = function(name, param)
        core.show_formspec(name, "technic_many_machines:tutorial", get_main_formspec())
        return true
        
    end,
})

