local S = minetest.get_translator("obsidiana")
local LDO = laminadeobsidiana
local tool = minetest.register_tool
local craft = minetest.register_craft
local craftitem = minetest.register_craftitem
local A = "obsidiana:LDO"

tool("obsidiana:grebasobsidiana", {
    description = S("obsidian kneepads"),
    inventory_image = "grebasobsidiana_inv.png",
    groups = {armor_legs=1, armor_heal=7, armor_use=180} ,
    wear = 0,
    armor_groups = {fleshy=6},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("obsidiana:escudoobsidiana", {
    description = S("obsidian shield"),
    inventory_image = "escudoobsidiana_inv.png",
    groups = {armor_shield=1, armor_heal=7, armor_use=180} ,
    wear = 0,
    armor_groups = {fleshy=7},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("obsidiana:botasobsidiana", {
    description = S("obsidian boots"),
    inventory_image = "botasobsidiana_inv.png",
    groups = {armor_feet=1, armor_heal=6, armor_use=180} ,
    wear = 0,
    armor_groups = {fleshy=6},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})


tool("obsidiana:petoobsidiana", {
    description = S("obsidian chestplate"),
    inventory_image = "petoobsidiana_inv.png",
    groups = {armor_torso=1, armor_heal=7, armor_use=180} ,
    wear = 0,
    armor_groups = {fleshy=7},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

tool("obsidiana:cascoobsidiana", {
    description = S("obsidian helmet"),
    inventory_image = "cascoobsidiana_inv.png",
    groups = {armor_head=1, armor_heal=6, armor_use=180} ,
    wear = 0,
    armor_groups = {fleshy=6},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},

})

craftitem("obsidiana:LDO", {
    description = S("obsidian sheet"),
    inventory_image = "laminaobsidiana.png"
})

craft({
    type = "cooking",
    output = "obsidiana:LDO",
    recipe = "default:obsidian",
    cooktime = 8,
})

craft({
    output = "obsidiana:hachadeobsidiana",
    recipe = {
        {A, A, ""},
        {A, "default:stick", ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "obsidiana:espadadeobsidiana",
    recipe = {
        {"", A, ""},
        {"", A, ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "obsidiana:picodeobsidiana",
    recipe = {
        {A, A, A},
        {"", "default:stick", ""},
        {"", "default:stick", ""},
    },
})

craft({
    output = "obsidiana:petoobsidiana",
    recipe = {
        {A, "", A},
        {A, A, A},
        {A, A, A},
    },
})

craft({
    output = "obsidiana:cascoobsidiana",
    recipe = {
        {A, A, A},
        {A, "", A},
        {"", "", ""},
    },
})

craft({
    output = "obsidiana:grebasobsidiana",
    recipe = {
        {A, A, A},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "obsidiana:botasobsidiana",
    recipe = {
        {"", "", ""},
        {A, "", A},
        {A, "", A},
    },
})

craft({
    output = "obsidiana:escudoobsidiana",
    recipe = {
        {A, A, A},
        {A, A, A},
        {"", A, ""},
    },
})

tool("obsidiana:picodeobsidiana", {
    description = S("obsidian pickaxe"),
    inventory_image = "picodeobsidiana.png",
    tool_capabilities = {
        full_punch_interval = 1.6,
        max_drop_level = 0,
        groupcaps = {
            cracky = {
                maxlevel = 3,
                uses = 15,
                times = { [1]=1.60, [2]=1.80, [3]=0.70 }
            },
        },
        damage_groups = {fleshy=1},
    },
    sound = {breaks = "tool_breaks"},
})

tool("obsidiana:espadadeobsidiana", {
    description = S("obsidian sword"),
    inventory_image = "espadadeobsidiana.png",
    tool_capabilities = {
        full_punch_interval = 1.6,
        max_drop_level = 0,
        groupcaps = {
            fleshy = {
                maxlevel = 3,
                uses = 15,
                times = { [1]=1.60, [2]=1.80, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=9},
    },
    sound = {breaks = "tool_breaks"},
})

tool("obsidiana:hachadeobsidiana", {
    description = S("obsidian axe"),
    inventory_image = "hachadeobsidiana.png",
    tool_capabilities = {
        full_punch_interval = 1.6,
        max_drop_level = 0,
        groupcaps = {
            choppy = {
                maxlevel = 3,
                uses = 15,
                times = { [1]=1.60, [2]=1.80, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=1},
    },
    sound = {breaks = "tool_breaks"},
})
