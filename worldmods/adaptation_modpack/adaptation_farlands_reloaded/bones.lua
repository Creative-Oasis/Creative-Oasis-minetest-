
adaptation_lib.add_item("bone", {
    name = "fl_bones:bone",
    tile = "farlands_bone.png",
    lists = {"bone"},
  })

minetest.override_item("fl_bones:bone", {
    groups = {bone = 1},
  })

