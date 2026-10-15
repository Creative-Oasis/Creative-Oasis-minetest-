
-- global

hopper = {version = "20260113"}

-- Translation and mod check

local S = core.get_translator("hopper")
local mod_screwdriver = core.get_modpath("screwdriver")

-- creative check

local creative_mode_cache = core.settings:get_bool("creative_mode")

local function check_creative(name)
	return creative_mode_cache or core.check_player_privs(name, {creative = true})
end

-- containers ( { where, node, inventory, run_callbacks })
-- run_callbacks is false to suppress logging during transfer. (be quiet like pipeworks)

local containers = {
	{"top", "hopper:hopper", "main", true},
	{"top", "hopper:hopper_side", "main", true},
	{"bottom", "hopper:hopper", "main", true},
	{"side", "hopper:hopper", "main", true},
	{"side", "hopper:hopper_side", "main", true},

	{"void", "hopper:hopper", "main", true},
	{"void", "hopper:hopper_side", "main", true},
	{"void", "hopper:hopper_void", "main", true},
}

-- default behavior for *_metadata_inventory_* callbacks
-- useful to prevent logging during transfer between nodes
-- cb_default: { true | false }
--  true: runs callbacks, except the nodes from the blacklist
--  false: only performs callbacks for the nodes in the whitelist
local cb_default = true
local cb_nodes = {}

if cb_default == false then

	-- a whitelist follows
	-- *_metadata_inventory_* or timer:start may be necessary to start processing
	cb_nodes = {
		-- callbacks without transfer logging
		"^bones:bones",      -- drop empty bones
		"^default:furnace",  -- start timer
		"^wine:wine_barrel", -- start timer
		--  crazy autocrafter:
		--   allow_metadata_inventory_* is needed to start processing,
		--   when 'main' was empty before.
		--   But don't call get_node_timer(pos):start(1) when disabled.
		"^pipeworks:autocrafter",
	--[[ notes
		-- no prozessing, no transfer logging
		"^pipeworks:deployer_",
		"^pipeworks:dispenser_",
		"^pipeworks:nodebreaker_",

		-- checks upgrade slots, no transfer logging
		"^technic:[lmh]v_",
		"^technic:coal_alloy_furnace", -- abm driven
		"^technic:constructor_mk",
		"^technic:injector",
		"^technic:tool_workshop",

		-- fixed: no transfer logging of fake players
		"^hopper:hopper",
	--]]
	}

elseif cb_default == true then

	-- a blacklist follows
	-- *_metadata_inventory_* or timer:start is not needed to start processing
	cb_nodes = {
		-- callbacks opens the formspec
		"^df_underworld_items:puzzle_seal",

		-- callbacks disabled to prevent logging during transfer between nodes
		"[:_]chest",
		"^castle_storage:",
		"^crafting_bench:workbench",
		"^darkage:box",
		"^darkage:wood_shelves",
		"^homedecor:",
	--[[ notes
		-- no prozessing, logs action in on_metadata_inventory_*
		"^digilines:chest",
		"^homedecor:nightstand_",
		"^homedecor:kitchen_cabinet_",
		"^homedecor:refrigerator_",
		"^homedecor:cardboard_box",
		"^homedecor:desk",
		"^homedecor:filing_cabine",
		"^homedecor:wardrobe",
		"^more_chests:",
		"^nanotech:carbon_chest",
		"^protector:chest",
		"^technic:.*_chest",

		-- abm driven, logs action in on_metadata_inventory_*
		"^homedecor:microwave_oven",
		"^homedecor:oven",
	--]]
	}
end

-- global function to add new containers

function hopper:add_container(list)

	for n = 1, #list do

		local cols = table.copy(list[n])

		cols[4] = cb_default

		for _, p in pairs(cb_nodes) do

			if string.find(cols[2], p) then

				cols[4] = not cb_nodes

				break
			end
		end

		table.insert(containers, cols)
	end
end

-- default containers

hopper:add_container({
	{"top", "default:chest", "main"},
	{"bottom", "default:chest", "main"},
	{"side", "default:chest", "main"},

	{"top", "default:furnace", "dst"},
	{"bottom", "default:furnace", "src"},
	{"side", "default:furnace", "fuel"},

	{"top", "default:furnace_active", "dst"},
	{"bottom", "default:furnace_active", "src"},
	{"side", "default:furnace_active", "fuel"},

	{"top", "default:chest_locked", "main"}, -- checks owner before taking items
	{"bottom", "default:chest_locked", "main"},
	{"side", "default:chest_locked", "main"},

	{"top", "default:chest_open", "main"}, --  new animated chests
	{"bottom", "default:chest_open", "main"},
	{"side", "default:chest_open", "main"},

	{"top", "default:chest_locked_open", "main"}, -- checks owner before taking items
	{"bottom", "default:chest_locked_open", "main"},
	{"side", "default:chest_locked_open", "main"},

	{"void", "default:chest", "main"},
	{"void", "default:chest_open", "main"},
	{"void", "default:furnace", "src"},
	{"void", "default:furnace_active", "src"}
})

-- protector redo mod support

if core.get_modpath("protector") then

	hopper:add_container({
		{"top", "protector:chest", "main"},
		{"bottom", "protector:chest", "main"},
		{"side", "protector:chest", "main"},
		{"void", "protector:chest", "main"}
	})
end

-- wine mod support

if core.get_modpath("wine") then

	hopper:add_container({
		{"top", "wine:wine_barrel", "dst"},
		{"bottom", "wine:wine_barrel", "src"},
		{"side", "wine:wine_barrel", "src"},
		{"void", "wine:wine_barrel", "src"}
	})
end

-- formspec

local function get_hopper_formspec(pos)

	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec = "size[8,9]"
		.. default.gui_bg
		.. default.gui_bg_img
		.. default.gui_slots
		.. "list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]"
		.. "list[current_player;main;0,4.85;8,1;]"
		.. "list[current_player;main;0,6.08;8,3;8]"
		.. "listring[nodemeta:" .. spos .. ";main]"
		.. "listring[current_player;main]"

	return formspec
end

-- only log actions of real players

local function log_action(player, pos, message)

	if player and not player.is_fake_player and player:is_player() then

		core.log("action", player:get_player_name() .. " "
			.. message .. " at " .. core.pos_to_string(pos))
	end
end

-- check where pointing and set normal or side-hopper

local hopper_place = function(itemstack, placer, pointed_thing)

	local pos = pointed_thing.above
	local x = pointed_thing.under.x - pos.x
	local z = pointed_thing.under.z - pos.z
	local name = placer:get_player_name() or ""

	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return itemstack
	end

	-- make sure we aren't replacing something we shouldnt
	local node = core.get_node_or_nil(pos)
	local def = node and core.registered_nodes[node.name]

	if def and not def.buildable_to then return itemstack end

	if pointed_thing.type == "node"
	and placer and not placer:get_player_control().sneak then

		local nn = core.get_node(pointed_thing.under).name

		if core.registered_nodes[nn]
		and core.registered_nodes[nn].on_rightclick then
			return core.item_place(itemstack, placer, pointed_thing)
		end
	end

	if x == -1 then
		core.set_node(pos, {name = "hopper:hopper_side", param2 = 0})

	elseif x == 1 then
		core.set_node(pos, {name = "hopper:hopper_side", param2 = 2})

	elseif z == -1 then
		core.set_node(pos, {name = "hopper:hopper_side", param2 = 3})

	elseif z == 1 then
		core.set_node(pos, {name = "hopper:hopper_side", param2 = 1})

	else
		core.set_node(pos, {name = "hopper:hopper"})
	end

	if not check_creative(placer:get_player_name()) then
		itemstack:take_item()
	end

	-- get and set metadata
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("main", 4*4)

	meta:set_string("owner", name)

	return itemstack
end

-- hopper node

core.register_node("hopper:hopper", {
	description = S("Hopper (Place onto sides for side-hopper)"),
	groups = {cracky = 3},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	tiles = {"hopper_top.png", "hopper_top.png", "hopper_front.png"},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.15, -0.3, -0.15, 0.15, -0.5, 0.15}
		}
	},

	on_place = hopper_place,

	can_dig = function(pos, player)

		local inv = core.get_meta(pos):get_inventory()

		return inv:is_empty("main")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not core.get_meta(pos)
		or core.is_protected(pos, clicker:get_player_name()) then
			return itemstack
		end

		core.show_formspec(clicker:get_player_name(),
				"hopper:hopper", get_hopper_formspec(pos))
	end,

	on_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		log_action(player, pos, "moves stuff in hopper")
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		log_action(player, pos,	"moves stuff to hopper")
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		log_action(player, pos, "moves stuff from hopper")
	end,

	on_rotate = mod_screwdriver and screwdriver.disallow,
	on_blast = function() end
})

-- side hopper node

core.register_node("hopper:hopper_side", {
	description = S("Side Hopper (Place into crafting to return normal Hopper)"),
	groups = {cracky = 3, not_in_creative_inventory = 1},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	paramtype2 = "facedir",
	tiles = {
		"hopper_top.png", "hopper_bottom.png", "hopper_back.png",
		"hopper_side.png", "hopper_back.png", "hopper_back.png"
	},
	drop = "hopper:hopper",
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.7, -0.3, -0.15, 0.15, 0.0, 0.15}
		}
	},

	on_place = hopper_place,

	can_dig = function(pos, player)

		local inv = core.get_meta(pos):get_inventory()

		return inv:is_empty("main")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not core.get_meta(pos)
		or core.is_protected(pos, clicker:get_player_name()) then
			return itemstack
		end

		core.show_formspec(clicker:get_player_name(),
				"hopper:hopper_side", get_hopper_formspec(pos))
	end,

	on_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		log_action(player, pos, "moves stuff in side hopper")
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		log_action(player, pos, "moves stuff to side hopper")
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		log_action(player, pos, "moves stuff from side hopper")
	end,

	on_rotate = mod_screwdriver and screwdriver.rotate_simple,
	on_blast = function() end
})

-- void hopper node

local player_void = {}

core.register_node("hopper:hopper_void", {
	description = S("Void Hopper (Use first to set destination container)"),
	groups = {cracky = 3},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	tiles = {
		"hopper_top.png", "hopper_bottom.png", "hopper_back.png",
		"hopper_back.png", "hopper_back.png", "hopper_back.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5}
		}
	},

	on_use = function(itemstack, player, pointed_thing)

		if pointed_thing.type ~= "node" then return end

		local pos = pointed_thing.under
		local name = player:get_player_name()
		local node = core.get_node(pos).name
		local ok, has_void

		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return itemstack
		end

		for _ = 1, #containers do

			if node == containers[_][2] then

				ok = true

				if containers[_][1] == "void" then
					has_void = true
				end
			end
		end

		if ok then

			if has_void then
				core.chat_send_player(name, S("Output container set")
					.. " " .. core.pos_to_string(pos))
				player_void[name] = pos
			else
				core.chat_send_player(name, S("Container without void hopper support!"))
				player_void[name] = nil
			end
		else
			core.chat_send_player(name, S("Not a registered container!"))
			player_void[name] = nil
		end
	end,

	on_place = function(itemstack, placer, pointed_thing)

		local pos = pointed_thing.above
		local name = placer:get_player_name() or ""

		if pointed_thing.type == "node"
		and placer and not placer:get_player_control().sneak then

			local nn = core.get_node(pointed_thing.under).name

			if core.registered_nodes[nn]
			and core.registered_nodes[nn].on_rightclick then
				return core.item_place(itemstack, placer, pointed_thing)
			end
		end

		if not player_void[name] then
			core.chat_send_player(name, S("No container position set!"))
			return itemstack
		end

		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return itemstack
		end

		-- make sure we aren't replacing something we shouldnt
		local node = core.get_node_or_nil(pos)
		local def = node and core.registered_nodes[node.name]
		if def and not def.buildable_to then
			return itemstack
		end

		if not check_creative(placer:get_player_name()) then
			itemstack:take_item()
		end

		core.set_node(pos, {name = "hopper:hopper_void", param2 = 0})

		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("main", 4*4)

		meta:set_string("owner", name)
		meta:set_string("void", core.pos_to_string(player_void[name]))
		meta:set_string("infotext", S("Void Hopper\nConnected to @1",
				core.pos_to_string(player_void[name])))

		return itemstack
	end,

	can_dig = function(pos, player)

		local inv = core.get_meta(pos):get_inventory()

		return inv:is_empty("main")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not core.get_meta(pos)
		or core.is_protected(pos, clicker:get_player_name()) then
			return itemstack
		end

		core.show_formspec(clicker:get_player_name(),
				"hopper:hopper", get_hopper_formspec(pos))
	end,

	on_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		log_action(player, pos, "moves stuff in void hopper")
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		log_action(player, pos, "moves stuff into void hopper")
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		log_action(player, pos, "moves stuff from void hopper")
	end,

	on_rotate = mod_screwdriver and screwdriver.disallow,
	on_blast = function() end
})

-- transfer function

local transfer = function(src, srcpos, dst, dstpos, allowed, finished)

	-- source inventory
	local inv = core.get_meta(srcpos):get_inventory()

	-- destination inventory
	local inv2 = core.get_meta(dstpos):get_inventory()

	-- check for empty source or no inventory
	if not inv or not inv2 or inv:is_empty(src) == true then return end

	local stack, item, max

	-- transfer item
	for i = 1, inv:get_size(src) do

		stack = inv:get_stack(src, i)
		item = stack:get_name()

		-- if slot not empty and room for item in destination
		if item ~= "" and inv2:room_for_item(dst, item) then

			local take = stack:take_item(1)

			if allowed(i, take) then

				inv2:add_item(dst, take)
				inv:set_stack(src, i, stack)

				finished(i, take)
			end

			return
		end
	end
end

-- lazy container setting and function

local lazy = core.settings:get_bool("lazy_container_support")

local function add_container_lazy(meta, where, node_name, inv_names)

	if not meta then return end

	local inv = meta:get_inventory()

	for _, inv_name in pairs(inv_names) do

		if inv:get_size(inv_name) > 0 then

			hopper:add_container({{where, node_name, inv_name}})

--print("hopper: add_container_lazy ["..#containers.."] "..where.." '"..node_name.."' "..inv_name .. " " .. (containers[#containers][4] and "true" or "false"))

			return
		end
	end
end

-- hopper workings

core.register_abm({

	label = "Hopper suction and transfer",
	nodenames = {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void"},
	interval = 1,
	chance = 1,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)

		local inv = core.get_meta(pos):get_inventory()

		for _,object in pairs(core.get_objects_inside_radius(pos, 1)) do

			if not object:is_player()
			and object:get_luaentity() and object:get_luaentity().name == "__builtin:item"
			and inv and inv:room_for_item("main",
					ItemStack(object:get_luaentity().itemstring)) then

				if object:get_pos().y - pos.y > 0.25 then

					inv:add_item("main", ItemStack(object:get_luaentity().itemstring))

					object:get_luaentity().itemstring = ""
					object:remove()
				end
			end
		end

		local dst_pos

		-- if side hopper check which way spout is facing
		if node.name == "hopper:hopper_side" then

			local face = node.param2

			if face == 0 then dst_pos = {x = pos.x - 1, y = pos.y, z = pos.z}

			elseif face == 1 then dst_pos = {x = pos.x, y = pos.y, z = pos.z + 1}

			elseif face == 2 then dst_pos = {x = pos.x + 1, y = pos.y, z = pos.z}

			elseif face == 3 then dst_pos = {x = pos.x, y = pos.y, z = pos.z - 1}
			else
				return
			end

		elseif node.name == "hopper:hopper_void" then

			local meta = core.get_meta(pos)

			if not meta then return end

			dst_pos = core.string_to_pos(meta:get_string("void"))

		elseif node.name == "hopper:hopper" then
			-- otherwise normal hopper, output downwards
			dst_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
		else
			return
		end

		-- get node above hopper
		local src_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local src_name = core.get_node(src_pos).name

		-- get node at other end of spout
		local dst_name = core.get_node(dst_pos).name

		-- hopper owner
		local hopper_owner = core.get_meta(pos):get_string("owner")

		-- the hopper itself interacts as fake player
		local player = {
			is_player = function() return false end,
			get_player_name = function() return hopper_owner end,
			is_fake_player = ":hopper",
			get_wielded_item = function() return ItemStack(nil) end
		}

		local hopper_owner_has_protection_bypass = false

		if core.check_player_privs(hopper_owner, "protection_bypass") then
			hopper_owner_has_protection_bypass = true
		end

		local to
		if node.name == "hopper:hopper" then to = "bottom"
		elseif node.name == "hopper:hopper_side" then to = "side"
		elseif node.name == "hopper:hopper_void" then to = "void" end

		local where, name, inv, run_cb, src_inv, dst_inv, src_cb, dst_cb

		-- do for loop here for api check
		for n = 1, #containers do

			where = containers[n][1]
			name = containers[n][2]
			inv = containers[n][3]
			run_cb = containers[n][4]

			if where == "top" and src_name == name then
				src_inv = inv -- from hopper into destionation container
				src_cb = run_cb
			elseif where == to and dst_name == name then
				dst_inv = inv
				dst_cb = run_cb
			end
		end

		-- get container owner
		local c_owner = core.get_meta(src_pos):get_string("owner") or ""

		-- if protection_bypass or actual owner or container not owned
		if hopper_owner_has_protection_bypass
		or hopper_owner == c_owner or c_owner == "" then

			if src_inv then

				-- run callbacks from source node or not
				local src_def = src_cb and core.registered_nodes[src_name]
				local allowed = function(i, stack)

					return not src_def
					or not src_def.allow_metadata_inventory_take
					or src_def.allow_metadata_inventory_take(src_pos, src_inv, i,
							stack, player) > 0
				end

				local finished = function(i, stack)

					return not src_def
					or not src_def.on_metadata_inventory_take
					or src_def.on_metadata_inventory_take(src_pos, src_inv, i, stack,
							player)
				end

				transfer(src_inv, src_pos, "main", pos, allowed, finished)

			elseif src_name ~= "ignore"
			and lazy and not string.find(src_name, "^hopper:") then

				local meta = core.get_meta(src_pos)

				add_container_lazy(meta, "top", src_name, {"main", "dst", "out"})
			end
		end

		c_owner = core.get_meta(dst_pos):get_string("owner") or ""

		if hopper_owner_has_protection_bypass
		or hopper_owner == c_owner or c_owner == "" then

			if dst_inv then

				-- run callbacks from destionation node or not
				local dst_def = dst_cb and core.registered_nodes[dst_name]
				local allowed = function(i, stack)

					return not dst_def
					or not dst_def.allow_metadata_inventory_put
					or dst_def.allow_metadata_inventory_put(dst_pos, dst_inv, i, stack,
							player) > 0
				end

				local finished = function(i, stack)

					return not dst_def
					or not dst_def.on_metadata_inventory_put
					or dst_def.on_metadata_inventory_put(dst_pos, dst_inv, i, stack,
							player)
				end

				transfer("main", pos, dst_inv, dst_pos, allowed, finished)

			elseif dst_name ~= "ignore" and lazy
			and not string.find(dst_name, "^hopper:") then

				local meta = core.get_meta(dst_pos)

				if to == "side" then
					add_container_lazy(meta, to, dst_name, {"fuel", "main", "src", "in"})
				else
					add_container_lazy(meta, to, dst_name, {"main", "src", "in"})
				end
			end
		end
	end
})

-- hopper recipe

core.register_craft({
	output = "hopper:hopper",
	recipe = {
		{"default:steel_ingot", "default:chest", "default:steel_ingot"},
		{"", "default:steel_ingot", ""}
	}
})

-- side hopper to hopper recipe

core.register_craft({
	output = "hopper:hopper",
	recipe = {{"hopper:hopper_side"}}
})

-- void hopper recipe

if core.get_modpath("teleport_potion") then

	core.register_craft({
		output = "hopper:hopper_void",
		recipe = {
			{"default:steel_ingot", "default:chest", "default:steel_ingot"},
			{"teleport_potion:potion", "default:steel_ingot", "teleport_potion:potion"}
		}
	})
else
	core.register_craft({
		output = "hopper:hopper_void",
		recipe = {
			{"default:steel_ingot", "default:chest", "default:steel_ingot"},
			{"default:diamondblock", "default:steel_ingot", "default:mese"}
		}
	})
end


-- add lucky blocks

if core.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"hopper:hopper"}, 3},
		{"nod", "default:lava_source", 1}
	})
end


print ("[MOD] Hopper loaded")
