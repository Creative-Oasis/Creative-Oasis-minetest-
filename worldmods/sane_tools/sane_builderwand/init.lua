-- ok, after_use is called once ter dig_node, we don't need this
local WEAR_PER_BLOCK = math.floor(65535 / 1000 +0.5)


minetest.register_tool("sane_builderwand:sane_builderwand", {
	description = "Builder Wand - Adds one layer",
	short_description = "Sane Builder Wand",
	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
	inventory_image="sane_builderwand.png",
	range=8,
	liquids_pointable = false,
	light_source = 8,
-- 	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
--
-- 	tool_capabilities = {
-- 		full_punch_interval = 0.83333333,
-- 		max_drop_level = 4,
-- 		groupcaps = {
-- 			choppy =				{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			cracky=					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			crumbly =				{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			snappy =				{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			oddly_breakable_by_hand={times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey =				{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			axey=					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			shovely=				{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey_dig_iron =		{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2}
-- 		},
-- 		damage_groups = {fleshy=1},
-- 	},


	after_use = function(itemstack, user, node, digparams)
		local wear = itemstack:get_wear()
		if wear >= 65535 then
			--minetest.chat_send_player(user:get_player_name(), "Please fix your Builder Wand!")
		else
			itemstack:add_wear(digparams.wear)
		end
		return itemstack
	end,


    -- Define the on_place function (right-click)
    on_place = function(itemstack, user, pointed_thing)

		local player_name = user:get_player_name()
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)

		local meta = itemstack:get_meta()
		    -- Check if the pointed node is a chest or similar
		--if minetest.get_item_group(node.name, "chest") > 0 then
			-- Attempt to call the on_rightclick function of the node
			local def = minetest.registered_nodes[node.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pos, node, user, itemstack, pointed_thing)
			end
		--end

		local wear = itemstack:get_wear()
		if wear >= 65535 then
			minetest.chat_send_player(user:get_player_name(), "Your Wand needs to be repaired!")
			return
		end

		local flood_fill = dofile(minetest.get_modpath("sane_shared") .. "/flood_fill.lua")
		local check_inventory = dofile(minetest.get_modpath("sane_shared") .. "/check_inventory.lua")
		local remove_from_inventory = dofile(minetest.get_modpath("sane_shared") .. "/remove_from_inventory.lua")
		local get_pointed_normal = dofile(minetest.get_modpath("sane_shared") .. "/get_pointed_normal.lua")

		local playerName = user:get_player_name()
   		--minetest.chat_send_player(playerName, "You right-clicked the tool!")

   		local player = minetest.get_player_by_name(playerName)
   		--print("player ", player)

        if not pointed_thing or not pointed_thing.above then
			--minetest.chat_send_player(user:get_player_name(), "pointed_thing not found!")
            return itemstack
        end

        --minetest.chat_send_player(user:get_player_name(), node.name)

		result = {}
		normal = {0,1,0}
		normal = get_pointed_normal(user)


		max_avail = check_inventory(user, node, 66)

		local directions_xz = {
			{ 0, 0, -1}, { 0, 0, 1}, {-1, 0, 0}, {1, 0, 0},	-- Ortogonal directions
			{-1, 0, -1}, {-1, 0, 1}, { 1, 0,-1}, {1, 0, 1}	-- Diagonal directions
		}

		local directions_yx = {
			{ 0, -1, 0}, { 0, 1, 0}, {-1, 0, 0}, {1, 0, 0},	-- Ortogonal directions
			{-1, -1, 0}, {-1, 1, 0}, { 1,-1, 0}, {1, 1, 0}	-- Diagonal directions
		}

		local directions_yz = {
			{0, 0,-1}, {0, 0, 1}, {0,-1, 0}, {0, 1, 0},	-- Ortogonal directions
			{0,-1,-1}, {0,-1, 1}, {0, 1,-1}, {0, 1, 1}	-- Diagonal directions
		}

		--print("normal = ",normal)
		-- TODO direction_?? should be a table of tables indexed by normal
		if normal == nil then
			return itemstack
		elseif normal[2] ~= 0 then
			flood_fill(node.name, pos, directions_xz, normal, result, max_avail)
		elseif normal[1] ~= 0 then
			flood_fill(node.name, pos, directions_yz, normal, result, max_avail)
		elseif normal[3] ~= 0 then
			flood_fill(node.name, pos, directions_yx, normal, result, max_avail)
		end

-- 		print("\nmax_avail", max_avail)
-- 		for _, res in pairs(result) do
-- 			print(res[1], res[2], res[3])
-- 		end

		local node_metadata = {
			name = node_name,
			param2 = param2
		}

		local undoStack = {nodeU,posU}

		-- TODO doesn't put all the stairs all the expected stairs
		local used = 0
		if ( max_avail > 0 ) then
			posFirst = {x=pos.x+normal[1], y=pos.y+normal[2], z=pos.z+normal[3]}
			deleteNode = minetest.get_node(posFirst)
			table.insert(undoStack, {nodeU=deleteNode,posU=posFirst})
			minetest.set_node( posFirst, {name = node.name, param2 = node.param2})

			used = 1
		end

		local posr = {["x"] = 0, ["y"] = 0, ["z"] = 0}
		for _, res in pairs(result) do
			if ( used > max_avail ) then
				break
			end
			posr.x = res[1]
			posr.y = res[2]
			posr.z = res[3]

			local nodepair = minetest.get_node(posr)

			posr.x = res[1] + normal[1]
			posr.y = res[2] + normal[2]
			posr.z = res[3] + normal[3]
			deleteNode = minetest.get_node(posr)
			table.insert(undoStack, {nodeU=deleteNode,posU=posr})
			minetest.set_node(posr, {name = node.name, param2 = nodepair.param2})
			used = used + 1
			--print("result ",posr)
		end

   		remove_from_inventory(user, node, used-1)

		if wear < 65535 then
			wear = wear + used * WEAR_PER_BLOCK
			if wear > 65535 then
				wear = 65535
			end
			itemstack:set_wear(wear)

			-- Update the tool's wear to show on the hotbar
			--minetest.chat_send_player(user:get_player_name(), "Wear: " .. wear)
		else
			minetest.chat_send_player(user:get_player_name(), "Tool is broken!")
		end

   		return itemstack
    end,

})


local ingredients
if minetest.get_modpath("mcl_core") then
		ingredients = {
				stick		= "mcl_core:stick",
				ironBlock	= "mcl_core:ironblock",
				ironIngot	= "mcl_core:iron_ingot",
				extraIngot	= "mcl_copper:copper_ingot",
				repair		= "mcl_core:stick"

		}
elseif minetest.get_modpath("default") then
		ingredients = {
				stick		 = "default:stick",
				ironBlock = "default:steelblock",
				ironIngot = "default:steel_ingot",
				extraIngot = "default:copper_ingot",
				repair = "default:stick"
		}
end



if ingredients then
	minetest.register_craft({
		output = "sane_builderwand:sane_builderwand",
		recipe = {
			{ingredients.extraIngot, ingredients.ironBlock, ingredients.extraIngot},
			{"", ingredients.stick, ""},
			{"", ingredients.stick, ""},
		},
	})

	minetest.register_craft({
			output = "sane_builderwand:sane_builderwand",
			recipe = {
				{"", "", ""},
				{"", ingredients.repair, "sane_builderwand:sane_builderwand"},
				{"", "", ""},
			},
		})

end



