-- Load support for MT game translation.
local S = minetest.get_translator("mtc_chisel")

local cobblestone_count = 21
local brick_count = 1

local dug_node = {}
minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger then return end
	dug_node[digger:get_player_name()] = pos
end)


local function handler(player_name, node, itemstack, digparams)
	local pos = dug_node[player_name]
	if not pos then return end

		local ndef = minetest.registered_nodes[node.name]
		if ndef then
			local item = ItemStack(ndef.drop or node.name)
			local inv = minetest.get_inventory({type="player", name=player_name})
			if inv and inv:room_for_item("main", item) then
				local taken = inv:remove_item("main", item)
			else
				for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
					obj:remove()
					break
				end
			end
		end
		--Cobblestone
		for i = 1,cobblestone_count do
			local j = i+1

			if j == cobblestone_count+1 then
				j = 1
			end

			local original = "mtc_chisel:cobblestone_" .. i
			local next = "mtc_chisel:cobblestone_" .. j
			if node.name == original then
				node.name = next
				break
			end
		end
		if node.name == "default:cobble" then
			node.name = "mtc_chisel:cobblestone_1"
		end
		--Brick
		for i = 1,brick_count do
			local j = i+1

			if j == brick_count+1 then
				j = 1
			end

			local original = "mtc_chisel:brick_" .. i
			local next = "mtc_chisel:brick_" .. j
			if node.name == original then
				node.name = next
				break
			end
		end
		if node.name == "default:brick" then
			node.name = "mtc_chisel:brick_1"
		end
		minetest.swap_node(pos, node)
		minetest.check_single_for_falling(pos)
end

local function reverse_handler(player_name, node, itemstack, digparams)
	local pos = dug_node[player_name]
	if not pos then return end

		local ndef = minetest.registered_nodes[node.name]
		if ndef then
			local item = ItemStack(ndef.drop or node.name)
			local inv = minetest.get_inventory({type="player", name=player_name})
			if inv and inv:room_for_item("main", item) then
				local taken = inv:remove_item("main", item)
			else
				for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
					obj:remove()
					break
				end
			end
		end
		--Cobblestone
		for i = cobblestone_count,1,-1 do
			local j = i-1

			if j == 0 then
				j = cobblestone_count
			end

			local original = "mtc_chisel:cobblestone_" .. i
			local next = "mtc_chisel:cobblestone_" .. j
			if node.name == original then
				node.name = next
				break
			end
		end
		if node.name == "default:cobble" then
			node.name = "mtc_chisel:cobblestone_" .. cobblestone_count
		end
		--Brick
		for i = brick_count,1,-1 do
			local j = i-1

			if j == 0 then
				j = brick_count
			end

			local original = "mtc_chisel:brick_" .. i
			local next = "mtc_chisel:brick_" .. j
			if node.name == original then
				node.name = next
				break
			end
		end
		if node.name == "default:brick" then
			node.name = "mtc_chisel:brick_" .. brick_count
		end
		minetest.swap_node(pos, node)
		minetest.check_single_for_falling(pos)
end
local function zero_handler(player_name, node, itemstack, digparams)
	local pos = dug_node[player_name]
	if not pos then return end

		local ndef = minetest.registered_nodes[node.name]
		if ndef then
			local item = ItemStack(ndef.drop or node.name)
			local inv = minetest.get_inventory({type="player", name=player_name})
			if inv and inv:room_for_item("main", item) then
				local taken = inv:remove_item("main", item)
			else
				for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
					obj:remove()
					break
				end
			end
		end
		--Cobblestone
		for i = 1,cobblestone_count do
			local original = "mtc_chisel:cobblestone_" .. i
			if node.name == original then
				node.name = "default:cobble"
				break
			end
		end
		--Brick
		for i = 1,brick_count do
			local original = "mtc_chisel:brick_" .. i
			if node.name == original then
				node.name = "default:brick"
				break
			end
		end
		minetest.swap_node(pos, node)
		minetest.check_single_for_falling(pos)
end



-- Chisel
minetest.register_tool("mtc_chisel:chisel", {
	description = S("Chisel"),
	inventory_image = "mtc_chisel_chisel.png",
	groups = {chisel_chisel=1},
	tool_capabilities = {
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
	},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.01, handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})
minetest.register_craft({
	output = "mtc_chisel:chisel",
	recipe = {
		{"","","default:steel_ingot"},
		{"","default:steel_ingot",""},
		{"default:stick","",""},
	}
})

-- Left-Chisel
minetest.register_tool("mtc_chisel:left_chisel", {
	description = S("Left Chisel"),
	inventory_image = "mtc_chisel_left_chisel.png",
	groups = {chisel_chisel=1},
	tool_capabilities = {
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
	},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.01, reverse_handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})
minetest.register_craft({
	type="shapeless",
	output = "mtc_chisel:left_chisel",
	recipe = {"mtc_chisel:chisel","bucket:bucket_water"},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})


-- Zero-Chisel
minetest.register_tool("mtc_chisel:zero_chisel", {
	description = S("Zero Chisel"),
	inventory_image = "mtc_chisel_zero_chisel.png",
	groups = {chisel_chisel=1},
	tool_capabilities = {
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
	},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.01, zero_handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})
minetest.register_craft({
	type="shapeless",
	output = "mtc_chisel:zero_chisel",
	recipe = {"mtc_chisel:chisel","default:gold_ingot"},
})