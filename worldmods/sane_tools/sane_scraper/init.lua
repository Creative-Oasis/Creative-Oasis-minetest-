-- ok, after_use is called once ter dig_node, we don't need these
local WEAR_PER_BLOCK = math.floor(65535 / 1000 +0.5)
local scraped = 0

minetest.register_tool("sane_scraper:sane_scraper", {
	description = "Scraper - Removes one layer",
	short_description = "Sane Scraper",
	groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
	inventory_image="ScraperDiamond_straight.png",
	range=8,
	liquids_pointable = false,
	light_source = 8,
	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 4,
		groupcaps = {
			choppy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			cracky=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			crumbly =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			snappy =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			oddly_breakable_by_hand = 	{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			pickaxey =					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			axey=						{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			shovely=					{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
			pickaxey_dig_iron =			{times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2}
		},
		damage_groups = {fleshy=1},

	},

	after_use = function(itemstack, user, node, digparams)
		local player_name = user:get_player_name()
		-- later --- local stamina_value = unified_stamina.get(player_name)
		local wear = itemstack:get_wear()

		--minetest.chat_send_player(player_name, "Your tool wear, scraped: " .. scraped)

		wear = wear + scraped * WEAR_PER_BLOCK
		if wear >= 65535 then
			itemstack:set_wear(65535)
		else
			itemstack:set_wear(wear)
		end
		-- later --- unified_stamina.set(player_name, stamina_value)
		return itemstack
	end,

-- 	on_destruct = function(pos)
-- 		--print("on_destruct ", pos)
-- 	end,
-- 	after_dig_node = function(pos, oldnode, oldmetadata, digger)
-- 		--print("after_dig_node ", pos)
-- 	end,
--
--     -- Define the on_use function (left-click)
--     on_use = function(itemstack, user, pointed_thing)
--         -- This function handles left-clicks on the tool
--         minetest.chat_send_player(user:get_player_name(), "You left-clicked the tool!")
--         return itemstack
--     end,
--
--     -- Define the on_place function (right-click)
--     on_place = function(itemstack, user, pointed_thing)
--         -- This function handles right-clicks on the tool
--         minetest.chat_send_player(user:get_player_name(), "You right-clicked the tool!")
--         return itemstack
--     end

})


local ingredients
if minetest.get_modpath("mcl_core") then
	ingredients = {
		stick = "mcl_core:stick",
		diamondblock = "mcl_core:diamondblock",
		diamond = "mcl_core:diamond",
		repair = "mcl_core:stick"
	}
elseif minetest.get_modpath("default") then
	ingredients = {
		stick = "default:stick",
		diamondblock = "default:diamondblock",
		diamond = "default:diamond",
		repair = "default:stick"
	}
end


if ingredients then
		minetest.register_craft({
			output = "sane_scraper:sane_scraper",
			recipe = {
				{"", "", ""},
				{"", ingredients.repair, "sane_scraper:sane_scraper"},
				{"", "", ""},
			},
			--additional_wear = 0
		})

		minetest.register_craft({
			output = "sane_scraper:sane_scraper",
			recipe = {
					{ingredients.diamondblock, ingredients.diamond, ingredients.diamond},
					{"", ingredients.stick, ""},
					{"", ingredients.stick, ""},
			},
			--additional_wear = 0
		})

end

local valid_tools = {
	["sane_scraper:sane_scraper"] = true,
}



local normal = {0,1,0}

local get_pointed_normal = dofile(minetest.get_modpath("sane_shared") .. "/get_pointed_normal.lua")
local flood_fill = dofile(minetest.get_modpath("sane_shared") .. "/flood_fill.lua")

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
local undoStack = {nodeU,posU}

--minetest.register_on_destruct(
--	function(pos)--, oldnode, puncher)
minetest.register_on_punchnode( function(pos, node, puncher, pointed_thing)
--local function my_punch(pos, node, puncher, pointed_thing)

		if puncher == nil then
			normal = nil
			return
		end

		if puncher and puncher:is_player() then
			local player_name = puncher:get_player_name()
		else
			normal = nil
			return
		end

		local digger_name = puncher:get_wielded_item():get_name()

		if puncher == nil or not valid_tools[digger_name] then
			normal = nil
		else
			local playerName = puncher:get_player_name()
			local player = minetest.get_player_by_name(playerName)
			normal = get_pointed_normal(player)
		end
	end
)

local scraperOn = {}


minetest.register_on_dignode( function(pos, oldnode, digger)
--local function my_dig(pos, oldnode, digger)

		scraped = 0

		if digger == nil or not valid_tools[digger:get_wielded_item():get_name()] then
			return
		end
		
		local playerName = digger:get_player_name()
		if(playerName == ""	or scraperOn[playerName]) then
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

		scraperOn[playerName] = true

		if normal then
			--print("Normal sane_scraper = ", normal)

			result = {}

			if normal[2] ~= 0 then
				flood_fill(oldnode.name, pos, directions_xz, normal, result, 99)
			elseif normal[1] ~= 0 then
				flood_fill(oldnode.name, pos, directions_yz, normal, result, 99)
			elseif normal[3] ~= 0 then
				flood_fill(oldnode.name, pos, directions_yx, normal, result, 99)
			end

		local posr = {x, y, z}

		local wielded_item = player:get_wielded_item()
		local tool_wear = wielded_item:get_wear()
		--minetest.chat_send_player(playerName, "Your tool wear: " .. tool_wear)
		if tool_wear >= 65535 then
			minetest.chat_send_player(playerName, "Your Scraper needs to be repaired")
			scraperOn[playerName] = nil
			return
		end

		local avail_digs = math.floor((65535 - tool_wear) / WEAR_PER_BLOCK + 0.5)

		for _, res in pairs(result) do
			if avail_digs <= 0 then
				break
			end
			avail_digs = avail_digs - 1
			--print("pair ",_)
			--if ( used > max_avail ) then
			--	break
			--end
			posr.x = res[1]
			posr.y = res[2]
			posr.z = res[3]

			local nodepair = minetest.get_node(posr)

			deleteNode = minetest.get_node(posr)
			--print("deleteNode ",deleteNode.name)
			table.insert(undoStack, {nodeU=deleteNode,posU=posr})
			minetest.node_dig(posr, deleteNode, digger)
			minetest.set_node(posr, {name = "air"})
			--print("result ",posr)
		end


		end

		normal = nil

		scraped = #result

		scraperOn[playerName] = nil
	end
)

