
replacer_technic = {
    -- 2x MkII drill.
    charge = 400000,

    -- Nodes that can be replaced per full charge.
    nodes = 3000,

    -- Maximum square mode.
    max_square = 3,

    blacklist = {},
}

replacer_technic.per =
    replacer_technic.charge / replacer_technic.nodes

function replacer_technic.register_blacklisted_node(name)
    replacer_technic.blacklist[name] = true
end

replacer_technic.register_blacklisted_node("air")
replacer_technic.register_blacklisted_node("ignore")

local name = {
    "Node",
    "3x3",
    "5x5",
}

for i = 1, replacer_technic.max_square do
    for _, place in ipairs((i == 1) and {false, true} or {false}) do
        local ncur = "replacer_technic:replacer" .. i
        local nnext = "replacer_technic:replacer" ..
            ((i == replacer_technic.max_square) and 1 or (i + 1))

        local desc = "Node Replacer (" .. (name[i] or "Square " .. i) .. ")"

        if place then
            ncur = "replacer_technic:replacer_p"
            nnext = "replacer_technic:replacer_p"
            desc = "Node Replacer (Place)"
        end

        technic.register_power_tool(ncur, replacer_technic.charge)

        local function handle_meta(s, selected_node)
            local meta = minetest.deserialize(s:get_metadata())

            if not meta or not meta.charge then
                meta = {
                    charge = 0,
                }
            end

            meta.item = selected_node or
                ((meta.item and meta.item.name) and meta.item) or {
                    name = "default:cobble",
                    param1 = 0,
                    param2 = 0,
                }

            s:set_metadata(minetest.serialize(meta))

            local def = minetest.registered_items[s:get_name()]

            if def then
                s:get_meta():set_string(
                    "description",
                    def.description .. " (" ..
                    meta.item.name .. " " ..
                    (meta.item.param1 or 0) .. " " ..
                    (meta.item.param2 or 0) .. ")"
                )
            end

            return s, meta.item
        end

        minetest.register_tool(ncur, {
            description = desc,

            inventory_image =
                "replacer_replacer.png^technic_tool_mode" .. i .. ".png",

            wield_image = "replacer_replacer.png",
            liquids_pointable = true,

            groups = {
                not_in_creative_inventory = (i == 1) and 0 or 1,
            },

            wear_represents = "technic_RE_charge",
            on_refill = technic.refill_RE_charge,

            on_place = function(itemstack, user, pointed_thing)
                local player_name = user:get_player_name()

                if user:get_player_control().aux1 then
                    itemstack:set_name(
                        place and "replacer_technic:replacer1"
                        or "replacer_technic:replacer_p"
                    )

                    itemstack = handle_meta(itemstack)

                    minetest.chat_send_player(
                        player_name,
                        minetest.registered_items[
                            itemstack:get_name()
                        ].description
                    )

                    return itemstack
                end

                local function set_node()
                    if pointed_thing.type ~= "node" then
                        minetest.chat_send_player(
                            player_name,
                            "Error: No node selected."
                        )
                        return itemstack
                    end

                    local pos =
                        minetest.get_pointed_thing_position(pointed_thing)

                    local pointed_node = minetest.get_node_or_nil(pos)

                    if not pointed_node then
                        minetest.chat_send_player(
                            player_name,
                            "Error: Node not yet loaded."
                        )
                        return itemstack
                    end

                    if replacer_technic.blacklist[pointed_node.name] then
                        minetest.chat_send_player(
                            player_name,
                            "You cannot use that node in a replacer."
                        )
                        return itemstack
                    end

                    itemstack = handle_meta(itemstack, pointed_node)

                    minetest.chat_send_player(
                        player_name,
                        "Node Replacer: " .. pointed_node.name
                    )

                    return itemstack
                end

                if user:get_player_control().sneak then
                    if place then
                        return set_node()
                    end

                    itemstack:set_name(nnext)
                    itemstack = handle_meta(itemstack)

                    minetest.chat_send_player(
                        player_name,
                        minetest.registered_items[nnext].description
                    )

                    return itemstack
                end

                if place then
                    return minetest.registered_items[ncur].on_use(
                        itemstack,
                        user,
                        pointed_thing,
                        true
                    )
                end

                return set_node()
            end,

            on_use = function(itemstack, user, pointed_thing, do_place)
                local player_name = user:get_player_name()
                local _, item = handle_meta(itemstack)

                if pointed_thing.type ~= "node" then
                    minetest.chat_send_player(
                        player_name,
                        "Error: No node selected."
                    )
                    return itemstack
                end

                local pos = minetest.get_pointed_thing_position(
                    pointed_thing,
                    do_place
                )

                local node = minetest.get_node_or_nil(pos)

                if not node then
                    minetest.chat_send_player(
                        player_name,
                        "Error: Node not yet loaded."
                    )
                    return itemstack
                end

                -- Place mode fills air; normal mode replaces a selected node.
                if not do_place and
                        replacer_technic.blacklist[node.name] then
                    minetest.chat_send_player(
                        player_name,
                        "You cannot use that node in a replacer."
                    )
                    return itemstack
                end

                -- Find the plane perpendicular to the player's look direction.
                local look = user:get_look_dir()
                local extreme = "x"

                for _, c in ipairs({"y", "z"}) do
                    if math.abs(look[c]) > math.abs(look[extreme]) then
                        extreme = c
                    end
                end

                local coords = {
                    x = true,
                    y = true,
                    z = true,
                }

                coords[extreme] = nil

                local r = vector.new()

                for c in pairs(coords) do
                    r[c] = i - 1
                end

                local min_pos = vector.subtract(pos, r)
                local max_pos = vector.add(pos, r)

                local nodes

                if do_place then
                    -- Place mode targets empty positions.
                    nodes = minetest.find_nodes_in_area(
                        min_pos,
                        max_pos,
                        {"air"}
                    )
                else
                    -- Normal mode targets matching node types.
                    nodes = minetest.find_nodes_in_area(
                        min_pos,
                        max_pos,
                        {node.name}
                    )
                end

                local inv = user:get_inventory()

                if not inv then
                    return itemstack
                end

                -- Filter out protected or ineligible positions.
                local allowed_nodes = {}

                for _, p in ipairs(nodes) do
                    local current_node = minetest.get_node_or_nil(p)

                    if current_node and
                            not minetest.is_protected(p, player_name) then
                        if do_place then
                            if current_node.name == "air" then
                                table.insert(allowed_nodes, p)
                            end
                        elseif current_node.name == node.name then
                            table.insert(allowed_nodes, p)
                        end
                    end
                end

                if #allowed_nodes == 0 then
                    minetest.chat_send_player(
                        player_name,
                        "Error: No replaceable nodes."
                    )
                    return itemstack
                end

                -- Count replacement items in the player's inventory.
                local available = 0
                local stacks = inv:get_list("main") or {}

                for _, stack in ipairs(stacks) do
                    if stack:get_name() == item.name then
                        available = available + stack:get_count()
                    end
                end

                if available < #allowed_nodes then
                    minetest.chat_send_player(
                        player_name,
                        "Error: Inventory does not contain necessary items."
                    )
                    return itemstack
                end

                -- Check charge before modifying nodes.
                local meta = minetest.deserialize(itemstack:get_metadata())

                if not meta or type(meta.charge) ~= "number" then
                    meta = {
                        charge = 0,
                    }
                end

                local cost =
                    replacer_technic.per * #allowed_nodes

                if meta.charge < cost then
                    minetest.chat_send_player(
                        player_name,
                        "Error: Not enough charge."
                    )
                    return itemstack
                end

                local replaced = 0

                for _, p in ipairs(allowed_nodes) do
                    local current_node = minetest.get_node_or_nil(p)

                    if current_node and
                            not minetest.is_protected(p, player_name) then
                        local eligible

                        if do_place then
                            eligible = current_node.name == "air"
                        else
                            eligible = current_node.name == node.name
                        end

                        if eligible then
                            local removed = inv:remove_item(
                                "main",
                                ItemStack(item.name)
                            )

                            if not removed:is_empty() then
                                if do_place then
                                    -- Place directly into the air target.
                                    minetest.set_node(p, item)
                                    replaced = replaced + 1
                                else
                                    -- Normal mode digs before placing.
                                    minetest.node_dig(p, current_node, user)

                                    local after = minetest.get_node_or_nil(p)

                                    if after and after.name == "air" then
                                        minetest.set_node(p, item)
                                        replaced = replaced + 1
                                    else
                                        -- Restore the item if digging failed.
                                        inv:add_item("main", removed)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Charge only for successful replacements.
                if replaced > 0 then
                    meta.charge = math.max(
                        0,
                        meta.charge -
                        replacer_technic.per * replaced
                    )

                    technic.set_RE_wear(
                        itemstack,
                        meta.charge,
                        replacer_technic.charge
                    )

                    itemstack:set_metadata(minetest.serialize(meta))
                end

                return itemstack
            end,
        })
    end
end

minetest.register_alias(
    "replacer_technic:replacer",
    "replacer_technic:replacer1"
)

-- Optional legacy aliases for existing worlds and inventories.
minetest.register_alias(
    "replacer:replacer",
    "replacer_technic:replacer1"
)

minetest.register_alias(
    "replacer:replacer1",
    "replacer_technic:replacer1"
)

minetest.register_alias(
    "replacer:replacer2",
    "replacer_technic:replacer2"
)

minetest.register_alias(
    "replacer:replacer3",
    "replacer_technic:replacer3"
)

minetest.register_alias(
    "replacer:replacer_p",
    "replacer_technic:replacer_p"
)

for _, drill in ipairs({"", "_1", "_2", "_3", "_4", "_5"}) do
    minetest.register_craft({
        output = "replacer_technic:replacer1",
        recipe = {
            {
                "technic:diamond_drill_head",
                "technic:mining_drill_mk3" .. drill,
                "technic:diamond_drill_head",
            },
            {
                "technic:stainless_steel_ingot",
                "technic:motor",
                "technic:stainless_steel_ingot",
            },
            {
                "pipeworks:filter",
                "technic:blue_energy_crystal",
                "default:copper_ingot",
            },
        },
    })
end
