function vehicle_mash.register_vehicle(name, def)

    -- Helper function to stop vehicle
    local function stop_vehicle(self)
        if self.object then
            local vel = self.object:get_velocity()
            self.object:set_velocity({x=0, y=vel.y, z=0}) -- stop horizontal motion
            self.object:set_acceleration({x=0, y=0, z=0})
        end
    end

    minetest.register_entity(name, {
        terrain_type = def.terrain_type,
        collisionbox = def.collisionbox,
        can_fly = def.can_fly,
        can_go_down = def.can_go_down,
        can_go_up = def.can_go_up,
        player_rotation = def.player_rotation,
        driver_attach_at = def.driver_attach_at,
        driver_eye_offset = def.driver_eye_offset,
        driver_detach_pos_offset = def.driver_detach_pos_offset,
        number_of_passengers = def.number_of_passengers,
        passengers = def.passengers or {},
        enable_crash = def.enable_crash,
        visual = def.visual,
        mesh = def.mesh,
        textures = def.textures,
        tiles = def.tiles,
        visual_size = def.visual_size,
        stepheight = def.stepheight,
        max_speed_forward = def.max_speed_forward,
        max_speed_reverse = def.max_speed_reverse,
        max_speed_upwards = def.max_speed_upwards,
        max_speed_downwards = def.max_speed_downwards,
        accel = def.accel,
        braking = def.braking,
        turn_spd = def.turn_speed,
        drop_on_destroy = def.drop_on_destroy or {},
        driver = nil,
        passenger = nil,
        v = 0,
        v2 = 0,
        mouselook = false,
        physical = true,
        removed = false,
        offset = vector.new(0,0,0),
        owner = "",
        hp_min = def.hp_min,
        hp_max = def.hp_max,
        armor = def.armor,
        rpm_values = {{16,16,.5},{10,10,.4},{0,5,.3}},

        -- =====================
        -- Player interaction
        -- =====================
        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end

            -- driver exists
            if self.driver then
                if clicker == self.driver then
                    -- detach all passengers safely
                    for i=1,self.number_of_passengers do
                        local p = self.passengers[i]
                        if p and p.player then
                            lib_mount.detach(p.player, p.eye_offset)
                        end
                    end
                    -- detach driver + stop car
                    lib_mount.detach(self.driver, self.offset)
                    stop_vehicle(self)
                else
                    -- check if passenger or attach to empty slot
                    for i=1,self.number_of_passengers do
                        local p = self.passengers[i]
                        if p then
                            if clicker == p.player then
                                lib_mount.detach(clicker, p.eye_offset)
                                break
                            elseif not p.player then
                                lib_mount.attach(self, clicker, true, i)
                                break
                            end
                        end
                    end
                end
            else
                -- no driver, attach driver
                if self.owner == clicker:get_player_name() then
                    lib_mount.attach(self, clicker, false, 0)
                end
            end
        end,

        on_activate = function(self, staticdata, dtime_s)
            if def.armor then
                self.object:set_armor_groups({fleshy=def.armor})
            else
                self.object:set_armor_groups({fleshy=0, immortal=1})
            end
            if def.hp_min and def.hp_max then
                self.object:set_hp(math.random(def.hp_min, def.hp_max))
            end
            local tmp = minetest.deserialize(staticdata)
            if tmp then
                for k,v in pairs(tmp) do
                    self[k] = v
                end
            end
            self.v2 = self.v
        end,

        get_staticdata = function(self)
            local tmp = {}
            for k,v in pairs(self) do
                local t = type(v)
                if t ~= "function" and t ~= "nil" and t ~= "userdata" then
                    tmp[k] = v
                end
            end
            return core.serialize(tmp)
        end,

        on_punch = function(self, puncher, ...)
            if not puncher or not puncher:is_player() or self.removed or self.driver then return end
            local pname = puncher:get_player_name()
            if self.owner == pname or minetest.get_player_privs(pname).protection_bypass then
                self.removed = true
                minetest.after(0.1, function() self.object:remove() end)
                puncher:get_inventory():add_item("main", self.name)
            end
        end,

        on_step = function(self, dtime, moveresult, ...)
            if not self.driver then
                stop_vehicle(self)
            else
                if def.enable_crash == nil then def.enable_crash = true end
                lib_mount.drive(self, dtime, false, nil, nil, 0,
                    def.can_fly, def.can_go_down, def.can_go_up, def.enable_crash, moveresult)
            end
        end,

        on_death = function(self, killer)
            if self.driver then
                lib_mount.detach(self.driver, self.offset)
                stop_vehicle(self)
            end
            for i=1,self.number_of_passengers do
                local p = self.passengers[i]
                if p and p.player then
                    lib_mount.detach(p.player, p.eye_offset)
                    p.player:set_eye_offset(vector.new(0,0,0), vector.new(0,0,0))
                end
            end
        end,
    })

    -- craftitem registration
    local can_float = def.terrain_type==2 or def.terrain_type==3
    minetest.register_craftitem(name, {
        description = def.description,
        inventory_image = def.inventory_image,
        wield_image = def.wield_image,
        wield_scale = def.wield_scale,
        liquids_pointable = can_float,
        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing.type ~= "node" then return end
            local ent
            if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "liquid")==0 then
                if def.terrain_type==0 or def.terrain_type==1 or def.terrain_type==3 then
                    pointed_thing.above.y = pointed_thing.above.y + def.onplace_position_adj
                    ent = minetest.add_entity(pointed_thing.above, name)
                else return end
            else
                if def.terrain_type==2 or def.terrain_type==3 then
                    pointed_thing.under.y = pointed_thing.under.y + 0.5
                    ent = minetest.add_entity(pointed_thing.under, name)
                else return end
            end
            if ent:get_luaentity().player_rotation.y==90 then
                ent:set_yaw(placer:get_look_horizontal())
            else
                ent:set_yaw(placer:get_look_horizontal() - math.pi/2)
            end
            ent:get_luaentity().owner = placer:get_player_name()
            itemstack:take_item()
            return itemstack
        end
    })

    if def.recipe then
        minetest.register_craft({output=name, recipe=def.recipe})
    end
end
