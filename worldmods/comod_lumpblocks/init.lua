---terumet
if core.get_modpath("terumet") then
    lumpblocks.register_lump_block{
        "terumetal",
        "terumet:lump_raw",
        colours = {"#79465aff", "#cc7b9cff"},
        description = "Raw Terumetal Block",
        name = "comod_lumpblocks:terumetal_block"
    }
end
--elepower dynamics
if core.get_modpath("elepower_dynamics") then
    lumpblocks.register_lump_block{
        "lead",
        "elepower_dynamics:lead_lump",
        colours = {"#2e3a4b", "#374559"},
        description = "Raw Lead Block",
        name = "comod_lumpblocks:lead_block"
    }

    lumpblocks.register_lump_block{
        "nickel",
        "elepower_dynamics:nickel_lump",
        colours = {"#7d7a5f", "#8b8769"},
        description = "Raw Nickel Block",
        name = "comod_lumpblocks:nickel_block"
    }

    lumpblocks.register_lump_block{
        "viridisium",
        "elepower_dynamics:viridisium_lump",
        colours = {"#4d8044", "#65a655"},
        description = "Raw Viridisium Block",
        name = "comod_lumpblocks:viridisium_block"
    }

    lumpblocks.register_lump_block{
        "zinc",
        "elepower_dynamics:zinc_lump",
        colours = {"#6290a3", "#82a6b7"},
        description = "Raw Zinc Block",
        name = "comod_lumpblocks:zinc_block"
    }
end
--elepower nuclear
if core.get_modpath("elepower_nuclear") then
    lumpblocks.register_lump_block{
        "uranium",
        "elepower_nuclear:uranium_lump",
        colours = {"#026503", "#028303"},
        description = "Raw Uranium Block",
        name = "comod_lumpblocks:uranium_block"
    }
end
--cloud items
if core.get_modpath("cloud_items") then
lumpblocks.register_lump_block{
        "cloud",
        "cloud_items:cloud_lump",
        colours = {"#2596be", "#d2dff4"},
        description = "Cloud Block",
        name = "comod_lumpblocks:cloud_block"
    }
end