comod_lag = {}

-- sizes
local AREA_SIZE = 32      -- 2x2x2 mapblocks
local MIN_DISTANCE = 16  -- 1 mapblock

-- limits per area
comod_lag.limits = {
	["logistica:injector_fast"]     = 35,
	["logistica:injector_slow"]    = 35,
	["logistica:requester_item"]   = 35,
	["logistica:requester_stack"]  = 35,

	["pipeworks:filter"]           = 35,
	["pipeworks:mese_filter"]      = 30,
	["pipeworks:mese_tube_000000"] = 12,

	["gravelsieve:auto_sieve3"]    = 40,
	["logistica:cobblegen_supplier"] = 25,
}

-- align area to 2x2x2 mapblocks
local function get_area_bounds(pos)
	local minp = {
		x = math.floor(pos.x / AREA_SIZE) * AREA_SIZE,
		y = math.floor(pos.y / AREA_SIZE) * AREA_SIZE,
		z = math.floor(pos.z / AREA_SIZE) * AREA_SIZE,
	}
	local maxp = {
		x = minp.x + AREA_SIZE - 1,
		y = minp.y + AREA_SIZE - 1,
		z = minp.z + AREA_SIZE - 1,
	}
	return minp, maxp
end

-- show GUI
local function show_limit_formspec(player, nodename, limit)
	local fs =
		"formspec_version[4]" ..
		"size[9,4]" ..
		"label[0.4,1.2;There can be "..limit.." "..nodename.." maximum in this area]" ..
		"label[0.4,1.8;Place the next one at least 16 blocks away]" ..
		"button_exit[3.5,2.7;2,0.9;ok;OK]"

	minetest.show_formspec(player:get_player_name(), "comod_lag:limit", fs)
end

-- check nearest same machine distance
local function too_close_to_existing(pos, nodename)
	local r = MIN_DISTANCE
	local minp = vector.subtract(pos, r)
	local maxp = vector.add(pos, r)

	local nodes = minetest.find_nodes_in_area(minp, maxp, nodename)
	for _, p in ipairs(nodes) do
		if vector.distance(p, pos) < MIN_DISTANCE then
			return true
		end
	end
	return false
end

-- placement hook
minetest.register_on_placenode(function(pos, newnode, placer)
	if not placer or not placer:is_player() then
		return
	end

	local limit = comod_lag.limits[newnode.name]
	if not limit then
		return
	end

	local minp, maxp = get_area_bounds(pos)
	local count = #minetest.find_nodes_in_area(minp, maxp, newnode.name)

	-- includes the placed node
	if count > limit then
		-- if too close to nearest same machine, deny
		if too_close_to_existing(pos, newnode.name) then
			minetest.remove_node(pos)

			local inv = placer:get_inventory()
			if inv then
				inv:add_item("main", newnode.name)
			end

			show_limit_formspec(placer, newnode.name, limit)
			return true
		end
	end
end)
