
local S = minetest.get_translator("adaptation_mineclone")

adaptation_lib.add_mod("stairs", {
    name = "mcl_stairs",
    register_stair_and_slab = 
      function (subname, recipeitem, groups, images,
                desc_stair, desc_slab, sounds, worldaligntex,
                desc_stair_inner, desc_stair_outer)
        local def = minetest.registered_items[recipeitem]
        local blast_resistance
        local hardness
        if def then
          blast_resistance = def._mcl_blast_resistance
          hardness = def._mcl_hardness
        end
        mcl_stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds,
        blast_resistance, hardness, S("Double @1", desc_slab))
      end,
  })

