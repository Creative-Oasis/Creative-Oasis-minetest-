if minetest.global_exists("armor") and armor.elements then
    table.insert(armor.elements, "shield")
end
local tool = minetest.register_tool
local S = minetest.get_translator("tugsteno")
local craft = minetest.register_craft
local craftitem = minetest.register_craftitem
local A = "tugsteno:LDTO"

tool("tugsteno:hachadetugsteno", {
    description = S("tugsten axe"),
    inventory_image = "hachadetugsteno.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            choppy = {
                maxlevel = 3.5,
                uses = 60,
                times = { [1]=1.50, [2]=1.50, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=3},
    },
    sound = {breaks = "tool_breaks"},
})

tool("tugsteno:picodetugsteno", {
    description = S("tugsten pickaxe"),
    inventory_image = "picodetugsteno.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            cracky = {
                maxlevel = 7,
                uses = 60,
                times = { [1]=1.50, [2]=1.50, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=2},
    },
    sound = {breaks = "tool_breaks"},
})

tool("tugsteno:espadatugsteno", {
    description = S("tugsten sword"),
    inventory_image = "espadatugsteno.png",
    tool_capabilities = {
        full_punch_interval = 1.9,
        max_drop_level = 0,
        groupcaps = {
            fleshy = {
                maxlevel = 4,
                uses = 60,
                times = { [1]=1.50, [2]=1.50, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=12.5},
    },
    sound = {breaks = "tool_breaks"},
})

minetest.register_node("tugsteno:tugstenoore", {
    description = S("tugsten ore"),
    tiles = {"mod6.png"},
    is_ground_content = false,
    groups = {cracky = 1, level = 6},
    drop = "tugsteno:tugstenolump"
})

minetest.register_ore({
        ore_type       = "scatter",
        ore            = "tugsteno:tugstenoore",
        wherein        = "default:stone",
        clust_scarcity = 20 * 19 * 20,
        clust_num_ores = 5,
        clust_size     = 3,
        y_max          = -14000,
        y_min          = -31000,
 })

minetest.register_node("tugsteno:bloquetugsteno", {
    description = S("tugsten block"),
    tiles = {"bloquetugsteno.png"},
    groups = {cracky = 1, level = 2},
})

craftitem("tugsteno:tugstenolump", {
    description = S("tugsten lump"),
    inventory_image = "tugstenolump.png"
})

craftitem("tugsteno:LDTO", {
    description = S("tugsten ingot"),
    inventory_image = "lingotedetugsteno.png"
})

craft({
    type = "cooking",
    output = "tugsteno:LDTO",
    recipe = "tugsteno:tugstenolump",
    cooktime = 10,
})

craft({
    output = "tugsteno:picodetugsteno",
    recipe = {
        {A, A, A},
        {"", "default:stick", ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "tugsteno:espadatugsteno",
    recipe = {
        {"", A, ""},
        {"", A, ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "tugsteno:hachadetugsteno",
    recipe = {
        {A, A, ""},
        {A, "default:stick", ""},
        {"", "default:stick", ""},
    },
})

tool("tugsteno:escudotugsteno", {
    description = S("tugsten shield"),
    inventory_image = "escudotugsteno_inv.png",
    groups = {armor_shield=1, armor_heal=9, armor_use=250} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("tugsteno:petotugsteno", {
    description = S("tugsten chestplate"),
    inventory_image = "petotugsteno_inv.png",
    groups = {armor_torso=1, armor_heal=9, armor_use=250} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("tugsteno:cascotugsteno", {
    description = S("tugsten helmet"),
    inventory_image = "cascotugsteno_inv.png",
    groups = {armor_head=1, armor_heal=8, armor_use=250} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("tugsteno:grebastugsteno", {
    description = S("tugsten kneepads"),
    inventory_image = "grebastugsteno_inv.png",
    groups = {armor_legs=1, armor_heal=9, armor_use=250} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("tugsteno:botastugsteno", {
    description = S("tugsten boots"),
    inventory_image = "botastugsteno_inv.png",
    groups = {armor_feet=1, armor_heal=8, armor_use=250} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

craft({
    output = "tugsteno:petotugsteno",
    recipe = {
        {A, "", A},
        {A, A, A},
        {A, A, A},
    },
})

craft({
    output = "tugsteno:cascotugsteno",
    recipe = {
        {A, A, A},
        {A, "", A},
        {"", "", ""},
    },
})

craft({
    output = "tugsteno:grebastugsteno",
    recipe = {
        {A, A, A},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "tugsteno:botastugsteno",
    recipe = {
        {"", "", ""},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "tugsteno:escudotugsteno",
    recipe = {
        {A, A, A},
        {A, A, A},
        {"", A, ""},
    },
})

craft({
    output = "tugsteno:bloquetugsteno",
    recipe = {
        {A, A, A},
        {A, A, A},
        {A, A, A},
    },
})