-- moretubes/src/decelerator.lua
-- Decelerating Pneumatic Tube Segment
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = minetest.get_translator("moretubes")

local color = "#9bb75c:128"
local nodecolor = 0xff9bb75c
pipeworks.register_tube("moretubes:decelerator_tube", {
    description     = S("Decelerating Pneumatic Tube Segment"),
    inventory_image = "pipeworks_tube_inv.png^[colorize:" .. color,
    plain           = { { name = "pipeworks_tube_plain.png", color = nodecolor } },
    noctr           = { { name = "pipeworks_tube_noctr.png", color = nodecolor } },
    ends            = { { name = "pipeworks_tube_end.png", color = nodecolor } },
    short           = { name = "pipeworks_tube_short.png", color = nodecolor },
    node_def        = {
        tube = {
            can_go = function(pos, node, velocity, stack)
                if velocity.speed > 0.5 then
                    velocity.speed = velocity.speed - 0.5
                end
                return pipeworks.notvel(pipeworks.meseadjlist, velocity)
            end
        }
    }
})

if xcompat.materials.dirt then
    minetest.register_craft({
        output = "moretubes:decelerator_tube_1 2",
        recipe = {
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
            { "",                              xcompat.materials.dirt,          "" },
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
        },
    })
end
