function airutils.physics(self)
    -- ===== basic safety =====
    if not self or not self.object then return end

    local dt = self.dtime
    if not dt or dt <= 0 then return end

    local friction = self._ground_friction or 0.99
    local vel = self.object:get_velocity() or {x=0,y=0,z=0}
    local new_velocity = {x=0,y=0,z=0}

    -- ===== buoyancy detection =====
    local surface = nil
    local surfnodename = nil

    local spos = airutils.get_stand_pos(self)
    if not spos then return end
    spos.y = spos.y + 0.01

    local snodepos = airutils.get_node_pos(spos)
    local surfnode = airutils.nodeatpos(spos)

    while surfnode
        and (surfnode.drawtype == "liquid" or surfnode.drawtype == "flowingliquid")
    do
        surfnodename = surfnode.name
        surface = snodepos.y + 0.5
        if surface > spos.y + (self.height or 0) then break end
        snodepos.y = snodepos.y + 1
        surfnode = airutils.nodeatpos(snodepos)
    end

    self.isinliquid = surface ~= nil

    -- ===== last accel =====
    local last_accel = nil
    if self._last_accel then
        last_accel = vector.new(self._last_accel)
    end

    -- ===== LIQUID PHYSICS =====
    if surface then
        self.water_drag = 0.2

        local height = self.height or 0
        if height <= 0 then return end

        local submergence = math.min(surface - spos.y, height) / height
        submergence = math.max(0, math.min(1, submergence))

        local buoyacc = airutils.gravity * ((self.buoyancy or 0) - submergence)

        local accell = {
            x = -vel.x * self.water_drag,
            y = buoyacc - (vel.y * math.abs(vel.y) * 0.4),
            z = -vel.z * self.water_drag
        }

        if self.buoyancy and self.buoyancy >= 1 then
            self._engine_running = false
        end

        if last_accel then
            accell = vector.add(accell, last_accel)
        end

        new_velocity = vector.multiply(accell, dt)

    -- ===== AIR / GROUND PHYSICS =====
    else
        self.isinliquid = false

        if last_accel then
            last_accel.y = last_accel.y + airutils.gravity
            new_velocity = vector.multiply(last_accel, dt)
        end
    end

    -- ===== GROUND HANDLING =====
    if self.isonground and not self.isinliquid then
        new_velocity = {
            x = new_velocity.x * friction,
            y = new_velocity.y,
            z = new_velocity.z * friction
        }

        -- bounciness
        if self.springiness and self.springiness > 0 and (self.buoyancy or 0) >= 1 then
            local vnew = vector.new(new_velocity)

            if not self.collided then
                for _,k in ipairs({"y","z","x"}) do
                    if new_velocity[k] == 0 and self.lastvelocity
                        and math.abs(self.lastvelocity[k] or 0) > 0.1
                    then
                        vnew[k] = -self.lastvelocity[k] * self.springiness
                    end
                end
            end

            if not vector.equals(new_velocity, vnew) then
                self.collided = true
            else
                if self.collided and self.lastvelocity then
                    vnew = vector.new(self.lastvelocity)
                end
                self.collided = false
            end

            new_velocity = vnew
        end

        -- friction damage
        if self._last_longit_speed and friction <= 0.97 and self._last_longit_speed > 0 then
            self.hp_max = (self.hp_max or 0) - 0.001
            airutils.setText(self, self._vehicle_name)
        end

        -- idle fix
        if not self.driver_name
            and math.abs(vel.x) < 0.2
            and math.abs(vel.z) < 0.2
        then
            self.object:set_velocity({
                x = 0,
                y = airutils.gravity * dt,
                z = 0
            })
            if self.wheels then
                self.wheels:set_animation_frame_speed(0)
            end
            return
        end
    end

    -- ===== FINAL NaN GUARD (CRASH PREVENTION) =====
    if not (
        new_velocity
        and new_velocity.x == new_velocity.x
        and new_velocity.y == new_velocity.y
        and new_velocity.z == new_velocity.z
    ) then
        minetest.log("error",
            "[airutils] Prevented NaN velocity: " ..
            minetest.serialize(new_velocity)
        )
        return
    end

    self.object:add_velocity(new_velocity)
end
