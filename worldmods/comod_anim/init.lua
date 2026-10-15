-- comod_anim
-- Luanti 5.17 / Minetest Game

local basepos = vector.new(0, 6.35, 0)

-- Camera settings
local SNEAK_EYE_Y = -2.0
local CAMERA_SMOOTHING = 20

-- Sprint detection
local SPRINT_SPEED_THRESHOLD = 4.0

-- Animation speeds
local STAND_SPEED = 30
local WALK_SPEED = 30
local SPRINT_SPEED = 45

-- Body rotation angles (radians)
local BODY_SNEAK_LEAN = -0.22
local BODY_SPRINT_LEAN = -0.18

-- Performance settings
local BONE_SMOOTHING = 0.10
local CAMERA_THRESHOLD = 0.001

local states = {}

local get_connected_players = minetest.get_connected_players
local sqrt = math.sqrt
local min = math.min
local abs = math.abs
local exp = math.exp

local function get_state(name)
    local state = states[name]

    if not state then
        state = {
            animation = nil,
            pose = nil,
            head_pitch = nil,
            camera_y = 0,
            applied_eye_y = nil,
        }

        states[name] = state
    end

    return state
end

local function has_movement_input(control)
    return control.up or control.down
        or control.left or control.right
end

local function choose_animation(control, speed)
    if control.sneak then
        return "sneak"
    end

    if control.aux1
        and has_movement_input(control)
        and speed >= SPRINT_SPEED_THRESHOLD then
        return "sprint"
    end

    if has_movement_input(control) and speed > 0.1 then
        return "walk"
    end

    return "stand"
end

local function set_bone(
    player, name, x, y, z, absolute, interpolation
)
    player:set_bone_override(name, {
        rotation = {
            vec = vector.new(x, y, z),
            absolute = absolute,
            interpolation = interpolation or 0,
        },
    })
end

local function apply_animation(player, state, animation)
    if state.animation == animation then
        return
    end

    state.animation = animation

    if not player_api or not player_api.set_animation then
        return
    end

    if animation == "walk" then
        player_api.set_animation(player, "walk", WALK_SPEED)
    elseif animation == "sprint" then
        player_api.set_animation(player, "walk", SPRINT_SPEED)
    else
        player_api.set_animation(player, "stand", STAND_SPEED)
    end
end

local function apply_body_pose(player, state, animation)
    if state.pose == animation then
        return
    end

    state.pose = animation

    if animation == "sneak" then
        set_bone(
            player, "Body",
            BODY_SNEAK_LEAN, 0, 0, false, BONE_SMOOTHING
        )

        -- Counter-rotate legs to reduce clipping.
        set_bone(
            player, "Leg_Left",
            -BODY_SNEAK_LEAN, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Leg_Right",
            -BODY_SNEAK_LEAN, 0, 0, false, BONE_SMOOTHING
        )

        set_bone(
            player, "Arm_Left", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Arm_Right", 0, 0, 0, false, BONE_SMOOTHING
        )

    elseif animation == "sprint" then
        set_bone(
            player, "Body",
            BODY_SPRINT_LEAN, 0, 0, false, BONE_SMOOTHING
        )

        set_bone(
            player, "Arm_Left", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Arm_Right", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Leg_Left", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Leg_Right", 0, 0, 0, false, BONE_SMOOTHING
        )

    else
        -- Reset the custom body pose.
        set_bone(
            player, "Body", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Arm_Left", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Arm_Right", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Leg_Left", 0, 0, 0, false, BONE_SMOOTHING
        )
        set_bone(
            player, "Leg_Right", 0, 0, 0, false, BONE_SMOOTHING
        )
    end
end

local function apply_head(player, state, animation)
    local pitch = -player:get_look_vertical()

    -- Compensate for torso lean while sneaking or sprinting.
    if animation == "sneak" then
        pitch = pitch - BODY_SNEAK_LEAN
    elseif animation == "sprint" then
        pitch = pitch - BODY_SPRINT_LEAN
    end

    -- Update only when the pitch actually changes.
    if state.head_pitch == pitch then
        return
    end

    state.head_pitch = pitch

    -- Follow the look direction immediately.
    player:set_bone_override("Head", {
        position = {
            vec = basepos,
            absolute = true,
            interpolation = 0,
        },
        rotation = {
            vec = vector.new(pitch, 0, 0),
            absolute = true,
            interpolation = 0,
        },
    })
end

local function update_camera(player, state, dtime, sneaking)
    -- Never overwrite a vehicle or mount's camera offset.
    if player:get_attach() then
        state.applied_eye_y = nil
        return
    end

    local target_y = sneaking and SNEAK_EYE_Y or 0

    -- Smooth camera movement.
    local alpha = 1 - exp(
        -CAMERA_SMOOTHING * min(dtime, 0.1)
    )

    state.camera_y = state.camera_y
        + (target_y - state.camera_y) * alpha

    if abs(state.camera_y - target_y) < CAMERA_THRESHOLD then
        state.camera_y = target_y
    end

    if state.applied_eye_y ~= nil
        and abs(state.camera_y - state.applied_eye_y)
            < CAMERA_THRESHOLD then
        return
    end

    state.applied_eye_y = state.camera_y

    player:set_eye_offset(
        vector.new(0, state.camera_y, 0),
        vector.zero(),
        vector.zero()
    )
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(get_connected_players()) do
        local name = player:get_player_name()
        local control = player:get_player_control()
        local state = get_state(name)

        -- Attached players are controlled by vehicles or mounts.
        if player:get_attach() then
            -- Remove the custom sneak/sprint pose.
            if state.pose ~= "stand" then
                apply_body_pose(player, state, "stand")
            end

            -- Let the vehicle or mount control the animation.
            state.animation = nil
            state.head_pitch = nil

            -- Do not overwrite the vehicle's camera offset.
            state.applied_eye_y = nil

        else
            local velocity = player:get_velocity()

            local horizontal_speed = sqrt(
                velocity.x * velocity.x
                + velocity.z * velocity.z
            )

            local animation = choose_animation(
                control,
                horizontal_speed
            )

            apply_animation(player, state, animation)
            apply_body_pose(player, state, animation)
            apply_head(player, state, animation)

            update_camera(
                player, state, dtime, control.sneak
            )
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    states[player:get_player_name()] = nil
end)