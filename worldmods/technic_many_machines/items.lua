local S = core.get_translator("technic_many_machines")

local function getfullname(name)
    return "technic_many_machines:"..name
end

--just adds technic_many_machines: to it
local function register_craftitem(name, def)
    core.register_craftitem(getfullname(name), def)
end

local register_node = function(name, def)
    core.register_node(getfullname(name), def)
end

--some modified textures that are useful
local base_ingot = "default_steel_ingot.png^[colorize:#ffffff:100"
local base_dust = "technic_silver_dust.png"
local base_plate = "technic_many_machines_base_plate.png"
local base_metal_block = "technic_many_machines_base_metal_block.png"
local base_metal_piece = "technic_many_machines_base_metal_piece.png"
local base_metal_gear = "technic_many_machines_base_metal_gear.png"

local enable_test_items = core.settings:get_bool("technic_many_machines_enable_test_items", false)
if enable_test_items then
    register_craftitem("base_ingot", {
        description = S("Base Ingot (Test Item)"),
        inventory_image = base_ingot,
    })
    register_craftitem("base_dust", {
        description = S("Base Dust (Test Item)"),
        inventory_image = base_dust,
    })
    register_craftitem("base_plate", {
        description = S("Base Plate (Test Item)"),
        inventory_image = base_plate,
    })
    register_node("base_metal_block", {
        description = S("Base Metal Block (Test Item)"),
        tiles = {base_metal_block},
        groups = {cracky = 1, level = 2},
    })
    register_craftitem("base_metal_piece", {
        description = S("Base Metal piece (Test Item)"),
        inventory_image = base_metal_piece
    })
end


--MACHINE PARTS
--compressor piston
register_craftitem("compressor_piston", {
    description = S("Compressor Piston"),
    inventory_image = "technic_many_machines_compressor_piston.png",
})
--color filter, for LCD
register_craftitem("color_filter", {
    description = S("Color Filter"),
    inventory_image = "technic_many_machines_color_filter.png",
})
--lcd
register_craftitem("lcd", {
    description = S("LCD Screen"),
    inventory_image = "technic_many_machines_lcd.png",
})
--curcuits
--radiant alloy curcuit, the base one
register_craftitem("radiant_alloy_circuit", {
    description = S("Radiant Alloy Circuit"),
    inventory_image = "technic_many_machines_radiant_alloy_circuit.png",
})
--functional parts
register_craftitem("blocker", {
    description = S("Blocker"),
    inventory_image = "technic_many_machines_blocker.png",
})


--helper to make registering metal pieces easier
local function register_metal_piece(name, data)
    local item = data.item or nil
    local color = data.color or "#ffffff"
    local intensity = data.intensity or 150
    local light_source = data.light_source or 0
    local title = data.title or name
    local mpgroups = table.copy(data.groups) or {}
    mpgroups["metal_piece"] = 1
    core.register_craftitem("technic_many_machines:" .. name .. "_piece", {
        inventory_image = base_metal_piece .. "^[colorize:" .. color .. ":" .. intensity,
        light_source = light_source,
        groups = mpgroups,
        description = S(title .. " Piece")
    })
    if data.item then
    technic_many_machines.register_crusher_recipe({
        input = {item},
        output = {"technic_many_machines:" .. name .. "_piece 9"},
        time = 4,
    })

    technic.register_compressor_recipe({
        input = {"technic_many_machines:" .. name .. "_piece 9"},
        output = {item},
        time = 4
    })
    end
    return "technic_many_machines:" .. name .. "_piece"
end

local function register_metal_gear(name, data)
    local item = data.item or nil
    local piece = data.item_piece or nil
    local color = data.color or "#ffffff"
    local intensity = data.intensity or 150
    local light_source = data.light_source or 0
    local title = data.title or name
    local mpgroups = table.copy(data.groups) or {}
    mpgroups["gear"] = 1
    core.register_craftitem("technic_many_machines:gear_" .. name, {
        inventory_image = base_metal_gear .. "^[colorize:" .. color .. ":" .. intensity,
        light_source = light_source,
        groups = mpgroups,
        description = S(title .. " Gear")
    })
    if item and piece then
        core.register_craft({
            output = "technic_many_machines:gear_" .. name,
            recipe = {
                {"", item, ""},
                {item, piece, item},
                {"", item, ""}
            }
        })
    end

    return "technic_many_machines:gear_" .. name
end
--helper to make registering metals easier
local function register_metal(name, data)
    local color = data.color or "#ffffff"
    local intensity = data.intensity or 150
    local light_source = data.light_source or 0
    local radioactivity = data.radioactivity or 0
    local title = data.title or name
    local ingotgroups = table.copy(data.groups) or {}
    ingotgroups["ingot"] = 1
    register_craftitem(name .. "_ingot", {
        description = S(title .. " Ingot"),
        inventory_image = base_ingot .. "^[colorize:" .. color .. ":" .. intensity,
        light_source = light_source,
        groups = ingotgroups,
    })

    local dustgroups = table.copy(data.groups) or {}
    dustgroups["dust"] = 1
    register_craftitem(name .. "_dust", {
        description = S(title .. " Dust"),
        inventory_image = base_dust .. "^[colorize:" .. color .. ":" .. intensity,
        light_source = light_source,
        groups = dustgroups,
    })
    local blockgroups = table.copy(data.groups) or {}
    blockgroups["block"] = 1
    blockgroups["radioactive"] = radioactivity
    blockgroups["cracky"] = data.cracky or 1
    blockgroups["level"] = data.level or 2

    register_node(name .. "_block", {
        description = S(title .. " Block"),
        tiles = {base_metal_block .. "^[colorize:" .. color .. ":" .. intensity},
        groups = blockgroups,
        light_source = light_source,
    })
    if data.enable_plate then
        local plategroups = table.copy(data.groups) or {}
        local presstime = data.presstime or 4
        plategroups["plate"] = 1
        register_craftitem(name .. "_plate", {
            description = S(title .. " Plate"),
            inventory_image = base_plate .. "^[colorize:" .. color .. ":" .. intensity,
            light_source = light_source,
            groups = plategroups,
        })
        technic.register_compressor_recipe({
            input = {"technic_many_machines:" .. name .. "_ingot 5"},
            output = {"technic_many_machines:" .. name .. "_plate"},
            time = presstime,
        })
    end
    local fullname = "technic_many_machines:" .. name
    data.item = fullname .. "_ingot"
    local metalpiece = register_metal_piece(name, data)
    data.item_piece = metalpiece
    local gear = register_metal_gear(name, data)
    core.register_craft({
        type = "shapeless",
        output = fullname .. "_ingot 9",
        recipe = {fullname .. "_block"},
    })

    core.register_craft({
        output = fullname .. "_block",
        recipe = {
            {fullname .. "_ingot", fullname .. "_ingot", fullname .. "_ingot"},
            {fullname .. "_ingot", fullname .. "_ingot", fullname .. "_ingot"},
            {fullname .. "_ingot", fullname .. "_ingot", fullname .. "_ingot"},
        },
    })

    core.register_craft({
        type = "cooking",
        output = fullname .. "_ingot",
        recipe = fullname .. "_dust",
        time = data.cooktime or 3,
    })

    technic.register_grinder_recipe({
        input = {fullname .. "_ingot"},
        output = {fullname .. "_dust"},
        time = data.grindtime or 2,
    })
end
--ingots
--radiant alloy ingot is made by alloying 0.0 fissile uranium with a mese fragment and stainless steel in advanced alloy furnace
register_metal("radiant_alloy", {
    title = "Radiant Alloy",
    color = "#c8ff00",
    intensity = 100,
    light_source = 7,
    enable_plate = true,
    presstime = 8,
})
--thorium, made in the radiation chamber by leaving uranium dust in it. The higher the fissile of uranium, the faster it is.
register_metal("thorium", {
    title = "Thorium",
    color = "#273126",
    intensity = 150,
    radioactivity = 2,
})
--forge alloy, used to make the forge
register_metal("forge", {
    title = "Forge",
    color = "#012c2c",
    intensity = 200,
    enable_plate = true,
    presstime = 12,
})

--misc parts that arent full ingots
core.register_craftitem(":technic:lead_plate", {
    description = S("Lead Plate"),
    inventory_image = "technic_many_machines_lead_plate.png",
    groups = {plate = 1},
})

--metal pieces
--i got the colors from the darkest part of the non border part of the texture
local pieces = {
    --item name color title intensity luminance groups
    --default
    {"default:bronze_ingot", "bronze", "#af4e13", "Bronze"},
    {"default:copper_ingot", "copper", "#b8722e", "Copper"},
    {"default:gold_ingot", "gold", "#d2a700", "Gold"},
    {"default:steel_ingot", "steel", "#888581", "Wrought Iron"},
    {"default:tin_ingot", "tin", "#9a9795", "Tin"},
    --basic materials
    {"basic_materials:brass_ingot", "brass", "#a87f23", "Brass"},
    --moreores
    {"moreores:silver_ingot", "silver", "#a7bfca", "Silver"},
    {"moreores:mithril_ingot", "mithril", "#a7bfca", "Mithril"},
    --technic
    {"technic:carbon_steel_ingot", "carbon_steel", "#7f84aa", "Carbon Steel"},
    {"technic:cast_iron_ingot", "cast_iron", "#6265a7", "Cast Iron"},
    {"technic:chromium_ingot", "chromium", "#c7d8d8", "Chromium"},
    {"technic:lead_ingot", "lead", "#838383", "Lead"},
    {"technic:stainless_steel_ingot", "stainless_steel", "#d0d0d0", "Stainless Steel"},
    {"technic:zinc_ingot", "zinc", "#a3d4e2", "Zinc"}
}

--uranium sold seperately
local ucolor = "#aeeba7"

for i = 0, 35 do
    local groups = {}
    local rnum = i
    if i == 7 then 
        num = ""
    else
        num = i
        groups["not_in_creative_inventory"] = 1
    end
    local uraniumname = "technic:uranium" .. num .. "_ingot"
    local uraniumtitle = (rnum/10) .. "%-Fissile Uranium"
    table.insert(pieces, {uraniumname, "uranium" .. num, ucolor, uraniumtitle, nil, nil, groups})
end

for _, data in ipairs(pieces) do
    register_metal_piece(data[2], {item = data[1], color = data[3], title = data[4], intensity = data[5], light_source = data[6], groups = data[7]})
end
--asteroid nodes
--it can drop copper, tin, iron, coal, and lead in dust form
local drops = {
    max_items = 1,
    items = {
        {items = {"technic:copper_dust"}, rarity = 10},
        {items = {"technic:tin_dust"}, rarity = 10},
        {items = {"technic:wrought_iron_dust"}, rarity = 10},
        {items = {"technic:coal_dust"}, rarity = 10},
        {items = {"technic:lead_dust"}, rarity = 10},
        {items = {"technic_many_machines:asteroid_stone"}},
    }
}
core.register_node("technic_many_machines:asteroid_stone", {
    description = S("Asteroid Stone"),
    tiles = {"technic_many_machines_asteroid_stone.png"},   
    groups = {cracky = 3, stone = 1, level = 2},
    drop = drops,
})

--multiblock nodes
local function register_multiblock_part(name, data)
    data.groups["multiblock_part"] = 1
    data.on_destruct = function(pos)
        local meta = core.get_meta(pos)
        local controller_str = meta:get_string("multiblockcontrollerpos")
        --Check if the string is not empty before proceeding
        if controller_str ~= "" then
            local ctrl_pos = core.string_to_pos(controller_str)
            if ctrl_pos then
                local ctrl_meta = core.get_meta(ctrl_pos)
                -- Use 0 to represent false in metadata
                ctrl_meta:set_int("multiblockactive", 0)
            end
        end
    end
    register_node(name, data)
end
function technic_many_machines.register_multiblock_part(name, data)
    register_multiblock_part(name, data)
end
register_multiblock_part("hv_mb_airlock", {
    description = "HV Airlock Part",
    paramtype = "light",
    use_texture_alpha = true,
    walkable = false,
    drawtype = "glasslike_framed",
    tiles = {"technic_many_machines_multiblock_hv_airlock.png", "technic_many_machines_damaged_hv_frame.png^[colorize:#7b7b7b:255^[opacity:117"},
    groups = {cracky = 1, level = 2},
    post_effect_color = {r = 123, b = 123, g = 123, a = 117}

})

register_multiblock_part("hv_mb_glass", {
    description = "HV Glass Part",
    use_texture_alpha = true,
    paramtype = "light",
    drawtype = "glasslike_framed",
    tiles = {"technic_many_machines_multiblock_hv_glass.png", "technic_many_machines_damaged_hv_frame.png^[colorize:#3a3b2a:255^[opacity:117"},
    groups = {cracky = 1, level = 2},
    post_effect_color = {r = 58, g = 59, b = 42, a = 117 }

})

register_multiblock_part("hv_mb_casing", {
    description = "HV Machine Casing Part",
    tiles = {"technic_many_machines_damaged_hv_frame.png"},
    groups = {cracky = 1, level = 2},
})
register_multiblock_part("void", {
    description = "Void", 
    tiles = {
        {
            name = "technic_many_machines_void.png",
            scale = 8,
            align_style = "world",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1, 
            },
        }
    },
    groups = {cracky = 1, level = 2},
    drop = ""
})


--misc other stuff
register_craftitem("radioactive_sludge", {
    description = S("Radioactive Sludge"),
    inventory_image = "technic_many_machines_radioactive_sludge.png",
    light_source = 7,
})

if core.get_modpath("underch") then
    register_craftitem("crushed_malachite", {
        description = S("Crushed Malachite"),
        inventory_image = "technic_many_machines_crushed_malachite.png"
    })
end
if core.get_modpath("too_many_stones") then
    register_craftitem("crushed_galena", {
        description = S("Crushed Galena"),
        inventory_image = "technic_many_machines_crushed_galena.png"
    })
end


