-- moretubes/init.lua
-- More fun and/or useful tubes for Pipeworks
-- SPDX-License-Identifier: LGPL-3.0-or-later

local MP = minetest.get_modpath("moretubes")

for _, name in ipairs({
	"decelerator",
	"eject",
	"low_priority",
	"reverse",
	"straight",
}) do
	dofile(MP .. DIR_DELIM .. "src" .. DIR_DELIM .. name .. ".lua")
end
