
local moretrees_mod = "moretrees"

if minetest.get_modpath("hades_moretrees") then
  moretrees_mod = "hades_moretrees"
end

local trees = {
    apple = "apple_tree",
    beech = "beech",
    birch = "birch",
    cedar = "cedar",
    date_palm = "date_palm",
    fir = "fir",
    oak = "oak",
    palm = "palm",
    poplar = "poplar",
    poplar_small = "poplar_small",
    rubber = "rubber_tree",
    sequoia = "sequoia",
    spruce = "spruce",
    willow = "willow",
  }

for key,tree in pairs(trees) do
  adaptation_lib.add_item("moretrees_wood_"..key, {
      name = moretrees_mod..":"..tree.."_planks",
      lists={"wood"},
    })
  adaptation_lib.add_item("moretrees_tree_"..key, {
      name = moretrees_mod..":"..tree.."_trunk",
      lists={"tree"},
    })
  adaptation_lib.add_item("moretrees_leaves_"..key, {
      name = moretrees_mod..":"..tree.."_leaves",
      lists={"leaves"},
    })
end

adaptation_lib.add_list_item("oak_leaves", moretrees_mod..":oak_leaves")

