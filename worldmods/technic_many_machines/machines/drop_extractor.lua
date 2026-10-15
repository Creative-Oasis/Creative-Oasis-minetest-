--TEXTURE IS TEMPORARY
local S = core.get_translator("technic_many_machines")
technic.register_recipe_type("technic_many_machines:drop_extracting", {
    description = S("Drop Extracting"),
    input_size = 1,
    output_size = 6,
})

table.insert(core.registered_on_mods_loaded, 1, function()
    local nodes = core.registered_nodes
    for nodename, def in pairs(nodes) do
        if def.groups.not_in_creative_inventory == 1 then
            -- Skip nodes that are not in the creative inventory, as they are likely technical nodes or similar
            core.log("info", "Skipping node " .. nodename .. " because it is not in the creative inventory")
        else
        local drop = def and def.drop
        local drop_items = {}
        local estimated_time = 1
        if drop then
            if type(drop) == "string" then
                if drop == nodename then
                    -- If the drop is the same as the node, we can't reliably determine the drops, so skip it
                    core.log("warning", "Skipping drop extracting recipe for " .. nodename .. " because it drops itself")
                else
                    table.insert(drop_items, drop)
                end
            elseif type(drop) == "table" then
                if drop.items then
                    for _, item in ipairs(drop.items) do
                        local rarity = item.rarity or 1
                        estimated_time = estimated_time + rarity
                        if item.items then
                            for _, subitem in ipairs(item.items) do
                                if subitem == nodename then
                                    -- If the subitem is the same as the node, we can't reliably determine the drops, so skip it
                                    core.log("warning", "Skipping drop extracting recipe for " .. nodename .. " because it drops itself in a nested item")
                                else
                                table.insert(drop_items, subitem)
                                end
                            end
                        else
                            if item.name == nodename then
                                -- If the item is the same as the node, we can't reliably determine the drops, so skip it
                                core.log("warning", "Skipping drop extracting recipe for " .. nodename .. " because it drops itself in a nested item")
                            else
                                table.insert(drop_items, item.name or "")
                            end
                        end
                    end
                elseif drop.name then
                    table.insert(drop_items, drop.name)
                end
            end
        end
        if #drop_items >= 1 and #drop_items <= 4 then
            core.log("action", "Registering drop extracting recipe for " .. nodename.." "..#drop_items.. " with drops in "..estimated_time.. " seconds: " .. table.concat(drop_items, ", "))
            technic.register_recipe("technic_many_machines:drop_extracting", {
                input = {nodename.." "..#drop_items},
                output = drop_items,
                time = estimated_time,
            })
        end
    end
    end
end)
technic.register_base_machine("technic_many_machines:lv_drop_extractor", {
    description = S("LV Drop Extractor"),
    typename = "technic_many_machines:drop_extracting",
    tier = "LV",
    demand = {400},
    speed = 1,
})
technic.register_base_machine("technic_many_machines:mv_drop_extractor", {
    description = S("MV Drop Extractor"),
    typename = "technic_many_machines:drop_extracting",
    tier = "MV",
    demand = {1500, 1100, 700},
    speed = 2,
    upgrade = 1,
    tube = 1
})
technic.register_base_machine("technic_many_machines:hv_drop_extractor", {
    description = S("HV Drop Extractor"),
    typename = "technic_many_machines:drop_extracting",
    tier = "HV",
    demand = {3000, 2200, 1400},
    speed = 4,
    upgrade = 1,
    tube = 1
})
core.override_item("technic_many_machines:lv_drop_extractor_active", {
    tiles = {
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:lv_drop_extractor", {
    short_description = S("LV Drop Extractor"),
    tiles = {
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_lv_side.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:mv_drop_extractor_active", {
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:mv_drop_extractor", {
    short_description = S("MV Drop Extractor"),
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_mv_side.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:hv_drop_extractor_active", {
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:hv_drop_extractor", {
    short_description = S("HV Drop Extractor"),
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side.png^technic_many_machines_base_metal_gear.png"
    }
})

--mk2
technic.register_base_machine("technic_many_machines:hv_drop_extractor_mk2", {
    description = S("HV Drop Extractor MK2"),
    typename = "technic_many_machines:drop_extracting",
    tier = "HV",
    demand = {15000, 12000, 9000},
    speed = 20,
    upgrade = 1,
    tube = 1
})

core.override_item("technic_many_machines:hv_drop_extractor_mk2_active", {
    tiles = {
        "technic_many_machines_hv_side_mk2.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^technic_many_machines_base_metal_gear.png"
    }
})
core.override_item("technic_many_machines:hv_drop_extractor_mk2", {
    short_description = S("HV Drop Extractor"),
    tiles = {
        "technic_many_machines_hv_side_mk2.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_side_mk2.png^technic_many_machines_base_metal_gear.png"
    }
})
if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_drop_extractor_mk2", "technic_many_machines:hv_drop_extractor_mk2_active", "technic_many_machines:hv_drop_extractor", "technic_many_machines:hv_drop_extractor_active", "technic_many_machines:mv_drop_extractor", "technic_many_machines:mv_drop_extractor_active"}, {
        on_push_item = function(pos, in_dir, stack)
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "src", stack)
        end,
        on_pull_item = function(pos, out_dir, count)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.get_items(pos, inv, "dst", count)
        end,
        on_unpull_item = function(pos, out_dir, stack)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "dst", stack)
        end,
    })
end