
local function flood_fill(nodeName, pos, directions, normal, result, limit)

		-- Function to check if {a, b, c} exists in the table
		local function hasElement(table, a, b, c)
			for _, v in ipairs(table) do
				if v[1] == a and v[2] == b and v[3] == c then
					return true
				end
			end
			return false
		end


	if limit <= 0 then
		return
	end

	--print("\n1 floodFill",nodeName, pos.x, pos.y, pos.z)
	for _, dir in pairs(directions) do
		--pos1 = {pos[1]+dir[1], pos[2]+dir[2], pos[3]+dir[3]}

		pos1 = {x,y,z}
		pos1 = {pos.x+dir[1], pos.y+dir[2], pos.z+dir[3]}
		pos1.x = pos.x+dir[1]
		pos1.y = pos.y+dir[2]
		pos1.z = pos.z+dir[3]

		pos2 = {x,y,z}
		pos2.x = pos1.x+normal.x
		pos2.y = pos1.y+normal.y
		pos2.z = pos1.z+normal.z

		local nodeEmpty = minetest.get_node(pos2)
		local nodeEmpty = minetest.get_node(pos2)


		if minetest.registered_nodes[nodeEmpty.name].buildable_to
			and not hasElement(result, pos1.x, pos1.y, pos1.z)
			and limit > 0
		then

			local node = minetest.get_node(pos1)
			local node = minetest.get_node(pos1)
			if ( node.name == nodeName ) then
				limit = limit - 1
				table.insert(result, {pos1.x, pos1.y, pos1.z})
				flood_fill(nodeName, pos1, directions, normal, result, limit)
			end
		end
	end
end

return flood_fill

