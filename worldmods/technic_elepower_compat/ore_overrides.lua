--Ore overrides to clear unneeded ores.
local lead_to_use = minetest.settings:get("lead_used") or "both"

if lead_to_use == "technic" then
    minetest.register_abm({
        nodenames = {"elepower_dynamics:stone_with_lead"}, -- replace with the name of the ore
        interval = 1, -- runs every 1 second
        chance = 1, -- always fires
        action = function(pos)
            minetest.swap_node(pos, {name = "default:stone"})
        end,
    })
elseif lead_to_use == "elepower" then
    minetest.register_abm({
        nodenames = {"technic:mineral_lead"}, -- replace with the name of the ore
		interval = 1, -- runs every 1 second
    	chance = 1, -- always fires
		action = function(pos)
        	minetest.swap_node(pos, {name = "default:stone"})
    	end,
    })
elseif lead_to_use == "both" then
	return false
end

local zinc_to_use = minetest.settings:get("zinc_used") or "both"

if zinc_to_use == "technic" then
    minetest.register_abm({
    	nodenames = {"elepower_dynamics:stone_with_zinc"}, -- replace with the name of the ore
    	interval = 1, -- runs every 1 second
    	chance = 1, -- always fires
    	action = function(pos)
        	minetest.swap_node(pos, {name = "default:stone"})
    	end,
    })
elseif zinc_to_use == "elepower" then 
    minetest.register_abm({
        nodenames = {"technic:mineral_zinc"}, -- replace with the name of the ore
	interval = 1, -- runs every 1 second
    	chance = 1, -- always fires
  	action = function(pos)
        	minetest.swap_node(pos, {name = "default:stone"})
    	end,
    })
elseif zinc_to_use == "both" then
    return false
end