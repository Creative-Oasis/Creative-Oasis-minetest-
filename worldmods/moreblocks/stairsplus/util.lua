local util = {}

local table_is_empty = futil.table.is_empty

function util.item_has_metadata(item)
	item = type(item) == "userdata" and item or ItemStack(item)
	local meta = item:get_meta()

	return not table_is_empty(meta:to_table().fields)
end

stairsplus.util = util
