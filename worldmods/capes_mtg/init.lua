-- capes_mtg/init.lua

local update_interval = 0.016
local frame_update_interval = 0.15

local timer = 0
local frame_timer = 0
local frame_global = 0

local cape_data = {}
local indicator_data = {}

local storage = minetest.get_mod_storage()

local world_wind = vector.new(0, 0, 0)
local world_wind_target = vector.new(
    math.random() * 2 - 1,
    0,
    math.random() * 2 - 1
)

local function get_cape(name)
    return storage:get_string("cape_" .. name)
end

local function set_cape(name, texture)
    storage:set_string("cape_" .. name, texture or "")
end

local function attach_entity(child, parent, bone, position, rotation)
    if not child or not parent then
        return
    end

    if child.set_attach then
        child:set_attach(
            parent,
            bone,
            position,
            rotation,
            false
        )
    elseif child.set_attachment then
        child:set_attachment(
            parent,
            bone,
            position,
            rotation,
            false
        )
    end
end

minetest.register_entity("capes_mtg:cape_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "cape_cosmetic.obj",
        textures = {"crown_cape.png"},
        visual_size = {
            x = 4,
            y = 4,
            z = 4
        },
        backface_culling = false,
        physical = false,
        pointable = false,
        static_save = false
    },

    on_activate = function(self)
        self.object:set_armor_groups({
            fleshy = 0
        })
    end
})

minetest.register_entity("capes_mtg:indicator_entity", {
    initial_properties = {
        visual = "sprite",
        visual_size = {
            x = 1,
            y = 0.25
        },
        textures = {"blank.png"},
        backface_culling = false,
        physical = false,
        pointable = false,
        static_save = false
    },

    on_activate = function(self)
        self.object:set_armor_groups({
            fleshy = 0
        })
    end
})

local function remove_cape(name)
    local data = cape_data[name]

    if data and data.obj then
        if data.obj:get_pos() then
            data.obj:remove()
        end
    end

    cape_data[name] = nil
end

local function give_cape(name, texture)
    if not texture or texture == "" then
        return false
    end

    set_cape(name, texture)

    remove_cape(name)

    return true
end

minetest.register_chatcommand("cape", {
    params = "<player> <pngname> | <player> clear",
    description = "Set or clear a player's cape",

    privs = {
        server = true
    },

    func = function(name, param)

        local target_name, cape_name =
            param:match("^%s*(%S+)%s+(%S+)%s*$")

        if not target_name or not cape_name then
            return false,
                "Usage: /cape <player> <pngname>"
                .. " or /cape <player> clear"
        end

        local target = minetest.get_player_by_name(target_name)

        if not target then
            return false,
                "Player '" .. target_name .. "' is not online."
        end

        local real_name = target:get_player_name()

        if cape_name:lower() == "clear" then
            set_cape(real_name, "")
            remove_cape(real_name)

            return true,
                "Cape cleared for " .. real_name .. "."
        end

        if not cape_name:lower():match("%.png$") then
            cape_name = cape_name .. "_cape.png"
        end

        local success = give_cape(
            real_name,
            cape_name
        )

        if not success then
            return false,
                "Invalid cape texture."
        end

        return true,
            "Cape '" .. cape_name
            .. "' set for " .. real_name .. "."
    end
})

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    remove_cape(name)

    local indicator = indicator_data[name]

    if indicator and indicator.obj then
        if indicator.obj:get_pos() then
            indicator.obj:remove()
        end
    end

    indicator_data[name] = nil
end)

minetest.register_globalstep(function(dtime)

    timer = timer + dtime
    frame_timer = frame_timer + dtime

    if timer < update_interval then
        return
    end

    timer = 0

    if frame_timer >= frame_update_interval then

        frame_timer = 0
        frame_global = (frame_global + 1) % 10

        for name, data in pairs(cape_data) do

            local cape_name = get_cape(name)

            if cape_name ~= "" then

                local frame_tex =
                    cape_name
                    .. "^[verticalframe:10:"
                    .. frame_global

                if data.obj and data.obj:get_pos() then
                    data.obj:set_properties({
                        textures = {frame_tex}
                    })
                end
            end
        end
    end

    world_wind = vector.add(
        world_wind,
        vector.multiply(
            vector.subtract(
                world_wind_target,
                world_wind
            ),
            0.02
        )
    )

    if math.random() < 0.05 then

        local WIND_MAX = 1.2
        local WIND_DELTA = 0.8

        world_wind_target.x = math.max(
            -WIND_MAX,
            math.min(
                WIND_MAX,
                world_wind_target.x
                    + (math.random() * 2 - 1)
                    * WIND_DELTA
            )
        )

        world_wind_target.z = math.max(
            -WIND_MAX,
            math.min(
                WIND_MAX,
                world_wind_target.z
                    + (math.random() * 2 - 1)
                    * WIND_DELTA
            )
        )
    end

    local gametime =
        minetest.get_gametime() + timer

    for _, player in ipairs(
        minetest.get_connected_players()
    ) do

        local name =
            player:get_player_name()

        local pos =
            player:get_pos()

        if pos then

            local cape_name =
                get_cape(name)

            if cape_name ~= "" then

                if not cape_data[name] then

                    local cape_obj =
                        minetest.add_entity(
                            pos,
                            "capes_mtg:cape_entity"
                        )

                    if cape_obj then

                        cape_obj:set_properties({
                            textures = {
                                cape_name
                            }
                        })

                        attach_entity(
                            cape_obj,
                            player,
                            "Body",
                            {
                                x = 0,
                                y = 6.3,
                                z = 1.2
                            },
                            {
                                x = 5,
                                y = 180,
                                z = 0
                            }
                        )

                        cape_data[name] = {
                            obj = cape_obj,
                            rot_x = 0,
                            rot_y = 0,
                            rot_z = 0
                        }
                    end

                else

                    local data =
                        cape_data[name]

                    local cape_obj =
                        data.obj

                    if cape_obj
                        and cape_obj:get_pos() then

                        local vel =
                            player:get_velocity()

                        if not vel then
                            vel = vector.new(
                                0,
                                0,
                                0
                            )
                        end

                        local yaw =
                            player:get_look_horizontal()

                        if not yaw then
                            yaw = 0
                        end

                        local forward =
                            vector.new(
                                -math.sin(yaw),
                                0,
                                math.cos(yaw)
                            )

                        local right =
                            vector.new(
                                math.cos(yaw),
                                0,
                                math.sin(yaw)
                            )

                        local f_speed =
                            vector.dot(
                                vel,
                                forward
                            )

                        local s_speed =
                            vector.dot(
                                vel,
                                right
                            )

                        local v_speed =
                            vel.y

                        if math.abs(f_speed)
                            < 0.01 then
                            f_speed = 0
                        end

                        if math.abs(s_speed)
                            < 0.01 then
                            s_speed = 0
                        end

                        local w_forward =
                            vector.dot(
                                world_wind,
                                forward
                            )

                        local w_strafe =
                            vector.dot(
                                world_wind,
                                right
                            )

                        local idle_wave =
                            math.sin(
                                gametime * 3
                            ) * 2.5

                        local idle_sway =
                            math.cos(
                                gametime * 2
                            ) * 1.5

                        local walk_speed =
                            math.sqrt(
                                f_speed * f_speed
                                    + s_speed * s_speed
                            )

                        local walk_swing =
                            -math.sin(
                                gametime * 10
                            ) * (
                                walk_speed * 1.8
                            )

                        local target_x =
                            (f_speed * 12)
                            + (w_forward * 8)
                            - (v_speed * 8)
                            + idle_wave

                        local target_y =
                            -(
                                (s_speed * 5)
                                + (w_strafe * 8)
                                + idle_sway
                            )

                        local target_z =
                            walk_swing
                            + (s_speed * 4)

                        target_x = math.max(
                            -8,
                            math.min(
                                80,
                                target_x
                            )
                        )

                        target_y = math.max(
                            -60,
                            math.min(
                                60,
                                target_y
                            )
                        )

                        target_z = math.max(
                            -25,
                            math.min(
                                25,
                                target_z
                            )
                        )

                        data.rot_x =
                            data.rot_x
                            + (
                                target_x
                                - data.rot_x
                            ) * 0.12

                        data.rot_y =
                            data.rot_y
                            + (
                                target_y
                                - data.rot_y
                            ) * 0.12

                        data.rot_z =
                            data.rot_z
                            + (
                                target_z
                                - data.rot_z
                            ) * 0.12

                        attach_entity(
                            cape_obj,
                            player,
                            "Body",
                            {
                                x = 0,
                                y = 6.3,
                                z = 1.2
                            },
                            {
                                x = 5 + data.rot_x,
                                y = 180 + data.rot_y,
                                z = data.rot_z
                            }
                        )

                    else
                        cape_data[name] = nil
                    end
                end

            else
                remove_cape(name)
            end

            if not indicator_data[name] then

                local ind_obj =
                    minetest.add_entity(
                        pos,
                        "capes_mtg:indicator_entity"
                    )

                if ind_obj then

                    attach_entity(
                        ind_obj,
                        player,
                        "",
                        {
                            x = 0,
                            y = 20,
                            z = 0
                        },
                        {
                            x = 0,
                            y = 0,
                            z = 0
                        }
                    )

                    indicator_data[name] = {
                        obj = ind_obj
                    }
                end
            end
        end
    end
end)