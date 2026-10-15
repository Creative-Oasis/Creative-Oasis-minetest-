-- ok, after_use is called once ter dig_node, we don't need this
local WEAR_PER_BLOCK = math.floor(65535 / 1000 +0.5)


-- minetest.register_tool("sane_hammer:sane_hammer", {
-- 	description = "Sane Hammer",
-- 	short_description = "Sane Hammer",
-- 	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
-- 	inventory_image="sane_hammer.png",
-- 	range=8,
-- 	liquids_pointable = false,
-- 	light_source = 3,
-- 	tool_capabilities = {
-- 		full_punch_interval = 0.83333333,
-- 		max_drop_level = 4,
-- 		groupcaps = {
-- 			choppy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			cracky=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			crumbly =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			snappy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			oddly_breakable_by_hand = 	{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			axey=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			shovely=					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey_dig_iron =			{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2}
-- 		},
-- 		damage_groups = {fleshy=1},
--
-- 	},
--
-- })




minetest.register_tool("sane_hammer:sane_hammerDiamond", {
	description = "Hammer - Removes 3x3",
	short_description = "Sane Hammer Diamond",
	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
	inventory_image="HammerDiamond.png",
	range=8,
	liquids_pointable = false,
	light_source = 8,
	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 4,
		groupcaps = {
			choppy =					{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			cracky=						{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			crumbly =					{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			snappy =					{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			oddly_breakable_by_hand = 	{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			pickaxey =					{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			axey=						{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			shovely=					{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2},
			pickaxey_dig_iron =			{times = {[1] = 0.50, [2] = 1.00, [3] = 0.50},uses = 111, maxlevel = 2}
		},
		damage_groups = {fleshy=1},

	},

	after_use = function(itemstack, user, node, digparams)
		local wear = itemstack:get_wear()
		wear = wear + WEAR_PER_BLOCK
		if wear >= 65535 then
			--minetest.chat_send_player(user:get_player_name(), "Please fix your Builder Wand!")
			itemstack:set_wear(65535)
		else
			-- TODO replace "9" by the actual number of blocks digged... maybe
			itemstack:set_wear(wear)
		end
		return itemstack
	end,



})

-- minetest.register_tool("sane_hammer:sane_hammerMese", {
-- 	description = "Sane Hammer Mese",
-- 	short_description = "Sane Hammer Mese",
-- 	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
-- 	inventory_image="HammerMese.png",
-- 	range=8,
-- 	liquids_pointable = false,
-- 	light_source = 3,
-- 	tool_capabilities = {
-- 		full_punch_interval = 0.43333333,
-- 		max_drop_level = 4,
-- 		groupcaps = {
-- 			choppy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			cracky=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			crumbly =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			snappy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			oddly_breakable_by_hand = 	{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			axey=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			shovely=					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
-- 			pickaxey_dig_iron =			{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2}
-- 		},
-- 		damage_groups = {fleshy=1},
--
-- 	},
--
-- })

local ingredients
--[[if true then
		ingredients = {
				stick		 = "default:dirt",
				ironBlock = "default:dirt",
				ironIngot = "default:dirt",
				extraIngot = "default:dirt",
		}
else]]if minetest.get_modpath("mcl_core") then
		ingredients = {
				stick		 = "mcl_core:stick",
				ironBlock = "mcl_core:ironblock",
				ironIngot = "mcl_core:iron_ingot",
				extraIngot = "mcl_core:copper_ingot",
				repair = "mcl_core:stick",
				diamondBlock = "mcl_core:diamondblock"
		}
elseif minetest.get_modpath("default") then
		ingredients = {
				stick		 = "default:stick",
				ironBlock = "default:steelblock",
				ironIngot = "default:steel_ingot",
				extraIngot = "default:copper_ingot",
				repair = "default:stick",
				diamondBlock = "default:diamondblock"
		}
end

-- if ingredients then
-- 		minetest.register_craft({
-- 			output = "sane_hammer:sane_hammer",
-- 			recipe = {
-- 				{"", "", ""},
-- 				{"", ingredients.repair, "sane_hammer:sane_hammer"},
-- 				{"", "", ""},
-- 			},
-- 		})
--
-- 		minetest.register_craft({
-- 				output = "sane_hammer:sane_hammer",
-- 				recipe = {
-- 						{ingredients.extraIngot, ingredients.ironBlock, ingredients.ironIngot},
-- 						{"", ingredients.stick, ""},
-- 						{"", ingredients.stick, ""},
-- 				},
-- 		})
-- end

if ingredients then
		minetest.register_craft({
			output = "sane_hammer:sane_hammerDiamond",


			--groups = { axe = 1, tool = 1 },
			--diggroups = { axey = {} },


			recipe = {
				{"", "", ""},
				{"", ingredients.repair, "sane_hammer:sane_hammerDiamond"},
				{"", "", ""},
			},
		})

		minetest.register_craft({
				output = "sane_hammer:sane_hammerDiamond",
				recipe = {
						{ingredients.diamondBlock, ingredients.ironBlock, ingredients.ironIngot},
						{"", ingredients.stick, ""},
						{"", ingredients.stick, ""},
				},
		})



end

-- if ingredients then
-- 		minetest.register_craft({
-- 			output = "sane_hammer:sane_hammerMese",
-- 			recipe = {
-- 				{"", "", ""},
-- 				{"", ingredients.repair, "sane_hammer:sane_hammerMese"},
-- 				{"", "", ""},
-- 			},
-- 		})
--
-- 		minetest.register_craft({
-- 				output = "sane_hammer:sane_hammerMese",
-- 				recipe = {
-- 						{"default:mese", ingredients.ironBlock, ingredients.ironIngot},
-- 						{"", ingredients.stick, ""},
-- 						{"", ingredients.stick, ""},
-- 				},
-- 		})
--end

local valid_tools = {
	--["sane_hammer:sane_hammer"] = true,
	--["sane_hammer:sane_hammerObsidian"] = true,
	--["sane_hammer:sane_hammerMese"] = true,
	["sane_hammer:sane_hammerDiamond"] = true
}


-- function isValueInTable(value, table_of_values)
--     for _, v in ipairs(table_of_values) do
--         if v == value then
--             return true  -- Value found, return true
--         end
--     end
--     return false  -- Value not found, return false
-- end

local hammerOn = {}

local normal


--minetest.register_on_destruct(
--	function(pos)--, oldnode, digger)
minetest.register_on_punchnode( function(pos, node, digger, pointed_thing)
--local function my_punch(pos, node, digger, pointed_thing)

		if digger == nil then
			normal = nil
			return
		end

		local digger_name = digger:get_wielded_item():get_name()

		if digger == nil or not valid_tools[digger_name] then
			normal = nil
		else

			local playerName = digger:get_player_name()
			local player = minetest.get_player_by_name(playerName)

			local get_pointed_normal = dofile(minetest.get_modpath("sane_shared") .. "/get_pointed_normal.lua")

			normal = get_pointed_normal(player)
		end
	end
)


minetest.register_on_dignode( function(pos, oldnode, digger)
--local function my_dig(pos, oldnode, digger)

		if digger == nil or not valid_tools[digger:get_wielded_item():get_name()] then
			return
		end
		
		local playerName = digger:get_player_name()
		if(playerName == ""	or hammerOn[playerName]) then
			return
		end

		local player = minetest.get_player_by_name(playerName)


		local p_pos = player:get_pos()
		local eye_height = digger:get_properties().eye_height
		p_pos.y = p_pos.y + eye_height
		local dir = player:get_look_dir()

		local wielded_item = player:get_wielded_item()
		local tool_wear = wielded_item:get_wear()
		--minetest.chat_send_player(playerName, "Your tool wear: " .. tool_wear)
		if tool_wear >= 65535 then
			minetest.chat_send_player(playerName, "Your Hammer needs to be repaired")
			hammerOn[playerName] = nil
			return
		end



		hammerOn[playerName] = true

		if normal then
			if normal.x == -1 or normal.x == 1 then
				pos.z = pos.z - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.z = pos.z + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.y = pos.y - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.z = pos.z - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.z = pos.z - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.y = pos.y + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.z = pos.z + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.z = pos.z + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)

			elseif normal.z == -1 or normal.z == 1 then

				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.y = pos.y - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.y = pos.y + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)

			elseif normal.y == -1 or normal.y == 1 then

				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.z = pos.z - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x - 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)

				pos.z = pos.z + 2
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
				pos.x = pos.x + 1
				minetest.node_dig(pos, minetest.get_node(pos), digger)
			end
		end

		normal = nil

		hammerOn[playerName] = nil
	end
)

