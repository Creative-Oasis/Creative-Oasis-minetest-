fmod.check_version({ year = 2023, month = 2, day = 1 })
futil.check_version({ year = 2023, month = 11, day = 1 }) -- is_player

stairsplus = fmod.create()

-- please don't change the order in which things are loaded, without understanding why they're ordered like this
stairsplus.dofile("util")

stairsplus.dofile("api", "init")

stairsplus.dofile("shapes", "init")
stairsplus.dofile("groups", "init")

if stairsplus.settings.crafting_schemata_enabled then
	stairsplus.dofile("craft_schemas", "init")
end

stairsplus.dofile("resources", "init")
stairsplus.dofile("circular_saw")

stairsplus.dofile("compat", "init")

stairsplus.dofile("aliases")

stairsplus.dofile("scripts", "init")
