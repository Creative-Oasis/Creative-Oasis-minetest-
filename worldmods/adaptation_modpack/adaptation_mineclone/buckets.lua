

adaptation_lib.add_item("bucket_empty", {
    name = "mcl_buckets:bucket_empty",
  })

adaptation_lib.add_item("bucket_water", {
    name = "mcl_buckets:bucket_water",
    name_craft_replace = "mcl_bucket:bucket_empty",
    lists = {"bucket_water"},
  })

adaptation_lib.add_item("bucket_river_water", {
    name = "mcl_buckets:bucket_river_water",
    name_craft_replace = "mcl_bucket:bucket_empty",
    lists = {"bucket_water"},
  })

adaptation_lib.add_mod("bucket", {
    register_bucket = function (liquid_source, liquid_flowing, bucket_name, bucket_img, description, groups, force_renew)
        mcl_buckets.register_liquid({
            source_take = {liquid_source},
            source_place = liquid_source,
            bucketname = bucket_name,
            groups = groups,
          })
      end,
  })

