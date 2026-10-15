
local S = minetest.get_translator("adaptation_minetest_game")

adaptation_lib.basic_colors = {
  white = {
    color = S("White"),
	  hex = "FFFFFF",
  },
  grey = {
    color = S("Grey"),
	  hex = "C0C0C0",
  },
  black = {
    color = S("Black"),
    hex = "232323",
  },
  red = {
    color = S("Red"),
    hex = "FF0000",
  },
  yellow = {
    color = S("Yellow"),
    hex = "FFEE00",
  },
  green = {
    color = S("Green"),
    hex = "32CD32",
  },
  cyan = {
    color = S("Cyan"),
    hex = "00959D",
  },
  blue = {
    color = S("Blue"),
    hex = "003376",
  },
  magenta = {
    color = S("Magenta"),
    hex = "D80481",
  },
  orange = {
    color = S("Orange"),
    hex = "E0601A",
  },
  violet = {
    color = S("Violet"),
    hex = "480080",
  },
  brown = {
    color = S("Brown"),
    hex = "391A00",
  },
  pink = {
    color = S("Pink"),
    hex = "FFA5A5",
  },
  dark_grey = {
    color = S("Dark Grey"),
    hex = "696969",
  },
  dark_green = {
    color = S("Dark Green"),
    hex = "154F00",
  },
}

for color_key, color_data in pairs(adaptation_lib.basic_colors) do
  adaptation_lib.add_item("dye_"..color_key, {
      name = "fl_dyes:"..color_key.."_dye",
    })
  color_data.dyes = {"fl_dyes:"..color_key.."_dye"}
end

for index, data in pairs(fl_dyes.dyes) do
  local color_data = adaptation_lib.basic_colors[data[1]]
  if color_data then
    color_data.index = index - 1
    color_data.hex = data[3]:sub(2,7)
  else
    minetest.log("error", "Dye "..data[1].." has not defined basic color.")
  end
end
