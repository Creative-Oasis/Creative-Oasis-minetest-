tt = {}

tt.COLOR_DEFAULT = "#d0ffd0"
tt.COLOR_DANGER = "#ffff00"
tt.COLOR_GOOD = "#00ff00"

-- The field tt.registered_snippets is no longer used to evaluate snippets and
-- only provided for backwards compatibility to prevent mods reading or
-- manipulating this undocumented field from crashing, but those mods probably
-- won't work correctly and need to be updated.
tt.registered_snippets = {}

tt.registered_itemstack_snippets = {}

tt.register_snippet = function(func)
	table.insert(tt.registered_snippets, func)
	tt.register_itemstack_snippet(function(itemstack)
		return func(itemstack:get_name())
	end)
end

tt.register_itemstack_snippet = function(func)
	table.insert(tt.registered_itemstack_snippets, func)
end

-- Register default snippets
dofile(minetest.get_modpath(minetest.get_current_modname()).."/snippets.lua")

-- Helper to evaluate all snippets for a given itemstack and concatenate their results
local function apply_snippets(itemstack)
	local desc = {}
	local count = 0
	local snippet_count = #tt.registered_itemstack_snippets
	for s=1, snippet_count do
		local str, snippet_color = tt.registered_itemstack_snippets[s](itemstack)
		if str then
			count = count + 1
			if snippet_color == nil then
				snippet_color = tt.COLOR_DEFAULT
			end
			desc[count] = snippet_color and minetest.colorize(snippet_color, str) or str
		end
	end
	return table.concat(desc, "\n"), count
end

tt.update_item_description = function(itemstring)
	local def = minetest.registered_items[itemstring]
	local orig_desc = def and (def._tt_original_description or def.description)
	if itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and orig_desc ~= nil and orig_desc ~= "" and def._tt_ignore ~= true then
		local desc, count = apply_snippets(ItemStack(itemstring))
		if count > 0 then
			minetest.override_item(itemstring, {
				description = orig_desc.."\n"..desc,
				_tt_original_description = orig_desc
			})
		end
	end
end

function tt.update_itemstack_description(itemstack)
	if not itemstack then return end
	local itemstring = itemstack:get_name()
	local def = minetest.registered_items[itemstring]

	-- description; since this is explicitly called, it shouldn't be
	-- strictly necessary, but it may be useful to just run this function
	-- for e.g. every itemstack in an inventory

	local desc, count = apply_snippets(itemstack)

	if count == 0 then
		-- stack's description should be the item's original
		-- description, but the default item description may have been
		-- overridden, check whether _tt_original_description is set
		if def._tt_original_description then
			-- description has been overridden and we need to
			-- explicitly set the stack's description to the
			-- original description
			desc = def._tt_original_description
		else
			-- def.description *is* the original description, just
			-- remove any description override from metadata
			desc = ""
		end
	elseif def._tt_original_description then
		desc = def._tt_original_description.."\n"..desc
		-- check whether new description is actually different from default description
		if desc == def.description then
			desc = ""
		end
	else
		-- new description is definitely different from default description
		desc = def.description.."\n"..desc
	end

	local meta = itemstack:get_meta()
	meta:set_string("description", desc) -- no need to check whether it actually changed

	return itemstack
end

-- Apply item description updates to all registered items after mods are loaded
local function append_snippets()
	for itemstring, def in pairs(minetest.registered_items) do
		tt.update_item_description(itemstring)
	end
end

minetest.register_on_mods_loaded(append_snippets)
