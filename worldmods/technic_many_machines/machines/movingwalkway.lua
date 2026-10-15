local smootherwalkway = core.settings:get_bool("technic_many_machines.walkwaysmooth") or false
local walkwayspeed = core.settings:get_bool("technic_many_machines.walkway_speed") or 1
local animspeed = 0.5/walkwayspeed
local time
local step = walkwayspeed
        if smootherwalkway == true then
            step = walkwayspeed / 10
        else 
            step = walkwayspeed / 2
        end

if smootherwalkway == true then 
    time = 0.1
else
    time = 0.5
end
local S = core.get_translator("technic_many_machines")
core.register_node("technic_many_machines:lv_moving_walkway", {
    description = S("LV Moving Walkway"),
    tiles = {
        {
            name = "movingwalkwaytop.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = animspeed, --2 blocks per second default
            },
        },
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, technic_machine = 1, technic_lv = 1},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local timer = core.get_node_timer(pos)
        timer:start(time)
        meta:set_int("LV_EU_demand", 80)
    end,
    on_timer = function(pos)
        local meta = core.get_meta(pos)
        local timer = core.get_node_timer(pos)
        local power = meta:get_int("LV_EU_input")
        local node = core.get_node(pos)
        local dir = node.param2
        if power >= 80 then
            local objects = core.get_objects_inside_radius({x=pos.x, y=pos.y+0.5, z=pos.z}, 0.5)
            for _, obj in ipairs(objects) do
                if obj:is_player() then
                    local startpos = obj:get_pos()
                    local endpos
                    if dir == 0 then
                        endpos = {x=startpos.x, y=startpos.y, z=startpos.z + step}
                    elseif dir == 1 then
                        endpos = {x=startpos.x + step, y=startpos.y, z=startpos.z}
                    elseif dir == 2 then
                        endpos = {x=startpos.x, y=startpos.y, z=startpos.z - step}
                    elseif dir == 3 then
                        endpos = {x=startpos.x - step, y=startpos.y, z=startpos.z}
                    end
                    -- Check if destination is walkable
                    local dest_node = core.get_node({x=math.floor(endpos.x+0.5), y=math.floor(endpos.y+0.5), z=math.floor(endpos.z+0.5)})
                    local dest_def = core.registered_nodes[dest_node.name]
                    if dest_def and (dest_def.walkable == false or dest_def.walkable == nil) then
                        obj:set_pos(endpos)
                    end
                end
            end
        end
        timer:start(time)
    end,
    technic_run = function(pos, node)
        local meta = core.get_meta(pos)
        local input = meta:get_int("LV_EU_input")
        if input >= 80 then
            meta:set_string("infotext", S("LV Moving Walkway Active"))
        else
            meta:set_string("infotext", S("LV Moving Walkway Unpowered"))
        end
    end,
})
technic.register_machine("LV", "technic_many_machines:lv_moving_walkway", technic.receiver)
