local S = core.get_translator("unified_inventory")
local NS = function(s) return s end
local F = core.formspec_escape
local ui = unified_inventory

core.register_privilege("creative", {
	description = S("Can use the creative inventory"),
	give_to_singleplayer = false,
})

core.register_privilege("ui_full", {
	description = S("Forces Unified Inventory to be displayed in Full mode if Lite mode is configured globally"),
	give_to_singleplayer = false,
})

local trash = core.create_detached_inventory("trash", {
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, nil)
		local player_name = player:get_player_name()
		core.sound_play("trash", {
			to_player = player_name,
			gain = 1.0,
		})
	end,
})

trash:set_size("main", 1)

ui.register_button("craft", {
	type = "image",
	image = "ui_craft_icon.png",
	tooltip = S("Crafting Grid"),
})

ui.register_button("craftguide", {
	type = "image",
	image = "ui_craftguide_icon.png",
	tooltip = S("Crafting Guide"),
})

local pending_home_confirmation = {}
local HOME_CONFIRM_FORM = "unified_inventory:confirm_home_position"

local function round_home_coordinate(n)
	return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
end

local function round_home_position(pos)
	return {
		x = round_home_coordinate(pos.x),
		y = round_home_coordinate(pos.y),
		z = round_home_coordinate(pos.z),
	}
end

local function format_home_position(pos)
	pos = round_home_position(pos)
	return string.format("(%d, %d, %d)", pos.x, pos.y, pos.z)
end

ui.register_button("home_gui_set", {
	type = "image",
	image = "ui_sethome_icon.png",
	tooltip = S("Set home position"),
	hide_lite = true,

	action = function(player)
		local player_name = player:get_player_name()
		local pos = round_home_position(player:get_pos())

		pending_home_confirmation[player_name] = pos

		local formspec = table.concat({
			"formspec_version[4]",
			"size[8,3.5]",
			"hypertext[0.2,0.35;7.6,0.7;home_confirm_title;<center>",
			F(S("Are you sure you want to set your home here?")),
			"</center>]",
			"hypertext[0.2,1.05;7.6,0.7;home_confirm_position;<center>",
			F(S("Position: @1", format_home_position(pos))),
			"</center>]",
			"button[1.5,2.1;2.2,0.8;confirm_home;",
			F(S("Confirm")), "]",
			"button[4.3,2.1;2.2,0.8;cancel_home;",
			F(S("Cancel")), "]",
		})

		core.after(0, function()
			if core.get_player_by_name(player_name) then
				core.show_formspec(
					player_name,
					HOME_CONFIRM_FORM,
					formspec
				)
			end
		end)
	end,

	condition = function(player)
		return core.check_player_privs(
			player:get_player_name(),
			{home = true}
		)
	end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= HOME_CONFIRM_FORM then
		return
	end

	local player_name = player:get_player_name()
	local pos = pending_home_confirmation[player_name]

	if fields.confirm_home and pos then
		ui.set_home(player, round_home_position(pos))

		local home = ui.home_pos[player_name]
		if home ~= nil then
			core.sound_play("dingdong", {
				to_player = player_name,
				gain = 1.0,
			})

			core.chat_send_player(
				player_name,
				S("Home position set to: @1", format_home_position(home))
			)
		end
	end

	pending_home_confirmation[player_name] = nil

	core.after(0, function()
		if core.get_player_by_name(player_name) then
			core.close_formspec(player_name, HOME_CONFIRM_FORM)
		end
	end)

	return true
end)

core.register_on_leaveplayer(function(player)
	pending_home_confirmation[player:get_player_name()] = nil
end)

ui.register_button("home_gui_go", {
	type = "image",
	image = "ui_gohome_icon.png",
	tooltip = S("Go home"),
	hide_lite = true,

	action = function(player)
		local player_name = player:get_player_name()

		if ui.go_home(player) then
			core.sound_play("teleport", {
				to_player = player_name,
			})
		end
	end,

	condition = function(player)
		return core.check_player_privs(
			player:get_player_name(),
			{home = true}
		)
	end,
})

ui.register_page("craft", {
	get_formspec = function(player, perplayer_formspec)
		local formheaderx = perplayer_formspec.form_header_x
		local formheadery = perplayer_formspec.form_header_y
		local craftx = perplayer_formspec.craft_x
		local crafty = perplayer_formspec.craft_y

		local player_name = player:get_player_name()

		local formspec = {
			perplayer_formspec.standard_inv_bg,
			perplayer_formspec.craft_grid,
			"label[" .. formheaderx .. "," .. formheadery .. ";" ..
				F(S("Crafting")) .. "]",
			"listring[current_name;craft]",
			"listring[current_player;main]",
		}

		local n = #formspec + 1

		-- Keep the Trash slot.
		if ui.trash_enabled
				or ui.is_creative(player_name)
				or core.get_player_privs(player_name).give then
			formspec[n] = string.format(
				"label[%f,%f;%s]",
				craftx + 6.35,
				crafty + 2.3,
				F(S("Trash:"))
			)

			formspec[n + 1] = ui.make_trash_slot(
				craftx + 6.25,
				crafty + 2.5
			)

			n = n + 2
		end

		-- Keep the Refill slot for creative players.
		if ui.is_creative(player_name) then
			formspec[n] = ui.single_slot(
				craftx - 2.5,
				crafty + 2.5
			)

			formspec[n + 1] = string.format(
				"label[%f,%f;%s]",
				craftx - 2.4,
				crafty + 2.3,
				F(S("Refill:"))
			)

			formspec[n + 2] = string.format(
				"list[detached:%srefill;main;%f,%f;1,1;]",
				F(player_name),
				craftx - 2.5 + ui.list_img_offset,
				crafty + 2.5 + ui.list_img_offset
			)
		end

		return {
			formspec = table.concat(formspec),
		}
	end,
})

-- Generate a formspec button displaying an item stack.
local function stack_image_button(
	x, y, w, h, buttonname_prefix, item, replacement
)
	local ok, normalized = pcall(ItemStack, item or "")

	if not ok or not normalized
			or type(normalized.get_name) ~= "function" then
		normalized = ItemStack("")
	end

	item = normalized

	local name = item:get_name()
	local show_is_group = false
	local displayitem = item:to_string()
	local selectitem = name

	if name:sub(1, 6) == "group:" then
		local group_item = ui.get_group_item(name:sub(7))

		show_is_group = not group_item.sole
		displayitem = group_item.item or name

		if item:get_count() > 1 then
			displayitem = displayitem .. " " .. item:get_count()
		end

		selectitem = group_item.sole and displayitem or name
	end

	local label = show_is_group and "G" or ""
	local unique_id = string.format("%i%i_", x * 10, y * 10)

	local buttonname = F(
		unique_id .. buttonname_prefix .. ui.mangle_for_formspec(selectitem)
	)

	local fs = {}

	fs[1] = string.format(
		"item_image_button[%f,%f;%f,%f;%s;%s;%s]",
		x, y, w, h,
		F(displayitem),
		buttonname,
		label
	)

	local tooltip = item:get_meta():get_string("description")

	if show_is_group then
		local groupstring, count = ui.extract_groupnames(name)

		if count == 1 then
			tooltip = S("Any item belonging to the @1 group", groupstring)
		elseif count > 1 then
			tooltip = S("Any item belonging to the groups @1", groupstring)
		else
			tooltip = ""
		end
	end

	if replacement then
		fs[#fs + 1] = string.format(
			"label[%f,%f;R]",
			x + w - 0.3,
			y + 0.25
		)

		tooltip = (tooltip == "" and item:get_description() or tooltip)
			.. "\n\n"
			.. S(
				"Replaced by: @1",
				("%s [%s]"):format(
					replacement:get_description(),
					replacement:get_name()
				)
			)
	end

	if tooltip ~= "" then
		fs[#fs + 1] = string.format(
			"tooltip[%s;%s]",
			buttonname,
			F(tooltip)
		)
	end

	return table.concat(fs)
end

local recipe_text = {
	recipe = NS("Recipe @1 of @2"),
	usage = NS("Usage @1 of @2"),
}

local no_recipe_text = {
	recipe = S("No recipes"),
	usage = S("No usages"),
}

local role_text = {
	recipe = S("Result"),
	usage = S("Ingredient"),
}

local next_alt_text = {
	recipe = S("Show next recipe"),
	usage = S("Show next usage"),
}

local prev_alt_text = {
	recipe = S("Show previous recipe"),
	usage = S("Show previous usage"),
}

ui.register_page("craftguide", {
	get_formspec = function(player, perplayer_formspec)
		local craftguidex = perplayer_formspec.craft_guide_x
		local craftguidey = perplayer_formspec.craft_guide_y
		local craftguidearrowx = perplayer_formspec.craft_guide_arrow_x
		local craftguideresultx = perplayer_formspec.craft_guide_result_x
		local formheaderx = perplayer_formspec.form_header_x
		local formheadery = perplayer_formspec.form_header_y
		local give_x = perplayer_formspec.give_btn_x

		local player_name = player:get_player_name()
		local player_privs = core.get_player_privs(player_name)

		local formspec = {
			perplayer_formspec.standard_inv_bg,
			"label[" .. formheaderx .. "," .. formheadery .. ";" ..
				F(S("Crafting Guide")) .. "]",
		}

		-- current_item must remain an item-name string.
		local item_name = ui.current_item[player_name]

		-- Safely accept a legacy ItemStack value if another mod left one.
		if item_name ~= nil and type(item_name) ~= "string" then
			local ok, stack = pcall(ItemStack, item_name)
			if ok and stack then
				item_name = stack:get_name()
				ui.current_item[player_name] = item_name
			else
				item_name = nil
			end
		end

		if not item_name or item_name == "" then
			return {
				formspec = table.concat(formspec),
			}
		end

		local item_def = core.registered_items[item_name]
		local item_name_shown

		if item_def and item_def.description then
			item_name_shown = S("@1 (@2)", item_def.description, item_name)
		else
			item_name_shown = item_name
		end

		local dir = ui.current_craft_direction[player_name]
		local direction_crafts = ui.crafts_for[dir] or {}
		local crafts = direction_crafts[item_name]
		local alternate = ui.alternate[player_name] or 1
		local alternates, craft

		if crafts and #crafts > 0 then
			alternates = #crafts
			craft = crafts[alternate]
		end

		local has_give = player_privs.give or ui.is_creative(player_name)
		local n = #formspec + 1

		formspec[n] = string.format(
			"image[%f,%f;%f,%f;ui_crafting_arrow.png]",
			craftguidearrowx,
			craftguidey,
			ui.imgscale,
			ui.imgscale
		)

		formspec[n + 1] = string.format(
			"textarea[%f,%f;10,1;;%s: %s;]",
			perplayer_formspec.craft_guide_resultstr_x,
			perplayer_formspec.craft_guide_resultstr_y,
			F(role_text[dir] or ""),
			F(item_name_shown)
		)

		n = n + 2

		local giveme_form =
			"label[" .. (give_x + 0.1) .. "," ..
				(craftguidey + 2.7) .. ";" ..
				F(S("Give me:")) .. "]" ..
			"button[" .. give_x .. "," ..
				(craftguidey + 2.9) ..
				";0.75,0.5;craftguide_giveme_1;1]"

		if item_def and item_def.type ~= "tool" then
			giveme_form = giveme_form ..
				"button[" .. (give_x + 0.8) .. "," ..
					(craftguidey + 2.9) ..
					";0.75,0.5;craftguide_giveme_10;10]" ..
				"button[" .. (give_x + 1.6) .. "," ..
					(craftguidey + 2.9) ..
					";0.75,0.5;craftguide_giveme_99;99]"
		end

		if not craft then
			formspec[n] = string.format(
				"label[%f,%f;%s]",
				craftguidex + 2.5,
				craftguidey + 1.5,
				F(no_recipe_text[dir] or "")
			)

			local no_pos = dir == "recipe"
				and (craftguidex + 2.5)
				or craftguideresultx

			local item_pos = dir == "recipe"
				and craftguideresultx
				or (craftguidex + 2.5)

			formspec[n + 1] =
				"image[" .. no_pos .. "," .. craftguidey ..
				";1.2,1.2;ui_no.png]"

			formspec[n + 2] = stack_image_button(
				item_pos,
				craftguidey,
				1.2,
				1.2,
				"item_button_",
				ItemStack(item_name)
			)

			if has_give then
				formspec[n + 3] = giveme_form
			end

			return {
				formspec = table.concat(formspec),
			}
		end

		-- Normalize craft outputs from different API variants.
		local craft_outputs = craft.output

		if type(craft_outputs) == "string" then
			craft_outputs = {craft_outputs}
		elseif type(craft_outputs) ~= "table" then
			craft_outputs = {}
		end

		for i = #craft_outputs, 1, -1 do
			local itemstack = ItemStack(craft_outputs[i] or "")

			formspec[n] = stack_image_button(
				craftguideresultx + (i - 1) * 0.8,
				craftguidey,
				1.2,
				1.2,
				"item_button_",
				itemstack
			)

			n = n + 1

			if itemstack:get_name() == item_name then
				-- Preserve the expected string type.
				ui.current_item[player_name] = item_name
			end
		end

		local craft_type = ui.registered_craft_types[craft.type]
			or ui.craft_type_defaults(craft.type, {})

		local label = F(craft_type.description)

		formspec[n] = string.format(
			"image_button[%f,%f;%f,%f;%s;%s;]",
			craftguidearrowx + 0.35,
			craftguidey,
			0.5,
			0.5,
			craft_type.icon,
			"crafttype_" .. craft.type
		)

		formspec[n + 1] = string.format(
			"tooltip[%s;%s]",
			"crafttype_" .. craft.type,
			F(S("Show recipes of the same craft type"))
		)

		n = n + 2

		if craft.type == "cooking" or craft.type == "fuel" then
			local res = core.get_craft_result({
				method = craft.type,
				width = 1,
				items = {
					ItemStack(craft.items[1]),
				},
			})

			if res.time then
				label = label .. " " .. S("(@1 seconds)", res.time)
			end
		end

		formspec[n] = string.format(
			"textarea[%f,%f;%f,%f;;;%s]",
			craftguidearrowx + 0.15,
			craftguidey + 1.4,
			10.3 - (craftguidearrowx + 0.15),
			0.75,
			label
		)

		n = n + 1

		local display_size = craft_type.dynamic_display_size
			and craft_type.dynamic_display_size(craft)
			or {
				width = craft_type.width,
				height = craft_type.height,
			}

		local craft_width = craft_type.get_shaped_craft_width
			and craft_type.get_shaped_craft_width(craft)
			or display_size.width

		local xoffset = craftguidex + 3.75
		local bspc = 1.25
		local of = 3 / math.max(
			3,
			math.max(display_size.width, display_size.height)
		)

		local od = 0
		local mini_craft_size = 6

		if display_size.width >= mini_craft_size then
			od = math.max(1, display_size.width - 2)
			xoffset = xoffset - 0.1
		end

		local sf = math.min(1, of * (1.05 + 0.05 * od))
		local bsize = 1.2 * sf

		if display_size.width >= mini_craft_size then
			bsize = 0.8 * sf
		end

		if bsize > 0.35 and display_size.width then
			local craft_items = {}

			for i, item in pairs(craft.items or {}) do
				craft_items[i] = ItemStack(item)
			end

			local replacements = {}

			for _, r in ipairs(craft.replacements or {}) do
				local candidates = ui.get_matching_items(r[1])

				for _, stack in ipairs(craft_items) do
					if not replacements[stack]
							and candidates[stack:get_name()] then
						replacements[stack] = ItemStack(r[2])
						break
					end
				end
			end

			for y = 1, display_size.height do
				for x = 1, display_size.width do
					local stack

					if x <= craft_width then
						stack = craft_items[
							(y - 1) * craft_width + x
						]
					end

					local fx = display_size.width - (x - 1)
					local xof = ((fx - 1) * of + of) * bspc
					local yof = ((y - 1) * of + 1) * bspc

					if stack then
						formspec[n] = stack_image_button(
							xoffset - xof,
							craftguidey - 1.25 + yof,
							bsize,
							bsize,
							"item_button_",
							stack,
							replacements[stack]
						)
					else
						formspec[n] = string.format(
							"image_button[%f,%f;%f,%f;ui_blank_image.png;;]",
							xoffset - xof,
							craftguidey - 1.25 + yof,
							bsize,
							bsize
						)
					end

					n = n + 1
				end
			end
		else
			formspec[n] = string.format(
				"label[2,%f;%s]",
				craftguidey,
				F(S("This recipe is too@nlarge to be displayed."))
			)

			n = n + 1
		end

		if craft_type.uses_crafting_grid and display_size.width <= 3 then
			formspec[n] =
				"label[" .. (give_x + 0.1) .. "," ..
				(craftguidey + 1.7) .. ";" ..
				F(S("To craft grid:")) .. "]"

			formspec[n + 1] =
				"button[" .. give_x .. "," ..
				(craftguidey + 1.9) ..
				";0.75,0.5;craftguide_craft_1;1]"

			formspec[n + 2] =
				"button[" .. (give_x + 0.8) .. "," ..
				(craftguidey + 1.9) ..
				";0.75,0.5;craftguide_craft_10;10]"

			formspec[n + 3] =
				"button[" .. (give_x + 1.6) .. "," ..
				(craftguidey + 1.9) ..
				";0.75,0.5;craftguide_craft_max;" ..
				F(S("All")) .. "]"

			n = n + 4
		end

		if has_give then
			formspec[n] = giveme_form
			n = n + 1
		end

		if alternates and alternates > 1 then
			formspec[n] = string.format(
				"label[%f,%f;%s]",
				craftguidex + 4,
				craftguidey + 2.3,
				F(S(recipe_text[dir], alternate, alternates))
			)

			formspec[n + 1] = string.format(
				"image_button[%f,%f;1.1,1.1;ui_left_icon.png;alternate_prev;]",
				craftguidearrowx + 0.2,
				craftguidey + 2.6
			)

			formspec[n + 2] = string.format(
				"image_button[%f,%f;1.1,1.1;ui_right_icon.png;alternate;]",
				craftguidearrowx + 1.35,
				craftguidey + 2.6
			)

			formspec[n + 3] =
				"tooltip[alternate_prev;" .. F(prev_alt_text[dir]) .. "]"

			formspec[n + 4] =
				"tooltip[alternate;" .. F(next_alt_text[dir]) .. "]"
		end

		return {
			formspec = table.concat(formspec),
		}
	end,
})

local function craftguide_giveme(player, field_name)
	local player_name = player:get_player_name()
	local player_privs = core.get_player_privs(player_name)

	if not player_privs.give and not ui.is_creative(player_name) then
		core.log(
			"action",
			"[unified_inventory] Denied give action to player " ..
			player_name
		)
		return
	end

	local amount = field_name:match("craftguide_giveme_(.*)")
	amount = tonumber(amount) or 0

	if amount == 0 then
		return
	end

	local selected_item = ui.current_item[player_name]

	if type(selected_item) ~= "string" or selected_item == "" then
		return
	end

	local to_give = ItemStack(selected_item)
	to_give:set_count(amount)

	player:get_inventory():add_item("main", to_give)
end

local function craftguide_craft(player, formname, fields)
	local amount

	for k in pairs(fields) do
		amount = k:match("craftguide_craft_(.*)")
		if amount then
			break
		end
	end

	if not amount then
		return
	end

	amount = tonumber(amount) or -1

	if amount == 0 or amount < -1 or amount > 99 then
		return
	end

	local player_name = player:get_player_name()
	local selected_item = ui.current_item[player_name]

	if type(selected_item) ~= "string" or selected_item == "" then
		return
	end

	local direction = ui.current_craft_direction[player_name]
	local direction_crafts = ui.crafts_for[direction]

	if not direction_crafts then
		return
	end

	local crafts = direction_crafts[selected_item] or {}

	if #crafts == 0 then
		return
	end

	local alternate = ui.alternate[player_name] or 1
	local craft = crafts[alternate]

	if not craft then
		return
	end

	if not craft.width then
		if not craft.output then
			core.log("warning", "[unified_inventory] Craft has no output.")
		else
			core.log(
				"warning",
				("[unified_inventory] Craft for '%s' has no width.")
					:format(craft.output)
			)
		end

		return
	end

	if craft.width > 3 then
		return
	end

	ui.craftguide_match_craft(
		player,
		"main",
		"craft",
		craft,
		amount
	)

	ui.set_inventory_formspec(player, "craft")
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end

	for k in pairs(fields) do
		if k:match("craftguide_craft_") then
			craftguide_craft(player, formname, fields)
			return
		end

		if k:match("craftguide_giveme_") then
			craftguide_giveme(player, k)
			return
		end
	end
end)

minetest.register_on_mods_loaded(function()
	minetest.log("warning", "[inventory_ores] Checking registered ore entries:")

	for name, def in pairs(minetest.registered_items) do
		if not def.inventory_image or def.inventory_image == "" then
			if name:find("ore", 1, true) then
				minetest.log(
					"warning",
					"[inventory_ores] Missing inventory_image: " .. name
				)
			end
		end
	end
end)
-- This Unified Inventory API version does not provide
-- register_crafting_tool().