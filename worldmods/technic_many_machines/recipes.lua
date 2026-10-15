--recipes for machines
--mass_compressor.lua
core.register_craft({
    output = "technic_many_machines:hv_masscompressor",
    recipe = {
        {"technic:composite_plate", "technic_many_machines:compressor_piston", "technic:composite_plate"},
        {"technic:hv_cable", "technic:hv_transformer", "default:tinblock"},
        {"technic:carbon_plate", "technic:mv_compressor", "technic:carbon_plate"},
}})
--bulk_alloy_furnace.lua
core.register_craft({
    output = "technic_many_machines:hv_alloy_furnace",
    recipe = {
        {"technic:mv_alloy_furnace", "technic:mv_alloy_furnace", "technic:mv_alloy_furnace"},
        {"technic:mv_alloy_furnace", "technic:mv_alloy_furnace", "technic:mv_alloy_furnace"},
        {"technic:composite_plate", "technic:hv_transformer", "technic:composite_plate"},
}})
--advanced_alloy_furnace.lua
core.register_craft({
    output = "technic_many_machines:hv_advancedalloyfurnace",
    recipe = {
        {"technic:composite_plate", "technic:mv_alloy_furnace", "technic:composite_plate"},
        {"technic:red_energy_crystal", "technic:hv_transformer", "technic:hv_cable"},
        {"technic:composite_plate", "technic:carbon_plate", "technic:composite_plate"},
}})
core.register_craft({
    output = "technic_many_machines:hv_sawmill",
    recipe = {
        {"technic:composite_plate", "technic:hv_transformer", "technic:composite_plate"},
        {"technic:diamond_drill_head", "technic:machine_casing", "technic_many_machines:carbon_plate"},
        {"technic:composite_place", "technic:hv_cable", "technic:composite_plate"},
    }
})
core.register_craft({
    output = "technic_many_machines:lv_moving_walkway",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"basic_materials:gear_steel", "technic:machine_casing", "basic_materials:gear_steel"},
        {"basic_materials:motor", "technic:lv_cable", "basic_materials:motor"},
    }
})
core.register_craft({
    output = "technic_many_machines:lv_drop_extractor",
    recipe = {
        {"default:steel_ingot", "technic:lv_cable", "default:steel_ingot"},
        {"default:pick_steel", "technic:machine_casing", "basic_materials:gear_steel"},
        {"default:steel_ingot", "technic:lv_cable", "default:steel_ingot"},
    }
})
core.register_craft({
    output = "technic_many_machines:mv_drop_extractor",
    recipe = {
        {"technic:stainless_steel_ingot", "technic:mv_cable", "technic:stainless_steel_ingot"},
        {"default:pick_mese", "technic_many_machines:lv_drop_extractor", "basic_materials:gear_steel"},
        {"technic:stainless_steel_ingot", "technic:mv_cable", "technic:stainless_steel_ingot"},
    }
})
core.register_craft({
    output = "technic_many_machines:hv_drop_extractor",
    recipe = {
        {"technic:composite_plate", "technic:hv_cable", "technic:composite_plate"},
        {"default:pick_diamond", "technic_many_machines:mv_drop_extractor", "basic_materials:gear_steel"},
        {"technic:composite_plate", "technic:hv_cable", "technic:composite_plate"},
    }
})
core.register_craft({
    output = "technic_many_machines:lv_cobble_generator",
    recipe = {
        {"basic_materials:gear_steel", "technic:lv_transformer", "basic_materials:gear_steel"},
        {"bucket:bucket_water", "technic:machine_casing", "bucket:bucket_lava"},
        {"technic:cast_iron_ingot", "technic:lv_cable", "technic:cast_iron_ingot"},
    },
    replacements = {
        {"bucket:bucket_water", "bucket:bucket_empty"},
        {"bucket:bucket_lava", "bucket:bucket_empty"},
    }
})
core.register_craft({
    output = "technic_many_machines:lv_cobble_generator",
    recipe = {
        {"basic_materials:gear_steel", "technic:lv_transformer", "basic_materials:gear_steel"},
        {"default:ice", "technic:machine_casing", "bucket:bucket_lava"},
        {"technic:cast_iron_ingot", "technic:lv_cable", "technic:cast_iron_ingot"},
    },
    replacements = {
        {"bucket:bucket_lava", "bucket:bucket_empty"},
    }
})
core.register_craft({
    output = "technic_many_machines:mv_cobble_generator",
    recipe = {
        {"technic:stainless_steel_ingot", "technic:mv_transformer", "technic:stainless_steel_ingot"},
        {"technic_many_machines:lv_cobble_generator", "technic:machine_casing", "technic_many_machines:lv_cobble_generator"},
        {"technic:stainless_steel_ingot", "technic:mv_cable", "technic:stainless_steel_ingot"},
    }
})
core.register_craft({
    output = "technic_many_machines:hv_cobble_generator",
    recipe = {
        {"technic:composite_plate", "technic:hv_transformer", "technic:composite_plate"},
        {"technic_many_machines:mv_cobble_generator", "technic:machine_casing", "technic_many_machines:mv_cobble_generator"},
        {"technic:composite_plate", "technic:hv_cable", "technic:composite_plate"},
    }
})
--asteroidteleporter.lua
core.register_craft({
    output = "technic_many_machines:hv_asteroid_teleporter",
    recipe = {
        {"technic_many_machines:thorium_block", "technic_many_machines:radiant_alloy_plate", "default:mese"},
        {"technic:composite_plate", "technic_many_machines:hv_mb_casing", "technic:composite_plate"},
        {"technic:control_logic_unit", "technic:hv_transformer", "technic:hv_cable"},
    }
})
--radiation_chamber.lua
core.register_craft({
    output = "technic_many_machines:hv_radiation_chamber",
    recipe = {
        {"technic:composite_plate", "technic:hv_transformer", "technic:composite_plate"},
        {"technic_many_machines:radiant_alloy_plate", "technic:machine_casing", "technic_many_machines:radiant_alloy_plate"},
        {"technic:uranium35_block", "technic:hv_cable", "technic:uranium35_block"},
    }
})
--sawmill.lua
core.register_craft({
    output = "technic_many_machines:hv_sawmill",
    recipe = {
        {"technic:composite_plate", "technic:hv_transformer", "technic:composite_plate"},
        {"technic:diamond_drill_head", "technic:machine_casing", "technic:diamond_drill_head"},
        {"technic:composite_plate", "technic:hv_cable", "technic:composite_plate"},
    }
})
--forge.lua
core.register_craft({
    output = "technic_many_machines:hv_forge_controller",
    recipe = {
        {"technic_many_machines:forge_plate", "technic_many_machines:lcd", "technic_many_machines:forge_plate"},
        {"technic_many_machines:radiant_alloy_circuit", "technic_many_machines:hv_forge_wall", "technic_many_machines:forge_plate"},
        {"technic_many_machines:forge_plate", "technic:hv_cable", "technic_many_machines:forge_plate"},
    }
})

core.register_craft({
    output = "technic_many_machines:hv_forge_wall", 
    recipe = {
        {"default:obsidian", "technic:carbon_plate", "default:obsidian"},
        {"technic:carbon_plate", "technic_many_machines:forge_block", "technic:carbon_plate"},
        {"technic:lead_plate", "technic:carbon_plate", "technic:lead_plate"},
    }
})

core.register_craft({
    output = "technic_many_machines:hv_forge_power", 
    type = "shapeless",
    recipe = {"technic:hv_cable", "technic_many_machines:hv_forge_wall"}
})

core.register_craft({
    output = "technic_many_machines:hv_forge_glass 4", 
    recipe = {
        {"technic_many_machines:forge_ingot", "technic_many_machines:hv_forge_wall", "technic_many_machines:forge_ingot"},
        {"technic_many_machines:hv_forge_wall", "default:glass", "technic_many_machines:hv_forge_wall"},
        {"technic_many_machines:forge_ingot", "technic_many_machines:hv_forge_wall", "technic_many_machines:forge_ingot"},
    }
})

core.register_craft({
    output = "technic_many_machines:hv_forge_glass_2 4", 
    recipe = {
        {"technic_many_machines:forge_ingot", "technic_many_machines:hv_forge_wall", "technic_many_machines:forge_ingot"},
        {"technic_many_machines:hv_forge_wall", "default:obsidian_glass", "technic_many_machines:hv_forge_wall"},
        {"technic_many_machines:forge_ingot", "technic_many_machines:hv_forge_wall", "technic_many_machines:forge_ingot"},
    }
})
--crusher.lua

core.register_craft({
    output = "technic_many_machines:mv_crusher",
    recipe = {
        {"technic:stainless_steel_ingot", "technic:lv_grinder", "technic:stainless_steel_ingot"},
        {"technic:mv_cable", "technic:mv_transformer", "pipeworks:tube_1"},
        {"technic:stainless_steel_ingot", "technic:lv_compressor", "technic:stainless_steel_ingot"}
    }
})

--machine parts
core.register_craft({
    output = "technic_many_machines:compressor_piston",
    recipe = {
        {"technic:cast_iron_ingot", "basic_materials:carbon_steel_bar", "technic:cast_iron_ingot"},
        {"technic:cast_iron_ingot", "basic_materials:carbon_steel_bar", "technic:cast_iron_ingot"},
        {"technic:carbon_plate", "technic:carbon_plate", "technic:carbon_plate"},
}})

core.register_craft({
    output = "technic_many_machines:color_filter 1",
    recipe = {
        {"", "xpanes:pane_flat", ""},
        {"dye:red", "dye:green", "dye:blue"},
        {"", "xpanes:pane_flat", ""}
    }
})

core.register_craft({
    output = "technic_many_machines:lcd",
    recipe = {
        {"xpanes:pane_flat", "technic_many_machines:color_filter"},
        {"technic:lv_led", "technic:doped_silicon_wafer"},
    }
})

core.register_craft({
    output = "technic_many_machines:radiant_alloy_circuit",
    recipe = {
        {"basic_materials:gold_wire", "basic_materials:copper_strip", "basic_materials:gold_wire"},
        {"basic_materials:ic", "technic_many_machines:radiant_alloy_plate", "basic_materials:ic"},
        {"technic:control_logic_unit", "basic_materials:plastic_strip", "technic:control_logic_unit"},
    },
    replacements = {
        {"basic_materials:gold_wire", "basic_materials:empty_spool"}
    }
})


--raw materials
if core.get_modpath("underch") then
    technic.register_grinder_recipe({
        time = 8,
        output = {"technic:copper_dust"},
        input = {"technic_many_machines:crushed_malachite"} 
    })
end
if core.get_modpath("too_many_stones") then
    technic.register_grinder_recipe({
        time = 8,
        output = {"technic:lead_dust"},
        input = {"technic_many_machines:crushed_galena"} 
    })
end
--simple materials

--machine processing recipes
local recipes
--compressor recipes
technic.register_compressor_recipe({
    time = 4,
    input = {"technic:lead_ingot 5"},
    output = {"technic:lead_plate"}
})
--alloy furnace recipes
recipes = {
    {"default:steel_ingot 5", "dye:red", "technic_many_machines:blocker", 8},
    {"default:glass 8", "technic:uranium0_dust", "technic_many_machines:uranium_glass 8"}
}
for _, recipe in pairs(recipes) do
	technic.register_alloy_recipe({
        input = {recipe[1], recipe[2]},
        output = recipe[3],
        time = recipe[4]
    })
end
--advanced alloy furnace recipes
recipes = {
    { 8, "technic:coal_dust 2", "default:steel_ingot 4", "technic:chromium_ingot 1", "technic:stainless_steel_ingot 5"},
    { 6, "technic:coal_dust 2", "technic:steel_dust 4", "technic:chromium_dust 1", "technic:stainless_steel_ingot 5"},
    { 8, "technic:uranium0_ingot", "technic:stainless_steel_ingot 3", "default:mese_crystal_fragment", "technic_many_machines:radiant_alloy_ingot 4"},
    { 4, "technic_many_machines:radiant_alloy_dust", "default:mese_crystal_fragment", "technic_many_machines:hv_mb_casing", "technic_many_machines:hv_mb_airlock"},
    { 6, "technic:graphite 5", "moreores:mithril_ingot 2", "technic:lead_ingot 6", "technic_many_machines:forge_ingot 2"},
    { 6, "technic:graphite 5", "technic:mithril_dust 2", "technic:lead_dust 6", "technic_many_machines:forge_ingot 2"},
    { 4, "technic:uranium0_dust", "technic:stainless_steel_dust 3", "default:mese_crystal_fragment", "technic_many_machines:radiant_alloy_ingot 4"},
}

for _, recipe in ipairs(recipes) do
    technic_many_machines.register_advanced_alloy_furnace_recipe({
        time = recipe[1],
        input = {recipe[2], recipe[3], recipe[4]},
        output = recipe[5]})
end
--mass compressor recipes
--not wanting to type a lot, also you might not wanna replace you compressor with this, this thing might be too heavy duty for some things
recipes = {
    { 2, "default:copper_ingot 10", "default:copper_ingot 10", "technic:copper_plate 4"},
    { 2, "default:sand 20", "default:sand 20", "default:sandstone 20"},
    { 2, "default:desert_sand 20", "default:desert_sand 20", "default:desert_sandstone 20"},
    { 2, "default:silver_sand 20", "default:silver_sand 20", "default:silver_sandstone 20"},
    { 2, "technic:mixed_metal_ingot 2", "technic:mixed_metal_ingot 2", "technic:composite_plate 4"},
    { 2, "technic:coal_dust 24", "technic:coal_dust 24", "technic:carbon_plate 4"},
	{ 10,"default:coal_lump 25", "default:coal_lump 25", "default:diamond"},
    { 4, "technic_many_machines:radiant_alloy_ingot 10", "technic_many_machines:radiant_alloy_ingot 10", "technic_many_machines:radiant_alloy_plate 4"},
    { 2, "technic_many_machines:radiant_alloy_plate", "technic:blast_resistant_concrete 2", "technic_many_machines:hv_mb_casing"},
    { 2, "technic_many_machines:hv_mb_casing", "default:obsidian_glass 4", "technic_many_machines:hv_mb_glass"},
    { 40, "technic_many_machines:forge_plate 10", "technic:lead_plate 10", "technic_many_machines:forge_catalyst"}
}
for _, recipe in ipairs(recipes) do
    technic_many_machines.register_bulk_compressor_recipe({
        time = recipe[1],
        input = {recipe[2], recipe[3]},
        output = recipe[4]})
end
--THE FORGE
recipes = {
    {10, "technic_many_machines:hydro_mv_generator_mk2", 30000, "technic:hydro_turbine 3", "technic_many_machines:forge_plate", "technic_many_machines:forge_ingot", "technic:carbon_plate 2"},
    {10, "technic_many_machines:hv_grinder_mk2", 40000, "technic:hv_grinder 2", "technic_many_machines:forge_plate 4", "technic:carbon_plate 3", "technic_many_machines:radiant_alloy_plate 2", "technic:diamond_drill_head 2", "technic_many_machines:radiant_alloy_circuit"},
    {10, "technic_many_machines:hv_drop_extractor_mk2", 40000, "technic_many_machines:hv_drop_extractor 3", "technic_many_machines:forge_plate 4", "technic:carbon_plate 2", "technic_many_machines:gear_forge 3", "moreores:pick_mithril", "technic_many_machines:radiant_alloy_circuit"},
}
for _, recipe in ipairs(recipes) do
    local itemsneeded = {}
    for index, item in ipairs(recipe) do
        if index > 3 then
            table.insert(itemsneeded, item)
        end
    end
    technic_many_machines.register_forge_recipe({
        time = recipe[1],
        output = recipe[2],
        powerdraw = recipe[3],
        input = itemsneeded,
    })
end
--radiation chamber
for i = 0, 35 do
    if i == 7 then num = ""
    else num = i
    end
    technic.register_recipe("radiation_chamber", {
        output = {"technic_many_machines:thorium_dust", "technic_many_machines:radioactive_sludge"},
        input = {"technic:uranium" .. num .. "_dust 10"},
        time = 60 - i,
    })
end
--crusher
local function getpn(name, count)
    return "technic_many_machines:" .. name .. "_piece " .. count
end
recipes = {
    --default
    {4, "default:pick_wood", "default:stick 9"},
    --worlds strangest way to make cobblestone
    {4, "default:pick_stone", "default:cobble 2"},
    {4, "default:pick_steel", getpn("steel", 19),},
    {4, "default:pick_bronze", getpn("bronze", 19)},
    {4, "default:pick_mese", "default:mese_crystal_fragment 19"},
    {3, "default:pick_diamond", "default:diamond 2"},
    {4, "default:axe_bronze", getpn("bronze", 19)},
    {3, "default:axe_diamond", "default:diamond 2"},
    {4, "default:axe_mese", "default:mese_crystal_fragment 19"},
    {4, "default:axe_steel", getpn("steel", 19)},
    {4, "default:axe_stone", "default:cobble 2"},
    {4, "default:axe_wood", "default:stick 9"},
    {4, "default:shovel_bronze", getpn("bronze", 7)},
    {4, "default:shovel_diamond", "default:diamond"},
    {4, "default:shovel_mese", "default:mese__crystal_fragment 7"},
    {4, "default:shovel_steel", getpn("steel", 7)},
    {4, "default:shovel_wood", "default:stick 4"},
    {4, "default:shovel_stone", "default:cobble"},
    {4, "default:sword_bronze", getpn("bronze", 13)},
    {4, "default:sword_diamond", "default:diamond"},
    {4, "default:sword_mese", "default:mese_crystal_fragment 13"},
    {4, "default:sword_steel", getpn("steel", 13)},
    {4, "default:sword_wood", "default:stick 6"},
    {4, "default:sword_stone", "default:cobble 2"},

    --moreores
    --mithril
    {4, "moreores:axe_mithril", getpn("mithril", 19)},
    {4, "moreores:hoe_mithril", getpn("mithril", 13)},
    {4, "moreores:pick_mithril", getpn("mithril", 19)},
    {4, "moreores:shovel_mithril", getpn("mithril", 7)},
    {4, "moreores:sword_mithril", getpn("mithril", 13)},
    --silver
    {4, "moreores:axe_silver", getpn("silver", 19)},
    {4, "moreores:hoe_silver", getpn("silver", 13)},
    {4, "moreores:pick_silver", getpn("silver", 19)},
    {4, "moreores:shovel_silver", getpn("silver", 7)},
    {4, "moreores:sword_silver", getpn("silver", 13)},
}
--no optional dependency on this since it doesnt really matter
if core.get_modpath("3d_armor") then
    local armor = {
    --bronze
    {4, "3d_armor:boots_bronze", getpn("bronze", 24)},
    {4, "3d_armor:chestplate_bronze", getpn("bronze", 48)},
    {4, "3d_armor:helmet_bronze", getpn("bronze", 30)},
    {4, "3d_armor:leggings_bronze", getpn("bronze", 42)},
    {4, "shields:shield_bronze", getpn("bronze", 48)},
    --diamond
    {4, "3d_armor:boots_diamond", "default:diamond 3"},
    {4, "3d_armor:chestplate_diamond", "default:diamond 6"},
    {4, "3d_armor:helmet_diamond", "default:diamond 4"},
    {4, "3d_armor:leggings_diamond", "default:diamond 6"},
    {4, "shields:shield_diamond", "default:diamond 6"},
    --gold
    {4, "3d_armor:boots_gold", getpn("gold", 24)},
    {4, "3d_armor:chestplate_gold", getpn("gold", 48)},
    {4, "3d_armor:helmet_gold", getpn("gold", 30)},
    {4, "3d_armor:leggings_gold", getpn("gold", 42)},
    {4, "shields:shield_gold", getpn("gold", 48)},
    --mithril
    {4, "3d_armor:boots_mithril", getpn("mithril", 24)},
    {4, "3d_armor:chestplate_mithril", getpn("mithril", 48)},
    {4, "3d_armor:helmet_mithril", getpn("mithril", 30)},
    {4, "3d_armor:leggings_mithril", getpn("mithril", 42)},
    {4, "shields:shield_mithril", getpn("mithril", 48)},
    --steel
    {4, "3d_armor:boots_steel", getpn("steel", 24)},
    {4, "3d_armor:chestplate_steel", getpn("steel", 48)},
    {4, "3d_armor:helmet_steel", getpn("steel", 30)},
    {4, "3d_armor:leggings_steel", getpn("steel", 42)},
    {4, "shields:shield_steel", getpn("steel", 48)},
}
table.insert_all(recipes, armor)
end
if core.get_modpath("technic_armor") then
    local technic_armor = {
    --brass
    {4, "technic_armor:boots_brass", getpn("brass", 24)},
    {4, "technic_armor:chestplate_brass", getpn("brass", 48)},
    {4, "technic_armor:helmet_brass", getpn("brass", 30)},
    {4, "technic_armor:leggings_brass", getpn("brass", 42)},
    {4, "technic_armor:shield_brass", getpn("brass", 48)},
    --carbon steel
    {4, "technic_armor:boots_carbon", getpn("carbon_steel", 24)},
    {4, "technic_armor:chestplate_carbon", getpn("carbon_steel", 48)},
    {4, "technic_armor:helmet_carbon", getpn("carbon_steel", 30)},
    {4, "technic_armor:leggings_carbon", getpn("carbon_steel", 42)},
    {4, "technic_armor:shield_carbon", getpn("carbon_steel", 48)},
    --cast iron
    {4, "technic_armor:boots_cast", getpn("cast_iron", 24)},
    {4, "technic_armor:chestplate_cast", getpn("cast_iron", 48)},
    {4, "technic_armor:helmet_cast", getpn("cast_iron", 30)},
    {4, "technic_armor:leggings_cast", getpn("cast_iron", 42)},
    {4, "technic_armor:shield_cast", getpn("cast_iron", 48)},
    --lead
    {4, "technic_armor:boots_lead", getpn("lead", 24)},
    {4, "technic_armor:chestplate_lead", getpn("lead", 48)},
    {4, "technic_armor:helmet_lead", getpn("lead", 30)},
    {4, "technic_armor:leggings_lead", getpn("lead", 42)},
    {4, "technic_armor:shield_lead", getpn("lead", 48)},
    --silver
    {4, "technic_armor:boots_silver", getpn("silver", 24)},
    {4, "technic_armor:chestplate_silver", getpn("silver", 48)},
    {4, "technic_armor:helmet_silver", getpn("silver", 30)},
    {4, "technic_armor:leggings_silver", getpn("silver", 42)},
    {4, "technic_armor:shield_silver", getpn("silver", 48)},
    --stainless steel
    {4, "technic_armor:boots_stainless", getpn("stainless_steel", 24)},
    {4, "technic_armor:chestplate_stainless", getpn("stainless_steel", 48)},
    {4, "technic_armor:helmet_stainless", getpn("stainless_steel", 30)},
    {4, "technic_armor:leggings_stainless", getpn("stainless_steel", 42)},
    {4, "technic_armor:shield_stainless", getpn("stainless_steel", 48)},
    --tin
    {4, "technic_armor:boots_tin", getpn("tin", 24)},
    {4, "technic_armor:chestplate_tin", getpn("tin", 48)},
    {4, "technic_armor:helmet_tin", getpn("tin", 30)},
    {4, "technic_armor:leggings_tin", getpn("tin", 42)},
    {4, "technic_armor:shield_tin", getpn("tin", 48)},
}
table.insert_all(recipes, technic_armor)
end

if core.get_modpath("underch") then
    table.insert(recipes, {
    30, "underch:malachite", "technic_many_machines:crushed_malachite 3"
    })
    
    core.register_craft({
        type = "cooking",
        output = "technic_many_machines:copper_piece 3",
        recipe = "technic_many_machines:crushed_malachite",
        cooktime = 6.0,
    })
end

if core.get_modpath("too_many_stones") then
    table.insert(recipes, {
    30, "too_many_stones:galena", "technic_many_machines:crushed_galena 2"
    })
    core.register_craft({
        type = "cooking",
        output = "technic_many_machines:lead_piece 3",
        recipe = "technic_many_machines:crushed_galena",
        cooktime = 6.0,
    })
end

for _, recipe in ipairs(recipes) do
    technic_many_machines.register_crusher_recipe({
        time = recipe[1],
        input = {recipe[2]},
        output = {recipe[3],  recipe[4], recipe[5], recipe[6]}
    })
end

--others
if core.get_modpath("darkage") then
    technic.register_compressor_recipe({
        time = 2,
        input = {"darkage:chalk_powder 4"},
        output = {"darkage:chalk"}
    })
    technic_many_machines.register_bulk_compressor_recipe({
        time = 2,
        input = {"darkage:chalk_powder 40", "darkage:chalk_powder 40"},
        output = {"darkage:chalk 20"}
    })
end