
adaptation_lib.add_item("bucket_empty", {
    name = "bucket:bucket_empty",
  })

adaptation_lib.add_item("bucket_water", {
    name = "bucket:bucket_water",
    name_craft_replace = "bucket:bucket_empty",
    lists = {"bucket_water"},
  })

adaptation_lib.add_item("bucket_river_water", {
    name = "bucket:bucket_river_water",
    name_craft_replace = "bucket:bucket_empty",
    lists = {"bucket_water"},
  })

adaptation_lib.add_mod("bucket", {
    register_bucket = bucket.register_liquid -- function with API like default minetest game bucket
  })

