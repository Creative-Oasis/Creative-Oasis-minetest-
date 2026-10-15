local old_register_node_func = core.register_node
core.register_node = function(name, nodedef)
    if type(nodedef) == "table" and nodedef.groups and nodedef.groups.leaves and nodedef.groups.leaves >= 1 and nodedef.post_effect_color == nil then
        nodedef.post_effect_color = {a = 60, r = 0, g = 160, b = 0}
    end
    old_register_node_func(name, nodedef)
end