
local S = minetest.get_translator("adaptation_mineclone")

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
      name = "mcl_dye:"..color_key,
    })
  color_data.dyes = {"mcl_dye:"..color_key}
end

