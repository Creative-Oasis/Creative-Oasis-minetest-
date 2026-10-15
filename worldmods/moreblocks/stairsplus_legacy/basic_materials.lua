local materials = stairsplus_legacy.materials

-- old moreblocks registered things *terribly*, hence these extra aliases
if not stairsplus_legacy.has.gloopblocks then
	stairsplus.api.register_alias_all("gloopblocks:cement", "basic_materials:cement_block")
end

-- old moreblocks registered things *terribly*, hence these extra aliases
if not stairsplus_legacy.has.technic then
	stairsplus.api.register_alias_all("technic:brass_block", "basic_materials:brass_block")
	stairsplus.api.register_alias_all("technic:concrete", "basic_materials:concrete_block")
end

if materials.brass_block and materials.brass_block ~= "basic_materials:brass_block" then
	stairsplus.api.register_alias_all("basic_materials:brass_block", materials.brass_block)
elseif minetest.registered_nodes["basic_materials:brass_block"] then
	stairsplus_legacy.register_legacy("basic_materials:brass_block")
end

if materials.cement_block and materials.cement_block ~= "basic_materials:cement_block" then
	stairsplus.api.register_alias_all("basic_materials:cement_block", materials.cement_block)
elseif minetest.registered_nodes["basic_materials:cement_block"] then
	stairsplus_legacy.register_legacy("basic_materials:cement_block")
end

if materials.concrete_block and materials.concrete_block ~= "basic_materials:concrete_block" then
	stairsplus.api.register_alias_all("basic_materials:concrete_block", materials.concrete_block)
elseif minetest.registered_nodes["basic_materials:concrete_block"] then
	stairsplus_legacy.register_legacy("basic_materials:concrete_block")
end
