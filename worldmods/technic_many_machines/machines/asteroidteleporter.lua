local S = core.get_translator("technic_many_machines")
local demand = 50000
local timeperasteroid = 300

--possible nodes teleporter makes, with the number on the right being weight
local asteroidoutputnodes = {
    ["technic_many_machines:asteroid_stone"] = 120
}
--getting a rando node from list based on weight
local totalweight = 0
local nodelist = {}
--ore creation function
local function register_asteroid_ore(name, data)
    core.register_node(":technic_many_machines:asteroid_"..name, {
        description = S(data.description),
        tiles = {"technic_many_machines_asteroid_stone.png^"..data.overlay},
        groups = data.groups or {cracky = 3, stone = 1, level = 2},
        drop = data.drop,
        light_source = data.light_source or 0,
    })
end

--ORES MADE HERE
--lead, coal, tin, copper, and iron arent ores since they drop from stone anyways
core.register_on_mods_loaded(function()
    register_asteroid_ore("mese_ore", {
        description = "Mese Ore",
        overlay = "default_mineral_mese.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "default:mese_crystal 3",
        light_source = 2,
    })
    register_asteroid_ore("diamond_ore", {
        description = "Diamond Ore",
        overlay = "default_mineral_diamond.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "default:diamond 1",
        light_source = 1,
    })
    register_asteroid_ore("gold_ore", {
        description = "Gold Ore",
        overlay = "default_mineral_gold.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "default:gold_lump 3",
        light_source = 1,
    })
    register_asteroid_ore("uranium_ore", {
        description = "Uranium Ore",
        overlay = "technic_mineral_uranium.png",
        groups = {cracky = 1, stone = 1, level = 2, radioactive = 2},
        drop = "technic:uranium_lump 3",
        light_source = 1,
    })
    register_asteroid_ore("zinc_ore", {
        description = "Zinc Ore",
        overlay = "technic_mineral_zinc.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "technic:zinc_lump 4",
        light_source = 1,
    })
    register_asteroid_ore("chromium_ore", {
        description = "Chromium Ore",
        overlay = "technic_mineral_chromium.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "technic:chromium_lump 4",
        light_source = 1,
    })
    register_asteroid_ore("silver_ore", {
        description = "Silver Ore",
        overlay = "moreores_mineral_silver.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "moreores:silver_lump 4",
        light_source = 1,
    })
    register_asteroid_ore("mithril_ore", {
        description = "Mithril Ore",
        overlay = "moreores_mineral_mithril.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "moreores:mithril_lump 2",
        light_source = 1,
    })
    register_asteroid_ore("sulfur_ore", {
        description = "Sulfur Ore",
        overlay = "technic_mineral_sulfur.png",
        groups = {cracky = 1, stone = 1, level = 2},
        drop = "technic:sulfur_lump 4",
        light_source = 1,
    })
    if core.get_modpath("ethereal") then
        register_asteroid_ore("etherium_ore", {
            description = "Etherium Ore",
            overlay = "ethereal_etherium_ore.png",
            groups = {cracky = 1, stone = 1, level = 2},
            drop = "ethereal:etherium_dust 4",
            light_source = 1,
        })
        asteroidoutputnodes["technic_many_machines:asteroid_etherium_ore"] = 2
        
    end
    asteroidoutputnodes["technic_many_machines:asteroid_mese_ore"] = 4
    asteroidoutputnodes["technic_many_machines:asteroid_diamond_ore"] = 2
    asteroidoutputnodes["technic_many_machines:asteroid_gold_ore"] = 3
    asteroidoutputnodes["technic_many_machines:asteroid_uranium_ore"] = 3
    asteroidoutputnodes["technic_many_machines:asteroid_zinc_ore"] = 4
    asteroidoutputnodes["technic_many_machines:asteroid_chromium_ore"] = 4
    asteroidoutputnodes["technic_many_machines:asteroid_silver_ore"] = 3
    asteroidoutputnodes["technic_many_machines:asteroid_mithril_ore"] = 1
    asteroidoutputnodes["technic_many_machines:asteroid_sulfur_ore"] = 4






for name, weight in pairs(asteroidoutputnodes) do
    totalweight = totalweight + weight
    table.insert(nodelist, {name = name, threshold = totalweight})
end
end)
--picks a random node based on weight
local function pickrandomnode()
    local roll = math.random(1, totalweight)
    for i = 1, #nodelist do
        if roll <= nodelist[i].threshold then
            return nodelist[i].name
        end
    end
end
--multiblock functions
local function activate_multiblock_part(pos, contposasstring, count)
    local meta = core.get_meta(pos)
    if meta:get_string("multiblockcontrollerpos") == ""
    then meta:set_string("multiblockcontrollerpos", contposasstring) 
         meta:set_string("infotext", "Linked to ".. contposasstring)
    end
    if meta:get_string("multiblockcontrollerpos") == contposasstring then
    return count + 1
    end
    return count
end
local function ismulmultiblockbuilt(pos)
    local contposasstring = core.pos_to_string(pos)
    local meta = core.get_meta(pos)
    if meta:get_int("multiblockactive") == 1 then
        return true
    end
    local validnodes = {
        ["technic_many_machines:hv_mb_airlock"] = true,
        ["technic_many_machines:hv_mb_glass"] = true,
        ["technic_many_machines:hv_mb_casing"] = true,
    }        
    local reqiuredcount = 217
    local count = 0
    for x = -2, 2 do
        for z = -2, 2 do
            local temppos = {x = pos.x + x, y = pos.y, z = pos.z + z}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
            local temppos = {x = pos.x + x, y = pos.y + 6, z = pos.z + z}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
        end
    end
    for y = 0, 6 do
        for x = -3, 3 do
            local temppos = {x = pos.x + x, y = pos.y + y, z = pos.z-3}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
            local temppos = {x = pos.x + x, y = pos.y + y, z = pos.z+3}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
        end
        for z = -2, 2 do
            local temppos = {x = pos.x-3, y = pos.y + y, z = pos.z + z}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
            local temppos = {x = pos.x+3, y = pos.y + y, z = pos.z + z}
            if validnodes[core.get_node(temppos).name] then
                count = activate_multiblock_part(temppos, contposasstring, count)
            end
        end
    end
    if count >= reqiuredcount then
        return true
    else
        return false
    end
end
local function deactivate_multiblock(pos)
    local contposasstring = core.pos_to_string(pos)
    local validnodes = {
        ["technic_many_machines:hv_mb_airlock"] = true,
        ["technic_many_machines:hv_mb_glass"] = true,
        ["technic_many_machines:hv_mb_casing"] = true,
    }
    local function check_and_clear_meta(pos)
        if validnodes[core.get_node(pos).name] then
            local meta = core.get_meta(pos)
            if meta:get_string("multiblockcontrollerpos") == contposasstring then
                meta:set_string("multiblockcontrollerpos", "")
            end
        end
    end
    for x = -2, 2 do
        for z = -2, 2 do
            local temppos = {x = pos.x + x, y = pos.y, z = pos.z + z}
            check_and_clear_meta(temppos)
            local temppos = {x = pos.x + x, y = pos.y + 6, z = pos.z + z}
            check_and_clear_meta(temppos)
        end
    end
    for y = 0, 6 do
        for x = -3, 3 do
            local temppos = {x = pos.x + x, y = pos.y + y, z = pos.z-3}
            check_and_clear_meta(temppos)
            local temppos = {x = pos.x + x, y = pos.y + y, z = pos.z+3}
            check_and_clear_meta(temppos)
        end
        for z = -2, 2 do
            local temppos = {x = pos.x-3, y = pos.y + y, z = pos.z + z}
            check_and_clear_meta(temppos)
            local temppos = {x = pos.x+3, y = pos.y + y, z = pos.z + z}
            check_and_clear_meta(temppos)
        end
    end
end
--registering node
core.register_node("technic_many_machines:hv_asteroid_teleporter", {
    description = "Asteroid Teleporter",
    tiles = {"technic_many_machines_hv_asteroid_teleporter_top.png",
             "technic_many_machines_hv_bottom.png", 
             "technic_many_machines_hv_asteroid_teleporter_side.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, technic_machine = 1, technic_hv = 1},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        --time, technic_run will increment it
        meta:set_int("time", 0)
        --HV EU usage
        meta:set_int("HV_EU_demand", 0)
        --multiblock status
        meta:set_int("multiblockactive", 0)
    end,
    on_destruct = function(pos)
        deactivate_multiblock(pos)
    end,
    on_rightclick = function(pos)
        local meta = core.get_meta(pos)
        if ismulmultiblockbuilt(pos) then
            meta:set_int("multiblockactive", 1)
            meta:set_int("HV_EU_demand", demand)
        else
            meta:set_int("multiblockactive", 0)
        end
    end,
    technic_run = function(pos, node)
        local meta = core.get_meta(pos)
        local input = meta:get_int("HV_EU_input")
        if meta:get_int("multiblockactive") == 0 then 
            meta:set_string("infotext", "Asteroid Teleporter Multiblock Incomplete")
            return 
        end
        if input >= demand then
            local time = meta:get_int("time") + 1
            meta:set_int("time", time)
            meta:set_string("infotext", "Asteroid Teleporter Active\nTime Until Asteroid: "..(timeperasteroid - time).." seconds")
            if time >= timeperasteroid then
                local originpos = {x = pos.x - 2, y = pos.y + 1, z = pos.z - 2}
                local can_spawn = true
                -- Step 1: Check area
                local nodes = core.find_nodes_in_area(originpos, {x = originpos.x + 4, y = originpos.y + 4, z = originpos.z + 4}, {"air"})
                if #nodes < 125 then
                    can_spawn = false
                end
                -- Step 2: Spawn random nodes
                if can_spawn then
                    meta:set_int("time", 0)
                    for x = 0, 4 do
                        for y = 0, 4 do
                            for z = 0, 4 do
                                local p = {x=originpos.x+x, y=originpos.y+y, z=originpos.z+z}
                                core.set_node(p, {name = pickrandomnode()})
                            end
                        end
                    end
                else
                    -- reset time a little bit so it doesnt spam too much
                    meta:set_int("time", time - 10)
                    meta:set_string("infotext", "Teleport Blocked: Obstruction Detected")
                end
            end
        else
            meta:set_string("infotext", "Asteroid Teleporter Unpowered")
        end
    end,
})

technic.register_machine("HV", "technic_many_machines:hv_asteroid_teleporter", technic.receiver)
