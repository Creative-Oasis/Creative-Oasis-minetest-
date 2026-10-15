local table_set_all = futil.table.set_all

stairsplus.resources.craft_materials = {}

if stairsplus.has.default then
	table_set_all(stairsplus.resources.craft_materials, {
		steel_ingot = "default:steel_ingot",
	})
end
