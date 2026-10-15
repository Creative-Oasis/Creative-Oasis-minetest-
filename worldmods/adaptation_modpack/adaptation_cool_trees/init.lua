
local modpath = minetest.get_modpath(minetest.get_current_modname())

local trees = {"baldcypress", "birch", "cherrytree", "clementinetree", "ebony",     "hollytree", "larch", "lemontree", "mahogany", "maple", "oak", "palm", "plumtree", "pomegranate", "willow"}

if minetest.get_modpath("bamboo") or minetest.get_modpath("hades_bamboo") then
  adaptation_lib.add_item("wood_bamboo", {
      name = "bamboo:wood",
      lists={"wood"},
    }, adaptation_lib.auto_take_tile_sounds)
end

for _, tree in pairs(trees) do
  if minetest.get_modpath(tree) or minetest.get_modpath("hades_"..tree) then
    if (tree~="larch") then
      adaptation_lib.add_item("leaves_cool_"..tree, {
          name = tree..":leaves",
          lists={"leaves"},
        }, adaptation_lib.auto_take_tile_sounds)
    else
      adaptation_lib.add_item("needles_cool_"..tree, {
          name = tree..":leaves",
          lists={"needles"},
        }, adaptation_lib.auto_take_tile_sounds)
    end
    adaptation_lib.add_item("wood_cool_"..tree, {
        name = tree..":wood",
        lists={"wood"},
      }, adaptation_lib.auto_take_tile_sounds)
    adaptation_lib.add_item("tree_cool_"..tree, {
        name = tree..":trunk",
        lists={"tree"},
      }, adaptation_lib.auto_take_tile_sounds)
    adaptation_lib.add_item("sapling_cool_"..tree, {
        name = tree..":sapling",
        lists={"sapling"},
      })
  end
end

if minetest.get_modpath("oak") or minetest.get_modpath("hades_oak") then
  adaptation_lib.add_list_item("oak_leaves", "oak:leaves")
end

