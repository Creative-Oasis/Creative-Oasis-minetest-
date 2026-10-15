local register_multiblock_part = technic_many_machines.register_multiblock_part
local has_unified_inventory = core.get_modpath("unified_inventory")
--this is so bad
--the multiblock parts
--recipes for the forge
technic_many_machines.forge_recipes = {}
--a simple table that allows storing recipes as numbers in the node
local recipes = {}
--makes a comma seperated string of items
local function get_key(input)
    local key
    if type(input) == "string" then
        return ItemStack(input):get_name()
    elseif type(input) == "table" then
        local inputs = {}
        for _, item in ipairs(input) do
            table.insert(inputs, ItemStack(item):get_name())
        end
        key = table.concat(inputs, ",")
        return key
    end
    return false
end
if has_unified_inventory then
    unified_inventory.register_craft_type("hv_forging", {
		description = "HV Forging",
		icon = "technic_many_machines_forge_controller.png",
		width = 4,  -- Optional. Default: 3
		height = 2, -- Optional. Default: 3
	})
end
--registeres a forge recipe
function technic_many_machines.register_forge_recipe(data)
    local time = data.time or 40
    local input = data.input or nil
    local output = data.output or nil
    local powerdraw = data.powerdraw or 20000
    --if no input or output then well... too bad
    if not input or not output then
        error("Forge recipe must have input and output")
    end
    local key = get_key(input)
    --you did something seriously wrong
    if not key then
        error("Key generation failed! (might have gotten an input that is not a string or table)")
    end
    if type(output) == "table" then
        error("Output cannot be table, there is only 1 slot anyways")
    end
    --store the data
    technic_many_machines.forge_recipes[key] = {
        time = time,
        input = input,
        output = output,
        powerdraw = powerdraw,
        index = #recipes + 1
    }
    if has_unified_inventory then
        unified_inventory.register_craft({
		type = "hv_forging",
        output = output,

		items = input,
		-- ^ Craft inputs. See also: `core.get_all_craft_recipes` -> `items`
		width = #input
		-- ^ The width of the recipe - in items. Same as `core.register_craft`.
	})


    end
    --add the recipe to the list
    table.insert(recipes, key)
end

--gets the forge recipe
local function get_forge_recipe(input)
    local key
    if type(input) == "string" then
        key = input
    elseif type(input) == "table" then
        key = table.concat(input, ",")
    end
    return technic_many_machines.forge_recipes[key]
end

register_multiblock_part("hv_forge_glass", {
    description = "HV Forge Glass Part",
    use_texture_alpha = "blend",
    paramtype = "light",
    drawtype = "glasslike",
    tiles = {"technic_many_machines_forge_glass.png"},
    groups = {cracky = 1, level = 2},

})

register_multiblock_part("hv_forge_glass_2", {
    description = "HV Forge Glass Part 2",
    use_texture_alpha = "blend",
    paramtype = "light",
    drawtype = "glasslike_framed",
    tiles = {"technic_many_machines_forge_glass_2_frame.png", "technic_many_machines_forge_glass_2.png"},
    groups = {cracky = 1, level = 2},

})

register_multiblock_part("hv_forge_wall", {
    description = "HV Forge Wall Part",
    tiles = {"technic_many_machines_forge_wall.png"},
    groups = {cracky = 1, level = 2},
})

register_multiblock_part("hv_forge_power", {
    description = "HV Forge Power Input Part",
    tiles = {
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_power_input.png",
        "technic_many_machines_forge_power_input.png",
        "technic_many_machines_forge_power_input.png",
        "technic_many_machines_forge_power_input.png"
    },
    groups = {cracky = 1, level = 2, technic_machine = 1, technic_hv = 1},
    technic_run = function(pos)
        local meta = core.get_meta(pos)
        local cpos = core.string_to_pos(meta:get_string("multiblockcontrollerpos"))

        if not cpos then 
            return 
        end
        local cmeta = core.get_meta(cpos)
        local demand = meta:get_int("HV_EU_demand")
        local supply = meta:get_int("HV_EU_input")
        if supply >= demand then
            cmeta:set_int("powered", 1)
            meta:set_string("infotext", "HV Power Port Active")
        else
            meta:set_string("infotext", "HV Power Port Unpowered")
            cmeta:set_int("powered", 0)
        end
    end
})

technic.register_machine("HV", "technic_many_machines:hv_forge_power", technic.receiver)


core.register_node("technic_many_machines:forge_catalyst", {
    description = "Forge Catalyst",
    tiles = {"technic_many_machines_forge_catalyst.png"},
    groups = {cracky = 1, level = 2},
})
local allowedwalls = {
    ["technic_many_machines:hv_forge_wall"] = true,
    ["technic_many_machines:hv_forge_glass"] = true,
    ["technic_many_machines:hv_forge_glass_2"] = true,
}
--bottom is a 5x5 of allowedwalls, except for the front center, which is controller, and back center, which is power input
--the sides are 5x3 of allowedwalls, except for the stuff mentioned above
--the top is just a 5x5 of allowedwalls
--the inside is a 3x3x3 of forge catalyst OR void, since on successful activation the catalyst becomes void
--the full structure is a 5x5x5 cube

local function activate_multiblock_part(pos, contposasstring, count)
    local meta = core.get_meta(pos)
    if meta:get_string("multiblockcontrollerpos") == "" then 
        meta:set_string("multiblockcontrollerpos", contposasstring) 
        meta:set_string("infotext", "Linked to ".. contposasstring)
    end
    if meta:get_string("multiblockcontrollerpos") == contposasstring then
        return count + 1
    end
    return count
end

--formspec to be used here
--first time using https://luk3yx.gitlab.io/minetest-formspec-editor/
--update i gave up and tried calculating slot sizes
--the number i got for width is 1.25x - 0.25
local formspec = "formspec_version[6]"
    .. "size[10.25,7.75]"
    .. "no_prepend[]"
    .. "background[0,0;10.25,7.75;technic_many_machines_forge_formspec_bg.png]"
    .. "listcolors[#021d20;#005864]"
    .. "list[current_player;main;0.25,2.75;8,4;0]"
    .. "list[context;src;0.25,0.25;4,2;0]"
    .. "list[context;dst;7.125,0.875;1,1;0]"
dirchecks = {
    [0] = function(pos, playername)
        local posstring = core.pos_to_string(pos)
        local count = 0
        local powerportpos
        for x = pos.x - 2, pos.x + 2 do
            for z = pos.z, pos.z +4 do
                local y = pos.y
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                elseif nodename == "technic_many_machines:hv_forge_power" then
                    powerportpos = checkpos
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if not powerportpos then
            core.chat_send_player(playername, "Power input is missing in bottom row.")
            return false
        end
        if count ~= 24 then
            core.chat_send_player(playername, "Bottom layer is not complete. Missing walls or glass.")
            return false
        end
        for x = pos.x - 2, pos.x + 2 do
            for y = pos.y + 1, pos.y + 4 do
                local z1 = pos.z
                local z2 = pos.z + 4
                local checkpos1 = {x=x, y=y, z=z1}
                local checkpos2 = {x=x, y=y, z=z2}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 64 then
            core.chat_send_player(playername, "Front or back walls are not complete.")
            return false
        end
        for z = pos.z + 1, pos.z + 3 do
            for y = pos.y + 1, pos.y + 4 do
                local x1 = pos.x - 2
                local x2 = pos.x + 2
                local checkpos1 = {x=x1, y=y, z=z}
                local checkpos2 = {x=x2, y=y, z=z}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 88 then
            core.chat_send_player(playername, "Left or right walls are not complete.")
            return false
        end
        for x = pos.x - 1, pos.x + 1 do
            for z = pos.z + 1, pos.z + 3 do
                local y = pos.y + 4
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if count ~= 97 then
            core.chat_send_player(playername, "Top layer is not complete.")
            return false
        end
        local centercorner1 = {x=pos.x - 1, y=pos.y + 1, z=pos.z + 1}
        local centercorner2 = {x=pos.x + 1, y=pos.y + 3, z=pos.z + 3}
        local noncatalystcount = 27 - #core.find_nodes_in_area(centercorner1, centercorner2, {"technic_many_machines:forge_catalyst", "technic_many_machines:void"}, false)
        if noncatalystcount ~= 0 then
            core.chat_send_player(playername, "The inside of the forge is not filled with catalyst. Missing " .. noncatalystcount .. " catalyst blocks.")
            return false
        end
        core.chat_send_player(playername, "Forge structure is complete. You can now use the forge.")
        for x = centercorner1.x, centercorner2.x do
            for y = centercorner1.y, centercorner2.y do
                for z = centercorner1.z, centercorner2.z do
                    local checkpos = {x=x, y=y, z=z}
                    core.set_node(checkpos, {name="technic_many_machines:void"})
                end
            end
        end
        local powerportposasstring = core.pos_to_string(powerportpos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", formspec)
        meta:set_string("powerportpos", powerportposasstring)
        return true
    end,
    [1] = function(pos, playername)
        local posstring = core.pos_to_string(pos)
        local count = 0
        local powerportpos
        for z = pos.z - 2, pos.z + 2 do
            for x = pos.x, pos.x + 4 do
                local y = pos.y
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                elseif nodename == "technic_many_machines:hv_forge_power" then
                    powerportpos = checkpos
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if not powerportpos then
            core.chat_send_player(playername, "Power input is missing in bottom row.")
            return false
        end
        if count ~= 24 then
            core.chat_send_player(playername, "Bottom layer is not complete. Missing walls or glass.")
            return false
        end
        for z = pos.z - 2, pos.z + 2 do
            for y = pos.y + 1, pos.y + 4 do
                local x1 = pos.x
                local x2 = pos.x + 4
                local checkpos1 = {x=x1, y=y, z=z}
                local checkpos2 = {x=x2, y=y, z=z}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 64 then
            core.chat_send_player(playername, "Front or back walls are not complete.")
            return false
        end
        for x = pos.x + 1, pos.x + 3 do
            for y = pos.y + 1, pos.y + 4 do
                local z1 = pos.z - 2
                local z2 = pos.z + 2
                local checkpos1 = {x=x, y=y, z=z1}
                local checkpos2 = {x=x, y=y, z=z2}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 88 then
            core.chat_send_player(playername, "Left or right walls are not complete.")
            return false
        end
        for z = pos.z - 1, pos.z + 1 do
            for x = pos.x + 1, pos.x + 3 do
                local y = pos.y + 4
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if count ~= 97 then
            core.chat_send_player(playername, "Top layer is not complete.")
            return false
        end
        local centercorner1 = {x=pos.x + 1, y=pos.y + 1, z=pos.z - 1}
        local centercorner2 = {x=pos.x + 3, y=pos.y + 3, z=pos.z + 1}
        local noncatalystcount = 27 - #core.find_nodes_in_area(centercorner1, centercorner2, {"technic_many_machines:forge_catalyst", "technic_many_machines:void"}, false)
        if noncatalystcount ~= 0 then
            core.chat_send_player(playername, "The inside of the forge is not filled with catalyst. Missing " .. noncatalystcount .. " catalyst blocks.")
            return false
        end
        core.chat_send_player(playername, "Forge structure is complete. You can now use the forge.")
        for z = centercorner1.z, centercorner2.z do
            for y = centercorner1.y, centercorner2.y do
                for x = centercorner1.x, centercorner2.x do
                    local checkpos = {x=x, y=y, z=z}
                    core.set_node(checkpos, {name="technic_many_machines:void"})
                end
            end
        end
        local powerportposasstring = core.pos_to_string(powerportpos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", formspec)
        meta:set_string("powerportpos", powerportposasstring)
        return true
    end,
    [2] = function(pos, playername)
        local posstring = core.pos_to_string(pos)
        local count = 0
        local powerportpos
        for x = pos.x - 2, pos.x + 2 do
            for z = pos.z - 4, pos.z do
                local y = pos.y
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                elseif nodename == "technic_many_machines:hv_forge_power" then
                    powerportpos = checkpos
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if not powerportpos then
            core.chat_send_player(playername, "Power input is missing in bottom row.")
            return false
        end
        if count ~= 24 then
            core.chat_send_player(playername, "Bottom layer is not complete. Missing walls or glass.")
            return false
        end
        for x = pos.x - 2, pos.x + 2 do
            for y = pos.y + 1, pos.y + 4 do
                local z1 = pos.z - 4
                local z2 = pos.z
                local checkpos1 = {x=x, y=y, z=z1}
                local checkpos2 = {x=x, y=y, z=z2}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 64 then
            core.chat_send_player(playername, "Front or back walls are not complete.")
            return false
        end
        for z = pos.z - 3, pos.z - 1 do
            for y = pos.y + 1, pos.y + 4 do
                local x1 = pos.x - 2
                local x2 = pos.x + 2
                local checkpos1 = {x=x1, y=y, z=z}
                local checkpos2 = {x=x2, y=y, z=z}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 88 then
            core.chat_send_player(playername, "Left or right walls are not complete.")
            return false
        end
        for x = pos.x - 1, pos.x + 1 do
            for z = pos.z - 3, pos.z - 1 do
                local y = pos.y + 4
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if count ~= 97 then
            core.chat_send_player(playername, "Top layer is not complete.")
            return false
        end
        local centercorner1 = {x=pos.x - 1, y=pos.y + 1, z=pos.z - 3}
        local centercorner2 = {x=pos.x + 1, y=pos.y + 3, z=pos.z - 1}
        local noncatalystcount = 27 - #core.find_nodes_in_area(centercorner1, centercorner2, {"technic_many_machines:forge_catalyst", "technic_many_machines:void"}, false)
        if noncatalystcount ~= 0 then
            core.chat_send_player(playername, "The inside of the forge is not filled with catalyst. Missing " .. noncatalystcount .. " catalyst blocks.")
            return false
        end
        core.chat_send_player(playername, "Forge structure is complete. You can now use the forge.")
        for x = centercorner1.x, centercorner2.x do
            for y = centercorner1.y, centercorner2.y do
                for z = centercorner1.z, centercorner2.z do
                    local checkpos = {x=x, y=y, z=z}
                    core.set_node(checkpos, {name="technic_many_machines:void"})
                end
            end
        end
        local powerportposasstring = core.pos_to_string(powerportpos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", formspec)
        meta:set_string("powerportpos", powerportposasstring)
        return true
    end,
    [3] = function(pos, playername)
        local posstring = core.pos_to_string(pos)
        local count = 0
        local powerportpos
        for z = pos.z - 2, pos.z + 2 do
            for x = pos.x - 4, pos.x do
                local y = pos.y
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                elseif nodename == "technic_many_machines:hv_forge_power" then
                    powerportpos = checkpos
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if not powerportpos then
            core.chat_send_player(playername, "Power input is missing in bottom row.")
            return false
        end
        if count ~= 24 then
            core.chat_send_player(playername, "Bottom layer is not complete. Missing walls or glass.")
            return false
        end
        for z = pos.z - 2, pos.z + 2 do
            for y = pos.y + 1, pos.y + 4 do
                local x1 = pos.x - 4
                local x2 = pos.x
                local checkpos1 = {x=x1, y=y, z=z}
                local checkpos2 = {x=x2, y=y, z=z}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 64 then
            core.chat_send_player(playername, "Front or back walls are not complete.")
            return false
        end
        for x = pos.x - 3, pos.x - 1 do
            for y = pos.y + 1, pos.y + 4 do
                local z1 = pos.z - 2
                local z2 = pos.z + 2
                local checkpos1 = {x=x, y=y, z=z1}
                local checkpos2 = {x=x, y=y, z=z2}
                local nodename1 = core.get_node(checkpos1).name
                local nodename2 = core.get_node(checkpos2).name
                if allowedwalls[nodename1] then
                    count = activate_multiblock_part(checkpos1, posstring, count)
                end
                if allowedwalls[nodename2] then
                    count = activate_multiblock_part(checkpos2, posstring, count)
                end
            end
        end
        if count ~= 88 then
            core.chat_send_player(playername, "Left or right walls are not complete.")
            return false
        end
        for z = pos.z - 1, pos.z + 1 do
            for x = pos.x - 3, pos.x - 1 do
                local y = pos.y + 4
                local checkpos = {x=x, y=y, z=z}
                local nodename = core.get_node(checkpos).name
                if allowedwalls[nodename] then
                    count = activate_multiblock_part(checkpos, posstring, count)
                end
            end
        end
        if count ~= 97 then
            core.chat_send_player(playername, "Top layer is not complete.")
            return false
        end
        local centercorner1 = {x=pos.x - 3, y=pos.y + 1, z=pos.z - 1}
        local centercorner2 = {x=pos.x - 1, y=pos.y + 3, z=pos.z + 1}
        local noncatalystcount = 27 - #core.find_nodes_in_area(centercorner1, centercorner2, {"technic_many_machines:forge_catalyst", "technic_many_machines:void"}, false)
        if noncatalystcount ~= 0 then
            core.chat_send_player(playername, "The inside of the forge is not filled with catalyst. Missing " .. noncatalystcount .. " catalyst blocks.")
            return false
        end
        core.chat_send_player(playername, "Forge structure is complete. You can now use the forge.")
        for z = centercorner1.z, centercorner2.z do
            for y = centercorner1.y, centercorner2.y do
                for x = centercorner1.x, centercorner2.x do
                    local checkpos = {x=x, y=y, z=z}
                    core.set_node(checkpos, {name="technic_many_machines:void"})
                end
            end
        end
        local powerportposasstring = core.pos_to_string(powerportpos)
        local meta = core.get_meta(pos)
        meta:set_string("powerportpos", powerportposasstring)
        meta:set_string("formspec", formspec)
        return true
    end,
}
local function check_structure(pos, dir, playername)
    return dirchecks[dir](pos, playername)
end
--will unclaim multiblock
local validnodes = {
    ["technic_many_machines:hv_forge_wall"] = true,
    ["technic_many_machines:hv_forge_glass"] = true,
    ["technic_many_machines:hv_forge_glass_2"] = true,
    ["technic_many_machines:hv_forge_power"] = true,
}

local function check_and_clear_meta(pos, contposasstring)
    local nodename = core.get_node(pos).name
    if validnodes[nodename] then
        local meta = core.get_meta(pos)
        if meta:get_string("multiblockcontrollerpos") == contposasstring then
            meta:set_string("infotext", "")
            meta:set_string("multiblockcontrollerpos", "")
            if nodename == "technic_many_machines:hv_forge_power" then
                meta:set_int("HV_EU_demand", 0)
            end
        end
    elseif nodename == "technic_many_machines:void" then
        core.set_node(pos, {name = "air"})
    end
end

local nodes_to_clear = {
    "technic_many_machines:hv_forge_wall",
    "technic_many_machines:hv_forge_glass",
    "technic_many_machines:hv_forge_glass_2",
    "technic_many_machines:hv_forge_power",
    "technic_many_machines:void"
}

local dirsforclear = {
    [0] = function(pos, contposasstring)
        local pos1 = {x = pos.x - 2, y = pos.y,     z = pos.z}
        local pos2 = {x = pos.x + 2, y = pos.y + 4, z = pos.z + 4}
        local positions, counts = core.find_nodes_in_area(pos1, pos2, nodes_to_clear)
        for _, npos in ipairs(positions) do check_and_clear_meta(npos, contposasstring) end
    end,

    [1] = function(pos, contposasstring)
        local pos1 = {x = pos.x,     y = pos.y,     z = pos.z - 2}
        local pos2 = {x = pos.x + 4, y = pos.y + 4, z = pos.z + 2}
        local positions, counts = core.find_nodes_in_area(pos1, pos2, nodes_to_clear)
        for _, npos in ipairs(positions) do check_and_clear_meta(npos, contposasstring) end
    end,

    [2] = function(pos, contposasstring)
        local pos1 = {x = pos.x - 2, y = pos.y,     z = pos.z - 4}
        local pos2 = {x = pos.x + 2, y = pos.y + 4, z = pos.z}
        local positions, counts = core.find_nodes_in_area(pos1, pos2, nodes_to_clear)
        for _, npos in ipairs(positions) do check_and_clear_meta(npos, contposasstring) end
    end,

    [3] = function(pos, contposasstring)
        local pos1 = {x = pos.x - 4, y = pos.y,     z = pos.z - 2}
        local pos2 = {x = pos.x,     y = pos.y + 4, z = pos.z + 2}
        local positions, counts = core.find_nodes_in_area(pos1, pos2, nodes_to_clear)
        for _, npos in ipairs(positions) do check_and_clear_meta(npos, contposasstring) end
    end,
}
    
core.register_node("technic_many_machines:hv_forge_controller", {
    description = "HV Forge Controller",
    tiles = {
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_wall.png",
        "technic_many_machines_forge_controller.png"
    },
    groups = {cracky = 1, level = 2, tubedevice = 1, tubedevice_receiver = 1},
    paramtype2 = "facedir",
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local playername = player:get_player_name()
        if core.is_protected(pos, playername) or to_list == "dst" then
            return 0
        end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local playername = player:get_player_name()
        if core.is_protected(pos, playername) or listname == "dst" then
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local playername = player:get_player_name()
        if core.is_protected(pos, playername) then
            return 0
        end
        return stack:get_count()
    end,
    on_punch = function(pos, node, puncher)
        if not puncher or not puncher:is_player() or not type(puncher) == "userdata" then
            return
        end
        local name = puncher:get_player_name()
        if core.is_protected(pos, name) then
            core.chat_send_player(name, "You are not allowed to configure the forge here.")
            return
        end
        local dir = node.param2
        if dir > 3 then
            core.chat_send_player(name, "Please replace the controller and try to avoid using screwdriver.")
            return
        end
        if check_structure(pos, dir, name) then
            local meta = core.get_meta(pos)
            meta:set_int("multiblockactive", 1)
            local timer = core.get_node_timer(pos)
            local powerportpos = core.string_to_pos(meta:get_string("powerportpos"))
            local pmeta = core.get_meta(powerportpos)
            pmeta:set_int("HV_EU_demand", 100)
            timer:start(1)
        end
    end,
    on_timer = function(pos)
        local meta = core.get_meta(pos)
        --if the multiblock isnt built
        if meta:get_int("multiblockactive") ~= 1 then
            --dont continue the timer
            return false
        end

        --get the inventory and current process of the node
        local inv = meta:get_inventory()
        local currentprocess = meta:get_int("currentprocess")
        --if there is no process
        if meta:get_int("powered") == 0 then
            meta:set_string("infotext", "HV Forge Unpowered")
            return true
        end
        if currentprocess == 0 then
            --find a recipe
            local items = {}
            local contin = true
            for i = 1, 8 do
                local item = inv:get_stack("src", i)
                if item:is_empty() or item:get_name() == "technic_many_machines:blocker" then
                    break
                else
                    table.insert(items, inv:get_stack("src", i):get_name())
                end
            end
            local key = table.concat(items, ",")
            local recipe = technic_many_machines.forge_recipes[key]
            if recipe then
                local input = recipe.input
                local output = recipe.output
                --check if there is enough items to do the recipe
                local success = true
                for i = 1, #input do
                    local required_count = ItemStack(input[i]):get_count()
                    local currentcount = inv:get_stack("src", i):get_count()
                    if required_count > currentcount then
                        success = false
                    end
                end
                --check if there is enough output space
                if not inv:room_for_item("dst", ItemStack(output)) then
                    success = false
                end
                --now we can PROCESS
                if success then
                    meta:set_int("time_left", recipe.time)
                    meta:set_int("currentprocess", recipe.index)
                    for i = 1, #input do
                        local item_to_remove = ItemStack(input[i])
                        inv:remove_item("src", item_to_remove)
                    end
                    meta:set_string("infotext", "HV Forge Active")
                    local powerportpos = core.string_to_pos(meta:get_string("powerportpos"))
                    local pmeta = core.get_meta(powerportpos)
                    pmeta:set_int("HV_EU_demand", recipe.powerdraw)
                else
                    meta:set_string("infotext", "HV Forge Idle")
                end
            else 
                meta:set_string("infotext", "HV Forge Idle")
            end
        else
            local time_left = meta:get_int("time_left")
            meta:set_string("infotext", "HV Forge Active")
            meta:set_int("time_left", time_left - 1)
            if time_left == 0 then
                local index = meta:get_int("currentprocess")
                local recipe = technic_many_machines.forge_recipes[recipes[index]]
                local output = ItemStack(recipe.output)
                inv:add_item("dst", output)
                meta:set_int("currentprocess", 0)
                local powerportpos = core.string_to_pos(meta:get_string("powerportpos"))
                local pmeta = core.get_meta(powerportpos)
                pmeta:set_int("HV_EU_demand", 100)
            end
        end
        return true
    end,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "HV Forge Controller")
        meta:set_int("multiblockactive", 0)

        local inv = meta:get_inventory()
        inv:set_size("src", 8)
        inv:set_size("dst", 1)
    end,
    on_destruct = function(pos)
        local node = core.get_node(pos)
        local dir = node.param2
        local strpos = core.pos_to_string(pos)
        if dir < 4 then
            dirsforclear[dir](pos, strpos)
        end
    end,
    after_dig_node = pipeworks.after_dig,
	after_place_node = pipeworks.after_place,
    tube = {
	    input_inventory = "dst",
        connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
    	insert_object = function(pos, node, stack, direction, owner)
            local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
            return inv:add_item("src", stack)
        end,
        can_insert = function(pos,node,stack,direction)
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
			return inv:room_for_item("src", stack)	
		end,
    },
    on_rotate = false,
})
--rotating is bad
local sonicscrewdriver = core.registered_tools["technic:sonic_screwdriver"]
if sonicscrewdriver then
    local on_use = sonicscrewdriver.on_use
    local on_place = sonicscrewdriver.on_place

    core.override_item("technic:sonic_screwdriver", {
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type ~= "node" then
		        return itemstack
	        end
            local pos = pointed_thing.under
            local node = core.get_node(pos)
            if node.name == "technic_many_machines:hv_forge_controller" then
                return itemstack 
            end
            return on_use(itemstack, user, pointed_thing)
        end,
        on_place = function(itemstack, user, pointed_thing)
        	if pointed_thing.type ~= "node" then
		        return itemstack
	        end
            local pos = pointed_thing.under
            local node = core.get_node(pos)
            
            if node.name == "technic_many_machines:hv_forge_controller" then
                return itemstack 
            end
            return on_place(itemstack, user, pointed_thing)
        end,
    })
end