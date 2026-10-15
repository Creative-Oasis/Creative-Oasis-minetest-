--shorter name
local tmm = technic_many_machines
--this will be used over core.hash_node_pos since its numbers are too big
local postoint = tmm.postoint
local inttopos = tmm.inttopos
--translator
local S = core.get_translator("technic_many_machines")
--all coordinate types
local coords_fields = {"x1", "y1", "z1", "x2", "y2", "z2"}
--picked this since it sounded fancy
--this is to compare one coordinate with another of a same type while knowing what kind of coordinate it is.
local comparison_field = {
    ["x1"] = {"x2", "x"},
    ["y1"] = {"y2", "y"},
    ["z1"] = {"z2", "z"},
}

--formspec made with this: https://luk3yx.gitlab.io/minetest-formspec-editor/
local function get_formspec(status)
    local textstatus = "false"
    if status == true then
        textstatus = "true"
    end
    local formspec = "formspec_version[6]"
    .."size[10.5,9.25]"
    .."list[context;upgrades;0.4,2.9;6,1;0]"
    .."field[7.5,0.7;0.8,0.5;x1;   x;${x1}]"
    .."field[8.4,0.7;0.8,0.5;y1;   y;${y1}]"
    .."field[9.3,0.7;0.8,0.5;z1;   z;${z1}]"
    .."field[7.5,2;0.8,0.5;x2;   x;${x2}]"
    .."field[8.4,2;0.8,0.5;y2;   y;${y2}]"
    .."field[9.3,2;0.8,0.5;z2;   z;${z2}]"
    .."label[6.5,0.9;Pos1]"
    .."label[6.5,2.2;Pos2]"
    .."list[current_player;main;0.4,4.1;8,4;0]"
    .."list[context;main;0.4,0.4;5,2;0]"
    .."checkbox[8.3,3.3;on;Start;" .. textstatus .. "]"
    .."box[0.4,2.9;1,1;#000000]"
    .."box[1.65,2.9;1,1;#000000]"
    .."box[2.9,2.9;1,1;#000000]"
    .."box[4.15,2.9;1,1;#000000]"
    .."box[5.4,2.9;1,1;#000000]"
    .."box[6.65,2.9;1,1;#000000]"

    return formspec
end

--toggles machine on and off
local function toggle_machine(meta)
    local state = meta:get_int("toggle")
    if state == 0 then
        meta:set_int("toggle", 1)
        meta:set_string("formspec", get_formspec(true))
        meta:set_string("HV_EU_demand", 5000)
    else
        meta:set_int("toggle", 0)
        meta:set_string("formspec", get_formspec(false))
        meta:set_string("HV_EU_demand", 0)
        meta:set_string("infotext", "HV Area Miner Idle")
        meta:set_int("targetpos", 0)
    end
end
--checks if the machine is on
local function machine_is_on(meta)
    local state = meta:get_int("toggle")
    if state == 1 then
        return true
    end
    return false
end
--gets the position to mine at, incrementing it afterwards
local function get_target_pos(meta)
    --get stored target position
    local targetposint = meta:get_int("targetpos")
    --get stored starting position
    local pos2int = meta:get_int("pos2")
    local pos2 = inttopos(pos2int)
    --if it exists
    if targetposint > 0 then
        local targetpos = inttopos(targetposint)
        local pos1 = inttopos(meta:get_int("pos1"))
        if targetpos.x > pos1.x then
            targetpos.x = targetpos.x - 1
            meta:set_int("targetpos", postoint(targetpos))
            return targetpos
        elseif targetpos.z > pos1.z then
            targetpos.z = targetpos.z - 1
            targetpos.x = pos2.x
            meta:set_int("targetpos", postoint(targetpos))
            return targetpos
        elseif targetpos.y > pos1.y then
            targetpos.y = targetpos.y - 1
            targetpos.z = pos2.z
            targetpos.x = pos2.x
            meta:set_int("targetpos", postoint(targetpos))
            return targetpos
        end
    end
    meta:set_int("targetpos", pos2int)
    return pos2
end

--does the digging part
local function do_dig(pos, meta, node, owner)
    local filtertype = meta:get_string("filtertype")
    if filtertype == "whitelist" then
        local nodename = node.name
        if meta:get_int(nodename) == 1 then
            return tmm.dig_node(meta, pos, {name = owner, node = node})
        end
    elseif filtertype == "blacklist" then
        local nodename = node.name
        if meta:get_int(nodename) ~= 1 then
            return tmm.dig_node(meta, pos, {name = owner, node = node})
        end
    else
        return tmm.dig_node(meta, pos, {name = owner, node = node})
    end
end

local animtiles = {
    name = "technic_many_machines_hv_areaminer.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25,
    },
}

local valid_upgrades = {
    ["technic_many_machines:whitelist_upgrade"] = true,
    ["technic_many_machines:blacklist_upgrade"] = true,
}

local filter_upgrades = {
    ["technic_many_machines:whitelist_upgrade"] = true,
    ["technic_many_machines:blacklist_upgrade"] = true
}

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    return 0
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    local playername = player:get_player_name()
    if core.is_protected(pos, playername) then
        return 0
    end
    if listname == "main" then
        return stack:get_count()
    elseif listname == "upgrades" then
        local meta = core.get_meta(pos)

        local upgname = stack:get_name()
        if not valid_upgrades[upgname] then
            return 0
        end

        if filter_upgrades[upgname] then

            local has_filter_upgrade = meta:get_string("filtertype")
            if has_filter_upgrade ~= "" then
                return 0
            end

            local filterdata = stack:get_meta():to_table().fields

            local filtertype

            if upgname == "technic_many_machines:whitelist_upgrade" then
                filtertype = "whitelist"
            else
                filtertype = "blacklist"
            end

            meta:set_string("filtertype", filtertype)

            for item, num in pairs(filterdata) do
                if num == "1" then
                    meta:set_int(item, 1)
                end
            end
        end

        return stack:get_count()
    end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    local playername = player:get_player_name()
    if core.is_protected(pos, playername) then
        return 0
    end
    if listname == "main" then
        return stack:get_count()
    elseif listname == "upgrades" then
        local meta = core.get_meta(pos)
        local upgname = stack:get_name()

        if filter_upgrades[upgname] then

            local filterdata = stack:get_meta():to_table().fields

            meta:set_string("filtertype", "")

            for item, num in pairs(filterdata) do
                if num == "1" then
                    meta:set_int(item, 0)
                end
            end
        end
        return stack:get_count()
    end
end


core.register_node("technic_many_machines:hv_areaminer", {
    description = S("HV Area Miner"),
    is_ground_content = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, technic_machine = 1, technic_hv = 1},

    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        animtiles,
        animtiles,
        animtiles,
        animtiles,
    },
    tube = {
	    input_inventory = "main",
    },

    
    on_receive_fields = function(pos, formname, fields, sender)
        local name = fields.name
        local meta = core.get_meta(pos)

        --toggle machine if on button was pressed
        
        if fields.on then
            toggle_machine(meta)
        end
        local coords_updated = false
        local coords = {}
        --get all inputted coordinates
        for index, field in ipairs(coords_fields) do
            local coord = tonumber(fields[field])
            if coord then
                coords[field] = coord
                --limit it to 30 in each direction
                coord = math.max(math.min(30, coord), -30)
                local existing_coord = meta:get_int(field)
                --only change if the number changed
                if coord ~= existing_coord then
                    meta:set_int(field, coord)
                    coords[field] = coord
                    coords_updated = true
                end
            end
        end
        --if the coordinates updated, get the 2 corners
        if coords_updated then
            local pos1 = {}
            local pos2 = {}
            for coord1, coord2 in pairs(comparison_field) do
                if coords[coord1] < coords[coord2[1]] then
                    pos1[coord2[2]] = coords[coord1]
                    pos2[coord2[2]] = coords[coord2[1]]
                else
                    pos1[coord2[2]] = coords[coord2[1]]
                    pos2[coord2[2]] = coords[coord1]
                end
            end
            --and store them
            local pos1int = postoint(pos1)
            local pos2int = postoint(pos2)
            meta:set_int("pos1", pos1int)
            meta:set_int("pos2", pos2int)
        end
    end,

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local timer = core.get_node_timer(pos)

        local inv = meta:get_inventory()
        for _, coord in ipairs(coords_fields) do
            meta:set_int(coord, 0)
        end
        inv:set_size("main", 10)
        inv:set_size("upgrades", 6)
        meta:set_int("HV_EU_demand", 0)
        meta:set_string("formspec", get_formspec(false))
        meta:set_string("active", "Turn On")
        meta:set_string("infotext", "HV Area Miner Idle")
        timer:start(1)
    end,

    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer:is_player() and type(placer) == "userdata" then
            local meta = core.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
        end
    end,

    technic_run = function(pos, node)
        local meta = core.get_meta(pos)
        if machine_is_on(meta) then
            local input = meta:get_int("HV_EU_input")

            if input >= 5000 then
                meta:set_string("infotext", S("HV Area Miner Active"))
                local targetpos = get_target_pos(meta)
                targetpos.x = targetpos.x + pos.x
                targetpos.y = targetpos.y + pos.y
                targetpos.z = targetpos.z + pos.z
                if not tmm.positions_are_equal(pos, targetpos) then
                    local owner = meta:get_string("owner")
                    local node_to_dig = core.get_node(targetpos)
                    do_dig(targetpos, meta, node_to_dig, owner)
                end
            else
                meta:set_string("infotext", S("HV Area Miner Unpowered"))
            end
        else
            meta:set_string("infotext", "HV Area Miner Idle")
        end
    end,

    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put =  allow_metadata_inventory_put,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})
technic.register_machine("HV", "technic_many_machines:hv_areaminer", technic.receiver)

if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_areaminer"}, {
        on_push_item = function(pos, in_dir, stack)
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "main", stack)
        end,
        on_pull_item = function(pos, out_dir, count)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.get_items(pos, inv, "main", count)
        end,
        on_unpull_item = function(pos, out_dir, stack)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "main", stack)
        end,
    })
end