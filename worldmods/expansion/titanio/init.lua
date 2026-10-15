if minetest.global_exists("armor") and armor.elements then
    table.insert(armor.elements, "shield")
end
local tool = minetest.register_tool
local craft = minetest.register_craft
local craftitem = minetest.register_craftitem
local S = minetest.get_translator("titanio")
local A = "titanio:LDT"

tool("titanio:grebastitanio", {
    description = S("titanium kneepads"),
    inventory_image = "grebas_titanio_inv.png",
    groups = {armor_legs=1, armor_heal=9.5, armor_use=200} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("titanio:botastitanio", {
    description = S("titanium boots"),
    inventory_image = "botas_titanio_inv.png",
    groups = {armor_feet=1, armor_heal=9.5, armor_use=200} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("titanio:petotitanio", {
    description = S("titanium chestplate"),
    inventory_image = "peto_titanio_inv.png",
    groups = {armor_torso=1, armor_heal=9.5, armor_use=200} ,
    wear = 0,
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("titanio:cascotitanio", {
    description = S("titanium helmet"),
    inventory_image = "casco_titanio_inv.png",
    groups = {armor_head=1, armor_heal=9.5, armor_use=200} ,
    wear = 0,
    armor_groups = {fleshy=9},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("titanio:escudotitanio", {
    description = S("titanium shield"),
    inventory_image = "escudotitanio_inv.png",
    groups = {armor_shield=1, armor_heal=9.5, armor_use=200} ,
    wear = 0,
    armor_groups = {fleshy=9},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

craftitem("titanio:titaniolump", {
    description = S("titanium lump"),
    inventory_image = "titaniolump.png"
})

craftitem("titanio:LDT", {
    description = S("titanium ingot"),
    inventory_image = "lingotedetitanio.png"
})

craft({
    type = "cooking",
    output = "titanio:LDT",
    recipe = "titanio:titaniolump",
    cooktime = 8,
})

craft({
    output = "titanio:picodetitanio",
    recipe = {
        {A, A, A},
        {"", "default:stick", ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "titanio:espadatitanio",
    recipe = {
        {"", A, ""},
        {"", A, ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "titanio:hachadetitanio",
    recipe = {
        {A, A, ""},
        {A, "default:stick", ""},
        {"", "default:stick", ""},
    },
})

minetest.register_node("titanio:titanioore", {
    description = S("titanium ore"),
    tiles = {"ore.png"},
    is_ground_content = true,
    groups = {cracky = 1, level = 5},
    drop = "titanio:titaniolump"
})

    minetest.register_ore({
        ore_type       = "scatter",
        ore            = "titanio:titanioore",
        wherein        = "default:stone",
        clust_scarcity = 17 * 15 * 14,
        clust_num_ores = 4,
        clust_size     = 4,
        y_max          = -7000,
        y_min          = -31000,
})

minetest.register_node("titanio:bloquetitanio", {
    description = S("titanium block"),
    tiles = {"bloquetitanio.png"},
    groups = {cracky = 1, level = 2},
})

tool("titanio:picodetitanio", {
    description = S("titanium pickaxe"),
    inventory_image = "picodetitanio.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            cracky = {
                maxlevel = 6,
                uses =50,
                times = { [1]=1.70, [2]=1.70, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=1},
    },
})

tool("titanio:espadatitanio", {
    description = S("titanium sword"),
    inventory_image = "espadatitanio.png",
    tool_capabilities = {
        full_punch_interval = 1.7,
        max_drop_level = 0,
        groupcaps = {
            fleshy = {
                maxlevel = 4.5,
                uses = 50,
                times = { [1]=1.70, [2]=1.70, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=12},
    },
    sound = {breaks = "tool_breaks"},
})

tool("titanio:hachadetitanio", {
    description = S("titanium axe"),
    inventory_image = "hachadetitanio.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 0,
        groupcaps = {
            choppy = {
                maxlevel = 4,
                uses = 40,
                times = { [1]=1.70, [2]=1.70, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=1},
    },
    sound = {breaks = "tool_breaks"},
})


craft({
    output = "titanio:petotitanio",
    recipe = {
        {A, "", A},
        {A, A, A},
        {A, A, A},
    },
})

craft({
    output = "titanio:cascotitanio",
    recipe = {
        {A, A, A},
        {A, "", A},
        {"", "", ""},
    },
})

craft({
    output = "titanio:grebastitanio",
    recipe = {
        {A, A, A},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "titanio:botastitanio",
    recipe = {
        {"", "", ""},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "titanio:escudotitanio",
    recipe = {
        {A, A, A},
        {A, A, A},
        {"", A, ""},
    },
})

craft({
    output = "titanio:bloquetitanio",
    recipe = {
        {A, A, A},
        {A, A, A},
        {A, A, A},
    },
})