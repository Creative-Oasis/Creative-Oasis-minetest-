--Init
local new_node = {info = {}}
compression = {}

--Main
compression.darken_tiles = function(tiles, count)
	if count > 0 then
		for key, tile in pairs(tiles) do
			if type(tile) == "table" then
				tile = compression.darken_tiles(tile, count)
			elseif type(tile) == "string" then
				tile = tile .. "^compression_darken.png"
			end
			tiles[key] = tile
		end
		return tiles
	end
end
local register_compressed = function(new_node)
	core.register_node(new_node.info.name, table.copy(new_node.def))
	core.register_craft({
		type = "shapeless", 
		recipe = {new_node.info.name}, 
		output = new_node.info.subordinate .. " 9", 
	})
	core.register_craft({
		type = "shapeless", 
		recipe = {
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
			new_node.info.subordinate, 
		}, 
		output = new_node.info.name, 
	})
end

compression.register_compressed_tiers = function(node, maxlvl)
	new_node.info.name = nil
	new_node.def = table.copy(core.registered_nodes[node])
	new_node.info.initial_compression = new_node.def.groups.compressed or 0
	new_node.info.original_description = new_node.def.description
	for level = new_node.info.initial_compression + 1, maxlvl, 1 do
		new_node.info.subordinate = new_node.info.name or node
		new_node.info.name = "compression:" .. (node:gsub(":", "_"))
		if new_node.info.initial_compression == 0 then
			new_node.info.name = new_node.info.name .. "_compressed_level_" .. level
		else
			new_node.info.name = new_node.info.name .. "_level_" .. level
		end
		new_node.def.groups.compressed = level
		new_node.def.description = new_node.info.original_description .. " (Level " .. level .. ") (x" .. (9^level) .. ")"
		if new_node.info.initial_compression == 0 then new_node.def.description = "Compressed " .. new_node.def.description end
		new_node.def.tiles = compression.darken_tiles(new_node.def.tiles, level-new_node.info.initial_compression)
		new_node.def.drop = new_node.info.name
		register_compressed(new_node)
	end
end

compression.register_compressed_nodes = function(nodes, maxlvl)
	for _, node in ipairs(nodes) do
		if core.registered_nodes[node] then
			compression.register_compressed_tiers(node, maxlvl)
		end
	end
end
