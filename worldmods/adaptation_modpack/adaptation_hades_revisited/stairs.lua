
local S = minetest.get_translator("adaptation_hades_revisited")

adaptation_lib.add_mod("stairs", {
    name = "hades_stairs",
    register_stair_and_slab = 
      function (subname, recipeitem, groups, images,
                desc_stair, desc_slab, sounds, worldaligntex,
                desc_stair_inner, desc_stair_outer)
        hades_stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, 
          S("Inner @1", desc_stair), S("Outer @1",desc_stair),
          desc_slab, sounds)
      end,
  })

