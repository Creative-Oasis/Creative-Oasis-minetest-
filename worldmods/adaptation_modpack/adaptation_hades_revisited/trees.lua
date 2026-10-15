
-- common/apple tree
adaptation_lib.add_item("wood_common", {
    name = "hades_trees:wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("wood_apple", {
    name = "hades_trees:wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_common", {
    name = "hades_trees:tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("tree_apple", {
    name = "hades_trees:tree",
    --lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_common", {
    name = "hades_trees:leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)
adaptation_lib.add_item("leaves_apple", {
    name = "hades_trees:leaves",
    --lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_common", {
    name = "hades_trees:sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)
adaptation_lib.add_item("sapling_apple", {
    name = "hades_trees:sapling",
    --lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- banana tree
adaptation_lib.add_item("leaves_banana", {
    name = "hades_trees:banana_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_banana", {
    name = "hades_trees:banana_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- birch tree
adaptation_lib.add_item("wood_birch", {
    name = "hades_trees:birch_wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_birch", {
    name = "hades_trees:birch_tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_birch", {
    name = "hades_trees:birch_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_birch", {
    name = "hades_trees:birch_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- canvas tree
adaptation_lib.add_item("wood_canvas", {
    name = "hades_trees:canvas_wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_canvas", {
    name = "hades_trees:jugnle_tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_canvas", {
    name = "hades_trees:canvas_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_canvas", {
    name = "hades_trees:canvas_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- cocoa tree
--[[
adaptation_lib.add_item("leaves_cocoa", {
    name = "hades_trees:cocoa_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)
--]]
adaptation_lib.add_item("sapling_cocoa", {
    name = "hades_trees:cocoa_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- coconut tree
--[[
adaptation_lib.add_item("leaves_coconut", {
    name = "hades_trees:coconut_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)
--]]
adaptation_lib.add_item("sapling_coconut", {
    name = "hades_trees:coconut_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- cultivated jungle tree
adaptation_lib.add_item("leaves_cultivated_jungle", {
    name = "hades_trees:cultivated_jungle_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_cultivated_jungle", {
    name = "hades_trees:cultivated_jungle_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- jungle tree
adaptation_lib.add_item("wood_jungle", {
    name = "hades_trees:jungle_wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_jungle", {
    name = "hades_trees:jugnle_tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_jungle", {
    name = "hades_trees:jungle_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_jungle", {
    name = "hades_trees:jungle_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- olive tree
adaptation_lib.add_item("leaves_olive", {
    name = "hades_trees:olive_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_olive", {
    name = "hades_trees:olive_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- orange tree
adaptation_lib.add_item("wood_orange", {
    name = "hades_trees:orange_wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_orange", {
    name = "hades_trees:orange_tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_orange", {
    name = "hades_trees:orange_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_orange", {
    name = "hades_trees:orange_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- pale tree
adaptation_lib.add_item("wood_pale", {
    name = "hades_trees:pale_wood",
    lists = {"wood"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("tree_pale", {
    name = "hades_trees:pale_tree",
    lists = {"tree"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("leaves_pale", {
    name = "hades_trees:pale_leaves",
    lists = {"leaves"},
  }, adaptation_lib.auto_take_tile_sounds)

adaptation_lib.add_item("sapling_pale", {
    name = "hades_trees:pale_sapling",
    lists = {"sapling"},
  }, adaptation_lib.auto_take_images_sounds)

-- colored wood
for color_key, color_data in pairs(adaptation_lib.basic_colors) do
  adaptation_lib.add_item("wood_colored_"..color_key, {
      name = "hades_trees:colwood_"..color_key,
      lists = {"wood_colored"},
      
      color = color_key,
    })
end

