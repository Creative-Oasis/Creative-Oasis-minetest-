-- wing + fuselage items still exist (for creative)
minetest.register_craftitem("ju52:wings",{
    description = "Ju52 wings",
    inventory_image = "ju52_wings.png",
})

minetest.register_craftitem("ju52:body",{
    description = "Ju52 body",
    inventory_image = "ju52_body.png",
})

-- ju52 item
minetest.register_craftitem("ju52:ju52", {
    description = "Ju 52",
    inventory_image = "ju52.png",
    liquids_pointable = true,

    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local pointed_pos = pointed_thing.under
        pointed_pos.y = pointed_pos.y + 3.0

        local new_ju52 = minetest.add_entity(pointed_pos, "ju52:ju52")
        if new_ju52 and placer then
            local ent = new_ju52:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
            new_ju52:set_yaw(placer:get_look_horizontal())
            itemstack:take_item()
            airutils.create_inventory(ent, ent._trunk_slots, owner)
        end
        return itemstack
    end,
})


