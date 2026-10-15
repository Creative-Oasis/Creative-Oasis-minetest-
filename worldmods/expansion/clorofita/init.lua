local S = minetest.get_translator("clorofita")
local herramienta = minetest.register_tool
local crafteo = minetest.register_craft
local craftitem = minetest.register_craftitem
local A = "clorofita:LDC"

herramienta("clorofita:escudoclorofita", {
    description = S("clorofite shield"),
    inventory_image = "escudodeclorofita_inv.png",
    groups = {armor_shield=1, armor_heal=10, armor_use=280} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

herramienta("clorofita:cascoclorofita", {
    description = S("clorofite helmet"),
    inventory_image = "cascoclorofita_inv.png",
    groups = {armor_head=1, armor_heal=10, armor_use=280} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

herramienta("clorofita:grebasclorofita", {
    description = S("clorofite kneepads"),
    inventory_image = "grebasclorofita_inv.png",
    groups = {armor_legs=1, armor_heal=10, armor_use=280} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

herramienta("clorofita:botasclorofita", {
    description = S("clorofite boots"),
    inventory_image = "botasclorofita_inv.png",
    groups = {armor_feet=1, armor_heal=10, armor_use=280} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

herramienta("clorofita:petoclorofita", {
    description = S("clorofite chestplate"),
    inventory_image = "petoclorofita_inv.png",
    groups = {armor_torso=1, armor_heal=10, armor_use=280} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

craftitem("clorofita:clorofitalump", {
    description = S("clorofite material"),
    inventory_image = "clorofitalump.png"
})

craftitem("clorofita:LDC", {
    description = S("clorofite ingot"),
    inventory_image = "lingotedeclorofita.png"
})

crafteo({
    type = "cooking",
    output = "clorofita:LDC",
    recipe = "clorofita:clorofitalump",
    cooktime = 7,
})

crafteo({
    output = "clorofita:picodeclorofita",
    recipe = {
        {A, A, A},
        {"", "default:stick", ""},
        {"", "default:stick", ""},
    },
})

crafteo({
    output = "clorofita:espadaclorofita",
    recipe = {
        {"", A, ""},
        {"", A, ""},
        {"", "default:stick", ""},
    },
})

crafteo({
    output = "clorofita:hachadeclorofita",
    recipe = {
        {A, A, ""},
        {A, "default:stick", ""},
        {"", "default:stick", ""},
    },
})

minetest.register_node("clorofita:clorofitaore", {
    description = S("clorofite ore"),
    tiles = {"clorofita_mineral.png"},
    is_ground_content = false,
    groups = {cracky = 1, level = 7},
    drop = "clorofita:clorofitalump"
})

    minetest.register_ore({
        ore_type       = "scatter",
        ore            = "clorofita:clorofitaore",
        wherein        = "default:stone",
        clust_scarcity = 24 * 23 * 24,
        clust_num_ores = 4,
        clust_size     = 4,
        y_max          = -18000,
        y_min          = -31000,
})

minetest.register_node("clorofita:bloqueclorofita", {
    description = S("clorofite block"),
    tiles = {"bloqueclorofita.png"},
    groups = {cracky = 1, level = 2},
})

herramienta("clorofita:hachadeclorofita", {
    description = S("clorofite axe"),
    inventory_image = "hachadeclorofita.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            choppy = {
                maxlevel = 4.1,
                uses = 80,
                times = { [1]=1.40, [2]=1.20, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=1},
    },
    sound = {breaks = "tool_breaks"},
})

herramienta("clorofita:picodeclorofita", {
    description = S("clorofite pickaxe"),
    inventory_image = "picodeclorofita.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            cracky = {
                maxlevel = 8,
                uses = 90,
                times = { [1]=1.40, [2]=1.20, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=1},
    },
    sound = {breaks = "tool_breaks"},
})

herramienta("clorofita:espadaclorofita", {
    description = S("clorofite sword"),
    inventory_image = "espadaclorofita.png",
    tool_capabilities = {
        full_punch_interval = 1.4,
        max_drop_level = 0,
        groupcaps = {
            fleshy = {
                maxlevel = 4,
                uses = 70,
                times = { [1]=1.40, [2]=1.20, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=13},
    },
    sound = {breaks = "tool_breaks"},
})

crafteo({
    output = "clorofita:petoclorofita",
    recipe = {
        {A, "", A},
        {A, A, A},
        {A, A, A},
    },
})

crafteo({
    output = "clorofita:cascoclorofita",
    recipe = {
        {A, A, A},
        {A, "", A},
        {"", "", ""},
    },
})

crafteo({
    output = "clorofita:grebasclorofita",
    recipe = {
        {A, A, A},
        {A, "", A},
        {A, "", A},
    },
})

crafteo({
    output = "clorofita:botasclorofita",
    recipe = {
        {"", "", ""},
        {A, "", A},
        {A, "", A},
    },
})

crafteo({
    output = "clorofita:escudoclorofita",
    recipe = {
        {A, A, A},
        {A, A, A},
        {"", A, ""},
    },
})

crafteo({
    output = "clorofita:bloqueclorofita",
    recipe = {
        {A, A, A},
        {A, A, A},
        {A, A, A},
    },
})