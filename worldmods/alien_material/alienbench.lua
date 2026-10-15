--[[
License of source code of this file
----------------------

The MIT License (MIT)
Copyright (C) 2020-2021 Mooncarguy
Copyright (C) 2020-2024 debiankaios

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

For more details:
https://opensource.org/licenses/MIT

]]

local S = minetest.get_translator("alien_material")

alienbench = {}
alienbench.mixes = {}

function alienbench.register_mix(input_a, input_b, result)
	local mix_id = string.gsub(input_a, ":", "-")..string.gsub(input_b, ":", "-")
	alienbench.mixes[mix_id] = {name = result.name, count = result.count}
end

alienbench.register_mix("default:apple", "alien_material:alien_ingot", {name = "alien_material:alien_apple", count = 1})
if minetest.get_modpath("farming") then
	alienbench.register_mix("farming:bread", "alien_material:alien_ingot", {name = "alien_material:alien_bread", count = 8})
end


local function alienbench_make(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local input_a = inv:get_stack("input_a", 1)
	local input_b = inv:get_stack("input_b", 1)
	local mix_id = string.gsub(input_a:get_name(), ":", "-")..string.gsub(input_b:get_name(), ":", "-")
	local mix_id_b = string.gsub(input_b:get_name(), ":", "-")..string.gsub(input_a:get_name(), ":", "-")
	local output = inv:get_stack("output", 1)
	local mixnum = 0

	--Predefining number of mixes calculated by the input stack counts
	if input_a:get_count() < input_b:get_count() then
		mixnum = input_a:get_count()
	else
		mixnum = input_b:get_count()
	end

	--Checking which way around the dyes are placed and return if not a valid recipes
	if not alienbench.mixes[mix_id] then
		mix_id = mix_id_b
	end
	if not alienbench.mixes[mix_id] then
		return false
	end

	--Redefining according to max stack
	local stack_to_check = ItemStack(alienbench.mixes[mix_id].name)
	for i=mixnum, 0, -1 do
		if  alienbench.mixes[mix_id].count*mixnum > stack_to_check:get_stack_max() then
			mixnum = mixnum - 1
		end
	end

	--Redefining according to space in output area
	for i=mixnum, 0, -1 do
		if inv:room_for_item ("output", {name = alienbench.mixes[mix_id].name, count = alienbench.mixes[mix_id].count*mixnum}) ~= true then
			mixnum = mixnum - 1
		end
	end

	--Setting the new stacks
	local newstack_a = {name = input_a:get_name(), count = input_a:get_count() - mixnum}
	local newstack_b = {name = input_b:get_name(), count = input_b:get_count() - mixnum}
	local newstack_output = {name = alienbench.mixes[mix_id].name, count = alienbench.mixes[mix_id].count*mixnum +
	output:get_count()}
	if mixnum >= 1 and (input_a:get_count() - mixnum) >= 0 and (input_b:get_count() - mixnum) >= 0 then
		inv:set_stack("input_a", 1, newstack_a)
		inv:set_stack("input_b", 1, newstack_b)
		inv:set_stack("output", 1, newstack_output)
	end
end

minetest.register_node("alien_material:alienbench", {
	description = S("Alienbench"),
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"alienbench_y.png",
		"alienbench_y.png",
		"alienbench_side.png",
		"alienbench_side.png",
		"alienbench_side.png",
		"alienbench.png"
	},
	paramtype2 = "facedir",
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("infotext", S("Alienbench"))
		inv:set_size("input_a", 1)
		inv:set_size("input_b", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec", [[
			size[8,4.8]
			box[-0.01,0;1.84,0.9;#555555]
			image[3,0;1,1;alien_ingot_bg.png]
			image[0,0;0.9,0.9;alien_apple.png]
			label[0.6,0.25;Alien Bench]
			list[context;input_a;2,0;1,1;]
			list[context;input_b;3,0;1,1;]
			image[4,0;1,1;gui_furnace_arrow_bg.png^[transformR270]
			list[context;output;5,0;1,1;]
			button[6,0;2,1;alienbench_make;Make!]
			list[current_player;main;0,1.1;8,4;]
		]].. default.gui_bg .. default.gui_bg_img .. default.gui_slots .. default.get_hotbar_bg(0, 1.1))
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local stackname = stack:get_name()
		if (listname == "input_a" or listname == "input_b") then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" then
			return 0
		else
			return count
		end
	end,
--[[	on_metadata_inventory_put = function(pos)
	end,
	on_metadata_inventory_take = function(pos)
	end,
	on_metadata_inventory_move = function(pos)
	end,]]
	on_receive_fields = function(pos, formname, fields, sender)
		if fields["alienbench_make"] then
			alienbench_make(pos)
		end
	end,
	can_dig = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		if inv:is_empty("input_a") and inv:is_empty("input_b") and inv:is_empty("output") then
			return true
		else
			return false
		end
end})
