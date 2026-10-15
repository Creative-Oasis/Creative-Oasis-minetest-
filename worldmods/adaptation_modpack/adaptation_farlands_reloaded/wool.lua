
adaptation_lib.add_item("wool_raw", {
    name = "fl_wool:wool",
    tile = "farlands_wool.png",
  })

for color_key, color_data in pairs(adaptation_lib.basic_colors) do
  local colored_wool = ItemStack(minetest.itemstring_with_palette("fl_wool:wool", color_data.index))
  colored_wool:get_meta():set_string("description",  color_data.color.." wool")
  adaptation_lib.add_item("wool_"..color_key, {
      name = colored_wool:to_string(),
      lists = {"wool"},
      
      color = color_key,
    }, nil, nil, false)
end

adaptation_lib.add_mod("wool", {
    name = "fl_wool",
    prefix = "fl_wool:",
    clear_colored_wool_recipe = function (color)
      minetest.clear_craft({
          type = "shapeless",
          --output = "wool:"..color,
          recipe = {"fl_wool:wool", "fl_dye:"..color.."_dye"},
        })
    end,
  })

