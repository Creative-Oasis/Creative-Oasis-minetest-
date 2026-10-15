-- Check if the pointed node is the type we want to remove from stack
local function remove_from_inventory(user, node, num_to_remove)
	local removed_count = 0

	local inventory = user:get_inventory()
	local main_inv = inventory:get_list("main")

	local inv_size = inventory:get_size("main")

	-- Iterate through the player's inventory in reverse
	for index = inv_size, 1, -1 do

	-- Loop through the player's inventory
	--for index, stack in ipairs(main_inv) do

		local stack = main_inv[index]
		if stack:get_name() == node.name then
			local stack_count = stack:get_count()
			if stack_count >= num_to_remove then
				-- Remove the entire stack if it has enough nodes
				stack:take_item(num_to_remove)
				inventory:set_stack("main", index, stack)
				removed_count = removed_count + num_to_remove
				break  -- Stop iterating since we removed the desired number of nodes
			else
				-- Remove the entire stack and move to the next
				inventory:set_stack("main", index, ItemStack(nil))  -- Clear the stack
				removed_count = removed_count + stack_count
				num_to_remove = num_to_remove - stack_count
			end
		end
	end

	--minetest.chat_send_player(user:get_player_name(), "Removed " .. removed_count .." "..node.name )
end

return remove_from_inventory
