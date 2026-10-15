demoiselle = {}

-- === Parts registration ===
function demoiselle.register_parts_method(self)
    local pos = self.object:get_pos()
    local wheels = minetest.add_entity(pos, 'demoiselle:wheels')
    wheels:set_attach(self.object, '', {x=0, y=0, z=0}, {x=0, y=0, z=0})
    self.wheels = wheels
end

function demoiselle.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end
    local pos = self.object:get_pos()
    pos.y = pos.y + 2
    minetest.add_item({x=pos.x+math.random()-0.5, y=pos.y, z=pos.z+math.random()-0.5}, 'demoiselle:wings')
    for i=1,6 do minetest.add_item({x=pos.x+math.random()-0.5, y=pos.y, z=pos.z+math.random()-0.5}, 'default:steel_ingot') end
    for i=1,4 do minetest.add_item({x=pos.x+math.random()-0.5, y=pos.y, z=pos.z+math.random()-0.5}, 'default:wood') end
    for i=1,6 do minetest.add_item({x=pos.x+math.random()-0.5, y=pos.y, z=pos.z+math.random()-0.5}, 'default:mese_crystal') end
end

-- === Step additional function ===
function demoiselle.step_additional_function(self)
    -- Adjust tail surfaces
    self.object:set_bone_position(
        "empenagem",
        {x=0, y=33.5, z=-0.5},
        {x=-self._elevator_angle/2.5, y=0, z=self._rudder_angle/2.5}
    )
    if self.driver_name == nil and self.co_pilot == nil then
        return
    end

    -- Update HUD
    local player_name = self.driver_name or self.co_pilot
    if player_name then
        local player = minetest.get_player_by_name(player_name)
        if player then
            demoiselle.update_hud(self, player)
        end
    end
end

-- === Plane properties ===
demoiselle.plane_properties = {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-1.2, 0, -1.2, 1.2, 2, 1.2},
        selectionbox = {-2, 0, -2, 2, 2, 2},
        visual = "mesh",
        backface_culling = false,
        mesh = "demoiselle_body.b3d",
        stepheight = 0.5,
        textures = {
            "demoiselle_bamboo.png", "demoiselle_black.png", "demoiselle_black.png",
            "demoiselle_canvas_structure.png", "demoiselle_canvas.png",
            "demoiselle_black.png", "demoiselle_bamboo.png",
            "demoiselle_metal2.png", "demoiselle_helice.png",
            "demoiselle_black.png", "demoiselle_metal.png",
            "demoiselle_canvas_structure.png", "demoiselle_canvas.png",
            "demoiselle_copper.png", "demoiselle_black.png"
        },
    },
    textures = {},
    _anim_frames = 11,
    driver_name = nil,
    sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.1,
    buoyancy = 1.02,
    physics = airutils.physics,
    _vehicle_name = "Demoiselle",
    _use_camera_relocation = false,
    _seats = {{x=0, y=5, z=2}},
    _seats_rot = {0},
    _have_copilot = false,
    _max_plane_hp = 50,
    _enable_fire_explosion = false,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 1.3,
    _wing_span = 12,
    _min_speed = 3,
    _max_speed = 8,
    _max_fuel = 5,
    _fuel_consumption_divisor = 1600000,
    _speed_not_exceed = 14,
    _damage_by_wind_speed = 4,
    _hard_damage = true,
    _min_attack_angle = 0.2,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 3,
    _tail_lift_max_speed = 5,
    _max_engine_acc = 7.5,
    _tail_angle = 0,
    _lift = 18,
    _trunk_slots = 2,
    _rudder_limit = 30.0,
    _elevator_limit = 40.0,
    _elevator_response_attenuation = 10,
    _pitch_intensity = 0.4,
    _yaw_intensity = 20,
    _yaw_turn_rate = 14,
    _elevator_pos = {x=0, y=0, z=0},
    _rudder_pos = {x=0,y=0,z=0},
    _aileron_r_pos = {x=0,y=0,z=0},
    _aileron_l_pos = {x=0,y=0,z=0},
    _color = "#FFFFFF",
    _color_2 = "#FFFFFF",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 0,
    _elevator_angle = 0,
    _power_lever = 0,
    _last_applied_power = 0,
    _energy = 1.0,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = true,
    _instruction_mode = false,
    _command_is_given = false,
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _inv = nil,
    _inv_id = "",
    _collision_sound = "airutils_collision",
    _engine_sound = "demoiselle_engine",
    _painting_texture = {"airutils_painting.png"},
    _painting_texture_2 = {"airutils_painting_2.png"},
    _mask_painting_associations = {},
    _register_parts_method = demoiselle.register_parts_method,
    _destroy_parts_method = demoiselle.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _custom_step_additional_function = demoiselle.step_additional_function,
    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

-- === HUD functions ===
function demoiselle.show_hud(self, player)
    if not player or self._hud_id then return end
    self._hud_id = player:hud_add({
        hud_elem_type = "statbar",
        position  = {x=0.5, y=0.95},
        size      = {x=24, y=24},
        text      = "demoiselle_hud.png",
        number    = 0xFFFFFF,
        direction = 0,
        alignment = {x=0, y=0},
    })
end

function demoiselle.update_hud(self, player)
    if not player or not self._hud_id then return end
    local speed = math.floor(vector.length(self.object:get_velocity())*10)
    local fuel = math.floor(self._energy*100)
    local alt = math.floor(self.object:get_pos().y)
    local display = speed + fuel + alt  -- simple example, can customize texture or number
    player:hud_change(self._hud_id, "number", display)
end

function demoiselle.hide_hud(self, player)
    if self._hud_id and player then
        player:hud_remove(self._hud_id)
        self._hud_id = nil
    end
end

function demoiselle.on_attach_player(self, player)
    demoiselle.show_hud(self, player)
end

function demoiselle.on_detach_player(self, player)
    demoiselle.hide_hud(self, player)
end

-- === Load other files ===
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "entities.lua")

-- === Remove old entities ===
local old_entities = {"demoiselle:seat_base","demoiselle:engine"}
for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata) self.object:remove() end,
    })
end
