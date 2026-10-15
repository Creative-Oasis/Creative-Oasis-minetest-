-- moretubes/src/eject.lua
-- Eject Tube Segment
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = minetest.get_translator("moretubes")

local color = "#76a5af:128"
local nodecolor = 0xff76a5af
pipeworks.register_tube("moretubes:eject_tube", {
    description     = S("Eject Tube Segment"),
    inventory_image = "pipeworks_tube_inv.png^[colorize:" .. color,
    plain           = { { name = "pipeworks_tube_plain.png", color = nodecolor } },
    noctr           = { { name = "pipeworks_tube_noctr.png", color = nodecolor } },
    ends            = { { name = "pipeworks_tube_end.png", color = nodecolor } },
    short           = { name = "pipeworks_tube_short.png", color = nodecolor },
    node_def        = {
        groups = { tubedevice_receiver = 1 },
        tube = {
            insert_object = function(pos, node, stack, direction)
                local drop = minetest.add_item(pos, stack)
                drop:add_velocity(vector.multiply(direction, 1.3))
                return ItemStack("")
            end,
            can_insert = function(pos, node, stack, direction)
                return true
            end,
            priority = 50,
        },
    },
})
