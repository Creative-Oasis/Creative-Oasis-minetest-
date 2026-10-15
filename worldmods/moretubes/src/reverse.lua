-- moretubes/src/reverse.lua
-- Reversing Tube Segment
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = minetest.get_translator("moretubes")

local color = "#00ff00:128"
local nodecolor = 0xff00ff00
pipeworks.register_tube("moretubes:reverse_tube", {
    description     = S("Reversing Tube Segment"),
    inventory_image = "pipeworks_tube_inv.png^[colorize:" .. color,
    plain           = { { name = "pipeworks_tube_plain.png", color = nodecolor } },
    noctr           = { { name = "pipeworks_tube_noctr.png", color = nodecolor } },
    ends            = { { name = "pipeworks_tube_end.png", color = nodecolor } },
    short           = { name = "pipeworks_tube_short.png", color = nodecolor },
    node_def        = {
        tube = {
            can_go = function(pos, node, velocity, stack)
                local nvelocity = table.copy(velocity)
                nvelocity.x = nvelocity.x * -1
                nvelocity.y = nvelocity.y * -1
                nvelocity.z = nvelocity.z * -1
                return nvelocity
            end
        }
    }
})
