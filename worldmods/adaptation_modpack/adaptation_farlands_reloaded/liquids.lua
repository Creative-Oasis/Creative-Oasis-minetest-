
adaptation_lib.add_item("water", {
    name = "fl_liquids:water_source",
    tile = {
        animation = {
          aspect_w = 16,
          aspect_h = 16,
          length = 2,
          type = "vertical_frames"
        },
        name = "farlands_water_source_animated.png",
        backface_culling = false
      },
      tile_noanim = "farlands_water.png",
  })
adaptation_lib.add_item("water_river", {
    name = "fl_liquids:river_water_source",
    tile = {
        animation = {
          aspect_w = 16,
          aspect_h = 16,
          length = 2,
          type = "vertical_frames"
        },
        name = "farlands_river_water_source_animated.png",
        backface_culling = false
      },
      tile_noanim = "farlands_river_water.png",
  })

adaptation_lib.add_item("bucket_empty", {
    name = "fl_bucket:bucket",
  })

adaptation_lib.add_item("bucket_water", {
    name = "fl_bucket:bucket_water",
    name_craft_replace = "fl_bucket:bucket",
    lists = {"bucket_water"},
  })
adaptation_lib.add_item("bucket_river_water", {
    name = "fl_bucket:bucket_river_water",
    name_craft_replace = "fl_bucket:bucket",
    lists = {"bucket_water"},
  })

adaptation_lib.add_mod("bucket", {
    register_bucket = function (liquid_source, liquid_flowing, bucket_name, bucket_img, description, groups, force_renew)
        minetest.register_craftitem(":"..bucket_name, {
            description = description,
            inventory_image = bucket_img,
            stack_max = 1,
            liquids_pointable = true,
            groups = groups,
            on_place = function(itemstack, user, pointed_thing)
              if pointed_thing.type == "node" then
              else
              end
              error "TODO:"
            end
          })
      end,
  })

