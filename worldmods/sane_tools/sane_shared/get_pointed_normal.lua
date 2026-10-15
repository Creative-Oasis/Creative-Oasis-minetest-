
function get_pointed_normal(player)

	local function get_pointed_thing(player)
		local eye_y = player:get_properties().eye_height
		local offset_1st, offset_3rd = player:get_eye_offset()

		local pos1 = vector.add(player:get_pos(), offset_1st)
		pos1.y = pos1.y + eye_y

		-- Get actual tool range
		local wield_item = player:get_wielded_item()
		local tool_range = hand_range
		if wield_item:is_known() then
			tool_range = wield_item:get_definition().range or hand_range
		end

		-- Shoot into the look direction
		local look_dir = player:get_look_dir()
		local pos2 = vector.add(pos1, vector.multiply(look_dir, tool_range or 8))

		local raycast = core.raycast(pos1, pos2, true, false)
		local pointed = raycast:next()
		if pointed and pointed.type == "object"
				and pointed.ref == player then
			pointed = raycast:next()
		end
		return pointed
	end


	local pointed_thing = get_pointed_thing(player)
	if pointed_thing then
		return pointed_thing.intersection_normal
	else
		return nil
	end
end

return get_pointed_normal
