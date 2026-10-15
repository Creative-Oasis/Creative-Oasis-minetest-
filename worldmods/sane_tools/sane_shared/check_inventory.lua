-- check inventory for enough of a type of node
local function check_inventory(user, node, enough)
	local inventory = user:get_inventory()
	local main_inv = inventory:get_list("main")
	local inv_size = inventory:get_size("main")

	local counting = 0

	-- Iterate through the player's inventory in reverse
	for index = inv_size, 1, -1 do
		local stack = main_inv[index]
		if stack:get_name() == node.name then
			counting = counting + stack:get_count()
			if counting >= enough then
				return enough
			end
		end
	end
	return counting
end

return check_inventory
