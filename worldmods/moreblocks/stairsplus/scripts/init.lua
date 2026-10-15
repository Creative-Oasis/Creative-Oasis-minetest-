local f = string.format
local S = stairsplus.S

minetest.register_chatcommand("dump_stairsplus_registered_nodes", {
	description = S("create a list of stairsplus nodes, including aliases, to use as a filter in creating a whitelist"),
	privs = { server = true },
	func = function()
		local shaped_nodes = {}
		for shaped_node, shape in pairs(stairsplus.api.shape_by_shaped_node) do
			if shape ~= "node" then
				shaped_nodes[shaped_node] = true
			end
		end
		local aliases = {}
		for original in pairs(minetest.registered_aliases) do
			local resolved = futil.resolve_item(original)
			if resolved and shaped_nodes[resolved] then
				aliases[original] = resolved
			end
		end
		local filename = futil.path_concat(minetest.get_worldpath(), "stairsplus_dump.json")
		local contents = minetest.write_json({
			aliases = aliases,
			shaped_nodes = shaped_nodes,
		}, true)

		if not futil.write_file(filename, contents) then
			return false, f("error writing file @ %s", filename)
		end

		return true, f("dump created @ %s.", filename)
	end,
})
