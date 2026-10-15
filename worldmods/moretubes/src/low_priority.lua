-- moretubes/src/low_priority.lua
-- Low Priority Tube Segment
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = minetest.get_translator("moretubes")

local color = "#ff8888:128"
local nodecolor = 0xffff8888
pipeworks.register_tube("moretubes:low_priority_tube", {
    description     = S("Low Priority Tube Segment"),
    inventory_image = "pipeworks_tube_inv.png^[colorize:" .. color,
    plain           = { { name = "pipeworks_tube_plain.png", color = nodecolor } },
    noctr           = { { name = "pipeworks_tube_noctr.png", color = nodecolor } },
    ends            = { { name = "pipeworks_tube_end.png", color = nodecolor } },
    short           = { name = "pipeworks_tube_short.png", color = nodecolor },
    node_def        = {
        tube = { priority = 45 } -- Lower than tubes and receivers (50, 100 resp.)
    },
})

if xcompat.materials.coal_lump then
    minetest.register_craft({
        output = "moretubes:low_priority_tube 6",
        recipe = {
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
            { xcompat.materials.coal_lump,     "",                              xcompat.materials.coal_lump },
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
        },
    })
end
