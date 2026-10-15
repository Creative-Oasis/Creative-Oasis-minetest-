
adaptation_lib.add_mod("stairs", {
    name = "fl_stairs",
    register_stair_and_slab = 
      function (subname, recipeitem, groups, images,
                desc_stair, desc_slab, sounds, worldaligntex,
                desc_stair_inner, desc_stair_outer)
        fl_stairs.register_stairslab(recipeitem)
      end,
  })

