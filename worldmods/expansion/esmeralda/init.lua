local S = minetest.get_translator("esmeralda")

minetest.register_node("esmeralda:ore", {
    description = S("esmeralda ore"),
    tiles = {"esmeralda_ore.png"},
    is_ground_content = false,
    groups = {cracky = 1, level = 2},
    drop = "esmeralda:esmeralda",
    light_source = 4,
})

minetest.register_ore({
        ore_type       = "scatter",
        ore            = "esmeralda:ore",
        wherein        = "default:stone",
        clust_scarcity = 30 * 20 * 30,
        clust_num_ores = 2,
        clust_size     = 2,
        y_max          = -1,
        y_min          = -31000,
 })

--minetest.register_node("esmeralda:bloque", {
--    description = S("esmeralda bloque"),
 --   tiles = {"bloque.png"},
 --   groups = {cracky = 1, level = 2},
--})

minetest.register_craftitem("esmeralda:esmeralda", {
    description = S("esmeralda"),
    inventory_image = "esmeralda.png"
})
