-- =========================================
-- MCL-style Auto Pickup for Minetest Game
-- =========================================

local pickup_radius = 1.1
local pickup_delay = 1.1

local pull_strength = 8
local max_speed = 4
local damping = 0.85

local max_player_speed = 6.5 -- disable pickup when moving fast

-- -----------------------------------------
-- Helpers
-- -----------------------------------------
local function get_player_speed(player)
    local v = player:get_velocity()
    if not v then return 0 end
    return math.sqrt(v.x * v.x + v.z * v.z)
end

local function player_valid(name)
    local p = minetest.get_player_by_name(name)
    return p and p:is_player()
end

-- -----------------------------------------
-- Main logic
-- -----------------------------------------
minetest.register_globalstep(function(dtime)
    local now = minetest.get_us_time() / 1e6

    for _, player in ipairs(minetest.get_connected_players()) do
        local ppos = player:get_pos()
        local pname = player:get_player_name()
        local inv = player:get_inventory()

        -- disable pickup if player is moving fast
        if get_player_speed(player) > max_player_speed then
            goto next_player
        end

        local objects = minetest.get_objects_inside_radius(ppos, pickup_radius)

        for _, obj in ipairs(objects) do
            local ent = obj:get_luaentity()
            if not ent or ent.name ~= "__builtin:item" then
                goto continue
            end

            local itemstack = ent.itemstring
            if itemstack == "" then
                goto continue
            end

            -- init pickup delay timer
            if not ent._pickup_time then
                ent._pickup_time = now
            end

            if now - ent._pickup_time < pickup_delay then
                goto continue
            end

            -- determine / validate owner
            local owner_name = ent._pickup_owner
            local owner = owner_name and minetest.get_player_by_name(owner_name)

            -- lock to nearest player if unlocked
            if not owner then
                ent._pickup_owner = pname
                ent._owner_time = now
                owner = player
            end

            -- ignore if this item belongs to another player
            if owner ~= player then
                goto continue
            end

            -- unlock if owner invalid or moving fast
            if not player_valid(ent._pickup_owner)
            or get_player_speed(owner) > max_player_speed then
                ent._pickup_owner = nil
                ent._owner_time = nil
                goto continue
            end

            -- inventory check
            if not inv:room_for_item("main", itemstack) then
                goto continue
            end

            local opos = obj:get_pos()
            local dist = vector.distance(ppos, opos)

            -- final pickup
            if dist < 0.8 then
                inv:add_item("main", itemstack)
                obj:remove()
                minetest.sound_play("sneak_drop_pickup", {
                    pos = ppos,
                    gain = 0.35,
                    max_hear_distance = 16,
                })
                goto continue
            end

            -- smooth magnet pull toward OWNER ONLY
            local dir = vector.direction(opos, ppos)

            -- limit vertical pull (prevents flying)
            if dir.y > 0 then
                dir.y = dir.y * 0.2
            end

            local vel = obj:get_velocity() or vector.zero()
            local force = pull_strength * math.min(dist / pickup_radius, 1)
            local target_vel = vector.multiply(dir, force)

            vel = vector.add(
                vector.multiply(vel, damping),
                vector.multiply(target_vel, dtime * 10)
            )

            -- clamp velocity
            if vector.length(vel) > max_speed then
                vel = vector.multiply(vector.normalize(vel), max_speed)
            end

            obj:set_velocity(vel)
            obj:set_acceleration({x = 0, y = -9.8, z = 0}) -- gravity only

            ::continue::
        end

        ::next_player::
    end
end)
