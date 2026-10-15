--UPGRADES
--whitelist upgrade for applicable machines
local S = core.get_translator()
core.register_tool("technic_many_machines:whitelist_upgrade", {
    description = S("Whitelist Upgrade"),
    inventory_image = "technic_many_machines_whitelist_upgrade.png",
    on_place = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local meta = itemstack:get_meta()
            meta:set_int(node.name, 1)
            if user.get_player_name and user:get_player_name() then
                core.chat_send_player(user:get_player_name(), "Added " .. node.name .. " to whitelist")
            end
            return itemstack
        end
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
        if type(user) == "userdata" then
            local name = user:get_player_name()
            local meta = itemstack:get_meta()
            local metatable = meta:to_table()
            core.chat_send_player(name, "Filtered Items:")
            print(dump(meta:to_table()))
            for item, num in pairs(metatable.fields) do
                if num == "1" then
                    core.chat_send_player(name, item)
                end
            end
        end
    end,

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local meta = itemstack:get_meta()
            meta:set_int(node.name, 0)
            if user.get_player_name and user:get_player_name() then
                core.chat_send_player(user:get_player_name(), "Removed " .. node.name .. " from whitelist")
            end
            return itemstack
        end
    end,
})
--blacklist upgrade for applicable machines
--whitelist upgrade for applicable machines
local S = core.get_translator()
core.register_tool("technic_many_machines:blacklist_upgrade", {
    description = S("Blacklist Upgrade"),
    inventory_image = "technic_many_machines_blacklist_upgrade.png",
    on_place = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local meta = itemstack:get_meta()
            meta:set_int(node.name, 1)
            if user.get_player_name and user:get_player_name() then
                core.chat_send_player(user:get_player_name(), "Added " .. node.name .. " to blacklist")
            end
            return itemstack
        end
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
        if type(user) == "userdata" then
            local name = user:get_player_name()
            local meta = itemstack:get_meta()
            local metatable = meta:to_table()
            core.chat_send_player(name, "Filtered Items:")
            print(dump(meta:to_table()))
            for item, num in pairs(metatable.fields) do
                if num == "1" then
                    core.chat_send_player(name, item)
                end
            end
        end
    end,

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local meta = itemstack:get_meta()
            meta:set_int(node.name, 0)
            if user.get_player_name and user:get_player_name() then
                core.chat_send_player(user:get_player_name(), "Removed " .. node.name .. " from blacklist")
            end
            return itemstack
        end
    end,
})