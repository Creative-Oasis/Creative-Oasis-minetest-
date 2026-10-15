-- Leaves that should NOT be converted to cubes
local keep_original = {
    ["ethereal:willow_twig"] = true,
    --["default:leaves"] = true,
}

minetest.register_on_mods_loaded(function()
    for nodename, def in pairs(minetest.registered_nodes) do
        if def.groups and def.groups.leaves then
            -- Skip leaves in exception list
            if not keep_original[nodename] then
                minetest.override_item(nodename, {
                    drawtype = "allfaces_optional",
                    paramtype = "light",

                    node_box = nil,
                    selection_box = nil,
                    collision_box = nil,
                    visual_scale = 1,
                    waving = 0,
                })
            end
        end
    end

    minetest.log("action",
        "[comod_leaves] Leaves converted to cubes (exceptions respected)")
end)
