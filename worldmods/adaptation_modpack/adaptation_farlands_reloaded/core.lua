
adaptation_lib.add_item("dirt", {
    name = "fl_core:dirt",
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("stone", {
    name = "fl_core:stone",
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("cobble", {
    name = "fl_core:cobble",
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("stone_desert", {
    name = "fl_core:desert_stone",
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("gravel", {
    name = "fl_core:gravel",
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sand", {
    name = "fl_core:sand",
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("sand_desert", {
    name = "fl_core:desert_sand",
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("sand_silver", {
    name = "fl_core:silver_sand",
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("glass", {
    name = "fl_core:glass",
    tile = "default_glass.png",
    sounds = default.node_sound_glass_defaults(),
  })
adaptation_lib.add_item("glass_obsidian", {
    name = "fl_core:obsidian_glass",
    tile = "default_obsidian_glass.png",
    sounds = default.node_sound_glass_defaults(),
  })

adaptation_lib.add_item("clay", {
    name = "fl_core:clay",
    tile = "default_clay.png",
    sounds = default.node_sound_dirt_defaults(),
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("wood_common", {
    name = "fl_core:wood",
    tile = "default_wood.png",
    sounds = default.node_sound_wood_defaults(),
    lists = {"wood"},
  })
adaptation_lib.add_item("wood_jungle", {
    name = "fl_core:junglewood",
    tile = "default_junglewood.png",
    sounds = default.node_sound_wood_defaults(),
    lists = {"wood"},
  })
adaptation_lib.add_item("wood_pine", {
    name = "fl_core:pine_wood",
    tile = "default_pine_wood.png",
    sounds = default.node_sound_wood_defaults(),
    lists = {"wood"},
  })

adaptation_lib.add_item("tree_common", {
    name = "fl_core:tree",
    sounds = default.node_sound_wood_defaults(),
    lists = {"tree"},
  })
adaptation_lib.add_item("tree_jungle", {
    name = "fl_core:jungletree",
    sounds = default.node_sound_wood_defaults(),
    lists = {"tree"},
  })
adaptation_lib.add_item("tree_pine", {
    name = "fl_core:pine_tree",
    sounds = default.node_sound_wood_defaults(),
    lists = {"tree"},
  })

adaptation_lib.add_item("leaves_common", {
    name = "fl_core:leaves",
    sounds = default.node_sound_leaves_defaults(),
    lists = {"leaves"},
  })
adaptation_lib.add_item("leaves_jungle", {
    name = "fl_core:jungle_leaves",
    sounds = default.node_sound_leaves_defaults(),
    lists = {"leaves"},
  })
adaptation_lib.add_item("needle_pine", {
    name = "fl_core:pine_needle",
    sounds = default.node_sound_leaves_defaults(),
    lists = {"needle"},
  })

adaptation_lib.add_item("paper", {
    name = "fl_core:paper",
  })

adaptation_lib.add_item("lump_iron", {
    name = "fl_core:iron_lump",
  })
adaptation_lib.add_item("lump_copper", {
    name = "fl_core:copper_lump",
  })
adaptation_lib.add_item("lump_tin", {
    name = "fl_core:tin_lump",
  })
adaptation_lib.add_item("lump_gold", {
    name = "fl_core:gold_lump",
  })

adaptation_lib.add_item("ingot_iron", {
    name = "fl_core:steel_ingot",
  })
adaptation_lib.add_item("ingot_copper", {
    name = "fl_core:copper_ingot",
  })
adaptation_lib.add_item("ingot_tin", {
    name = "fl_core:tin_ingot",
  })
adaptation_lib.add_item("ingot_bronze", {
    name = "fl_core:bronze_ingot",
  })
adaptation_lib.add_item("ingot_gold", {
    name = "fl_core:gold_ingot",
  })


adaptation_lib.add_item("chest", {
    name = "fl_core:chest",
    sounds = default.node_sound_wood_defaults(),
  })

adaptation_lib.add_item("mese", {
    name = "fl_core:mese",
    tile = "default_mese_block.png",
    sounds = default.node_sound_stone_defaults(),
  })
adaptation_lib.add_item("mese_crystal", {
    name = "fl_core:mese_crystal",
  })
adaptation_lib.add_item("mese_crystal_fragment", {
    name = "fl_core:mese_crystal_fragment",
  })

adaptation_lib.add_item("torch", {
    name = "fl_core:torch",
  })

adaptation_lib.add_item("water", {
    name = "fl_core:water_source",
    tile = "default_water.png",
    sounds = default.node_sound_water_defaults(),
    lists = {"water_source"},
  })
adaptation_lib.add_item("water_river", {
    name = "fl_core:river_water_source",
    tile = "default_river_water.png",
    sounds = default.node_sound_water_defaults(),
    lists = {"water_source"},
  })
adaptation_lib.add_item("water_flowing", {
    name = "fl_core:water_flowing",
    tile = "default_water.png",
    sounds = default.node_sound_water_defaults(),
    lists = {"water_flowing"},
  })
adaptation_lib.add_item("water_flowing_river", {
    name = "fl_core:river_water_flowing",
    tile = "default_river_water.png",
    sounds = default.node_sound_water_defaults(),
    lists = {"water_flowing"},
  })
