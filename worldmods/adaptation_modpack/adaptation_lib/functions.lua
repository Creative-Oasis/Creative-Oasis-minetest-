
function adaptation_lib.auto_take_by_param(data, def, param)
  for _,key in pairs(param) do
    data[key] = def[key]
  end
end

function adaptation_lib.auto_take_tile_sounds(data, def)
  data.tiles = def.tiles
  data.tile = def.tiles and def.tiles[1]
  data.sounds = def.sounds
end

function adaptation_lib.auto_take_images_sounds(data, def)
  data.tiles = def.tiles
  data.tile = def.tiles and def.tiles[1]
  data.inventory_image = def.inventory_image or def.tile
  data.inventory_overlay = def.inventory_overlay
  data.wield_image = def.wield_image or data.inventory_image
  data.wield_overlay = def.wield_overlay
  data.sounds = def.sounds
end

