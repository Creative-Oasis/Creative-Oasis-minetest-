stairsplus_legacy = fmod.create()

stairsplus_legacy.dofile("resources")

function stairsplus_legacy.register_legacy(node, overrides, meta)
	if stairsplus.settings.legacy_mode then
		stairsplus.api.register_group(node, "legacy", overrides, meta)
	else
		stairsplus.api.register_group(node, "common", overrides, meta)
	end
end

local mods = {
	"basic_materials",
	"default",
	"farming",
	"gloopblocks",
	"technic",
	"prefab",
	"wool",
}

for _, mod in ipairs(mods) do
	if stairsplus_legacy.has[mod] and stairsplus_legacy.settings[mod] then
		stairsplus_legacy.dofile(mod)
	end
end
