--[[
    X Obsidianmese. Adds obsidian and mese tools and items.
    Copyright (C) 2025 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
--]]

-- Sword engraved - bullet entity
core.register_entity('x_obsidianmese:sword_bullet', {
    initial_properties = {
        physical = false,
        visual = 'mesh',
        -- >= 5.10, this will be set dynamically when supported (on_activate)
        -- mesh = 'x_obsidianmese_sword_projectile.glb',
        mesh = 'x_obsidianmese_sword_projectile.b3d',
        visual_size = { x = 0.75, y = 0.75, z = 0.75},
        textures = { 'x_obsidianmese_sword_projectile.png' },
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        selectionbox = { 0, 0, 0, 0, 0, 0 },
        glow = 8,
        use_texture_alpha = true,
        -- automatic_rotate = math.pi * 0.5,
    },
    _lifetime = 3, -- seconds before removing
    _lifetime_cancel_charging = false, -- seconds before removing
    _timer = 0, -- initial value
    _user_name = 'unknown', -- initial value
    _set_velocity = true,
    _set_acceleration = true,
    _step_count = 0,
    _fade_out_step_count = 0,
    _strength = 30,
    _skip_raycast = false,
    _follow_look_dir = false,
    _fade_in = false,
    _is_faded_in = false,
    _fade_out = false,
    _orig_textures = { 'x_obsidianmese_sword_projectile.png' },
    _orig_visual_size = { x = 0.75, y = 0.75, z = 0.75},
    _textures = {},
    _is_critical_hit = false,

    on_activate = function(self, staticdata, dtime_s)
        local _staticdata = core.deserialize(staticdata) or {}

        -- restore saved values (use fallbacks if missing)
        self._user_name = _staticdata._user_name or self._user_name or 'unknown'
        -- try to get player object, may be nil if player offline or name invalid
        self._user = core.get_player_by_name(self._user_name)

        -- if player object is not available, safely remove entity to avoid crashes
        if not self._user then
            -- We may be loading after a server restart or the player disconnected.
            -- Safer to remove the entity than attempt to access player methods.
            if self.object then
                self.object:remove()
            end
            return
        end

        -- Safe calls now that self._user exists
        -- Protect against players without expected methods by using pcall where appropriate
        local ok, look_dir = pcall(function() return self._user:get_look_dir() end)
        self._player_look_dir = ok and look_dir or vector.new(0,0,1)

        ok, self._timer = pcall(function() return _staticdata._timer or self._timer end)
        if not ok then self._timer = self._timer end

        -- wielded item and capabilities: guard in case of unexpected return values
        local wield_ok, wield_item = pcall(function() return self._user:get_wielded_item() end)
        if wield_ok and wield_item then
            self._user_wielditem = wield_item
            local cap_ok, caps = pcall(function() return self._user_wielditem:get_tool_capabilities() end)
            self._user_tool_capabilities = cap_ok and caps or nil
        else
            self._user_wielditem = nil
            self._user_tool_capabilities = nil
        end

        self._set_velocity = _staticdata._set_velocity
        self._set_acceleration = _staticdata._set_acceleration
        self._lifetime = _staticdata._lifetime or self._lifetime
        self._lifetime_cancel_charging = _staticdata._lifetime_cancel_charging or self._lifetime_cancel_charging
        self._skip_raycast = _staticdata._skip_raycast
        self._follow_look_dir = _staticdata._follow_look_dir

        -- player properties: guard in case get_properties fails
        local props_ok, pprops = pcall(function() return self._user:get_properties() end)
        self._player_props = props_ok and pprops or {}
        self._eye_height = (self._player_props and self._player_props.eye_height) or 1.625
        self._eye_height = self._eye_height - ((self._eye_height / 100) * 7.7)

        self._fade_in = _staticdata._fade_in
        self._textures = _staticdata._textures or {}
        self._is_critical_hit = _staticdata._is_critical_hit

        -- damage modifier defaults
        self._damage_modifier = function(damage)
            return damage + 2
        end
        self._damage_modifier_radius = function(damage)
            return (damage + 2) / 2
        end

        if self._is_critical_hit then
            self._damage_modifier = function(damage)
                return (damage + 2) * 2
            end

            self._damage_modifier_radius = function(damage)
                return ((damage + 2) * 2) / 2
            end
        end

        if self.object and self.object.set_armor_groups then
            self.object:set_armor_groups({ immortal = 1 })
        end
        -- levitate (no spin)
        -- self.object:set_animation({ x = 61, y = 121 }, 20, 0, true)
        -- spin (no levitate)
        if self.object and self.object.set_animation then
            self.object:set_animation({ x = 1, y = 60 }, 20, 0, true)
        end

        if self._is_critical_hit and self.object and self.object.set_properties then
            self.object:set_properties({ textures = { 'x_obsidianmese_sword_projectile_crit.png' } })
        end

        if self._fade_in and self.object and self.object.set_properties then
            local prev_texture = self._orig_textures[1]

            if next(self._textures or {}) then
                prev_texture = self._textures[1]
            end

            self.object:set_properties({ textures = { prev_texture .. '^[opacity:0' } })
        end

        -- Only attempt to check client protocol if API call succeeds
        local info_ok, info = pcall(function() return core.get_player_information(self._user:get_player_name()) end)
        if info_ok and info and info.protocol_version and info.protocol_version >= (x_obsidianmese.protocol_versions['5.10.0'] or 0) then
            if self.object and self.object.set_properties then
                self.object:set_properties({ mesh = 'x_obsidianmese_sword_projectile.glb' })
            end
        end
    end,

    -- should return a string that will be passed to `on_activate` when the object is instantiated the next time
    get_staticdata = function(self)
        local table = {
            _user_name = self._user_name,
            _set_velocity = self._set_velocity,
            _set_acceleration = self._set_acceleration,
            _lifetime = self._lifetime,
            _lifetime_cancel_charging = self._lifetime_cancel_charging,
            _skip_raycast = self._skip_raycast,
            _follow_look_dir = self._follow_look_dir,
            _fade_in = self._fade_in,
            _textures = self._textures,
            _is_critical_hit = self._is_critical_hit
        }

        return core.serialize(table)
    end,

    on_step = function(self, dtime)
        self._step_count = self._step_count + 1

        if self._step_count == 1 then
            ---initialize
            ---this has to be done here for raycast to kick-in asap

            if self._set_velocity and self._player_look_dir and self.object and self.object.set_velocity then
                self.object:set_velocity(vector.multiply(self._player_look_dir, self._strength))
            end

            if self._set_acceleration and self._player_look_dir and self.object and self.object.set_acceleration then
                self.object:set_acceleration(self._player_look_dir)
            end
        end

        -- in case of error (player offline, doesn't exist, ...)
        if not core.get_player_by_name(self._user_name) then
            if self.object then self.object:remove() end
            return
        end

        local pos = self.object and self.object:get_pos() or nil
        if not pos then
            if self.object then self.object:remove() end
            return
        end

        self._old_pos = self._old_pos or pos
        self._timer = (self._timer or 0) + dtime

        -- TTL
        if self._lifetime and (self._timer > self._lifetime or not x_obsidianmese.within_limits(pos, 0)) then
            -- Explode
            core.add_particlespawner(x_obsidianmese:get_particlespwaner_def('projectile_explode', { pos = pos, is_crit = self._is_critical_hit }))

            core.sound_play({
                name = self._is_critical_hit and 'x_obsidianmese_projectile_impact_crit' or 'x_obsidianmese_projectile_impact',
                gain = 1,
            }, {
                pos = pos,
                pitch = self._is_critical_hit and 1 or math.random(7, 13) / 10,
                max_hear_distance = 32
            }, true)

            if self.object then self.object:remove() end

            if self._lifetime_cancel_charging and x_obsidianmese.cancel_charging and self._user then
                x_obsidianmese:cancel_charging(self._user, { fade_out = true })
            end

            return
        end

        if self._fade_in and not self._is_faded_in then
            local prev_texture = self._orig_textures[1]
            local opacity = self._step_count * 50

            if next(self._textures or {}) then
                prev_texture = self._textures[1]
            end

            if opacity > 255 then
                opacity = 255
                self._is_faded_in = true
            end

            if self.object and self.object.set_properties then
                self.object:set_properties({ textures = { prev_texture .. '^[opacity:' .. opacity } })
            end
        end

        if self._fade_out then
            self._fade_out_step_count = self._fade_out_step_count + 1
            local prev_texture = self._orig_textures[1]
            local opacity = 255 - self._fade_out_step_count * 50

            if next(self._textures or {}) then
                prev_texture = self._textures[1]
            end

            if opacity < 0 then
                if self.object then self.object:remove() end
                return
            end

            if self.object and self.object.set_properties then
                self.object:set_properties({ textures = { prev_texture .. '^[opacity:' .. opacity } })
            end
        end

        --
        -- Raycast
        --

        if not self._skip_raycast then
            local ray = core.raycast(self._old_pos, pos, true, false, nil)

            for pt in ray do
                local ip_pos = pt.intersection_point

                if pt.type == 'object'
                    and x_obsidianmese:is_valid_player_or_entity(pt.ref, self._user)
                then
                    x_obsidianmese:punch_player_or_entity(pos, pt.ref, self._user, self._damage_modifier)
                    x_obsidianmese:punch_objects_inside_radius(ip_pos, pt.ref, self._user, self._damage_modifier_radius)

                    --  Explode
                    core.add_particlespawner(x_obsidianmese:get_particlespwaner_def('projectile_explode', { pos = ip_pos, is_crit = self._is_critical_hit }))

                    core.sound_play({
                        name = self._is_critical_hit and 'x_obsidianmese_projectile_impact_crit' or 'x_obsidianmese_projectile_impact',
                        gain = 1,
                    }, {
                        pos = ip_pos,
                        pitch = self._is_critical_hit and 1 or math.random(7, 13) / 10,
                        max_hear_distance = 32
                    }, true)

                    if self.object then self.object:remove() end

                    break

                elseif pt.type == 'node' then
                    local node = core.get_node(pt.under)
                    local node_def = core.registered_nodes[node.name]

                    if not node_def then
                        break
                    end

                    if node_def.walkable then
                        x_obsidianmese:punch_objects_inside_radius(ip_pos, pt.ref, self._user, self._damage_modifier_radius)

                        -- Explode
                        core.add_particlespawner(x_obsidianmese:get_particlespwaner_def('projectile_explode', { pos = ip_pos, is_crit = self._is_critical_hit }))

                        core.sound_play({
                            name = self._is_critical_hit and 'x_obsidianmese_projectile_impact_crit' or 'x_obsidianmese_projectile_impact',
                            gain = 1,
                        }, {
                            pos = ip_pos,
                            pitch = self._is_critical_hit and 1 or math.random(7, 13) / 10,
                            max_hear_distance = 32
                        }, true)

                        if self.object then self.object:remove() end

                        break
                    end
                end
            end
        end

        if self._follow_look_dir then
            if not self._user then
                if self.object then self.object:remove() end
                return
            end

            local player_pos = self._user and self._user.get_pos and self._user:get_pos()
            if not player_pos then
                if self.object then self.object:remove() end
                return
            end

            local entity_pos = vector.new(player_pos.x, player_pos.y + self._eye_height - 0.25, player_pos.z)
            local look_dir = (self._user and self._user.get_look_dir) and self._user:get_look_dir() or vector.new(0,0,1)

            if self.object and self.object.move_to then
                self.object:move_to(vector.add(entity_pos, vector.multiply(look_dir, 1)))
            end
        end

        -- Add projectile trail
        if self._timer > (self._lifetime / 10) then
            core.add_particlespawner(x_obsidianmese:get_particlespwaner_def('projectile_trail', { pos =  pos, attached = self.object, origin_attached = self.object, direction_attached = self.object }))
        end

        self._old_pos = pos
    end
})
