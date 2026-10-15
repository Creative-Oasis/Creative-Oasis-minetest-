-- mods/too_many_stones/flowstones.lua

-- support for MT game translation.
local S = minetest.get_translator("too_many_stones")

-- Settings
local growth_interval = 1 -- Debug: 1 second, Production: 300 (5 minutes)
local growth_chance = 1.0 -- Debug: 100%, Production: 0.7 (30% fail = 70% success)

-- Helper function to get flowstone base name (removes _flowstone_X suffix)
local function get_base_stone_name(flowstone_name)
return flowstone_name:match("too_many_stones:(.+)_flowstone_%d+")
end

-- Helper function to check if there's water directly above a position
local function has_water_above(pos)
local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
local above_node = minetest.get_node(above_pos)
local above_def = minetest.registered_nodes[above_node.name]
return above_def and above_def.groups and above_def.groups.water
end

-- Helper function to check if node is correct base stone for flowstone
local function is_correct_base_stone(stone_pos, flowstone_base_name)
local stone_node = minetest.get_node(stone_pos)
-- Check exact match or block variant
return stone_node.name == "too_many_stones:" .. flowstone_base_name or
stone_node.name == "too_many_stones:" .. flowstone_base_name .. "_block"
end

-- Helper function to get next growth stage
local function get_next_stage(current_name, direction)
local base_name = get_base_stone_name(current_name)
local current_num = tonumber(current_name:match("_flowstone_(%d+)"))

if direction == "down" then -- stalactite growth
	if current_num == 1 then
		return "too_many_stones:" .. base_name .. "_flowstone_2"
		elseif current_num == 2 then
			-- F2 can repeat or transition to F3 - higher chance for tips
			if math.random() < 0.3 then -- 30% chance to start ending
				return "too_many_stones:" .. base_name .. "_flowstone_3"
				else
					return "too_many_stones:" .. base_name .. "_flowstone_2" -- repeat
					end
					elseif current_num == 3 then
						return "too_many_stones:" .. base_name .. "_flowstone_4"
						end
						elseif direction == "up" then -- stalagmite growth
							if current_num == 5 then
								return "too_many_stones:" .. base_name .. "_flowstone_6"
								elseif current_num == 6 then
									-- F6 can repeat or transition to F7 - higher chance for tips
									if math.random() < 0.3 then -- 30% chance to start ending
										return "too_many_stones:" .. base_name .. "_flowstone_7"
										else
											return "too_many_stones:" .. base_name .. "_flowstone_6" -- repeat
											end
											elseif current_num == 7 then
												return "too_many_stones:" .. base_name .. "_flowstone_8"
												end
												end
												return nil
												end

												-- Helper function to find if there's a matching formation within range
												local function find_matching_formation(pos, base_name, search_direction, max_distance)
												for i = 1, max_distance do
													local check_pos = {x = pos.x, y = pos.y + (search_direction * i), z = pos.z}
													local check_node = minetest.get_node(check_pos)

													if check_node.name:find("too_many_stones:" .. base_name .. "_flowstone_") then
														return true, i
														elseif check_node.name ~= "air" then
															return false, i
															end
															end
															return false, max_distance
															end

															-- Main growth function
															local function attempt_flowstone_growth(pos, node)
															local node_name = node.name
															local base_name = get_base_stone_name(node_name)
															if not base_name then
																minetest.log("action", "[TMS] No base name found for " .. node_name)
																return
																end

																local current_num = tonumber(node_name:match("_flowstone_(%d+)"))
																if not current_num then
																	minetest.log("action", "[TMS] No flowstone number found for " .. node_name)
																	return
																	end

																	minetest.log("action", "[TMS] Processing flowstone " .. current_num .. " at " .. minetest.pos_to_string(pos))

																	-- Determine if this is stalactite (1-4) or stalagmite (5-8)
																	if current_num >= 1 and current_num <= 4 then
																		-- Stalactite logic - grows downward
																		local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
																		local below_node = minetest.get_node(below_pos)

																		minetest.log("action", "[TMS] Stalactite " .. current_num .. ", below is " .. below_node.name)

																		-- Check growth conditions
																		if current_num == 1 then
																			-- F1 needs water above the source stone
																			local stone_above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
																			if not is_correct_base_stone(stone_above_pos, base_name) then
																				minetest.log("action", "[TMS] F1: No correct base stone above")
																				return
																				end
																				if not has_water_above(stone_above_pos) then
																					minetest.log("action", "[TMS] F1: No water above base stone")
																					return
																					end
																					end

																					-- Only grow if space below is air
																					if below_node.name == "air" then
																						local next_stage = get_next_stage(node_name, "down")
																						if next_stage then
																							-- Additional logic for tip placement
																							if current_num == 2 then
																								-- Check distance to ensure tips are added
																								local formation_length = 0
																								local check_pos = {x = pos.x, y = pos.y, z = pos.z}

																								-- Count upward to find formation length
																								while formation_length < 10 do
																									check_pos.y = check_pos.y + 1
																									local check_node = minetest.get_node(check_pos)
																									if check_node.name:find("too_many_stones:" .. base_name .. "_flowstone_[1-2]") then
																										formation_length = formation_length + 1
																											else
																												break
																												end
																												end

																												-- Force tip if formation is getting long or close to meeting stalagmite
																												if formation_length >= 3 or below_node.name:find("too_many_stones:" .. base_name .. "_flowstone_") then
																													next_stage = "too_many_stones:" .. base_name .. "_flowstone_3"
																													end
																													end

																													minetest.log("action", "[TMS] Growing stalactite: " .. node_name .. " -> " .. next_stage)
																													minetest.set_node(below_pos, {name = next_stage})
																													else
																														minetest.log("action", "[TMS] No next stage for stalactite " .. node_name)
																														end
																														elseif below_node.name:find("too_many_stones:" .. base_name .. "_flowstone_8") then
																															-- Meeting a stalagmite tip - stop growth
																															minetest.log("action", "[TMS] Stalactite meeting stalagmite tip, stopping growth")
																															return
																															end

																															elseif current_num >= 5 and current_num <= 8 then
																																-- Stalagmite logic - grows upward
																																local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
																																local above_node = minetest.get_node(above_pos)

																																minetest.log("action", "[TMS] Stalagmite " .. current_num .. ", above is " .. above_node.name)

																																-- Check growth conditions
																																if current_num == 5 then
																																	-- F5 needs correct base stone below
																																	local stone_below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
																																	if not is_correct_base_stone(stone_below_pos, base_name) then
																																		minetest.log("action", "[TMS] F5: No correct base stone below")
																																		return
																																		end

																																		-- Check for stalactite within 20 blocks above
																																		local found_stalactite, distance = find_matching_formation(pos, base_name, 1, 20)
																																		if not found_stalactite then
																																			minetest.log("action", "[TMS] F5: No stalactite found within 20 blocks")
																																			return
																																			end
																																			end

																																			-- Only grow if space above is air
																																			if above_node.name == "air" then
																																				local next_stage = get_next_stage(node_name, "up")
																																				if next_stage then
																																					-- Additional logic for tip placement
																																					if current_num == 6 then
																																						-- Check distance to ensure tips are added
																																						local formation_length = 0
																																						local check_pos = {x = pos.x, y = pos.y, z = pos.z}

																																						-- Count downward to find formation length
																																						while formation_length < 10 do
																																							check_pos.y = check_pos.y - 1
																																							local check_node = minetest.get_node(check_pos)
																																							if check_node.name:find("too_many_stones:" .. base_name .. "_flowstone_[5-6]") then
																																								formation_length = formation_length + 1
																																									else
																																										break
																																										end
																																										end

																																										-- Force tip if formation is getting long or close to meeting stalactite
																																										if formation_length >= 3 or above_node.name:find("too_many_stones:" .. base_name .. "_flowstone_") then
																																											next_stage = "too_many_stones:" .. base_name .. "_flowstone_7"
																																											end
																																											end

																																											minetest.log("action", "[TMS] Growing stalagmite: " .. node_name .. " -> " .. next_stage)
																																											minetest.set_node(above_pos, {name = next_stage})
																																											else
																																												minetest.log("action", "[TMS] No next stage for stalagmite " .. node_name)
																																												end
																																												elseif above_node.name:find("too_many_stones:" .. base_name .. "_flowstone_4") then
																																													-- Meeting a stalactite tip - stop growth
																																													minetest.log("action", "[TMS] Stalagmite meeting stalactite tip, stopping growth")
																																													return
																																													end
																																													end
																																													end

																																													-- ABM for flowstone growth
																																													minetest.register_abm({
																																														label = "TMS Flowstone Growth",
																																														nodenames = {"group:flowstone"},
																																														interval = growth_interval,
																																														chance = math.ceil(1.0 / growth_chance),
																																																		  action = function(pos, node)
																																																		  -- Debug: Log growth attempts
																																																		  minetest.log("action", "[TMS] Growth attempt at " .. minetest.pos_to_string(pos) .. " for " .. node.name)
																																																		  attempt_flowstone_growth(pos, node)
																																																		  end,
																																													})

																																													-- Function to auto-correct placed flowstone tips
																																													local function auto_correct_flowstone_placement(pos, placer, itemstack, pointed_thing)
																																													-- Delay the check to ensure node is properly placed
																																													minetest.after(0.1, function()
																																													local node = minetest.get_node(pos)
																																													local base_name = get_base_stone_name(node.name)
																																													if not base_name then return end

																																														-- Check what's above and below
																																														local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
																																														local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
																																														local above_node = minetest.get_node(above_pos)
																																														local below_node = minetest.get_node(below_pos)

																																														local correct_node = nil

																																														-- Determine correct orientation based on surroundings
																																														if is_correct_base_stone(below_pos, base_name) then
																																															-- Should be stalagmite starting from F5 (growing UP from floor)
																																													-- Check for stalactite within 20 blocks above
																																													local found_stalactite, distance = find_matching_formation(pos, base_name, 1, 20)
																																													if found_stalactite then
																																														correct_node = "too_many_stones:" .. base_name .. "_flowstone_5"
																																														end
																																														elseif below_node.name:find("too_many_stones:" .. base_name .. "_flowstone_[5-7]") then
																																															-- Extending existing stalagmite
																																															local below_num = tonumber(below_node.name:match("_flowstone_(%d+)"))
																																															if below_num == 5 or below_num == 6 then
																																																correct_node = "too_many_stones:" .. base_name .. "_flowstone_6"
																																																elseif below_num == 7 then
																																																	correct_node = "too_many_stones:" .. base_name .. "_flowstone_8"
																																																	end
																																																	elseif is_correct_base_stone(above_pos, base_name) and has_water_above(above_pos) then
																																																		-- Should be stalactite starting from F1 (growing DOWN from ceiling)
																																													correct_node = "too_many_stones:" .. base_name .. "_flowstone_1"
																																													elseif above_node.name:find("too_many_stones:" .. base_name .. "_flowstone_[1-3]") then
																																														-- Extending existing stalactite
																																														local above_num = tonumber(above_node.name:match("_flowstone_(%d+)"))
																																														if above_num == 1 or above_num == 2 then
																																															correct_node = "too_many_stones:" .. base_name .. "_flowstone_2"
																																															elseif above_num == 3 then
																																																correct_node = "too_many_stones:" .. base_name .. "_flowstone_4"
																																																end
																																																end

																																																-- Apply correction if needed
																																																if correct_node and correct_node ~= node.name then
																																																	minetest.set_node(pos, {name = correct_node})
																																																	end
																																																	end)
																																													end

																																													-- Function to register flowstone variants for a stone type
																																													function too_many_stones.register_flowstone(stone_name, description, groups)
																																													local base_groups = groups or {cracky = 3, attached_node = 1, stone = 1, flowstone = 1}

																																													-- Register 8 flowstone nodes (1-4 stalactites, 5-8 stalagmites)
																																													for i = 1, 8 do
																																														local node_name = "too_many_stones:" .. stone_name .. "_flowstone_" .. i
																																														local node_description

																																														if i <= 4 then
																																															node_description = S(description .. " Stalactite " .. i)
																																															else
																																																node_description = S(description .. " Stalagmite " .. (i-4))
																																																end

																																																local node_texture
																																																if i <= 4 then
																																																	node_texture = "tms_" .. stone_name .. "_flowstone_" .. i .. ".png"
																																																	else
																																																		-- Mirrored textures for stalagmites (5-8 are mirrors of 1-4)
																																																		local mirror_index = i - 4
																																																		node_texture = "tms_" .. stone_name .. "_flowstone_" .. mirror_index .. ".png^[transformFY"
																																																		end

																																																		local node_groups = table.copy(base_groups)

																																																		-- Set attachment rules based on flowstone type
																																																		if i >= 1 and i <= 4 then
																																																			-- Stalactites attach to ceiling
																																																			node_groups.attached_node = 1
																																																			node_groups.connect_to_raillike = nil -- Ensure ceiling attachment
																																																			else
																																																				-- Stalagmites attach to floor
																																																				node_groups.attached_node = 1
																																																				end

																																																				minetest.register_node(node_name, {
																																																					description = node_description,
																																																					drawtype = "plantlike",
																																																					tiles = {node_texture},
																																																					use_texture_alpha = "clip",
																																																					sunlight_propagates = true,
																																																					paramtype = "light",
																																																					paramtype2 = "wallmounted",
																																																					groups = node_groups,
																																																					drop = "too_many_stones:" .. stone_name .. "_flowstone_4", -- Always drop tip
																																																					sounds = too_many_stones.node_sound_stone_defaults(),
																																																									   is_ground_content = false,
																																																									   after_place_node = auto_correct_flowstone_placement,

																																																									   -- Custom attachment check for ceiling attachment
																																																									   on_construct = function(pos)
																																																									   local node = minetest.get_node(pos)
																																																									   local node_num = tonumber(node.name:match("_flowstone_(%d+)"))

																																																									   if node_num and node_num >= 1 and node_num <= 4 then
																																																										   -- Stalactites - check ceiling attachment
																																																										   local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
																																																										   local above_node = minetest.get_node(above_pos)
																																																										   if above_node.name == "air" then
																																																											   minetest.remove_node(pos)
																																																											   return false
																																																											   end
																																																											   end
																																																											   end,
																																																				})
																																																				end
																																																				end

																																																				-- Register flowstones for calcium carbonate stones
																																																				too_many_stones.register_flowstone(
																																																					"calcite",
																					   "Calcite",
																					   {cracky = 3, attached_node = 1, white_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"calcite_grey",
																					   "Grey Calcite",
																					   {cracky = 3, attached_node = 1, grey_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"calcite_orange",
																					   "Orange Calcite",
																					   {cracky = 3, attached_node = 1, orange_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"limestone_blue",
																					   "Blue Limestone",
																					   {limestone = 1, cracky = 3, attached_node = 1, grey_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"limestone_white",
																					   "White Limestone",
																					   {limestone = 1, cracky = 3, attached_node = 1, white_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"travertine",
																					   "Travertine",
																					   {limestone = 1, cracky = 3, attached_node = 1, yellow_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"travertine_yellow",
																					   "Yellow Travertine",
																					   {limestone = 1, cracky = 3, attached_node = 1, yellow_stone = 1, stone = 1, flowstone = 1}
																																																				)

																																																				too_many_stones.register_flowstone(
																																																					"geyserite",
																					   "Geyserite",
																					   {cracky = 3, attached_node = 1, yellow_stone = 1, stone = 1, granite = 1, flowstone = 1}
																																																				)
