local mineroutput = core.settings:get("technic_many_machines_cryptominer_output")
technic_many_machines.active_miner_count = 0
local temp_count = 0
local last_reset_time = 0
core.register_craftitem("technic_many_machines:crypto", {
    description = "crypto",
    inventory_image = "crypto.png",
})
core.register_abm({
    label = "Active Cryptominer Counter",
    nodenames = {"technic_many_machines:hv_cryptominer"},
    interval = 3,
    chance = 1,
    action = function(pos)
        local current_time = core.get_gametime()

        if current_time >= last_reset_time + 30 then
            technic_many_machines.active_miner_count = temp_count
            temp_count = 0
            last_reset_time = math.floor(current_time / 30) * 30
        end
        local meta = core.get_meta(pos)
        local level = meta:get_int("upgrades")
        temp_count = temp_count + 1 + level

    end,
})

local cryptocalc = function(miners)
    return math.ceil(300*miners^0.33)
end
local formspec = "size[10,8.5]" ..
    "no_prepend[]" ..
    "bgcolor[#2c0657]" ..
    "box[0,0;5.5,2.4;#111111CC]" ..
    "box[5.8,0;3.9,5;#111111CC]" ..
    "box[0,2.6;5.5,2.4;#111111CC]" ..
    "label[0.3,0.3;UPGRADES]" ..
    "list[current_name;upgrades;0.3,3.4;5,1;]" ..
    "list[current_name;dst;0.3,1;5,1]" ..
    "list[current_player;main;0.5,5.5;9,3;]" ..
    "label[6,0.1;STATUS]" ..
    "label[6,0.6;Hashrate: H/s]" ..
    "label[6,1.1;Total Time Remaining: ]" ..
    "label[6,1.6;Time For Next: ]" ..
    "label[6,2.1;Total EU Draw: ]" ..
    "label[6,2.6;Upgrades: ]" ..
    "label[6,3.1;Difficulty: ]" ..
    "label[6,3.6;Total Yield: ]" ..
    "label[6,4.1;Status: Mining...]" ..
    "box[0.2,4.5;5.1,0.3;#333333FF]" ..
    "label[0.2,2.8;Output:]" ..
    "label[0.2,4.4;Progress: 0%]" ..
    "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

core.register_node("technic_many_machines:hv_cryptominer", {
    description = "HV Crypto Miner",
    groups = {cracky = 2, oddly_breakable_by_hand = 1, technic_machine = 1, technic_hv = 1},
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        "technic_many_machines_hv_side.png", 
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_crypto_miner.png",
    },
    paramtype2 = "facedir",
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local timer = core.get_node_timer(pos)
        inv:set_size("upgrades", 5)
        inv:set_size("dst", 5)      
        meta:set_string("formspec", formspec)
        meta:set_int("HV_EU_demand", 5000)
        meta:set_int("time", 0)
        meta:set_int("totalyield", 0)
        meta:set_int("hashes/sec", 1)
        meta:set_int("upgrades", 0)
        timer:start(2)
    end,


    on_timer = function(pos)
        local meta = core.get_meta(pos)
        local time = meta:get_int("time")
        local power = meta:get_int("HV_EU_input") -- power input
        local timer = core.get_node_timer(pos)
        local difficulty = math.ceil(300*technic_many_machines.active_miner_count^0.6)
        local totalyield = meta:get_int("totalyield")
        local hashespersec = meta:get_int("hashes/sec")
        local timeuntilnext
        --calculate difficulty
        if difficulty == 0 then
            difficulty = 300
        end
        if meta:get_int("timeuntilnext") == 0 then
            meta:set_int("timeuntilnext", difficulty)
            timeuntilnext = difficulty 
        else
            timeuntilnext = meta:get_int("timeuntilnext")
        end
        local time_remaining = timeuntilnext - time
        local status
        if power >= 5000*(1+meta:get_int("upgrades")) then
            meta:set_int("time", time + 2*hashespersec)
            time = time+2
            status = "Mining"
            meta:set_string("infotext", "HV Cryptominer Active")
            if time >= timeuntilnext then
                local inv = meta:get_inventory()
                inv:add_item("dst", mineroutput)
                meta:set_int("totalyield", totalyield + 1)
                timeuntilnext = difficulty
                meta:set_int("timeuntilnext", difficulty)
                meta:set_int("time", 0)
            end
        else
            status = "Unpowered"
            meta:set_string("infotext", "HV Cryptominer Unpowered")
        end
        local inv = meta:get_inventory()
        local upgrade_count = 0
        for i=1, inv:get_size("upgrades") do
            local stack = inv:get_stack("upgrades", i)
            if stack:get_name() == "technic_many_machines:hv_cryptominer" then
                upgrade_count = upgrade_count + stack:get_count()
            end
        end
        meta:set_int("HV_EU_demand", 5000*(upgrade_count + 1))
        meta:set_int("upgrades", upgrade_count)
        meta:set_int("hashes/sec", 1+  upgrade_count)
        local hveudemand = 5000*(upgrade_count + 1)
        --nonsense for repeating dots
        local dot_count = ((time/2 - 1) % 3) + 1
        local dots = string.rep(".", dot_count)
        --calculate progress bar length and percent
        local percent = math.ceil(100-time_remaining*100/timeuntilnext)/100
        local barpercent = 5.1*percent
        percent = percent*100
        local formspec = "size[10,8.5]" ..
        "no_prepend[]" ..
        "bgcolor[#2c0657]" ..
        "box[0,0;5.5,2.4;#111111CC]" ..
        "box[5.8,0;3.9,5;#111111CC]" ..
        "box[0,2.6;5.5,2.4;#111111CC]" ..
        "label[0.3,0.3;UPGRADES]" ..
        "list[current_name;dst;0.3,3.4;5,1;]" ..
        "list[current_name;upgrades;0.3,1;5,1]" ..
        "list[current_player;main;0.5,5.5;9,3;]" ..
        "label[6,0.1;STATUS]" ..
        "label[6,0.6;Hashrate: "..(upgrade_count+1).."/s]" ..
        "label[6,1.1;Total Hashes Remaining: "..time_remaining.."]" ..
        "label[6,1.6;Hashes For Next: "..timeuntilnext.."]" ..
        "label[6,2.1;Total EU Draw: "..hveudemand.."]" ..
        "label[6,2.6;Upgrades: "..upgrade_count.."]" ..
        "label[6,3.1;Difficulty: "..difficulty.."]" ..
        "label[6,3.6;Total Yield: "..totalyield.."]" ..
        "label[6,4.1;Status: "..status..dots.."]" ..
        "box[0.2,4.5;5.1,0.3;#333333FF]" ..
        "box[0.2,4.5;"..barpercent..",0.3;#1c8727]" ..
        "label[0.2,2.8;Output:]" ..
        "label[0.2,4.4;Progress: "..percent.."%]" ..
        "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"
        meta:set_string("formspec", formspec)
        timer:start(2)
    end,
})

technic.register_machine("HV", "technic_many_machines:hv_cryptominer", technic.receiver)
